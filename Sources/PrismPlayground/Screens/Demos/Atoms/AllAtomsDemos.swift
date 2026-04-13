//
//  AllAtomsDemos.swift
//  PrismPlayground
//
//  Created by Rafael Escaleira on 11/04/26.
//

import PrismFoundation
import PrismUI
import SwiftUI

private struct CustomString: PrismResourceString {
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
        PrismList {
            PrismSection {
                PrismHStack {
                    PrismLabel("Configurações", symbol: "gear")
                    PrismSpacer()
                    PrismSymbol("chevron.right")
                        .prism(color: .textSecondary)
                }

                PrismHStack {
                    PrismLabel("Perfil", symbol: "person")
                    PrismSpacer()
                    PrismSymbol("chevron.right")
                        .prism(color: .textSecondary)
                }
            } header: {
                PrismText("Primeira Seção")
                    .prism(font: .footnote)
                    .prism(color: .textSecondary)
            }

            PrismSection(
                header: CustomString("Segunda Seção"),
                footer: CustomString("Rodapé da seção")
            ) {
                PrismHStack {
                    PrismLabel("Notificações", symbol: "bell")
                    PrismSpacer()
                    PrismTag("Novo", style: .info, size: .small)
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
        PrismLazyList {
            PrismSection {
                PrismBodyText("Conteúdo da seção")
            } header: {
                PrismText("Seção com Header")
                    .prism(font: .footnote)
                    .prism(color: .textSecondary)
            }

            PrismSection {
                PrismBodyText("Seção sem header/footer")
            }

            PrismSection {
                PrismBodyText("Conteúdo")
            } header: {
                PrismText("Apenas Header")
                    .prism(font: .footnote)
                    .prism(color: .textSecondary)
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
        PrismTabView(
            selection: $selectedTab,
            searchText: .constant("")
        ) {
            PrismLazyList {
                PrismSection {
                    PrismBodyText("Conteúdo da home")
                } header: {
                    PrismText("Home")
                        .prism(font: .footnote)
                        .prism(color: .textSecondary)
                }
            }
            .tabItem {
                PrismLabel("Home", symbol: "house")
            }
            .tag(0)

            PrismLazyList {
                PrismSection {
                    PrismBodyText("Conteúdo de busca")
                } header: {
                    PrismText("Busca")
                        .prism(font: .footnote)
                        .prism(color: .textSecondary)
                }
            }
            .tabItem {
                PrismLabel("Busca", symbol: "magnifyingglass")
            }
            .tag(1)

            PrismLazyList {
                PrismSection {
                    PrismBodyText("Conteúdo do perfil")
                } header: {
                    PrismText("Perfil")
                        .prism(font: .footnote)
                        .prism(color: .textSecondary)
                }
            }
            .tabItem {
                PrismLabel("Perfil", symbol: "person")
            }
            .tag(2)
        }
        .navigationTitle("TabView")
    }
}

// MARK: - Preview Stubs

struct PrimaryButtonDemoView: View {
    var body: some View {
        PrismLazyList {
            PrismSection {
                PrismVStack(spacing: .medium) {
                    PrismPrimaryButton("Ação Principal") {}
                    PrismPrimaryButton("Destrutivo", role: .destructive) {}
                    PrismPrimaryButton("Cancelar", role: .cancel) {}
                }
                .prismPadding()
            } header: {
                PrismText("PrismPrimaryButton")
                    .prism(font: .footnote)
                    .prism(color: .textSecondary)
            }
        }
        .navigationTitle("Primary Button")
    }
}

struct SecondaryButtonDemoView: View {
    var body: some View {
        PrismLazyList {
            PrismSection {
                PrismVStack(spacing: .medium) {
                    PrismSecondaryButton("Ação Secundária") {}
                    PrismSecondaryButton("Destrutivo", role: .destructive) {}
                    PrismSecondaryButton("Cancelar", role: .cancel) {}
                }
                .prismPadding()
            } header: {
                PrismText("PrismSecondaryButton")
                    .prism(font: .footnote)
                    .prism(color: .textSecondary)
            }
        }
        .navigationTitle("Secondary Button")
    }
}

struct BodyTextDemoView: View {
    var body: some View {
        PrismLazyList {
            PrismSection {
                PrismVStack(alignment: .leading, spacing: .medium) {
                    PrismBodyText("Texto de corpo padrão do Design System. Usa automaticamente a fonte body e cor de texto primária.")
                    PrismBodyText("Texto customizado")
                }
                .prismPadding()
            } header: {
                PrismText("PrismBodyText")
                    .prism(font: .footnote)
                    .prism(color: .textSecondary)
            }
        }
        .navigationTitle("Body Text")
    }
}

struct FootnoteTextDemoView: View {
    var body: some View {
        PrismLazyList {
            PrismSection {
                PrismVStack(alignment: .leading, spacing: .medium) {
                    PrismFootnoteText("Texto de nota de rodapé. Ideal para legendas e metadados.")
                    PrismFootnoteText("Customizado")
                }
                .prismPadding()
            } header: {
                PrismText("PrismFootnoteText")
                    .prism(font: .footnote)
                    .prism(color: .textSecondary)
            }
        }
        .navigationTitle("Footnote Text")
    }
}

struct CurrencyTextFieldDemoView: View {
    @State private var amount: Double = 0.0

    var body: some View {
        PrismLazyList {
            PrismSection {
                PrismVStack(spacing: .medium) {
                    PrismCurrencyTextField(
                        amount: $amount,
                        locale: .portugueseBR
                    )
                    PrismFootnoteText(String(format: "Valor: R$ %.2f", amount))
                }
                .prismPadding()
            } header: {
                PrismText("PrismCurrencyTextField")
                    .prism(font: .footnote)
                    .prism(color: .textSecondary)
            }
        }
        .navigationTitle("Currency TextField")
    }
}

struct BackgroundDemoView: View {
    @Environment(\.theme) private var theme

    var body: some View {
        PrismLazyList {
            PrismSection {
                PrismVStack(spacing: .medium) {
                    PrismHStack {
                        PrismText("Background")
                        PrismSpacer()
                        PrismShape.rounded(radius: 6)
                            .prism(background: PrismColor.background)
                            .frame(width: 40, height: 40)
                    }
                    .prismPadding()
                    .prismBackground()

                    PrismHStack {
                        PrismText("Background Secondary")
                        PrismSpacer()
                        PrismShape.rounded(radius: 6)
                            .prism(background: PrismColor.backgroundSecondary)
                            .frame(width: 40, height: 40)
                    }
                    .prismPadding()
                    .prismBackgroundSecondary()

                    PrismHStack {
                        PrismText("Background Row")
                        PrismSpacer()
                        PrismShape.rounded(radius: 6)
                            .prism(background: PrismColor.background)
                            .frame(width: 40, height: 40)
                    }
                    .prismPadding()
                    .prismBackgroundRow()
                }
            } header: {
                PrismText("Backgrounds")
                    .prism(font: .footnote)
                    .prism(color: .textSecondary)
            }
        }
        .navigationTitle("Backgrounds")
    }
}

#Preview {
    PrismNavigationView(router: .init()) { (_: PlaygroundRoute) in EmptyView() } content: {
        ListDemoView()
    }
    .prism(theme: PrismPlaygroundTheme())
}
