//
//  SkeletonDemoView.swift
//  PrismPlayground
//
//  Created by Rafael Escaleira on 11/04/26.
//

import PrismUI
import SwiftUI
import PrismArchitecture

struct SkeletonDemoView: View {
    @Environment(\.theme) private var theme
    @State private var isLoading = true
    @State private var contentLoaded = false

    var body: some View {
        PrismLazyList {
            // Toggle Control
            PrismSection {
                PrismHStack {
                    PrismText("Estado")
                    PrismSpacer()
                    PrismButton(isLoading ? "Loading" : "Loaded", testID: "toggle_loading_button") {
                        isLoading.toggle()
                    }
                }
                .prismPadding()
            } header: {
                PrismText("Controle de Loading")
                    .prism(font: .footnote)
                    .prism(color: .textSecondary)
            }

            // Text Skeleton
            PrismSection {
                PrismVStack(alignment: .leading, spacing: .small) {
                    PrismText("Título do Conteúdo")
                        .prism(loading: isLoading)

                    PrismBodyText("Este é um parágrafo de exemplo que exibe skeleton quando está carregando.")
                        .prism(loading: isLoading)

                    PrismFootnoteText("Metadado ou informação secundária")
                        .prism(loading: isLoading)
                }
                .prismPadding()
            } header: {
                PrismText("Texto com Skeleton")
                    .prism(font: .footnote)
                    .prism(color: .textSecondary)
            }

            // Image Skeleton
            PrismSection {
                PrismAsyncImage("https://picsum.photos/400/200")
                    .prism(clip: .rounded(radius: 12))
                    .aspectRatio(2, contentMode: .fit)
                    .prism(loading: isLoading)
                    .prismPadding()
            } header: {
                PrismText("Imagem com Skeleton")
                    .prism(font: .footnote)
                    .prism(color: .textSecondary)
            }

            // Card Skeleton
            PrismSection {
                PrismVStack(alignment: .leading, spacing: .medium) {
                    PrismHStack(spacing: .medium) {
                        PrismShape(shape: .circle)
                            .prism(background: isLoading ? .secondary : .primary)
                            .frame(width: 50, height: 50)
                            .prism(loading: isLoading)

                        PrismVStack(alignment: .leading, spacing: .small) {
                            PrismText("Nome do Usuário")
                                .prism(loading: isLoading)
                            PrismFootnoteText("email@exemplo.com")
                                .prism(loading: isLoading)
                        }
                    }

                    PrismShape.rounded(radius: 12)
                        .prism(background: isLoading ? .secondary : .backgroundSecondary)
                        .frame(height: 100)
                        .prism(loading: isLoading)

                    PrismHStack {
                        PrismShape(shape: .capsule)
                            .prism(background: isLoading ? .secondary : .primary)
                            .frame(width: 80, height: 36)
                            .prism(loading: isLoading)

                        PrismSpacer()

                        PrismShape(shape: .capsule)
                            .prism(background: isLoading ? .secondary : .secondary)
                            .frame(width: 60, height: 36)
                            .prism(loading: isLoading)
                    }
                }
                .prismPadding()
                .prismBackgroundSecondary()
                .prism(clip: .rounded(radius: 12))
            } header: {
                PrismText("Card com Skeleton")
                    .prism(font: .footnote)
                    .prism(color: .textSecondary)
            }

            // List Skeleton
            PrismSection {
                PrismVStack(spacing: .medium) {
                    ForEach(0..<4, id: \.self) { index in
                        PrismHStack(spacing: .medium) {
                            PrismShape(shape: .circle)
                                .frame(width: 40, height: 40)
                                .prism(loading: isLoading)

                            PrismVStack(alignment: .leading, spacing: .small) {
                                PrismShape.rounded(radius: 6)
                                    .frame(width: 150, height: 16)
                                    .prism(loading: isLoading)

                                PrismShape.rounded(radius: 6)
                                    .frame(width: 100, height: 12)
                                    .prism(loading: isLoading)
                            }

                            PrismSpacer()

                            PrismShape.rounded(radius: 6)
                                .frame(width: 30, height: 30)
                                .prism(loading: isLoading)
                        }
                    }
                }
                .prismPadding()
            } header: {
                PrismText("Lista com Skeleton")
                    .prism(font: .footnote)
                    .prism(color: .textSecondary)
            }

            // Simulate Loading
            PrismSection {
                PrismVStack(spacing: .medium) {
                    PrismPrimaryButton(contentLoaded ? "Recarregar" : "Carregar Conteúdo", testID: "load_content_button") {
                        isLoading = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                isLoading = false
                                contentLoaded = true
                            }
                        }
                    }

                    if contentLoaded && !isLoading {
                        PrismVStack(alignment: .leading, spacing: .small) {
                            PrismText("Conteúdo Carregado!")
                                .prism(font: .headline)
                            PrismBodyText("O skeleton foi substituído pelo conteúdo real após 2 segundos.")
                        }
                        .prismPadding()
                        .prismBackgroundSecondary()
                        .prism(clip: .rounded(radius: 12))
                        .transition(.opacity.combined(with: .scale))
                    }
                }
                .prismPadding()
            } header: {
                PrismText("Simular Carregamento")
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
                    "Skeleton é essencial para perceived performance. Use prism(loading:) em qualquer view para exibir placeholder animado durante carregamento de dados."
                )

                PrismTag("Performance", style: .info, size: .small)
                PrismTag("UX", style: .info, size: .small)
                PrismTag("Animado", style: .info, size: .small)
            }
            .prismPadding()
            .prismBackgroundSecondary()
            .prism(clip: .rounded(radius: 20))
        }
        .navigationTitle("Skeleton")
    }
}

#Preview {
    PrismNavigationView(router: .init()) { (_: PlaygroundRoute) in
        EmptyView()
    } content: {
        SkeletonDemoView()
    }
    .prism(theme: PrismPlaygroundTheme())
}
