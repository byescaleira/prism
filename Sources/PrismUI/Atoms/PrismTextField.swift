//
//  PrismTextField.swift
//  Prism
//
//  Created by Rafael Escaleira on 07/06/25.
//

import PrismFoundation
import SwiftUI

/// Campo de texto estilizado do Design System PrismUI.
///
/// `PrismTextField` é um componente de input de texto com:
/// - Label flutuante (animação automática ao focar/digitar)
/// - Validação integrada com exibição de erros
/// - Ícone opcional
/// - Botão de limpar (aparece ao digitar)
/// - Acessibilidade completa (VoiceOver/TalkBack)
/// - Testes de UI (XCUITest) via testIDs estáveis
///
/// ## Uso Básico
/// ```swift
/// @State var email = ""
/// PrismTextField(
///     text: $email,
///     configuration: PrismDefaultTextFieldConfiguration.email
/// )
/// ```
///
/// ## Com testID
/// ```swift
/// PrismTextField(
///     text: $email,
///     label: "Email",
///     testID: "email_field",
///     configuration: .email
/// )
/// ```
///
/// ## Com Builder de Acessibilidade
/// ```swift
/// PrismTextField(
///     text: $email,
///     configuration: .email,
///     accessibility: {
///         $0.label("Email")
///             .hint("Digite seu email corporativo")
///             .testID("email_field")
///     }
/// )
/// ```
///
/// ## Validação Automática
/// O campo valida automaticamente baseado na configuração:
/// - `.email` - Valida formato de email
/// - `.phone` - Valida formato de telefone
/// - `.cpf` - Valida CPF brasileiro
/// - etc.
///
/// - Note: Erros são exibidos automaticamente abaixo do campo com ícone e mensagem.
public struct PrismTextField: PrismView {
    @Environment(\.theme) var theme
    @FocusState var isFocused: Bool
    @Binding var text: String
    @State var error: PrismError?

    let configuration: PrismTextFieldConfiguration
    public var accessibility: PrismAccessibilityProperties?

    // MARK: - Initialization

    public init(
        text: Binding<String>,
        _ accessibility: PrismAccessibilityProperties? = nil,
        configuration: PrismTextFieldConfiguration
    ) {
        self._text = text
        self.accessibility = accessibility
        self.configuration = configuration
    }

    /// Inicialização rápida com conveniência de acessibilidade
    public init(
        text: Binding<String>,
        configuration: PrismTextFieldConfiguration,
        accessibility: (PrismAccessibilityConfig) -> PrismAccessibilityConfig = { $0 }
    ) {
        self._text = text
        self.configuration = configuration
        self.accessibility = accessibility(PrismAccessibilityConfig()).build()
    }

    /// Inicialização com conveniência estática
    public init(
        text: Binding<String>,
        label: LocalizedStringKey,
        testID: String,
        configuration: PrismTextFieldConfiguration
    ) {
        self._text = text
        self.configuration = configuration
        self.accessibility = PrismAccessibility.textField(label, testID: testID)
    }

    var needFocus: Bool {
        isFocused || !text.isEmpty
    }

    var stateColor: PrismColor {
        error == nil && !text.isEmpty ? .success : error == nil ? .secondary : .error
    }

    public var body: some View {
        PrismVStack(alignment: .leading, spacing: .small) {
            contentTextField
                .overlay(alignment: .topLeading) { placeholderView }
                .contentShape(.rect)
                .onTapGesture {
                    isFocused = true
                }
                .prism(accessibility: accessibility ?? defaultAccessibility)

            errorView
        }
        .animation(theme.animation, value: isFocused)
        .animation(theme.animation, value: text.isEmpty)
        .animation(theme.animation, value: error?.localizedDescription)
        .onChange(of: text) { validate() }
    }

    // MARK: - Default Accessibility

    private var defaultAccessibility: PrismAccessibilityProperties {
        PrismAccessibility.textField(
            LocalizedStringKey(configuration.placeholder.value),
            testID: ""
        )
    }

    var contentTextField: some View {
        TextField(
            "",
            text: $text,
            axis: .vertical
        )
        .focused($isFocused)
        .autocorrectionDisabled()
        #if os(iOS)
            .keyboardType(configuration.contentType.rawValue)
            .textInputAutocapitalization(configuration.autocapitalizationType.rawValue)
        #endif
        .submitLabel(configuration.submitLabel)
        .prism(alignment: .leading)
        .prismPadding(.horizontal, .extraLarge)
        .prismPadding(.horizontal, .small)
        .overlay(alignment: .leading) { iconView }
        .overlay(alignment: .trailing) { clearButton }
        .prismPadding()
        .prismBackgroundSecondary()
        .prism(clip: .rounded(radius: theme.radius.large))
    }

    func validate() {
        do {
            try configuration.validate(text: text)
            self.error = nil
        } catch let error as PrismError {
            self.error = error
        } catch {

        }
    }

    var clearButton: some View {
        Button {
            text = ""
            isFocused = true
        } label: {
            PrismSymbol(
                "xmark.circle.fill",
                mode: .hierarchical
            )
            .prism(font: .body)
            .prism(color: .textSecondary)
            .offset(x: needFocus && !text.isEmpty ? .zero : 50)
            .opacity(0.5)
            .scaleEffect(0.8)
        }
    }

    @ViewBuilder
    var iconView: some View {
        if let icon = configuration.icon {
            PrismSymbol(icon)
                .prism(font: .footnote)
                .prism(color: stateColor)
                .prismGlow(for: error == nil ? nil : theme.color.error)
                .offset(x: needFocus ? .zero : -50)
        }
    }

    @ViewBuilder
    var placeholderView: some View {
        PrismText(configuration.placeholder)
            .prism(font: needFocus ? .footnote : .body)
            .prism(color: .disabled)
            .lineLimit(1)
            .prismPadding()
            .offset(y: needFocus ? -40 : .zero)
    }

    @ViewBuilder
    var errorView: some View {
        if error != nil {
            PrismVStack(alignment: .leading) {
                failureReasonView
                recoverySuggestionView
            }
            .prism(width: .max)
            .transition(.blurReplace)
        }
    }

    @ViewBuilder
    var failureReasonView: some View {
        if let failureReason = error?.failureReason {
            PrismHStack(spacing: .small) {
                PrismSymbol(
                    "xmark.circle.fill",
                    mode: .hierarchical
                )
                .prism(font: .footnote)
                .prism(color: .error)

                PrismText(failureReason)
                    .prism(font: needFocus ? .footnote : .body)
                    .prism(color: .disabled)
                    .prism(alignment: .leading)
            }
        }
    }

    @ViewBuilder
    var recoverySuggestionView: some View {
        if let recoverySuggestion = error?.recoverySuggestion {
            PrismHStack(spacing: .small) {
                PrismSymbol(
                    "lightbulb.max.fill",
                    mode: .hierarchical
                )
                .prism(font: .footnote)
                .prism(color: .success)

                PrismText(recoverySuggestion)
                    .prism(font: needFocus ? .footnote : .body)
                    .prism(color: .disabled)
                    .prism(alignment: .leading)
            }
        }
    }

    public static func mocked() -> some View {
        PrismTextField(
            text: .constant(""),
            configuration: PrismDefaultTextFieldConfiguration.email,
            accessibility: { $0 }
        )
    }
}

#Preview {
    @Previewable @State var text: String = ""
    PrismTextField(
        text: $text,
        configuration: PrismDefaultTextFieldConfiguration.email,
        accessibility: { $0 }
    )
    .prismPadding()
}
