//
//  LabelDemoView.swift
//  PrismPlayground
//
//  Created by Rafael Escaleira on 11/04/26.
//

import PrismUI
import SwiftUI
import PrismArchitecture

struct LabelDemoView: View {
    @Environment(\.theme) private var theme
    @State private var isLoading = true

    var body: some View {
        PrismLazyList {
            // Basic Labels
            PrismSection {
                PrismVStack(alignment: .leading, spacing: .medium) {
                    PrismLabel("Início", symbol: "house")
                    PrismLabel("Configurações", symbol: "gear")
                    PrismLabel("Perfil", symbol: "person.circle")
                    PrismLabel("Notificações", symbol: "bell")
                    PrismLabel("Mensagens", symbol: "message")
                }
                .prismPadding()
            } header: {
                PrismText("Labels Básicos")
                    .prism(font: .footnote)
                    .prism(color: .textSecondary)
            }

            // Loading State
            PrismSection {
                PrismVStack(alignment: .leading, spacing: .medium) {
                    PrismHStack {
                        PrismLabel("Carregando...", symbol: "arrow.clockwise")
                            .prism(loading: isLoading)

                        PrismSpacer()

                        PrismButton(isLoading ? "Carregar" : "Carregado", testID: "loading_toggle") {
                            isLoading.toggle()
                        }
                    }

                    PrismLabel("Status", symbol: "checkmark.circle")
                        .prism(loading: isLoading)
                }
                .prismPadding()
            } header: {
                PrismText("Estado de Loading")
                    .prism(font: .footnote)
                    .prism(color: .textSecondary)
            }

            // In Lists
            PrismSection {
                PrismVStack(spacing: .zero) {
                    ForEach(sampleMenuItems, id: \.symbol) { item in
                        PrismHStack {
                            PrismLabel(item.title, symbol: item.symbol)
                            PrismSpacer()
                            PrismSymbol("chevron.right")
                                .prism(color: .textSecondary)
                        }
                        .prismPadding()
                        .prismBackgroundRow()

                        if item.id != sampleMenuItems.last?.id {
                            Divider()
                                .padding(.leading, 50)
                        }
                    }
                }
                .prismBackgroundSecondary()
                .prism(clip: .rounded(radius: 12))
            } header: {
                PrismText("Em Listas")
                    .prism(font: .footnote)
                    .prism(color: .textSecondary)
            }

            // With Different Symbols
            PrismSection {
                LazyVGrid(
                    columns: [
                        GridItem(.adaptive(minimum: 120), spacing: theme.spacing.small),
                    ],
                    spacing: theme.spacing.small
                ) {
                    ForEach(actionSymbols, id: \.self) { symbol in
                        PrismLabel(symbol, symbol: symbol)
                            .prism(font: .footnote)
                    }
                }
                .prismPadding()
            } header: {
                PrismText("Variedade de Símbolos")
                    .prism(font: .footnote)
                    .prism(color: .textSecondary)
            }

            // Intelligence
            PrismVStack(alignment: .leading, spacing: .medium) {
                PrismHStack(spacing: .small) {
                    PrismSymbol("brain.headset", mode: .hierarchical)
                        .prism(color: .primary)

                    PrismText("Intelligence")
                        .prism(font: .headline)
                }

                PrismBodyText(
                    "PrismLabel combina ícone e texto em um único componente. Ideal para menus, navegação e lists. Suporta estado de loading com skeleton automático."
                )

                PrismTag("SF Symbols", style: .info, size: .small)
                PrismTag("Loading", style: .info, size: .small)
            }
            .prismPadding()
            .prismBackgroundSecondary()
            .prism(clip: .rounded(radius: 20))
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
    PrismNavigationView(router: .init()) { (_: PlaygroundRoute) in
        EmptyView()
    } content: {
        LabelDemoView()
    }
    .prism(theme: PrismPlaygroundTheme())
}
