import SwiftUI

/// Debug panel displaying all active design tokens from the current theme.
public struct PrismTokenInspector: View {
    @Environment(\.prismTheme) private var theme

    /// Creates a token inspector view.
    public init() {}

    /// The token inspector view body with categorized design token sections.
    public var body: some View {
        NavigationStack {
            List {
                colorSection
                typographySection
                spacingSection
                radiusSection
                elevationSection
            }
            .navigationTitle("Token Inspector")
        }
    }

    // MARK: - Color Swatches

    @ViewBuilder
    private var colorSection: some View {
        Section("Colors") {
            ForEach(ColorToken.allCases, id: \.rawValue) { token in
                HStack(spacing: SpacingToken.md.rawValue) {
                    RoundedRectangle(cornerRadius: RadiusToken.xs.rawValue)
                        .fill(theme.color(token))
                        .frame(width: 32, height: 32)
                        .overlay(
                            RoundedRectangle(cornerRadius: RadiusToken.xs.rawValue)
                                .strokeBorder(Color.primary.opacity(0.15), lineWidth: 1)
                        )
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: SpacingToken.xxs.rawValue) {
                        Text(token.rawValue)
                            .font(TypographyToken.body.font)
                        Text(token.rawValue)
                            .font(TypographyToken.caption.font)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()
                }
                .accessibilityLabel("\(token.rawValue) color token")
            }
        }
    }

    // MARK: - Typography Samples

    @ViewBuilder
    private var typographySection: some View {
        Section("Typography") {
            ForEach(TypographyToken.allCases, id: \.textStyle) { token in
                VStack(alignment: .leading, spacing: SpacingToken.xxs.rawValue) {
                    Text("Aa — \(String(describing: token))")
                        .font(token.font)
                    Text("weight: \(String(describing: token.defaultWeight))")
                        .font(TypographyToken.caption2.font)
                        .foregroundStyle(.secondary)
                }
                .accessibilityLabel("\(String(describing: token)) typography sample")
            }
        }
    }

    // MARK: - Spacing Rulers

    @ViewBuilder
    private var spacingSection: some View {
        Section("Spacing") {
            ForEach(SpacingToken.allCases, id: \.rawValue) { token in
                HStack(spacing: SpacingToken.md.rawValue) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.accentColor.opacity(0.5))
                        .frame(width: max(token.rawValue, 2), height: 16)
                        .accessibilityHidden(true)

                    Text("\(String(describing: token)) — \(Int(token.rawValue))pt")
                        .font(TypographyToken.caption.font)
                }
                .accessibilityLabel("\(String(describing: token)) spacing \(Int(token.rawValue)) points")
            }
        }
    }

    // MARK: - Radius Visual

    @ViewBuilder
    private var radiusSection: some View {
        Section("Radius") {
            ForEach(RadiusToken.allCases, id: \.rawValue) { token in
                HStack(spacing: SpacingToken.md.rawValue) {
                    RoundedRectangle(cornerRadius: min(token.rawValue, 20))
                        .strokeBorder(Color.accentColor, lineWidth: 2)
                        .frame(width: 40, height: 40)
                        .accessibilityHidden(true)

                    Text("\(String(describing: token)) — \(Int(token.rawValue))pt")
                        .font(TypographyToken.caption.font)
                }
                .accessibilityLabel("\(String(describing: token)) radius \(Int(token.rawValue)) points")
            }
        }
    }

    // MARK: - Elevation Shadows

    @ViewBuilder
    private var elevationSection: some View {
        Section("Elevation") {
            ForEach(ElevationToken.allCases, id: \.rawValue) { token in
                HStack(spacing: SpacingToken.md.rawValue) {
                    RoundedRectangle(cornerRadius: RadiusToken.sm.rawValue)
                        .fill(Color.white)
                        .frame(width: 40, height: 40)
                        .shadow(
                            color: .black.opacity(token.shadowOpacity),
                            radius: token.shadowRadius,
                            y: token.shadowY
                        )
                        .accessibilityHidden(true)

                    VStack(alignment: .leading) {
                        Text(String(describing: token))
                            .font(TypographyToken.caption.font)
                        Text("radius: \(Int(token.shadowRadius)), y: \(Int(token.shadowY))")
                            .font(TypographyToken.caption2.font)
                            .foregroundStyle(.secondary)
                    }
                }
                .accessibilityLabel("\(String(describing: token)) elevation shadow")
            }
        }
    }
}

// MARK: - View Modifier

/// Modifier that presents the token inspector as a sheet.
private struct PrismTokenInspectorModifier: ViewModifier {
    @Binding var isPresented: Bool

    func body(content: Content) -> some View {
        content.sheet(isPresented: $isPresented) {
            PrismTokenInspector()
        }
    }
}

extension View {
    /// Presents a debug sheet showing all active design tokens.
    public func prismTokenInspector(isPresented: Binding<Bool>) -> some View {
        modifier(PrismTokenInspectorModifier(isPresented: isPresented))
    }
}
