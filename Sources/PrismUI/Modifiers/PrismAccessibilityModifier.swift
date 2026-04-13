//
//  PrismAccessibilityModifier.swift
//  Prism
//
//  Created by Rafael Escaleira on 09/04/26.
//

import SwiftUI

/// Modificador que aplica todas as propriedades de acessibilidade de forma unificada
struct PrismAccessibilityModifier: ViewModifier {
    let properties: PrismAccessibilityProperties

    public func body(content: Content) -> some View {
        let identifiedContent: some View = Group {
            if properties.testID.isEmpty {
                content
            } else {
                content.accessibilityIdentifier(properties.testID)
            }
        }

        let base =
            identifiedContent
            .accessibilityAddTraits(properties.traits)
            .accessibilityValue(properties.value ?? "")
            .accessibilityHidden(properties.isHidden)
            .accessibilityLabel(properties.label)
            .accessibilityHint(properties.hint)

        return properties.actions.reduce(base) { view, action in
            view.accessibilityAction(named: action.name) {
                _ = action.handler()
            }
        }
    }
}

// MARK: - View Extension

extension View {
    /// Aplica propriedades de acessibilidade completas a uma view
    ///
    /// - Parameter properties: Configuração de acessibilidade
    /// - Returns: View modificada com todas as propriedades de acessibilidade
    public func prism(accessibility properties: PrismAccessibilityProperties) -> some View {
        modifier(PrismAccessibilityModifier(properties: properties))
    }

    /// Aplica propriedades de acessibilidade usando builder pattern
    ///
    /// - Parameter builder: Closure que configura PrismAccessibilityConfig
    /// - Returns: View modificada com todas as propriedades de acessibilidade
    ///
    /// ## Exemplo:
    /// ```swift
    /// PrismTextField(text: $email)
    ///     .prism(accessibility: {
    ///         $0.label("Email")
    ///             .hint("Digite seu email")
    ///             .testID("email_field")
    ///             .asSearchField()
    ///     })
    /// ```
    public func prism(accessibility builder: (PrismAccessibilityConfig) -> PrismAccessibilityConfig) -> some View {
        let config = builder(PrismAccessibilityConfig())
        return prism(accessibility: config.build())
    }

    /// Atalho para definir apenas testID
    public func prism(testID: String) -> some View {
        prism(accessibility: PrismAccessibility.custom(label: "", testID: testID))
    }

    /// Atalho para definir apenas label de acessibilidade
    public func prism(accessibilityLabel label: LocalizedStringKey) -> some View {
        prism(accessibility: PrismAccessibility.custom(label: label, testID: ""))
    }

    /// Atalho para definir label e hint
    public func prism(accessibilityLabel label: LocalizedStringKey, hint: LocalizedStringKey) -> some View {
        prism(accessibility: PrismAccessibility.custom(label: label, testID: "", hint: hint))
    }
}

// MARK: - Accessibility Action Conveniences

extension View {
    /// Adiciona ação de delete para acessibilidade
    public func prismAccessibilityDelete(handler: @escaping () -> Bool) -> some View {
        accessibilityAction(named: "Delete") {
            _ = handler()
        }
    }

    /// Adiciona ação de adjust para acessibilidade
    public func prismAccessibilityAdjust(handler: @escaping () -> Bool) -> some View {
        accessibilityAction(named: "Adjust") {
            _ = handler()
        }
    }
}
