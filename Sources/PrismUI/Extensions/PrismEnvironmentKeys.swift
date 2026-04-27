//
//  PrismEnvironmentKeys.swift
//  Prism
//
//  Created by Rafael Escaleira on 27/04/26.
//

import PrismFoundation
import SwiftUI

// MARK: - Analytics Provider

private struct AnalyticsProviderKey: EnvironmentKey {
    static let defaultValue: (any PrismAnalyticsProvider)? = nil
}

extension EnvironmentValues {
    /// The analytics provider for automatic component tracking.
    public var analyticsProvider: (any PrismAnalyticsProvider)? {
        get { self[AnalyticsProviderKey.self] }
        set { self[AnalyticsProviderKey.self] = newValue }
    }
}

// MARK: - Locale Manager

private struct LocaleManagerKey: @unchecked Sendable, EnvironmentKey {
    nonisolated static let defaultValue: PrismLocaleManager? = nil
}

extension EnvironmentValues {
    /// The locale manager for runtime language switching.
    @MainActor
    public var localeManager: PrismLocaleManager? {
        get { self[LocaleManagerKey.self] }
        set { self[LocaleManagerKey.self] = newValue }
    }
}
