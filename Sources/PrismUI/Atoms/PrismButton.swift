//
//  PrismButton.swift
//  Prism
//
//  Created by Rafael Escaleira on 18/06/25.
//

import SwiftUI

/// Um botão estilizado do Design System PrismUI.
///
/// `PrismButton` é o componente base para botões interativos, com suporte nativo a
/// acessibilidade (VoiceOver/TalkBack) e testes de UI (XCUITest) através de testIDs estáveis.
///
/// ## Uso Básico
/// ```swift
/// PrismButton("Entrar", testID: "login_button") {
///     // ação de login
/// }
/// ```
///
/// ## Uso com Builder de Acessibilidade
/// ```swift
/// PrismButton(
///     accessibility: {
///         $0.label("Entrar")
///             .hint("Toque para fazer login")
///             .testID("login_button")
///     }
/// ) {
///     PrismText("Entrar")
/// }
/// ```
///
/// - Important: Para testes de UI, sempre forneça um `testID` único e estável.
/// - Note: O botão possui feedback tátil (haptic) no iOS.
public struct PrismButton: PrismView {
    let role: ButtonRole?
    let action: () async -> Void
    let label: any View
    public var accessibility: PrismAccessibilityProperties?

    // MARK: - Initialization

    /// Inicialização padrão com propriedades de acessibilidade explícitas.
    /// - Parameters:
    ///   - accessibility: Propriedades de acessibilidade opcionais.
    ///   - role: Papel do botão (`.none`, `.cancel`, `.destructive`).
    ///   - action: Ação assíncrona executada ao tocar.
    ///   - label: Conteúdo visual do botão.
    public init(
        accessibility: PrismAccessibilityProperties? = nil,
        role: ButtonRole? = .none,
        action: @escaping () async -> Void,
        @ViewBuilder label: () -> some View
    ) {
        self.accessibility = accessibility
        self.role = role
        self.action = action
        self.label = label()
    }

    /// Inicialização com propriedades de acessibilidade como primeiro parâmetro.
    /// - Parameters:
    ///   - accessibility: Propriedades de acessibilidade opcionais.
    ///   - role: Papel do botão (`.none`, `.cancel`, `.destructive`).
    ///   - action: Ação assíncrona executada ao tocar.
    ///   - label: Conteúdo visual do botão.
    public init(
        _ accessibility: PrismAccessibilityProperties? = nil,
        role: ButtonRole? = .none,
        action: @escaping () async -> Void,
        @ViewBuilder label: () -> some View
    ) {
        self.accessibility = accessibility
        self.role = role
        self.action = action
        self.label = label()
    }

    /// Inicialização rápida com builder de acessibilidade.
    /// - Parameters:
    ///   - role: Papel do botão (`.none`, `.cancel`, `.destructive`).
    ///   - action: Ação assíncrona executada ao tocar.
    ///   - label: Conteúdo visual do botão.
    ///   - accessibility: Closure que configura `PrismAccessibilityConfig`.
    public init(
        role: ButtonRole? = .none,
        action: @escaping () async -> Void,
        @ViewBuilder label: () -> some View,
        accessibility: (PrismAccessibilityConfig) -> PrismAccessibilityConfig = { $0 }
    ) {
        self.accessibility = accessibility(PrismAccessibilityConfig()).build()
        self.role = role
        self.action = action
        self.label = label()
    }

    /// Inicialização rápida com conveniência estática para acessibilidade.
    /// - Parameters:
    ///   - label: Texto do botão (LocalizedStringKey).
    ///   - testID: Identificador único para testes de UI (NÃO localizável).
    ///   - role: Papel do botão (`.none`, `.cancel`, `.destructive`).
    ///   - hint: Dica adicional para VoiceOver (opcional).
    ///   - action: Ação assíncrona executada ao tocar.
    public init(
        _ label: LocalizedStringKey,
        testID: String,
        role: ButtonRole? = .none,
        hint: LocalizedStringKey? = nil,
        action: @escaping () async -> Void
    ) {
        self.accessibility = PrismAccessibility.button(label, testID: testID, hint: hint)
        self.role = role
        self.action = action
        self.label = PrismText(label)
    }

    // MARK: - Body

    public var body: some View {
        Button(role: role) {
            #if os(iOS)
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            #endif
            Task { await action() }
        } label: {
            AnyView(label)
        }
        .prism(accessibility: accessibility ?? defaultAccessibility)
    }

    // MARK: - Default Accessibility

    private var defaultAccessibility: PrismAccessibilityProperties {
        PrismAccessibility.button(
            "Button",
            testID: ""
        )
    }

    // MARK: - Mock

    public static func mocked() -> some View {
        PrismButton(
            accessibility: nil,
            role: .none,
            action: {}
        ) {
            PrismText.mocked()
        }
    }
}

// MARK: - Previews

#Preview("Default") {
    PrismButton.mocked()
        .prismPadding()
}

#Preview("With Accessibility") {
    PrismButton(
        "Entrar",
        testID: "login_button",
        hint: "Toque para fazer login"
    ) {
        // action
    }
    .prismPadding()
}
