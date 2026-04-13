//
//  ConfettiDemoView.swift
//  PrismPlayground
//
//  Created by Rafael Escaleira on 11/04/26.
//

import PrismUI
import SwiftUI
import PrismArchitecture

struct ConfettiDemoView: View {
    @Environment(\.theme) private var theme
    @State private var isCelebrating = false
    @State private var celebrationCount = 0

    var body: some View {
        PrismLazyList {
            // Trigger Button
            PrismSection {
                PrismVStack(spacing: .medium) {
                    PrismPrimaryButton("🎉 Celebrar!") {
                        isCelebrating = true
                        celebrationCount += 1

                        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                            isCelebrating = false
                        }
                    }
                    .prism(width: .max)

                    PrismFootnoteText("Celebrações: \(celebrationCount)")
                }
                .prismPadding()
            } header: {
                PrismText("Ativar Confetti")
                    .prism(font: .footnote)
                    .prism(color: .textSecondary)
            }

            // Demo with Confetti
            PrismSection {
                PrismVStack {
                    PrismZStack {
                        PrismShape(shape: .circle)
                            .prism(background: .primary)
                            .frame(width: 150, height: 150)

                        PrismVStack(spacing: .small) {
                            PrismSymbol("trophy.fill")
                                .prism(font: .largeTitle)
                                .prism(color: .primary)

                            PrismText("Sucesso!")
                                .prism(font: .headline)
                                .prism(color: .primary)
                        }
                    }
                    .prismConfetti(amount: 50, seconds: 4, isActive: isCelebrating)
                }
                .prismPadding()
                .prismBackgroundSecondary()
                .prism(clip: .rounded(radius: 20))
            } header: {
                PrismText("Demo de Celebração")
                    .prism(font: .footnote)
                    .prism(color: .textSecondary)
            }

            // Amount Variation
            PrismSection {
                PrismVStack(spacing: .medium) {
                    PrismHStack {
                        PrismVStack(alignment: .leading, spacing: .small) {
                            PrismFootnoteText("30 partículas")
                            PrismButton("Leve", testID: "confetti_light") {
                                triggerConfetti(amount: 30)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .prismPadding()
                        .prismBackgroundSecondary()
                        .prism(clip: .rounded(radius: 12))

                        PrismVStack(alignment: .leading, spacing: .small) {
                            PrismFootnoteText("60 partículas")
                            PrismButton("Médio", testID: "confetti_medium") {
                                triggerConfetti(amount: 60)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .prismPadding()
                        .prismBackgroundSecondary()
                        .prism(clip: .rounded(radius: 12))
                    }

                    PrismHStack {
                        PrismVStack(alignment: .leading, spacing: .small) {
                            PrismFootnoteText("100 partículas")
                            PrismButton("Intenso", testID: "confetti_intense") {
                                triggerConfetti(amount: 100)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .prismPadding()
                        .prismBackgroundSecondary()
                        .prism(clip: .rounded(radius: 12))
                    }
                }
                .prismPadding()
            } header: {
                PrismText("Quantidade de Partículas")
                    .prism(font: .footnote)
                    .prism(color: .textSecondary)
            }

            // Use Cases
            PrismSection {
                PrismVStack(spacing: .medium) {
                    ConfettiUseCaseCard(
                        title: "Compra Confirmada",
                        icon: "checkmark.circle.fill",
                        color: PrismColor.success,
                        message: "Sua compra foi realizada com sucesso!"
                    ) {
                        triggerConfetti(amount: 50)
                    }

                    ConfettiUseCaseCard(
                        title: "Conquista Desbloqueada",
                        icon: "star.fill",
                        color: PrismColor.warning,
                        message: "Você alcançou 1000 pontos!"
                    ) {
                        triggerConfetti(amount: 70)
                    }

                    ConfettiUseCaseCard(
                        title: "Tarefa Completa",
                        icon: "list.bullet.indent",
                        color: PrismColor.info,
                        message: "Todas as tarefas foram concluídas!"
                    ) {
                        triggerConfetti(amount: 40)
                    }
                }
                .prismPadding()
            } header: {
                PrismText("Casos de Uso")
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
                    "Confetti é perfeito para momentos de celebração: compras confirmadas, conquistas, milestones. O feedback háptico automático reforça a experiência positiva."
                )

                PrismTag("Celebração", style: .info, size: .small)
                PrismTag("Feedback Háptico", style: .info, size: .small)
                PrismTag("Animação", style: .info, size: .small)
            }
            .prismPadding()
            .prismBackgroundSecondary()
            .prism(clip: .rounded(radius: 20))
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
    let color: PrismColor
    let message: String
    let action: () -> Void

    var body: some View {
        PrismHStack(spacing: .medium) {
            PrismShape(shape: .circle)
                .prism(background: color)
                .opacity(0.2)
                .frame(width: 50, height: 50)

            PrismSymbol(icon, mode: .hierarchical)
                .prism(color: color)
                .prism(font: .title2)

            PrismVStack(alignment: .leading, spacing: .small) {
                PrismText(title)
                    .prism(font: .headline)
                PrismFootnoteText(message)
            }

            PrismSpacer()

            PrismButton("Comemorar", testID: "celebrate_button", action: action)
        }
        .prismPadding()
        .prismBackgroundSecondary()
        .prism(clip: .rounded(radius: 12))
    }
}

#Preview {
    PrismNavigationView(router: .init()) { (_: PlaygroundRoute) in
        EmptyView()
    } content: {
        ConfettiDemoView()
    }
    .prism(theme: PrismPlaygroundTheme())
}
