import SwiftUI

/// Determinate or indeterminate progress bar with label support.
public struct PrismProgressBar: View {
    @Environment(\.prismTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let value: Double?
    private let total: Double
    private let label: LocalizedStringKey?

    @State private var indeterminateOffset: CGFloat = -1

    /// Determinate progress bar.
    public init(
        value: Double,
        total: Double = 1.0,
        label: LocalizedStringKey? = nil
    ) {
        self.value = value
        self.total = total
        self.label = label
    }

    /// Indeterminate progress bar.
    public init(label: LocalizedStringKey? = nil) {
        self.value = nil
        self.total = 1.0
        self.label = label
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: SpacingToken.xs.rawValue) {
            if let label {
                HStack {
                    Text(label)
                        .font(TypographyToken.caption.font(weight: .medium))
                        .foregroundStyle(theme.color(.onBackgroundSecondary))
                    Spacer()
                    if let value {
                        Text("\(Int(clampedProgress * 100))%")
                            .font(TypographyToken.caption.font(weight: .medium))
                            .foregroundStyle(theme.color(.onBackgroundSecondary))
                    }
                }
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    trackShape
                    if let value {
                        determinateFill(width: geometry.size.width)
                    } else {
                        indeterminateFill(width: geometry.size.width)
                    }
                }
            }
            .frame(height: 6)
            .accessibilityElement()
            .accessibilityValue(accessibilityText)
            .accessibilityLabel(label ?? "Progress")
        }
    }

    private var trackShape: some View {
        Capsule()
            .fill(theme.color(.surfaceSecondary))
    }

    private func determinateFill(width: CGFloat) -> some View {
        Capsule()
            .fill(theme.color(.interactive))
            .frame(width: max(width * clampedProgress, 6))
            .animation(
                reduceMotion ? nil : MotionToken.normal.animation,
                value: value
            )
    }

    private func indeterminateFill(width: CGFloat) -> some View {
        Capsule()
            .fill(theme.color(.interactive))
            .frame(width: width * 0.3)
            .offset(x: indeterminateOffset * width * 0.7)
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(
                    .easeInOut(duration: 1.2)
                    .repeatForever(autoreverses: true)
                ) {
                    indeterminateOffset = 1
                }
            }
    }

    private var clampedProgress: Double {
        guard let value else { return 0 }
        return min(max(value / total, 0), 1)
    }

    private var accessibilityText: String {
        if let value {
            "\(Int(min(max(value / total, 0), 1) * 100)) percent"
        } else {
            "In progress"
        }
    }
}
