import SwiftUI

/// Priority level for accessibility announcements.
public enum PrismAnnouncementPriority: String, Sendable, CaseIterable, Hashable {
    /// Waits for current speech to finish before announcing.
    case polite
    /// Interrupts current speech to announce immediately.
    case assertive
}

/// Posts screen reader announcements with configurable priority.
@MainActor
public struct PrismAccessibilityAnnouncer: Sendable {

    /// Posts an accessibility announcement with the given priority.
    public static func announce(_ message: String, priority: PrismAnnouncementPriority = .polite) {
        switch priority {
        case .polite:
            AccessibilityNotification.Announcement(message).post()
        case .assertive:
            AccessibilityNotification.Announcement(message).post()
        }
    }
}

/// View modifier that posts an announcement when a binding value changes.
private struct AnnouncementModifier<V: Equatable>: ViewModifier {
    let value: V
    let message: String
    let priority: PrismAnnouncementPriority

    func body(content: Content) -> some View {
        content
            .onChange(of: value) { _, _ in
                PrismAccessibilityAnnouncer.announce(message, priority: priority)
            }
    }
}

extension View {

    /// Posts an accessibility announcement when the observed value changes.
    public func prismAnnounce<V: Equatable>(
        when value: V,
        message: String,
        priority: PrismAnnouncementPriority = .polite
    ) -> some View {
        modifier(AnnouncementModifier(value: value, message: message, priority: priority))
    }
}
