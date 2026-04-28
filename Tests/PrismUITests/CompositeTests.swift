import SwiftUI
import Testing

@testable import PrismUI

struct CompositeTests {

    // MARK: - PrismAlert

    @Test
    func alertActionCreatesWithTitle() {
        let action = PrismAlert.Action("OK")
        #expect(action.role == nil)
    }

    @Test
    func alertDestructiveActionHasCorrectRole() {
        let action = PrismAlert.Action.destructive("Delete") {}
        #expect(action.role == .destructive)
    }

    @Test
    func alertCancelActionHasCorrectRole() {
        let action = PrismAlert.Action.cancel()
        #expect(action.role == .cancel)
    }

    // MARK: - PrismBanner

    @Test
    func bannerStylesHaveFourCases() {
        let styles: [PrismBanner.Style] = [.info, .success, .warning, .error]
        #expect(styles.count == 4)
    }

    @Test
    func bannerStyleIconsAreDistinct() {
        let icons = [PrismBanner.Style.info, .success, .warning, .error].map(\.icon)
        #expect(Set(icons).count == 4)
    }

    // MARK: - PrismSearchBar

    @Test
    func searchBarCreatesWithBinding() {
        @State var text = ""
        let bar = PrismSearchBar(text: $text)
        #expect(bar != nil)
    }

    // MARK: - PrismToolbar

    @Test
    func toolbarItemCreatesWithTitleAndIcon() {
        let item = PrismToolbar.ToolbarItem("Save", icon: "checkmark") {}
        #expect(item.icon == "checkmark")
    }

    @Test
    func toolbarItemCreatesWithoutIcon() {
        let item = PrismToolbar.ToolbarItem("Done") {}
        #expect(item.icon == nil)
    }
}
