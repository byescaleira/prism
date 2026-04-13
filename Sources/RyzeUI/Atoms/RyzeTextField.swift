//
//  RyzeTextField.swift
//  Ryze
//
//  Created by Rafael Escaleira on 07/06/25.
//

import RyzeFoundation
import SwiftUI

/// Campo de texto estilizado do Design System RyzeUI.
///
/// `RyzeTextField` é um componente de input de texto com:
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
/// RyzeTextField(
///     text: $email,
///     configuration: RyzeDefaultTextFieldConfiguration.email
/// )
/// ```
///
/// ## Com testID
/// ```swift
/// RyzeTextField(
///     text: $email,
///     label: "Email",
///     testID: "email_field",
///     configuration: .email
/// )
/// ```
///
/// ## Com Builder de Acessibilidade
/// ```swift
/// RyzeTextField(
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
public struct RyzeTextField: RyzeView {
    @Environment(\.theme) var theme
    @FocusState var isFocused: Bool
    @Binding var text: String
    @State var error: RyzeError?

    let configuration: RyzeTextFieldConfiguration
    public var accessibility: RyzeAccessibilityProperties?

    // MARK: - Initialization

    public init(
        text: Binding<String>,
        _ accessibility: RyzeAccessibilityProperties? = nil,
        configuration: RyzeTextFieldConfiguration
    ) {
        self._text = text
        self.accessibility = accessibility
        self.configuration = configuration
    }

    /// Inicialização rápida com conveniência de acessibilidade
    public init(
        text: Binding<String>,
        configuration: RyzeTextFieldConfiguration,
        accessibility: (RyzeAccessibilityConfig) -> RyzeAccessibilityConfig = { $0 }
    ) {
        self._text = text
        self.configuration = configuration
        self.accessibility = accessibility(RyzeAccessibilityConfig()).build()
    }

    /// Inicialização com conveniência estática
    public init(
        text: Binding<String>,
        label: LocalizedStringKey,
        testID: String,
        configuration: RyzeTextFieldConfiguration
    ) {
        self._text = text
        self.configuration = configuration
        self.accessibility = RyzeAccessibility.textField(label, testID: testID)
    }

    var needFocus: Bool {
        isFocused || !text.isEmpty
    }

    var stateColor: RyzeColor {
        error == nil && !text.isEmpty ? .success : error == nil ? .secondary : .error
    }

    public var body: some View {
        RyzeVStack(alignment: .leading, spacing: .small) {
            contentTextField
                .overlay(alignment: .topLeading) { placeholderView }
                .contentShape(.rect)
                .onTapGesture {
                    isFocused = true
                }
                .ryze(accessibility: accessibility ?? defaultAccessibility)

            errorView
        }
        .animation(theme.animation, value: isFocused)
        .animation(theme.animation, value: text.isEmpty)
        .animation(theme.animation, value: error?.localizedDescription)
        .onChange(of: text) { validate() }
    }

    // MARK: - Default Accessibility

    private var defaultAccessibility: RyzeAccessibilityProperties {
        RyzeAccessibility.textField(
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
        .ryze(alignment: .leading)
        .ryzePadding(.horizontal, .extraLarge)
        .ryzePadding(.horizontal, .small)
        .overlay(alignment: .leading) { iconView }
        .overlay(alignment: .trailing) { clearButton }
        .ryzePadding()
        .ryzeBackgroundSecondary()
        .ryze(clip: .rounded(radius: theme.radius.large))
    }

    func validate() {
        do {
            try configuration.validate(text: text)
            self.error = nil
        } catch let error as RyzeError {
            self.error = error
        } catch {

        }
    }

    var clearButton: some View {
        Button {
            text = ""
            isFocused = true
        } label: {
            RyzeSymbol(
                "xmark.circle.fill",
                mode: .hierarchical
            )
            .ryze(font: .body)
            .ryze(color: .textSecondary)
            .offset(x: needFocus && !text.isEmpty ? .zero : 50)
            .opacity(0.5)
            .scaleEffect(0.8)
        }
    }

    @ViewBuilder
    var iconView: some View {
        if let icon = configuration.icon {
            RyzeSymbol(icon)
                .ryze(font: .footnote)
                .ryze(color: stateColor)
                .ryzeGlow(for: error == nil ? nil : theme.color.error)
                .offset(x: needFocus ? .zero : -50)
        }
    }

    @ViewBuilder
    var placeholderView: some View {
        RyzeText(configuration.placeholder)
            .ryze(font: needFocus ? .footnote : .body)
            .ryze(color: .disabled)
            .lineLimit(1)
            .ryzePadding()
            .offset(y: needFocus ? -40 : .zero)
    }

    @ViewBuilder
    var errorView: some View {
        if error != nil {
            RyzeVStack(alignment: .leading) {
                failureReasonView
                recoverySuggestionView
            }
            .ryze(width: .max)
            .transition(.blurReplace)
        }
    }

    @ViewBuilder
    var failureReasonView: some View {
        if let failureReason = error?.failureReason {
            RyzeHStack(spacing: .small) {
                RyzeSymbol(
                    "xmark.circle.fill",
                    mode: .hierarchical
                )
                .ryze(font: .footnote)
                .ryze(color: .error)

                RyzeText(failureReason)
                    .ryze(font: needFocus ? .footnote : .body)
                    .ryze(color: .disabled)
                    .ryze(alignment: .leading)
            }
        }
    }

    @ViewBuilder
    var recoverySuggestionView: some View {
        if let recoverySuggestion = error?.recoverySuggestion {
            RyzeHStack(spacing: .small) {
                RyzeSymbol(
                    "lightbulb.max.fill",
                    mode: .hierarchical
                )
                .ryze(font: .footnote)
                .ryze(color: .success)

                RyzeText(recoverySuggestion)
                    .ryze(font: needFocus ? .footnote : .body)
                    .ryze(color: .disabled)
                    .ryze(alignment: .leading)
            }
        }
    }

    public static func mocked() -> some View {
        RyzeTextField(
            text: .constant(""),
            configuration: RyzeDefaultTextFieldConfiguration.email,
            accessibility: { $0 }
        )
    }
}

#Preview {
    @Previewable @State var text: String = ""
    RyzeTextField(
        text: $text,
        configuration: RyzeDefaultTextFieldConfiguration.email,
        accessibility: { $0 }
    )
    .ryzePadding()
}
