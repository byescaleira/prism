//
//  LayoutDemoView.swift
//  PrismPlayground
//
//  Created by Rafael Escaleira on 11/04/26.
//

import PrismUI
import PrismArchitecture
import SwiftUI

struct LayoutDemoView: View {
    @Environment(\.theme) private var theme

    var body: some View {
        PrismLazyList {
            // PrismHStack
            PrismSection {
                PrismVStack(spacing: .medium) {
                    PrismHStack(spacing: .small) {
                        PrismSymbol("star.fill")
                            .prism(color: .primary)
                        PrismText("Item 1")
                        PrismSymbol("star.fill")
                            .prism(color: .primary)
                        PrismText("Item 2")
                    }

                    PrismHStack(alignment: .top, spacing: .medium) {
                        PrismVStack(alignment: .leading) {
                            PrismText("Título")
                                .prism(font: .headline)
                            PrismFootnoteText("Descrição")
                        }
                        PrismSpacer()
                        PrismSymbol("chevron.right")
                    }
                    .prismPadding()
                    .prismBackgroundSecondary()
                    .prism(clip: .rounded(radius: 12))
                }
                .prismPadding()
            } header: {
                PrismText("PrismHStack")
                    .prism(font: .footnote)
                    .prism(color: .textSecondary)
            }

            // PrismVStack
            PrismSection {
                PrismHStack(spacing: .medium) {
                    PrismVStack(alignment: .leading, spacing: .small) {
                        PrismText("Título")
                            .prism(font: .headline)
                        PrismBodyText("Conteúdo do card")
                        PrismFootnoteText("Metadado")
                    }
                    .prismPadding()
                    .prismBackgroundSecondary()
                    .prism(clip: .rounded(radius: 12))

                    PrismVStack(alignment: .trailing, spacing: .small) {
                        PrismText("Direita")
                            .prism(font: .headline)
                        PrismBodyText("Alinhado")
                        PrismFootnoteText("À direita")
                    }
                    .prismPadding()
                    .prismBackgroundSecondary()
                    .prism(clip: .rounded(radius: 12))
                }
                .prismPadding()
            } header: {
                PrismText("PrismVStack")
                    .prism(font: .footnote)
                    .prism(color: .textSecondary)
            }

            // PrismZStack
            PrismSection {
                PrismHStack(spacing: .large) {
                    PrismZStack {
                        PrismShape(shape: .circle)
                            .prism(background: PrismColor.primary)
                            .opacity(0.3)
                            .frame(width: 100, height: 100)

                        PrismSymbol("star.fill")
                            .prism(font: .largeTitle)
                            .prism(color: .primary)
                    }

                    PrismZStack(alignment: .bottomTrailing) {
                        PrismShape.rounded(radius: 12)
                            .prism(background: .secondary)
                            .frame(width: 100, height: 80)

                        PrismSymbol("badge.plus.radioback.fill")
                            .prism(color: PrismColor.warning)
                            .prism(font: .title)
                    }
                }
                .prismPadding()
            } header: {
                PrismText("PrismZStack")
                    .prism(font: .footnote)
                    .prism(color: .textSecondary)
            }

            // Nested Layouts
            PrismSection {
                PrismVStack(alignment: .leading, spacing: .medium) {
                    PrismHStack {
                        PrismShape(shape: .circle)
                            .prism(background: .primary)
                            .frame(width: 50, height: 50)

                        PrismVStack(alignment: .leading, spacing: .small) {
                            PrismText("Nome do Usuário")
                                .prism(font: .headline)
                            PrismFootnoteText("email@exemplo.com")
                        }

                        PrismSpacer()

                        PrismSymbol("chevron.right")
                    }
                    .prismPadding()
                    .prismBackgroundSecondary()
                    .prism(clip: .rounded(radius: 12))

                    PrismHStack(spacing: .medium) {
                        PrismVStack(spacing: .small) {
                            PrismSymbol("heart.fill")
                                .prism(color: .error)
                            PrismFootnoteText("Likes")
                        }
                        .frame(maxWidth: .infinity)
                        .prismPadding(.vertical, .small)
                        .prismBackgroundSecondary()
                        .prism(clip: .rounded(radius: 12))

                        PrismVStack(spacing: .small) {
                            PrismSymbol("star.fill")
                                .prism(color: .warning)
                            PrismFootnoteText("Stars")
                        }
                        .frame(maxWidth: .infinity)
                        .prismPadding(.vertical, .small)
                        .prismBackgroundSecondary()
                        .prism(clip: .rounded(radius: 12))

                        PrismVStack(spacing: .small) {
                            PrismSymbol("bookmark.fill")
                                .prism(color: .info)
                            PrismFootnoteText("Saved")
                        }
                        .frame(maxWidth: .infinity)
                        .prismPadding(.vertical, .small)
                        .prismBackgroundSecondary()
                        .prism(clip: .rounded(radius: 12))
                    }
                }
                .prismPadding()
            } header: {
                PrismText("Layouts Aninhados")
                    .prism(font: .footnote)
                    .prism(color: .textSecondary)
            }

            // Alignment Demo
            PrismSection {
                PrismVStack(alignment: .leading, spacing: .small) {
                    PrismText(".top")
                        .prism(font: .caption)
                    ForEach(0..<3, id: \.self) { _ in
                        PrismHStack(alignment: .top, spacing: .small) {
                            PrismSymbol("circle.fill")
                                .prism(font: .caption)
                            PrismText("Texto")
                                .prism(font: .caption2)
                        }
                        .prismPadding(.horizontal, .small)
                        .prismBackgroundSecondary()
                    }

                    PrismText(".center")
                        .prism(font: .caption)
                    ForEach(0..<3, id: \.self) { _ in
                        PrismHStack(alignment: .center, spacing: .small) {
                            PrismSymbol("circle.fill")
                                .prism(font: .caption)
                            PrismText("Texto")
                                .prism(font: .caption2)
                        }
                        .prismPadding(.horizontal, .small)
                        .prismBackgroundSecondary()
                    }

                    PrismText(".bottom")
                        .prism(font: .caption)
                    ForEach(0..<3, id: \.self) { _ in
                        PrismHStack(alignment: .bottom, spacing: .small) {
                            PrismSymbol("circle.fill")
                                .prism(font: .caption)
                            PrismText("Texto")
                                .prism(font: .caption2)
                        }
                        .prismPadding(.horizontal, .small)
                        .prismBackgroundSecondary()
                    }
                }
                .prismPadding()
            } header: {
                PrismText("Alinhamentos HStack")
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
                    "HStack, VStack e ZStack são wrappers dos containers nativos com espaçamento semântico via PrismSpacing. Use aninhamento para criar layouts complexos mantendo consistência."
                )

                PrismTag("Espaçamento Semântico", style: .info, size: .small)
                PrismTag("Acessibilidade", style: .info, size: .small)
                PrismTag("testID", style: .info, size: .small)
            }
            .prismPadding()
            .prismBackgroundSecondary()
            .prism(clip: .rounded(radius: 20))
        }
        .navigationTitle("Layout")
    }
}

#Preview {
    PrismNavigationView(router: .init()) { (_: PlaygroundRoute) in
        EmptyView()
    } content: {
        LayoutDemoView()
    }
    .prism(theme: PrismPlaygroundTheme())
}
