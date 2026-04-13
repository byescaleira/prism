//
//  CarouselDemoView.swift
//  RyzePlayground
//
//  Created by Rafael Escaleira on 11/04/26.
//

import RyzeUI
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
        RyzeLazyList {
            // Basic Carousel
            RyzeSection {
                RyzeVStack(spacing: .medium) {
                    RyzeCarousel(
                        items: images.enumerated().map { ImageItem(id: $0.offset, url: $0.element) },
                        selection: $selectedImage,
                        isAutoScrolling: autoScrollEnabled
                    ) { index in
                        RyzeAsyncImage(images[index])
                            .ryze(clip: .rounded(radius: 12))
                    }

                    RyzeFootnoteText("Imagem selecionada: \(selectedImage ?? 0 + 1)")
                }
                .ryzePadding()
            } header: {
                RyzeText("Carrossel Básico")
                    .ryze(font: .footnote)
                    .ryze(color: .textSecondary)
            }

            // Auto Scroll Control
            RyzeSection {
                RyzeVStack(spacing: .medium) {
                    RyzeHStack {
                        RyzeText("Auto Scroll")
                        RyzeSpacer()
                        RyzeButton(autoScrollEnabled ? "Ativado" : "Desativado", testID: "auto_scroll_toggle") {
                            autoScrollEnabled.toggle()
                        }
                    }

                    RyzeCarousel(
                        items: images.enumerated().map { ImageItem(id: $0.offset, url: $0.element) },
                        selection: $selectedImage,
                        isAutoScrolling: autoScrollEnabled
                    ) { index in
                        RyzeAsyncImage(images[index])
                            .ryze(clip: .rounded(radius: 12))
                    }
                }
                .ryzePadding()
            } header: {
                RyzeText("Controle de Auto Scroll")
                    .ryze(font: .footnote)
                    .ryze(color: .textSecondary)
            }

            // Custom Item Width
            RyzeSection {
                RyzeCarousel(
                    items: images.enumerated().map { ImageItem(id: $0.offset, url: $0.element) },
                    itemWidth: 200,
                    selection: $selectedImage,
                    isAutoScrolling: false
                ) { index in
                    RyzeAsyncImage(images[index])
                        .ryze(clip: .rounded(radius: 12))
                }
                .ryzePadding()
            } header: {
                RyzeText("Largura Personalizada")
                    .ryze(font: .footnote)
                    .ryze(color: .textSecondary)
            }

            // Custom Spacing
            RyzeSection {
                RyzeVStack(spacing: .medium) {
                    RyzeText("Spacing: .small")
                        .ryze(font: .footnote)
                    RyzeCarousel(
                        items: images.enumerated().map { ImageItem(id: $0.offset, url: $0.element) },
                        spacing: .small,
                        selection: $selectedImage,
                        isAutoScrolling: false
                    ) { index in
                        RyzeAsyncImage(images[index])
                            .ryze(clip: .rounded(radius: 6))
                    }

                    RyzeText("Spacing: .large")
                        .ryze(font: .footnote)
                    RyzeCarousel(
                        items: images.enumerated().map { ImageItem(id: $0.offset, url: $0.element) },
                        spacing: .large,
                        selection: $selectedImage,
                        isAutoScrolling: false
                    ) { index in
                        RyzeAsyncImage(images[index])
                            .ryze(clip: .rounded(radius: 6))
                    }
                }
                .ryzePadding()
            } header: {
                RyzeText("Espaçamento")
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
                    "RyzeCarousel oferece scroll horizontal com efeito de escala nos itens laterais. O auto scroll é útil para featured content. Use binding de selection para controle programático."
                )

                RyzeTag("Auto Scroll", style: .info, size: .small)
                RyzeTag("Scale Effect", style: .info, size: .small)
                RyzeTag("Binding", style: .info, size: .small)
            }
            .ryzePadding()
            .ryzeBackgroundSecondary()
            .ryze(clip: .rounded(radius: 20))
        }
        .navigationTitle("Carousel")
    }
}

private struct ImageItem: Identifiable, Equatable {
    let id: Int
    let url: String
}

#Preview {
    RyzeNavigationView(router: .init()) { (_: PlaygroundRoute) in
        EmptyView()
    } content: {
        CarouselDemoView()
    }
    .ryze(theme: RyzePlaygroundTheme())
}
