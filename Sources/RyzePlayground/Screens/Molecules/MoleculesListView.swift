//
//  MoleculesListView.swift
//  RyzePlayground
//
//  Created by Rafael Escaleira on 11/04/26.
//

import RyzeUI
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
        RyzeLazyList {
            RyzeVStack(alignment: .leading, spacing: .medium) {
                ForEach(molecules, id: \.self) { molecule in
                    MoleculeRow(molecule: molecule)
                }
            }
            .ryzePadding()
            .ryzeBackgroundSecondary()
            .ryze(clip: .rounded(radius: 20))

            intelligenceSection
        }
        .navigationTitle("Molecules")
    }

    private var intelligenceSection: some View {
        RyzeVStack(alignment: .leading, spacing: .medium) {
            RyzeHStack(spacing: .small) {
                RyzeSymbol("brain.headset", mode: .hierarchical)
                    .ryze(color: .primary)

                RyzeText("Sobre Molecules")
                    .ryze(font: .headline)
            }

            RyzeBodyText(
                "Molecules são componentes compostos que combinam Atoms para criar funcionalidades mais complexas e específicas. Eles representam padrões de UI reutilizáveis."
            )

            RyzeTag("10 componentes", style: .info, size: .small)
        }
        .ryzePadding()
        .ryzeBackgroundSecondary()
        .ryze(clip: .rounded(radius: 20))
    }
}

private struct MoleculeRow: View {
    @Environment(\.theme) private var theme
    let molecule: PlaygroundMolecule

    var body: some View {
        RyzeHStack(spacing: .medium) {
            RyzeSymbol(molecule.icon, mode: .hierarchical)
                .ryze(font: .title2)
                .ryze(color: RyzeColor(rawValue: molecule.color))

            RyzeVStack(alignment: .leading, spacing: .small) {
                RyzeText(molecule.title)
                    .ryze(font: .body)
                RyzeFootnoteText(molecule.description)
                    .lineLimit(1)
            }

            RyzeSpacer()

            RyzeSymbol("chevron.right")
                .ryze(color: .textSecondary)
        }
        .ryzePadding()
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
        case .tag: "RyzeTag"
        case .carousel: "RyzeCarousel"
        case .primaryButton: "RyzePrimaryButton"
        case .secondaryButton: "RyzeSecondaryButton"
        case .bodyText: "RyzeBodyText"
        case .footnoteText: "RyzeFootnoteText"
        case .currencyTextField: "RyzeCurrencyTextField"
        case .navigationView: "RyzeNavigationView"
        case .browserView: "RyzeBrowserView"
        case .videoView: "RyzeVideoView"
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
    RyzeNavigationView(router: .init()) { (_: PlaygroundRoute) in
        EmptyView()
    } content: {
        MoleculesListView()
    }
    .ryze(theme: RyzePlaygroundTheme())
}
