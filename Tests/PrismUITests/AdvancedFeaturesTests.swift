import Testing
import SwiftUI
@testable import PrismUI

@MainActor
@Suite("Advanced Features")
struct AdvancedFeaturesTests {

    // MARK: - Theme Editor

    @Suite("Theme Editor")
    struct ThemeEditorTests {

        @Test("PrismThemeEditor renders")
        @MainActor func themeEditorRenders() {
            let view = PrismThemeEditor()
            _ = view.body
        }
    }

    // MARK: - Auto Theme

    @Suite("Auto Theme Generation")
    struct AutoThemeTests {

        @Test("generate complementary from blue")
        @MainActor func complementary() {
            let theme = PrismAutoTheme.generate(from: .blue)
            let brand = theme.color(.brand)
            #expect(brand != nil)
        }

        @Test("generate analogous from red")
        @MainActor func analogous() {
            let theme = PrismAutoTheme.analogous(from: .red)
            let brand = theme.color(.brand)
            #expect(brand != nil)
        }

        @Test("generate triadic from green")
        @MainActor func triadic() {
            let theme = PrismAutoTheme.triadic(from: .green)
            let brand = theme.color(.brand)
            #expect(brand != nil)
        }

        @Test("generate split-complementary from purple")
        @MainActor func splitComplementary() {
            let theme = PrismAutoTheme.splitComplementary(from: .purple)
            let brand = theme.color(.brand)
            #expect(brand != nil)
        }

        @Test("Harmony cases")
        @MainActor func harmonyCases() {
            let cases = PrismAutoTheme.Harmony.allCases
            #expect(cases.count == 4)
        }

        @Test("generate with harmony parameter")
        @MainActor func generateWithHarmony() {
            for harmony in PrismAutoTheme.Harmony.allCases {
                let theme = PrismAutoTheme.generate(from: .orange, harmony: harmony)
                #expect(theme.color(.brand) != nil)
            }
        }

        @Test("different harmonies produce different themes")
        @MainActor func differentHarmonies() {
            let comp = PrismAutoTheme.generate(from: .blue, harmony: .complementary)
            let tri = PrismAutoTheme.generate(from: .blue, harmony: .triadic)
            let brandComp = comp.color(.brandVariant).resolve(in: .init())
            let brandTri = tri.color(.brandVariant).resolve(in: .init())
            let different = abs(Double(brandComp.red) - Double(brandTri.red)) > 0.01
                || abs(Double(brandComp.green) - Double(brandTri.green)) > 0.01
                || abs(Double(brandComp.blue) - Double(brandTri.blue)) > 0.01
            #expect(different)
        }
    }

    // MARK: - Figma Sync

    @Suite("Figma Sync")
    struct FigmaSyncTests {

        @Test("exportVariables produces valid structure")
        @MainActor func exportStructure() {
            let result = PrismFigmaSync.exportVariables(theme: DefaultTheme())
            #expect(result["version"] as? String == "1.0")
            let collections = result["collections"] as? [[String: Any]]
            #expect(collections?.count == 2)
        }

        @Test("exportVariablesString produces JSON")
        @MainActor func exportString() {
            let json = PrismFigmaSync.exportVariablesString(theme: DefaultTheme())
            #expect(json != nil)
            #expect(json!.contains("Prism Colors"))
        }

        @Test("exportDTCG has color tokens")
        @MainActor func dtcgExport() {
            let tokens = PrismFigmaSync.exportDTCG(theme: DefaultTheme())
            #expect(tokens["color.brand"] != nil)
            #expect(tokens["spacing.md"] != nil)
            #expect(tokens["radius.md"] != nil)
            #expect(tokens["elevation.medium"] != nil)
        }

        @Test("importTheme roundtrip")
        @MainActor func importRoundtrip() {
            let exported = PrismFigmaSync.exportVariables(theme: DefaultTheme())
            guard let data = try? JSONSerialization.data(withJSONObject: exported) else {
                Issue.record("Failed to serialize")
                return
            }
            let imported = PrismFigmaSync.importTheme(from: data)
            #expect(imported != nil)
        }

        @Test("importTheme from string")
        @MainActor func importFromString() {
            let json = PrismFigmaSync.exportVariablesString(theme: DefaultTheme()) ?? ""
            let imported = PrismFigmaSync.importTheme(from: json)
            #expect(imported != nil)
        }

        @Test("importTheme returns nil for invalid data")
        @MainActor func importInvalid() {
            let result = PrismFigmaSync.importTheme(from: Data())
            #expect(result == nil)
        }
    }

    // MARK: - Storybook

    @Suite("Storybook")
    struct StorybookTests {

        @Test("PrismStorybook renders")
        @MainActor func storybookRenders() {
            let view = PrismStorybook()
            _ = view.body
        }

        @Test("StoryCategory has all categories")
        @MainActor func storyCategories() {
            let categories = PrismStorybook.StoryCategory.allCases
            #expect(categories.count == 5)
        }

        @Test("Each category has stories")
        @MainActor func categoriesHaveStories() {
            for category in PrismStorybook.StoryCategory.allCases {
                #expect(!category.stories.isEmpty)
            }
        }

        @Test("Story equality by id")
        @MainActor func storyEquality() {
            let stories = PrismStorybook.StoryCategory.buttons.stories
            guard let first = stories.first else {
                Issue.record("No stories")
                return
            }
            #expect(first == first)
            #expect(first.id == "button-filled")
        }

        @Test("ThemeChoice has all cases")
        @MainActor func themeChoices() {
            let choices = PrismStorybook.ThemeChoice.allCases
            #expect(choices.count == 3)
        }

        @Test("Each ThemeChoice produces a theme")
        @MainActor func themeChoiceProducesTheme() {
            for choice in PrismStorybook.ThemeChoice.allCases {
                let theme = choice.theme
                #expect(theme.color(.brand) != nil)
            }
        }
    }
}
