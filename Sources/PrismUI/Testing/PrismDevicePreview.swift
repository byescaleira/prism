import SwiftUI

/// Multi-device preview matrix for testing component layout across screen sizes.
///
/// ```swift
/// #Preview {
///     PrismDevicePreview {
///         PrismButton("Tap me", variant: .filled) {}
///     }
/// }
/// ```
public struct PrismDevicePreview<Content: View>: View {
    private let content: Content

    /// Creates a device preview matrix with the given content.
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    /// The view body.
    public var body: some View {
        ScrollView {
            VStack(spacing: SpacingToken.xl.rawValue) {
                sizePreview("iPhone SE (375×667)", width: 375, height: 667)
                sizePreview("iPhone 16 (393×852)", width: 393, height: 852)
                sizePreview("iPhone 16 Pro Max (430×932)", width: 430, height: 932)
                sizePreview("iPad Mini (744×1133)", width: 744, height: 500)
                sizePreview("iPad Pro 13\" (1032×1376)", width: 1032, height: 400)
            }
            .padding(SpacingToken.lg.rawValue)
        }
    }

    @ViewBuilder
    private func sizePreview(_ label: String, width: CGFloat, height: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: SpacingToken.xs.rawValue) {
            Text(label)
                .font(TypographyToken.caption.font(weight: .medium))
                .foregroundStyle(.secondary)

            content
                .frame(width: width, height: height)
                .clipped()
                .border(Color.secondary.opacity(0.3))
        }
    }
}

/// Locale/RTL preview matrix for testing localization.
///
/// ```swift
/// #Preview {
///     PrismLocalePreview {
///         PrismButton("Save", variant: .filled) {}
///     }
/// }
/// ```
public struct PrismLocalePreview<Content: View>: View {
    private let content: Content

    /// Creates a locale preview matrix with the given content.
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    /// The view body.
    public var body: some View {
        ScrollView {
            VStack(spacing: SpacingToken.xl.rawValue) {
                localeBlock("LTR (English)") {
                    content
                        .environment(\.layoutDirection, .leftToRight)
                }

                localeBlock("RTL (Arabic)") {
                    content
                        .environment(\.layoutDirection, .rightToLeft)
                }

                localeBlock("Extra Large Text") {
                    content
                        .dynamicTypeSize(.accessibility3)
                }

                localeBlock("Extra Small Text") {
                    content
                        .dynamicTypeSize(.xSmall)
                }
            }
            .padding(SpacingToken.lg.rawValue)
        }
    }

    @ViewBuilder
    private func localeBlock<V: View>(_ title: String, @ViewBuilder content: () -> V) -> some View {
        VStack(alignment: .leading, spacing: SpacingToken.xs.rawValue) {
            Text(title)
                .font(TypographyToken.caption.font(weight: .medium))
                .foregroundStyle(.secondary)

            content()
                .padding(SpacingToken.md.rawValue)
                .background(.quaternary, in: RadiusToken.md.shape)
        }
    }
}
