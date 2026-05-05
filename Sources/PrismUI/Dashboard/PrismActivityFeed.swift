import SwiftUI

/// A single activity entry in a feed.
public struct PrismActivity: Sendable, Identifiable {
    /// Unique identifier.
    public let id: UUID
    /// User who performed the action.
    public let user: String
    /// Action description (e.g. "commented on").
    public let action: String
    /// Target of the action (e.g. "Issue #42").
    public let target: String
    /// When the activity happened.
    public let timestamp: Date
    /// Optional SF Symbol name.
    public let icon: String?

    /// Creates an activity entry with user, action, target, and timestamp.
    public init(
        id: UUID = UUID(),
        user: String,
        action: String,
        target: String,
        timestamp: Date,
        icon: String? = nil
    ) {
        self.id = id
        self.user = user
        self.action = action
        self.target = target
        self.timestamp = timestamp
        self.icon = icon
    }
}

/// Chronological feed of activities with avatars and relative timestamps.
public struct PrismActivityFeed: View {
    @Environment(\.prismTheme) private var theme

    private let activities: [PrismActivity]
    private let groupByDate: Bool

    /// Creates an activity feed with optional date grouping.
    public init(
        activities: [PrismActivity],
        groupByDate: Bool = false
    ) {
        self.activities = activities
        self.groupByDate = groupByDate
    }

    /// The activity feed view body with flat or date-grouped layout.
    public var body: some View {
        if groupByDate {
            groupedContent
        } else {
            flatContent
        }
    }

    private var flatContent: some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            ForEach(activities) { activity in
                activityRow(activity)
                if activity.id != activities.last?.id {
                    Divider()
                        .padding(.leading, SpacingToken.xxxl.rawValue)
                }
            }
        }
        .accessibilityLabel("Activity feed")
    }

    private var groupedContent: some View {
        let groups = PrismActivityGroup.group(activities)
        return LazyVStack(alignment: .leading, spacing: SpacingToken.lg.rawValue) {
            ForEach(groups) { group in
                Section {
                    ForEach(group.activities) { activity in
                        activityRow(activity)
                    }
                } header: {
                    Text(group.title)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(theme.color(.onBackgroundSecondary))
                        .padding(.leading, SpacingToken.sm.rawValue)
                }
            }
        }
        .accessibilityLabel("Activity feed grouped by date")
    }

    private func activityRow(_ activity: PrismActivity) -> some View {
        HStack(alignment: .top, spacing: SpacingToken.sm.rawValue) {
            avatar(for: activity)
            VStack(alignment: .leading, spacing: SpacingToken.xxs.rawValue) {
                HStack(spacing: SpacingToken.xxs.rawValue) {
                    Text(activity.user)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(theme.color(.onBackground))
                    Text(activity.action)
                        .font(.subheadline)
                        .foregroundStyle(theme.color(.onBackgroundSecondary))
                    Text(activity.target)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(theme.color(.interactive))
                }
                Text(relativeTimestamp(activity.timestamp))
                    .font(.caption2)
                    .foregroundStyle(theme.color(.onBackgroundTertiary))
            }
            Spacer()
        }
        .padding(.vertical, SpacingToken.sm.rawValue)
        .padding(.horizontal, SpacingToken.sm.rawValue)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(activity.user) \(activity.action) \(activity.target)")
    }

    private func avatar(for activity: PrismActivity) -> some View {
        ZStack {
            Circle()
                .fill(theme.color(.surfaceSecondary))
                .frame(width: 32, height: 32)
            if let icon = activity.icon {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(theme.color(.brand))
            } else {
                Text(String(activity.user.prefix(1)).uppercased())
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(theme.color(.onSurface))
            }
        }
    }

    private func relativeTimestamp(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

/// Groups activities by calendar date for sectioned display.
public struct PrismActivityGroup: Sendable, Identifiable {
    /// Unique identifier for this activity group.
    public let id = UUID()
    /// Section title (e.g. "Today", "Yesterday", or a formatted date).
    public let title: String
    /// Activities in this date group.
    public let activities: [PrismActivity]

    /// Groups an array of activities by calendar date.
    public static func group(_ activities: [PrismActivity]) -> [PrismActivityGroup] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: activities) { activity in
            calendar.startOfDay(for: activity.timestamp)
        }
        return grouped
            .sorted { $0.key > $1.key }
            .map { date, items in
                PrismActivityGroup(
                    title: formatGroupDate(date),
                    activities: items.sorted { $0.timestamp > $1.timestamp }
                )
            }
    }

    private static func formatGroupDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) { return "Today" }
        if calendar.isDateInYesterday(date) { return "Yesterday" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
