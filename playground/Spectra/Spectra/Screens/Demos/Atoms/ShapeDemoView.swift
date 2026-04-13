//
//  ShapeDemoView.swift
//  PrismPlayground
//
//  Created by Rafael Escaleira on 11/04/26.
//

import PrismUI
import PrismArchitecture
import SwiftUI

struct ShapeDemoView: View {
    @Environment(\.theme) private var theme

    var body: some View {
        PrismLazyList {
            // Basic Shapes
            PrismSection {
                PrismHStack(spacing: .large) {
                    PrismShape(shape: .circle)
                        .prism(background: .primary)
                        .frame(width: 80, height: 80)

                    PrismShape(shape: .capsule)
                        .prism(background: .secondary)
                        .frame(width: 120, height: 60)

                    PrismShape.rounded(radius: 12)
                        .prism(background: PrismColor.warning)
                        .frame(width: 80, height: 80)
                }
                .prismPadding()
            } header: {
                PrismText("Formas Básicas")
                    .prism(font: .footnote)
                    .prism(color: .textSecondary)
            }

            // As Clip Shape
            PrismSection {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                    ],
                    spacing: theme.spacing.medium
                ) {
                    PrismAsyncImage("https://picsum.photos/200/200")
                        .prism(clip: .circle)

                    PrismAsyncImage("https://picsum.photos/200/200")
                        .prism(clip: .capsule)

                    PrismAsyncImage("https://picsum.photos/200/200")
                        .prism(clip: .rounded(radius: 6))

                    PrismAsyncImage("https://picsum.photos/200/200")
                        .prism(clip: .rounded(radius: 20))
                }
                .prismPadding()
            } header: {
                PrismText("Como Clip Shape")
                    .prism(font: .footnote)
                    .prism(color: .textSecondary)
            }

            // Radius Tokens
            PrismSection {
                PrismHStack(alignment: .center, spacing: .medium) {
                    PrismShape.rounded(radius: 0)
                        .prism(background: .primary)
                        .frame(width: 50, height: 50)

                    PrismShape.rounded(radius: 6)
                        .prism(background: .secondary)
                        .frame(width: 50, height: 50)

                    PrismShape.rounded(radius: 12)
                        .prism(background: PrismColor.warning)
                        .frame(width: 50, height: 50)

                    PrismShape.rounded(radius: 20)
                        .prism(background: PrismColor.primary)
                        .opacity(0.7)
                        .frame(width: 50, height: 50)

                    PrismShape.rounded(radius: 32)
                        .prism(background: PrismColor.secondary)
                        .opacity(0.7)
                        .frame(width: 50, height: 50)

                    PrismShape.rounded(radius: 48)
                        .prism(background: PrismColor.warning)
                        .opacity(0.7)
                        .frame(width: 50, height: 50)
                }
                .prismPadding()
            } header: {
                PrismText("Radius Tokens")
                    .prism(font: .footnote)
                    .prism(color: .textSecondary)
            }

            // Combined with Effects
            PrismSection {
                PrismHStack(spacing: .large) {
                    PrismShape(shape: .circle)
                        .prism(background: .primary)
                        .prismGlow()
                        .frame(width: 80, height: 80)

                    PrismShape.rounded(radius: 12)
                        .prism(background: .secondary)
                        .prismGlow(for: .purple)
                        .frame(width: 80, height: 80)
                }
                .prismPadding()
            } header: {
                PrismText("Com Efeitos")
                    .prism(font: .footnote)
                    .prism(color: .textSecondary)
            }

            // As Background
            PrismSection {
                PrismVStack(spacing: .medium) {
                    PrismText("Circle Background")
                        .prism(font: .headline)
                        .prism(color: .white)
                        .frame(width: 150)
                        .prismBackground()
                        .prism(background: PrismColor.primary)

                    PrismText("Rounded Background")
                        .prism(font: .headline)
                        .prism(color: .white)
                        .frame(width: 150, height: 60)
                        .prismBackground()
                        .prism(background: PrismColor.secondary)
                }
                .prismPadding()
            } header: {
                PrismText("Como Background")
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
                    "PrismShape unifica o uso de formas no Design System. Use com prism(clip:) para recortar views ou prismBackground() para backgrounds. Radius tokens garantem consistência visual."
                )

                PrismTag(".circle", style: .info, size: .small)
                PrismTag(".capsule", style: .info, size: .small)
                PrismTag(".rounded(radius:)", style: .info, size: .small)
            }
            .prismPadding()
            .prismBackgroundSecondary()
            .prism(clip: .rounded(radius: 20))
        }
        .navigationTitle("Shapes")
    }
}

#Preview {
    PrismNavigationView(router: .init()) { (_: PlaygroundRoute) in
        EmptyView()
    } content: {
        ShapeDemoView()
    }
    .prism(theme: PrismPlaygroundTheme())
}
