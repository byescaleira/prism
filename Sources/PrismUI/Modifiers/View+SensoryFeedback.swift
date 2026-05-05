import SwiftUI

/// Named sensory feedback types matching SwiftUI's `.sensoryFeedback`.
public enum PrismSensoryFeedback: Sendable {
    /// Represents a success haptic feedback.
    case success
    /// Represents a warning haptic feedback.
    case warning
    /// Represents an error haptic feedback.
    case error
    /// Represents a selection change haptic feedback.
    case selection
    /// Represents an increase haptic feedback.
    case increase
    /// Represents a decrease haptic feedback.
    case decrease
    /// Represents an activity start haptic feedback.
    case start
    /// Represents an activity stop haptic feedback.
    case stop
    /// Represents an alignment haptic feedback.
    case alignment
    /// Represents a level change haptic feedback.
    case levelChange
    /// Represents a physical impact haptic feedback.
    case impact

    @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
    var native: SensoryFeedback {
        switch self {
        case .success: .success
        case .warning: .warning
        case .error: .error
        case .selection: .selection
        case .increase: .increase
        case .decrease: .decrease
        case .start: .start
        case .stop: .stop
        case .alignment: .alignment
        case .levelChange: .levelChange
        case .impact: .impact
        }
    }
}

extension View {

    /// Triggers sensory feedback when a value changes.
    @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
    public func prismSensoryFeedback<T: Equatable>(
        _ feedback: PrismSensoryFeedback,
        trigger: T
    ) -> some View {
        sensoryFeedback(feedback.native, trigger: trigger)
    }
}
