//
//  ButtonDemoView.swift
//  PrismPlayground
//
//  Created by Rafael Escaleira on 11/04/26.
//

import PrismIntelligence
import PrismUI
import SwiftUI

struct ButtonDemoView: View {
    @Environment(\.theme) private var theme
    @State private var isToggleOn = false
    @State private var showSheet = false
    @State private var isLoading = false

    var body: some View {
        PrismLazyList {
            // Basic Usage
            PrismSection {
                PrismVStack(spacing: .medium) {
                    PrismButton("Clique aqui", testID: "toggle_button") {
                        isToggleOn.toggle()
                    }

                    PrismFootnoteText("Estado: \(isToggleOn ? "Ativado" : "Desativado")")
                }
                .prismPadding()
            } header: {
                PrismText("Uso Básico")
                    .prism(font: .footnote)
                    .prism(color: .textSecondary)
            }

            // PrismButton Styles
            PrismSection {
                PrismVStack(spacing: .medium) {
                    PrismHStack {
                        PrismButton("Default", testID: "default_button") {}
                        PrismButton("Disabled", testID: "disabled_button") {}
                            .disabled(true)
                    }
                }
                .prismPadding()
            } header: {
                PrismText("PrismButton")
                    .prism(font: .footnote)
                    .prism(color: .textSecondary)
            }

            // PrismPrimaryButton
            PrismSection {
                PrismVStack(spacing: .medium) {
                    PrismPrimaryButton("Ação Principal", testID: "primary_button") {
                        isLoading = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            isLoading = false
                        }
                    }
                    .disabled(isLoading)

                    PrismPrimaryButton("Destrutivo", testID: "destructive_button", role: .destructive) {
                        showSheet = true
                    }

                    PrismPrimaryButton("Cancelar", testID: "cancel_button", role: .cancel) {}
                }
                .prismPadding()
            } header: {
                PrismText("PrismPrimaryButton")
                    .prism(font: .footnote)
                    .prism(color: .textSecondary)
            }

            // PrismSecondaryButton
            PrismSection {
                PrismVStack(spacing: .medium) {
                    PrismSecondaryButton("Ação Secundária", testID: "secondary_button") {}

                    PrismSecondaryButton("Destrutivo", testID: "secondary_destructive_button", role: .destructive) {}

                    PrismSecondaryButton("Cancelar", testID: "secondary_cancel_button", role: .cancel) {}
                }
                .prismPadding()
            } header: {
                PrismText("PrismSecondaryButton")
                    .prism(font: .footnote)
                    .prism(color: .textSecondary)
            }

            // Intelligence Section
            PrismVStack(alignment: .leading, spacing: .medium) {
                PrismHStack(spacing: .small) {
                    PrismSymbol("brain.headset", mode: .hierarchical)
                        .prism(color: .primary)

                    PrismText("Intelligence")
                        .prism(font: .headline)
                }

                PrismBodyText(
                    "Botões no PrismUI seguem princípios de acessibilidade e oferecem feedback tátil (haptic) no iOS. Use PrismPrimaryButton para a ação principal (CTA) e PrismSecondaryButton para ações secundárias."
                )

                PrismTag("Acessibilidade", style: .info, size: .small)
                PrismTag("Haptic Feedback", style: .info, size: .small)
                PrismTag("testID", style: .info, size: .small)
            }
            .prismPadding()
            .prismBackgroundSecondary()
            .prism(clip: .rounded(radius: 20))
        }
        .navigationTitle("Buttons")
        .sheet(isPresented: $showSheet) {
            PrismVStack(spacing: .medium) {
                PrismText("Ação destrutiva confirmada!")
                PrismPrimaryButton("OK") {
                    showSheet = false
                }
            }
            .prismPadding()
        }
    }
}

#Preview {
    PrismNavigationView(router: .init()) { (_: PlaygroundRoute) in
        EmptyView()
    } content: {
        ButtonDemoView()
    }
    .prism(theme: PrismPlaygroundTheme())
}
