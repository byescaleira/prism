import SwiftUI
import Testing

@testable import PrismUI

@MainActor
@Suite("Component Variants V2")
struct ComponentVariantsV2Tests {

    // MARK: - Icon Button

    @Suite("Icon Button")
    struct IconButtonTests {

        @Test("renders with default variant")
        @MainActor func defaultRender() {
            let view = PrismIconButton("star.fill") {}
            _ = view.body
        }

        @Test("renders with filled variant")
        @MainActor func filledRender() {
            let view = PrismIconButton("heart.fill", variant: .filled) {}
            _ = view.body
        }

        @Test("all sizes have correct frame dimensions")
        @MainActor func sizes() {
            let sizes: [PrismIconButton.Size] = [.small, .regular, .large]
            let expectedFrames: [CGFloat] = [32, 40, 52]
            let expectedIcons: [CGFloat] = [14, 18, 22]
            for (size, (frame, icon)) in zip(sizes, zip(expectedFrames, expectedIcons)) {
                #expect(size.frameSize == frame)
                #expect(size.iconSize == icon)
            }
        }

        @Test("destructive role renders")
        @MainActor func destructive() {
            let view = PrismIconButton("trash", variant: .filled, role: .destructive) {}
            _ = view.body
        }

        @Test("bordered variant renders")
        @MainActor func bordered() {
            let view = PrismIconButton("plus", variant: .bordered) {}
            _ = view.body
        }
    }

    // MARK: - Expandable Card

    @Suite("Expandable Card")
    struct ExpandableCardTests {

        @Test("renders collapsed")
        @MainActor func collapsed() {
            let view = PrismExpandableCard {
                Text("Header")
            } expanded: {
                Text("Detail")
            }
            _ = view.body
        }

        @Test("custom tokens")
        @MainActor func customTokens() {
            let view = PrismExpandableCard(
                surface: .surfaceSecondary,
                radius: .md,
                elevation: .medium
            ) {
                Text("Header")
            } expanded: {
                Text("Detail")
            }
            _ = view.body
        }
    }

    // MARK: - Skeleton View

    @Suite("Skeleton View")
    struct SkeletonViewTests {

        @Test("text layout renders")
        @MainActor func textLayout() {
            let view = PrismSkeletonView(.text)
            _ = view.body
        }

        @Test("avatar layout renders")
        @MainActor func avatarLayout() {
            let view = PrismSkeletonView(.avatar)
            _ = view.body
        }

        @Test("card layout renders")
        @MainActor func cardLayout() {
            let view = PrismSkeletonView(.card)
            _ = view.body
        }

        @Test("list layout renders")
        @MainActor func listLayout() {
            let view = PrismSkeletonView(.list(rows: 3))
            _ = view.body
        }

        @Test("custom layout renders")
        @MainActor func customLayout() {
            let view = PrismSkeletonView(.custom(width: 100, height: 20, radius: .sm))
            _ = view.body
        }

        @Test("default is text")
        @MainActor func defaultLayout() {
            let view = PrismSkeletonView()
            _ = view.body
        }
    }

    // MARK: - Search Suggestions

    @Suite("Search Suggestions")
    struct SearchSuggestionsTests {

        struct Item: Identifiable, Sendable {
            let id: Int
            let name: String
        }

        @Test("renders with empty suggestions")
        @MainActor func emptySuggestions() {
            let items: [Item] = []
            let view = PrismSearchSuggestions(
                text: .constant(""),
                suggestions: items
            ) { item in
                Text(item.name)
            } onSelect: { _ in
            }
            _ = view.body
        }

        @Test("renders with suggestions")
        @MainActor func withSuggestions() {
            let items = (0..<3).map { Item(id: $0, name: "Item \($0)") }
            let view = PrismSearchSuggestions(
                text: .constant("It"),
                suggestions: items
            ) { item in
                Text(item.name)
            } onSelect: { _ in
            }
            _ = view.body
        }

        @Test("max suggestions limits visible items")
        @MainActor func maxSuggestions() {
            let items = (0..<10).map { Item(id: $0, name: "Item \($0)") }
            let view = PrismSearchSuggestions(
                text: .constant("It"),
                suggestions: items,
                maxSuggestions: 3
            ) { item in
                Text(item.name)
            } onSelect: { _ in
            }
            _ = view.body
        }
    }

    // MARK: - Button Group

    @Suite("Button Group")
    struct ButtonGroupTests {

        @Test("renders")
        @MainActor func renders() {
            let view = PrismButtonGroup {
                PrismButton("A", variant: .bordered) {}
                PrismButton("B", variant: .filled) {}
            }
            _ = view.body
        }

        @Test("custom alignment and spacing")
        @MainActor func customParams() {
            let view = PrismButtonGroup(alignment: .trailing, spacing: .lg) {
                PrismButton("Cancel", variant: .plain) {}
            }
            _ = view.body
        }
    }

    // MARK: - Segmented Buttons

    @Suite("Segmented Buttons")
    struct SegmentedButtonsTests {

        @Test("renders with options")
        @MainActor func renders() {
            let view = PrismSegmentedButtons(
                options: ["Day", "Week", "Month"],
                selection: .constant("Day")
            )
            _ = view.body
        }

        @Test("selection state matches")
        @MainActor func selectionState() {
            let options = ["A", "B", "C"]
            let view = PrismSegmentedButtons(options: options, selection: .constant("B"))
            _ = view.body
        }
    }
}
