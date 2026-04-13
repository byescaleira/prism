//
//  PatternsListView.swift
//  RyzePlayground
//
//  Created by Rafael Escaleira on 11/04/26.
//

import RyzeUI
import SwiftUI

struct PatternsListView: View {
    @Environment(\.theme) private var theme

    private let patterns: [PlaygroundPattern] = [
        .formPattern,
        .cardPattern,
        .listDetailPattern,
        .dashboardPattern,
        .onboardingPattern,
        .settingsPattern,
        .feedPattern,
        .profilePattern,
    ]

    var body: some View {
        RyzeLazyList {
            RyzeVStack(alignment: .leading, spacing: .medium) {
                ForEach(patterns, id: \.self) { pattern in
                    PatternRow(pattern: pattern)
                }
            }
            .ryzePadding()
            .ryzeBackgroundSecondary()
            .ryze(clip: .rounded(radius: 20))

            intelligenceSection
        }
        .navigationTitle("Patterns")
    }

    private var intelligenceSection: some View {
        RyzeVStack(alignment: .leading, spacing: .medium) {
            RyzeHStack(spacing: .small) {
                RyzeSymbol("brain.headset", mode: .hierarchical)
                    .ryze(color: .primary)

                RyzeText("Sobre Patterns")
                    .ryze(font: .headline)
            }

            RyzeBodyText(
                "Patterns são soluções reutilizáveis para problemas comuns de UI. Eles combinam Atoms e Molecules em arranjos padronizados que resolvem necessidades específicas."
            )

            RyzeTag("8 patterns", style: .info, size: .small)
        }
        .ryzePadding()
        .ryzeBackgroundSecondary()
        .ryze(clip: .rounded(radius: 20))
    }
}

private struct PatternRow: View {
    @Environment(\.theme) private var theme
    let pattern: PlaygroundPattern

    var body: some View {
        RyzeHStack(spacing: .medium) {
            RyzeSymbol(pattern.icon, mode: .hierarchical)
                .ryze(font: .title2)
                .ryze(color: RyzeColor(rawValue: pattern.color))

            RyzeVStack(alignment: .leading, spacing: .small) {
                RyzeText(pattern.title)
                    .ryze(font: .body)
                RyzeFootnoteText(pattern.description)
                    .lineLimit(1)
            }

            RyzeSpacer()

            RyzeSymbol("chevron.right")
                .ryze(color: .textSecondary)
        }
        .ryzePadding()
    }
}

// MARK: - Playground Pattern Model

enum PlaygroundPattern: Hashable, CaseIterable {
    case formPattern
    case cardPattern
    case listDetailPattern
    case dashboardPattern
    case onboardingPattern
    case settingsPattern
    case feedPattern
    case profilePattern

    var title: String {
        switch self {
        case .formPattern: "Formulário"
        case .cardPattern: "Card"
        case .listDetailPattern: "List-Detail"
        case .dashboardPattern: "Dashboard"
        case .onboardingPattern: "Onboarding"
        case .settingsPattern: "Settings"
        case .feedPattern: "Feed"
        case .profilePattern: "Profile"
        }
    }

    var icon: String {
        switch self {
        case .formPattern: "textformat.abc"
        case .cardPattern: "square.split.2x2"
        case .listDetailPattern: "list.bullet.indent"
        case .dashboardPattern: "gauge"
        case .onboardingPattern: "flag.checkered"
        case .settingsPattern: "gearshape.fill"
        case .feedPattern: "newspaper"
        case .profilePattern: "person.crop.circle"
        }
    }

    var color: Color {
        switch self {
        case .formPattern: .init(red: 0.2, green: 0.4, blue: 0.9)
        case .cardPattern: .init(red: 0.6, green: 0.3, blue: 0.8)
        case .listDetailPattern: .init(red: 0.1, green: 0.7, blue: 0.4)
        case .dashboardPattern: .init(red: 0.9, green: 0.3, blue: 0.5)
        case .onboardingPattern: .init(red: 1.0, green: 0.6, blue: 0.0)
        case .settingsPattern: .init(red: 0.5, green: 0.5, blue: 0.5)
        case .feedPattern: .init(red: 0.0, green: 0.5, blue: 0.9)
        case .profilePattern: .init(red: 0.8, green: 0.4, blue: 0.1)
        }
    }

    var description: String {
        switch self {
        case .formPattern: "Padrão de formulário com validação"
        case .cardPattern: "Card com conteúdo e ações"
        case .listDetailPattern: "Navegação mestre-detalhe"
        case .dashboardPattern: "Dashboard com métricas e gráficos"
        case .onboardingPattern: "Fluxo de onboarding passo-a-passo"
        case .settingsPattern: "Tela de configurações e ajustes"
        case .feedPattern: "Feed de conteúdo scrollável"
        case .profilePattern: "Perfil de usuário com informações"
        }
    }
}

#Preview {
    RyzeNavigationView(router: .init()) { (_: PlaygroundRoute) in
        EmptyView()
    } content: {
        PatternsListView()
    }
    .ryze(theme: RyzePlaygroundTheme())
}
