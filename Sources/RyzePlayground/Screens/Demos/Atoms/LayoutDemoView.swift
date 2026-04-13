//
//  LayoutDemoView.swift
//  RyzePlayground
//
//  Created by Rafael Escaleira on 11/04/26.
//

import RyzeUI
import SwiftUI

struct LayoutDemoView: View {
    @Environment(\.theme) private var theme

    var body: some View {
        RyzeLazyList {
            // RyzeHStack
            RyzeSection {
                RyzeVStack(spacing: .medium) {
                    RyzeHStack(spacing: .small) {
                        RyzeSymbol("star.fill")
                            .ryze(color: .primary)
                        RyzeText("Item 1")
                        RyzeSymbol("star.fill")
                            .ryze(color: .primary)
                        RyzeText("Item 2")
                    }

                    RyzeHStack(alignment: .top, spacing: .medium) {
                        RyzeVStack(alignment: .leading) {
                            RyzeText("Título")
                                .ryze(font: .headline)
                            RyzeFootnoteText("Descrição")
                        }
                        RyzeSpacer()
                        RyzeSymbol("chevron.right")
                    }
                    .ryzePadding()
                    .ryzeBackgroundSecondary()
                    .ryze(clip: .rounded(radius: 12))
                }
                .ryzePadding()
            } header: {
                RyzeText("RyzeHStack")
                    .ryze(font: .footnote)
                    .ryze(color: .textSecondary)
            }

            // RyzeVStack
            RyzeSection {
                RyzeHStack(spacing: .medium) {
                    RyzeVStack(alignment: .leading, spacing: .small) {
                        RyzeText("Título")
                            .ryze(font: .headline)
                        RyzeBodyText("Conteúdo do card")
                        RyzeFootnoteText("Metadado")
                    }
                    .ryzePadding()
                    .ryzeBackgroundSecondary()
                    .ryze(clip: .rounded(radius: 12))

                    RyzeVStack(alignment: .trailing, spacing: .small) {
                        RyzeText("Direita")
                            .ryze(font: .headline)
                        RyzeBodyText("Alinhado")
                        RyzeFootnoteText("À direita")
                    }
                    .ryzePadding()
                    .ryzeBackgroundSecondary()
                    .ryze(clip: .rounded(radius: 12))
                }
                .ryzePadding()
            } header: {
                RyzeText("RyzeVStack")
                    .ryze(font: .footnote)
                    .ryze(color: .textSecondary)
            }

            // RyzeZStack
            RyzeSection {
                RyzeHStack(spacing: .large) {
                    RyzeZStack {
                        RyzeShape(shape: .circle)
                            .ryze(background: RyzeColor.primary)
                            .opacity(0.3)
                            .frame(width: 100, height: 100)

                        RyzeSymbol("star.fill")
                            .ryze(font: .largeTitle)
                            .ryze(color: .primary)
                    }

                    RyzeZStack(alignment: .bottomTrailing) {
                        RyzeShape.rounded(radius: 12)
                            .ryze(background: .secondary)
                            .frame(width: 100, height: 80)

                        RyzeSymbol("badge.plus.radioback.fill")
                            .ryze(color: RyzeColor.warning)
                            .ryze(font: .title)
                    }
                }
                .ryzePadding()
            } header: {
                RyzeText("RyzeZStack")
                    .ryze(font: .footnote)
                    .ryze(color: .textSecondary)
            }

            // Nested Layouts
            RyzeSection {
                RyzeVStack(alignment: .leading, spacing: .medium) {
                    RyzeHStack {
                        RyzeShape(shape: .circle)
                            .ryze(background: .primary)
                            .frame(width: 50, height: 50)

                        RyzeVStack(alignment: .leading, spacing: .small) {
                            RyzeText("Nome do Usuário")
                                .ryze(font: .headline)
                            RyzeFootnoteText("email@exemplo.com")
                        }

                        RyzeSpacer()

                        RyzeSymbol("chevron.right")
                    }
                    .ryzePadding()
                    .ryzeBackgroundSecondary()
                    .ryze(clip: .rounded(radius: 12))

                    RyzeHStack(spacing: .medium) {
                        RyzeVStack(spacing: .small) {
                            RyzeSymbol("heart.fill")
                                .ryze(color: .error)
                            RyzeFootnoteText("Likes")
                        }
                        .frame(maxWidth: .infinity)
                        .ryzePadding(.vertical, .small)
                        .ryzeBackgroundSecondary()
                        .ryze(clip: .rounded(radius: 12))

                        RyzeVStack(spacing: .small) {
                            RyzeSymbol("star.fill")
                                .ryze(color: .warning)
                            RyzeFootnoteText("Stars")
                        }
                        .frame(maxWidth: .infinity)
                        .ryzePadding(.vertical, .small)
                        .ryzeBackgroundSecondary()
                        .ryze(clip: .rounded(radius: 12))

                        RyzeVStack(spacing: .small) {
                            RyzeSymbol("bookmark.fill")
                                .ryze(color: .info)
                            RyzeFootnoteText("Saved")
                        }
                        .frame(maxWidth: .infinity)
                        .ryzePadding(.vertical, .small)
                        .ryzeBackgroundSecondary()
                        .ryze(clip: .rounded(radius: 12))
                    }
                }
                .ryzePadding()
            } header: {
                RyzeText("Layouts Aninhados")
                    .ryze(font: .footnote)
                    .ryze(color: .textSecondary)
            }

            // Alignment Demo
            RyzeSection {
                RyzeVStack(alignment: .leading, spacing: .small) {
                    RyzeText(".top")
                        .ryze(font: .caption)
                    ForEach(0..<3, id: \.self) { _ in
                        RyzeHStack(alignment: .top, spacing: .small) {
                            RyzeSymbol("circle.fill")
                                .ryze(font: .caption)
                            RyzeText("Texto")
                                .ryze(font: .caption2)
                        }
                        .ryzePadding(.horizontal, .small)
                        .ryzeBackgroundSecondary()
                    }

                    RyzeText(".center")
                        .ryze(font: .caption)
                    ForEach(0..<3, id: \.self) { _ in
                        RyzeHStack(alignment: .center, spacing: .small) {
                            RyzeSymbol("circle.fill")
                                .ryze(font: .caption)
                            RyzeText("Texto")
                                .ryze(font: .caption2)
                        }
                        .ryzePadding(.horizontal, .small)
                        .ryzeBackgroundSecondary()
                    }

                    RyzeText(".bottom")
                        .ryze(font: .caption)
                    ForEach(0..<3, id: \.self) { _ in
                        RyzeHStack(alignment: .bottom, spacing: .small) {
                            RyzeSymbol("circle.fill")
                                .ryze(font: .caption)
                            RyzeText("Texto")
                                .ryze(font: .caption2)
                        }
                        .ryzePadding(.horizontal, .small)
                        .ryzeBackgroundSecondary()
                    }
                }
                .ryzePadding()
            } header: {
                RyzeText("Alinhamentos HStack")
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
                    "HStack, VStack e ZStack são wrappers dos containers nativos com espaçamento semântico via RyzeSpacing. Use aninhamento para criar layouts complexos mantendo consistência."
                )

                RyzeTag("Espaçamento Semântico", style: .info, size: .small)
                RyzeTag("Acessibilidade", style: .info, size: .small)
                RyzeTag("testID", style: .info, size: .small)
            }
            .ryzePadding()
            .ryzeBackgroundSecondary()
            .ryze(clip: .rounded(radius: 20))
        }
        .navigationTitle("Layout")
    }
}

#Preview {
    RyzeNavigationView(router: .init()) { (_: PlaygroundRoute) in
        EmptyView()
    } content: {
        LayoutDemoView()
    }
    .ryze(theme: RyzePlaygroundTheme())
}
