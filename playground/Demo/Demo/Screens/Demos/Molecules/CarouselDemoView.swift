//
//  CarouselDemoView.swift
//  PrismPlayground
//
//  Created by Rafael Escaleira on 11/04/26.
//

import PrismUI
import SwiftUI

struct CarouselDemoView: View {
    @Environment(\.theme) private var theme
    @State private var selectedImage: Int?
    @State private var autoScrollEnabled = true

    private let images = [
        "https://picsum.photos/400/300?random=1",
        "https://picsum.photos/400/300?random=2",
        "https://picsum.photos/400/300?random=3",
        "https://picsum.photos/400/300?random=4",
        "https://picsum.photos/400/300?random=5",
    ]

    var body: some View {
        PrismLazyList {
            // Basic Carousel
            PrismSection {
                PrismVStack(spacing: .medium) {
                    PrismCarousel(
                        items: images.enumerated().map { ImageItem(id: $0.offset, url: $0.element) },
                        selection: $selectedImage,
                        isAutoScrolling: autoScrollEnabled
                    ) { index in
                        PrismAsyncImage(images[index])
                            .prism(clip: .rounded(radius: 12))
                    }

                    PrismFootnoteText("Imagem selecionada: \(selectedImage ?? 0 + 1)")
                }
                .prismPadding()
            } header: {
                PrismText("Carrossel Básico")
                    .prism(font: .footnote)
                    .prism(color: .textSecondary)
            }

            // Auto Scroll Control
            PrismSection {
                PrismVStack(spacing: .medium) {
                    PrismHStack {
                        PrismText("Auto Scroll")
                        PrismSpacer()
                        PrismButton(autoScrollEnabled ? "Ativado" : "Desativado", testID: "auto_scroll_toggle") {
                            autoScrollEnabled.toggle()
                        }
                    }

                    PrismCarousel(
                        items: images.enumerated().map { ImageItem(id: $0.offset, url: $0.element) },
                        selection: $selectedImage,
                        isAutoScrolling: autoScrollEnabled
                    ) { index in
                        PrismAsyncImage(images[index])
                            .prism(clip: .rounded(radius: 12))
                    }
                }
                .prismPadding()
            } header: {
                PrismText("Controle de Auto Scroll")
                    .prism(font: .footnote)
                    .prism(color: .textSecondary)
            }

            // Custom Item Width
            PrismSection {
                PrismCarousel(
                    items: images.enumerated().map { ImageItem(id: $0.offset, url: $0.element) },
                    itemWidth: 200,
                    selection: $selectedImage,
                    isAutoScrolling: false
                ) { index in
                    PrismAsyncImage(images[index])
                        .prism(clip: .rounded(radius: 12))
                }
                .prismPadding()
            } header: {
                PrismText("Largura Personalizada")
                    .prism(font: .footnote)
                    .prism(color: .textSecondary)
            }

            // Custom Spacing
            PrismSection {
                PrismVStack(spacing: .medium) {
                    PrismText("Spacing: .small")
                        .prism(font: .footnote)
                    PrismCarousel(
                        items: images.enumerated().map { ImageItem(id: $0.offset, url: $0.element) },
                        spacing: .small,
                        selection: $selectedImage,
                        isAutoScrolling: false
                    ) { index in
                        PrismAsyncImage(images[index])
                            .prism(clip: .rounded(radius: 6))
                    }

                    PrismText("Spacing: .large")
                        .prism(font: .footnote)
                    PrismCarousel(
                        items: images.enumerated().map { ImageItem(id: $0.offset, url: $0.element) },
                        spacing: .large,
                        selection: $selectedImage,
                        isAutoScrolling: false
                    ) { index in
                        PrismAsyncImage(images[index])
                            .prism(clip: .rounded(radius: 6))
                    }
                }
                .prismPadding()
            } header: {
                PrismText("Espaçamento")
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
                    "PrismCarousel oferece scroll horizontal com efeito de escala nos itens laterais. O auto scroll é útil para featured content. Use binding de selection para controle programático."
                )

                PrismTag("Auto Scroll", style: .info, size: .small)
                PrismTag("Scale Effect", style: .info, size: .small)
                PrismTag("Binding", style: .info, size: .small)
            }
            .prismPadding()
            .prismBackgroundSecondary()
            .prism(clip: .rounded(radius: 20))
        }
        .navigationTitle("Carousel")
    }
}

private struct ImageItem: Identifiable, Equatable {
    let id: Int
    let url: String
}

#Preview {
    PrismNavigationView(router: .init()) { (_: PlaygroundRoute) in
        EmptyView()
    } content: {
        CarouselDemoView()
    }
    .prism(theme: PrismPlaygroundTheme())
}
