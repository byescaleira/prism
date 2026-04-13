//
//  RyzeSection.swift
//  Ryze
//
//  Created by Rafael Escaleira on 06/06/25.
//

import RyzeFoundation
import SwiftUI

/// Seção de lista do Design System RyzeUI.
///
/// `RyzeSection` é um wrapper do `Section` nativo com:
/// - Header e footer opcionais
/// - Suporte a strings localizadas via `RyzeResourceString`
/// - Header automático em uppercase para estilo de lista
/// - Acessibilidade completa (VoiceOver/TalkBack)
/// - Testes de UI (XCUITest) via testIDs estáveis
///
/// ## Uso Básico
/// ```swift
/// RyzeSection {
///     RyzeBodyText("Conteúdo da seção")
/// }
/// ```
///
/// ## Com Header e Footer
/// ```swift
/// RyzeSection(
///     header: RyzeUIString.sectionTitle,
///     footer: RyzeUIString.sectionDescription
/// ) {
///     RyzeBodyText("Conteúdo")
/// }
/// ```
///
/// ## Com Header Personalizado
/// ```swift
/// RyzeSection {
///     RyzeBodyText("Conteúdo")
/// } header: {
///     RyzeText("Título")
///         .ryze(font: .headline)
/// }
/// ```
///
/// ## Com testID para Testes
/// ```swift
/// RyzeSection(testID: "settings_section") {
///     RyzeBodyText("Configurações")
/// }
/// ```
///
/// - Note: O header automático usa `.footnote` font e `.textSecondary` color em uppercase.
public struct RyzeSection: RyzeView {
    let header: any View
    let content: any View
    let footer: any View
    public var accessibility: RyzeAccessibilityProperties?

    public init(
        _ accessibility: RyzeAccessibilityProperties? = nil,
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
        header: RyzeResourceString? = nil,
        footer: RyzeResourceString? = nil,
        @ViewBuilder content: () -> some View
    ) {
        self.content = content()
        self.header =
            header == nil
            ? EmptyView()
            : RyzeText(header?.value.uppercased())
                .ryze(font: .footnote)
                .ryze(color: .textSecondary)

        self.footer =
            footer == nil
            ? EmptyView()
            : RyzeText(footer)
                .ryze(font: .footnote)
                .ryze(color: .textSecondary)
    }

    public init(
        testID: String,
        @ViewBuilder content: () -> some View
    ) {
        self.accessibility = RyzeAccessibility.custom(label: "", testID: testID)
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
        RyzeSection(
            header: RyzeUIString.ryzePreviewTitle,
            footer: RyzeUIString.ryzePreviewDescription
        ) {
            RyzeBodyText.mocked()
            RyzeHStack.mocked()
            RyzeFootnoteText.mocked()
        }
    }
}

#Preview {
    RyzeSection.mocked()
}
