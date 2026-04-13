//
//  TagDemoView.swift
//  PrismPlayground
//
//  Created by Rafael Escaleira on 11/04/26.
//

import PrismUI
import SwiftUI

struct TagDemoView: View {
    @Environment(\.theme) private var theme
    @State private var isTagPresented = true

    var body: some View {
        PrismLazyList {
            // All Styles
            PrismSection {
                PrismVStack(spacing: .medium) {
                    PrismHStack(spacing: .small) {
                        PrismTag("Filled", style: .filled)
                        PrismTag("Outlined", style: .outlined)
                        PrismTag("Ghost", style: .ghost)
                    }

                    PrismHStack(spacing: .small) {
                        PrismTag("Success", style: .success)
                        PrismTag("Error", style: .error)
                        PrismTag("Warning", style: .warning)
                        PrismTag("Info", style: .info)
                    }
                }
                .prismPadding()
            } header: {
                PrismText("Estilos Disponíveis")
                    .prism(font: .footnote)
                    .prism(color: .textSecondary)
            }

            // All Sizes
            PrismSection {
                PrismVStack(spacing: .medium) {
                    PrismHStack(spacing: .small) {
                        PrismTag("Small", size: .small)
                        PrismTag("Medium", size: .medium)
                        PrismTag("Large", size: .large)
                    }
                }
                .prismPadding()
            } header: {
                PrismText("Tamanhos")
                    .prism(font: .footnote)
                    .prism(color: .textSecondary)
            }

            // With Icons
            PrismSection {
                PrismHStack(spacing: .small) {
                    PrismTag("Swift", icon: "swift")
                    PrismTag("iOS", icon: "applelogo")
                    PrismTag("macOS", icon: "applelogo")
                    PrismTag("watchOS", icon: "applelogo")
                    PrismTag("tvOS", icon: "applelogo")
                    PrismTag("visionOS", icon: "applelogo")
                }
                .prismPadding()
            } header: {
                PrismText("Com Ícones")
                    .prism(font: .footnote)
                    .prism(color: .textSecondary)
            }

            // Closable Tags
            PrismSection {
                PrismVStack(spacing: .medium) {
                    if isTagPresented {
                        PrismTag("Clique no X para fechar", onClose: {
                            withAnimation {
                                isTagPresented = false
                            }
                        })
                    } else {
                        PrismButton("Reabir Tag", testID: "reopen_tag_button") {
                            withAnimation {
                                isTagPresented = true
                            }
                        }
                    }

                    PrismHStack(spacing: .small) {
                        PrismTag("Item 1", onClose: {})
                        PrismTag("Item 2", onClose: {})
                        PrismTag("Item 3", onClose: {})
                    }
                }
                .prismPadding()
            } header: {
                PrismText("Tags Fecháveis")
                    .prism(font: .footnote)
                    .prism(color: .textSecondary)
            }

            // In Real Context
            PrismSection {
                PrismVStack(alignment: .leading, spacing: .medium) {
                    PrismVStack(alignment: .leading, spacing: .small) {
                        PrismText("SwiftUI Developer")
                            .prism(font: .headline)

                        PrismHStack(spacing: .small) {
                            PrismTag("Swift", style: .info, size: .small)
                            PrismTag("iOS", style: .info, size: .small)
                            PrismTag("macOS", style: .info, size: .small)
                            PrismTag("UI/UX", style: .success, size: .small)
                        }

                        PrismHStack(spacing: .small) {
                            PrismTag("Senior", style: .filled, size: .small)
                            PrismTag("Remote", style: .ghost, size: .small)
                        }
                    }
                    .prismPadding()
                    .prismBackgroundSecondary()
                    .prism(clip: .rounded(radius: 12))
                }
                .prismPadding()
            } header: {
                PrismText("Em Contexto Real")
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
                    "PrismTag é ideal para categorização, filtros e labels. Use estilos semânticos (.success, .error) para comunicar status. Tags fecháveis são ótimas para filtros removíveis."
                )

                PrismTag("7 estilos", style: .info, size: .small)
                PrismTag("3 tamanhos", style: .info, size: .small)
                PrismTag("Ícones", style: .info, size: .small)
            }
            .prismPadding()
            .prismBackgroundSecondary()
            .prism(clip: .rounded(radius: 20))
        }
        .navigationTitle("Tag")
    }
}

#Preview {
    PrismNavigationView(router: .init()) { (_: PlaygroundRoute) in
        EmptyView()
    } content: {
        TagDemoView()
    }
    .prism(theme: PrismPlaygroundTheme())
}
