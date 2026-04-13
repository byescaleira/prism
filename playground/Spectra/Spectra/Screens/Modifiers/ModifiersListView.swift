//
//  ModifiersListView.swift
//  PrismPlayground
//
//  Created by Rafael Escaleira on 11/04/26.
//

import PrismUI
import PrismArchitecture
import SwiftUI

struct ModifiersListView: View {
    @Environment(\.theme) private var theme

    private let modifiers: [PlaygroundModifier] = [
        .glow,
        .skeleton,
        .confetti,
        .parallax,
        .background,
        .backgroundSecondary,
        .backgroundRow,
        .size,
        .spacing,
        .screenObserve,
        .accessibility,
        .symbolEffect,
    ]

    var body: some View {
        PrismLazyList {
            PrismVStack(alignment: .leading, spacing: .medium) {
                ForEach(modifiers, id: \.self) { modifier in
                    ModifierRow(modifier: modifier)
                }
            }
            .prismPadding()
            .prismBackgroundSecondary()
            .prism(clip: .rounded(radius: 20))

            intelligenceSection
        }
        .navigationTitle("Modifiers")
    }

    private var intelligenceSection: some View {
        PrismVStack(alignment: .leading, spacing: .medium) {
            PrismHStack(spacing: .small) {
                PrismSymbol("brain.headset", mode: .hierarchical)
                    .prism(color: .primary)

                PrismText("Sobre Modifiers")
                    .prism(font: .headline)
            }

            PrismBodyText(
                "Modifiers são transformadores que aplicam efeitos, animações, comportamentos e estilizações às views. Eles seguem o padrão de composição do SwiftUI."
            )

            PrismTag("12 modifiers", style: .info, size: .small)
        }
        .prismPadding()
        .prismBackgroundSecondary()
        .prism(clip: .rounded(radius: 20))
    }
}

private struct ModifierRow: View {
    @Environment(\.theme) private var theme
    let modifier: PlaygroundModifier

    var body: some View {
        PrismHStack(spacing: .medium) {
            PrismSymbol(modifier.icon, mode: .hierarchical)
                .prism(font: .title2)
                .prism(color: PrismColor(rawValue: modifier.color))

            PrismVStack(alignment: .leading, spacing: .small) {
                PrismText(modifier.title)
                    .prism(font: .body)
                PrismFootnoteText(modifier.description)
                    .lineLimit(1)
            }

            PrismSpacer()

            PrismSymbol("chevron.right")
                .prism(color: .textSecondary)
        }
        .prismPadding()
    }
}

// MARK: - Playground Modifier Model

enum PlaygroundModifier: Hashable, CaseIterable {
    case glow
    case skeleton
    case confetti
    case parallax
    case background
    case backgroundSecondary
    case backgroundRow
    case size
    case spacing
    case screenObserve
    case accessibility
    case symbolEffect

    var title: String {
        switch self {
        case .glow: "prismGlow"
        case .skeleton: "prismSkeleton"
        case .confetti: "prismConfetti"
        case .parallax: "prismParallax"
        case .background: "prismBackground"
        case .backgroundSecondary: "prismBackgroundSecondary"
        case .backgroundRow: "prismBackgroundRow"
        case .size: "prism(width:height:)"
        case .spacing: "prismPadding"
        case .screenObserve: "prismScreenObserve"
        case .accessibility: "prism(accessibility:)"
        case .symbolEffect: "prismSymbol"
        }
    }

    var icon: String {
        switch self {
        case .glow: "light.beacon.max.fill"
        case .skeleton: "rectangle.dashed"
        case .confetti: "party.popper.fill"
        case .parallax: "box.trianglebadge.arrow.up.and.arrow.down"
        case .background: "square.fill"
        case .backgroundSecondary: "square.2.layers.3d"
        case .backgroundRow: "list.and.film"
        case .size: "arrow.up.left.and.arrow.down.right"
        case .spacing: "arrow.left.and.right"
        case .screenObserve: "eye"
        case .accessibility: "accessibility"
        case .symbolEffect: "sparkles"
        }
    }

    var color: Color {
        switch self {
        case .glow: .init(red: 1.0, green: 0.6, blue: 0.0)
        case .skeleton: .init(red: 0.6, green: 0.6, blue: 0.6)
        case .confetti: .init(red: 0.9, green: 0.3, blue: 0.5)
        case .parallax: .init(red: 0.6, green: 0.3, blue: 0.8)
        case .background: .init(red: 0.2, green: 0.4, blue: 0.9)
        case .backgroundSecondary: .init(red: 0.3, green: 0.5, blue: 0.9)
        case .backgroundRow: .init(red: 0.4, green: 0.6, blue: 0.9)
        case .size: .init(red: 0.1, green: 0.7, blue: 0.4)
        case .spacing: .init(red: 0.2, green: 0.6, blue: 0.5)
        case .screenObserve: .init(red: 0.5, green: 0.3, blue: 0.9)
        case .accessibility: .init(red: 0.0, green: 0.5, blue: 0.9)
        case .symbolEffect: .init(red: 0.8, green: 0.4, blue: 0.1)
        }
    }

    var description: String {
        switch self {
        case .glow: "Efeito de brilho animado com gradiente"
        case .skeleton: "Estado de loading com placeholder"
        case .confetti: "Chuva de partículas para celebrações"
        case .parallax: "Efeito 3D baseado no movimento do dispositivo"
        case .background: "Background padrão do tema"
        case .backgroundSecondary: "Background secundário do tema"
        case .backgroundRow: "Background adaptativo para rows"
        case .size: "Dimensões semânticas com tokens"
        case .spacing: "Padding com tokens de spacing"
        case .screenObserve: "Observa tamanho da tela e scroll"
        case .accessibility: "Aplica propriedades de acessibilidade"
        case .symbolEffect: "Efeitos animados de símbolo"
        }
    }
}

#Preview {
    PrismNavigationView(router: .init()) { (_: PlaygroundRoute) in
        EmptyView()
    } content: {
        ModifiersListView()
    }
    .prism(theme: PrismPlaygroundTheme())
}
