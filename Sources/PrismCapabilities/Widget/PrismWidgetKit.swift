#if canImport(WidgetKit)
import WidgetKit

// MARK: - Widget Family

/// The supported widget sizes and form factors.
public enum PrismWidgetFamily: Sendable, CaseIterable {
    case systemSmall
    case systemMedium
    case systemLarge
    case systemExtraLarge
    case accessoryCircular
    case accessoryRectangular
    case accessoryInline
}

// MARK: - Widget Entry

/// A timeline entry that provides data for a widget at a specific date.
public struct PrismWidgetEntry: Sendable {
    /// The date this entry should be displayed.
    public let date: Date
    /// The relevance score for Smart Stack ordering.
    public let relevance: Double?
    /// An optional display name for the entry.
    public let displayName: String?

    public init(date: Date, relevance: Double? = nil, displayName: String? = nil) {
        self.date = date
        self.relevance = relevance
        self.displayName = displayName
    }
}

// MARK: - Reload Policy

/// When the widget timeline should be refreshed.
public enum PrismWidgetReloadPolicy: Sendable {
    case atEnd
    case afterMinutes(Int)
    case never
}

// MARK: - Widget Configuration

/// Describes an active widget instance on the user's device.
public struct PrismWidgetConfiguration: Sendable {
    /// The widget kind identifier.
    public let kind: String
    /// The widget size family.
    public let family: PrismWidgetFamily

    public init(kind: String, family: PrismWidgetFamily) {
        self.kind = kind
        self.family = family
    }
}

// MARK: - Widget Center

/// Utility for reloading widget timelines and querying active configurations.
public struct PrismWidgetCenter: Sendable {

    public init() {}

    /// Reloads timelines for all configured widgets.
    public func reloadAllTimelines() {
        WidgetCenter.shared.reloadAllTimelines()
    }

    /// Reloads the timeline for widgets with the specified kind.
    public func reloadTimeline(kind: String) {
        WidgetCenter.shared.reloadTimelines(ofKind: kind)
    }

    /// Returns the current widget configurations on the user's device.
    public func getCurrentConfigurations() async -> [PrismWidgetConfiguration] {
        await withCheckedContinuation { continuation in
            WidgetCenter.shared.getCurrentConfigurations { result in
                switch result {
                case .success(let infos):
                    let configs = infos.map { info in
                        let family: PrismWidgetFamily = switch info.family {
                        case .systemSmall: .systemSmall
                        case .systemMedium: .systemMedium
                        case .systemLarge: .systemLarge
                        case .systemExtraLarge: .systemExtraLarge
                        case .accessoryCircular: .accessoryCircular
                        case .accessoryRectangular: .accessoryRectangular
                        case .accessoryInline: .accessoryInline
                        @unknown default: .systemSmall
                        }
                        return PrismWidgetConfiguration(kind: info.kind, family: family)
                    }
                    continuation.resume(returning: configs)
                case .failure:
                    continuation.resume(returning: [])
                }
            }
        }
    }
}
#endif
