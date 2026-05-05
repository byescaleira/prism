#if canImport(SwiftData)
    import Foundation
    import SwiftData

    extension PrismChallengeManager {
        // MARK: - Submit Score

        /// Submits or updates a score for a user in the given period.
        ///
        /// Creates a new leaderboard record if none exists for the user/period pair,
        /// or updates the existing record's score. After saving, computes the user's
        /// new rank and emits a `.leaderboardUpdated` event.
        ///
        /// - Parameters:
        ///   - userID: Unique identifier for the user.
        ///   - displayName: The user's display name shown on the leaderboard.
        ///   - score: The score to set.
        ///   - period: The leaderboard period to submit to.
        /// - Returns: The user's leaderboard entry with current rank.
        @discardableResult
        public func submitScore(
            userID: String,
            displayName: String,
            score: Int,
            period: PrismLeaderboardPeriod
        ) throws -> PrismLeaderboardEntry {
            let entryID = "\(userID)_\(period.rawValue)"

            if let existing = try fetchLeaderboardRecordIfExists(entryID: entryID) {
                existing.score = score
                existing.displayName = displayName
                existing.updatedAt = .now
            } else {
                let record = PrismLeaderboardRecord(
                    entryID: entryID,
                    userID: userID,
                    displayName: displayName,
                    score: score,
                    periodRawValue: period.rawValue
                )
                modelContext.insert(record)
            }

            try modelContext.save()

            let rank = try computeRank(for: userID, period: period)
            eventContinuation.yield(.leaderboardUpdated(userID: userID, newRank: rank))
            return PrismLeaderboardEntry(id: userID, displayName: displayName, score: score, rank: rank)
        }

        // MARK: - Update Score

        /// Updates the score for an existing leaderboard entry.
        ///
        /// - Parameters:
        ///   - userID: The user whose score to update.
        ///   - score: The new score value.
        ///   - period: The leaderboard period.
        /// - Returns: The updated leaderboard entry with current rank.
        /// - Throws: ``PrismGamificationError/leaderboardEntryNotFound(_:)`` if no record exists.
        @discardableResult
        public func updateScore(
            userID: String,
            score: Int,
            period: PrismLeaderboardPeriod
        ) throws -> PrismLeaderboardEntry {
            let record = try fetchLeaderboardRecord(userID: userID, period: period)
            record.score = score
            record.updatedAt = .now
            try modelContext.save()

            let rank = try computeRank(for: userID, period: period)
            eventContinuation.yield(.leaderboardUpdated(userID: userID, newRank: rank))
            return record.toEntry(rank: rank)
        }

        // MARK: - Leaderboard Query

        /// Returns a ranked leaderboard snapshot for the given period.
        ///
        /// - Parameters:
        ///   - period: The leaderboard period to query.
        ///   - limit: Maximum number of entries to return. Defaults to 100.
        /// - Returns: A ``PrismLeaderboardSnapshot`` with ranked entries.
        public func leaderboard(
            period: PrismLeaderboardPeriod,
            limit: Int = 100
        ) throws -> PrismLeaderboardSnapshot {
            let periodValue = period.rawValue
            let descriptor = FetchDescriptor<PrismLeaderboardRecord>(
                predicate: #Predicate { $0.periodRawValue == periodValue },
                sortBy: [SortDescriptor(\.score, order: .reverse)]
            )
            let records = try modelContext.fetch(descriptor)
            let limited = records.prefix(limit)

            let entries = limited.enumerated().map { index, record in
                record.toEntry(rank: index + 1)
            }

            return PrismLeaderboardSnapshot(
                entries: entries,
                period: period,
                generatedAt: .now
            )
        }

        // MARK: - Rank Query

        /// Returns the rank and entry for a specific user in the given period.
        ///
        /// - Parameters:
        ///   - userID: The user to look up.
        ///   - period: The leaderboard period.
        /// - Returns: The user's ``PrismLeaderboardEntry`` with computed rank.
        /// - Throws: ``PrismGamificationError/leaderboardEntryNotFound(_:)`` if no record exists.
        public func rank(
            for userID: String,
            period: PrismLeaderboardPeriod
        ) throws -> PrismLeaderboardEntry {
            let record = try fetchLeaderboardRecord(userID: userID, period: period)
            let rank = try computeRank(for: userID, period: period)
            return record.toEntry(rank: rank)
        }

        // MARK: - Reset

        /// Deletes all leaderboard entries for the given period.
        ///
        /// - Parameter period: The leaderboard period to reset.
        public func resetLeaderboard(period: PrismLeaderboardPeriod) throws {
            let periodValue = period.rawValue
            let descriptor = FetchDescriptor<PrismLeaderboardRecord>(
                predicate: #Predicate { $0.periodRawValue == periodValue }
            )
            let records = try modelContext.fetch(descriptor)
            for record in records {
                modelContext.delete(record)
            }
            try modelContext.save()
        }

        // MARK: - Private

        private func fetchLeaderboardRecord(
            userID: String,
            period: PrismLeaderboardPeriod
        ) throws -> PrismLeaderboardRecord {
            let entryID = "\(userID)_\(period.rawValue)"
            let descriptor = FetchDescriptor<PrismLeaderboardRecord>(
                predicate: #Predicate { $0.entryID == entryID }
            )
            guard let record = try modelContext.fetch(descriptor).first else {
                throw PrismGamificationError.leaderboardEntryNotFound(userID)
            }
            return record
        }

        private func fetchLeaderboardRecordIfExists(
            entryID: String
        ) throws -> PrismLeaderboardRecord? {
            let descriptor = FetchDescriptor<PrismLeaderboardRecord>(
                predicate: #Predicate { $0.entryID == entryID }
            )
            return try modelContext.fetch(descriptor).first
        }

        private func computeRank(
            for userID: String,
            period: PrismLeaderboardPeriod
        ) throws -> Int {
            let periodValue = period.rawValue
            let descriptor = FetchDescriptor<PrismLeaderboardRecord>(
                predicate: #Predicate { $0.periodRawValue == periodValue },
                sortBy: [SortDescriptor(\.score, order: .reverse)]
            )
            let records = try modelContext.fetch(descriptor)
            guard let index = records.firstIndex(where: { $0.userID == userID }) else {
                throw PrismGamificationError.leaderboardEntryNotFound(userID)
            }
            return index + 1
        }
    }
#endif
