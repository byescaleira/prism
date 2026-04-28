import Testing
import SwiftUI
@testable import PrismUI

@MainActor
@Suite("Apple Reference Upgrades")
struct AppleReferenceTests {

    // MARK: - Glass Upgrades

    @Suite("Glass Effects")
    struct GlassTests {

        @Test("prismGlass with default shape")
        @MainActor func glassDefault() {
            let view = Text("Glass")
                .prismGlass()
            _ = view
        }

        @Test("prismGlass with corner radius")
        @MainActor func glassCornerRadius() {
            let view = Text("Glass")
                .prismGlass(cornerRadius: 16)
            _ = view
        }

        @Test("prismGlass with custom shape")
        @MainActor func glassCustomShape() {
            let view = Text("Glass")
                .prismGlass(in: RoundedRectangle(cornerRadius: 12))
            _ = view
        }

        @Test("PrismGlassContainer renders")
        @MainActor func glassContainer() {
            let view = PrismGlassContainer {
                Text("A")
                Text("B")
            }
            _ = view.body
        }

        @Test("PrismGlassContainer custom spacing")
        @MainActor func glassContainerSpacing() {
            let view = PrismGlassContainer(spacing: 16) {
                Text("Content")
            }
            _ = view.body
        }

        @Test("prismBackgroundExtension modifier")
        @MainActor func backgroundExtension() {
            let view = Image(systemName: "photo")
                .prismBackgroundExtension()
            _ = view
        }
    }

    // MARK: - Button Variants

    @Suite("Button Glass Variants")
    struct ButtonGlassTests {

        @Test("PrismButton glass variant")
        @MainActor func glassButton() {
            let view = PrismButton("Glass", variant: .glass) {}
            _ = view.body
        }

        @Test("PrismButton glassProminent variant")
        @MainActor func glassProminentButton() {
            let view = PrismButton("Prominent", variant: .glassProminent) {}
            _ = view.body
        }

        @Test("All button variants exist")
        @MainActor func allVariants() {
            let variants: [PrismButtonVariant] = [
                .filled, .tinted, .bordered, .plain, .glass, .glassProminent,
            ]
            #expect(variants.count == 6)
        }
    }

    // MARK: - Motion Token Upgrades

    @Suite("Motion Tokens")
    struct MotionTests {

        @Test("New spring motion tokens exist")
        @MainActor func springTokens() {
            let tokens: [MotionToken] = [.snappy, .bouncy, .smooth]
            for token in tokens {
                _ = token.animation
                _ = token.duration
            }
        }

        @Test("All motion tokens in allCases")
        @MainActor func allMotionCases() {
            #expect(MotionToken.allCases.count == 8)
        }

        @Test("Snappy uses .snappy animation")
        @MainActor func snappyAnimation() {
            let token = MotionToken.snappy
            #expect(token.duration == 0.25)
        }

        @Test("Bouncy uses .bouncy animation")
        @MainActor func bouncyAnimation() {
            let token = MotionToken.bouncy
            #expect(token.duration == 0.35)
        }
    }

    // MARK: - Typography Width

    @Suite("Typography Width")
    struct TypographyWidthTests {

        @Test("TypographyToken font with width")
        @MainActor func fontWithWidth() {
            let font = TypographyToken.title.font(weight: .bold, width: .expanded)
            _ = font
        }

        @Test("TypographyToken font with design and width")
        @MainActor func fontWithDesignAndWidth() {
            let font = TypographyToken.body.font(weight: .regular, design: .serif, width: .condensed)
            _ = font
        }

        @Test("prismFont with width modifier")
        @MainActor func prismFontWidth() {
            let view = Text("Expanded")
                .prismFont(.headline, weight: .bold, width: .expanded)
            _ = view
        }

        @Test("prismFontWidth modifier")
        @MainActor func fontWidthModifier() {
            let view = Text("Condensed")
                .prismFontWidth(.condensed)
            _ = view
        }
    }

    // MARK: - Sheet Upgrades

    @Suite("Sheet & Presentation")
    struct SheetTests {

        @Test("prismSheet with background style")
        @MainActor func sheetBackground() {
            @State var shown = false
            let view = Text("Content")
                .prismSheet(isPresented: $shown, background: .material) {
                    Text("Sheet")
                }
            _ = view
        }

        @Test("prismSheet with interactive dismiss disabled")
        @MainActor func sheetNoDismiss() {
            @State var shown = false
            let view = Text("Content")
                .prismSheet(isPresented: $shown, interactiveDismiss: false) {
                    Text("Locked")
                }
            _ = view
        }

        @Test("PrismSheetBackground cases exist")
        @MainActor func sheetBackgroundCases() {
            let cases: [PrismSheetBackground] = [.automatic, .material, .clear]
            #expect(cases.count == 3)
        }

        @Test("prismConfirmationDialog modifier")
        @MainActor func confirmationDialog() {
            @State var shown = false
            let view = Text("Content")
                .prismConfirmationDialog("Delete?", isPresented: $shown) {
                    Button("Delete", role: .destructive) {}
                    Button("Cancel", role: .cancel) {}
                }
            _ = view
        }

        @Test("prismConfirmationDialog with message")
        @MainActor func confirmationDialogMessage() {
            @State var shown = false
            let view = Text("Content")
                .prismConfirmationDialog("Delete?", isPresented: $shown) {
                    Button("Delete", role: .destructive) {}
                } message: {
                    Text("This cannot be undone")
                }
            _ = view
        }

        @Test("prismInspector modifier")
        @MainActor func inspectorModifier() {
            @State var shown = false
            let view = Text("Content")
                .prismInspector(isPresented: $shown) {
                    Text("Inspector sidebar")
                }
            _ = view
        }

        @Test("prismSheet item-based presentation")
        @MainActor func sheetItemBased() {
            struct Item: Identifiable { let id = UUID() }
            @State var item: Item? = nil
            let view = Text("Content")
                .prismSheet(item: $item) { item in
                    Text("\(item.id)")
                }
            _ = view
        }
    }

    // MARK: - Navigation Split View

    @Suite("Navigation Split View")
    struct SplitViewTests {

        @Test("PrismSplitView two-column")
        @MainActor func twoColumn() {
            let view = PrismSplitView {
                List { Text("Sidebar") }
            } detail: {
                Text("Detail")
            }
            _ = view.body
        }

        @Test("PrismSplitView with column visibility")
        @MainActor func columnVisibility() {
            let view = PrismSplitView(columnVisibility: .all) {
                List { Text("Sidebar") }
            } detail: {
                Text("Detail")
            }
            _ = view.body
        }

        @Test("PrismThreeColumnView")
        @MainActor func threeColumn() {
            let view = PrismThreeColumnView {
                List { Text("Sidebar") }
            } content: {
                List { Text("Content") }
            } detail: {
                Text("Detail")
            }
            _ = view.body
        }
    }

    // MARK: - Transitions

    @Suite("Transitions & Scroll Effects")
    struct TransitionTests {

        @Test("prismScrollTransition scale")
        @MainActor func scrollTransitionScale() {
            let view = Text("Item")
                .prismScrollTransition()
            _ = view
        }

        @Test("prismScrollTransitionFade")
        @MainActor func scrollTransitionFade() {
            let view = Text("Item")
                .prismScrollTransitionFade()
            _ = view
        }

        @Test("prismSymbolTransition")
        @MainActor func symbolTransition() {
            let view = Image(systemName: "checkmark")
                .prismSymbolTransition()
            _ = view
        }

        @Test("prismScrollEdge")
        @MainActor func scrollEdge() {
            let view = ScrollView {
                Text("Content")
            }
            .prismScrollEdge()
            _ = view
        }
    }

    // MARK: - Mesh Gradient

    @Suite("Mesh Gradient")
    struct MeshGradientTests {

        @Test("PrismMeshGradient aurora preset", .tags(.skipOnOlderOS))
        @available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
        @MainActor func auroraPreset() {
            let view = PrismMeshGradient(preset: .aurora)
            _ = view.body
        }

        @Test("PrismMeshGradient sunset preset", .tags(.skipOnOlderOS))
        @available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
        @MainActor func sunsetPreset() {
            let view = PrismMeshGradient(preset: .sunset)
            _ = view.body
        }

        @Test("PrismMeshGradient ocean preset", .tags(.skipOnOlderOS))
        @available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
        @MainActor func oceanPreset() {
            let view = PrismMeshGradient(preset: .ocean)
            _ = view.body
        }

        @Test("PrismMeshGradient subtle preset", .tags(.skipOnOlderOS))
        @available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
        @MainActor func subtlePreset() {
            let view = PrismMeshGradient(preset: .subtle)
            _ = view.body
        }

        @Test("PrismMeshGradient custom points", .tags(.skipOnOlderOS))
        @available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
        @MainActor func customGradient() {
            let view = PrismMeshGradient(
                width: 2, height: 2,
                points: [
                    SIMD2(0, 0), SIMD2(1, 0),
                    SIMD2(0, 1), SIMD2(1, 1),
                ],
                colors: [.red, .blue, .green, .yellow]
            )
            _ = view.body
        }

        @Test("MeshPreset cases")
        @available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
        @MainActor func meshPresetCases() {
            let presets: [PrismMeshGradient.MeshPreset] = [.aurora, .sunset, .ocean, .subtle, .custom]
            #expect(presets.count == 5)
        }
    }

    // MARK: - Responsive Layout

    @Suite("Responsive Layout")
    struct ResponsiveTests {

        @Test("PrismResponsiveSize fractions")
        @MainActor func sizeFractions() {
            #expect(PrismResponsiveSize.full.fraction == 1.0)
            #expect(PrismResponsiveSize.half.fraction == 0.5)
            #expect(abs(PrismResponsiveSize.third.fraction - 1.0 / 3.0) < 0.001)
            #expect(PrismResponsiveSize.quarter.fraction == 0.25)
            #expect(PrismResponsiveSize.custom(0.7).fraction == 0.7)
        }

        @Test("prismContainerFrame modifier")
        @MainActor func containerFrame() {
            let view = Text("Half width")
                .prismContainerFrame(.horizontal, size: .half)
            _ = view
        }

        @Test("PrismScaledView renders")
        @MainActor func scaledView() {
            let view = PrismScaledView(baseSize: 44) { size in
                Image(systemName: "star")
                    .frame(width: size, height: size)
            }
            _ = view.body
        }

        @Test("prismContentMargins modifier")
        @MainActor func contentMargins() {
            let view = ScrollView { Text("Content") }
                .prismContentMargins(.bottom, .xl)
            _ = view
        }
    }

    // MARK: - Empty State Upgrades

    @Suite("Empty State")
    struct EmptyStateTests {

        @Test("PrismContentUnavailable basic")
        @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
        @MainActor func contentUnavailable() {
            let view = PrismContentUnavailable(
                "No Results",
                systemImage: "magnifyingglass"
            )
            _ = view.body
        }

        @Test("PrismContentUnavailable with description")
        @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
        @MainActor func contentUnavailableDescription() {
            let view = PrismContentUnavailable(
                "No Items",
                systemImage: "tray",
                description: "Add items to get started"
            )
            _ = view.body
        }

        @Test("PrismContentUnavailable with actions")
        @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
        @MainActor func contentUnavailableActions() {
            let view = PrismContentUnavailable(
                "Empty",
                systemImage: "plus.circle",
                description: "Create first item"
            ) {
                Button("Add") {}
            }
            _ = view.body
        }

        @Test("PrismSearchUnavailable empty query")
        @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
        @MainActor func searchUnavailableEmpty() {
            let view = PrismSearchUnavailable()
            _ = view.body
        }

        @Test("PrismSearchUnavailable with query")
        @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
        @MainActor func searchUnavailableWithQuery() {
            let view = PrismSearchUnavailable(query: "test")
            _ = view.body
        }
    }

    // MARK: - Share & Search

    @Suite("Share & Search")
    struct ShareSearchTests {

        @Test("PrismShareButton with text")
        @MainActor func shareText() {
            let view = PrismShareButton(text: "Hello World")
            _ = view.body
        }

        @Test("PrismShareButton with URL")
        @MainActor func shareURL() {
            let view = PrismShareButton(url: URL(string: "https://example.com")!)
            _ = view.body
        }

        @Test("prismSearchable modifier")
        @MainActor func searchable() {
            @State var text = ""
            let view = List { Text("Item") }
                .prismSearchable(text: $text, prompt: "Find items")
            _ = view
        }
    }

    // MARK: - Scroll Modifiers

    @Suite("Scroll Modifiers")
    struct ScrollTests {

        @Test("prismScrollTarget viewAligned")
        @MainActor func scrollTargetAligned() {
            let view = ScrollView(.horizontal) {
                LazyHStack { Text("A") }
            }
            .prismScrollTarget(.viewAligned)
            _ = view
        }

        @Test("prismScrollTarget paging")
        @MainActor func scrollTargetPaging() {
            let view = ScrollView(.horizontal) {
                LazyHStack { Text("A") }
            }
            .prismScrollTarget(.paging)
            _ = view
        }

        @Test("prismScrollIndicators hidden")
        @MainActor func scrollIndicatorsHidden() {
            let view = ScrollView { Text("A") }
                .prismScrollIndicators(.hidden)
            _ = view
        }

        @Test("prismScrollClipDisabled")
        @MainActor func scrollClipDisabled() {
            let view = ScrollView { Text("A") }
                .prismScrollClipDisabled()
            _ = view
        }

        @Test("PrismScrollBehavior cases")
        @MainActor func scrollBehaviorCases() {
            let cases: [PrismScrollBehavior] = [.viewAligned, .paging, .automatic]
            #expect(cases.count == 3)
        }
    }
}

extension Tag {
    @Tag static var skipOnOlderOS: Self
}
