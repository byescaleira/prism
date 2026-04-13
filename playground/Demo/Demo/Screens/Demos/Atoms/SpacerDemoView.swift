//
//  SpacerDemoView.swift
//  PrismPlayground
//
//  Created by Rafael Escaleira on 11/04/26.
//

import PrismUI
import SwiftUI

struct SpacerDemoView: View {
    @Environment(\.theme) private var theme

    var body: some View {
        PrismLazyList {
            // Basic Spacer
            PrismSection {
                PrismHStack {
                    PrismSymbol("square.fill")
                        .prism(color: .primary)

                    PrismSpacer()

                    PrismSymbol("square.fill")
                        .prism(color: .secondary)
                }
                .frame(height: 60)
                .prismBackgroundSecondary()
                .prismPadding()
            } header: {
                PrismText("Spacer Básico")
                    .prism(font: .footnote)
                    .prism(color: .textSecondary)
            }

            // Spacer with Size
            PrismSection {
                PrismVStack(alignment: .leading, spacing: .medium) {
                    PrismHStack {
                        PrismText("Zero")
                        PrismSpacer(size: .zero)
                        PrismSymbol("square.fill")
                    }
                    .frame(height: 40)
                    .prismBackgroundSecondary()

                    PrismHStack {
                        PrismText("Small")
                        PrismSpacer(size: .small)
                        PrismSymbol("square.fill")
                    }
                    .frame(height: 40)
                    .prismBackgroundSecondary()

                    PrismHStack {
                        PrismText("Medium")
                        PrismSpacer(size: .medium)
                        PrismSymbol("square.fill")
                    }
                    .frame(height: 40)
                    .prismBackgroundSecondary()

                    PrismHStack {
                        PrismText("Large")
                        PrismSpacer(size: .large)
                        PrismSymbol("square.fill")
                    }
                    .frame(height: 40)
                    .prismBackgroundSecondary()

                    PrismHStack {
                        PrismText("Extra Large")
                        PrismSpacer(size: .extraLarge)
                        PrismSymbol("square.fill")
                    }
                    .frame(height: 40)
                    .prismBackgroundSecondary()
                }
                .prismPadding()
            } header: {
                PrismText("Spacer com Tamanho")
                    .prism(font: .footnote)
                    .prism(color: .textSecondary)
            }

            // Vertical Spacer
            PrismSection {
                PrismVStack {
                    PrismSymbol("square.fill")
                        .prism(color: .primary)

                    PrismSpacer(size: .medium)

                    PrismSymbol("square.fill")
                        .prism(color: .secondary)

                    PrismSpacer(size: .large)

                    PrismSymbol("square.fill")
                        .prism(color: PrismColor.warning)
                }
                .frame(height: 300)
                .prismBackgroundSecondary()
                .prismPadding()
            } header: {
                PrismText("Spacer Vertical")
                    .prism(font: .footnote)
                    .prism(color: .textSecondary)
            }

            // In Forms
            PrismSection {
                PrismVStack(spacing: .medium) {
                    PrismHStack {
                        PrismLabel("Email", symbol: "envelope")
                            .frame(width: 100, alignment: .leading)
                        PrismSpacer()
                        PrismText("usuario@exemplo.com")
                            .prism(color: .textSecondary)
                    }

                    PrismHStack {
                        PrismLabel("Telefone", symbol: "phone")
                            .frame(width: 100, alignment: .leading)
                        PrismSpacer()
                        PrismText("(11) 99999-9999")
                            .prism(color: .textSecondary)
                    }

                    PrismHStack {
                        PrismLabel("Endereço", symbol: "location")
                            .frame(width: 100, alignment: .leading)
                        PrismSpacer()
                        PrismText("São Paulo, SP")
                            .prism(color: .textSecondary)
                    }
                }
                .prismPadding()
                .prismBackgroundSecondary()
                .prism(clip: .rounded(radius: 12))
            } header: {
                PrismText("Em Formulários")
                    .prism(font: .footnote)
                    .prism(color: .textSecondary)
            }

            // Push to Edges
            PrismSection {
                PrismVStack {
                    PrismHStack {
                        PrismSymbol("arrow.left")
                        PrismSpacer()
                        PrismText("Título")
                        PrismSpacer()
                        PrismSymbol("arrow.right")
                    }

                    PrismSpacer()

                    PrismHStack {
                        PrismPrimaryButton("Cancelar", testID: "cancel_button") {}
                        PrismSpacer(size: .medium)
                        PrismPrimaryButton("Confirmar", testID: "confirm_button") {}
                    }
                }
                .frame(height: 200)
                .prismBackgroundSecondary()
                .prismPadding()
            } header: {
                PrismText("Push para Bordas")
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
                    "PrismSpacer usa tokens semânticos de spacing para consistência. Diferente do Spacer nativo, permite definir tamanhos específicos usando o sistema de tokens do Design System."
                )

                PrismTag("Spacing Tokens", style: .info, size: .small)
                PrismTag("Consistência", style: .info, size: .small)
            }
            .prismPadding()
            .prismBackgroundSecondary()
            .prism(clip: .rounded(radius: 20))
        }
        .navigationTitle("Spacer")
    }
}

#Preview {
    PrismNavigationView(router: .init()) { (_: PlaygroundRoute) in
        EmptyView()
    } content: {
        SpacerDemoView()
    }
    .prism(theme: PrismPlaygroundTheme())
}
