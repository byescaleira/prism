//
//  GlowDemoView.swift
//  PrismPlayground
//
//  Created by Rafael Escaleira on 11/04/26.
//

import PrismUI
import SwiftUI

struct GlowDemoView: View {
    @Environment(\.theme) private var theme

    var body: some View {
        PrismLazyList {
            // Basic Glow
            PrismSection {
                PrismHStack(spacing: .large) {
                    PrismSymbol("star.fill")
                        .prism(font: .largeTitle)
                        .prismGlow()

                    PrismSymbol("heart.fill")
                        .prism(font: .largeTitle)
                        .prism(color: .error)
                        .prismGlow(for: .red)
                }
                .prismPadding()
            } header: {
                PrismText("Glow Básico")
                    .prism(font: .footnote)
                    .prism(color: .textSecondary)
            }

            // Glow on Shapes
            PrismSection {
                PrismHStack(spacing: .large) {
                    PrismShape(shape: .circle)
                        .prism(background: .primary)
                        .frame(width: 80, height: 80)
                        .prismGlow()

                    PrismShape.rounded(radius: 12)
                        .prism(background: .secondary)
                        .frame(width: 80, height: 80)
                        .prismGlow(for: .purple)

                    PrismShape(shape: .capsule)
                        .prism(background: PrismColor(rawValue: .init(red: 1, green: 0.4, blue: 0.8)))
                        .frame(width: 120, height: 60)
                        .prismGlow(for: .pink)
                }
                .prismPadding()
            } header: {
                PrismText("Glow em Formas")
                    .prism(font: .footnote)
                    .prism(color: .textSecondary)
            }

            // Glow on Text
            PrismSection {
                PrismVStack(spacing: .medium) {
                    PrismText("Neon Effect")
                        .prism(font: .largeTitle)
                        .prism(color: .primary)
                        .prismGlow()

                    PrismText("Purple Glow")
                        .prism(font: .title)
                        .prism(color: PrismColor(rawValue: .purple))
                        .prismGlow(for: .purple)

                    PrismText("Pink Glow")
                        .prism(font: .title)
                        .prism(color: PrismColor(rawValue: .pink))
                        .prismGlow(for: .pink)
                }
                .prismPadding()
            } header: {
                PrismText("Glow em Texto")
                    .prism(font: .footnote)
                    .prism(color: .textSecondary)
            }

            // Glow on Buttons
            PrismSection {
                PrismVStack(spacing: .medium) {
                    PrismPrimaryButton("Botão com Glow") {
                        // Action
                    }
                    .prismGlow()

                    PrismSecondaryButton("Glow Personalizado") {
                        // Action
                    }
                    .prismGlow(for: .orange)
                }
                .prismPadding()
            } header: {
                PrismText("Glow em Botões")
                    .prism(font: .footnote)
                    .prism(color: .textSecondary)
            }

            // Combined Effects
            PrismSection {
                PrismHStack(spacing: .large) {
                    PrismZStack {
                        PrismShape(shape: .circle)
                            .prism(background: PrismColor.primary)
                            .opacity(0.2)
                            .frame(width: 100, height: 100)

                        PrismSymbol("bolt.fill")
                            .prism(font: .largeTitle)
                            .prism(color: .primary)
                            .prismGlow()
                    }

                    PrismZStack {
                        PrismShape(shape: .circle)
                            .prism(background: PrismColor.secondary)
                            .opacity(0.2)
                            .frame(width: 100, height: 100)

                        PrismSymbol("flame.fill")
                            .prism(font: .largeTitle)
                            .prism(color: PrismColor(rawValue: .orange))
                            .prismGlow(for: .orange)
                    }
                }
                .prismPadding()
            } header: {
                PrismText("Efeitos Combinados")
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
                    "prismGlow cria um gradiente angular animado que gira continuamente. Use para destacar elementos importantes, criar efeitos neon, ou indicar estados ativos/destacados."
                )

                PrismTag("Animado", style: .info, size: .small)
                PrismTag("Gradiente", style: .info, size: .small)
                PrismTag("Destaque", style: .info, size: .small)
            }
            .prismPadding()
            .prismBackgroundSecondary()
            .prism(clip: .rounded(radius: 20))
        }
        .navigationTitle("Glow Effect")
    }
}

#Preview {
    PrismNavigationView(router: .init()) { (_: PlaygroundRoute) in
        EmptyView()
    } content: {
        GlowDemoView()
    }
    .prism(theme: PrismPlaygroundTheme())
}
