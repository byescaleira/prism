import SwiftUI

/// A single candlestick (OHLC) data point.
public struct PrismCandlestick: Sendable, Hashable, Identifiable {
    /// Stable identity derived from date.
    public var id: Date { date }
    /// The trading period date.
    public let date: Date
    /// Opening price.
    public let open: Double
    /// Highest price.
    public let high: Double
    /// Lowest price.
    public let low: Double
    /// Closing price.
    public let close: Double

    /// Creates a candlestick data point.
    public init(date: Date, open: Double, high: Double, low: Double, close: Double) {
        self.date = date
        self.open = open
        self.high = high
        self.low = low
        self.close = close
    }

    /// Whether the candle is bullish (close >= open).
    public var isBullish: Bool { close >= open }
}

/// A candlestick (OHLC) chart with green/red coloring for bullish/bearish candles.
@MainActor
public struct PrismCandlestickChart: View {
    @Environment(\.prismTheme) private var theme

    private let candles: [PrismCandlestick]
    private let bullishColor: Color?
    private let bearishColor: Color?

    /// Creates a candlestick chart from an array of OHLC data.
    public init(
        candles: [PrismCandlestick],
        bullishColor: Color? = nil,
        bearishColor: Color? = nil
    ) {
        self.candles = candles
        self.bullishColor = bullishColor
        self.bearishColor = bearishColor
    }

    public var body: some View {
        GeometryReader { geo in
            let sorted = candles.sorted { $0.date < $1.date }
            let allValues = sorted.flatMap { [$0.high, $0.low] }
            let minPrice = allValues.min() ?? 0
            let maxPrice = allValues.max() ?? 1
            let priceRange = maxPrice - minPrice
            let count = sorted.count

            if count > 0, priceRange > 0 {
                let candleWidth = max(geo.size.width / CGFloat(count) * 0.7, 2)
                let spacing = geo.size.width / CGFloat(count)

                ZStack(alignment: .topLeading) {
                    gridBackground(geo: geo, minPrice: minPrice, maxPrice: maxPrice)

                    ForEach(Array(sorted.enumerated()), id: \.element.id) { index, candle in
                        let x = spacing * (CGFloat(index) + 0.5)
                        let bullish = candle.isBullish
                        let fillColor = bullish ? (bullishColor ?? theme.color(.success)) : (bearishColor ?? theme.color(.error))

                        let highY = yPosition(value: candle.high, minPrice: minPrice, range: priceRange, height: geo.size.height)
                        let lowY = yPosition(value: candle.low, minPrice: minPrice, range: priceRange, height: geo.size.height)
                        let openY = yPosition(value: candle.open, minPrice: minPrice, range: priceRange, height: geo.size.height)
                        let closeY = yPosition(value: candle.close, minPrice: minPrice, range: priceRange, height: geo.size.height)

                        // Wick (high-low line)
                        Path { path in
                            path.move(to: CGPoint(x: x, y: highY))
                            path.addLine(to: CGPoint(x: x, y: lowY))
                        }
                        .stroke(fillColor, lineWidth: 1)

                        // Body (open-close rect)
                        let bodyTop = min(openY, closeY)
                        let bodyHeight = max(abs(openY - closeY), 1)
                        RoundedRectangle(cornerRadius: 1)
                            .fill(fillColor)
                            .frame(width: candleWidth, height: bodyHeight)
                            .position(x: x, y: bodyTop + bodyHeight / 2)
                            .accessibilityLabel("Candle: O \(candle.open, specifier: "%.2f") H \(candle.high, specifier: "%.2f") L \(candle.low, specifier: "%.2f") C \(candle.close, specifier: "%.2f")")
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func gridBackground(geo: GeometryProxy, minPrice: Double, maxPrice: Double) -> some View {
        let levels = 4
        let range = maxPrice - minPrice
        ForEach(0...levels, id: \.self) { level in
            let fraction = Double(level) / Double(levels)
            let price = minPrice + range * fraction
            let y = geo.size.height * (1 - fraction)

            Path { path in
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: geo.size.width, y: y))
            }
            .stroke(theme.color(.separator).opacity(0.3), style: StrokeStyle(lineWidth: 0.5, dash: [4, 4]))

            Text("\(price, specifier: "%.2f")")
                .font(.caption2)
                .foregroundStyle(theme.color(.onBackgroundSecondary))
                .position(x: geo.size.width - 24, y: y - 8)
        }
    }

    private func yPosition(value: Double, minPrice: Double, range: Double, height: CGFloat) -> CGFloat {
        let normalized = (value - minPrice) / range
        return height * (1 - normalized)
    }
}
