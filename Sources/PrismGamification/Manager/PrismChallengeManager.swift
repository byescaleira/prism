#if canImport(SwiftData)
    import Foundation
    import SwiftData

    /// Primary entry point for gamification features.
    ///
    /// Bridges enum-based challenge definitions to persisted SwiftData progress
    /// with optional CloudKit sync.
    ///
    /// ```swift
    /// let container = try PrismChallengeContainerProvider.makeContainer(
    ///     cloudKitContainerIdentifier: "iCloud.com.app"
    /// )
    /// let manager = PrismChallengeManager(container: container)
    ///
    /// try await manager.register(AppChallenge.self)
    /// try await manager.increment(.tenWorkouts)
    /// try await manager.complete(.firstLogin)
    ///
    /// let done = try await manager.isCompleted(.firstLogin)
    /// let streak = try await manager.currentStreak("daily")
    /// ```
    public actor PrismChallengeManager: ModelActor {
        /// The model executor.
        public nonisolated let modelExecutor: any ModelExecutor
        /// The model container.
        public nonisolated let modelContainer: ModelContainer
        /// Stream of challenge events for UI observation.
        public nonisolated let events: AsyncStream<PrismChallengeEvent>
        nonisolated let eventContinuation: AsyncStream<PrismChallengeEvent>.Continuation

        /// Creates a challenge manager backed by the given ModelContainer.
        public init(container: ModelContainer) {
            self.modelContainer = container
            let context = ModelContext(container)
            self.modelExecutor = DefaultSerialModelExecutor(modelContext: context)
            let (stream, continuation) = AsyncStream.makeStream(of: PrismChallengeEvent.self)
            self.events = stream
            self.eventContinuation = continuation
        }

        // MARK: - Registration

        /// Registers all cases of a PrismChallenge enum, creating progress records for new challenges.
        public func register<C: PrismChallenge>(_ challengeType: C.Type) throws {
            for challenge in C.allCases {
                let id = challenge.rawValue
                let descriptor = FetchDescriptor<PrismChallengeProgress>(
                    predicate: #Predicate { $0.challengeID == id }
                )
                let existing = try modelContext.fetch(descriptor)
                if existing.isEmpty {
                    let record = PrismChallengeProgress(
                        challengeID: id,
                        goalValue: challenge.goal,
                        typeRawValue: challenge.type.rawValue
                    )
                    modelContext.insert(record)
                }
            }
            try modelContext.save()
        }

        // MARK: - Increment

        /// Increments a counter challenge by the given amount.
        @discardableResult
        public func increment<C: PrismChallenge>(
            _ challenge: C,
            by amount: Int = 1
        ) throws -> PrismChallengeSnapshot {
            let record = try fetchProgress(for: challenge.rawValue)

            guard !record.isCompleted else {
                throw PrismGamificationError.challengeAlreadyCompleted(challenge.rawValue)
            }
            guard record.typeRawValue == PrismChallengeType.counter.rawValue else {
                throw PrismGamificationError.invalidOperation(
                    "Cannot increment milestone challenge '\(challenge.rawValue)'. Use complete() instead."
                )
            }

            record.currentValue = min(record.currentValue + amount, record.goalValue)
            record.updatedAt = .now

            if record.currentValue >= record.goalValue {
                record.isCompleted = true
                record.completedAt = .now
                eventContinuation.yield(.completed(challengeID: challenge.rawValue, points: challenge.points))
            } else {
                eventContinuation.yield(.progressed(
                    challengeID: challenge.rawValue,
                    currentValue: record.currentValue,
                    goalValue: record.goalValue
                ))
            }

            try modelContext.save()
            return record.snapshot
        }

        // MARK: - Complete

        /// Marks a milestone challenge as completed.
        @discardableResult
        public func complete<C: PrismChallenge>(_ challenge: C) throws -> PrismChallengeSnapshot {
            let record = try fetchProgress(for: challenge.rawValue)

            guard !record.isCompleted else {
                throw PrismGamificationError.challengeAlreadyCompleted(challenge.rawValue)
            }

            record.currentValue = record.goalValue
            record.isCompleted = true
            record.updatedAt = .now
            record.completedAt = .now

            eventContinuation.yield(.completed(challengeID: challenge.rawValue, points: challenge.points))
            try modelContext.save()
            return record.snapshot
        }

        // MARK: - Query

        /// Returns progress snapshot for a challenge.
        public func progress<C: PrismChallenge>(for challenge: C) throws -> PrismChallengeSnapshot {
            try fetchProgress(for: challenge.rawValue).snapshot
        }

        /// Returns whether a challenge has been completed.
        public func isCompleted<C: PrismChallenge>(_ challenge: C) throws -> Bool {
            try fetchProgress(for: challenge.rawValue).isCompleted
        }

        /// Returns all registered progress snapshots.
        public func allProgress() throws -> [PrismChallengeSnapshot] {
            let descriptor = FetchDescriptor<PrismChallengeProgress>(
                sortBy: [SortDescriptor(\.createdAt)]
            )
            return try modelContext.fetch(descriptor).map(\.snapshot)
        }

        /// Returns total points earned from completed challenges.
        public func totalPoints<C: PrismChallenge>(_ challengeType: C.Type) throws -> Int {
            let allRecords = try allProgress()
            let completedIDs = Set(allRecords.filter(\.isCompleted).map(\.challengeID))
            return C.allCases
                .filter { completedIDs.contains($0.rawValue) }
                .reduce(0) { $0 + $1.points }
        }

        // MARK: - Reset

        /// Resets a single challenge to zero progress.
        public func reset<C: PrismChallenge>(_ challenge: C) throws {
            let record = try fetchProgress(for: challenge.rawValue)
            record.currentValue = 0
            record.isCompleted = false
            record.completedAt = nil
            record.updatedAt = .now
            try modelContext.save()
        }

        /// Resets all challenges of the given type.
        public func resetAll<C: PrismChallenge>(_ challengeType: C.Type) throws {
            for challenge in C.allCases {
                let record = try fetchProgress(for: challenge.rawValue)
                record.currentValue = 0
                record.isCompleted = false
                record.completedAt = nil
                record.updatedAt = .now
            }
            try modelContext.save()
        }

        // MARK: - Streaks

        /// Records a streak-qualifying activity for today.
        public func recordStreakActivity(_ streakID: String, calendar: Calendar = .current) throws {
            let record = try fetchOrCreateStreak(streakID)
            let today = calendar.startOfDay(for: .now)

            if let lastDate = record.lastActivityDate {
                let lastDay = calendar.startOfDay(for: lastDate)

                if lastDay == today { return }

                let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
                if lastDay == calendar.startOfDay(for: yesterday) {
                    record.currentStreak += 1
                } else {
                    let previousStreak = record.currentStreak
                    record.currentStreak = 1
                    eventContinuation.yield(.streakBroken(streakID: streakID, previousStreak: previousStreak))
                }
            } else {
                record.currentStreak = 1
            }

            record.lastActivityDate = today
            record.totalActiveDays += 1

            if record.currentStreak > record.longestStreak {
                record.longestStreak = record.currentStreak
                eventContinuation.yield(.newStreakRecord(streakID: streakID, longestStreak: record.longestStreak))
            }

            eventContinuation.yield(.streakExtended(streakID: streakID, currentStreak: record.currentStreak))
            try modelContext.save()
        }

        /// Returns current streak count.
        public func currentStreak(_ streakID: String) throws -> Int {
            try fetchStreak(streakID).currentStreak
        }

        /// Returns longest-ever streak.
        public func longestStreak(_ streakID: String) throws -> Int {
            try fetchStreak(streakID).longestStreak
        }

        /// Returns full streak snapshot.
        public func streakRecord(_ streakID: String) throws -> PrismStreakSnapshot {
            try fetchStreak(streakID).snapshot
        }

        /// Resets a streak to zero.
        public func resetStreak(_ streakID: String) throws {
            let record = try fetchStreak(streakID)
            record.currentStreak = 0
            record.lastActivityDate = nil
            try modelContext.save()
        }

        // MARK: - Private

        private func fetchProgress(for challengeID: String) throws -> PrismChallengeProgress {
            let descriptor = FetchDescriptor<PrismChallengeProgress>(
                predicate: #Predicate { $0.challengeID == challengeID }
            )
            guard let record = try modelContext.fetch(descriptor).first else {
                throw PrismGamificationError.challengeNotFound(challengeID)
            }
            return record
        }

        private func fetchStreak(_ streakID: String) throws -> PrismStreakRecord {
            let descriptor = FetchDescriptor<PrismStreakRecord>(
                predicate: #Predicate { $0.streakID == streakID }
            )
            guard let record = try modelContext.fetch(descriptor).first else {
                throw PrismGamificationError.streakNotFound(streakID)
            }
            return record
        }

        private func fetchOrCreateStreak(_ streakID: String) throws -> PrismStreakRecord {
            let descriptor = FetchDescriptor<PrismStreakRecord>(
                predicate: #Predicate { $0.streakID == streakID }
            )
            if let existing = try modelContext.fetch(descriptor).first {
                return existing
            }
            let record = PrismStreakRecord(streakID: streakID)
            modelContext.insert(record)
            return record
        }
    }
#endif
