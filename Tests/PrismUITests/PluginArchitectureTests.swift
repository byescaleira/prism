import SwiftUI
import Testing

@testable import PrismUI

@MainActor
@Suite("Plugin Architecture")
struct PluginArchitectureTests {

    struct TestPlugin: PrismPlugin {
        let id = "com.test.plugin"
        let name = "Test Plugin"

        func register(in registry: PrismPluginRegistry) {
            registry.registerTheme(DarkTheme(), id: "dark-custom")
            registry.registerColorOverride(.brand, color: .purple)
            registry.registerSpacingOverride(.md, value: 20)
            registry.registerRadiusOverride(.md, value: 16)
            registry.registerComponent("testCard") { @MainActor @Sendable in
                AnyView(Text("Plugin Card"))
            }
        }
    }

    struct AnotherPlugin: PrismPlugin {
        let id = "com.test.another"
        let name = "Another Plugin"
        let version = "2.0.0"

        func register(in registry: PrismPluginRegistry) {
            registry.registerTheme(HighContrastTheme(), id: "hc-custom")
        }
    }

    private func freshRegistry() -> PrismPluginRegistry {
        let registry = PrismPluginRegistry.shared
        registry.reset()
        return registry
    }

    @Test("install plugin registers it")
    @MainActor func install() {
        let registry = freshRegistry()
        let plugin = TestPlugin()
        registry.install(plugin)
        #expect(registry.isInstalled("com.test.plugin"))
        #expect(registry.plugins.count == 1)
    }

    @Test("duplicate install is no-op")
    @MainActor func duplicateInstall() {
        let registry = freshRegistry()
        registry.install(TestPlugin())
        registry.install(TestPlugin())
        #expect(registry.plugins.count == 1)
    }

    @Test("uninstall removes plugin")
    @MainActor func uninstall() {
        let registry = freshRegistry()
        registry.install(TestPlugin())
        registry.uninstall(pluginID: "com.test.plugin")
        #expect(!registry.isInstalled("com.test.plugin"))
    }

    @Test("theme registration and retrieval")
    @MainActor func themeRegistration() {
        let registry = freshRegistry()
        registry.install(TestPlugin())
        let theme = registry.theme(id: "dark-custom")
        #expect(theme != nil)
        #expect(registry.registeredThemeIDs.contains("dark-custom"))
    }

    @Test("color override")
    @MainActor func colorOverride() {
        let registry = freshRegistry()
        registry.install(TestPlugin())
        let color = registry.colorOverride(for: .brand)
        #expect(color != nil)
    }

    @Test("spacing override")
    @MainActor func spacingOverride() {
        let registry = freshRegistry()
        registry.install(TestPlugin())
        let spacing = registry.spacingOverride(for: .md)
        #expect(spacing == 20)
    }

    @Test("radius override")
    @MainActor func radiusOverride() {
        let registry = freshRegistry()
        registry.install(TestPlugin())
        let radius = registry.radiusOverride(for: .md)
        #expect(radius == 16)
    }

    @Test("component factory")
    @MainActor func componentFactory() {
        let registry = freshRegistry()
        registry.install(TestPlugin())
        let view = registry.component("testCard")
        #expect(view != nil)
        #expect(registry.registeredComponentIDs.contains("testCard"))
    }

    @Test("missing component returns nil")
    @MainActor func missingComponent() {
        let registry = freshRegistry()
        #expect(registry.component("nonexistent") == nil)
    }

    @Test("missing theme returns nil")
    @MainActor func missingTheme() {
        let registry = freshRegistry()
        #expect(registry.theme(id: "nonexistent") == nil)
    }

    @Test("missing override returns nil")
    @MainActor func missingOverrides() {
        let registry = freshRegistry()
        #expect(registry.colorOverride(for: .brand) == nil)
        #expect(registry.spacingOverride(for: .md) == nil)
        #expect(registry.radiusOverride(for: .md) == nil)
    }

    @Test("multiple plugins coexist")
    @MainActor func multiplePlugins() {
        let registry = freshRegistry()
        registry.install(TestPlugin())
        registry.install(AnotherPlugin())
        #expect(registry.plugins.count == 2)
        #expect(registry.registeredThemeIDs.count == 2)
    }

    @Test("reset clears everything")
    @MainActor func reset() {
        let registry = freshRegistry()
        registry.install(TestPlugin())
        registry.reset()
        #expect(registry.plugins.isEmpty)
        #expect(registry.registeredThemeIDs.isEmpty)
        #expect(registry.registeredComponentIDs.isEmpty)
    }

    @Test("default version is 1.0.0")
    @MainActor func defaultVersion() {
        let plugin = TestPlugin()
        #expect(plugin.version == "1.0.0")
    }

    @Test("custom version")
    @MainActor func customVersion() {
        let plugin = AnotherPlugin()
        #expect(plugin.version == "2.0.0")
    }

    @Test("prismPlugin modifier exists")
    @MainActor func pluginModifier() {
        let registry = freshRegistry()
        registry.install(TestPlugin())
        #expect(type(of: Text("X").prismPlugin(theme: "dark-custom", registry: registry)) is any View.Type)
    }
}
