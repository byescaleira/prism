//
//  TagDemoView.swift
//  RyzePlayground
//
//  Created by Rafael Escaleira on 11/04/26.
//

import RyzeUI
import SwiftUI

struct TagDemoView: View {
    @Environment(\.theme) private var theme
    @State private var isTagPresented = true

    var body: some View {
        RyzeLazyList {
            // All Styles
            RyzeSection {
                RyzeVStack(spacing: .medium) {
                    RyzeHStack(spacing: .small) {
                        RyzeTag("Filled", style: .filled)
                        RyzeTag("Outlined", style: .outlined)
                        RyzeTag("Ghost", style: .ghost)
                    }

                    RyzeHStack(spacing: .small) {
                        RyzeTag("Success", style: .success)
                        RyzeTag("Error", style: .error)
                        RyzeTag("Warning", style: .warning)
                        RyzeTag("Info", style: .info)
                    }
                }
                .ryzePadding()
            } header: {
                RyzeText("Estilos Disponíveis")
                    .ryze(font: .footnote)
                    .ryze(color: .textSecondary)
            }

            // All Sizes
            RyzeSection {
                RyzeVStack(spacing: .medium) {
                    RyzeHStack(spacing: .small) {
                        RyzeTag("Small", size: .small)
                        RyzeTag("Medium", size: .medium)
                        RyzeTag("Large", size: .large)
                    }
                }
                .ryzePadding()
            } header: {
                RyzeText("Tamanhos")
                    .ryze(font: .footnote)
                    .ryze(color: .textSecondary)
            }

            // With Icons
            RyzeSection {
                RyzeHStack(spacing: .small) {
                    RyzeTag("Swift", icon: "swift")
                    RyzeTag("iOS", icon: "applelogo")
                    RyzeTag("macOS", icon: "applelogo")
                    RyzeTag("watchOS", icon: "applelogo")
                    RyzeTag("tvOS", icon: "applelogo")
                    RyzeTag("visionOS", icon: "applelogo")
                }
                .ryzePadding()
            } header: {
                RyzeText("Com Ícones")
                    .ryze(font: .footnote)
                    .ryze(color: .textSecondary)
            }

            // Closable Tags
            RyzeSection {
                RyzeVStack(spacing: .medium) {
                    if isTagPresented {
                        RyzeTag("Clique no X para fechar", onClose: {
                            withAnimation {
                                isTagPresented = false
                            }
                        })
                    } else {
                        RyzeButton("Reabir Tag", testID: "reopen_tag_button") {
                            withAnimation {
                                isTagPresented = true
                            }
                        }
                    }

                    RyzeHStack(spacing: .small) {
                        RyzeTag("Item 1", onClose: {})
                        RyzeTag("Item 2", onClose: {})
                        RyzeTag("Item 3", onClose: {})
                    }
                }
                .ryzePadding()
            } header: {
                RyzeText("Tags Fecháveis")
                    .ryze(font: .footnote)
                    .ryze(color: .textSecondary)
            }

            // In Real Context
            RyzeSection {
                RyzeVStack(alignment: .leading, spacing: .medium) {
                    RyzeVStack(alignment: .leading, spacing: .small) {
                        RyzeText("SwiftUI Developer")
                            .ryze(font: .headline)

                        RyzeHStack(spacing: .small) {
                            RyzeTag("Swift", style: .info, size: .small)
                            RyzeTag("iOS", style: .info, size: .small)
                            RyzeTag("macOS", style: .info, size: .small)
                            RyzeTag("UI/UX", style: .success, size: .small)
                        }

                        RyzeHStack(spacing: .small) {
                            RyzeTag("Senior", style: .filled, size: .small)
                            RyzeTag("Remote", style: .ghost, size: .small)
                        }
                    }
                    .ryzePadding()
                    .ryzeBackgroundSecondary()
                    .ryze(clip: .rounded(radius: 12))
                }
                .ryzePadding()
            } header: {
                RyzeText("Em Contexto Real")
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
                    "RyzeTag é ideal para categorização, filtros e labels. Use estilos semânticos (.success, .error) para comunicar status. Tags fecháveis são ótimas para filtros removíveis."
                )

                RyzeTag("7 estilos", style: .info, size: .small)
                RyzeTag("3 tamanhos", style: .info, size: .small)
                RyzeTag("Ícones", style: .info, size: .small)
            }
            .ryzePadding()
            .ryzeBackgroundSecondary()
            .ryze(clip: .rounded(radius: 20))
        }
        .navigationTitle("Tag")
    }
}

#Preview {
    RyzeNavigationView(router: .init()) { (_: PlaygroundRoute) in
        EmptyView()
    } content: {
        TagDemoView()
    }
    .ryze(theme: RyzePlaygroundTheme())
}
