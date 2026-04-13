//
//  SpacerDemoView.swift
//  RyzePlayground
//
//  Created by Rafael Escaleira on 11/04/26.
//

import RyzeUI
import SwiftUI

struct SpacerDemoView: View {
    @Environment(\.theme) private var theme

    var body: some View {
        RyzeLazyList {
            // Basic Spacer
            RyzeSection {
                RyzeHStack {
                    RyzeSymbol("square.fill")
                        .ryze(color: .primary)

                    RyzeSpacer()

                    RyzeSymbol("square.fill")
                        .ryze(color: .secondary)
                }
                .frame(height: 60)
                .ryzeBackgroundSecondary()
                .ryzePadding()
            } header: {
                RyzeText("Spacer Básico")
                    .ryze(font: .footnote)
                    .ryze(color: .textSecondary)
            }

            // Spacer with Size
            RyzeSection {
                RyzeVStack(alignment: .leading, spacing: .medium) {
                    RyzeHStack {
                        RyzeText("Zero")
                        RyzeSpacer(size: .zero)
                        RyzeSymbol("square.fill")
                    }
                    .frame(height: 40)
                    .ryzeBackgroundSecondary()

                    RyzeHStack {
                        RyzeText("Small")
                        RyzeSpacer(size: .small)
                        RyzeSymbol("square.fill")
                    }
                    .frame(height: 40)
                    .ryzeBackgroundSecondary()

                    RyzeHStack {
                        RyzeText("Medium")
                        RyzeSpacer(size: .medium)
                        RyzeSymbol("square.fill")
                    }
                    .frame(height: 40)
                    .ryzeBackgroundSecondary()

                    RyzeHStack {
                        RyzeText("Large")
                        RyzeSpacer(size: .large)
                        RyzeSymbol("square.fill")
                    }
                    .frame(height: 40)
                    .ryzeBackgroundSecondary()

                    RyzeHStack {
                        RyzeText("Extra Large")
                        RyzeSpacer(size: .extraLarge)
                        RyzeSymbol("square.fill")
                    }
                    .frame(height: 40)
                    .ryzeBackgroundSecondary()
                }
                .ryzePadding()
            } header: {
                RyzeText("Spacer com Tamanho")
                    .ryze(font: .footnote)
                    .ryze(color: .textSecondary)
            }

            // Vertical Spacer
            RyzeSection {
                RyzeVStack {
                    RyzeSymbol("square.fill")
                        .ryze(color: .primary)

                    RyzeSpacer(size: .medium)

                    RyzeSymbol("square.fill")
                        .ryze(color: .secondary)

                    RyzeSpacer(size: .large)

                    RyzeSymbol("square.fill")
                        .ryze(color: RyzeColor.warning)
                }
                .frame(height: 300)
                .ryzeBackgroundSecondary()
                .ryzePadding()
            } header: {
                RyzeText("Spacer Vertical")
                    .ryze(font: .footnote)
                    .ryze(color: .textSecondary)
            }

            // In Forms
            RyzeSection {
                RyzeVStack(spacing: .medium) {
                    RyzeHStack {
                        RyzeLabel("Email", symbol: "envelope")
                            .frame(width: 100, alignment: .leading)
                        RyzeSpacer()
                        RyzeText("usuario@exemplo.com")
                            .ryze(color: .textSecondary)
                    }

                    RyzeHStack {
                        RyzeLabel("Telefone", symbol: "phone")
                            .frame(width: 100, alignment: .leading)
                        RyzeSpacer()
                        RyzeText("(11) 99999-9999")
                            .ryze(color: .textSecondary)
                    }

                    RyzeHStack {
                        RyzeLabel("Endereço", symbol: "location")
                            .frame(width: 100, alignment: .leading)
                        RyzeSpacer()
                        RyzeText("São Paulo, SP")
                            .ryze(color: .textSecondary)
                    }
                }
                .ryzePadding()
                .ryzeBackgroundSecondary()
                .ryze(clip: .rounded(radius: 12))
            } header: {
                RyzeText("Em Formulários")
                    .ryze(font: .footnote)
                    .ryze(color: .textSecondary)
            }

            // Push to Edges
            RyzeSection {
                RyzeVStack {
                    RyzeHStack {
                        RyzeSymbol("arrow.left")
                        RyzeSpacer()
                        RyzeText("Título")
                        RyzeSpacer()
                        RyzeSymbol("arrow.right")
                    }

                    RyzeSpacer()

                    RyzeHStack {
                        RyzePrimaryButton("Cancelar", testID: "cancel_button") {}
                        RyzeSpacer(size: .medium)
                        RyzePrimaryButton("Confirmar", testID: "confirm_button") {}
                    }
                }
                .frame(height: 200)
                .ryzeBackgroundSecondary()
                .ryzePadding()
            } header: {
                RyzeText("Push para Bordas")
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
                    "RyzeSpacer usa tokens semânticos de spacing para consistência. Diferente do Spacer nativo, permite definir tamanhos específicos usando o sistema de tokens do Design System."
                )

                RyzeTag("Spacing Tokens", style: .info, size: .small)
                RyzeTag("Consistência", style: .info, size: .small)
            }
            .ryzePadding()
            .ryzeBackgroundSecondary()
            .ryze(clip: .rounded(radius: 20))
        }
        .navigationTitle("Spacer")
    }
}

#Preview {
    RyzeNavigationView(router: .init()) { (_: PlaygroundRoute) in
        EmptyView()
    } content: {
        SpacerDemoView()
    }
    .ryze(theme: RyzePlaygroundTheme())
}
