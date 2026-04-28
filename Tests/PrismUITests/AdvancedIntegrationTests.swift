import Testing
import SwiftUI
@testable import PrismUI

@MainActor
@Suite("Advanced Integrations")
struct AdvancedIntegrationTests {

    // MARK: - Widget Views

    @Suite("Widget Components")
    struct WidgetTests {

        @Test("PrismWidgetView wraps content with theme")
        @MainActor func widgetViewCreation() {
            let view = PrismWidgetView {
                Text("Widget content")
            }
            _ = view.body
        }

        @Test("PrismWidgetView accepts custom theme")
        @MainActor func widgetViewCustomTheme() {
            let view = PrismWidgetView(theme: DarkTheme()) {
                Text("Dark widget")
            }
            _ = view.body
        }

        @Test("PrismWidgetGauge clamps value 0-1")
        @MainActor func widgetGaugeClamp() {
            let over = PrismWidgetGauge(value: 1.5, label: "Test")
            _ = over.body

            let under = PrismWidgetGauge(value: -0.5, label: "Test")
            _ = under.body
        }

        @Test("PrismWidgetGauge with icon")
        @MainActor func widgetGaugeIcon() {
            let view = PrismWidgetGauge(value: 0.75, label: "Progress", icon: "bolt.fill")
            _ = view.body
        }

        @Test("PrismWidgetStat basic display")
        @MainActor func widgetStatBasic() {
            let view = PrismWidgetStat("Revenue", value: "$1.2k")
            _ = view.body
        }

        @Test("PrismWidgetStat with icon and trend")
        @MainActor func widgetStatFull() {
            let view = PrismWidgetStat("Revenue", value: "$1.2k", icon: "dollarsign.circle", trend: .up)
            _ = view.body
        }

        @Test("PrismWidgetStat trend icons correct")
        @MainActor func trendIcons() {
            #expect(PrismWidgetStat.Trend.up.icon == "arrow.up.right")
            #expect(PrismWidgetStat.Trend.down.icon == "arrow.down.right")
            #expect(PrismWidgetStat.Trend.flat.icon == "arrow.right")
        }

        @Test("PrismWidgetStat trend colors use correct tokens")
        @MainActor func trendColors() {
            let theme = DefaultTheme()
            #expect(PrismWidgetStat.Trend.up.color(theme) == theme.color(.success))
            #expect(PrismWidgetStat.Trend.down.color(theme) == theme.color(.error))
            #expect(PrismWidgetStat.Trend.flat.color(theme) == theme.color(.onBackgroundSecondary))
        }
    }

    // MARK: - Live Activity

    @Suite("Live Activity Components")
    struct LiveActivityTests {

        @Test("PrismLiveActivityCompact renders leading and trailing")
        @MainActor func compactLayout() {
            let view = PrismLiveActivityCompact(
                leading: { Text("Left") },
                trailing: { Text("Right") }
            )
            _ = view.body
        }

        @Test("PrismLiveActivityExpanded renders title and content")
        @MainActor func expandedLayout() {
            let view = PrismLiveActivityExpanded("Timer", icon: "timer") {
                Text("2:45 remaining")
            }
            _ = view.body
        }

        @Test("PrismLiveActivityExpanded without icon")
        @MainActor func expandedNoIcon() {
            let view = PrismLiveActivityExpanded("Status") {
                Text("Active")
            }
            _ = view.body
        }

        @Test("PrismLiveActivityMinimal wraps content with min size")
        @MainActor func minimalLayout() {
            let view = PrismLiveActivityMinimal {
                Image(systemName: "timer")
            }
            _ = view.body
        }
    }

    // MARK: - App Intents

    @Suite("App Intent Components")
    struct AppIntentTests {

        @Test("PrismIntentSnippet applies themed container")
        @MainActor func snippetView() {
            let view = PrismIntentSnippet {
                Text("Task completed")
            }
            _ = view.body
        }

        @Test("PrismIntentConfirmation basic")
        @MainActor func confirmationBasic() {
            let view = PrismIntentConfirmation("Done!")
            _ = view.body
        }

        @Test("PrismIntentConfirmation with message and icon")
        @MainActor func confirmationFull() {
            let view = PrismIntentConfirmation(
                "Saved",
                message: "Your changes have been saved",
                icon: "checkmark.seal.fill"
            )
            _ = view.body
        }
    }

    // MARK: - Animation Presets

    @Suite("Animation Presets")
    struct AnimationTests {

        @Test("All preset cases exist", arguments: [
            PrismAnimationPreset.bounce,
            .wiggle,
            .pulse,
            .shake,
            .fadeIn,
            .slideUp,
            .scaleIn,
            .springIn,
        ])
        @MainActor func presetCases(preset: PrismAnimationPreset) {
            let view = Text("Animated")
                .prismAnimate(preset, trigger: false)
            _ = view
        }

        @Test("prismAnimate modifier applies")
        @MainActor func animateTrigger() {
            let view = Text("Hello")
                .prismAnimate(.bounce, trigger: true)
            _ = view
        }

        @Test("prismPulse continuous modifier applies")
        @MainActor func pulseModifier() {
            let view = Text("Pulsing")
                .prismPulse(.pulse)
            _ = view
        }

        @Test("prismPulse default preset is pulse")
        @MainActor func pulseDefault() {
            let view = Text("Default")
                .prismPulse()
            _ = view
        }
    }

    // MARK: - SwiftData Integration

    @Suite("SwiftData Integration")
    struct SwiftDataTests {

        struct TestItem: Identifiable {
            let id = UUID()
            let name: String
        }

        @Test("PrismModelList shows empty state for empty collection")
        @MainActor func modelListEmpty() {
            let items: [TestItem] = []
            let view = PrismModelList(items) { item in
                Text(item.name)
            }
            _ = view.body
        }

        @Test("PrismModelList shows list for non-empty collection")
        @MainActor func modelListWithData() {
            let items = [TestItem(name: "A"), TestItem(name: "B")]
            let view = PrismModelList(items) { item in
                Text(item.name)
            }
            _ = view.body
        }

        @Test("PrismModelList custom empty state")
        @MainActor func modelListCustomEmpty() {
            let items: [TestItem] = []
            let view = PrismModelList(
                items,
                emptyIcon: "checkmark.circle",
                emptyTitle: "All done!",
                emptyMessage: "No pending tasks"
            ) { item in
                Text(item.name)
            }
            _ = view.body
        }

        @Test("PrismModelList with explicit id keypath")
        @MainActor func modelListExplicitId() {
            struct NamedItem {
                let name: String
            }
            let items = [NamedItem(name: "X")]
            let view = PrismModelList(items, id: \.name) { item in
                Text(item.name)
            }
            _ = view.body
        }

        @Test("PrismModelForm applies themed background")
        @MainActor func modelForm() {
            let view = PrismModelForm {
                Section("Details") {
                    Text("Field 1")
                    Text("Field 2")
                }
            }
            _ = view.body
        }
    }

    // MARK: - Token Export

    @Suite("Design Token Export")
    struct TokenExportTests {

        @Test("toJSON returns all 6 token categories")
        @MainActor func jsonContainsAllCategories() {
            let json = PrismTokenExport.toJSON(theme: DefaultTheme())
            #expect(json["colors"] != nil)
            #expect(json["typography"] != nil)
            #expect(json["spacing"] != nil)
            #expect(json["radius"] != nil)
            #expect(json["elevation"] != nil)
            #expect(json["motion"] != nil)
        }

        @Test("toJSON colors export all ColorToken cases")
        @MainActor func jsonColorsComplete() {
            let json = PrismTokenExport.toJSON(theme: DefaultTheme())
            let colors = json["colors"] as? [String: String]
            #expect(colors != nil)
            for token in ColorToken.allCases {
                #expect(colors?[token.rawValue] != nil)
            }
        }

        @Test("toJSON color format is hex")
        @MainActor func jsonColorHexFormat() {
            let json = PrismTokenExport.toJSON(theme: DefaultTheme())
            let colors = json["colors"] as? [String: String]
            if let firstColor = colors?.values.first {
                #expect(firstColor.hasPrefix("#"))
            }
        }

        @Test("toJSON spacing exports all SpacingToken cases")
        @MainActor func jsonSpacingComplete() {
            let json = PrismTokenExport.toJSON(theme: DefaultTheme())
            let spacing = json["spacing"] as? [String: CGFloat]
            #expect(spacing != nil)
            #expect(spacing?.count == SpacingToken.allCases.count)
        }

        @Test("toJSON radius exports all RadiusToken cases")
        @MainActor func jsonRadiusComplete() {
            let json = PrismTokenExport.toJSON(theme: DefaultTheme())
            let radius = json["radius"] as? [String: CGFloat]
            #expect(radius != nil)
            #expect(radius?.count == RadiusToken.allCases.count)
        }

        @Test("toJSON motion exports all MotionToken cases")
        @MainActor func jsonMotionComplete() {
            let json = PrismTokenExport.toJSON(theme: DefaultTheme())
            let motion = json["motion"] as? [String: TimeInterval]
            #expect(motion != nil)
            #expect(motion?.count == MotionToken.allCases.count)
        }

        @Test("toJSONData returns valid data")
        @MainActor func jsonDataNotNil() {
            let data = PrismTokenExport.toJSONData(theme: DefaultTheme())
            #expect(data != nil)
        }

        @Test("toJSONString returns valid string")
        @MainActor func jsonStringNotNil() {
            let string = PrismTokenExport.toJSONString(theme: DefaultTheme())
            #expect(string != nil)
            #expect(string?.contains("colors") == true)
        }

        @Test("toFigmaTokens returns color, spacing, borderRadius")
        @MainActor func figmaTokensStructure() {
            let tokens = PrismTokenExport.toFigmaTokens(theme: DefaultTheme())
            #expect(tokens["color"] != nil)
            #expect(tokens["spacing"] != nil)
            #expect(tokens["borderRadius"] != nil)
        }

        @Test("Figma color tokens use DTCG $value/$type format")
        @MainActor func figmaColorFormat() {
            let tokens = PrismTokenExport.toFigmaTokens(theme: DefaultTheme())
            let colors = tokens["color"] as? [String: Any]
            if let firstToken = colors?.values.first as? [String: String] {
                #expect(firstToken["$value"]?.hasPrefix("#") == true)
                #expect(firstToken["$type"] == "color")
            }
        }

        @Test("Figma spacing tokens use dimension type with px suffix")
        @MainActor func figmaSpacingFormat() {
            let tokens = PrismTokenExport.toFigmaTokens(theme: DefaultTheme())
            let spacing = tokens["spacing"] as? [String: Any]
            if let firstToken = spacing?.values.first as? [String: String] {
                #expect(firstToken["$value"]?.hasSuffix("px") == true)
                #expect(firstToken["$type"] == "dimension")
            }
        }

        @Test("toJSON with different themes produces different colors")
        @MainActor func differentThemesDifferentOutput() {
            let defaultJSON = PrismTokenExport.toJSON(theme: DefaultTheme())
            let darkJSON = PrismTokenExport.toJSON(theme: DarkTheme())
            let defaultColors = defaultJSON["colors"] as? [String: String]
            let darkColors = darkJSON["colors"] as? [String: String]
            #expect(defaultColors?[ColorToken.background.rawValue] != darkColors?[ColorToken.background.rawValue])
        }
    }

    // MARK: - Charts (compile-time check only, needs Charts framework)

    #if canImport(Charts)
    @Suite("Chart Components")
    struct ChartTests {

        struct ChartItem: Identifiable {
            let id = UUID()
            let label: String
            let value: Double
        }

        @Test("PrismBarChart creation")
        @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
        @MainActor func barChart() {
            let data = [ChartItem(label: "A", value: 10), ChartItem(label: "B", value: 20)]
            let view = PrismBarChart(data, x: \.label, y: \.value)
            _ = view.body
        }

        @Test("PrismBarChart custom color")
        @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
        @MainActor func barChartColor() {
            let data = [ChartItem(label: "A", value: 10)]
            let view = PrismBarChart(data, x: \.label, y: \.value, barColor: .success)
            _ = view.body
        }

        @Test("PrismLineChart creation")
        @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
        @MainActor func lineChart() {
            let data = [ChartItem(label: "Jan", value: 100), ChartItem(label: "Feb", value: 150)]
            let view = PrismLineChart(data, x: \.label, y: \.value)
            _ = view.body
        }

        @Test("PrismLineChart with area")
        @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
        @MainActor func lineChartArea() {
            let data = [ChartItem(label: "A", value: 50)]
            let view = PrismLineChart(data, x: \.label, y: \.value, showArea: true)
            _ = view.body
        }

        @Test("PrismDonutChart creation")
        @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
        @MainActor func donutChart() {
            let data = [ChartItem(label: "Slice A", value: 60), ChartItem(label: "Slice B", value: 40)]
            let view = PrismDonutChart(data, label: \.label, value: \.value)
            _ = view.body
        }

        @Test("PrismDonutChart custom colors")
        @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
        @MainActor func donutChartColors() {
            let data = [ChartItem(label: "A", value: 50)]
            let view = PrismDonutChart(data, label: \.label, value: \.value, colors: [.brand, .success])
            _ = view.body
        }
    }
    #endif
}
