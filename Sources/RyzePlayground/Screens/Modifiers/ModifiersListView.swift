//
//  ModifiersListView.swift
//  RyzePlayground
//
//  Created by Rafael Escaleira on 11/04/26.
//

import RyzeUI
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
        RyzeLazyList {
            RyzeVStack(alignment: .leading, spacing: .medium) {
                ForEach(modifiers, id: \.self) { modifier in
                    ModifierRow(modifier: modifier)
                }
            }
            .ryzePadding()
            .ryzeBackgroundSecondary()
            .ryze(clip: .rounded(radius: 20))

            intelligenceSection
        }
        .navigationTitle("Modifiers")
    }

    private var intelligenceSection: some View {
        RyzeVStack(alignment: .leading, spacing: .medium) {
            RyzeHStack(spacing: .small) {
                RyzeSymbol("brain.headset", mode: .hierarchical)
                    .ryze(color: .primary)

                RyzeText("Sobre Modifiers")
                    .ryze(font: .headline)
            }

            RyzeBodyText(
                "Modifiers são transformadores que aplicam efeitos, animações, comportamentos e estilizações às views. Eles seguem o padrão de composição do SwiftUI."
            )

            RyzeTag("12 modifiers", style: .info, size: .small)
        }
        .ryzePadding()
        .ryzeBackgroundSecondary()
        .ryze(clip: .rounded(radius: 20))
    }
}

private struct ModifierRow: View {
    @Environment(\.theme) private var theme
    let modifier: PlaygroundModifier

    var body: some View {
        RyzeHStack(spacing: .medium) {
            RyzeSymbol(modifier.icon, mode: .hierarchical)
                .ryze(font: .title2)
                .ryze(color: RyzeColor(rawValue: modifier.color))

            RyzeVStack(alignment: .leading, spacing: .small) {
                RyzeText(modifier.title)
                    .ryze(font: .body)
                RyzeFootnoteText(modifier.description)
                    .lineLimit(1)
            }

            RyzeSpacer()

            RyzeSymbol("chevron.right")
                .ryze(color: .textSecondary)
        }
        .ryzePadding()
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
        case .glow: "ryzeGlow"
        case .skeleton: "ryzeSkeleton"
        case .confetti: "ryzeConfetti"
        case .parallax: "ryzeParallax"
        case .background: "ryzeBackground"
        case .backgroundSecondary: "ryzeBackgroundSecondary"
        case .backgroundRow: "ryzeBackgroundRow"
        case .size: "ryze(width:height:)"
        case .spacing: "ryzePadding"
        case .screenObserve: "ryzeScreenObserve"
        case .accessibility: "ryze(accessibility:)"
        case .symbolEffect: "ryzeSymbol"
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
    RyzeNavigationView(router: .init()) { (_: PlaygroundRoute) in
        EmptyView()
    } content: {
        ModifiersListView()
    }
    .ryze(theme: RyzePlaygroundTheme())
}
