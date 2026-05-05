import SwiftUI

/// Named timeline schedules.
public enum PrismTimelineSchedule: Sendable {
    /// Represents a continuous animation frame schedule.
    case animation
    /// Represents a one-second interval periodic schedule.
    case everySecond
    /// Represents a custom interval periodic schedule.
    case every(TimeInterval)
    /// Represents a schedule with explicit date triggers.
    case explicit([Date])
}

/// Themed TimelineView wrapper for continuous updates.
///
/// ```swift
/// PrismTimelineView(.everySecond) { date in
///     Text(date, style: .timer)
/// }
/// ```
public struct PrismTimelineView<Content: View>: View {
    @Environment(\.prismTheme) private var theme

    private let schedule: PrismTimelineSchedule
    private let content: (Date) -> Content

    /// Creates a timeline view with a schedule and content builder receiving the current date.
    public init(
        _ schedule: PrismTimelineSchedule,
        @ViewBuilder content: @escaping (Date) -> Content
    ) {
        self.schedule = schedule
        self.content = content
    }

    /// The content and behavior of the timeline view.
    public var body: some View {
        switch schedule {
        case .animation:
            TimelineView(.animation) { context in
                content(context.date)
            }
        case .everySecond:
            TimelineView(.periodic(from: .now, by: 1)) { context in
                content(context.date)
            }
        case .every(let interval):
            TimelineView(.periodic(from: .now, by: interval)) { context in
                content(context.date)
            }
        case .explicit(let dates):
            TimelineView(.explicit(dates)) { context in
                content(context.date)
            }
        }
    }
}
