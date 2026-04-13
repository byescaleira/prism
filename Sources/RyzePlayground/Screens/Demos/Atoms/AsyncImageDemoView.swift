//
//  AsyncImageDemoView.swift
//  RyzePlayground
//
//  Created by Rafael Escaleira on 11/04/26.
//

import RyzeUI
import SwiftUI

struct AsyncImageDemoView: View {
    @Environment(\.theme) private var theme
    @State private var customURL = "https://picsum.photos/400/300"

    var body: some View {
        RyzeLazyList {
            // Basic Usage
            RyzeSection {
                RyzeVStack(spacing: .medium) {
                    RyzeAsyncImage("https://picsum.photos/400/300")
                        .ryze(clip: .rounded(radius: 12))
                        .aspectRatio(4 / 3, contentMode: .fill)

                    RyzeFootnoteText("Imagem carregada com cache automático")
                }
                .ryzePadding()
            } header: {
                RyzeText("Uso Básico")
                    .ryze(font: .footnote)
                    .ryze(color: .textSecondary)
            }

            // With Placeholder
            RyzeSection {
                RyzeVStack(spacing: .medium) {
                    RyzeAsyncImage(
                        "https://picsum.photos/400/300",
                        placeholder: {
                            RyzeZStack {
                                RyzeSymbol("photo")
                                    .ryze(font: .largeTitle)
                                    .ryze(color: .textSecondary)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .ryzeBackgroundSecondary()
                        }
                    )
                    .ryze(clip: .rounded(radius: 12))
                    .aspectRatio(4 / 3, contentMode: .fill)
                }
                .ryzePadding()
            } header: {
                RyzeText("Com Placeholder")
                    .ryze(font: .footnote)
                    .ryze(color: .textSecondary)
            }

            // Custom Content
            RyzeSection {
                RyzeVStack(spacing: .medium) {
                    RyzeAsyncImage("https://picsum.photos/400/300") { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .overlay {
                                RyzeVStack(alignment: .leading, spacing: .small) {
                                    RyzeText("Imagem Carregada")
                                        .ryze(color: .white)
                                        .ryze(font: .headline)
                                    RyzeFootnoteText("Com overlay personalizado")
                                        .ryze(color: .white)
                                        .opacity(0.8)
                                }
                                .ryzePadding()
                            }
                            .overlay(alignment: .bottom) {
                                LinearGradient(
                                    colors: [.clear, .black.opacity(0.7)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            }
                    }
                    .ryze(clip: .rounded(radius: 12))
                    .aspectRatio(4 / 3, contentMode: .fill)
                }
                .ryzePadding()
            } header: {
                RyzeText("Conteúdo Personalizado")
                    .ryze(font: .footnote)
                    .ryze(color: .textSecondary)
            }

            // Cache Control
            RyzeSection {
                RyzeVStack(spacing: .medium) {
                    RyzeHStack {
                        RyzeVStack(alignment: .leading, spacing: .small) {
                            RyzeText("Cache Infinito")
                                .ryze(font: .footnote)
                            RyzeAsyncImage(
                                "https://picsum.photos/200/200",
                                cacheInterval: .infinity
                            )
                            .ryze(clip: .circle)
                            .frame(width: 80, height: 80)
                        }

                        RyzeVStack(alignment: .leading, spacing: .small) {
                            RyzeText("Sem Cache")
                                .ryze(font: .footnote)
                            RyzeAsyncImage(
                                "https://picsum.photos/200/201",
                                cacheInterval: nil
                            )
                            .ryze(clip: .circle)
                            .frame(width: 80, height: 80)
                        }
                    }

                    RyzeFootnoteText("Cache controla performance vs atualização")
                }
                .ryzePadding()
            } header: {
                RyzeText("Controle de Cache")
                    .ryze(font: .footnote)
                    .ryze(color: .textSecondary)
            }

            // Animation Control
            RyzeSection {
                RyzeVStack(spacing: .medium) {
                    RyzeHStack {
                        RyzeVStack(alignment: .leading, spacing: .small) {
                            RyzeText("Animado")
                                .ryze(font: .footnote)
                            RyzeAsyncImage(
                                "https://picsum.photos/200/202",
                                isAnimated: true
                            )
                            .ryze(clip: .rounded(radius: 12))
                            .frame(width: 100, height: 100)
                        }

                        RyzeVStack(alignment: .leading, spacing: .small) {
                            RyzeText("Sem Animação")
                                .ryze(font: .footnote)
                            RyzeAsyncImage(
                                "https://picsum.photos/200/203",
                                isAnimated: false
                            )
                            .ryze(clip: .rounded(radius: 12))
                            .frame(width: 100, height: 100)
                        }
                    }
                }
                .ryzePadding()
            } header: {
                RyzeText("Animação")
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
                    "RyzeAsyncImage gerencia automaticamente cache de imagens usando URLCache. O cache reduz requisições de rede e melhora performance. Use placeholder para melhor UX durante carregamento."
                )

                RyzeTag("Cache Automático", style: .info, size: .small)
                RyzeTag("Placeholder", style: .info, size: .small)
                RyzeTag("Animação", style: .info, size: .small)
            }
            .ryzePadding()
            .ryzeBackgroundSecondary()
            .ryze(clip: .rounded(radius: 20))
        }
        .navigationTitle("Async Image")
    }
}

#Preview {
    RyzeNavigationView(router: .init()) { (_: PlaygroundRoute) in
        EmptyView()
    } content: {
        AsyncImageDemoView()
    }
    .ryze(theme: RyzePlaygroundTheme())
}
