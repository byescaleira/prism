//
//  MoleculesListView.swift
//  PrismPlayground
//
//  Created by Rafael Escaleira on 11/04/26.
//

import PrismUI
import SwiftUI

struct MoleculesListView: View {
    @Environment(\.theme) private var theme

    private let molecules: [PlaygroundMolecule] = [
        .tag,
        .carousel,
        .primaryButton,
        .secondaryButton,
        .bodyText,
        .footnoteText,
        .currencyTextField,
        .navigationView,
        .browserView,
        .videoView,
    ]

    var body: some View {
        PrismLazyList {
            PrismVStack(alignment: .leading, spacing: .medium) {
                ForEach(molecules, id: \.self) { molecule in
                    MoleculeRow(molecule: molecule)
                }
            }
            .prismPadding()
            .prismBackgroundSecondary()
            .prism(clip: .rounded(radius: 20))

            intelligenceSection
        }
        .navigationTitle("Molecules")
    }

    private var intelligenceSection: some View {
        PrismVStack(alignment: .leading, spacing: .medium) {
            PrismHStack(spacing: .small) {
                PrismSymbol("brain.headset", mode: .hierarchical)
                    .prism(color: .primary)

                PrismText("Sobre Molecules")
                    .prism(font: .headline)
            }

            PrismBodyText(
                "Molecules são componentes compostos que combinam Atoms para criar funcionalidades mais complexas e específicas. Eles representam padrões de UI reutilizáveis."
            )

            PrismTag("10 componentes", style: .info, size: .small)
        }
        .prismPadding()
        .prismBackgroundSecondary()
        .prism(clip: .rounded(radius: 20))
    }
}

private struct MoleculeRow: View {
    @Environment(\.theme) private var theme
    let molecule: PlaygroundMolecule

    var body: some View {
        PrismHStack(spacing: .medium) {
            PrismSymbol(molecule.icon, mode: .hierarchical)
                .prism(font: .title2)
                .prism(color: PrismColor(rawValue: molecule.color))

            PrismVStack(alignment: .leading, spacing: .small) {
                PrismText(molecule.title)
                    .prism(font: .body)
                PrismFootnoteText(molecule.description)
                    .lineLimit(1)
            }

            PrismSpacer()

            PrismSymbol("chevron.right")
                .prism(color: .textSecondary)
        }
        .prismPadding()
    }
}

// MARK: - Playground Molecule Model

enum PlaygroundMolecule: Hashable, CaseIterable {
    case tag
    case carousel
    case primaryButton
    case secondaryButton
    case bodyText
    case footnoteText
    case currencyTextField
    case navigationView
    case browserView
    case videoView

    var title: String {
        switch self {
        case .tag: "PrismTag"
        case .carousel: "PrismCarousel"
        case .primaryButton: "PrismPrimaryButton"
        case .secondaryButton: "PrismSecondaryButton"
        case .bodyText: "PrismBodyText"
        case .footnoteText: "PrismFootnoteText"
        case .currencyTextField: "PrismCurrencyTextField"
        case .navigationView: "PrismNavigationView"
        case .browserView: "PrismBrowserView"
        case .videoView: "PrismVideoView"
        }
    }

    var icon: String {
        switch self {
        case .tag: "tag.fill"
        case .carousel: "arrow.left.and.right"
        case .primaryButton: "button.fill"
        case .secondaryButton: "button.programmable"
        case .bodyText: "doc.text"
        case .footnoteText: "doc.text.fill"
        case .currencyTextField: "dollarsign.circle.fill"
        case .navigationView: "navigation"
        case .browserView: "globe"
        case .videoView: "video.fill"
        }
    }

    var color: Color {
        switch self {
        case .tag: .init(red: 0.6, green: 0.3, blue: 0.8)
        case .carousel: .init(red: 0.9, green: 0.3, blue: 0.5)
        case .primaryButton: .init(red: 0.2, green: 0.4, blue: 0.9)
        case .secondaryButton: .init(red: 0.4, green: 0.4, blue: 0.45)
        case .bodyText: .init(red: 0.3, green: 0.3, blue: 0.35)
        case .footnoteText: .init(red: 0.5, green: 0.5, blue: 0.55)
        case .currencyTextField: .init(red: 0.1, green: 0.6, blue: 0.3)
        case .navigationView: .init(red: 0.2, green: 0.5, blue: 0.9)
        case .browserView: .init(red: 0.0, green: 0.4, blue: 0.8)
        case .videoView: .init(red: 0.8, green: 0.2, blue: 0.4)
        }
    }

    var description: String {
        switch self {
        case .tag: "Tag/badge para labels categorizados"
        case .carousel: "Carrossel horizontal com scroll automático"
        case .primaryButton: "Botão primário para ações principais"
        case .secondaryButton: "Botão secundário para ações secundárias"
        case .bodyText: "Texto de corpo pré-estilizado"
        case .footnoteText: "Texto de nota de rodapé pré-estilizado"
        case .currencyTextField: "Campo de entrada para valores monetários"
        case .navigationView: "Container de navegação com rotas tipadas"
        case .browserView: "Navegador web em sheet modal"
        case .videoView: "Player de vídeo com Picture in Picture"
        }
    }
}

#Preview {
    PrismNavigationView(router: .init()) { (_: PlaygroundRoute) in
        EmptyView()
    } content: {
        MoleculesListView()
    }
    .prism(theme: PrismPlaygroundTheme())
}
