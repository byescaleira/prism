import SwiftUI
import Testing

@testable import PrismUI

@MainActor
@Suite("Developer Experience")
struct DeveloperExperienceTests {

    // MARK: - Component Generator

    @Test("PrismComponentTemplate has all 6 cases")
    func templateCases() {
        let cases = PrismComponentTemplate.allCases
        #expect(cases.count == 6)
        #expect(cases.contains(.button))
        #expect(cases.contains(.card))
        #expect(cases.contains(.form))
        #expect(cases.contains(.list))
        #expect(cases.contains(.detail))
        #expect(cases.contains(.settings))
    }

    @Test("availableTemplates returns all templates")
    func availableTemplates() {
        let templates = PrismComponentGenerator.availableTemplates()
        #expect(templates.count == PrismComponentTemplate.allCases.count)
    }

    @Test("generate produces non-empty string for each template")
    func generateNonEmpty() {
        for template in PrismComponentTemplate.allCases {
            let code = PrismComponentGenerator.generate(template: template, name: "TestComponent")
            #expect(!code.isEmpty, "Template \(template) generated empty code")
        }
    }

    @Test("generated code contains struct keyword and View conformance")
    func generatedCodeStructure() {
        for template in PrismComponentTemplate.allCases {
            let code = PrismComponentGenerator.generate(template: template, name: "MyView")
            #expect(code.contains("struct MyView"), "Template \(template) missing struct declaration")
            #expect(code.contains("View"), "Template \(template) missing View conformance")
        }
    }

    @Test("generated code contains PrismUI import")
    func generatedCodeImport() {
        let code = PrismComponentGenerator.generate(template: .button, name: "TestBtn")
        #expect(code.contains("import PrismUI"))
    }

    @Test("generated code contains theme environment")
    func generatedCodeTheme() {
        let code = PrismComponentGenerator.generate(template: .card, name: "TestCard")
        #expect(code.contains("prismTheme"))
    }

    @Test("generated code contains accessibility")
    func generatedCodeAccessibility() {
        let code = PrismComponentGenerator.generate(template: .button, name: "TestBtn")
        #expect(code.contains("accessibilityLabel"))
    }

    // MARK: - Component Debugger

    @Test("PrismDebugInfo stores component name and size")
    func debugInfoStorage() {
        let info = PrismDebugInfo(
            componentName: "TestView",
            renderCount: 3,
            frameSize: CGSize(width: 200, height: 100),
            accessibilityLabel: "Test"
        )
        #expect(info.componentName == "TestView")
        #expect(info.renderCount == 3)
        #expect(info.frameSize.width == 200)
        #expect(info.frameSize.height == 100)
        #expect(info.accessibilityLabel == "Test")
    }

    @Test("PrismComponentDebugger register adds component")
    func debuggerRegister() {
        let debugger = PrismComponentDebugger()
        debugger.register(component: "Button", size: CGSize(width: 100, height: 44))
        #expect(debugger.components.count == 1)
        #expect(debugger.components.first?.componentName == "Button")
    }

    @Test("PrismComponentDebugger register increments render count")
    func debuggerRenderCount() {
        let debugger = PrismComponentDebugger()
        debugger.register(component: "Button", size: CGSize(width: 100, height: 44))
        debugger.register(component: "Button", size: CGSize(width: 100, height: 44))
        #expect(debugger.components.count == 1)
        #expect(debugger.components.first?.renderCount == 2)
    }

    @Test("PrismComponentDebugger reset clears components")
    func debuggerReset() {
        let debugger = PrismComponentDebugger()
        debugger.register(component: "A", size: .zero)
        debugger.register(component: "B", size: .zero)
        #expect(debugger.components.count == 2)
        debugger.reset()
        #expect(debugger.components.isEmpty)
    }

    // MARK: - Live Reload

    @Test("PrismLiveReloadServer default state is disconnected")
    func liveReloadDefault() {
        let server = PrismLiveReloadServer()
        #expect(!server.isConnected)
        #expect(server.lastReloadDate == nil)
    }

    @Test("PrismLiveReloadServer triggerReload updates lastReloadDate")
    func liveReloadTrigger() {
        let server = PrismLiveReloadServer()
        #expect(server.lastReloadDate == nil)
        server.triggerReload()
        #expect(server.lastReloadDate != nil)
    }

    @Test("PrismLiveReloadServer register connects server")
    func liveReloadRegister() {
        let server = PrismLiveReloadServer()
        let reloadable = MockReloadable()
        server.register(reloadable)
        #expect(server.isConnected)
    }

    @Test("PrismLiveReloadServer disconnect clears state")
    func liveReloadDisconnect() {
        let server = PrismLiveReloadServer()
        let reloadable = MockReloadable()
        server.register(reloadable)
        server.disconnect()
        #expect(!server.isConnected)
    }

    @Test("PrismLiveReloadServer triggerReload calls reload on registered objects")
    func liveReloadCallsReload() {
        let server = PrismLiveReloadServer()
        let reloadable = MockReloadable()
        server.register(reloadable)
        server.triggerReload()
        #expect(reloadable.reloadCount == 1)
    }

    // MARK: - Prototype Screen

    @Test("PrismPrototypeScreen stores name")
    func prototypeScreenName() {
        let screen = PrismPrototypeScreen(name: "Home")
        #expect(screen.name == "Home")
        #expect(!screen.id.isEmpty)
    }

    @Test("PrismPrototypeScreen stores views array")
    func prototypeScreenViews() {
        let screen = PrismPrototypeScreen(name: "Settings", views: [AnyView(Text("Hello"))])
        #expect(screen.views.count == 1)
    }

    // MARK: - Environment Snapshot

    @Test("PrismEnvironmentSnapshot captures values")
    func environmentSnapshot() {
        let snapshot = PrismEnvironmentSnapshot(
            colorScheme: .dark,
            dynamicTypeSize: .large,
            layoutDirection: .leftToRight,
            accessibilityEnabled: false,
            reduceMotion: true,
            reduceTransparency: false
        )
        #expect(snapshot.colorScheme == .dark)
        #expect(snapshot.dynamicTypeSize == .large)
        #expect(snapshot.layoutDirection == .leftToRight)
        #expect(snapshot.accessibilityEnabled == false)
        #expect(snapshot.reduceMotion == true)
        #expect(snapshot.reduceTransparency == false)
    }

    // MARK: - View Type Conformance

    @Test("PrismTokenInspector conforms to View")
    func tokenInspectorIsView() {
        let inspector = PrismTokenInspector()
        #expect(type(of: inspector) is any View.Type)
    }

    @Test("PrismDebugOverlay conforms to View")
    func debugOverlayIsView() {
        let debugger = PrismComponentDebugger()
        let overlay = PrismDebugOverlay(debugger: debugger)
        #expect(type(of: overlay) is any View.Type)
    }

    @Test("PrismLiveReloadBanner conforms to View")
    func liveReloadBannerIsView() {
        let server = PrismLiveReloadServer()
        let banner = PrismLiveReloadBanner(server: server)
        #expect(type(of: banner) is any View.Type)
    }

    @Test("PrismEnvironmentDebugger conforms to View")
    func environmentDebuggerIsView() {
        let debugger = PrismEnvironmentDebugger()
        #expect(type(of: debugger) is any View.Type)
    }

    @Test("PrismPrototypeFlow conforms to View")
    func prototypeFlowIsView() {
        let flow = PrismPrototypeFlow(screens: [])
        #expect(type(of: flow) is any View.Type)
    }
}

// MARK: - Test Helpers

@MainActor
private final class MockReloadable: PrismLiveReloadable, @unchecked Sendable {
    var reloadCount = 0

    func reload() {
        reloadCount += 1
    }
}
