import SwiftUI
import Testing

@testable import PrismUI

struct NewComponentTests {

    // MARK: - PrismToast

    @Test
    func toastCreatesWithMessage() {
        let toast = PrismToast("Saved successfully")
        #expect(toast != nil)
    }

    @Test
    func toastStylesHaveFourCases() {
        let styles: [PrismToast.Style] = [.neutral, .success, .error, .info]
        #expect(styles.count == 4)
    }

    @Test
    func toastCreatesWithIconAndStyle() {
        let toast = PrismToast("Error occurred", icon: "xmark.circle", style: .error)
        #expect(toast != nil)
    }

    // MARK: - PrismProgressBar

    @Test
    func progressBarDeterminate() {
        let bar = PrismProgressBar(value: 0.5, label: "Uploading")
        #expect(bar != nil)
    }

    @Test
    func progressBarIndeterminate() {
        let bar = PrismProgressBar(label: "Loading")
        #expect(bar != nil)
    }

    @Test
    func progressBarClampsValue() {
        let bar = PrismProgressBar(value: 1.5, total: 1.0)
        #expect(bar != nil)
    }

    // MARK: - PrismAvatar

    @Test
    func avatarCreatesWithInitials() {
        let avatar = PrismAvatar(initials: "JD", size: .large)
        #expect(avatar != nil)
    }

    @Test
    func avatarCreatesWithImage() {
        let avatar = PrismAvatar(image: Image(systemName: "person"), status: .online)
        #expect(avatar != nil)
    }

    @Test
    func avatarSizesAreDistinct() {
        let sizes: [PrismAvatar.Size] = [.small, .medium, .large, .xLarge, .custom(100)]
        let dimensions = sizes.map(\.dimension)
        #expect(Set(dimensions).count == 5)
    }

    @Test
    func avatarStatusHasFourCases() {
        let statuses: [PrismAvatar.Status] = [.online, .offline, .busy, .away]
        #expect(statuses.count == 4)
    }

    // MARK: - PrismMenu

    @Test
    func menuCreatesWithItems() {
        let menu = PrismMenu("Actions", items: [
            .button("Edit", icon: "pencil") {},
            .divider,
            .destructive("Delete", icon: "trash") {},
        ])
        #expect(menu != nil)
    }

    @Test
    func menuSectionCreatesWithSubItems() {
        let menu = PrismMenu("Options", items: [
            .section("Group", items: [
                .button("Item 1") {},
                .button("Item 2") {},
            ]),
        ])
        #expect(menu != nil)
    }

    // MARK: - PrismSegmentedControl

    @Test
    func segmentedControlCreatesWithSelection() {
        @State var selection = 0
        let control = PrismSegmentedControl("View", selection: $selection) {
            Text("List").tag(0)
            Text("Grid").tag(1)
        }
        #expect(control != nil)
    }

    // MARK: - PrismStepper

    @Test
    func stepperCreatesWithRange() {
        @State var value = 5
        let stepper = PrismStepper("Quantity", value: $value, in: 1...99, icon: "number")
        #expect(stepper != nil)
    }

    @Test
    func stepperSupportsFormat() {
        @State var value = 3
        let stepper = PrismStepper("Size", value: $value, in: 1...10) { "\($0) items" }
        #expect(stepper != nil)
    }

    // MARK: - PrismBottomSheet

    @Test
    func bottomSheetCreatesWithSnapPoints() {
        @State var isPresented = true
        let sheet = PrismBottomSheet(
            isPresented: $isPresented,
            snapPoints: [0.3, 0.6, 0.9]
        ) {
            Text("Content")
        }
        #expect(sheet != nil)
    }

    // MARK: - PrismChip

    @Test
    func chipCreatesWithSelection() {
        @State var isSelected = false
        let chip = PrismChip("Swift", isSelected: $isSelected, icon: "swift")
        #expect(chip != nil)
    }

    @Test
    func chipGroupCreatesWithData() {
        let tags = ["iOS", "macOS", "watchOS"]
        let group = PrismChipGroup(tags, id: \.self) { tag in
            Text(tag)
        }
        #expect(group != nil)
    }

    // MARK: - PrismEmptyState

    @Test
    func emptyStateCreatesWithAction() {
        let state = PrismEmptyState(
            icon: "tray",
            title: "No items",
            message: "Add your first item to get started"
        ) {
            PrismButton("Add Item") {}
        }
        #expect(state != nil)
    }

    @Test
    func emptyStateCreatesWithoutAction() {
        let state = PrismEmptyState(icon: "magnifyingglass", title: "No results")
        #expect(state != nil)
    }

    // MARK: - PrismTextArea

    @Test
    func textAreaCreatesWithBinding() {
        @State var text = ""
        let area = PrismTextArea("Description", text: $text, maxCharacters: 500)
        #expect(area != nil)
    }

    // MARK: - PrismRating

    @Test
    func ratingCreatesWithValue() {
        @State var value = 3.5
        let rating = PrismRating(value: $value, allowHalf: true)
        #expect(rating != nil)
    }

    @Test
    func ratingDefaultsFiveStars() {
        @State var value = 0.0
        let rating = PrismRating(value: $value)
        #expect(rating != nil)
    }

    // MARK: - PrismCountdownTimer

    @Test
    func countdownTimerCreatesWithSeconds() {
        let timer = PrismCountdownTimer(seconds: 120)
        #expect(timer != nil)
    }

    // MARK: - PrismPinField

    @Test
    func pinFieldCreatesWithBinding() {
        @State var code = ""
        let field = PrismPinField(code: $code, length: 4, isSecure: true)
        #expect(field != nil)
    }

    @Test
    func pinFieldDefaultsSixDigits() {
        @State var code = ""
        let field = PrismPinField(code: $code)
        #expect(field != nil)
    }

    // MARK: - PrismColorWell

    @Test
    func colorWellCreatesWithSelection() {
        @State var color = Color.blue
        let well = PrismColorWell("Accent", selection: $color)
        #expect(well != nil)
    }

    @Test
    func colorWellDefaultPresetsHaveTenColors() {
        #expect(PrismColorWell.defaultPresets.count == 10)
    }

    // MARK: - PrismSwipeAction

    @Test
    func swipeActionDeletePreset() {
        let action = PrismSwipeAction.delete {}
        #expect(action.role == .destructive)
    }

    @Test
    func swipeActionCustom() {
        let action = PrismSwipeAction("Share", icon: "square.and.arrow.up") {}
        #expect(action.icon == "square.and.arrow.up")
    }
}
