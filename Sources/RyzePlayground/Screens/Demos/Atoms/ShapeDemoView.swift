//
//  ShapeDemoView.swift
//  RyzePlayground
//
//  Created by Rafael Escaleira on 11/04/26.
//

import RyzeUI
import SwiftUI

struct ShapeDemoView: View {
    @Environment(\.theme) private var theme

    var body: some View {
        RyzeLazyList {
            // Basic Shapes
            RyzeSection {
                RyzeHStack(spacing: .large) {
                    RyzeShape(shape: .circle)
                        .ryze(background: .primary)
                        .frame(width: 80, height: 80)

                    RyzeShape(shape: .capsule)
                        .ryze(background: .secondary)
                        .frame(width: 120, height: 60)

                    RyzeShape.rounded(radius: 12)
                        .ryze(background: RyzeColor.warning)
                        .frame(width: 80, height: 80)
                }
                .ryzePadding()
            } header: {
                RyzeText("Formas Básicas")
                    .ryze(font: .footnote)
                    .ryze(color: .textSecondary)
            }

            // As Clip Shape
            RyzeSection {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                    ],
                    spacing: theme.spacing.medium
                ) {
                    RyzeAsyncImage("https://picsum.photos/200/200")
                        .ryze(clip: .circle)

                    RyzeAsyncImage("https://picsum.photos/200/200")
                        .ryze(clip: .capsule)

                    RyzeAsyncImage("https://picsum.photos/200/200")
                        .ryze(clip: .rounded(radius: 6))

                    RyzeAsyncImage("https://picsum.photos/200/200")
                        .ryze(clip: .rounded(radius: 20))
                }
                .ryzePadding()
            } header: {
                RyzeText("Como Clip Shape")
                    .ryze(font: .footnote)
                    .ryze(color: .textSecondary)
            }

            // Radius Tokens
            RyzeSection {
                RyzeHStack(alignment: .center, spacing: .medium) {
                    RyzeShape.rounded(radius: 0)
                        .ryze(background: .primary)
                        .frame(width: 50, height: 50)

                    RyzeShape.rounded(radius: 6)
                        .ryze(background: .secondary)
                        .frame(width: 50, height: 50)

                    RyzeShape.rounded(radius: 12)
                        .ryze(background: RyzeColor.warning)
                        .frame(width: 50, height: 50)

                    RyzeShape.rounded(radius: 20)
                        .ryze(background: RyzeColor.primary)
                        .opacity(0.7)
                        .frame(width: 50, height: 50)

                    RyzeShape.rounded(radius: 32)
                        .ryze(background: RyzeColor.secondary)
                        .opacity(0.7)
                        .frame(width: 50, height: 50)

                    RyzeShape.rounded(radius: 48)
                        .ryze(background: RyzeColor.warning)
                        .opacity(0.7)
                        .frame(width: 50, height: 50)
                }
                .ryzePadding()
            } header: {
                RyzeText("Radius Tokens")
                    .ryze(font: .footnote)
                    .ryze(color: .textSecondary)
            }

            // Combined with Effects
            RyzeSection {
                RyzeHStack(spacing: .large) {
                    RyzeShape(shape: .circle)
                        .ryze(background: .primary)
                        .ryzeGlow()
                        .frame(width: 80, height: 80)

                    RyzeShape.rounded(radius: 12)
                        .ryze(background: .secondary)
                        .ryzeGlow(for: .purple)
                        .frame(width: 80, height: 80)
                }
                .ryzePadding()
            } header: {
                RyzeText("Com Efeitos")
                    .ryze(font: .footnote)
                    .ryze(color: .textSecondary)
            }

            // As Background
            RyzeSection {
                RyzeVStack(spacing: .medium) {
                    RyzeText("Circle Background")
                        .ryze(font: .headline)
                        .ryze(color: .white)
                        .frame(width: 150)
                        .ryzeBackground()
                        .ryze(background: RyzeColor.primary)

                    RyzeText("Rounded Background")
                        .ryze(font: .headline)
                        .ryze(color: .white)
                        .frame(width: 150, height: 60)
                        .ryzeBackground()
                        .ryze(background: RyzeColor.secondary)
                }
                .ryzePadding()
            } header: {
                RyzeText("Como Background")
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
                    "RyzeShape unifica o uso de formas no Design System. Use com ryze(clip:) para recortar views ou ryzeBackground() para backgrounds. Radius tokens garantem consistência visual."
                )

                RyzeTag(".circle", style: .info, size: .small)
                RyzeTag(".capsule", style: .info, size: .small)
                RyzeTag(".rounded(radius:)", style: .info, size: .small)
            }
            .ryzePadding()
            .ryzeBackgroundSecondary()
            .ryze(clip: .rounded(radius: 20))
        }
        .navigationTitle("Shapes")
    }
}

#Preview {
    RyzeNavigationView(router: .init()) { (_: PlaygroundRoute) in
        EmptyView()
    } content: {
        ShapeDemoView()
    }
    .ryze(theme: RyzePlaygroundTheme())
}
