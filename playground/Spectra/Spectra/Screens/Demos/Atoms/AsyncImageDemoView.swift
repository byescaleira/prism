//
//  AsyncImageDemoView.swift
//  PrismPlayground
//
//  Created by Rafael Escaleira on 11/04/26.
//

import PrismUI
import SwiftUI
import PrismArchitecture

struct AsyncImageDemoView: View {
    @Environment(\.theme) private var theme
    @State private var customURL = "https://picsum.photos/400/300"

    var body: some View {
        PrismLazyList {
            // Basic Usage
            PrismSection {
                PrismVStack(spacing: .medium) {
                    PrismAsyncImage("https://picsum.photos/400/300")
                        .prism(clip: .rounded(radius: 12))
                        .aspectRatio(4 / 3, contentMode: .fill)

                    PrismFootnoteText("Imagem carregada com cache automático")
                }
                .prismPadding()
            } header: {
                PrismText("Uso Básico")
                    .prism(font: .footnote)
                    .prism(color: .textSecondary)
            }

            // With Placeholder
            PrismSection {
                PrismVStack(spacing: .medium) {
                    PrismAsyncImage(
                        "https://picsum.photos/400/300",
                        placeholder: {
                            PrismZStack {
                                PrismSymbol("photo")
                                    .prism(font: .largeTitle)
                                    .prism(color: .textSecondary)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .prismBackgroundSecondary()
                        }
                    )
                    .prism(clip: .rounded(radius: 12))
                    .aspectRatio(4 / 3, contentMode: .fill)
                }
                .prismPadding()
            } header: {
                PrismText("Com Placeholder")
                    .prism(font: .footnote)
                    .prism(color: .textSecondary)
            }

            // Custom Content
            PrismSection {
                PrismVStack(spacing: .medium) {
                    PrismAsyncImage("https://picsum.photos/400/300") { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .overlay {
                                PrismVStack(alignment: .leading, spacing: .small) {
                                    PrismText("Imagem Carregada")
                                        .prism(color: .white)
                                        .prism(font: .headline)
                                    PrismFootnoteText("Com overlay personalizado")
                                        .prism(color: .white)
                                        .opacity(0.8)
                                }
                                .prismPadding()
                            }
                            .overlay(alignment: .bottom) {
                                LinearGradient(
                                    colors: [.clear, .black.opacity(0.7)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            }
                    }
                    .prism(clip: .rounded(radius: 12))
                    .aspectRatio(4 / 3, contentMode: .fill)
                }
                .prismPadding()
            } header: {
                PrismText("Conteúdo Personalizado")
                    .prism(font: .footnote)
                    .prism(color: .textSecondary)
            }

            // Cache Control
            PrismSection {
                PrismVStack(spacing: .medium) {
                    PrismHStack {
                        PrismVStack(alignment: .leading, spacing: .small) {
                            PrismText("Cache Infinito")
                                .prism(font: .footnote)
                            PrismAsyncImage(
                                "https://picsum.photos/200/200",
                                cacheInterval: .infinity
                            )
                            .prism(clip: .circle)
                            .frame(width: 80, height: 80)
                        }

                        PrismVStack(alignment: .leading, spacing: .small) {
                            PrismText("Sem Cache")
                                .prism(font: .footnote)
                            PrismAsyncImage(
                                "https://picsum.photos/200/201",
                                cacheInterval: nil
                            )
                            .prism(clip: .circle)
                            .frame(width: 80, height: 80)
                        }
                    }

                    PrismFootnoteText("Cache controla performance vs atualização")
                }
                .prismPadding()
            } header: {
                PrismText("Controle de Cache")
                    .prism(font: .footnote)
                    .prism(color: .textSecondary)
            }

            // Animation Control
            PrismSection {
                PrismVStack(spacing: .medium) {
                    PrismHStack {
                        PrismVStack(alignment: .leading, spacing: .small) {
                            PrismText("Animado")
                                .prism(font: .footnote)
                            PrismAsyncImage(
                                "https://picsum.photos/200/202",
                                isAnimated: true
                            )
                            .prism(clip: .rounded(radius: 12))
                            .frame(width: 100, height: 100)
                        }

                        PrismVStack(alignment: .leading, spacing: .small) {
                            PrismText("Sem Animação")
                                .prism(font: .footnote)
                            PrismAsyncImage(
                                "https://picsum.photos/200/203",
                                isAnimated: false
                            )
                            .prism(clip: .rounded(radius: 12))
                            .frame(width: 100, height: 100)
                        }
                    }
                }
                .prismPadding()
            } header: {
                PrismText("Animação")
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
                    "PrismAsyncImage gerencia automaticamente cache de imagens usando URLCache. O cache reduz requisições de rede e melhora performance. Use placeholder para melhor UX durante carregamento."
                )

                PrismTag("Cache Automático", style: .info, size: .small)
                PrismTag("Placeholder", style: .info, size: .small)
                PrismTag("Animação", style: .info, size: .small)
            }
            .prismPadding()
            .prismBackgroundSecondary()
            .prism(clip: .rounded(radius: 20))
        }
        .navigationTitle("Async Image")
    }
}

#Preview {
    PrismNavigationView(router: .init()) { (_: PlaygroundRoute) in
        EmptyView()
    } content: {
        AsyncImageDemoView()
    }
    .prism(theme: PrismPlaygroundTheme())
}
