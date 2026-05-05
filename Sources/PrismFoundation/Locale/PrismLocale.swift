//
//  Locale.swift
//  Prism
//
//  Created by Rafael Escaleira on 25/04/25.
//

import Foundation
import NaturalLanguage

/// Locale enumeration with formatting and currency support.
public enum PrismLocale: CaseIterable, Sendable, Codable, CustomStringConvertible {
    /// English (United States) locale.
    case englishUS
    /// Portuguese (Brazil) locale.
    case portugueseBR
    /// Spanish (Spain) locale.
    case spanishES
    /// French (France) locale.
    case frenchFR
    /// German (Germany) locale.
    case germanDE
    /// Arabic (Saudi Arabia) locale.
    case arabicSA
    /// Japanese (Japan) locale.
    case japaneseJP
    /// Chinese Simplified (China) locale.
    case chineseCN

    /// The Foundation `Locale` corresponding to this case.
    public var rawValue: Locale {
        Locale(identifier: identifier)
    }

    /// The flag emoji representing this locale's country.
    public var emoji: String {
        switch self {
        case .englishUS: return "🇺🇸"
        case .portugueseBR: return "🇧🇷"
        case .spanishES: return "🇪🇸"
        case .frenchFR: return "🇫🇷"
        case .germanDE: return "🇩🇪"
        case .arabicSA: return "🇸🇦"
        case .japaneseJP: return "🇯🇵"
        case .chineseCN: return "🇨🇳"
        }
    }

    /// A human-readable label combining the flag emoji and language name.
    public var description: String {
        switch self {
        case .englishUS: return "\(emoji) English (US)"
        case .portugueseBR: return "\(emoji) Português (BR)"
        case .spanishES: return "\(emoji) Español"
        case .frenchFR: return "\(emoji) Français"
        case .germanDE: return "\(emoji) Deutsch"
        case .arabicSA: return "\(emoji) العربية"
        case .japaneseJP: return "\(emoji) 日本語"
        case .chineseCN: return "\(emoji) 中文"
        }
    }

    /// The ISO 639 language code (e.g., "en", "pt").
    public var languageCode: String? {
        rawValue.language.languageCode?.identifier
    }

    /// The `NLLanguage` value for NaturalLanguage framework integration.
    public var naturalLanguage: NLLanguage? {
        switch self {
        case .englishUS: return .english
        case .portugueseBR: return .portuguese
        case .spanishES: return .spanish
        case .frenchFR: return .french
        case .germanDE: return .german
        case .arabicSA: return .arabic
        case .japaneseJP: return .japanese
        case .chineseCN: return .simplifiedChinese
        }
    }

    /// The locale identifier string (e.g., "en_US", "pt_BR").
    public var identifier: String {
        switch self {
        case .englishUS: return "en_US"
        case .portugueseBR: return "pt_BR"
        case .spanishES: return "es_ES"
        case .frenchFR: return "fr_FR"
        case .germanDE: return "de_DE"
        case .arabicSA: return "ar_SA"
        case .japaneseJP: return "ja_JP"
        case .chineseCN: return "zh_CN"
        }
    }

    var isRTL: Bool {
        ["ar", "he", "fa", "ur"].contains(languageCode)
    }

    /// The ISO 4217 currency code for this locale (e.g., "USD", "BRL").
    public var currencyCode: String {
        switch self {
        case .englishUS: return "USD"
        case .portugueseBR: return "BRL"
        case .spanishES, .frenchFR, .germanDE: return "EUR"
        case .arabicSA: return "SAR"
        case .japaneseJP: return "JPY"
        case .chineseCN: return "CNY"
        }
    }

    /// The calendar system appropriate for this locale.
    public var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)

        switch self {
        case .japaneseJP:
            calendar = Calendar(identifier: .japanese)
        case .arabicSA:
            calendar = Calendar(identifier: .islamicUmmAlQura)
        default:
            break
        }

        calendar.locale = rawValue
        return calendar
    }

    /// A `Date.FormatStyle` configured with this locale and its calendar.
    public var dateFormatStyle: Date.FormatStyle {
        var style = Date.FormatStyle()
        style.locale = rawValue
        style.calendar = calendar
        return style
    }

    /// The locale matching the device's current language, defaulting to English (US).
    public static var current: PrismLocale {
        match(languageCode: Locale.current.language.languageCode?.identifier)
    }

    static func match(languageCode: String?) -> PrismLocale {
        PrismLocale.allCases.first(where: { $0.languageCode == languageCode }) ?? .englishUS
    }
}
