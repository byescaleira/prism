import Foundation

/// Configuration for an incomplete challenge reminder.
public struct PrismChallengeReminder: Sendable {
    public let challengeID: String
    public let intervalSeconds: TimeInterval
    public let title: String
    public let body: String

    public init(challengeID: String, intervalSeconds: TimeInterval, title: String, body: String) {
        self.challengeID = challengeID
        self.intervalSeconds = intervalSeconds
        self.title = title
        self.body = body
    }

    public var notificationIdentifier: String {
        "prism.challenge.\(challengeID)"
    }

    public var notificationRequest: PrismNotificationRequest {
        PrismNotificationRequest(
            identifier: notificationIdentifier,
            title: title,
            body: body,
            trigger: .timeInterval(seconds: intervalSeconds, repeats: true)
        )
    }
}
