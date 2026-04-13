//
//  IntelligenceDetailView.swift
//  PrismPlayground
//
//  Created by Rafael Escaleira on 11/04/26.
//

import PrismFoundation
import PrismIntelligence
import PrismArchitecture
import PrismUI
import SwiftUI

private struct CustomString: PrismResourceString {
    let value: String
    var localized: LocalizedStringKey { LocalizedStringKey(value) }

    init(_ value: String) {
        self.value = value
    }
}

private struct IntelligenceQueryConfiguration: PrismTextFieldConfiguration {
    var placeholder: PrismResourceString { CustomString("Faça sua pergunta...") }
    var mask: PrismTextFieldMask? { nil }
    var icon: String? { "questionmark.circle" }
    var contentType: PrismTextFieldContentType { .default }
    var autocapitalizationType: PrismTextInputAutocapitalization { .sentences }
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
        PrismLazyList {
            // Component Header
            PrismVStack(alignment: .leading, spacing: .medium) {
                PrismHStack(spacing: .small) {
                    PrismSymbol("brain.headset", mode: .hierarchical)
                        .prism(color: .primary)
                        .prism(font: .title2)

                    PrismText(component)
                        .prism(font: .title)
                        .prism(color: .primary)
                }

                PrismBodyText(
                    "Obtenha explicações inteligentes sobre \(component), incluindo melhores práticas, padrões de uso e exemplos de código."
                )
            }
            .prismPadding()
            .prismBackgroundSecondary()
            .prism(clip: .rounded(radius: 20))

            // Quick Actions
            PrismSection {
                PrismVStack(spacing: .small) {
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
                .prismPadding(.vertical, .small)
            } header: {
                PrismText("Perguntas Rápidas").prism(font: .footnote).prism(color: .textSecondary)
            }

            // Query Input
            PrismSection {
                PrismVStack(spacing: .medium) {
                    PrismTextField(
                        text: $intelligenceQuery,
                        configuration: IntelligenceQueryConfiguration(),
                        accessibility: {
                            $0.label("Pergunta")
                                .testID("intelligence_query_field")
                        }
                    )

                    PrismPrimaryButton("Perguntar ao Prism Intelligence", testID: "ask_button") {
                        awaitQuery(intelligenceQuery)
                    }
                    .disabled(intelligenceQuery.isEmpty || isQuerying)
                }
                .prismPadding()
            } header: {
                PrismText("Pergunta Personalizada").prism(font: .footnote).prism(color: .textSecondary)
            }

            // Response
            if let response = intelligenceResponse {
                PrismSection {
                    PrismVStack(alignment: .leading, spacing: .medium) {
                        if isQuerying {
                            PrismHStack(spacing: .small) {
                                PrismSymbol("arrow.clockwise")
                                    .prismSymbol(
                                        effect: .variableColor.cumulative.dimInactiveLayers.reversing
                                    )

                                PrismBodyText("Consultando Prism Intelligence...")
                            }
                        } else {
                            PrismBodyText(response)
                        }
                    }
                    .prismPadding()
                    .prismBackgroundSecondary()
                    .prism(clip: .rounded(radius: 12))
                } header: {
                    PrismText("Resposta").prism(font: .footnote).prism(color: .textSecondary)
                }
            }

            // Related Topics
            PrismSection {
                PrismHStack(spacing: .small) {
                    PrismTag("Design System", style: .info, size: .small)
                    PrismTag("SwiftUI", style: .info, size: .small)
                    PrismTag("Acessibilidade", style: .info, size: .small)
                    PrismTag("Testes", style: .info, size: .small)
                    PrismTag("Performance", style: .info, size: .small)
                }
                .prismPadding()
            } header: {
                PrismText("Tópicos Relacionados").prism(font: .footnote).prism(color: .textSecondary)
            }
        }
        .navigationTitle("Intelligence")
    }

    private func awaitQuery(_ query: String) {
        isQuerying = true
        intelligenceResponse = nil

        // Simula chamada ao PrismIntelligence
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                intelligenceResponse = generateMockResponse(for: query)
                isQuerying = false
            }
        }
    }

    private func generateMockResponse(for query: String) -> String {
        """
        **\(component)** no PrismUI

        O componente \(component) é parte fundamental do Design System PrismUI, seguindo os princípios de:

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
        PrismButton(
            action: action,
            label: {
                PrismHStack(spacing: .medium) {
                    PrismSymbol(icon, mode: .hierarchical)
                        .prism(color: .primary)

                    PrismText(question)
                        .prism(font: .body)

                    PrismSpacer()

                    PrismSymbol("arrow.right")
                        .prism(color: .textSecondary)
                }
                .prismPadding()
            },
            accessibility: {
                $0.label(LocalizedStringKey(question))
                    .testID("question_button")
            }
        )
        .buttonStyle(.plain)
        .prismBackgroundSecondary()
        .prism(clip: .rounded(radius: 12))
    }
}

#Preview {
    PrismNavigationView(router: .init()) { (_: PlaygroundRoute) in
        EmptyView()
    } content: {
        IntelligenceDetailView(component: "PrismButton")
    }
    .prism(theme: PrismPlaygroundTheme())
}
