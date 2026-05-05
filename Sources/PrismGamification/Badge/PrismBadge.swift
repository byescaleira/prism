import Foundation

/// Protocol for enum types that define gamification badges.
///
/// Each enum case represents a distinct badge with metadata.
/// The manager bridges these definitions to persisted progress.
///
/// ```swift
/// enum AppBadge: String, PrismBadge {
///     case earlyAdopter
///     case streakMaster
///
///     var title: String {
///         switch self {
///         case .earlyAdopter: "Early Adopter"
///         case .streakMaster: "Streak Master"
///         }
///     }
///
///     var badgeDescription: String {
///         switch self {
///         case .earlyAdopter: "Complete your first challenge"
///         case .streakMaster: "Maintain a 30-day streak"
///         }
///     }
///
///     var tier: PrismBadgeTier {
///         switch self {
///         case .earlyAdopter: .bronze
///         case .streakMaster: .gold
///         }
///     }
///
///     var condition: PrismBadgeCondition {
///         switch self {
///         case .earlyAdopter: .challengeCompleted(challengeID: "firstLogin")
///         case .streakMaster: .streakReached(streakID: "daily", days: 30)
///         }
///     }
/// }
/// ```
public protocol PrismBadge: RawRepresentable, CaseIterable, Hashable, Sendable
where RawValue == String {
    /// Human-readable title.
    var title: String { get }
    /// Description of what the user needs to achieve.
    var badgeDescription: String { get }
    /// Optional SF Symbol name.
    var iconName: String? { get }
    /// Badge tier level.
    var tier: PrismBadgeTier { get }
    /// Condition required to unlock this badge.
    var condition: PrismBadgeCondition { get }
}

extension PrismBadge {
    /// The default `iconName` value.
    public var iconName: String? { nil }
}
