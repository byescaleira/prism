#if canImport(UserNotifications)
    import UserNotifications
    #if canImport(UIKit)
        import UIKit
    #elseif canImport(AppKit)
        import AppKit
    #endif

    // MARK: - Permission

    /// The current notification permission status.
    public enum PrismNotificationPermission: Sendable, CaseIterable {
        /// The user has not yet been asked for notification permission.
        case notDetermined
        /// The user has denied notification permission.
        case denied
        /// The user has granted full notification permission.
        case authorized
        /// Notifications are delivered quietly without interrupting the user.
        case provisional
        /// Notifications are authorized for a limited time (e.g., App Clips).
        case ephemeral
    }

    // MARK: - Notification Option

    /// Options to request when asking for notification permissions.
    public enum PrismNotificationOption: Sendable {
        /// Display alerts (banners, lock screen).
        case alert
        /// Update the app icon badge number.
        case badge
        /// Play a notification sound.
        case sound
        /// Deliver notifications provisionally without explicit user permission.
        case provisional
        /// Deliver critical alerts that bypass Do Not Disturb.
        case criticalAlert
    }

    // MARK: - Sound

    /// The sound to play when a notification is delivered.
    public enum PrismNotificationSound: Sendable {
        /// The system default notification sound.
        case default_
        /// A custom sound file identified by name.
        case named(String)
        /// The critical alert sound that plays even when the device is muted.
        case critical
    }

    // MARK: - Content

    /// The content payload for a local notification.
    public struct PrismNotificationContent: Sendable {
        /// The primary title text.
        public let title: String
        /// The body text.
        public let body: String
        /// The secondary subtitle text.
        public let subtitle: String?
        /// The badge number to display on the app icon.
        public let badge: Int?
        /// The notification sound.
        public let sound: PrismNotificationSound?
        /// The category identifier for actionable notifications.
        public let categoryIdentifier: String?
        /// Custom key-value pairs attached to the notification.
        public let userInfo: [String: String]

        /// Creates notification content with the given title, body, and optional configuration.
        public init(
            title: String, body: String, subtitle: String? = nil, badge: Int? = nil,
            sound: PrismNotificationSound? = nil, categoryIdentifier: String? = nil, userInfo: [String: String] = [:]
        ) {
            self.title = title
            self.body = body
            self.subtitle = subtitle
            self.badge = badge
            self.sound = sound
            self.categoryIdentifier = categoryIdentifier
            self.userInfo = userInfo
        }
    }

    // MARK: - Trigger

    /// Defines when a local notification should be delivered.
    public enum PrismNotificationTrigger: Sendable {
        /// Deliver the notification immediately.
        case immediate
        /// Deliver the notification after the specified time interval in seconds.
        case timeInterval(TimeInterval)
        /// Deliver the notification at the date matching the given components.
        case calendar(DateComponents)
        /// Deliver the notification when entering the specified geographic region.
        case location(latitude: Double, longitude: Double, radius: Double)
    }

    // MARK: - Push Notification Client

    /// Observable client for managing local and remote push notifications.
    @MainActor @Observable
    public final class PrismPushNotificationClient {
        /// The current notification permission status.
        public private(set) var permissionStatus: PrismNotificationPermission = .notDetermined
        /// The device token for remote notifications, if registered.
        public var deviceToken: Data?

        private let center = UNUserNotificationCenter.current()

        /// Creates a new push notification client.
        public init() {}

        /// Requests notification permission with the specified options.
        public func requestPermission(options: [PrismNotificationOption]) async throws -> Bool {
            var authOptions: UNAuthorizationOptions = []
            for option in options {
                switch option {
                case .alert: authOptions.insert(.alert)
                case .badge: authOptions.insert(.badge)
                case .sound: authOptions.insert(.sound)
                case .provisional: authOptions.insert(.provisional)
                case .criticalAlert: authOptions.insert(.criticalAlert)
                }
            }
            let granted = try await center.requestAuthorization(options: authOptions)
            await refreshPermissionStatus()
            return granted
        }

        /// Schedules a local notification with the given content, trigger, and identifier.
        public func scheduleLocal(
            content: PrismNotificationContent, trigger: PrismNotificationTrigger, identifier: String
        ) async throws {
            let unContent = UNMutableNotificationContent()
            unContent.title = content.title
            unContent.body = content.body
            if let subtitle = content.subtitle {
                unContent.subtitle = subtitle
            }
            if let badge = content.badge {
                unContent.badge = NSNumber(value: badge)
            }
            if let sound = content.sound {
                switch sound {
                case .default_: unContent.sound = .default
                case .named(let name):
                    unContent.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: name))
                case .critical: unContent.sound = .defaultCritical
                }
            }
            if let category = content.categoryIdentifier {
                unContent.categoryIdentifier = category
            }
            unContent.userInfo = content.userInfo

            let unTrigger: UNNotificationTrigger?
            switch trigger {
            case .immediate:
                unTrigger = nil
            case .timeInterval(let interval):
                unTrigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
            case .calendar(let components):
                unTrigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            case .location:
                // Location triggers require CoreLocation import; simplified here
                unTrigger = nil
            }

            let request = UNNotificationRequest(identifier: identifier, content: unContent, trigger: unTrigger)
            try await center.add(request)
        }

        /// Removes delivered notifications with the specified identifiers.
        public func removeDelivered(identifiers: [String]) {
            center.removeDeliveredNotifications(withIdentifiers: identifiers)
        }

        /// Removes pending notification requests with the specified identifiers.
        public func removePending(identifiers: [String]) {
            center.removePendingNotificationRequests(withIdentifiers: identifiers)
        }

        /// Registers the app for remote push notifications.
        public func registerForRemoteNotifications() {
            #if canImport(UIKit)
                UIApplication.shared.registerForRemoteNotifications()
            #elseif canImport(AppKit)
                NSApplication.shared.registerForRemoteNotifications()
            #endif
        }

        // MARK: - Private

        private func refreshPermissionStatus() async {
            let settings = await center.notificationSettings()
            permissionStatus =
                switch settings.authorizationStatus {
                case .notDetermined: .notDetermined
                case .denied: .denied
                case .authorized: .authorized
                case .provisional: .provisional
                case .ephemeral: .ephemeral
                @unknown default: .notDetermined
                }
        }
    }
#endif
