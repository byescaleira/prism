import SwiftUI

/// Captures a snapshot of the current SwiftUI environment values.
public struct PrismEnvironmentSnapshot: Sendable {
    /// The current color scheme (light/dark).
    public let colorScheme: ColorScheme
    /// The current dynamic type size.
    public let dynamicTypeSize: DynamicTypeSize
    /// The current layout direction (LTR/RTL).
    public let layoutDirection: LayoutDirection
    /// Whether accessibility features are enabled.
    public let accessibilityEnabled: Bool
    /// Whether reduce motion is active.
    public let reduceMotion: Bool
    /// Whether reduce transparency is active.
    public let reduceTransparency: Bool

    /// Creates a snapshot with explicit environment values.
    public init(
        colorScheme: ColorScheme,
        dynamicTypeSize: DynamicTypeSize,
        layoutDirection: LayoutDirection,
        accessibilityEnabled: Bool,
        reduceMotion: Bool,
        reduceTransparency: Bool
    ) {
        self.colorScheme = colorScheme
        self.dynamicTypeSize = dynamicTypeSize
        self.layoutDirection = layoutDirection
        self.accessibilityEnabled = accessibilityEnabled
        self.reduceMotion = reduceMotion
        self.reduceTransparency = reduceTransparency
    }
}

/// Displays the current environment values in a debug panel.
public struct PrismEnvironmentDebugger: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.layoutDirection) private var layoutDirection
    @Environment(\.accessibilityEnabled) private var accessibilityEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    /// Creates an environment debugger view.
    public init() {}

    /// Returns a snapshot of the current environment.
    public var snapshot: PrismEnvironmentSnapshot {
        PrismEnvironmentSnapshot(
            colorScheme: colorScheme,
            dynamicTypeSize: dynamicTypeSize,
            layoutDirection: layoutDirection,
            accessibilityEnabled: accessibilityEnabled,
            reduceMotion: reduceMotion,
            reduceTransparency: reduceTransparency
        )
    }

    /// The environment debugger view body listing current settings.
    public var body: some View {
        List {
            Section("Environment") {
                row(
                    label: "Color Scheme",
                    value: colorScheme == .dark ? "Dark" : "Light",
                    icon: "circle.lefthalf.filled"
                )
                row(
                    label: "Dynamic Type",
                    value: String(describing: dynamicTypeSize),
                    icon: "textformat.size"
                )
                row(
                    label: "Layout Direction",
                    value: layoutDirection == .rightToLeft ? "RTL" : "LTR",
                    icon: "text.alignleft"
                )
            }

            Section("Accessibility") {
                row(
                    label: "VoiceOver",
                    value: accessibilityEnabled ? "On" : "Off",
                    icon: "accessibility"
                )
                row(
                    label: "Reduce Motion",
                    value: reduceMotion ? "On" : "Off",
                    icon: "figure.walk"
                )
                row(
                    label: "Reduce Transparency",
                    value: reduceTransparency ? "On" : "Off",
                    icon: "square.on.square"
                )
            }
        }
        .accessibilityLabel("Environment debugger")
    }

    @ViewBuilder
    private func row(label: String, value: String, icon: String) -> some View {
        HStack {
            Label(label, systemImage: icon)
                .font(TypographyToken.body.font)
            Spacer()
            Text(value)
                .font(TypographyToken.body.font(weight: .medium, design: .monospaced))
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }
}

// MARK: - Floating Badge Modifier

/// Modifier that adds a small floating badge with key environment values.
private struct PrismEnvironmentDebugBadge: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        #if DEBUG
            content.overlay(alignment: .bottomTrailing) {
                HStack(spacing: 4) {
                    Image(systemName: colorScheme == .dark ? "moon.fill" : "sun.max.fill")
                        .font(.system(size: 9))
                    Text(String(describing: dynamicTypeSize))
                        .font(.system(size: 8, weight: .medium, design: .monospaced))
                    if reduceMotion {
                        Image(systemName: "figure.walk")
                            .font(.system(size: 9))
                    }
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(.black.opacity(0.7))
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                .padding(8)
                .allowsHitTesting(false)
            }
        #else
            content
        #endif
    }
}

extension View {
    /// Adds a small floating badge showing key environment values in DEBUG builds.
    public func prismEnvironmentDebug() -> some View {
        modifier(PrismEnvironmentDebugBadge())
    }
}
