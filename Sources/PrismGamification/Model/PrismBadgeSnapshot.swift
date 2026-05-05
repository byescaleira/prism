#if canImport(SwiftData)
    import Foundation

    /// Sendable snapshot of badge progress, safe to pass across actor boundaries.
    public struct PrismBadgeSnapshot: Sendable {
        /// The badge identifier.
        public let badgeID: String
        /// Whether unlocked.
        public let isUnlocked: Bool
        /// Badge tier raw value.
        public let tierRawValue: String
        /// When unlocked.
        public let unlockedAt: Date?
        /// When created.
        public let createdAt: Date
    }

    extension PrismBadgeProgress {
        /// Creates a Sendable snapshot of this badge progress record.
        public var snapshot: PrismBadgeSnapshot {
            PrismBadgeSnapshot(
                badgeID: badgeID,
                isUnlocked: isUnlocked,
                tierRawValue: tierRawValue,
                unlockedAt: unlockedAt,
                createdAt: createdAt
            )
        }
    }
#endif
