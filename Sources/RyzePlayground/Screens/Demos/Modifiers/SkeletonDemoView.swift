//
//  SkeletonDemoView.swift
//  RyzePlayground
//
//  Created by Rafael Escaleira on 11/04/26.
//

import RyzeUI
import SwiftUI

struct SkeletonDemoView: View {
    @Environment(\.theme) private var theme
    @State private var isLoading = true
    @State private var contentLoaded = false

    var body: some View {
        RyzeLazyList {
            // Toggle Control
            RyzeSection {
                RyzeHStack {
                    RyzeText("Estado")
                    RyzeSpacer()
                    RyzeButton(isLoading ? "Loading" : "Loaded", testID: "toggle_loading_button") {
                        isLoading.toggle()
                    }
                }
                .ryzePadding()
            } header: {
                RyzeText("Controle de Loading")
                    .ryze(font: .footnote)
                    .ryze(color: .textSecondary)
            }

            // Text Skeleton
            RyzeSection {
                RyzeVStack(alignment: .leading, spacing: .small) {
                    RyzeText("Título do Conteúdo")
                        .ryze(loading: isLoading)

                    RyzeBodyText("Este é um parágrafo de exemplo que exibe skeleton quando está carregando.")
                        .ryze(loading: isLoading)

                    RyzeFootnoteText("Metadado ou informação secundária")
                        .ryze(loading: isLoading)
                }
                .ryzePadding()
            } header: {
                RyzeText("Texto com Skeleton")
                    .ryze(font: .footnote)
                    .ryze(color: .textSecondary)
            }

            // Image Skeleton
            RyzeSection {
                RyzeAsyncImage("https://picsum.photos/400/200")
                    .ryze(clip: .rounded(radius: 12))
                    .aspectRatio(2, contentMode: .fit)
                    .ryze(loading: isLoading)
                    .ryzePadding()
            } header: {
                RyzeText("Imagem com Skeleton")
                    .ryze(font: .footnote)
                    .ryze(color: .textSecondary)
            }

            // Card Skeleton
            RyzeSection {
                RyzeVStack(alignment: .leading, spacing: .medium) {
                    RyzeHStack(spacing: .medium) {
                        RyzeShape(shape: .circle)
                            .ryze(background: isLoading ? .secondary : .primary)
                            .frame(width: 50, height: 50)
                            .ryze(loading: isLoading)

                        RyzeVStack(alignment: .leading, spacing: .small) {
                            RyzeText("Nome do Usuário")
                                .ryze(loading: isLoading)
                            RyzeFootnoteText("email@exemplo.com")
                                .ryze(loading: isLoading)
                        }
                    }

                    RyzeShape.rounded(radius: 12)
                        .ryze(background: isLoading ? .secondary : .backgroundSecondary)
                        .frame(height: 100)
                        .ryze(loading: isLoading)

                    RyzeHStack {
                        RyzeShape(shape: .capsule)
                            .ryze(background: isLoading ? .secondary : .primary)
                            .frame(width: 80, height: 36)
                            .ryze(loading: isLoading)

                        RyzeSpacer()

                        RyzeShape(shape: .capsule)
                            .ryze(background: isLoading ? .secondary : .secondary)
                            .frame(width: 60, height: 36)
                            .ryze(loading: isLoading)
                    }
                }
                .ryzePadding()
                .ryzeBackgroundSecondary()
                .ryze(clip: .rounded(radius: 12))
            } header: {
                RyzeText("Card com Skeleton")
                    .ryze(font: .footnote)
                    .ryze(color: .textSecondary)
            }

            // List Skeleton
            RyzeSection {
                RyzeVStack(spacing: .medium) {
                    ForEach(0..<4, id: \.self) { index in
                        RyzeHStack(spacing: .medium) {
                            RyzeShape(shape: .circle)
                                .frame(width: 40, height: 40)
                                .ryze(loading: isLoading)

                            RyzeVStack(alignment: .leading, spacing: .small) {
                                RyzeShape.rounded(radius: 6)
                                    .frame(width: 150, height: 16)
                                    .ryze(loading: isLoading)

                                RyzeShape.rounded(radius: 6)
                                    .frame(width: 100, height: 12)
                                    .ryze(loading: isLoading)
                            }

                            RyzeSpacer()

                            RyzeShape.rounded(radius: 6)
                                .frame(width: 30, height: 30)
                                .ryze(loading: isLoading)
                        }
                    }
                }
                .ryzePadding()
            } header: {
                RyzeText("Lista com Skeleton")
                    .ryze(font: .footnote)
                    .ryze(color: .textSecondary)
            }

            // Simulate Loading
            RyzeSection {
                RyzeVStack(spacing: .medium) {
                    RyzePrimaryButton(contentLoaded ? "Recarregar" : "Carregar Conteúdo", testID: "load_content_button") {
                        isLoading = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                isLoading = false
                                contentLoaded = true
                            }
                        }
                    }

                    if contentLoaded && !isLoading {
                        RyzeVStack(alignment: .leading, spacing: .small) {
                            RyzeText("Conteúdo Carregado!")
                                .ryze(font: .headline)
                            RyzeBodyText("O skeleton foi substituído pelo conteúdo real após 2 segundos.")
                        }
                        .ryzePadding()
                        .ryzeBackgroundSecondary()
                        .ryze(clip: .rounded(radius: 12))
                        .transition(.opacity.combined(with: .scale))
                    }
                }
                .ryzePadding()
            } header: {
                RyzeText("Simular Carregamento")
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
                    "Skeleton é essencial para perceived performance. Use ryze(loading:) em qualquer view para exibir placeholder animado durante carregamento de dados."
                )

                RyzeTag("Performance", style: .info, size: .small)
                RyzeTag("UX", style: .info, size: .small)
                RyzeTag("Animado", style: .info, size: .small)
            }
            .ryzePadding()
            .ryzeBackgroundSecondary()
            .ryze(clip: .rounded(radius: 20))
        }
        .navigationTitle("Skeleton")
    }
}

#Preview {
    RyzeNavigationView(router: .init()) { (_: PlaygroundRoute) in
        EmptyView()
    } content: {
        SkeletonDemoView()
    }
    .ryze(theme: RyzePlaygroundTheme())
}
