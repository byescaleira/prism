//
//  RyzeButton.swift
//  Ryze
//
//  Created by Rafael Escaleira on 18/06/25.
//

import SwiftUI

/// Um botão estilizado do Design System RyzeUI.
///
/// `RyzeButton` é o componente base para botões interativos, com suporte nativo a
/// acessibilidade (VoiceOver/TalkBack) e testes de UI (XCUITest) através de testIDs estáveis.
///
/// ## Uso Básico
/// ```swift
/// RyzeButton("Entrar", testID: "login_button") {
///     // ação de login
/// }
/// ```
///
/// ## Uso com Builder de Acessibilidade
/// ```swift
/// RyzeButton(
///     accessibility: {
///         $0.label("Entrar")
///             .hint("Toque para fazer login")
///             .testID("login_button")
///     }
/// ) {
///     RyzeText("Entrar")
/// }
/// ```
///
/// - Important: Para testes de UI, sempre forneça um `testID` único e estável.
/// - Note: O botão possui feedback tátil (haptic) no iOS.
public struct RyzeButton: RyzeView {
    let role: ButtonRole?
    let action: () async -> Void
    let label: any View
    public var accessibility: RyzeAccessibilityProperties?

    // MARK: - Initialization

    /// Inicialização padrão com propriedades de acessibilidade explícitas.
    /// - Parameters:
    ///   - accessibility: Propriedades de acessibilidade opcionais.
    ///   - role: Papel do botão (`.none`, `.cancel`, `.destructive`).
    ///   - action: Ação assíncrona executada ao tocar.
    ///   - label: Conteúdo visual do botão.
    public init(
        accessibility: RyzeAccessibilityProperties? = nil,
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
        _ accessibility: RyzeAccessibilityProperties? = nil,
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
    ///   - accessibility: Closure que configura `RyzeAccessibilityConfig`.
    public init(
        role: ButtonRole? = .none,
        action: @escaping () async -> Void,
        @ViewBuilder label: () -> some View,
        accessibility: (RyzeAccessibilityConfig) -> RyzeAccessibilityConfig = { $0 }
    ) {
        self.accessibility = accessibility(RyzeAccessibilityConfig()).build()
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
        self.accessibility = RyzeAccessibility.button(label, testID: testID, hint: hint)
        self.role = role
        self.action = action
        self.label = RyzeText(label)
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
        .ryze(accessibility: accessibility ?? defaultAccessibility)
    }

    // MARK: - Default Accessibility

    private var defaultAccessibility: RyzeAccessibilityProperties {
        RyzeAccessibility.button(
            "Button",
            testID: ""
        )
    }

    // MARK: - Mock

    public static func mocked() -> some View {
        RyzeButton(
            accessibility: nil,
            role: .none,
            action: {}
        ) {
            RyzeText.mocked()
        }
    }
}

// MARK: - Previews

#Preview("Default") {
    RyzeButton.mocked()
        .ryzePadding()
}

#Preview("With Accessibility") {
    RyzeButton(
        "Entrar",
        testID: "login_button",
        hint: "Toque para fazer login"
    ) {
        // action
    }
    .ryzePadding()
}
