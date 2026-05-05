import SwiftUI

/// An item in a focus order sequence with priority and label.
public struct PrismFocusOrderItem: Sendable, Hashable, Identifiable {
    /// Unique identifier for this focus item.
    public let id: String
    /// Human-readable label describing the focusable element.
    public let label: String
    /// Sort priority — higher values are focused first by VoiceOver.
    public let priority: Int

    /// Creates a focus order item with an identifier, label, and priority.
    public init(id: String, label: String, priority: Int) {
        self.id = id
        self.label = label
        self.priority = priority
    }
}

/// Result of validating a focus order sequence.
public struct PrismFocusOrderValidationResult: Sendable, Hashable {
    /// Whether the focus order is valid (items sorted by descending priority).
    public let isValid: Bool
    /// Warnings for out-of-order items.
    public let warnings: [String]

    /// Creates a validation result with validity flag and warning messages.
    public init(isValid: Bool, warnings: [String]) {
        self.isValid = isValid
        self.warnings = warnings
    }
}

/// Validates that focus order items are arranged by descending priority.
public struct PrismFocusOrderValidator: Sendable {

    /// Checks whether items are in correct descending priority order.
    public static func validate(_ items: [PrismFocusOrderItem]) -> PrismFocusOrderValidationResult {
        var warnings: [String] = []
        for i in 0..<items.count - 1 where items[i].priority < items[i + 1].priority {
            warnings.append(
                "'\(items[i].label)' (priority \(items[i].priority)) should come after '\(items[i + 1].label)' (priority \(items[i + 1].priority))"
            )
        }
        return PrismFocusOrderValidationResult(isValid: warnings.isEmpty, warnings: warnings)
    }
}

/// View modifier that sets accessibility sort priority and label for focus ordering.
private struct FocusOrderModifier: ViewModifier {
    let priority: Double
    let label: String

    func body(content: Content) -> some View {
        content
            .accessibilityAddTraits(.isStaticText)
            .accessibilitySortPriority(priority)
            .accessibilityLabel(Text(label))
    }
}

extension View {

    /// Assigns focus order priority and accessibility label for VoiceOver navigation.
    public func prismFocusOrder(priority: Int, label: String) -> some View {
        modifier(FocusOrderModifier(priority: Double(priority), label: label))
    }
}
