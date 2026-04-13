//
//  GlowDemoView.swift
//  RyzePlayground
//
//  Created by Rafael Escaleira on 11/04/26.
//

import RyzeUI
import SwiftUI

struct GlowDemoView: View {
    @Environment(\.theme) private var theme

    var body: some View {
        RyzeLazyList {
            // Basic Glow
            RyzeSection {
                RyzeHStack(spacing: .large) {
                    RyzeSymbol("star.fill")
                        .ryze(font: .largeTitle)
                        .ryzeGlow()

                    RyzeSymbol("heart.fill")
                        .ryze(font: .largeTitle)
                        .ryze(color: .error)
                        .ryzeGlow(for: .red)
                }
                .ryzePadding()
            } header: {
                RyzeText("Glow Básico")
                    .ryze(font: .footnote)
                    .ryze(color: .textSecondary)
            }

            // Glow on Shapes
            RyzeSection {
                RyzeHStack(spacing: .large) {
                    RyzeShape(shape: .circle)
                        .ryze(background: .primary)
                        .frame(width: 80, height: 80)
                        .ryzeGlow()

                    RyzeShape.rounded(radius: 12)
                        .ryze(background: .secondary)
                        .frame(width: 80, height: 80)
                        .ryzeGlow(for: .purple)

                    RyzeShape(shape: .capsule)
                        .ryze(background: RyzeColor(rawValue: .init(red: 1, green: 0.4, blue: 0.8)))
                        .frame(width: 120, height: 60)
                        .ryzeGlow(for: .pink)
                }
                .ryzePadding()
            } header: {
                RyzeText("Glow em Formas")
                    .ryze(font: .footnote)
                    .ryze(color: .textSecondary)
            }

            // Glow on Text
            RyzeSection {
                RyzeVStack(spacing: .medium) {
                    RyzeText("Neon Effect")
                        .ryze(font: .largeTitle)
                        .ryze(color: .primary)
                        .ryzeGlow()

                    RyzeText("Purple Glow")
                        .ryze(font: .title)
                        .ryze(color: RyzeColor(rawValue: .purple))
                        .ryzeGlow(for: .purple)

                    RyzeText("Pink Glow")
                        .ryze(font: .title)
                        .ryze(color: RyzeColor(rawValue: .pink))
                        .ryzeGlow(for: .pink)
                }
                .ryzePadding()
            } header: {
                RyzeText("Glow em Texto")
                    .ryze(font: .footnote)
                    .ryze(color: .textSecondary)
            }

            // Glow on Buttons
            RyzeSection {
                RyzeVStack(spacing: .medium) {
                    RyzePrimaryButton("Botão com Glow") {
                        // Action
                    }
                    .ryzeGlow()

                    RyzeSecondaryButton("Glow Personalizado") {
                        // Action
                    }
                    .ryzeGlow(for: .orange)
                }
                .ryzePadding()
            } header: {
                RyzeText("Glow em Botões")
                    .ryze(font: .footnote)
                    .ryze(color: .textSecondary)
            }

            // Combined Effects
            RyzeSection {
                RyzeHStack(spacing: .large) {
                    RyzeZStack {
                        RyzeShape(shape: .circle)
                            .ryze(background: RyzeColor.primary)
                            .opacity(0.2)
                            .frame(width: 100, height: 100)

                        RyzeSymbol("bolt.fill")
                            .ryze(font: .largeTitle)
                            .ryze(color: .primary)
                            .ryzeGlow()
                    }

                    RyzeZStack {
                        RyzeShape(shape: .circle)
                            .ryze(background: RyzeColor.secondary)
                            .opacity(0.2)
                            .frame(width: 100, height: 100)

                        RyzeSymbol("flame.fill")
                            .ryze(font: .largeTitle)
                            .ryze(color: RyzeColor(rawValue: .orange))
                            .ryzeGlow(for: .orange)
                    }
                }
                .ryzePadding()
            } header: {
                RyzeText("Efeitos Combinados")
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
                    "ryzeGlow cria um gradiente angular animado que gira continuamente. Use para destacar elementos importantes, criar efeitos neon, ou indicar estados ativos/destacados."
                )

                RyzeTag("Animado", style: .info, size: .small)
                RyzeTag("Gradiente", style: .info, size: .small)
                RyzeTag("Destaque", style: .info, size: .small)
            }
            .ryzePadding()
            .ryzeBackgroundSecondary()
            .ryze(clip: .rounded(radius: 20))
        }
        .navigationTitle("Glow Effect")
    }
}

#Preview {
    RyzeNavigationView(router: .init()) { (_: PlaygroundRoute) in
        EmptyView()
    } content: {
        GlowDemoView()
    }
    .ryze(theme: RyzePlaygroundTheme())
}
