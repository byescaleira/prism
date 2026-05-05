import PrismFoundation
import SwiftUI

/// Analytics tracking modifier that fires events on view appearance.
private struct AnalyticsTrackModifier: ViewModifier {
    @Environment(\.prismAnalyticsProvider) private var provider
    let event: PrismAnalyticsEvent

    func body(content: Content) -> some View {
        content.onAppear {
            provider?.track(event)
        }
    }
}

// MARK: - Environment

private struct PrismAnalyticsProviderKey: @preconcurrency EnvironmentKey {
    @MainActor static let defaultValue: (any PrismAnalyticsProvider)? = nil
}

extension EnvironmentValues {
    /// The analytics provider used to track events in the view hierarchy.
    public var prismAnalyticsProvider: (any PrismAnalyticsProvider)? {
        get { self[PrismAnalyticsProviderKey.self] }
        set { self[PrismAnalyticsProviderKey.self] = newValue }
    }
}

extension View {

    /// Injects an analytics provider into the view hierarchy.
    public func prismAnalytics(_ provider: some PrismAnalyticsProvider) -> some View {
        environment(\.prismAnalyticsProvider, provider)
    }

    /// Tracks an analytics event when this view appears.
    public func prismTrack(_ event: PrismAnalyticsEvent) -> some View {
        modifier(AnalyticsTrackModifier(event: event))
    }

    /// Tracks a screen view event when this view appears.
    public func prismTrackScreen(_ name: String) -> some View {
        modifier(AnalyticsTrackModifier(event: .screenView(name: name)))
    }
}
