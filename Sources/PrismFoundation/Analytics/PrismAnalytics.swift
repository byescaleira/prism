//
//  PrismAnalytics.swift
//  Prism
//
//  Created by Rafael Escaleira on 27/04/26.
//

import Foundation

/// Provider-agnostic analytics protocol for the Prism framework.
///
/// Conform to this protocol to integrate any analytics backend
/// (Firebase, Mixpanel, Amplitude, custom) with Prism's automatic
/// component tracking.
///
/// ## Implementation
/// ```swift
/// struct FirebaseAnalytics: PrismAnalyticsProvider {
///     func track(_ event: PrismAnalyticsEvent) {
///         Analytics.logEvent(event.name, parameters: event.parameters)
///     }
/// }
/// ```
///
/// ## Registration
/// ```swift
/// ContentView()
///     .prism(analytics: FirebaseAnalytics())
/// ```
public protocol PrismAnalyticsProvider: Sendable {
    /// Tracks a single analytics event.
    func track(_ event: PrismAnalyticsEvent)
}

/// A structured analytics event emitted by Prism components.
public struct PrismAnalyticsEvent: Sendable, Equatable {
    /// The event name (e.g., "button_tap", "screen_view").
    public let name: String
    /// Key-value parameters attached to the event.
    public let parameters: [String: String]
    /// Timestamp when the event was created.
    public let timestamp: Date

    /// Creates an analytics event with the given name, parameters, and timestamp.
    public init(
        name: String,
        parameters: [String: String] = [:],
        timestamp: Date = .now
    ) {
        self.name = name
        self.parameters = parameters
        self.timestamp = timestamp
    }
}

// MARK: - Event Categories

extension PrismAnalyticsEvent {
    /// A button was tapped.
    public static func buttonTap(
        label: String,
        testID: String = ""
    ) -> PrismAnalyticsEvent {
        PrismAnalyticsEvent(
            name: "button_tap",
            parameters: [
                "label": label,
                "test_id": testID,
            ]
        )
    }

    /// A screen became visible.
    public static func screenView(
        name: String,
        route: String = ""
    ) -> PrismAnalyticsEvent {
        PrismAnalyticsEvent(
            name: "screen_view",
            parameters: [
                "screen_name": name,
                "route": route,
            ]
        )
    }

    /// A text field received or lost focus.
    public static func fieldInteraction(
        testID: String,
        action: String
    ) -> PrismAnalyticsEvent {
        PrismAnalyticsEvent(
            name: "field_interaction",
            parameters: [
                "test_id": testID,
                "action": action,
            ]
        )
    }

    /// A carousel scrolled to a new item.
    public static func carouselScroll(
        testID: String,
        index: Int
    ) -> PrismAnalyticsEvent {
        PrismAnalyticsEvent(
            name: "carousel_scroll",
            parameters: [
                "test_id": testID,
                "index": String(index),
            ]
        )
    }

    /// A tab was selected.
    public static func tabSelect(
        testID: String,
        tab: String
    ) -> PrismAnalyticsEvent {
        PrismAnalyticsEvent(
            name: "tab_select",
            parameters: [
                "test_id": testID,
                "tab": tab,
            ]
        )
    }

    /// A menu item was activated.
    public static func menuAction(
        testID: String,
        action: String
    ) -> PrismAnalyticsEvent {
        PrismAnalyticsEvent(
            name: "menu_action",
            parameters: [
                "test_id": testID,
                "action": action,
            ]
        )
    }

    /// A custom event with arbitrary name and parameters.
    public static func custom(
        _ name: String,
        parameters: [String: String] = [:]
    ) -> PrismAnalyticsEvent {
        PrismAnalyticsEvent(name: name, parameters: parameters)
    }
}
