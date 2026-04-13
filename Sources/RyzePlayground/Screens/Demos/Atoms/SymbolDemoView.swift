//
//  SymbolDemoView.swift
//  RyzePlayground
//
//  Created by Rafael Escaleira on 11/04/26.
//

import RyzeUI
import SwiftUI

struct SymbolDemoView: View {
    @Environment(\.theme) private var theme

    var body: some View {
        RyzeLazyList {
            // Basic Symbols
            RyzeSection {
                LazyVGrid(
                    columns: [
                        GridItem(.adaptive(minimum: 80), spacing: theme.spacing.medium),
                    ],
                    spacing: theme.spacing.medium
                ) {
                    ForEach(sampleSymbols, id: \.self) { symbol in
                        RyzeVStack(spacing: .small) {
                            RyzeSymbol(symbol)
                                .ryze(font: .title)
                            RyzeFootnoteText(symbol)
                                .lineLimit(1)
                        }
                    }
                }
                .ryzePadding()
            } header: {
                RyzeText("Símbolos Básicos")
                    .ryze(font: .footnote)
                    .ryze(color: .textSecondary)
            }

            // Rendering Modes
            RyzeSection {
                RyzeVStack(spacing: .medium) {
                    RyzeHStack {
                        RyzeVStack {
                            RyzeSymbol("star.fill", mode: .monochrome)
                                .ryze(font: .title)
                            RyzeFootnoteText("Monochrome")
                        }

                        RyzeVStack {
                            RyzeSymbol("star.fill", mode: .hierarchical)
                                .ryze(font: .title)
                            RyzeFootnoteText("Hierarchical")
                        }

                        RyzeVStack {
                            RyzeSymbol("star.fill", mode: .palette)
                                .ryze(font: .title)
                            RyzeFootnoteText("Palette")
                        }
                    }
                }
                .ryzePadding()
            } header: {
                RyzeText("Rendering Modes")
                    .ryze(font: .footnote)
                    .ryze(color: .textSecondary)
            }

            // Symbol Variants
            RyzeSection {
                LazyVGrid(
                    columns: [
                        GridItem(.adaptive(minimum: 60), spacing: theme.spacing.small),
                    ],
                    spacing: theme.spacing.small
                ) {
                    ForEach(symbolVariants, id: \.self) { variant in
                        RyzeVStack(spacing: .small) {
                            RyzeSymbol("square", variants: variant)
                                .ryze(font: .title2)
                            RyzeFootnoteText(variantName(for: variant))
                                .lineLimit(1)
                        }
                    }
                }
                .ryzePadding()
            } header: {
                RyzeText("Symbol Variants")
                    .ryze(font: .footnote)
                    .ryze(color: .textSecondary)
            }

            // Symbol Effects
            RyzeSection {
                RyzeVStack(spacing: .medium) {
                    RyzeHStack {
                        RyzeSymbol("wifi")
                            .ryzeSymbol(
                                effect: .variableColor.cumulative.dimInactiveLayers.reversing
                            )

                        RyzeSymbol("heart")
                            .ryzeSymbol(
                                effect: .pulse.byLayer
                            )

                        RyzeSymbol("bell")
                            .ryzeSymbol(
                                effect: .bounce
                            )
                    }

                    RyzeFootnoteText("Efeitos animados automáticos")
                }
                .ryzePadding()
            } header: {
                RyzeText("Symbol Effects")
                    .ryze(font: .footnote)
                    .ryze(color: .textSecondary)
            }

            // Sizes
            RyzeSection {
                RyzeHStack(alignment: .center, spacing: .medium) {
                    RyzeSymbol("circle.fill")
                        .ryze(font: .caption2)
                    RyzeSymbol("circle.fill")
                        .ryze(font: .caption)
                    RyzeSymbol("circle.fill")
                        .ryze(font: .footnote)
                    RyzeSymbol("circle.fill")
                        .ryze(font: .body)
                    RyzeSymbol("circle.fill")
                        .ryze(font: .title)
                    RyzeSymbol("circle.fill")
                        .ryze(font: .title2)
                    RyzeSymbol("circle.fill")
                        .ryze(font: .title)
                }
                .ryzePadding()
            } header: {
                RyzeText("Tamanhos")
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
                    "SF Symbols oferece mais de 5.000 ícones. Use .hierarchical para ícones com múltiplas cores e .palette para controle preciso. Efeitos animados adicionam feedback visual."
                )
            }
            .ryzePadding()
            .ryzeBackgroundSecondary()
            .ryze(clip: .rounded(radius: 20))
        }
        .navigationTitle("Symbols")
    }

    private let sampleSymbols = [
        "star.fill", "heart.fill", "circle.fill", "square.fill",
        "triangle.fill", "hexagon.fill", "pentagon.fill", "octagon.fill",
        "plus", "minus", "multiply", "divide", "equal",
        "chevron.left", "chevron.right", "chevron.up", "chevron.down",
        "arrow.left", "arrow.right", "arrow.up", "arrow.down",
    ]

    private let symbolVariants: [SymbolVariants] = [
        .none,
        .fill,
        .circle,
        .square,
        .slash,
    ]

    private func variantName(for variant: SymbolVariants) -> String {
        switch variant {
        case .none: "None"
        case .fill: "Fill"
        case .circle: "Circle"
        case .square: "Square"
        case .slash: "Slash"
        default: "Other"
        }
    }
}

#Preview {
    RyzeNavigationView(router: .init()) { (_: PlaygroundRoute) in
        EmptyView()
    } content: {
        SymbolDemoView()
    }
    .ryze(theme: RyzePlaygroundTheme())
}
