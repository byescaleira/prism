//
//  LabelDemoView.swift
//  RyzePlayground
//
//  Created by Rafael Escaleira on 11/04/26.
//

import RyzeUI
import SwiftUI

struct LabelDemoView: View {
    @Environment(\.theme) private var theme
    @State private var isLoading = true

    var body: some View {
        RyzeLazyList {
            // Basic Labels
            RyzeSection {
                RyzeVStack(alignment: .leading, spacing: .medium) {
                    RyzeLabel("Início", symbol: "house")
                    RyzeLabel("Configurações", symbol: "gear")
                    RyzeLabel("Perfil", symbol: "person.circle")
                    RyzeLabel("Notificações", symbol: "bell")
                    RyzeLabel("Mensagens", symbol: "message")
                }
                .ryzePadding()
            } header: {
                RyzeText("Labels Básicos")
                    .ryze(font: .footnote)
                    .ryze(color: .textSecondary)
            }

            // Loading State
            RyzeSection {
                RyzeVStack(alignment: .leading, spacing: .medium) {
                    RyzeHStack {
                        RyzeLabel("Carregando...", symbol: "arrow.clockwise")
                            .ryze(loading: isLoading)

                        RyzeSpacer()

                        RyzeButton(isLoading ? "Carregar" : "Carregado", testID: "loading_toggle") {
                            isLoading.toggle()
                        }
                    }

                    RyzeLabel("Status", symbol: "checkmark.circle")
                        .ryze(loading: isLoading)
                }
                .ryzePadding()
            } header: {
                RyzeText("Estado de Loading")
                    .ryze(font: .footnote)
                    .ryze(color: .textSecondary)
            }

            // In Lists
            RyzeSection {
                RyzeVStack(spacing: .zero) {
                    ForEach(sampleMenuItems, id: \.symbol) { item in
                        RyzeHStack {
                            RyzeLabel(item.title, symbol: item.symbol)
                            RyzeSpacer()
                            RyzeSymbol("chevron.right")
                                .ryze(color: .textSecondary)
                        }
                        .ryzePadding()
                        .ryzeBackgroundRow()

                        if item.id != sampleMenuItems.last?.id {
                            Divider()
                                .padding(.leading, 50)
                        }
                    }
                }
                .ryzeBackgroundSecondary()
                .ryze(clip: .rounded(radius: 12))
            } header: {
                RyzeText("Em Listas")
                    .ryze(font: .footnote)
                    .ryze(color: .textSecondary)
            }

            // With Different Symbols
            RyzeSection {
                LazyVGrid(
                    columns: [
                        GridItem(.adaptive(minimum: 120), spacing: theme.spacing.small),
                    ],
                    spacing: theme.spacing.small
                ) {
                    ForEach(actionSymbols, id: \.self) { symbol in
                        RyzeLabel(symbol, symbol: symbol)
                            .ryze(font: .footnote)
                    }
                }
                .ryzePadding()
            } header: {
                RyzeText("Variedade de Símbolos")
                    .ryze(font: .footnote)
                    .ryze(color: .textSecondary)
            }

            // Intelligence
            RyzeVStack(alignment: .leading, spacing: .medium) {
                RyzeHStack(spacing: .small) {
                    RyzeSymbol("brain.headset", mode: .hierarchical)
                        .ryze(color: .primary)

                    RyzeText("Intelligence")
                        .ryze(font: .headline)
                }

                RyzeBodyText(
                    "RyzeLabel combina ícone e texto em um único componente. Ideal para menus, navegação e lists. Suporta estado de loading com skeleton automático."
                )

                RyzeTag("SF Symbols", style: .info, size: .small)
                RyzeTag("Loading", style: .info, size: .small)
            }
            .ryzePadding()
            .ryzeBackgroundSecondary()
            .ryze(clip: .rounded(radius: 20))
        }
        .navigationTitle("Label")
    }

    private let sampleMenuItems = [
        (id: 1, title: "Dashboard", symbol: "gauge"),
        (id: 2, title: "Relatórios", symbol: "doc.chart"),
        (id: 3, title: "Usuários", symbol: "person.2"),
        (id: 4, title: "Ajustes", symbol: "gearshape"),
        (id: 5, title: "Ajuda", symbol: "questionmark.circle"),
    ]

    private let actionSymbols = [
        "star", "heart", "bookmark", "flag",
        "bell", "gear", "lock", "shield",
        "cloud", "download", "upload", "share",
    ]
}

#Preview {
    RyzeNavigationView(router: .init()) { (_: PlaygroundRoute) in
        EmptyView()
    } content: {
        LabelDemoView()
    }
    .ryze(theme: RyzePlaygroundTheme())
}
