//
//  PrismLocaleManager.swift
//  Prism
//
//  Created by Rafael Escaleira on 27/04/26.
//

import Foundation
import Observation

/// Observable locale manager for runtime language switching.
///
/// `PrismLocaleManager` is the single source of truth for the app's
/// active locale. Changing ``current`` automatically updates all
/// PrismUI components in the view hierarchy.
///
/// ## Setup
/// ```swift
/// @main struct MyApp: App {
///     @State var localeManager = PrismLocaleManager()
///
///     var body: some Scene {
///         WindowGroup {
///             ContentView()
///                 .prism(localeManager: localeManager)
///         }
///     }
/// }
/// ```
///
/// ## Switching Language
/// ```swift
/// localeManager.current = .spanishES
/// ```
///
/// ## Persistence
/// The selected locale is persisted to `UserDefaults` and restored
/// on next launch. Pass `persistsSelection: false` to disable.
@Observable
@MainActor
public final class PrismLocaleManager {
    private static let defaultsKey = "com.prism.selectedLocale"

    /// The currently active locale.
    public var current: PrismLocale {
        didSet {
            if persistsSelection {
                persistLocale(current)
            }
        }
    }

    /// All locales available for selection.
    public let available: [PrismLocale]

    /// Whether locale changes are persisted to `UserDefaults`.
    public let persistsSelection: Bool

    /// Creates a locale manager.
    ///
    /// - Parameters:
    ///   - initial: The starting locale. Defaults to the persisted value or system locale.
    ///   - available: Locales available for selection. Defaults to all supported locales.
    ///   - persistsSelection: Whether to persist the selection. Defaults to `true`.
    public init(
        initial: PrismLocale? = nil,
        available: [PrismLocale] = PrismLocale.allCases.map { $0 },
        persistsSelection: Bool = true
    ) {
        self.available = available
        self.persistsSelection = persistsSelection
        self.current = initial ?? Self.restoredLocale() ?? .current
    }

    // MARK: - Persistence

    private static func restoredLocale() -> PrismLocale? {
        guard let identifier = UserDefaults.standard.string(forKey: defaultsKey) else {
            return nil
        }
        return PrismLocale.allCases.first { $0.identifier == identifier }
    }

    private func persistLocale(_ locale: PrismLocale) {
        UserDefaults.standard.set(locale.identifier, forKey: Self.defaultsKey)
    }
}
