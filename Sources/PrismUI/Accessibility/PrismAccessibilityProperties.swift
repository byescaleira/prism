//
//  PrismAccessibilityProperties.swift
//  Prism
//
//  Created by Rafael Escaleira on 09/04/26.
//

import SwiftUI

/// Propriedades de acessibilidade modernas para componentes PrismUI
///
/// Este struct unifica todas as propriedades de acessibilidade em um único tipo,
/// facilitando testes de UI (XCUITest) e suporte a VoiceOver/TalkBack.
///
/// ## Uso Básico:
/// ```swift
/// PrismButton(
///     accessibility: .button(label: "Entrar", testID: "login_button")
/// ) {
///     PrismText("Entrar")
/// }
/// ```
///
/// ## Uso com Builder:
/// ```swift
/// PrismTextField(
///     text: $email,
///     accessibility: PrismAccessibilityConfig()
///         .label("Email")
///         .hint("Digite seu email")
///         .testID("email_field")
///         .traits([.searchField])
///         .build()
/// )
/// ```
public struct PrismAccessibilityProperties {
    /// Label descritivo para VoiceOver
    public var label: LocalizedStringKey

    /// Dica adicional (opcional)
    public var hint: LocalizedStringKey

    /// Identificador estável para XCUITest (NÃO localizável)
    public var testID: String

    /// Traits de acessibilidade (.button, .header, .image, etc.)
    public var traits: AccessibilityTraits

    /// Ações customizadas de acessibilidade
    public var actions: [PrismAccessibilityAction]

    /// Labels de input para formulários (accessibilityInputLabel)
    public var inputLabels: [LocalizedStringKey]

    /// Valor atual (para elementos que mudam)
    public var value: LocalizedStringKey?

    /// Se o elemento deve ser ignorado pela acessibilidade
    public var isHidden: Bool

    public init(
        label: LocalizedStringKey,
        hint: LocalizedStringKey = "",
        testID: String,
        traits: AccessibilityTraits = [],
        actions: [PrismAccessibilityAction] = [],
        inputLabels: [LocalizedStringKey] = [],
        value: LocalizedStringKey? = nil,
        isHidden: Bool = false
    ) {
        self.label = label
        self.hint = hint
        self.testID = testID
        self.traits = traits
        self.actions = actions
        self.inputLabels = inputLabels
        self.value = value
        self.isHidden = isHidden
    }
}

/// Ação de acessibilidade customizada para gestos e interações especiais
public struct PrismAccessibilityAction {
    public let name: LocalizedStringKey
    public let handler: @Sendable () -> Bool

    public init(name: LocalizedStringKey, handler: @Sendable @escaping () -> Bool) {
        self.name = name
        self.handler = handler
    }

    // MARK: - Predefinições

    public static func delete(handler: @Sendable @escaping () -> Bool) -> Self {
        Self(name: "Delete", handler: handler)
    }

    public static func adjust(handler: @Sendable @escaping () -> Bool) -> Self {
        Self(name: "Adjust", handler: handler)
    }

    public static func expand(handler: @Sendable @escaping () -> Bool) -> Self {
        Self(name: "Expand", handler: handler)
    }

    public static func collapse(handler: @Sendable @escaping () -> Bool) -> Self {
        Self(name: "Collapse", handler: handler)
    }

    public static func custom(_ name: LocalizedStringKey, handler: @Sendable @escaping () -> Bool) -> Self {
        Self(name: name, handler: handler)
    }
}

// MARK: - Conveniências Estáticas

public enum PrismAccessibility {

    // MARK: - Buttons

    public static func button(
        _ label: LocalizedStringKey,
        testID: String,
        hint: LocalizedStringKey? = nil
    ) -> PrismAccessibilityProperties {
        PrismAccessibilityProperties(
            label: label,
            hint: hint ?? "",
            testID: testID,
            traits: [.allowsDirectInteraction]
        )
    }

    // MARK: - Text Fields

    public static func textField(
        _ label: LocalizedStringKey,
        testID: String,
        hint: LocalizedStringKey? = nil,
        value: LocalizedStringKey? = nil
    ) -> PrismAccessibilityProperties {
        PrismAccessibilityProperties(
            label: label,
            hint: hint ?? "",
            testID: testID,
            traits: [.isStaticText],
            value: value
        )
    }

    // MARK: - Headers

    public static func header(
        _ label: LocalizedStringKey,
        testID: String,
        level: Int = 1
    ) -> PrismAccessibilityProperties {
        PrismAccessibilityProperties(
            label: label,
            testID: testID,
            traits: [.isHeader]
        )
    }

    // MARK: - Images

    public static func image(
        _ label: LocalizedStringKey,
        testID: String
    ) -> PrismAccessibilityProperties {
        PrismAccessibilityProperties(
            label: label,
            testID: testID,
            traits: []
        )
    }

    // MARK: - Text

    public static func text(
        _ label: LocalizedStringKey,
        testID: String,
        isHeader: Bool = false
    ) -> PrismAccessibilityProperties {
        PrismAccessibilityProperties(
            label: label,
            testID: testID,
            traits: isHeader ? [.isHeader] : []
        )
    }

    // MARK: - Groups

    public static func group(
        testID: String,
        label: LocalizedStringKey? = nil
    ) -> PrismAccessibilityProperties {
        PrismAccessibilityProperties(
            label: label ?? "",
            testID: testID,
            traits: []
        )
    }

    // MARK: - Custom

    public static func custom(
        label: LocalizedStringKey,
        testID: String,
        hint: LocalizedStringKey = "",
        traits: AccessibilityTraits = []
    ) -> PrismAccessibilityProperties {
        PrismAccessibilityProperties(
            label: label,
            hint: hint,
            testID: testID,
            traits: traits
        )
    }

    // MARK: - Hidden

    public static func hidden(testID: String) -> PrismAccessibilityProperties {
        PrismAccessibilityProperties(
            label: "",
            testID: testID,
            isHidden: true
        )
    }
}

// MARK: - Preview Support

#if DEBUG
    extension PrismAccessibilityProperties {
        public static var preview: Self {
            PrismAccessibilityProperties(
                label: "Preview Label",
                testID: "preview_test_id"
            )
        }
    }
#endif
