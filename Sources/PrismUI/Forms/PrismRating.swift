import SwiftUI

/// Star rating input with configurable max stars and half-star support.
public struct PrismRating: View {
    @Environment(\.prismTheme) private var theme

    @Binding private var value: Double
    private let maxStars: Int
    private let allowHalf: Bool
    private let starSize: CGFloat

    /// Creates a star rating with configurable max stars, half-star support, and size.
    public init(
        value: Binding<Double>,
        maxStars: Int = 5,
        allowHalf: Bool = false,
        starSize: CGFloat = 24
    ) {
        self._value = value
        self.maxStars = maxStars
        self.allowHalf = allowHalf
        self.starSize = starSize
    }

    /// The star rating view body with tappable filled/empty stars.
    public var body: some View {
        HStack(spacing: SpacingToken.xs.rawValue) {
            ForEach(1...maxStars, id: \.self) { star in
                starImage(for: star)
                    .font(.system(size: starSize))
                    .foregroundStyle(starColor(for: star))
                    .onTapGesture {
                        handleTap(star: star)
                    }
                    .accessibilityElement()
                    .accessibilityLabel("\(star) star\(star == 1 ? "" : "s")")
                    .accessibilityAddTraits(.isButton)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Rating")
        .accessibilityValue("\(formattedValue) out of \(maxStars) stars")
    }

    private func starImage(for star: Int) -> Image {
        let floored = Int(value)
        let hasHalf = value - Double(floored) >= 0.5

        if star <= floored {
            return Image(systemName: "star.fill")
        } else if star == floored + 1 && hasHalf {
            return Image(systemName: "star.leadinghalf.filled")
        } else {
            return Image(systemName: "star")
        }
    }

    private func starColor(for star: Int) -> Color {
        let floored = Int(value)
        let hasHalf = value - Double(floored) >= 0.5

        if star <= floored || (star == floored + 1 && hasHalf) {
            return theme.color(.warning)
        }
        return theme.color(.onBackgroundTertiary)
    }

    private func handleTap(star: Int) {
        if allowHalf {
            if value == Double(star) {
                value = Double(star) - 0.5
            } else if value == Double(star) - 0.5 {
                value = 0
            } else {
                value = Double(star)
            }
        } else {
            value = value == Double(star) ? 0 : Double(star)
        }
    }

    private var formattedValue: String {
        allowHalf ? String(format: "%.1f", value) : "\(Int(value))"
    }
}
