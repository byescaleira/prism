//
//  ButtonDemoView.swift
//  RyzePlayground
//
//  Created by Rafael Escaleira on 11/04/26.
//

import RyzeIntelligence
import RyzeUI
import SwiftUI

struct ButtonDemoView: View {
    @Environment(\.theme) private var theme
    @State private var isToggleOn = false
    @State private var showSheet = false
    @State private var isLoading = false

    var body: some View {
        RyzeLazyList {
            // Basic Usage
            RyzeSection {
                RyzeVStack(spacing: .medium) {
                    RyzeButton("Clique aqui", testID: "toggle_button") {
                        isToggleOn.toggle()
                    }

                    RyzeFootnoteText("Estado: \(isToggleOn ? "Ativado" : "Desativado")")
                }
                .ryzePadding()
            } header: {
                RyzeText("Uso Básico")
                    .ryze(font: .footnote)
                    .ryze(color: .textSecondary)
            }

            // RyzeButton Styles
            RyzeSection {
                RyzeVStack(spacing: .medium) {
                    RyzeHStack {
                        RyzeButton("Default", testID: "default_button") {}
                        RyzeButton("Disabled", testID: "disabled_button") {}
                            .disabled(true)
                    }
                }
                .ryzePadding()
            } header: {
                RyzeText("RyzeButton")
                    .ryze(font: .footnote)
                    .ryze(color: .textSecondary)
            }

            // RyzePrimaryButton
            RyzeSection {
                RyzeVStack(spacing: .medium) {
                    RyzePrimaryButton("Ação Principal", testID: "primary_button") {
                        isLoading = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            isLoading = false
                        }
                    }
                    .disabled(isLoading)

                    RyzePrimaryButton("Destrutivo", testID: "destructive_button", role: .destructive) {
                        showSheet = true
                    }

                    RyzePrimaryButton("Cancelar", testID: "cancel_button", role: .cancel) {}
                }
                .ryzePadding()
            } header: {
                RyzeText("RyzePrimaryButton")
                    .ryze(font: .footnote)
                    .ryze(color: .textSecondary)
            }

            // RyzeSecondaryButton
            RyzeSection {
                RyzeVStack(spacing: .medium) {
                    RyzeSecondaryButton("Ação Secundária", testID: "secondary_button") {}

                    RyzeSecondaryButton("Destrutivo", testID: "secondary_destructive_button", role: .destructive) {}

                    RyzeSecondaryButton("Cancelar", testID: "secondary_cancel_button", role: .cancel) {}
                }
                .ryzePadding()
            } header: {
                RyzeText("RyzeSecondaryButton")
                    .ryze(font: .footnote)
                    .ryze(color: .textSecondary)
            }

            // Intelligence Section
            RyzeVStack(alignment: .leading, spacing: .medium) {
                RyzeHStack(spacing: .small) {
                    RyzeSymbol("brain.headset", mode: .hierarchical)
                        .ryze(color: .primary)

                    RyzeText("Intelligence")
                        .ryze(font: .headline)
                }

                RyzeBodyText(
                    "Botões no RyzeUI seguem princípios de acessibilidade e oferecem feedback tátil (haptic) no iOS. Use RyzePrimaryButton para a ação principal (CTA) e RyzeSecondaryButton para ações secundárias."
                )

                RyzeTag("Acessibilidade", style: .info, size: .small)
                RyzeTag("Haptic Feedback", style: .info, size: .small)
                RyzeTag("testID", style: .info, size: .small)
            }
            .ryzePadding()
            .ryzeBackgroundSecondary()
            .ryze(clip: .rounded(radius: 20))
        }
        .navigationTitle("Buttons")
        .sheet(isPresented: $showSheet) {
            RyzeVStack(spacing: .medium) {
                RyzeText("Ação destrutiva confirmada!")
                RyzePrimaryButton("OK") {
                    showSheet = false
                }
            }
            .ryzePadding()
        }
    }
}

#Preview {
    RyzeNavigationView(router: .init()) { (_: PlaygroundRoute) in
        EmptyView()
    } content: {
        ButtonDemoView()
    }
    .ryze(theme: RyzePlaygroundTheme())
}
