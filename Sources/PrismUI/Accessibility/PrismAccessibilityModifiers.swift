import SwiftUI

extension View {

    /// Adds semantic accessibility label, hint, and value in one call.
    public func prismAccessibility(
        label: Text? = nil,
        hint: Text? = nil,
        value: Text? = nil,
        traits: AccessibilityTraits = [],
        isHidden: Bool = false
    ) -> some View {
        self
            .accessibilityLabel(label ?? Text(""))
            .accessibilityHint(hint ?? Text(""))
            .accessibilityValue(value ?? Text(""))
            .accessibilityAddTraits(traits)
            .accessibilityHidden(isHidden)
    }

    /// Marks view as a semantic header for VoiceOver navigation.
    public func prismAccessibilityHeader() -> some View {
        self.accessibilityAddTraits(.isHeader)
    }

    /// Groups children into a single accessible element.
    public func prismAccessibilityGroup(label: Text) -> some View {
        self
            .accessibilityElement(children: .combine)
            .accessibilityLabel(label)
    }

    /// Adds an accessibility action with a themed name.
    public func prismAccessibilityAction(_ name: Text, action: @escaping () -> Void) -> some View {
        self.accessibilityAction(named: name, action)
    }

    /// Configures sort priority for VoiceOver ordering.
    public func prismAccessibilitySortPriority(_ priority: Double) -> some View {
        self.accessibilitySortPriority(priority)
    }

    /// Posts an accessibility announcement.
    public static func prismAnnounce(_ message: String) {
        #if canImport(UIKit)
            UIAccessibility.post(notification: .announcement, argument: message)
        #elseif canImport(AppKit)
            NSAccessibility.post(
                element: NSApp as Any, notification: .announcementRequested, userInfo: [.announcement: message])
        #endif
    }
}
