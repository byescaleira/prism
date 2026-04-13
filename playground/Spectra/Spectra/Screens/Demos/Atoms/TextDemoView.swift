//
//  TextDemoView.swift
//  PrismPlayground
//
//  Created by Rafael Escaleira on 11/04/26.
//

import PrismUI
import SwiftUI
import PrismArchitecture

struct TextDemoView: View {
    @Environment(\.theme) private var theme
    @State private var isLoading = true

    var body: some View {
        PrismLazyList {
            // PrismText Variants
            PrismSection {
                PrismVStack(alignment: .leading, spacing: .small) {
                    PrismText("Title Large")
                        .prism(font: .system(size: 34, weight: .regular))

                    PrismText("Title")
                        .prism(font: .title)

                    PrismText("Headline")
                        .prism(font: .headline)

                    PrismText("Body")
                        .prism(font: .body)

                    PrismText("Callout")
                        .prism(font: .callout)

                    PrismText("Footnote")
                        .prism(font: .footnote)

                    PrismText("Caption")
                        .prism(font: .caption)

                    PrismText("Caption 2")
                        .prism(font: .caption2)
                }
                .prismPadding()
            } header: {
                PrismText("PrismText")
                    .prism(font: .footnote)
                    .prism(color: .textSecondary)
            }

            // PrismBodyText
            PrismSection {
                PrismVStack(alignment: .leading, spacing: .small) {
                    PrismBodyText(
                        "Este é um componente de texto de corpo pré-estilizado. Ele usa automaticamente a fonte body e a cor de texto primária do tema."
                    )
                }
                .prismPadding()
            } header: {
                PrismText("PrismBodyText")
                    .prism(font: .footnote)
                    .prism(color: .textSecondary)
            }

            // PrismFootnoteText
            PrismSection {
                PrismVStack(alignment: .leading, spacing: .small) {
                    PrismFootnoteText(
                        "Texto secundário ideal para legendas, descrições auxiliares e metadados. Usa automaticamente footnote font e textSecondary color."
                    )
                }
                .prismPadding()
            } header: {
                PrismText("PrismFootnoteText")
                    .prism(font: .footnote)
                    .prism(color: .textSecondary)
            }

            // Loading State
            PrismSection {
                PrismVStack(alignment: .leading, spacing: .medium) {
                    PrismHStack {
                        PrismText("Carregando...")
                            .prism(loading: isLoading)

                        PrismSpacer()

                        PrismButton(isLoading ? "Ocultar" : "Mostrar", testID: "toggle_loading_button") {
                            isLoading.toggle()
                        }
                    }

                    PrismBodyText("Skeleton automático quando isLoading = true")
                        .prism(loading: isLoading)

                    PrismFootnoteText("Funciona com qualquer texto")
                        .prism(loading: isLoading)
                }
                .prismPadding()
            } header: {
                PrismText("Loading State")
                    .prism(font: .footnote)
                    .prism(color: .textSecondary)
            }

            // Font Weights
            PrismSection {
                PrismVStack(alignment: .leading, spacing: .small) {
                    PrismText("Ultra Light")
                        .prism(font: .body, weight: .ultraLight)
                    PrismText("Thin")
                        .prism(font: .body, weight: .thin)
                    PrismText("Light")
                        .prism(font: .body, weight: .light)
                    PrismText("Regular")
                        .prism(font: .body, weight: .regular)
                    PrismText("Medium")
                        .prism(font: .body, weight: .medium)
                    PrismText("Semibold")
                        .prism(font: .body, weight: .semibold)
                    PrismText("Bold")
                        .prism(font: .body, weight: .bold)
                    PrismText("Heavy")
                        .prism(font: .body, weight: .heavy)
                    PrismText("Black")
                        .prism(font: .body, weight: .black)
                }
                .prismPadding()
            } header: {
                PrismText("Font Weights")
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
                    "O sistema de tipografia do PrismUI é baseado em tokens semânticos. Use PrismBodyText e PrismFootnoteText para consistência. O estado de loading exibe skeleton automaticamente."
                )
            }
            .prismPadding()
            .prismBackgroundSecondary()
            .prism(clip: .rounded(radius: 20))
        }
        .navigationTitle("Text")
    }
}

#Preview {
    PrismNavigationView(router: .init()) { (_: PlaygroundRoute) in
        EmptyView()
    } content: {
        TextDemoView()
    }
    .prism(theme: PrismPlaygroundTheme())
}
