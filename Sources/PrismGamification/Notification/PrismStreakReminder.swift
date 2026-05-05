import Foundation

/// Configuration for a streak protection reminder.
public struct PrismStreakReminder: Sendable {
    public let streakID: String
    public let reminderHour: Int
    public let reminderMinute: Int
    public let title: String
    public let body: String

    public init(streakID: String, reminderHour: Int, reminderMinute: Int, title: String, body: String) {
        self.streakID = streakID
        self.reminderHour = reminderHour
        self.reminderMinute = reminderMinute
        self.title = title
        self.body = body
    }

    /// Unique identifier for this reminder's notification.
    public var notificationIdentifier: String {
        "prism.streak.\(streakID)"
    }

    /// Converts to a notification request.
    public var notificationRequest: PrismNotificationRequest {
        PrismNotificationRequest(
            identifier: notificationIdentifier,
            title: title,
            body: body,
            trigger: .daily(hour: reminderHour, minute: reminderMinute)
        )
    }
}
