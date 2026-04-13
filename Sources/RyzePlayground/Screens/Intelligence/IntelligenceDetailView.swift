//
//  IntelligenceDetailView.swift
//  RyzePlayground
//
//  Created by Rafael Escaleira on 11/04/26.
//

import RyzeFoundation
import RyzeIntelligence
import RyzeUI
import SwiftUI

private struct CustomString: RyzeResourceString {
    let value: String
    var localized: LocalizedStringKey { LocalizedStringKey(value) }

    init(_ value: String) {
        self.value = value
    }
}

private struct IntelligenceQueryConfiguration: RyzeTextFieldConfiguration {
    var placeholder: RyzeResourceString { CustomString("Faça sua pergunta...") }
    var mask: RyzeTextFieldMask? { nil }
    var icon: String? { "questionmark.circle" }
    var contentType: RyzeTextFieldContentType { .default }
    var autocapitalizationType: RyzeTextInputAutocapitalization { .sentences }
    var submitLabel: SubmitLabel { .done }

    func validate(text: String) throws {}
}

struct IntelligenceDetailView: View {
    @Environment(\.theme) private var theme
    let component: String

    @State private var intelligenceQuery: String = ""
    @State private var intelligenceResponse: String?
    @State private var isQuerying = false

    var body: some View {
        RyzeLazyList {
            // Component Header
            RyzeVStack(alignment: .leading, spacing: .medium) {
                RyzeHStack(spacing: .small) {
                    RyzeSymbol("brain.headset", mode: .hierarchical)
                        .ryze(color: .primary)
                        .ryze(font: .title2)

                    RyzeText(component)
                        .ryze(font: .title)
                        .ryze(color: .primary)
                }

                RyzeBodyText(
                    "Obtenha explicações inteligentes sobre \(component), incluindo melhores práticas, padrões de uso e exemplos de código."
                )
            }
            .ryzePadding()
            .ryzeBackgroundSecondary()
            .ryze(clip: .rounded(radius: 20))

            // Quick Actions
            RyzeSection {
                RyzeVStack(spacing: .small) {
                    IntelligenceQuestionButton(
                        question: "Como usar \(component)?",
                        icon: "questionmark.circle"
                    ) {
                        awaitQuery("Como usar \(component) em um projeto iOS?")
                    }

                    IntelligenceQuestionButton(
                        question: "Quais as melhores práticas?",
                        icon: "star.fill"
                    ) {
                        awaitQuery("Quais as melhores práticas para usar \(component)?")
                    }

                    IntelligenceQuestionButton(
                        question: "Exemplos de código",
                        icon: "doc.text.fill"
                    ) {
                        awaitQuery("Mostre exemplos de código usando \(component)")
                    }

                    IntelligenceQuestionButton(
                        question: "Acessibilidade",
                        icon: "accessibility"
                    ) {
                        awaitQuery("Como implementar acessibilidade em \(component)?")
                    }
                }
                .ryzePadding(.vertical, .small)
            } header: {
                RyzeText("Perguntas Rápidas").ryze(font: .footnote).ryze(color: .textSecondary)
            }

            // Query Input
            RyzeSection {
                RyzeVStack(spacing: .medium) {
                    RyzeTextField(
                        text: $intelligenceQuery,
                        configuration: IntelligenceQueryConfiguration(),
                        accessibility: {
                            $0.label("Pergunta")
                                .testID("intelligence_query_field")
                        }
                    )

                    RyzePrimaryButton("Perguntar ao Ryze Intelligence", testID: "ask_button") {
                        awaitQuery(intelligenceQuery)
                    }
                    .disabled(intelligenceQuery.isEmpty || isQuerying)
                }
                .ryzePadding()
            } header: {
                RyzeText("Pergunta Personalizada").ryze(font: .footnote).ryze(color: .textSecondary)
            }

            // Response
            if let response = intelligenceResponse {
                RyzeSection {
                    RyzeVStack(alignment: .leading, spacing: .medium) {
                        if isQuerying {
                            RyzeHStack(spacing: .small) {
                                RyzeSymbol("arrow.clockwise")
                                    .ryzeSymbol(
                                        effect: .variableColor.cumulative.dimInactiveLayers.reversing
                                    )

                                RyzeBodyText("Consultando Ryze Intelligence...")
                            }
                        } else {
                            RyzeBodyText(response)
                        }
                    }
                    .ryzePadding()
                    .ryzeBackgroundSecondary()
                    .ryze(clip: .rounded(radius: 12))
                } header: {
                    RyzeText("Resposta").ryze(font: .footnote).ryze(color: .textSecondary)
                }
            }

            // Related Topics
            RyzeSection {
                RyzeHStack(spacing: .small) {
                    RyzeTag("Design System", style: .info, size: .small)
                    RyzeTag("SwiftUI", style: .info, size: .small)
                    RyzeTag("Acessibilidade", style: .info, size: .small)
                    RyzeTag("Testes", style: .info, size: .small)
                    RyzeTag("Performance", style: .info, size: .small)
                }
                .ryzePadding()
            } header: {
                RyzeText("Tópicos Relacionados").ryze(font: .footnote).ryze(color: .textSecondary)
            }
        }
        .navigationTitle("Intelligence")
    }

    private func awaitQuery(_ query: String) {
        isQuerying = true
        intelligenceResponse = nil

        // Simula chamada ao RyzeIntelligence
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                intelligenceResponse = generateMockResponse(for: query)
                isQuerying = false
            }
        }
    }

    private func generateMockResponse(for query: String) -> String {
        """
        **\(component)** no RyzeUI

        O componente \(component) é parte fundamental do Design System RyzeUI, seguindo os princípios de:

        1. **Acessibilidade**: Suporte completo a VoiceOver e TalkBack
        2. **Testabilidade**: testIDs estáveis para testes de UI
        3. **Consistência**: Tokens semânticos para spacing, colors e typography

        **Exemplo de uso:**
        ```swift
        \(component)(
            configuration: .default,
            accessibility: {
                $0.label("Label")
                    .testID("\(component.lowercased())_id")
            }
        )
        ```

        **Melhores práticas:**
        - Sempre forneça um testID único
        - Use o builder de acessibilidade para clareza
        - Siga os padrões de spacing do Design System
        """
    }
}

private struct IntelligenceQuestionButton: View {
    let question: String
    let icon: String
    let action: () -> Void

    var body: some View {
        RyzeButton(
            action: action,
            label: {
                RyzeHStack(spacing: .medium) {
                    RyzeSymbol(icon, mode: .hierarchical)
                        .ryze(color: .primary)

                    RyzeText(question)
                        .ryze(font: .body)

                    RyzeSpacer()

                    RyzeSymbol("arrow.right")
                        .ryze(color: .textSecondary)
                }
                .ryzePadding()
            },
            accessibility: {
                $0.label(LocalizedStringKey(question))
                    .testID("question_button")
            }
        )
        .buttonStyle(.plain)
        .ryzeBackgroundSecondary()
        .ryze(clip: .rounded(radius: 12))
    }
}

#Preview {
    RyzeNavigationView(router: .init()) { (_: PlaygroundRoute) in
        EmptyView()
    } content: {
        IntelligenceDetailView(component: "RyzeButton")
    }
    .ryze(theme: RyzePlaygroundTheme())
}
