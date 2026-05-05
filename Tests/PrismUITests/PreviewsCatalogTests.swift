import SwiftUI
import Testing

@testable import PrismUI

@MainActor
@Suite("Previews Catalog")
struct PreviewsCatalogTests {

    @Test("buttons preview type exists")
    @MainActor func buttons() {
        #expect(type(of: PrismPreviews.buttons) is any View.Type)
    }

    @Test("textFields preview type exists")
    @MainActor func textFields() {
        #expect(type(of: PrismPreviews.textFields) is any View.Type)
    }

    @Test("cards preview type exists")
    @MainActor func cards() {
        #expect(type(of: PrismPreviews.cards) is any View.Type)
    }

    @Test("tags preview type exists")
    @MainActor func tags() {
        #expect(type(of: PrismPreviews.tags) is any View.Type)
    }

    @Test("avatars preview type exists")
    @MainActor func avatars() {
        #expect(type(of: PrismPreviews.avatars) is any View.Type)
    }

    @Test("loadingStates preview type exists")
    @MainActor func loadingStates() {
        #expect(type(of: PrismPreviews.loadingStates) is any View.Type)
    }

    @Test("banners preview type exists")
    @MainActor func banners() {
        #expect(type(of: PrismPreviews.banners) is any View.Type)
    }

    @Test("searchBar preview type exists")
    @MainActor func searchBar() {
        #expect(type(of: PrismPreviews.searchBar) is any View.Type)
    }

    @Test("forms preview type exists")
    @MainActor func forms() {
        #expect(type(of: PrismPreviews.forms) is any View.Type)
    }

    @Test("layout preview type exists")
    @MainActor func layout() {
        #expect(type(of: PrismPreviews.layout) is any View.Type)
    }

    @Test("elevationScale preview type exists")
    @MainActor func elevationScale() {
        #expect(type(of: PrismPreviews.elevationScale) is any View.Type)
    }

    @Test("motionScale preview type exists")
    @MainActor func motionScale() {
        #expect(type(of: PrismPreviews.motionScale) is any View.Type)
    }

    @Test("allThemes preview type exists")
    @MainActor func allThemes() {
        #expect(type(of: PrismPreviews.allThemes) is any View.Type)
    }

    @Test("PrismPreviewCatalog wraps content")
    @MainActor func catalogWrapper() {
        let view = PrismPreviewCatalog {
            Text("Test")
        }
        _ = view.body
    }

    @Test("PrismPreviewBlocks all methods return views")
    @MainActor func previewBlocks() {
        #expect(type(of: PrismPreviewBlocks.buttonVariants()) is any View.Type)
        #expect(type(of: PrismPreviewBlocks.typographyScale()) is any View.Type)
        #expect(type(of: PrismPreviewBlocks.colorSwatches()) is any View.Type)
        #expect(type(of: PrismPreviewBlocks.spacingScale()) is any View.Type)
        #expect(type(of: PrismPreviewBlocks.themeComparison()) is any View.Type)
        #expect(type(of: PrismPreviewBlocks.radiusScale()) is any View.Type)
    }
}
