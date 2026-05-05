import SwiftUI

/// WidgetKit-compatible container that applies theme tokens in widget context.
///
/// Widgets can't use environment-based theming, so this applies token colors directly.
///
/// ```swift
/// struct MyWidget: Widget {
///     var body: some WidgetConfiguration {
///         StaticConfiguration(...) { entry in
///             PrismWidgetView {
///                 VStack {
///                     Text(entry.title)
///                         .prismFont(.headline)
///                 }
///             }
///         }
///     }
/// }
/// ```
public struct PrismWidgetView<Content: View>: View {
    private let theme: any PrismTheme
    private let content: Content

    /// Creates a widget container with an optional theme override.
    public init(
        theme: any PrismTheme = DefaultTheme(),
        @ViewBuilder content: () -> Content
    ) {
        self.theme = theme
        self.content = content()
    }

    /// The view body.
    public var body: some View {
        content
            .environment(\.prismTheme, theme)
    }
}

/// Gauge-style circular progress for widgets.
public struct PrismWidgetGauge: View {
    @Environment(\.prismTheme) private var theme

    private let value: Double
    private let label: LocalizedStringKey
    private let icon: String?

    /// Creates a widget gauge with the given value (0-1), label, and optional icon.
    public init(
        value: Double,
        label: LocalizedStringKey,
        icon: String? = nil
    ) {
        self.value = min(max(value, 0), 1)
        self.label = label
        self.icon = icon
    }

    /// The view body.
    public var body: some View {
        Gauge(value: value) {
            if let icon {
                Image(systemName: icon)
            } else {
                Text(label)
            }
        } currentValueLabel: {
            Text("\(Int(value * 100))%")
                .font(TypographyToken.caption.font(weight: .semibold))
        }
        .gaugeStyle(.accessoryCircular)
        .tint(gaugeColor)
    }

    private var gaugeColor: Color {
        if value >= 0.8 { return theme.color(.success) }
        if value >= 0.4 { return theme.color(.interactive) }
        return theme.color(.warning)
    }
}

/// Compact stat display optimized for widget layouts.
public struct PrismWidgetStat: View {
    @Environment(\.prismTheme) private var theme

    private let title: LocalizedStringKey
    private let value: String
    private let icon: String?
    private let trend: Trend?

    /// Creates a widget stat display with a title, formatted value, and optional trend.
    public init(
        _ title: LocalizedStringKey,
        value: String,
        icon: String? = nil,
        trend: Trend? = nil
    ) {
        self.title = title
        self.value = value
        self.icon = icon
        self.trend = trend
    }

    /// The view body.
    public var body: some View {
        VStack(alignment: .leading, spacing: SpacingToken.xxs.rawValue) {
            HStack(spacing: SpacingToken.xs.rawValue) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 12))
                        .foregroundStyle(theme.color(.interactive))
                }
                Text(title)
                    .font(TypographyToken.caption.font)
                    .foregroundStyle(theme.color(.onBackgroundSecondary))
            }

            HStack(spacing: SpacingToken.xs.rawValue) {
                Text(value)
                    .font(TypographyToken.title2.font(weight: .bold))
                    .foregroundStyle(theme.color(.onBackground))
                    .contentTransition(.numericText())

                if let trend {
                    Image(systemName: trend.icon)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(trend.color(theme))
                }
            }
        }
    }

    /// The directional trend shown alongside a stat value.
    public enum Trend: Sendable {
        case up, down, flat

        var icon: String {
            switch self {
            case .up: "arrow.up.right"
            case .down: "arrow.down.right"
            case .flat: "arrow.right"
            }
        }

        @MainActor
        func color(_ theme: any PrismTheme) -> Color {
            switch self {
            case .up: theme.color(.success)
            case .down: theme.color(.error)
            case .flat: theme.color(.onBackgroundSecondary)
            }
        }
    }
}
