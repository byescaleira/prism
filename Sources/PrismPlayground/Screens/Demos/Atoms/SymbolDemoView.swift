//
//  SymbolDemoView.swift
//  PrismPlayground
//
//  Created by Rafael Escaleira on 11/04/26.
//

import PrismUI
import SwiftUI

struct SymbolDemoView: View {
    @Environment(\.theme) private var theme

    var body: some View {
        PrismLazyList {
            // Basic Symbols
            PrismSection {
                LazyVGrid(
                    columns: [
                        GridItem(.adaptive(minimum: 80), spacing: theme.spacing.medium),
                    ],
                    spacing: theme.spacing.medium
                ) {
                    ForEach(sampleSymbols, id: \.self) { symbol in
                        PrismVStack(spacing: .small) {
                            PrismSymbol(symbol)
                                .prism(font: .title)
                            PrismFootnoteText(symbol)
                                .lineLimit(1)
                        }
                    }
                }
                .prismPadding()
            } header: {
                PrismText("Símbolos Básicos")
                    .prism(font: .footnote)
                    .prism(color: .textSecondary)
            }

            // Rendering Modes
            PrismSection {
                PrismVStack(spacing: .medium) {
                    PrismHStack {
                        PrismVStack {
                            PrismSymbol("star.fill", mode: .monochrome)
                                .prism(font: .title)
                            PrismFootnoteText("Monochrome")
                        }

                        PrismVStack {
                            PrismSymbol("star.fill", mode: .hierarchical)
                                .prism(font: .title)
                            PrismFootnoteText("Hierarchical")
                        }

                        PrismVStack {
                            PrismSymbol("star.fill", mode: .palette)
                                .prism(font: .title)
                            PrismFootnoteText("Palette")
                        }
                    }
                }
                .prismPadding()
            } header: {
                PrismText("Rendering Modes")
                    .prism(font: .footnote)
                    .prism(color: .textSecondary)
            }

            // Symbol Variants
            PrismSection {
                LazyVGrid(
                    columns: [
                        GridItem(.adaptive(minimum: 60), spacing: theme.spacing.small),
                    ],
                    spacing: theme.spacing.small
                ) {
                    ForEach(symbolVariants, id: \.self) { variant in
                        PrismVStack(spacing: .small) {
                            PrismSymbol("square", variants: variant)
                                .prism(font: .title2)
                            PrismFootnoteText(variantName(for: variant))
                                .lineLimit(1)
                        }
                    }
                }
                .prismPadding()
            } header: {
                PrismText("Symbol Variants")
                    .prism(font: .footnote)
                    .prism(color: .textSecondary)
            }

            // Symbol Effects
            PrismSection {
                PrismVStack(spacing: .medium) {
                    PrismHStack {
                        PrismSymbol("wifi")
                            .prismSymbol(
                                effect: .variableColor.cumulative.dimInactiveLayers.reversing
                            )

                        PrismSymbol("heart")
                            .prismSymbol(
                                effect: .pulse.byLayer
                            )

                        PrismSymbol("bell")
                            .prismSymbol(
                                effect: .bounce
                            )
                    }

                    PrismFootnoteText("Efeitos animados automáticos")
                }
                .prismPadding()
            } header: {
                PrismText("Symbol Effects")
                    .prism(font: .footnote)
                    .prism(color: .textSecondary)
            }

            // Sizes
            PrismSection {
                PrismHStack(alignment: .center, spacing: .medium) {
                    PrismSymbol("circle.fill")
                        .prism(font: .caption2)
                    PrismSymbol("circle.fill")
                        .prism(font: .caption)
                    PrismSymbol("circle.fill")
                        .prism(font: .footnote)
                    PrismSymbol("circle.fill")
                        .prism(font: .body)
                    PrismSymbol("circle.fill")
                        .prism(font: .title)
                    PrismSymbol("circle.fill")
                        .prism(font: .title2)
                    PrismSymbol("circle.fill")
                        .prism(font: .title)
                }
                .prismPadding()
            } header: {
                PrismText("Tamanhos")
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
                    "SF Symbols oferece mais de 5.000 ícones. Use .hierarchical para ícones com múltiplas cores e .palette para controle preciso. Efeitos animados adicionam feedback visual."
                )
            }
            .prismPadding()
            .prismBackgroundSecondary()
            .prism(clip: .rounded(radius: 20))
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
    PrismNavigationView(router: .init()) { (_: PlaygroundRoute) in
        EmptyView()
    } content: {
        SymbolDemoView()
    }
    .prism(theme: PrismPlaygroundTheme())
}
