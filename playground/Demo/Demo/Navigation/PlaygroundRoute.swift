//
//  PlaygroundRoute.swift
//  PrismPlayground
//
//  Created by Rafael Escaleira on 11/04/26.
//

import PrismArchitecture
import SwiftUI

enum PlaygroundRoute: PrismRoutable, Hashable {
    // Categories
    case atomsList
    case moleculesList
    case modifiersList
    case patternsList

    // Atom demos
    case buttonDemo
    case textDemo
    case textFieldDemo
    case symbolDemo
    case asyncImageDemo
    case shapeDemo
    case spacerDemo
    case labelDemo
    case listDemo
    case sectionDemo
    case tabViewDemo

    // Molecule demos
    case tagDemo
    case carouselDemo
    case primaryButtonDemo
    case secondaryButtonDemo
    case bodyTextDemo
    case footnoteTextDemo
    case currencyTextFieldDemo

    // Modifier demos
    case glowDemo
    case skeletonDemo
    case confettiDemo
    case parallaxDemo
    case backgroundDemo

    // Intelligence
    case intelligenceDetail(component: String)

    var id: String {
        switch self {
        case .atomsList: "atoms_list"
        case .moleculesList: "molecules_list"
        case .modifiersList: "modifiers_list"
        case .patternsList: "patterns_list"
        case .buttonDemo: "button_demo"
        case .textDemo: "text_demo"
        case .textFieldDemo: "text_field_demo"
        case .symbolDemo: "symbol_demo"
        case .asyncImageDemo: "async_image_demo"
        case .shapeDemo: "shape_demo"
        case .spacerDemo: "spacer_demo"
        case .labelDemo: "label_demo"
        case .listDemo: "list_demo"
        case .sectionDemo: "section_demo"
        case .tabViewDemo: "tab_view_demo"
        case .tagDemo: "tag_demo"
        case .carouselDemo: "carousel_demo"
        case .primaryButtonDemo: "primary_button_demo"
        case .secondaryButtonDemo: "secondary_button_demo"
        case .bodyTextDemo: "body_text_demo"
        case .footnoteTextDemo: "footnote_text_demo"
        case .currencyTextFieldDemo: "currency_text_field_demo"
        case .glowDemo: "glow_demo"
        case .skeletonDemo: "skeleton_demo"
        case .confettiDemo: "confetti_demo"
        case .parallaxDemo: "parallax_demo"
        case .backgroundDemo: "background_demo"
        case .intelligenceDetail(let component): "intelligence_\(component)"
        }
    }

    @ViewBuilder
    func destinationView() -> some View {
        switch self {
        case .atomsList:
            AtomsListView()
        case .moleculesList:
            MoleculesListView()
        case .modifiersList:
            ModifiersListView()
        case .patternsList:
            PatternsListView()
        case .buttonDemo:
            ButtonDemoView()
        case .textDemo:
            TextDemoView()
        case .textFieldDemo:
            TextFieldDemoView()
        case .symbolDemo:
            SymbolDemoView()
        case .asyncImageDemo:
            AsyncImageDemoView()
        case .shapeDemo:
            ShapeDemoView()
        case .spacerDemo:
            SpacerDemoView()
        case .labelDemo:
            LabelDemoView()
        case .listDemo:
            ListDemoView()
        case .sectionDemo:
            SectionDemoView()
        case .tabViewDemo:
            TabViewDemoView()
        case .tagDemo:
            TagDemoView()
        case .carouselDemo:
            CarouselDemoView()
        case .primaryButtonDemo:
            PrimaryButtonDemoView()
        case .secondaryButtonDemo:
            SecondaryButtonDemoView()
        case .bodyTextDemo:
            BodyTextDemoView()
        case .footnoteTextDemo:
            FootnoteTextDemoView()
        case .currencyTextFieldDemo:
            CurrencyTextFieldDemoView()
        case .glowDemo:
            GlowDemoView()
        case .skeletonDemo:
            SkeletonDemoView()
        case .confettiDemo:
            ConfettiDemoView()
        case .parallaxDemo:
            ParallaxDemoView()
        case .backgroundDemo:
            BackgroundDemoView()
        case .intelligenceDetail(let component):
            IntelligenceDetailView(component: component)
        }
    }
}
