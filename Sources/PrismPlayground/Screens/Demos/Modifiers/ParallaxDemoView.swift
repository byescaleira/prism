//
//  ParallaxDemoView.swift
//  PrismPlayground
//
//  Created by Rafael Escaleira on 11/04/26.
//

import PrismUI
import SwiftUI

struct ParallaxDemoView: View {
    @Environment(\.theme) private var theme

    var body: some View {
        PrismLazyList {
            // Platform Notice
            PrismSection {
                PrismVStack(spacing: .small) {
                    PrismHStack(spacing: .small) {
                        PrismSymbol("info.circle.fill")
                            .prism(color: .info)
                        PrismBodyText("Efeito parallax requer dispositivo físico com giroscópio (iPhone/iPad).")
                    }
                }
                .prismPadding()
                .prismBackgroundSecondary()
                .prism(clip: .rounded(radius: 12))
            } header: {
                PrismText("Disponibilidade")
                    .prism(font: .footnote)
                    .prism(color: .textSecondary)
            }

            // Basic Parallax
            PrismSection {
                PrismVStack(spacing: .medium) {
                    #if os(iOS)
                    PrismSymbol("rainbow")
                        .prism(font: .system(size: 80))
                        .prismParallax(height: .large)
                    #else
                    PrismSymbol("rainbow")
                        .prism(font: .system(size: 80))
                    #endif
                }
                .prismPadding()
                .prismBackgroundSecondary()
                .prism(clip: .rounded(radius: 20))
            } header: {
                PrismText("Efeito Parallax")
                    .prism(font: .footnote)
                    .prism(color: .textSecondary)
            }

            // Parallax Card
            PrismSection {
                PrismVStack(spacing: .medium) {
                    #if os(iOS)
                    PrismZStack {
                        PrismAsyncImage("https://picsum.photos/400/300")
                            .prism(clip: .rounded(radius: 20))
                            .prismParallax(width: .large, height: .medium)

                        PrismVStack(alignment: .leading, spacing: .small) {
                            PrismText("Efeito 3D")
                                .prism(font: .headline)
                                .prism(color: .white)
                            PrismFootnoteText("Incline o dispositivo")
                                .prism(color: .white)
                                .opacity(0.8)
                        }
                        .prismPadding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                    }
                    .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
                    #else
                    PrismText("Parallax disponível apenas no iOS")
                        .prismPadding()
                    #endif
                }
                .prismPadding()
            } header: {
                PrismText("Card com Parallax")
                    .prism(font: .footnote)
                    .prism(color: .textSecondary)
            }

            // Shine Effect
            PrismSection {
                PrismVStack(spacing: .medium) {
                    #if os(iOS)
                    PrismHStack(spacing: .large) {
                        PrismZStack {
                            PrismShape(shape: .circle)
                                .prism(background: .primary)
                                .frame(width: 100, height: 100)

                            PrismSymbol("bolt.fill")
                                .prism(font: .largeTitle)
                                .prism(color: .white)
                        }
                        .prismParallax(height: .medium)

                        PrismZStack {
                            PrismShape.rounded(radius: 12)
                                .prism(background: .secondary)
                                .frame(width: 100, height: 100)

                            PrismSymbol("star.fill")
                                .prism(font: .largeTitle)
                                .prism(color: .white)
                        }
                        .prismParallax(height: .medium)
                    }
                    #else
                    PrismText("Brilho dinâmico disponível apenas no iOS")
                        .prismPadding()
                    #endif
                }
                .prismPadding()
            } header: {
                PrismText("Brilho Dinâmico")
                    .prism(font: .footnote)
                    .prism(color: .textSecondary)
            }

            // Use Cases
            PrismSection {
                PrismVStack(spacing: .medium) {
                    ParallaxUseCaseRow(
                        title: "Cards Premium",
                        description: "Destaque visual para conteúdo exclusivo",
                        icon: "star.circle.fill"
                    )

                    ParallaxUseCaseRow(
                        title: "Trophies/Conquistas",
                        description: "Efeito celebratório em badges",
                        icon: "trophy.fill"
                    )

                    ParallaxUseCaseRow(
                        title: "NFTs/Colecionáveis",
                        description: "Profundidade em itens digitais",
                        icon: "photo.on.rectangle"
                    )
                }
                .prismPadding()
            } header: {
                PrismText("Casos de Uso")
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
                    "Parallax usa o giroscópio do dispositivo para criar ilusão de profundidade 3D. O brilho dinâmico (shine) segue a inclinação para realismo. Use com moderação em elementos de destaque."
                )

                PrismTag("iOS Apenas", style: .info, size: .small)
                PrismTag("Giroscópio", style: .info, size: .small)
                PrismTag("3D Effect", style: .info, size: .small)
            }
            .prismPadding()
            .prismBackgroundSecondary()
            .prism(clip: .rounded(radius: 20))
        }
        .navigationTitle("Parallax")
    }
}

private struct ParallaxUseCaseRow: View {
    let title: String
    let description: String
    let icon: String

    var body: some View {
        PrismHStack(spacing: .medium) {
            PrismShape(shape: .circle)
                .prism(background: .secondary)
                .frame(width: 44, height: 44)

            PrismSymbol(icon, mode: .hierarchical)
                .prism(color: .primary)
                .prism(font: .title2)

            PrismVStack(alignment: .leading, spacing: .small) {
                PrismText(title)
                    .prism(font: .body)
                PrismFootnoteText(description)
            }
        }
        .prismPadding(.vertical, .small)
    }
}

#Preview {
    PrismNavigationView(router: .init()) { (_: PlaygroundRoute) in
        EmptyView()
    } content: {
        ParallaxDemoView()
    }
    .prism(theme: PrismPlaygroundTheme())
}
