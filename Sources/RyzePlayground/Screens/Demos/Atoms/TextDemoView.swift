//
//  TextDemoView.swift
//  RyzePlayground
//
//  Created by Rafael Escaleira on 11/04/26.
//

import RyzeUI
import SwiftUI

struct TextDemoView: View {
    @Environment(\.theme) private var theme
    @State private var isLoading = true

    var body: some View {
        RyzeLazyList {
            // RyzeText Variants
            RyzeSection {
                RyzeVStack(alignment: .leading, spacing: .small) {
                    RyzeText("Title Large")
                        .ryze(font: .system(size: 34, weight: .regular))

                    RyzeText("Title")
                        .ryze(font: .title)

                    RyzeText("Headline")
                        .ryze(font: .headline)

                    RyzeText("Body")
                        .ryze(font: .body)

                    RyzeText("Callout")
                        .ryze(font: .callout)

                    RyzeText("Footnote")
                        .ryze(font: .footnote)

                    RyzeText("Caption")
                        .ryze(font: .caption)

                    RyzeText("Caption 2")
                        .ryze(font: .caption2)
                }
                .ryzePadding()
            } header: {
                RyzeText("RyzeText")
                    .ryze(font: .footnote)
                    .ryze(color: .textSecondary)
            }

            // RyzeBodyText
            RyzeSection {
                RyzeVStack(alignment: .leading, spacing: .small) {
                    RyzeBodyText(
                        "Este é um componente de texto de corpo pré-estilizado. Ele usa automaticamente a fonte body e a cor de texto primária do tema."
                    )
                }
                .ryzePadding()
            } header: {
                RyzeText("RyzeBodyText")
                    .ryze(font: .footnote)
                    .ryze(color: .textSecondary)
            }

            // RyzeFootnoteText
            RyzeSection {
                RyzeVStack(alignment: .leading, spacing: .small) {
                    RyzeFootnoteText(
                        "Texto secundário ideal para legendas, descrições auxiliares e metadados. Usa automaticamente footnote font e textSecondary color."
                    )
                }
                .ryzePadding()
            } header: {
                RyzeText("RyzeFootnoteText")
                    .ryze(font: .footnote)
                    .ryze(color: .textSecondary)
            }

            // Loading State
            RyzeSection {
                RyzeVStack(alignment: .leading, spacing: .medium) {
                    RyzeHStack {
                        RyzeText("Carregando...")
                            .ryze(loading: isLoading)

                        RyzeSpacer()

                        RyzeButton(isLoading ? "Ocultar" : "Mostrar", testID: "toggle_loading_button") {
                            isLoading.toggle()
                        }
                    }

                    RyzeBodyText("Skeleton automático quando isLoading = true")
                        .ryze(loading: isLoading)

                    RyzeFootnoteText("Funciona com qualquer texto")
                        .ryze(loading: isLoading)
                }
                .ryzePadding()
            } header: {
                RyzeText("Loading State")
                    .ryze(font: .footnote)
                    .ryze(color: .textSecondary)
            }

            // Font Weights
            RyzeSection {
                RyzeVStack(alignment: .leading, spacing: .small) {
                    RyzeText("Ultra Light")
                        .ryze(font: .body, weight: .ultraLight)
                    RyzeText("Thin")
                        .ryze(font: .body, weight: .thin)
                    RyzeText("Light")
                        .ryze(font: .body, weight: .light)
                    RyzeText("Regular")
                        .ryze(font: .body, weight: .regular)
                    RyzeText("Medium")
                        .ryze(font: .body, weight: .medium)
                    RyzeText("Semibold")
                        .ryze(font: .body, weight: .semibold)
                    RyzeText("Bold")
                        .ryze(font: .body, weight: .bold)
                    RyzeText("Heavy")
                        .ryze(font: .body, weight: .heavy)
                    RyzeText("Black")
                        .ryze(font: .body, weight: .black)
                }
                .ryzePadding()
            } header: {
                RyzeText("Font Weights")
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
                    "O sistema de tipografia do RyzeUI é baseado em tokens semânticos. Use RyzeBodyText e RyzeFootnoteText para consistência. O estado de loading exibe skeleton automaticamente."
                )
            }
            .ryzePadding()
            .ryzeBackgroundSecondary()
            .ryze(clip: .rounded(radius: 20))
        }
        .navigationTitle("Text")
    }
}

#Preview {
    RyzeNavigationView(router: .init()) { (_: PlaygroundRoute) in
        EmptyView()
    } content: {
        TextDemoView()
    }
    .ryze(theme: RyzePlaygroundTheme())
}
