//
//  PrismSection.swift
//  Prism
//
//  Created by Rafael Escaleira on 06/06/25.
//

import PrismFoundation
import SwiftUI

/// Seção de lista do Design System PrismUI.
///
/// `PrismSection` é um wrapper do `Section` nativo com:
/// - Header e footer opcionais
/// - Suporte a strings localizadas via `PrismResourceString`
/// - Header automático em uppercase para estilo de lista
/// - Acessibilidade completa (VoiceOver/TalkBack)
/// - Testes de UI (XCUITest) via testIDs estáveis
///
/// ## Uso Básico
/// ```swift
/// PrismSection {
///     PrismBodyText("Conteúdo da seção")
/// }
/// ```
///
/// ## Com Header e Footer
/// ```swift
/// PrismSection(
///     header: PrismUIString.sectionTitle,
///     footer: PrismUIString.sectionDescription
/// ) {
///     PrismBodyText("Conteúdo")
/// }
/// ```
///
/// ## Com Header Personalizado
/// ```swift
/// PrismSection {
///     PrismBodyText("Conteúdo")
/// } header: {
///     PrismText("Título")
///         .prism(font: .headline)
/// }
/// ```
///
/// ## Com testID para Testes
/// ```swift
/// PrismSection(testID: "settings_section") {
///     PrismBodyText("Configurações")
/// }
/// ```
///
/// - Note: O header automático usa `.footnote` font e `.textSecondary` color em uppercase.
public struct PrismSection: PrismView {
    let header: any View
    let content: any View
    let footer: any View
    public var accessibility: PrismAccessibilityProperties?

    public init(
        _ accessibility: PrismAccessibilityProperties? = nil,
        @ViewBuilder header: () -> some View,
        @ViewBuilder content: () -> some View,
        @ViewBuilder footer: () -> some View
    ) {
        self.accessibility = accessibility
        self.header = header()
        self.content = content()
        self.footer = footer()
    }

    public init(@ViewBuilder content: () -> some View) {
        self.content = content()
        self.header = EmptyView()
        self.footer = EmptyView()
    }

    public init(
        @ViewBuilder content: () -> some View,
        @ViewBuilder header: () -> some View
    ) {
        self.content = content()
        self.header = header()
        self.footer = EmptyView()
    }

    public init(
        @ViewBuilder content: () -> some View,
        @ViewBuilder footer: () -> some View
    ) {
        self.content = content()
        self.header = EmptyView()
        self.footer = footer()
    }

    public init(
        header: PrismResourceString? = nil,
        footer: PrismResourceString? = nil,
        @ViewBuilder content: () -> some View
    ) {
        self.content = content()
        self.header =
            header == nil
            ? EmptyView()
            : PrismText(header?.value.uppercased())
                .prism(font: .footnote)
                .prism(color: .textSecondary)

        self.footer =
            footer == nil
            ? EmptyView()
            : PrismText(footer)
                .prism(font: .footnote)
                .prism(color: .textSecondary)
    }

    public init(
        testID: String,
        @ViewBuilder content: () -> some View
    ) {
        self.accessibility = PrismAccessibility.custom(label: "", testID: testID)
        self.content = content()
        self.header = EmptyView()
        self.footer = EmptyView()
    }

    public var body: some View {
        Section {
            AnyView(content)
        } header: {
            AnyView(header)
        } footer: {
            AnyView(footer)
        }
    }

    public static func mocked() -> some View {
        PrismSection(
            header: PrismUIString.prismPreviewTitle,
            footer: PrismUIString.prismPreviewDescription
        ) {
            PrismBodyText.mocked()
            PrismHStack.mocked()
            PrismFootnoteText.mocked()
        }
    }
}

#Preview {
    PrismSection.mocked()
}
