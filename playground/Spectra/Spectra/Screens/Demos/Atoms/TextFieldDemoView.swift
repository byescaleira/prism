//
//  TextFieldDemoView.swift
//  PrismPlayground
//
//  Created by Rafael Escaleira on 11/04/26.
//

import PrismFoundation
import PrismUI
import SwiftUI
import PrismArchitecture

private struct CustomString: PrismResourceString {
    let value: String
    var localized: LocalizedStringKey { LocalizedStringKey(value) }

    init(_ value: String) {
        self.value = value
    }
}

private struct EmailTextFieldConfiguration: PrismTextFieldConfiguration {
    var placeholder: PrismResourceString { CustomString("Digite seu email") }
    var mask: PrismTextFieldMask? { nil }
    var icon: String? { "envelope.fill" }
    var contentType: PrismTextFieldContentType { .emailAddress }
    var autocapitalizationType: PrismTextInputAutocapitalization { .never }
    var submitLabel: SubmitLabel { .next }

    func validate(text: String) throws {
        guard !text.isEmpty else { return }
        let emailRegex = "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,64}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES[c] %@", emailRegex)
        if !emailPredicate.evaluate(with: text) {
            throw PrismUIError.emailValidationFailed
        }
    }
}

struct TextFieldDemoView: View {
    @Environment(\.theme) private var theme
    @State private var email = ""
    @State private var currencyAmount = 0.0

    var body: some View {
        PrismLazyList {
            // Basic TextField
            PrismSection {
                PrismVStack(spacing: .medium) {
                    PrismTextField(
                        text: $email,
                        configuration: EmailTextFieldConfiguration(),
                        accessibility: {
                            $0.label("Email")
                                .testID("email_field_basic")
                        }
                    )
                }
                .prismPadding()
            } header: {
                PrismText("PrismTextField")
                    .prism(font: .footnote)
                    .prism(color: .textSecondary)
            }

            // With testID
            PrismSection {
                PrismVStack(spacing: .medium) {
                    PrismTextField(
                        text: $email,
                        configuration: EmailTextFieldConfiguration(),
                        accessibility: {
                            $0.label("Email")
                                .testID("email_field")
                        }
                    )
                }
                .prismPadding()
            } header: {
                PrismText("Com testID para Testes")
                    .prism(font: .footnote)
                    .prism(color: .textSecondary)
            }

            // Currency TextField
            PrismSection {
                PrismVStack(spacing: .medium) {
                    PrismCurrencyTextField(
                        amount: $currencyAmount,
                        locale: .portugueseBR
                    )

                    PrismFootnoteText(String(format: "Valor: R$ %.2f", currencyAmount))
                }
                .prismPadding()
            } header: {
                PrismText("PrismCurrencyTextField")
                    .prism(font: .footnote)
                    .prism(color: .textSecondary)
            }

            // Validation
            PrismSection {
                PrismVStack(spacing: .medium) {
                    PrismTextField(
                        text: $email,
                        configuration: EmailTextFieldConfiguration(),
                        accessibility: {
                            $0.label("Email")
                                .testID("email_field_validation")
                        }
                    )

                    PrismFootnoteText("Digite um email inválido para ver a validação")
                }
                .prismPadding()
            } header: {
                PrismText("Validação Automática")
                    .prism(font: .footnote)
                    .prism(color: .textSecondary)
            }

            // Accessibility Builder
            PrismSection {
                PrismVStack(spacing: .medium) {
                    PrismTextField(
                        text: $email,
                        configuration: EmailTextFieldConfiguration(),
                        accessibility: {
                            $0.label("Email")
                                .hint("Digite seu email")
                                .testID("email_field")
                        }
                    )
                }
                .prismPadding()
            } header: {
                PrismText("Accessibility Builder")
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
                    "PrismTextField possui label flutuante animado, validação integrada e botão de limpar. As configurações (.email, .phone, .cpf) validam automaticamente o formato."
                )

                PrismTag("Label Flutuante", style: .info, size: .small)
                PrismTag("Validação", style: .info, size: .small)
                PrismTag("Acessibilidade", style: .info, size: .small)
            }
            .prismPadding()
            .prismBackgroundSecondary()
            .prism(clip: .rounded(radius: 20))
        }
        .navigationTitle("Text Fields")
    }
}

#Preview {
    PrismNavigationView(router: .init()) { (_: PlaygroundRoute) in
        EmptyView()
    } content: {
        TextFieldDemoView()
    }
    .prism(theme: PrismPlaygroundTheme())
}
