//
//  ConfettiDemoView.swift
//  RyzePlayground
//
//  Created by Rafael Escaleira on 11/04/26.
//

import RyzeUI
import SwiftUI

struct ConfettiDemoView: View {
    @Environment(\.theme) private var theme
    @State private var isCelebrating = false
    @State private var celebrationCount = 0

    var body: some View {
        RyzeLazyList {
            // Trigger Button
            RyzeSection {
                RyzeVStack(spacing: .medium) {
                    RyzePrimaryButton("🎉 Celebrar!") {
                        isCelebrating = true
                        celebrationCount += 1

                        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                            isCelebrating = false
                        }
                    }
                    .ryze(width: .max)

                    RyzeFootnoteText("Celebrações: \(celebrationCount)")
                }
                .ryzePadding()
            } header: {
                RyzeText("Ativar Confetti")
                    .ryze(font: .footnote)
                    .ryze(color: .textSecondary)
            }

            // Demo with Confetti
            RyzeSection {
                RyzeVStack {
                    RyzeZStack {
                        RyzeShape(shape: .circle)
                            .ryze(background: .primary)
                            .frame(width: 150, height: 150)

                        RyzeVStack(spacing: .small) {
                            RyzeSymbol("trophy.fill")
                                .ryze(font: .largeTitle)
                                .ryze(color: .primary)

                            RyzeText("Sucesso!")
                                .ryze(font: .headline)
                                .ryze(color: .primary)
                        }
                    }
                    .ryzeConfetti(amount: 50, seconds: 4, isActive: isCelebrating)
                }
                .ryzePadding()
                .ryzeBackgroundSecondary()
                .ryze(clip: .rounded(radius: 20))
            } header: {
                RyzeText("Demo de Celebração")
                    .ryze(font: .footnote)
                    .ryze(color: .textSecondary)
            }

            // Amount Variation
            RyzeSection {
                RyzeVStack(spacing: .medium) {
                    RyzeHStack {
                        RyzeVStack(alignment: .leading, spacing: .small) {
                            RyzeFootnoteText("30 partículas")
                            RyzeButton("Leve", testID: "confetti_light") {
                                triggerConfetti(amount: 30)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .ryzePadding()
                        .ryzeBackgroundSecondary()
                        .ryze(clip: .rounded(radius: 12))

                        RyzeVStack(alignment: .leading, spacing: .small) {
                            RyzeFootnoteText("60 partículas")
                            RyzeButton("Médio", testID: "confetti_medium") {
                                triggerConfetti(amount: 60)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .ryzePadding()
                        .ryzeBackgroundSecondary()
                        .ryze(clip: .rounded(radius: 12))
                    }

                    RyzeHStack {
                        RyzeVStack(alignment: .leading, spacing: .small) {
                            RyzeFootnoteText("100 partículas")
                            RyzeButton("Intenso", testID: "confetti_intense") {
                                triggerConfetti(amount: 100)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .ryzePadding()
                        .ryzeBackgroundSecondary()
                        .ryze(clip: .rounded(radius: 12))
                    }
                }
                .ryzePadding()
            } header: {
                RyzeText("Quantidade de Partículas")
                    .ryze(font: .footnote)
                    .ryze(color: .textSecondary)
            }

            // Use Cases
            RyzeSection {
                RyzeVStack(spacing: .medium) {
                    ConfettiUseCaseCard(
                        title: "Compra Confirmada",
                        icon: "checkmark.circle.fill",
                        color: RyzeColor.success,
                        message: "Sua compra foi realizada com sucesso!"
                    ) {
                        triggerConfetti(amount: 50)
                    }

                    ConfettiUseCaseCard(
                        title: "Conquista Desbloqueada",
                        icon: "star.fill",
                        color: RyzeColor.warning,
                        message: "Você alcançou 1000 pontos!"
                    ) {
                        triggerConfetti(amount: 70)
                    }

                    ConfettiUseCaseCard(
                        title: "Tarefa Completa",
                        icon: "list.bullet.indent",
                        color: RyzeColor.info,
                        message: "Todas as tarefas foram concluídas!"
                    ) {
                        triggerConfetti(amount: 40)
                    }
                }
                .ryzePadding()
            } header: {
                RyzeText("Casos de Uso")
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
                    "Confetti é perfeito para momentos de celebração: compras confirmadas, conquistas, milestones. O feedback háptico automático reforça a experiência positiva."
                )

                RyzeTag("Celebração", style: .info, size: .small)
                RyzeTag("Feedback Háptico", style: .info, size: .small)
                RyzeTag("Animação", style: .info, size: .small)
            }
            .ryzePadding()
            .ryzeBackgroundSecondary()
            .ryze(clip: .rounded(radius: 20))
        }
        .navigationTitle("Confetti")
    }

    private func triggerConfetti(amount: Int) {
        isCelebrating = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            isCelebrating = false
        }
    }
}

private struct ConfettiUseCaseCard: View {
    let title: String
    let icon: String
    let color: RyzeColor
    let message: String
    let action: () -> Void

    var body: some View {
        RyzeHStack(spacing: .medium) {
            RyzeShape(shape: .circle)
                .ryze(background: color)
                .opacity(0.2)
                .frame(width: 50, height: 50)

            RyzeSymbol(icon, mode: .hierarchical)
                .ryze(color: color)
                .ryze(font: .title2)

            RyzeVStack(alignment: .leading, spacing: .small) {
                RyzeText(title)
                    .ryze(font: .headline)
                RyzeFootnoteText(message)
            }

            RyzeSpacer()

            RyzeButton("Comemorar", testID: "celebrate_button", action: action)
        }
        .ryzePadding()
        .ryzeBackgroundSecondary()
        .ryze(clip: .rounded(radius: 12))
    }
}

#Preview {
    RyzeNavigationView(router: .init()) { (_: PlaygroundRoute) in
        EmptyView()
    } content: {
        ConfettiDemoView()
    }
    .ryze(theme: RyzePlaygroundTheme())
}
