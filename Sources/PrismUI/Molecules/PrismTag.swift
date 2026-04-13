//
//  PrismTag.swift
//  Prism
//
//  Created by Rafael Escaleira on 04/07/25.
//

import SwiftUI

// MARK: - PrismTag

/// Uma tag/badge estilizada do Design System PrismUI.
///
/// `PrismTag` é usada para exibir labels categorizados com estilos visuais distintos.
/// Suporta ícones, botão de fechar, e múltiplos estilos (filled, outlined, success, error, etc.).
///
/// ## Uso Básico
/// ```swift
/// PrismTag("Swift")
/// ```
///
/// ## Com testID
/// ```swift
/// PrismTag("Swift", testID: "language_tag")
/// ```
///
/// ## Com Ícone
/// ```swift
/// PrismTag("Swift", icon: "swift")
/// ```
///
/// ## Closable (com botão de fechar)
/// ```swift
/// PrismTag("Tag", onClose: { isPresented = false })
/// ```
///
/// ## Estilos Disponíveis
/// - `.filled` - Preenchido com cor primária
/// - `.outlined` - Apenas borda
/// - `.ghost` - Sem fundo, texto secundário
/// - `.success`, `.error`, `.warning`, `.info` - Cores semânticas
///
/// ## Tamanhos Disponíveis
/// - `.small`, `.medium`, `.large`
///
/// - Note: Tags com `onClose` exibem automaticamente um botão "x" para dismiss.
public struct PrismTag: PrismView {
    @Environment(\.theme) private var theme

    // MARK: - Properties

    let text: String
    let style: Style
    let size: Size
    let icon: String?
    let onClose: (() -> Void)?

    public var accessibility: PrismAccessibilityProperties?

    // MARK: - Initialization

    public init(
        _ text: String,
        style: Style = .filled,
        size: Size = .medium,
        icon: String? = nil,
        onClose: (() -> Void)? = nil,
        accessibility: PrismAccessibilityProperties? = nil
    ) {
        self.text = text
        self.style = style
        self.size = size
        self.icon = icon
        self.onClose = onClose
        self.accessibility = accessibility
    }

    public init(
        _ text: String,
        testID: String,
        style: Style = .filled,
        size: Size = .medium,
        icon: String? = nil,
        onClose: (() -> Void)? = nil
    ) {
        self.text = text
        self.style = style
        self.size = size
        self.icon = icon
        self.onClose = onClose
        self.accessibility = PrismAccessibility.custom(label: LocalizedStringKey(stringLiteral: text), testID: testID)
    }

    // MARK: - Body

    public var body: some View {
        HStack(spacing: size.iconSpacing) {
            if let icon {
                PrismSymbol(icon)
                    .prism(font: size.iconFont)
            }

            PrismText(text)
                .prism(font: size.font)

            if let onClose {
                Button(action: onClose) {
                    PrismSymbol("xmark")
                        .prism(font: size.iconFont)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, size.horizontalPadding)
        .padding(.vertical, size.verticalPadding)
        .background(backgroundColor)
        .foregroundStyle(foregroundColor)
        .clipShape(.capsule)
        .overlay(
            RoundedRectangle(cornerRadius: size.cornerRadius)
                .stroke(borderColor, lineWidth: 1)
        )
        .prism(accessibility)
    }

    // MARK: - Computed Colors

    @MainActor
    private var backgroundColor: some ShapeStyle {
        switch style {
        case .filled:
            return theme.color.primary.opacity(0.15)
        case .outlined, .ghost:
            return Color.clear
        case .success:
            return theme.color.success.opacity(0.15)
        case .error:
            return theme.color.error.opacity(0.15)
        case .warning:
            return theme.color.warning.opacity(0.15)
        case .info:
            return theme.color.info.opacity(0.15)
        }
    }

    @MainActor
    private var foregroundColor: some ShapeStyle {
        switch style {
        case .filled, .success, .error, .warning, .info:
            return primaryColor
        case .outlined:
            return theme.color.borderStrong
        case .ghost:
            return theme.color.textSecondary
        }
    }

    @MainActor
    private var borderColor: Color {
        switch style {
        case .filled, .ghost:
            return .clear
        case .outlined:
            return theme.color.border
        case .success:
            return theme.color.success.opacity(0.3)
        case .error:
            return theme.color.error.opacity(0.3)
        case .warning:
            return theme.color.warning.opacity(0.3)
        case .info:
            return theme.color.info.opacity(0.3)
        }
    }

    @MainActor
    private var primaryColor: Color {
        switch style {
        case .filled:
            return theme.color.primary
        case .success:
            return theme.color.success
        case .error:
            return theme.color.error
        case .warning:
            return theme.color.warning
        case .info:
            return theme.color.info
        case .outlined, .ghost:
            return theme.color.text
        }
    }

    // MARK: - Style

    public enum Style: Sendable {
        case filled
        case outlined
        case ghost
        case success
        case error
        case warning
        case info
    }

    // MARK: - Size

    public enum Size: Sendable {
        case small
        case medium
        case large

        var horizontalPadding: CGFloat {
            switch self {
            case .small: 6
            case .medium: 10
            case .large: 14
            }
        }

        var verticalPadding: CGFloat {
            switch self {
            case .small: 2
            case .medium: 4
            case .large: 6
            }
        }

        var iconSpacing: CGFloat {
            switch self {
            case .small: 2
            case .medium: 4
            case .large: 6
            }
        }

        var cornerRadius: CGFloat {
            switch self {
            case .small: 6
            case .medium: 8
            case .large: 12
            }
        }

        var font: Font {
            switch self {
            case .small: .caption2
            case .medium: .caption
            case .large: .footnote
            }
        }

        var iconFont: Font {
            switch self {
            case .small: .caption2
            case .medium: .caption
            case .large: .footnote
            }
        }
    }

    // MARK: - Convenience Initializers

    public static func filled(_ text: String, icon: String? = nil) -> PrismTag {
        PrismTag(text, style: .filled, icon: icon)
    }

    public static func outlined(_ text: String, icon: String? = nil) -> PrismTag {
        PrismTag(text, style: .outlined, icon: icon)
    }

    public static func ghost(_ text: String, icon: String? = nil) -> PrismTag {
        PrismTag(text, style: .ghost, icon: icon)
    }

    public static func success(_ text: String, icon: String? = nil) -> PrismTag {
        PrismTag(text, style: .success, icon: icon)
    }

    public static func error(_ text: String, icon: String? = nil) -> PrismTag {
        PrismTag(text, style: .error, icon: icon)
    }

    public static func warning(_ text: String, icon: String? = nil) -> PrismTag {
        PrismTag(text, style: .warning, icon: icon)
    }

    public static func info(_ text: String, icon: String? = nil) -> PrismTag {
        PrismTag(text, style: .info, icon: icon)
    }

    // MARK: - Mock

    public static func mocked() -> some View {
        PrismTag("Tag", style: .filled, size: .medium)
    }
}

// MARK: - Preview

#Preview("Styles") {
    PrismVStack(spacing: .medium) {
        PrismHStack {
            PrismTag("Filled", style: PrismTag.Style.filled)
            PrismTag("Outlined", style: PrismTag.Style.outlined)
            PrismTag("Ghost", style: PrismTag.Style.ghost)
        }
        PrismHStack {
            PrismTag("Success", style: PrismTag.Style.success)
            PrismTag("Error", style: PrismTag.Style.error)
            PrismTag("Warning", style: PrismTag.Style.warning)
            PrismTag("Info", style: PrismTag.Style.info)
        }
    }
    .prismPadding()
}

#Preview("Sizes") {
    PrismVStack(spacing: .medium) {
        PrismTag("Small", size: PrismTag.Size.small)
        PrismTag("Medium", size: PrismTag.Size.medium)
        PrismTag("Large", size: PrismTag.Size.large)
    }
    .prismPadding()
}

#Preview("With Icon") {
    PrismTag("Swift", icon: "swift")
        .prismPadding()
}

#Preview("Closable") {
    @Previewable @State var isPresented = true
    PrismVStack {
        if isPresented {
            PrismTag("Closable", onClose: { isPresented = false })
        }
    }
    .prismPadding()
}
