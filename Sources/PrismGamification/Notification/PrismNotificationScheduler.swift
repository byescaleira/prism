import Foundation

/// Trigger type for scheduled notifications.
public enum PrismNotificationTrigger: Sendable, Equatable {
    /// Fire after time interval.
    case timeInterval(seconds: TimeInterval, repeats: Bool)
    /// Fire daily at hour:minute.
    case daily(hour: Int, minute: Int)
}

/// A notification request.
public struct PrismNotificationRequest: Sendable {
    public let identifier: String
    public let title: String
    public let body: String
    public let trigger: PrismNotificationTrigger

    public init(identifier: String, title: String, body: String, trigger: PrismNotificationTrigger) {
        self.identifier = identifier
        self.title = title
        self.body = body
        self.trigger = trigger
    }
}

/// Protocol for notification scheduling. Inject a mock for testing.
public protocol PrismNotificationScheduling: Sendable {
    func schedule(_ request: PrismNotificationRequest) async throws
    func cancel(identifier: String) async
    func cancelAll() async
}
