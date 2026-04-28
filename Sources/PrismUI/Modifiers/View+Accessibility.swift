import SwiftUI

extension View {

    /// Applies accessibility label and optional hint.
    public func prismAccessibility(
        label: LocalizedStringKey,
        hint: LocalizedStringKey? = nil,
        traits: AccessibilityTraits = []
    ) -> some View {
        let modified = self
            .accessibilityLabel(label)
            .accessibilityAddTraits(traits)

        if let hint {
            return AnyView(modified.accessibilityHint(hint))
        }
        return AnyView(modified)
    }

    /// Assigns a stable test identifier for UI testing.
    public func prismTestID(_ id: String) -> some View {
        accessibilityIdentifier(id)
    }

    /// Hides the view from assistive technologies.
    public func prismAccessibilityHidden() -> some View {
        accessibilityHidden(true)
    }
}
