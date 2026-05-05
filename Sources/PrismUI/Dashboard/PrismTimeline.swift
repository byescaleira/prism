import SwiftUI

/// Status of a timeline event.
public enum PrismEventStatus: String, Sendable, CaseIterable {
    case completed
    case current
    case upcoming
    case failed

    /// Semantic color for the event status.
    public var colorToken: ColorToken {
        switch self {
        case .completed: .success
        case .current: .interactive
        case .upcoming: .onBackgroundTertiary
        case .failed: .error
        }
    }

    /// SF Symbol for the event status dot.
    public var systemImage: String {
        switch self {
        case .completed: "checkmark.circle.fill"
        case .current: "circle.fill"
        case .upcoming: "circle"
        case .failed: "xmark.circle.fill"
        }
    }
}

/// A single event in a vertical timeline.
public struct PrismTimelineEvent: Sendable, Identifiable {
    /// Unique identifier.
    public let id: UUID
    /// Event title.
    public let title: String
    /// Optional longer description.
    public let description: String?
    /// When the event occurred or is scheduled.
    public let date: Date
    /// Current status of the event.
    public let status: PrismEventStatus
    /// Optional SF Symbol name.
    public let icon: String?

    /// Creates a timeline event with title, date, status, and optional description.
    public init(
        id: UUID = UUID(),
        title: String,
        description: String? = nil,
        date: Date,
        status: PrismEventStatus,
        icon: String? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.date = date
        self.status = status
        self.icon = icon
    }
}

/// Vertical timeline with a connecting line and status-colored dots.
public struct PrismTimeline: View {
    @Environment(\.prismTheme) private var theme

    private let events: [PrismTimelineEvent]

    /// Creates a timeline from an ordered array of events.
    public init(events: [PrismTimelineEvent]) {
        self.events = events
    }

    /// The timeline view body with connecting line and status-colored dots.
    public var body: some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            ForEach(Array(events.enumerated()), id: \.element.id) { index, event in
                timelineRow(event, isLast: index == events.count - 1)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Timeline")
    }

    private func timelineRow(_ event: PrismTimelineEvent, isLast: Bool) -> some View {
        HStack(alignment: .top, spacing: SpacingToken.md.rawValue) {
            // Status indicator column
            VStack(spacing: 0) {
                statusDot(event)
                if !isLast {
                    Rectangle()
                        .fill(theme.color(.separator))
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                }
            }
            .frame(width: 24)

            // Content column
            VStack(alignment: .leading, spacing: SpacingToken.xxs.rawValue) {
                Text(event.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(
                        theme.color(
                            event.status == .upcoming ? .onBackgroundSecondary : .onBackground
                        ))
                if let description = event.description {
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(theme.color(.onBackgroundSecondary))
                }
                Text(formattedDate(event.date))
                    .font(.caption2)
                    .foregroundStyle(theme.color(.onBackgroundTertiary))
            }
            .padding(.bottom, isLast ? 0 : SpacingToken.lg.rawValue)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(event.title), \(event.status.rawValue)")
    }

    private func statusDot(_ event: PrismTimelineEvent) -> some View {
        Image(systemName: event.icon ?? event.status.systemImage)
            .font(.caption)
            .foregroundStyle(theme.color(event.status.colorToken))
            .frame(width: 24, height: 24)
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
