//
//  TextFieldDemoView.swift
//  RyzePlayground
//
//  Created by Rafael Escaleira on 11/04/26.
//

import RyzeFoundation
import RyzeUI
import SwiftUI

private struct CustomString: RyzeResourceString {
    let value: String
    var localized: LocalizedStringKey { LocalizedStringKey(value) }

    init(_ value: String) {
        self.value = value
    }
}

private struct EmailTextFieldConfiguration: RyzeTextFieldConfiguration {
    var placeholder: RyzeResourceString { CustomString("Digite seu email") }
    var mask: RyzeTextFieldMask? { nil }
    var icon: String? { "envelope.fill" }
    var contentType: RyzeTextFieldContentType { .emailAddress }
    var autocapitalizationType: RyzeTextInputAutocapitalization { .never }
    var submitLabel: SubmitLabel { .next }

    func validate(text: String) throws {
        guard !text.isEmpty else { return }
        let emailRegex = "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,64}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES[c] %@", emailRegex)
        if !emailPredicate.evaluate(with: text) {
            throw RyzeUIError.emailValidationFailed
        }
    }
}

struct TextFieldDemoView: View {
    @Environment(\.theme) private var theme
    @State private var email = ""
    @State private var currencyAmount = 0.0

    var body: some View {
        RyzeLazyList {
            // Basic TextField
            RyzeSection {
                RyzeVStack(spacing: .medium) {
                    RyzeTextField(
                        text: $email,
                        configuration: EmailTextFieldConfiguration(),
                        accessibility: {
                            $0.label("Email")
                                .testID("email_field_basic")
                        }
                    )
                }
                .ryzePadding()
            } header: {
                RyzeText("RyzeTextField")
                    .ryze(font: .footnote)
                    .ryze(color: .textSecondary)
            }

            // With testID
            RyzeSection {
                RyzeVStack(spacing: .medium) {
                    RyzeTextField(
                        text: $email,
                        configuration: EmailTextFieldConfiguration(),
                        accessibility: {
                            $0.label("Email")
                                .testID("email_field")
                        }
                    )
                }
                .ryzePadding()
            } header: {
                RyzeText("Com testID para Testes")
                    .ryze(font: .footnote)
                    .ryze(color: .textSecondary)
            }

            // Currency TextField
            RyzeSection {
                RyzeVStack(spacing: .medium) {
                    RyzeCurrencyTextField(
                        amount: $currencyAmount,
                        locale: .portugueseBR
                    )

                    RyzeFootnoteText(String(format: "Valor: R$ %.2f", currencyAmount))
                }
                .ryzePadding()
            } header: {
                RyzeText("RyzeCurrencyTextField")
                    .ryze(font: .footnote)
                    .ryze(color: .textSecondary)
            }

            // Validation
            RyzeSection {
                RyzeVStack(spacing: .medium) {
                    RyzeTextField(
                        text: $email,
                        configuration: EmailTextFieldConfiguration(),
                        accessibility: {
                            $0.label("Email")
                                .testID("email_field_validation")
                        }
                    )

                    RyzeFootnoteText("Digite um email inválido para ver a validação")
                }
                .ryzePadding()
            } header: {
                RyzeText("Validação Automática")
                    .ryze(font: .footnote)
                    .ryze(color: .textSecondary)
            }

            // Accessibility Builder
            RyzeSection {
                RyzeVStack(spacing: .medium) {
                    RyzeTextField(
                        text: $email,
                        configuration: EmailTextFieldConfiguration(),
                        accessibility: {
                            $0.label("Email")
                                .hint("Digite seu email")
                                .testID("email_field")
                        }
                    )
                }
                .ryzePadding()
            } header: {
                RyzeText("Accessibility Builder")
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
                    "RyzeTextField possui label flutuante animado, validação integrada e botão de limpar. As configurações (.email, .phone, .cpf) validam automaticamente o formato."
                )

                RyzeTag("Label Flutuante", style: .info, size: .small)
                RyzeTag("Validação", style: .info, size: .small)
                RyzeTag("Acessibilidade", style: .info, size: .small)
            }
            .ryzePadding()
            .ryzeBackgroundSecondary()
            .ryze(clip: .rounded(radius: 20))
        }
        .navigationTitle("Text Fields")
    }
}

#Preview {
    RyzeNavigationView(router: .init()) { (_: PlaygroundRoute) in
        EmptyView()
    } content: {
        TextFieldDemoView()
    }
    .ryze(theme: RyzePlaygroundTheme())
}
