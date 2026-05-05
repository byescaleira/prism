import SwiftUI

/// A localization key with metadata for string catalog extraction.
public struct PrismLocalizedKey: Sendable, Identifiable {
    /// Unique identifier derived from the key string.
    public var id: String { key }
    /// The localization key string.
    public let key: String
    /// Developer comment describing the context for translators.
    public let comment: String
    /// Optional string table name (defaults to Localizable).
    public let table: String?

    /// Creates a localized key with the given parameters.
    public init(key: String, comment: String, table: String? = nil) {
        self.key = key
        self.comment = comment
        self.table = table
    }

    /// Returns a SwiftUI LocalizedStringKey for this key.
    public var localizedStringKey: LocalizedStringKey {
        LocalizedStringKey(key)
    }
}

/// Registry that collects localized keys for catalog generation.
@MainActor
public final class PrismStringExporter: Sendable {
    /// All registered localization keys.
    public private(set) var keys: [PrismLocalizedKey] = []

    /// Shared instance for global key collection.
    public static let shared = PrismStringExporter()

    /// Creates a string exporter instance.
    public init() {}

    /// Registers a localization key.
    public func register(_ key: PrismLocalizedKey) {
        guard !keys.contains(where: { $0.key == key.key }) else { return }
        keys.append(key)
    }

    /// Exports all registered keys, optionally filtered by module prefix.
    public func exportKeys(from module: String) -> [PrismLocalizedKey] {
        keys.filter { $0.key.hasPrefix(module) || module.isEmpty }
    }

    /// Removes all registered keys.
    public func reset() {
        keys.removeAll()
    }
}

// MARK: - View Modifier

extension View {

    /// Registers a localization key and applies the localized string to this view.
    public func prismLocalized(_ key: String, comment: String, table: String? = nil) -> some View {
        modifier(PrismLocalizedModifier(key: key, comment: comment, table: table))
    }
}

/// Modifier that registers a localization key on appearance.
@MainActor
private struct PrismLocalizedModifier: ViewModifier {
    let key: String
    let comment: String
    let table: String?

    func body(content: Content) -> some View {
        content
            .onAppear {
                let localizedKey = PrismLocalizedKey(key: key, comment: comment, table: table)
                PrismStringExporter.shared.register(localizedKey)
            }
    }
}
