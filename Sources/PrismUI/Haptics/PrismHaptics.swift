import SwiftUI

/// Haptic feedback types aligned with Apple HIG feedback patterns.
public enum PrismHapticType: Sendable {
    /// Impact feedback with configurable weight.
    case impact(PrismImpactWeight)
    /// Notification feedback for success, warning, or error events.
    case notification(PrismNotificationStyle)
    /// Selection change feedback for picker-like interactions.
    case selection
}

/// Impact weight for haptic feedback.
public enum PrismImpactWeight: Sendable {
    /// Light impact feedback.
    case light
    /// Medium impact feedback.
    case medium
    /// Heavy impact feedback.
    case heavy
    /// Soft impact feedback.
    case soft
    /// Rigid impact feedback.
    case rigid
}

/// Notification haptic style.
public enum PrismNotificationStyle: Sendable {
    /// Success notification feedback.
    case success
    /// Warning notification feedback.
    case warning
    /// Error notification feedback.
    case error
}

/// Platform-adaptive haptic feedback engine.
///
/// Wraps `UIFeedbackGenerator` (iOS), `NSHapticFeedbackManager` (macOS),
/// and `WKInterfaceDevice` (watchOS) behind a unified API.
///
/// ```swift
/// PrismHaptics.play(.impact(.medium))
/// PrismHaptics.play(.notification(.success))
/// ```
@MainActor
public enum PrismHaptics {

    /// Plays haptic feedback of the given type on the current platform.
    public static func play(_ type: PrismHapticType) {
        #if canImport(UIKit) && !os(watchOS) && !os(tvOS)
            playUIKit(type)
        #elseif os(watchOS)
            playWatchOS(type)
        #elseif os(macOS)
            playAppKit(type)
        #endif
    }

    /// Prepares the haptic engine for low-latency feedback on supported platforms.
    public static func prepare(_ type: PrismHapticType) {
        #if canImport(UIKit) && !os(watchOS) && !os(tvOS)
            prepareUIKit(type)
        #endif
    }
}

// MARK: - iOS / iPadOS / visionOS

#if canImport(UIKit) && !os(watchOS) && !os(tvOS)
    import UIKit

    extension PrismHaptics {

        private static func playUIKit(_ type: PrismHapticType) {
            switch type {
            case .impact(let weight):
                let generator = UIImpactFeedbackGenerator(style: weight.uiKitStyle)
                generator.impactOccurred()
            case .notification(let style):
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(style.uiKitType)
            case .selection:
                let generator = UISelectionFeedbackGenerator()
                generator.selectionChanged()
            }
        }

        private static func prepareUIKit(_ type: PrismHapticType) {
            switch type {
            case .impact(let weight):
                UIImpactFeedbackGenerator(style: weight.uiKitStyle).prepare()
            case .notification:
                UINotificationFeedbackGenerator().prepare()
            case .selection:
                UISelectionFeedbackGenerator().prepare()
            }
        }
    }

    extension PrismImpactWeight {
        var uiKitStyle: UIImpactFeedbackGenerator.FeedbackStyle {
            switch self {
            case .light: .light
            case .medium: .medium
            case .heavy: .heavy
            case .soft: .soft
            case .rigid: .rigid
            }
        }
    }

    extension PrismNotificationStyle {
        var uiKitType: UINotificationFeedbackGenerator.FeedbackType {
            switch self {
            case .success: .success
            case .warning: .warning
            case .error: .error
            }
        }
    }
#endif

// MARK: - watchOS

#if os(watchOS)
    import WatchKit

    extension PrismHaptics {

        private static func playWatchOS(_ type: PrismHapticType) {
            let device = WKInterfaceDevice.current()
            switch type {
            case .impact(let weight):
                switch weight {
                case .light, .soft: device.play(.click)
                case .medium: device.play(.directionUp)
                case .heavy, .rigid: device.play(.directionDown)
                }
            case .notification(let style):
                switch style {
                case .success: device.play(.success)
                case .warning: device.play(.retry)
                case .error: device.play(.failure)
                }
            case .selection:
                device.play(.click)
            }
        }
    }
#endif

// MARK: - macOS

#if os(macOS)
    import AppKit

    extension PrismHaptics {

        private static func playAppKit(_ type: PrismHapticType) {
            let performer = NSHapticFeedbackManager.defaultPerformer
            switch type {
            case .impact:
                performer.perform(.alignment, performanceTime: .default)
            case .notification(let style):
                switch style {
                case .success: performer.perform(.levelChange, performanceTime: .default)
                case .warning: performer.perform(.generic, performanceTime: .default)
                case .error: performer.perform(.generic, performanceTime: .default)
                }
            case .selection:
                performer.perform(.generic, performanceTime: .default)
            }
        }
    }
#endif

// MARK: - View Modifier

private struct PrismHapticModifier: ViewModifier {
    let type: PrismHapticType
    let trigger: Bool

    func body(content: Content) -> some View {
        content
            .onChange(of: trigger) { _, newValue in
                if newValue {
                    PrismHaptics.play(type)
                }
            }
    }
}

extension View {

    /// Plays haptic feedback when trigger becomes true.
    public func prismHaptic(_ type: PrismHapticType, trigger: Bool) -> some View {
        modifier(PrismHapticModifier(type: type, trigger: trigger))
    }
}
