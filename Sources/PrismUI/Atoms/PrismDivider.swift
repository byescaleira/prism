//
//  PrismDivider.swift
//  Prism
//
//  Created by Rafael Escaleira on 27/04/26.
//

import SwiftUI

/// Semantic divider for the PrismUI Design System.
///
/// `PrismDivider` renders a thin separator line using the theme's border color.
/// It adapts its thickness and insets based on the current platform context.
///
/// ## Basic Usage
/// ```swift
/// PrismVStack {
///     PrismText("Section A")
///     PrismDivider()
///     PrismText("Section B")
/// }
/// ```
///
/// ## With Label
/// ```swift
/// PrismDivider(label: "or")
/// ```
///
/// - Note: On macOS the divider uses a 0.5pt line for Retina sharpness;
///   on all other platforms it uses the standard 1pt `Divider()`.
public struct PrismDivider: PrismView {
    @Environment(\.theme) private var theme
    @Environment(\.platformContext) private var platformContext

    private let label: String?
    public var accessibility: PrismAccessibilityProperties?

    /// Creates a plain separator line.
    public init() {
        self.label = nil
    }

    /// Creates a divider with a centered text label.
    ///
    /// - Parameter label: The text displayed between two line segments.
    public init(label: String) {
        self.label = label
    }

    public var body: some View {
        if let label {
            labeledDivider(label)
        } else {
            plainDivider
        }
    }

    private var plainDivider: some View {
        Rectangle()
            .fill(theme.color.border)
            .frame(height: lineHeight)
            .frame(maxWidth: .infinity)
    }

    private func labeledDivider(_ text: String) -> some View {
        HStack(spacing: 0) {
            plainDivider
            PrismText(text)
                .prism(font: .caption)
                .prism(color: .textSecondary)
                .prismPadding(.horizontal, .medium)
                .layoutPriority(1)
            plainDivider
        }
    }

    private var lineHeight: CGFloat {
        switch platformContext.platform {
        case .macOS:
            0.5
        default:
            1
        }
    }

    public static func mocked() -> some View {
        PrismDivider(label: "or")
            .prismPadding()
    }
}

#Preview("Plain") {
    PrismDivider()
        .prismPadding()
}

#Preview("With Label") {
    PrismDivider.mocked()
}
