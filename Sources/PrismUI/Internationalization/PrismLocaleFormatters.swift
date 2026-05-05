import Foundation

/// Number formatting style for locale-aware output.
public enum PrismNumberStyle: Sendable {
    /// Plain decimal number.
    case decimal
    /// Currency with ISO 4217 code (e.g., "USD").
    case currency(code: String)
    /// Percentage (0.5 -> "50%").
    case percent
    /// Scientific notation.
    case scientific
}

/// Date formatting style for locale-aware output.
public enum PrismDateStyle: Sendable {
    /// Shortest representation (e.g., "4/28/26").
    case short
    /// Medium representation (e.g., "Apr 28, 2026").
    case medium
    /// Long representation (e.g., "April 28, 2026").
    case long
    /// Full representation (e.g., "Tuesday, April 28, 2026").
    case full
    /// Relative date (e.g., "yesterday").
    case relative
}

/// Locale-aware number formatter wrapping Foundation format styles.
public struct PrismNumberFormatter: Sendable {

    /// Shared instance.
    public static let shared = PrismNumberFormatter()

    /// Creates a number formatter instance.
    public init() {}

    /// Formats a numeric value according to the given style and locale.
    public func format(_ value: Double, style: PrismNumberStyle, locale: Locale) -> String {
        switch style {
        case .decimal:
            return value.formatted(
                .number
                    .locale(locale)
                    .precision(.fractionLength(0...2))
            )
        case .currency(let code):
            return value.formatted(
                .currency(code: code)
                    .locale(locale)
            )
        case .percent:
            return value.formatted(
                .percent
                    .locale(locale)
            )
        case .scientific:
            let formatter = NumberFormatter()
            formatter.numberStyle = .scientific
            formatter.locale = locale
            formatter.maximumFractionDigits = 4
            return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
        }
    }
}

/// Locale-aware date formatter wrapping Foundation format styles.
public struct PrismDateFormatter: Sendable {

    /// Shared instance.
    public static let shared = PrismDateFormatter()

    /// Creates a date formatter instance.
    public init() {}

    /// Formats a date according to the given style and locale.
    public func format(_ date: Date, style: PrismDateStyle, locale: Locale) -> String {
        switch style {
        case .short:
            return date.formatted(
                .dateTime
                    .year().month(.twoDigits).day()
                    .locale(locale)
            )
        case .medium:
            return date.formatted(
                .dateTime
                    .year().month(.abbreviated).day()
                    .locale(locale)
            )
        case .long:
            return date.formatted(
                .dateTime
                    .year().month(.wide).day()
                    .locale(locale)
            )
        case .full:
            return date.formatted(
                .dateTime
                    .year().month(.wide).day().weekday(.wide)
                    .locale(locale)
            )
        case .relative:
            let formatter = RelativeDateTimeFormatter()
            formatter.locale = locale
            formatter.unitsStyle = .full
            return formatter.localizedString(for: date, relativeTo: Date.now)
        }
    }
}

/// Formats dates as relative time strings (e.g., "2 hours ago", "in 3 days").
public struct PrismRelativeTimeFormatter: Sendable {

    /// Shared instance.
    public static let shared = PrismRelativeTimeFormatter()

    /// Creates a relative time formatter instance.
    public init() {}

    /// Formats the time difference between two dates as a human-readable string.
    public func format(_ date: Date, relativeTo reference: Date, locale: Locale) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = locale
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: reference)
    }
}
