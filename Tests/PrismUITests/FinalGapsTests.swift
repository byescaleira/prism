import SwiftUI
import Testing

@testable import PrismUI

#if canImport(TipKit)
    import TipKit
#endif

@MainActor
@Suite("Final Gaps & Polish")
struct FinalGapsTests {

    // MARK: - Context Menu

    @Suite("Context Menu")
    struct ContextMenuTests {

        @Test("prismContextMenu without preview")
        @MainActor func contextMenuWithoutPreview() {
            let view = Text("Tap me")
                .prismContextMenu {
                    Button("Copy") {}
                    Button("Delete") {}
                }
            _ = view
        }

        @Test("prismContextMenu with preview")
        @MainActor func contextMenuWithPreview() {
            let view = Text("Long press")
                .prismContextMenu {
                    Button("Share") {}
                } preview: {
                    Text("Preview")
                }
            _ = view
        }
    }

    // MARK: - Gauge

    @Suite("Gauge")
    struct GaugeTests {

        @Test("PrismGauge default range")
        @MainActor func gaugeDefault() {
            let view = PrismGauge(value: 0.5, label: "Battery")
            _ = view.body
        }

        @Test("PrismGauge custom range")
        @MainActor func gaugeCustomRange() {
            let view = PrismGauge(value: 50, in: 0...100, label: "Progress")
            _ = view.body
        }

        @Test("PrismGauge with current value label")
        @MainActor func gaugeWithLabel() {
            let view = PrismGauge(value: 0.7, label: "Storage") {
                Text("70%")
            }
            _ = view.body
        }
    }

    // MARK: - GroupBox

    @Suite("GroupBox")
    struct GroupBoxTests {

        @Test("PrismGroupBox with title")
        @MainActor func groupBoxTitle() {
            let view = PrismGroupBox("Settings") {
                Text("Content")
            }
            _ = view.body
        }

        @Test("PrismGroupBox with custom label")
        @MainActor func groupBoxCustomLabel() {
            let view = PrismGroupBox {
                Text("Content")
            } label: {
                Label("Options", systemImage: "gear")
            }
            _ = view.body
        }

        @Test("PrismGroupBox without label")
        @MainActor func groupBoxNoLabel() {
            let view = PrismGroupBox {
                Text("Standalone content")
            }
            _ = view.body
        }
    }

    // MARK: - Label Style

    @Suite("Label Style")
    struct LabelStyleTests {

        @Test("PrismLabelStyle cases exist")
        @MainActor func labelStyleCases() {
            let cases: [PrismLabelStyle] = [
                .automatic, .iconOnly, .titleOnly, .titleAndIcon,
            ]
            #expect(cases.count == 4)
        }

        @Test("prismLabelStyle iconOnly")
        @MainActor func labelStyleIconOnly() {
            let view = Label("Settings", systemImage: "gear")
                .prismLabelStyle(.iconOnly)
            _ = view
        }

        @Test("prismLabelStyle titleAndIcon")
        @MainActor func labelStyleTitleAndIcon() {
            let view = Label("Settings", systemImage: "gear")
                .prismLabelStyle(.titleAndIcon)
            _ = view
        }
    }

    // MARK: - Content Transition

    @Suite("Content Transition")
    struct ContentTransitionTests {

        @Test("PrismContentTransition cases exist")
        @MainActor func contentTransitionCases() {
            let cases: [PrismContentTransition] = [
                .numericText, .numericTextCountdown, .interpolate, .opacity, .identity,
            ]
            #expect(cases.count == 5)
        }

        @Test("prismContentTransition numericText")
        @MainActor func numericText() {
            let view = Text("42")
                .prismContentTransition(.numericText)
            _ = view
        }

        @Test("prismContentTransition interpolate")
        @MainActor func interpolate() {
            let view = Text("Hello")
                .prismContentTransition(.interpolate)
            _ = view
        }
    }

    // MARK: - Sensory Feedback

    @Suite("Sensory Feedback")
    struct SensoryFeedbackTests {

        @Test("PrismSensoryFeedback cases exist")
        @MainActor func feedbackCases() {
            let cases: [PrismSensoryFeedback] = [
                .success, .warning, .error, .selection,
                .increase, .decrease, .start, .stop,
                .alignment, .levelChange, .impact,
            ]
            #expect(cases.count == 11)
        }

        @Test("prismSensoryFeedback modifier")
        @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
        @MainActor func sensoryFeedbackModifier() {
            @State var trigger = false
            let view = Text("Tap")
                .prismSensoryFeedback(.success, trigger: trigger)
            _ = view
        }
    }

    // MARK: - Image Resource

    @Suite("Image Resource")
    struct ImageResourceTests {

        @Test("PrismImageResource system")
        @MainActor func systemImage() {
            let view = PrismImageResource(.system("star.fill"), color: .interactive)
            _ = view.body
        }

        @Test("PrismImageResource catalog")
        @MainActor func catalogImage() {
            let view = PrismImageResource(.catalog("logo"))
            _ = view.body
        }

        @Test("Source cases")
        @MainActor func sourceCases() {
            let system = PrismImageResource.Source.system("star")
            let catalog = PrismImageResource.Source.catalog("icon")
            _ = system
            _ = catalog
        }
    }

    // MARK: - Paste Button

    @Suite("Paste Button")
    struct PasteButtonTests {

        @Test("PrismPasteButton creation")
        @MainActor func pasteButtonCreation() {
            let view = PrismPasteButton { strings in
                _ = strings
            }
            _ = view.body
        }

        @Test("PrismPasteButton custom title")
        @MainActor func pasteButtonCustomTitle() {
            let view = PrismPasteButton("Paste Text") { _ in }
            _ = view.body
        }
    }

    // MARK: - Refreshable

    @Suite("Refreshable")
    struct RefreshableTests {

        @Test("prismRefreshable modifier")
        @MainActor func refreshableModifier() {
            let view = List {
                Text("Item")
            }
            .prismRefreshable {}
            _ = view
        }
    }

    // MARK: - Timeline View

    @Suite("Timeline View")
    struct TimelineViewTests {

        @Test("PrismTimelineSchedule cases")
        @MainActor func scheduleCases() {
            let animation = PrismTimelineSchedule.animation
            let everySecond = PrismTimelineSchedule.everySecond
            let custom = PrismTimelineSchedule.every(5)
            let explicit = PrismTimelineSchedule.explicit([Date()])
            _ = (animation, everySecond, custom, explicit)
        }

        @Test("PrismTimelineView everySecond")
        @MainActor func timelineEverySecond() {
            let view = PrismTimelineView(.everySecond) { date in
                Text(date, style: .timer)
            }
            _ = view.body
        }

        @Test("PrismTimelineView animation schedule")
        @MainActor func timelineAnimation() {
            let view = PrismTimelineView(.animation) { date in
                Text("\(date.timeIntervalSince1970)")
            }
            _ = view.body
        }

        @Test("PrismTimelineView custom interval")
        @MainActor func timelineCustom() {
            let view = PrismTimelineView(.every(2)) { _ in
                Text("Tick")
            }
            _ = view.body
        }
    }

    // MARK: - Settings

    @Suite("Settings")
    struct SettingsTests {

        @Test("PrismSettingsView renders")
        @MainActor func settingsView() {
            let view = PrismSettingsView {
                Toggle("Notifications", isOn: .constant(true))
            }
            _ = view.body
        }

        @Test("PrismSettingsSection with footer")
        @MainActor func settingsSection() {
            let view = PrismSettingsSection("General", footer: "Configure basics") {
                Toggle("Dark Mode", isOn: .constant(false))
            }
            _ = view.body
        }

        @Test("PrismSettingsSection without footer")
        @MainActor func settingsSectionNoFooter() {
            let view = PrismSettingsSection("Account") {
                Text("email@example.com")
            }
            _ = view.body
        }
    }

    // MARK: - Table (macOS only)

    #if os(macOS)
        @Suite("Table")
        struct TableTests {

            struct Person: Identifiable {
                let id = UUID()
                let name: String
            }

            @Test("PrismTable creation")
            @MainActor func tableCreation() {
                let data = [Person(name: "Alice"), Person(name: "Bob")]
                let view = PrismTable(data) { people in
                    Table(people) {
                        TableColumn("Name", value: \.name)
                    }
                }
                _ = view.body
            }
        }
    #endif
}
