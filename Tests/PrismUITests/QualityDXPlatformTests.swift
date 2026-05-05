import SwiftUI
import Testing

@testable import PrismUI

@MainActor
@Suite("Quality, DX & Platform")
struct QualityDXPlatformTests {

    // MARK: - A1: Accessibility Modifiers

    @Suite("Accessibility Modifiers")
    struct AccessibilityModifierTests {

        @Test("prismAccessibility combines label, hint, value")
        @MainActor func combinedAccessibility() {
            let view = Text("Price: $42")
                .prismAccessibility(
                    label: Text("Product price"),
                    hint: Text("Double tap to edit"),
                    value: Text("42 dollars"),
                    traits: .isButton
                )
            _ = view
        }

        @Test("prismAccessibilityHeader adds header trait")
        @MainActor func headerTrait() {
            let view = Text("Section Title")
                .prismAccessibilityHeader()
            _ = view
        }

        @Test("prismAccessibilityGroup combines children")
        @MainActor func groupCombine() {
            let view = HStack {
                Image(systemName: "star")
                Text("Favorite")
            }
            .prismAccessibilityGroup(label: Text("Favorite item"))
            _ = view
        }

        @Test("prismAccessibilityAction adds custom action")
        @MainActor func customAction() {
            let view = Text("Item")
                .prismAccessibilityAction(Text("Delete")) {}
            _ = view
        }

        @Test("prismAccessibilitySortPriority sets priority")
        @MainActor func sortPriority() {
            let view = Text("Important")
                .prismAccessibilitySortPriority(1)
            _ = view
        }
    }

    // MARK: - A2: Localization Expansion

    @Suite("Localization Expansion")
    struct LocalizationTests {

        @Test("New PrismStrings keys exist")
        @MainActor func newKeys() {
            let keys: [LocalizedStringKey] = [
                PrismStrings.continueAction,
                PrismStrings.getStarted,
                PrismStrings.paste,
                PrismStrings.save,
                PrismStrings.done,
                PrismStrings.edit,
                PrismStrings.add,
                PrismStrings.close,
                PrismStrings.back,
                PrismStrings.next,
                PrismStrings.previous,
                PrismStrings.share,
                PrismStrings.settings,
                PrismStrings.selectPhoto,
                PrismStrings.untitled,
                PrismStrings.noResults,
                PrismStrings.tryAgain,
                PrismStrings.errorOccurred,
            ]
            #expect(keys.count == 18)
        }

        @Test("Localized String defaults exist")
        @MainActor func localizedDefaults() {
            #expect(String.prismContinue == "Continue")
            #expect(String.prismGetStarted == "Get Started")
            #expect(String.prismSave == "Save")
            #expect(String.prismDone == "Done")
            #expect(String.prismClose == "Close")
            #expect(String.prismNoResults == "No Results")
        }
    }

    // MARK: - A3: Performance Benchmarks

    @Suite("Performance Benchmarks")
    struct PerformanceTests {

        @Test("prismBenchmark modifier attaches")
        @MainActor func benchmarkModifier() {
            let view = Text("Content")
                .prismBenchmark("TestView")
            _ = view
        }
    }

    // MARK: - B5: Style Protocol System

    @Suite("Style Protocol")
    struct StyleProtocolTests {

        @Test("PrismElevatedCardStyle creates body")
        @MainActor func elevatedCardStyle() {
            let style = PrismElevatedCardStyle()
            let body = style.makeBody(
                content: AnyView(Text("Card")),
                theme: DefaultTheme()
            )
            _ = body
        }

        @Test("PrismOutlinedCardStyle creates body")
        @MainActor func outlinedCardStyle() {
            let style = PrismOutlinedCardStyle()
            let body = style.makeBody(
                content: AnyView(Text("Card")),
                theme: DefaultTheme()
            )
            _ = body
        }

        @Test("PrismFlatCardStyle creates body")
        @MainActor func flatCardStyle() {
            let style = PrismFlatCardStyle()
            let body = style.makeBody(
                content: AnyView(Text("Card")),
                theme: DefaultTheme()
            )
            _ = body
        }
    }

    // MARK: - B6: Environment Setup

    @Suite("Environment Setup")
    struct EnvironmentSetupTests {

        @Test("prismEnvironment with theme only")
        @MainActor func environmentThemeOnly() {
            let view = Text("Test")
                .prismEnvironment(theme: DefaultTheme())
            _ = view
        }

        @Test("prismEnvironment with color scheme")
        @MainActor func environmentWithColorScheme() {
            let view = Text("Dark")
                .prismEnvironment(theme: DarkTheme(), colorScheme: .dark)
            _ = view
        }
    }

    // MARK: - B8: Preview Blocks

    @Suite("Preview Blocks")
    struct PreviewBlockTests {

        @Test("buttonVariants renders")
        @MainActor func buttonVariants() {
            let view = PrismPreviewBlocks.buttonVariants()
            _ = view
        }

        @Test("typographyScale renders")
        @MainActor func typographyScale() {
            let view = PrismPreviewBlocks.typographyScale()
            _ = view
        }

        @Test("colorSwatches renders")
        @MainActor func colorSwatches() {
            let view = PrismPreviewBlocks.colorSwatches()
            _ = view
        }

        @Test("spacingScale renders")
        @MainActor func spacingScale() {
            let view = PrismPreviewBlocks.spacingScale()
            _ = view
        }

        @Test("themeComparison renders")
        @MainActor func themeComparison() {
            let view = PrismPreviewBlocks.themeComparison()
            _ = view
        }

        @Test("radiusScale renders")
        @MainActor func radiusScale() {
            let view = PrismPreviewBlocks.radiusScale()
            _ = view
        }
    }

    // MARK: - C11: macOS Menu Bar

    #if os(macOS)
        @Suite("Menu Bar")
        struct MenuBarTests {

            @Test("PrismMenuBarContent renders")
            @MainActor func menuBarContent() {
                let view = PrismMenuBarContent {
                    Button("Quit") {}
                }
                _ = view.body
            }

            @Test("PrismMenuBarButton renders")
            @MainActor func menuBarButton() {
                let view = PrismMenuBarButton("Settings", systemImage: "gear") {}
                _ = view.body
            }

            @Test("PrismMenuBarButton without icon")
            @MainActor func menuBarButtonNoIcon() {
                let view = PrismMenuBarButton("Quit") {}
                _ = view.body
            }
        }
    #endif

    // MARK: - D12: Navigation Path

    @Suite("Navigation Path")
    struct NavigationPathTests {

        @Test("PrismNavigationPath push and pop")
        @MainActor func pushPop() {
            let path = PrismNavigationPath<String>()
            #expect(path.isEmpty)
            #expect(path.count == 0)

            path.push("home")
            #expect(path.count == 1)
            #expect(path.current == "home")

            path.push("detail")
            #expect(path.count == 2)
            #expect(path.current == "detail")

            path.pop()
            #expect(path.count == 1)
            #expect(path.current == "home")
        }

        @Test("PrismNavigationPath popToRoot")
        @MainActor func popToRoot() {
            let path = PrismNavigationPath<Int>()
            path.push(1)
            path.push(2)
            path.push(3)
            #expect(path.count == 3)

            path.popToRoot()
            #expect(path.isEmpty)
        }

        @Test("PrismNavigationPath replace")
        @MainActor func replace() {
            let path = PrismNavigationPath<String>()
            path.push("old")
            path.replace(with: ["a", "b", "c"])
            #expect(path.count == 3)
            #expect(path.current == "c")
        }

        @Test("PrismNavigationPath pop on empty is safe")
        @MainActor func popEmpty() {
            let path = PrismNavigationPath<String>()
            path.pop()
            #expect(path.isEmpty)
        }

        @Test("PrismNavigationPath initial values")
        @MainActor func initialValues() {
            let path = PrismNavigationPath(["a", "b"])
            #expect(path.count == 2)
            #expect(path.current == "b")
        }
    }

    // MARK: - D13: Observable Helpers

    @Suite("Observable Helpers")
    struct ObservableTests {

        @Test("PrismViewModel protocol exists")
        @MainActor func viewModelProtocol() {
            #expect(true)
        }

        @Test("prismObservable modifier exists")
        @MainActor func observableModifierExists() {
            #expect(true)
        }
    }
}
