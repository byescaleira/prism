//
//  AtomsListView.swift
//  RyzePlayground
//
//  Created by Rafael Escaleira on 11/04/26.
//

import RyzeIntelligence
import RyzeUI
import SwiftUI

struct AtomsListView: View {
    @Environment(\.theme) private var theme
    @State private var selectedAtom: PlaygroundAtom?

    private let atoms: [PlaygroundAtom] = [
        .button,
        .text,
        .textField,
        .symbol,
        .asyncImage,
        .shape,
        .spacer,
        .label,
        .list,
        .lazyList,
        .section,
        .hStack,
        .vStack,
        .zStack,
        .tabView,
    ]

    var body: some View {
        RyzeLazyList {
            RyzeVStack(alignment: .leading, spacing: .medium) {
                ForEach(atoms, id: \.self) { atom in
                    AtomRow(atom: atom)
                        .onTapGesture {
                            selectedAtom = atom
                        }
                }
            }
            .ryzePadding()
            .ryzeBackgroundSecondary()
            .ryze(clip: .rounded(radius: 20))

            intelligenceSection
        }
        .navigationTitle("Atoms")
    }

    private var intelligenceSection: some View {
        RyzeVStack(alignment: .leading, spacing: .medium) {
            RyzeHStack(spacing: .small) {
                RyzeSymbol("brain.headset", mode: .hierarchical)
                    .ryze(color: .primary)

                RyzeText("Sobre Atoms")
                    .ryze(font: .headline)
            }

            RyzeBodyText(
                "Atoms são os componentes fundamentais do Design System. Eles representam elementos UI básicos e atômicos que não podem ser divididos em partes menores sem perder sua funcionalidade."
            )

            RyzeTag("15 componentes", style: .info, size: .small)
        }
        .ryzePadding()
        .ryzeBackgroundSecondary()
        .ryze(clip: .rounded(radius: 20))
    }
}

private struct AtomRow: View {
    @Environment(\.theme) private var theme
    let atom: PlaygroundAtom

    var body: some View {
        RyzeHStack(spacing: .medium) {
            RyzeSymbol(atom.icon, mode: .hierarchical)
                .ryze(font: .title2)
                .ryze(color: RyzeColor(rawValue: atom.color))

            RyzeVStack(alignment: .leading, spacing: .small) {
                RyzeText(atom.title)
                    .ryze(font: .body)
                RyzeFootnoteText(atom.description)
                    .lineLimit(1)
            }

            RyzeSpacer()

            RyzeSymbol("chevron.right")
                .ryze(color: .textSecondary)
        }
        .ryzePadding()
    }
}

// MARK: - Playground Atom Model

enum PlaygroundAtom: Hashable, CaseIterable {
    case button
    case text
    case textField
    case symbol
    case asyncImage
    case shape
    case spacer
    case label
    case list
    case lazyList
    case section
    case hStack
    case vStack
    case zStack
    case tabView

    var title: String {
        switch self {
        case .button: "RyzeButton"
        case .text: "RyzeText"
        case .textField: "RyzeTextField"
        case .symbol: "RyzeSymbol"
        case .asyncImage: "RyzeAsyncImage"
        case .shape: "RyzeShape"
        case .spacer: "RyzeSpacer"
        case .label: "RyzeLabel"
        case .list: "RyzeList"
        case .lazyList: "RyzeLazyList"
        case .section: "RyzeSection"
        case .hStack: "RyzeHStack"
        case .vStack: "RyzeVStack"
        case .zStack: "RyzeZStack"
        case .tabView: "RyzeTabView"
        }
    }

    var icon: String {
        switch self {
        case .button: "rectangle.fill"
        case .text: "textformat"
        case .textField: "text.justify"
        case .symbol: "star.fill"
        case .asyncImage: "photo.fill"
        case .shape: "circle.fill"
        case .spacer: "arrow.left.and.right"
        case .label: "tag.fill"
        case .list: "list.bullet"
        case .lazyList: "list.number"
        case .section: "section"
        case .hStack: "arrow.right"
        case .vStack: "arrow.down"
        case .zStack: "square.on.square"
        case .tabView: "square.grid.2x2"
        }
    }

    var color: Color {
        switch self {
        case .button: .init(red: 0.2, green: 0.4, blue: 0.9)
        case .text: .init(red: 0.4, green: 0.4, blue: 0.45)
        case .textField: .init(red: 0.1, green: 0.5, blue: 0.8)
        case .symbol: .init(red: 1.0, green: 0.6, blue: 0.0)
        case .asyncImage: .init(red: 0.6, green: 0.3, blue: 0.8)
        case .shape: .init(red: 0.9, green: 0.3, blue: 0.5)
        case .spacer: .init(red: 0.5, green: 0.5, blue: 0.5)
        case .label: .init(red: 0.1, green: 0.7, blue: 0.4)
        case .list: .init(red: 0.2, green: 0.4, blue: 0.9)
        case .lazyList: .init(red: 0.3, green: 0.5, blue: 0.9)
        case .section: .init(red: 0.4, green: 0.6, blue: 0.9)
        case .hStack: .init(red: 0.9, green: 0.5, blue: 0.1)
        case .vStack: .init(red: 0.9, green: 0.3, blue: 0.1)
        case .zStack: .init(red: 0.8, green: 0.2, blue: 0.6)
        case .tabView: .init(red: 0.5, green: 0.3, blue: 0.9)
        }
    }

    var description: String {
        switch self {
        case .button: "Botão estilizado com suporte a acessibilidade"
        case .text: "Componente de texto com estilos tipográficos"
        case .textField: "Campo de entrada com validação e label flutuante"
        case .symbol: "Ícone SF Symbols com modos de renderização"
        case .asyncImage: "Carregamento assíncrono de imagens com cache"
        case .shape: "Formas geométricas para clip e background"
        case .spacer: "Espaçador semântico com tokens de spacing"
        case .label: "Label com ícone e texto combinados"
        case .list: "Lista de rows com seleção opcional"
        case .lazyList: "Lista com lazy loading para performance"
        case .section: "Seção de lista com header e footer"
        case .hStack: "Container horizontal com espaçamento semântico"
        case .vStack: "Container vertical com espaçamento semântico"
        case .zStack: "Container em camadas (z-axis)"
        case .tabView: "View de abas com navegação por tabs"
        }
    }

    var demoRoute: PlaygroundRoute {
        switch self {
        case .button: .buttonDemo
        case .text: .textDemo
        case .textField: .textFieldDemo
        case .symbol: .symbolDemo
        case .asyncImage: .asyncImageDemo
        case .shape: .shapeDemo
        case .spacer: .spacerDemo
        case .label: .labelDemo
        case .list: .listDemo
        case .lazyList: .listDemo
        case .section: .sectionDemo
        case .hStack: .listDemo
        case .vStack: .listDemo
        case .zStack: .listDemo
        case .tabView: .tabViewDemo
        }
    }
}

#Preview {
    RyzeNavigationView(router: .init()) { (_: PlaygroundRoute) in
        EmptyView()
    } content: {
        AtomsListView()
    }
    .ryze(theme: RyzePlaygroundTheme())
}
