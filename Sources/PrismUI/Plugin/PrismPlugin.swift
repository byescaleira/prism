import SwiftUI

/// Extension point for registering custom tokens, components, and themes.
///
/// ```swift
/// struct MyPlugin: PrismPlugin {
///     let id = "com.myapp.brand"
///     let name = "My Brand Plugin"
///
///     func register(in registry: PrismPluginRegistry) {
///         registry.registerTheme(MyCustomTheme(), id: "myTheme")
///         registry.registerColorOverride(.brand, color: .indigo)
///     }
/// }
///
/// // At app launch:
/// PrismPluginRegistry.shared.install(MyPlugin())
/// ```
@MainActor
public protocol PrismPlugin: Sendable {
    /// The unique identifier for this plugin.
    var id: String { get }
    /// The human-readable name of this plugin.
    var name: String { get }
    /// The semantic version of this plugin.
    var version: String { get }
    /// Registers the plugin's themes, tokens, and components in the given registry.
    func register(in registry: PrismPluginRegistry)
}

extension PrismPlugin {
    /// The default plugin version.
    public var version: String { "1.0.0" }
}

/// Central registry for installed plugins.
@MainActor
public final class PrismPluginRegistry: @unchecked Sendable {
    /// The shared singleton plugin registry.
    public static let shared = PrismPluginRegistry()

    private var installedPlugins: [String: any PrismPlugin] = [:]
    private var themeOverrides: [String: any PrismTheme] = [:]
    private var colorOverrides: [ColorToken: Color] = [:]
    private var spacingOverrides: [SpacingToken: CGFloat] = [:]
    private var radiusOverrides: [RadiusToken: CGFloat] = [:]
    private var componentFactories: [String: @MainActor @Sendable () -> AnyView] = [:]

    private init() {}

    // MARK: - Plugin Lifecycle

    /// Installs a plugin, registering its customizations in this registry.
    public func install(_ plugin: some PrismPlugin) {
        guard installedPlugins[plugin.id] == nil else { return }
        installedPlugins[plugin.id] = plugin
        plugin.register(in: self)
    }

    /// Removes a previously installed plugin by its identifier.
    public func uninstall(pluginID: String) {
        installedPlugins.removeValue(forKey: pluginID)
    }

    /// All currently installed plugins.
    public var plugins: [any PrismPlugin] {
        Array(installedPlugins.values)
    }

    /// Returns whether a plugin with the given identifier is installed.
    public func isInstalled(_ pluginID: String) -> Bool {
        installedPlugins[pluginID] != nil
    }

    // MARK: - Theme Registration

    /// Registers a custom theme under the given identifier.
    public func registerTheme(_ theme: some PrismTheme, id: String) {
        themeOverrides[id] = theme
    }

    /// Returns the registered theme for the given identifier, if any.
    public func theme(id: String) -> (any PrismTheme)? {
        themeOverrides[id]
    }

    /// The sorted list of all registered theme identifiers.
    public var registeredThemeIDs: [String] {
        Array(themeOverrides.keys.sorted())
    }

    // MARK: - Token Overrides

    /// Overrides a color token with a custom color.
    public func registerColorOverride(_ token: ColorToken, color: Color) {
        colorOverrides[token] = color
    }

    /// Returns the color override for a token, if any.
    public func colorOverride(for token: ColorToken) -> Color? {
        colorOverrides[token]
    }

    /// Overrides a spacing token with a custom value.
    public func registerSpacingOverride(_ token: SpacingToken, value: CGFloat) {
        spacingOverrides[token] = value
    }

    /// Returns the spacing override for a token, if any.
    public func spacingOverride(for token: SpacingToken) -> CGFloat? {
        spacingOverrides[token]
    }

    /// Overrides a radius token with a custom value.
    public func registerRadiusOverride(_ token: RadiusToken, value: CGFloat) {
        radiusOverrides[token] = value
    }

    /// Returns the radius override for a token, if any.
    public func radiusOverride(for token: RadiusToken) -> CGFloat? {
        radiusOverrides[token]
    }

    // MARK: - Component Factory

    /// Registers a component factory under the given identifier.
    public func registerComponent(
        _ id: String,
        factory: @MainActor @Sendable @escaping () -> AnyView
    ) {
        componentFactories[id] = factory
    }

    /// Returns an instantiated component view for the given identifier, if registered.
    public func component(_ id: String) -> AnyView? {
        componentFactories[id]?()
    }

    /// The sorted list of all registered component identifiers.
    public var registeredComponentIDs: [String] {
        Array(componentFactories.keys.sorted())
    }

    // MARK: - Reset

    /// Removes all installed plugins, overrides, and component registrations.
    public func reset() {
        installedPlugins.removeAll()
        themeOverrides.removeAll()
        colorOverrides.removeAll()
        spacingOverrides.removeAll()
        radiusOverrides.removeAll()
        componentFactories.removeAll()
    }
}

/// View modifier that applies plugin overrides to the environment.
private struct PrismPluginModifier: ViewModifier {
    let registry: PrismPluginRegistry
    let themeID: String?

    func body(content: Content) -> some View {
        if let themeID, let theme = registry.theme(id: themeID) {
            content.environment(\.prismTheme, theme)
        } else {
            content
        }
    }
}

extension View {

    /// Applies a plugin-registered theme by ID.
    @MainActor
    public func prismPlugin(
        theme themeID: String,
        registry: PrismPluginRegistry = .shared
    ) -> some View {
        modifier(PrismPluginModifier(registry: registry, themeID: themeID))
    }
}
