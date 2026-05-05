#if canImport(SwiftData)
    import Foundation
    import SwiftData

    /// Persisted progress for a single badge, synced to CloudKit.
    @Model
    public final class PrismBadgeProgress {
        /// Stable identifier matching the PrismBadge enum rawValue.
        @Attribute(.unique)
        public var badgeID: String

        /// Whether the badge has been unlocked.
        public var isUnlocked: Bool

        /// Badge tier raw value.
        public var tierRawValue: String

        /// When the badge was unlocked.
        public var unlockedAt: Date?

        /// When the record was first created.
        public var createdAt: Date

        /// Creates a new `PrismBadgeProgress` with the specified configuration.
        public init(
            badgeID: String,
            isUnlocked: Bool = false,
            tierRawValue: String,
            unlockedAt: Date? = nil,
            createdAt: Date = .now
        ) {
            self.badgeID = badgeID
            self.isUnlocked = isUnlocked
            self.tierRawValue = tierRawValue
            self.unlockedAt = unlockedAt
            self.createdAt = createdAt
        }
    }
#endif
