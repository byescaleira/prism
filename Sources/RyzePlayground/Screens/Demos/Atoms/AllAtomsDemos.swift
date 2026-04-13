//
//  AllAtomsDemos.swift
//  RyzePlayground
//
//  Created by Rafael Escaleira on 11/04/26.
//

import RyzeFoundation
import RyzeUI
import SwiftUI

private struct CustomString: RyzeResourceString {
    let value: String
    var localized: LocalizedStringKey { LocalizedStringKey(value) }

    init(_ value: String) {
        self.value = value
    }
}

// MARK: - List & Section Demo

struct ListDemoView: View {
    @Environment(\.theme) private var theme

    var body: some View {
        RyzeList {
            RyzeSection {
                RyzeHStack {
                    RyzeLabel("Configurações", symbol: "gear")
                    RyzeSpacer()
                    RyzeSymbol("chevron.right")
                        .ryze(color: .textSecondary)
                }

                RyzeHStack {
                    RyzeLabel("Perfil", symbol: "person")
                    RyzeSpacer()
                    RyzeSymbol("chevron.right")
                        .ryze(color: .textSecondary)
                }
            } header: {
                RyzeText("Primeira Seção")
                    .ryze(font: .footnote)
                    .ryze(color: .textSecondary)
            }

            RyzeSection(
                header: CustomString("Segunda Seção"),
                footer: CustomString("Rodapé da seção")
            ) {
                RyzeHStack {
                    RyzeLabel("Notificações", symbol: "bell")
                    RyzeSpacer()
                    RyzeTag("Novo", style: .info, size: .small)
                }
            }
        }
        .navigationTitle("List")
    }
}

// MARK: - Section Demo

struct SectionDemoView: View {
    @Environment(\.theme) private var theme

    var body: some View {
        RyzeLazyList {
            RyzeSection {
                RyzeBodyText("Conteúdo da seção")
            } header: {
                RyzeText("Seção com Header")
                    .ryze(font: .footnote)
                    .ryze(color: .textSecondary)
            }

            RyzeSection {
                RyzeBodyText("Seção sem header/footer")
            }

            RyzeSection {
                RyzeBodyText("Conteúdo")
            } header: {
                RyzeText("Apenas Header")
                    .ryze(font: .footnote)
                    .ryze(color: .textSecondary)
            }
        }
        .navigationTitle("Section")
    }
}

// MARK: - TabView Demo

struct TabViewDemoView: View {
    @Environment(\.theme) private var theme
    @State private var selectedTab = 0

    var body: some View {
        RyzeTabView(
            selection: $selectedTab,
            searchText: .constant("")
        ) {
            RyzeLazyList {
                RyzeSection {
                    RyzeBodyText("Conteúdo da home")
                } header: {
                    RyzeText("Home")
                        .ryze(font: .footnote)
                        .ryze(color: .textSecondary)
                }
            }
            .tabItem {
                RyzeLabel("Home", symbol: "house")
            }
            .tag(0)

            RyzeLazyList {
                RyzeSection {
                    RyzeBodyText("Conteúdo de busca")
                } header: {
                    RyzeText("Busca")
                        .ryze(font: .footnote)
                        .ryze(color: .textSecondary)
                }
            }
            .tabItem {
                RyzeLabel("Busca", symbol: "magnifyingglass")
            }
            .tag(1)

            RyzeLazyList {
                RyzeSection {
                    RyzeBodyText("Conteúdo do perfil")
                } header: {
                    RyzeText("Perfil")
                        .ryze(font: .footnote)
                        .ryze(color: .textSecondary)
                }
            }
            .tabItem {
                RyzeLabel("Perfil", symbol: "person")
            }
            .tag(2)
        }
        .navigationTitle("TabView")
    }
}

// MARK: - Preview Stubs

struct PrimaryButtonDemoView: View {
    var body: some View {
        RyzeLazyList {
            RyzeSection {
                RyzeVStack(spacing: .medium) {
                    RyzePrimaryButton("Ação Principal") {}
                    RyzePrimaryButton("Destrutivo", role: .destructive) {}
                    RyzePrimaryButton("Cancelar", role: .cancel) {}
                }
                .ryzePadding()
            } header: {
                RyzeText("RyzePrimaryButton")
                    .ryze(font: .footnote)
                    .ryze(color: .textSecondary)
            }
        }
        .navigationTitle("Primary Button")
    }
}

struct SecondaryButtonDemoView: View {
    var body: some View {
        RyzeLazyList {
            RyzeSection {
                RyzeVStack(spacing: .medium) {
                    RyzeSecondaryButton("Ação Secundária") {}
                    RyzeSecondaryButton("Destrutivo", role: .destructive) {}
                    RyzeSecondaryButton("Cancelar", role: .cancel) {}
                }
                .ryzePadding()
            } header: {
                RyzeText("RyzeSecondaryButton")
                    .ryze(font: .footnote)
                    .ryze(color: .textSecondary)
            }
        }
        .navigationTitle("Secondary Button")
    }
}

struct BodyTextDemoView: View {
    var body: some View {
        RyzeLazyList {
            RyzeSection {
                RyzeVStack(alignment: .leading, spacing: .medium) {
                    RyzeBodyText("Texto de corpo padrão do Design System. Usa automaticamente a fonte body e cor de texto primária.")
                    RyzeBodyText("Texto customizado")
                }
                .ryzePadding()
            } header: {
                RyzeText("RyzeBodyText")
                    .ryze(font: .footnote)
                    .ryze(color: .textSecondary)
            }
        }
        .navigationTitle("Body Text")
    }
}

struct FootnoteTextDemoView: View {
    var body: some View {
        RyzeLazyList {
            RyzeSection {
                RyzeVStack(alignment: .leading, spacing: .medium) {
                    RyzeFootnoteText("Texto de nota de rodapé. Ideal para legendas e metadados.")
                    RyzeFootnoteText("Customizado")
                }
                .ryzePadding()
            } header: {
                RyzeText("RyzeFootnoteText")
                    .ryze(font: .footnote)
                    .ryze(color: .textSecondary)
            }
        }
        .navigationTitle("Footnote Text")
    }
}

struct CurrencyTextFieldDemoView: View {
    @State private var amount: Double = 0.0

    var body: some View {
        RyzeLazyList {
            RyzeSection {
                RyzeVStack(spacing: .medium) {
                    RyzeCurrencyTextField(
                        amount: $amount,
                        locale: .portugueseBR
                    )
                    RyzeFootnoteText(String(format: "Valor: R$ %.2f", amount))
                }
                .ryzePadding()
            } header: {
                RyzeText("RyzeCurrencyTextField")
                    .ryze(font: .footnote)
                    .ryze(color: .textSecondary)
            }
        }
        .navigationTitle("Currency TextField")
    }
}

struct BackgroundDemoView: View {
    @Environment(\.theme) private var theme

    var body: some View {
        RyzeLazyList {
            RyzeSection {
                RyzeVStack(spacing: .medium) {
                    RyzeHStack {
                        RyzeText("Background")
                        RyzeSpacer()
                        RyzeShape.rounded(radius: 6)
                            .ryze(background: RyzeColor.background)
                            .frame(width: 40, height: 40)
                    }
                    .ryzePadding()
                    .ryzeBackground()

                    RyzeHStack {
                        RyzeText("Background Secondary")
                        RyzeSpacer()
                        RyzeShape.rounded(radius: 6)
                            .ryze(background: RyzeColor.backgroundSecondary)
                            .frame(width: 40, height: 40)
                    }
                    .ryzePadding()
                    .ryzeBackgroundSecondary()

                    RyzeHStack {
                        RyzeText("Background Row")
                        RyzeSpacer()
                        RyzeShape.rounded(radius: 6)
                            .ryze(background: RyzeColor.background)
                            .frame(width: 40, height: 40)
                    }
                    .ryzePadding()
                    .ryzeBackgroundRow()
                }
            } header: {
                RyzeText("Backgrounds")
                    .ryze(font: .footnote)
                    .ryze(color: .textSecondary)
            }
        }
        .navigationTitle("Backgrounds")
    }
}

#Preview {
    RyzeNavigationView(router: .init()) { (_: PlaygroundRoute) in EmptyView() } content: {
        ListDemoView()
    }
    .ryze(theme: RyzePlaygroundTheme())
}
