import Foundation
import NaturalLanguage
import Testing

@testable import PrismFoundation

struct PrismLocaleTests {
    @Test(arguments: PrismLocale.allCases)
    func localeMetadataIsConsistent(locale: PrismLocale) {
        #expect(locale.rawValue.identifier == locale.identifier)
        #expect(locale.emoji.isEmpty == false)
        #expect(locale.description.contains(locale.emoji))
        #expect(locale.languageCode == locale.rawValue.language.languageCode?.identifier)
        #expect(locale.currencyCode.isEmpty == false)
        #expect(locale.dateFormatStyle.locale == locale.rawValue)
    }

    @Test
    func localeSpecificMappingsMatchExpectedValues() {
        #expect(PrismLocale.englishUS.naturalLanguage == NLLanguage.english)
        #expect(PrismLocale.portugueseBR.naturalLanguage == NLLanguage.portuguese)
        #expect(PrismLocale.spanishES.naturalLanguage == NLLanguage.spanish)
        #expect(PrismLocale.frenchFR.naturalLanguage == NLLanguage.french)
        #expect(PrismLocale.germanDE.naturalLanguage == NLLanguage.german)
        #expect(PrismLocale.arabicSA.naturalLanguage == NLLanguage.arabic)
        #expect(PrismLocale.japaneseJP.naturalLanguage == NLLanguage.japanese)
        #expect(PrismLocale.chineseCN.naturalLanguage == NLLanguage.simplifiedChinese)
        #expect(PrismLocale.englishUS.currencyCode == "USD")
        #expect(PrismLocale.portugueseBR.currencyCode == "BRL")
        #expect(PrismLocale.arabicSA.isRTL)
        #expect(PrismLocale.englishUS.isRTL == false)
    }

    @Test
    func localeCalendarsAdaptToSpecificRegions() {
        #expect(PrismLocale.englishUS.calendar.identifier == .gregorian)
        #expect(PrismLocale.japaneseJP.calendar.identifier == .japanese)
        #expect(PrismLocale.arabicSA.calendar.identifier == .islamicUmmAlQura)
    }

    @Test
    func currentLocaleUsesSameSelectionRuleAsImplementation() {
        let currentLanguageCode = Locale.current.language.languageCode?.identifier
        let expected = PrismLocale.match(languageCode: currentLanguageCode)

        #expect(PrismLocale.current == expected)
    }

    @Test
    func unsupportedLanguageCodesFallBackToEnglishUS() {
        #expect(PrismLocale.match(languageCode: "xx") == .englishUS)
        #expect(PrismLocale.match(languageCode: nil) == .englishUS)
    }

    @Test
    func codableRoundTripsAllLocales() throws {
        let encoded = try JSONEncoder().encode(PrismLocale.allCases)
        let decoded = try JSONDecoder().decode([PrismLocale].self, from: encoded)

        #expect(decoded == PrismLocale.allCases)
    }
}
