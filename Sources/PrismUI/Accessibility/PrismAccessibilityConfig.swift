//
//  PrismAccessibilityConfig.swift
//  Prism
//
//  Created by Rafael Escaleira on 09/04/26.
//

import SwiftUI

/// Builder fluente para criar propriedades de acessibilidade
///
/// ## Exemplo de uso:
/// ```swift
/// PrismTextField(
///     text: $email,
///     accessibility: PrismAccessibilityConfig()
///         .label("Email")
///         .hint("Digite seu email corporativo")
///         .testID("email_field")
///         .traits([.searchField, .updatesFrequently])
///         .build()
/// )
/// ```
public struct PrismAccessibilityConfig {
    private var label: LocalizedStringKey = ""
    private var hint: LocalizedStringKey = ""
    private var testID: String = ""
    private var traits: AccessibilityTraits = []
    private var actions: [PrismAccessibilityAction] = []
    private var inputLabels: [LocalizedStringKey] = []
    private var value: LocalizedStringKey?
    private var isHidden: Bool = false

    public init() {}

    // MARK: - Required

    @discardableResult
    public func label(_ label: LocalizedStringKey) -> Self {
        var copy = self
        copy.label = label
        return copy
    }

    @discardableResult
    public func testID(_ testID: String) -> Self {
        var copy = self
        copy.testID = testID
        return copy
    }

    // MARK: - Optional

    @discardableResult
    public func hint(_ hint: LocalizedStringKey) -> Self {
        var copy = self
        copy.hint = hint
        return copy
    }

    @discardableResult
    public func traits(_ traits: AccessibilityTraits) -> Self {
        var copy = self
        copy.traits = traits
        return copy
    }

    @discardableResult
    public func traits(_ traits: AccessibilityTraits...) -> Self {
        var copy = self
        copy.traits = AccessibilityTraits(traits)
        return copy
    }

    @discardableResult
    public func action(_ action: PrismAccessibilityAction) -> Self {
        var copy = self
        copy.actions.append(action)
        return copy
    }

    @discardableResult
    public func actions(_ actions: [PrismAccessibilityAction]) -> Self {
        var copy = self
        copy.actions.append(contentsOf: actions)
        return copy
    }

    @discardableResult
    public func inputLabels(_ labels: [LocalizedStringKey]) -> Self {
        var copy = self
        copy.inputLabels = labels
        return copy
    }

    @discardableResult
    public func inputLabel(_ label: LocalizedStringKey) -> Self {
        var copy = self
        copy.inputLabels.append(label)
        return copy
    }

    @discardableResult
    public func value(_ value: LocalizedStringKey) -> Self {
        var copy = self
        copy.value = value
        return copy
    }

    @discardableResult
    public func isHidden(_ isHidden: Bool) -> Self {
        var copy = self
        copy.isHidden = isHidden
        return copy
    }

    // MARK: - Conveniências

    @discardableResult
    public func asButton() -> Self {
        var copy = self
        copy.traits.formUnion(.allowsDirectInteraction)
        return copy
    }

    @discardableResult
    public func asHeader(_ level: Int = 1) -> Self {
        var copy = self
        copy.traits.formUnion(.isHeader)
        return copy
    }

    @discardableResult
    public func asImage() -> Self {
        var copy = self
        copy.traits.formUnion(.isImage)
        return copy
    }

    @discardableResult
    public func asSearchField() -> Self {
        var copy = self
        copy.traits.formUnion(.isStaticText)
        return copy
    }

    @discardableResult
    public func asAdjustable() -> Self {
        var copy = self
        copy.traits.formUnion(.updatesFrequently)
        return copy
    }

    @discardableResult
    public func updatesFrequently() -> Self {
        var copy = self
        copy.traits.formUnion(.updatesFrequently)
        return copy
    }

    // MARK: - Build

    public func build() -> PrismAccessibilityProperties {
        PrismAccessibilityProperties(
            label: label,
            hint: hint,
            testID: testID,
            traits: traits,
            actions: actions,
            inputLabels: inputLabels,
            value: value,
            isHidden: isHidden
        )
    }
}

// MARK: - Result Builder

@resultBuilder
public enum PrismAccessibilityBuilder {
    public static func buildBlock(_ components: PrismAccessibilityProperties...) -> [PrismAccessibilityProperties] {
        components
    }

    public static func buildOptional(_ component: PrismAccessibilityProperties?) -> PrismAccessibilityProperties? {
        component
    }

    public static func buildEither(first component: PrismAccessibilityProperties) -> PrismAccessibilityProperties {
        component
    }

    public static func buildEither(second component: PrismAccessibilityProperties) -> PrismAccessibilityProperties {
        component
    }

    public static func buildArray(_ components: [PrismAccessibilityProperties]) -> [PrismAccessibilityProperties] {
        components
    }
}
