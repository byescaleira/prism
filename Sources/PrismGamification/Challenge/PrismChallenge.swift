import Foundation

/// Protocol for enum types that define gamification challenges.
///
/// Each enum case represents a distinct challenge with metadata.
/// The manager bridges these definitions to persisted progress.
///
/// ```swift
/// enum AppChallenge: String, PrismChallenge {
///     case firstLogin
///     case tenWorkouts
///
///     var title: String {
///         switch self {
///         case .firstLogin: "First Login"
///         case .tenWorkouts: "Fitness Streak"
///         }
///     }
///
///     var challengeDescription: String {
///         switch self {
///         case .firstLogin: "Log in for the first time"
///         case .tenWorkouts: "Complete 10 workouts"
///         }
///     }
///
///     var type: PrismChallengeType {
///         switch self {
///         case .firstLogin: .milestone
///         case .tenWorkouts: .counter
///         }
///     }
///
///     var goal: Int {
///         switch self {
///         case .firstLogin: 1
///         case .tenWorkouts: 10
///         }
///     }
/// }
/// ```
public protocol PrismChallenge: RawRepresentable, CaseIterable, Hashable, Sendable
where RawValue == String {
    /// Human-readable title.
    var title: String { get }
    /// Description of what the user needs to do.
    var challengeDescription: String { get }
    /// Whether counter-based or milestone-based.
    var type: PrismChallengeType { get }
    /// Target value. For counters, number to reach. For milestones, always 1.
    var goal: Int { get }
    /// Optional grouping category.
    var category: String? { get }
    /// Optional SF Symbol name.
    var iconName: String? { get }
    /// Points awarded upon completion.
    var points: Int { get }
}

extension PrismChallenge {
    /// The default `category` value.
    public var category: String? { nil }
    /// The default `iconName` value.
    public var iconName: String? { nil }
    /// The default `points` value.
    public var points: Int { 0 }
}
