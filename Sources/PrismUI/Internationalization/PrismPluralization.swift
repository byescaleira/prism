import SwiftUI

/// CLDR plural categories for locale-aware pluralization.
public enum PrismPluralCategory: String, Sendable, CaseIterable {
    /// Zero quantity (e.g., Arabic "no items").
    case zero
    /// Singular (e.g., English "1 item").
    case one
    /// Dual (e.g., Arabic "2 items").
    case two
    /// Few (e.g., Russian 2-4).
    case few
    /// Many (e.g., Russian 5-20).
    case many
    /// General/default form.
    case other
}

/// Locale-aware plural rule resolver following CLDR plural rules.
public struct PrismPluralRule: Sendable {

    /// Shared instance with built-in rules for English, Arabic, Russian, and Japanese.
    public static let shared = PrismPluralRule()

    /// Creates a plural rule resolver instance.
    public init() {}

    /// Returns the plural category for a given count and locale.
    public func category(for count: Int, locale: Locale) -> PrismPluralCategory {
        let language = locale.language.languageCode?.identifier ?? "en"

        switch language {
        case "en":
            return englishCategory(for: count)
        case "ar":
            return arabicCategory(for: count)
        case "ru":
            return russianCategory(for: count)
        case "ja", "zh", "ko", "vi", "th":
            return .other
        default:
            return englishCategory(for: count)
        }
    }

    // MARK: - English (CLDR: one/other)

    private func englishCategory(for count: Int) -> PrismPluralCategory {
        count == 1 ? .one : .other
    }

    // MARK: - Arabic (CLDR: zero/one/two/few/many/other)

    private func arabicCategory(for count: Int) -> PrismPluralCategory {
        if count == 0 { return .zero }
        if count == 1 { return .one }
        if count == 2 { return .two }
        let mod100 = count % 100
        if (3...10).contains(mod100) { return .few }
        if (11...99).contains(mod100) { return .many }
        return .other
    }

    // MARK: - Russian (CLDR: one/few/many/other)

    private func russianCategory(for count: Int) -> PrismPluralCategory {
        let mod10 = count % 10
        let mod100 = count % 100

        if mod10 == 1 && mod100 != 11 {
            return .one
        }
        if (2...4).contains(mod10) && !(12...14).contains(mod100) {
            return .few
        }
        if mod10 == 0 || (5...9).contains(mod10) || (11...14).contains(mod100) {
            return .many
        }
        return .other
    }
}

/// A view that displays pluralized text based on count and locale.
public struct PrismPluralizedText: View {
    @Environment(\.locale) private var locale
    private let count: Int
    private let forms: [PrismPluralCategory: String]
    private let rule: PrismPluralRule

    /// Creates a pluralized text view with the given count and form dictionary.
    public init(
        count: Int,
        forms: [PrismPluralCategory: String],
        rule: PrismPluralRule = .shared
    ) {
        self.count = count
        self.forms = forms
        self.rule = rule
    }

    /// The view body displaying the resolved pluralized text.
    public var body: some View {
        Text(resolvedText)
    }

    private var resolvedText: String {
        let category = rule.category(for: count, locale: locale)
        return forms[category] ?? forms[.other] ?? ""
    }
}
