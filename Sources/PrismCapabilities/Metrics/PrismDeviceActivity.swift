import Foundation

// MARK: - Schedule

/// Defines a daily monitoring window for Screen Time device activity.
public struct PrismDeviceActivitySchedule: Sendable {
    /// The hour component when monitoring begins (0-23).
    public let startHour: Int
    /// The minute component when monitoring begins (0-59).
    public let startMinute: Int
    /// The hour component when monitoring ends (0-23).
    public let endHour: Int
    /// The minute component when monitoring ends (0-59).
    public let endMinute: Int
    /// Whether the schedule repeats daily.
    public let repeats: Bool

    /// Creates a new device activity schedule with the given start and end times.
    public init(startHour: Int, startMinute: Int, endHour: Int, endMinute: Int, repeats: Bool = true) {
        self.startHour = startHour
        self.startMinute = startMinute
        self.endHour = endHour
        self.endMinute = endMinute
        self.repeats = repeats
    }
}

// MARK: - Event

/// A threshold-based event that fires during a device activity monitoring session.
public struct PrismDeviceActivityEvent: Sendable {
    /// The display name for this event.
    public let name: String
    /// The time interval threshold in seconds before the event triggers.
    public let threshold: TimeInterval
    /// Whether the event tracks all app activity or only selected apps.
    public let includesAllActivity: Bool

    /// Creates a new device activity event with the given name and threshold.
    public init(name: String, threshold: TimeInterval, includesAllActivity: Bool = false) {
        self.name = name
        self.threshold = threshold
        self.includesAllActivity = includesAllActivity
    }
}

// MARK: - Device Activity Client

#if canImport(DeviceActivity) && os(iOS)
import DeviceActivity

/// Client that wraps the DeviceActivity framework for Screen Time monitoring.
public final class PrismDeviceActivityClient: Sendable {
    private nonisolated(unsafe) let center = DeviceActivityCenter()

    /// Creates a new device activity client.
    public init() {}

    /// Starts monitoring a named activity with the given schedule and events.
    public func startMonitoring(name: String, schedule: PrismDeviceActivitySchedule, events: [PrismDeviceActivityEvent]) throws {
        let activityName = DeviceActivityName(rawValue: name)
        let startComponents = DateComponents(hour: schedule.startHour, minute: schedule.startMinute)
        let endComponents = DateComponents(hour: schedule.endHour, minute: schedule.endMinute)
        let activitySchedule = DeviceActivitySchedule(
            intervalStart: startComponents,
            intervalEnd: endComponents,
            repeats: schedule.repeats
        )
        let activityEvents: [DeviceActivityEvent.Name: DeviceActivityEvent] = Dictionary(
            uniqueKeysWithValues: events.map { event in
                let eventName = DeviceActivityEvent.Name(rawValue: event.name)
                let activityEvent = DeviceActivityEvent(
                    threshold: DateComponents(second: Int(event.threshold))
                )
                return (eventName, activityEvent)
            }
        )
        try center.startMonitoring(activityName, during: activitySchedule, events: activityEvents)
    }

    /// Stops monitoring the named activity.
    public func stopMonitoring(name: String) {
        center.stopMonitoring([DeviceActivityName(rawValue: name)])
    }

    /// Stops all active monitoring sessions.
    public func stopAllMonitoring() {
        center.stopMonitoring()
    }
}
#endif
