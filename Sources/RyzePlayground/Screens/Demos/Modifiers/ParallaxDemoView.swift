//
//  ParallaxDemoView.swift
//  RyzePlayground
//
//  Created by Rafael Escaleira on 11/04/26.
//

import RyzeUI
import SwiftUI

struct ParallaxDemoView: View {
    @Environment(\.theme) private var theme

    var body: some View {
        RyzeLazyList {
            // Platform Notice
            RyzeSection {
                RyzeVStack(spacing: .small) {
                    RyzeHStack(spacing: .small) {
                        RyzeSymbol("info.circle.fill")
                            .ryze(color: .info)
                        RyzeBodyText("Efeito parallax requer dispositivo físico com giroscópio (iPhone/iPad).")
                    }
                }
                .ryzePadding()
                .ryzeBackgroundSecondary()
                .ryze(clip: .rounded(radius: 12))
            } header: {
                RyzeText("Disponibilidade")
                    .ryze(font: .footnote)
                    .ryze(color: .textSecondary)
            }

            // Basic Parallax
            RyzeSection {
                RyzeVStack(spacing: .medium) {
                    #if os(iOS)
                    RyzeSymbol("rainbow")
                        .ryze(font: .system(size: 80))
                        .ryzeParallax(height: .large)
                    #else
                    RyzeSymbol("rainbow")
                        .ryze(font: .system(size: 80))
                    #endif
                }
                .ryzePadding()
                .ryzeBackgroundSecondary()
                .ryze(clip: .rounded(radius: 20))
            } header: {
                RyzeText("Efeito Parallax")
                    .ryze(font: .footnote)
                    .ryze(color: .textSecondary)
            }

            // Parallax Card
            RyzeSection {
                RyzeVStack(spacing: .medium) {
                    #if os(iOS)
                    RyzeZStack {
                        RyzeAsyncImage("https://picsum.photos/400/300")
                            .ryze(clip: .rounded(radius: 20))
                            .ryzeParallax(width: .large, height: .medium)

                        RyzeVStack(alignment: .leading, spacing: .small) {
                            RyzeText("Efeito 3D")
                                .ryze(font: .headline)
                                .ryze(color: .white)
                            RyzeFootnoteText("Incline o dispositivo")
                                .ryze(color: .white)
                                .opacity(0.8)
                        }
                        .ryzePadding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                    }
                    .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
                    #else
                    RyzeText("Parallax disponível apenas no iOS")
                        .ryzePadding()
                    #endif
                }
                .ryzePadding()
            } header: {
                RyzeText("Card com Parallax")
                    .ryze(font: .footnote)
                    .ryze(color: .textSecondary)
            }

            // Shine Effect
            RyzeSection {
                RyzeVStack(spacing: .medium) {
                    #if os(iOS)
                    RyzeHStack(spacing: .large) {
                        RyzeZStack {
                            RyzeShape(shape: .circle)
                                .ryze(background: .primary)
                                .frame(width: 100, height: 100)

                            RyzeSymbol("bolt.fill")
                                .ryze(font: .largeTitle)
                                .ryze(color: .white)
                        }
                        .ryzeParallax(height: .medium)

                        RyzeZStack {
                            RyzeShape.rounded(radius: 12)
                                .ryze(background: .secondary)
                                .frame(width: 100, height: 100)

                            RyzeSymbol("star.fill")
                                .ryze(font: .largeTitle)
                                .ryze(color: .white)
                        }
                        .ryzeParallax(height: .medium)
                    }
                    #else
                    RyzeText("Brilho dinâmico disponível apenas no iOS")
                        .ryzePadding()
                    #endif
                }
                .ryzePadding()
            } header: {
                RyzeText("Brilho Dinâmico")
                    .ryze(font: .footnote)
                    .ryze(color: .textSecondary)
            }

            // Use Cases
            RyzeSection {
                RyzeVStack(spacing: .medium) {
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
                .ryzePadding()
            } header: {
                RyzeText("Casos de Uso")
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
                    "Parallax usa o giroscópio do dispositivo para criar ilusão de profundidade 3D. O brilho dinâmico (shine) segue a inclinação para realismo. Use com moderação em elementos de destaque."
                )

                RyzeTag("iOS Apenas", style: .info, size: .small)
                RyzeTag("Giroscópio", style: .info, size: .small)
                RyzeTag("3D Effect", style: .info, size: .small)
            }
            .ryzePadding()
            .ryzeBackgroundSecondary()
            .ryze(clip: .rounded(radius: 20))
        }
        .navigationTitle("Parallax")
    }
}

private struct ParallaxUseCaseRow: View {
    let title: String
    let description: String
    let icon: String

    var body: some View {
        RyzeHStack(spacing: .medium) {
            RyzeShape(shape: .circle)
                .ryze(background: .secondary)
                .frame(width: 44, height: 44)

            RyzeSymbol(icon, mode: .hierarchical)
                .ryze(color: .primary)
                .ryze(font: .title2)

            RyzeVStack(alignment: .leading, spacing: .small) {
                RyzeText(title)
                    .ryze(font: .body)
                RyzeFootnoteText(description)
            }
        }
        .ryzePadding(.vertical, .small)
    }
}

#Preview {
    RyzeNavigationView(router: .init()) { (_: PlaygroundRoute) in
        EmptyView()
    } content: {
        ParallaxDemoView()
    }
    .ryze(theme: RyzePlaygroundTheme())
}
