import SwiftUI

#if os(watchOS)
    /// Themed watch complication view with token-based styling.
    ///
    /// ```swift
    /// PrismComplicationGauge(value: 0.7, label: "Steps")
    /// PrismComplicationText(title: "68°", subtitle: "Sunny")
    /// ```
    public struct PrismComplicationGauge: View {
        @Environment(\.prismTheme) private var theme

        private let value: Double
        private let label: LocalizedStringKey
        private let icon: String?

        /// Creates a gauge complication with the given value and label.
        public init(
            value: Double,
            label: LocalizedStringKey,
            icon: String? = nil
        ) {
            self.value = value
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
            }
            .gaugeStyle(.accessoryCircular)
            .tint(theme.color(.interactive))
        }
    }

    /// Themed text complication showing a title with optional subtitle.
    public struct PrismComplicationText: View {
        @Environment(\.prismTheme) private var theme

        private let title: LocalizedStringKey
        private let subtitle: LocalizedStringKey?

        /// Creates a text complication with the given title and optional subtitle.
        public init(title: LocalizedStringKey, subtitle: LocalizedStringKey? = nil) {
            self.title = title
            self.subtitle = subtitle
        }

        /// The view body.
        public var body: some View {
            VStack(spacing: 2) {
                Text(title)
                    .font(TypographyToken.headline.font)
                    .foregroundStyle(theme.color(.onBackground))
                if let subtitle {
                    Text(subtitle)
                        .font(TypographyToken.caption2.font)
                        .foregroundStyle(theme.color(.onBackgroundSecondary))
                }
            }
        }
    }
#endif
