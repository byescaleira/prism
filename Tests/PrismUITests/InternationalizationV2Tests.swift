import SwiftUI
import Testing

@testable import PrismUI

@MainActor
@Suite("Internationalization V2")
struct InternationalizationV2Tests {

    // MARK: - Layout Direction

    @Test("PrismLayoutDirection has 3 cases")
    func layoutDirectionCases() {
        let cases = PrismLayoutDirection.allCases
        #expect(cases.count == 3)
        #expect(cases.contains(.leftToRight))
        #expect(cases.contains(.rightToLeft))
        #expect(cases.contains(.auto))
    }

    @Test("PrismDirectionalEdge has 2 cases")
    func directionalEdgeCases() {
        let cases = PrismDirectionalEdge.allCases
        #expect(cases.count == 2)
        #expect(cases.contains(.leading))
        #expect(cases.contains(.trailing))
    }

    @Test("PrismDirectionalEdge resolves correctly for LTR")
    func directionalEdgeLTR() {
        let leadingResolved = PrismDirectionalEdge.leading.resolved(for: .leftToRight)
        let trailingResolved = PrismDirectionalEdge.trailing.resolved(for: .leftToRight)
        #expect(leadingResolved == .leading)
        #expect(trailingResolved == .trailing)
    }

    @Test("PrismDirectionalEdge resolves correctly for RTL")
    func directionalEdgeRTL() {
        let leadingResolved = PrismDirectionalEdge.leading.resolved(for: .rightToLeft)
        let trailingResolved = PrismDirectionalEdge.trailing.resolved(for: .rightToLeft)
        #expect(leadingResolved == .trailing)
        #expect(trailingResolved == .leading)
    }

    @Test("PrismBidirectionalStack is a View")
    func bidirectionalStackIsView() {
        let stack = PrismBidirectionalStack {
            Text("Hello")
            Text("World")
        }
        #expect(type(of: stack) is any View.Type)
    }

    @Test("prismLayoutDirection modifier applies without crash")
    func layoutDirectionModifier() {
        let view = Text("Test").prismLayoutDirection(.rightToLeft)
        #expect(type(of: view) is any View.Type)
    }

    // MARK: - Pluralization

    @Test("PrismPluralCategory has 6 cases")
    func pluralCategoryCases() {
        let cases = PrismPluralCategory.allCases
        #expect(cases.count == 6)
        #expect(cases.contains(.zero))
        #expect(cases.contains(.one))
        #expect(cases.contains(.two))
        #expect(cases.contains(.few))
        #expect(cases.contains(.many))
        #expect(cases.contains(.other))
    }

    @Test("English plural rules: 0->other, 1->one, 2->other, 5->other")
    func englishPluralRules() {
        let rule = PrismPluralRule.shared
        let en = Locale(identifier: "en")
        #expect(rule.category(for: 0, locale: en) == .other)
        #expect(rule.category(for: 1, locale: en) == .one)
        #expect(rule.category(for: 2, locale: en) == .other)
        #expect(rule.category(for: 5, locale: en) == .other)
    }

    @Test("Arabic plural rules differ from English")
    func arabicPluralRules() {
        let rule = PrismPluralRule.shared
        let ar = Locale(identifier: "ar")
        #expect(rule.category(for: 0, locale: ar) == .zero)
        #expect(rule.category(for: 1, locale: ar) == .one)
        #expect(rule.category(for: 2, locale: ar) == .two)
        #expect(rule.category(for: 5, locale: ar) == .few)
        #expect(rule.category(for: 11, locale: ar) == .many)
        #expect(rule.category(for: 100, locale: ar) == .other)
    }

    @Test("Russian plural rules: one/few/many")
    func russianPluralRules() {
        let rule = PrismPluralRule.shared
        let ru = Locale(identifier: "ru")
        #expect(rule.category(for: 1, locale: ru) == .one)
        #expect(rule.category(for: 2, locale: ru) == .few)
        #expect(rule.category(for: 5, locale: ru) == .many)
        #expect(rule.category(for: 21, locale: ru) == .one)
        #expect(rule.category(for: 11, locale: ru) == .many)
    }

    @Test("Japanese plural rules: always other")
    func japanesePluralRules() {
        let rule = PrismPluralRule.shared
        let ja = Locale(identifier: "ja")
        #expect(rule.category(for: 0, locale: ja) == .other)
        #expect(rule.category(for: 1, locale: ja) == .other)
        #expect(rule.category(for: 100, locale: ja) == .other)
    }

    @Test("PrismPluralizedText is a View")
    func pluralizedTextIsView() {
        let view = PrismPluralizedText(
            count: 3,
            forms: [.one: "1 item", .other: "items"]
        )
        #expect(type(of: view) is any View.Type)
    }

    // MARK: - Number Formatter

    @Test("PrismNumberFormatter decimal formatting")
    func numberFormatterDecimal() {
        let formatter = PrismNumberFormatter.shared
        let result = formatter.format(1234.56, style: .decimal, locale: Locale(identifier: "en_US"))
        #expect(result.contains("1") && result.contains("234"))
    }

    @Test("PrismNumberFormatter currency with USD")
    func numberFormatterCurrencyUSD() {
        let formatter = PrismNumberFormatter.shared
        let result = formatter.format(42.99, style: .currency(code: "USD"), locale: Locale(identifier: "en_US"))
        #expect(result.contains("$") || result.contains("USD"))
        #expect(result.contains("42"))
    }

    @Test("PrismNumberFormatter percent")
    func numberFormatterPercent() {
        let formatter = PrismNumberFormatter.shared
        let result = formatter.format(0.85, style: .percent, locale: Locale(identifier: "en_US"))
        #expect(result.contains("85") || result.contains("%"))
    }

    @Test("PrismNumberFormatter scientific")
    func numberFormatterScientific() {
        let formatter = PrismNumberFormatter.shared
        let result = formatter.format(1500.0, style: .scientific, locale: Locale(identifier: "en_US"))
        #expect(!result.isEmpty)
    }

    // MARK: - Date Formatter

    @Test("PrismDateFormatter short style")
    func dateFormatterShort() {
        let formatter = PrismDateFormatter.shared
        let date = Date(timeIntervalSince1970: 1_777_536_000)  // 2026-04-28 approx
        let result = formatter.format(date, style: .short, locale: Locale(identifier: "en_US"))
        #expect(!result.isEmpty)
        #expect(result.contains("2026") || result.contains("26"))
    }

    @Test("PrismDateFormatter medium style")
    func dateFormatterMedium() {
        let formatter = PrismDateFormatter.shared
        let date = Date(timeIntervalSince1970: 1_777_536_000)
        let result = formatter.format(date, style: .medium, locale: Locale(identifier: "en_US"))
        #expect(!result.isEmpty)
    }

    // MARK: - Relative Time Formatter

    @Test("PrismRelativeTimeFormatter produces non-empty output")
    func relativeTimeFormatterNonEmpty() {
        let formatter = PrismRelativeTimeFormatter.shared
        let now = Date.now
        let twoHoursAgo = now.addingTimeInterval(-7200)
        let result = formatter.format(twoHoursAgo, relativeTo: now, locale: Locale(identifier: "en_US"))
        #expect(!result.isEmpty)
    }

    @Test("PrismRelativeTimeFormatter future date")
    func relativeTimeFormatterFuture() {
        let formatter = PrismRelativeTimeFormatter.shared
        let now = Date.now
        let threeDaysLater = now.addingTimeInterval(259_200)
        let result = formatter.format(threeDaysLater, relativeTo: now, locale: Locale(identifier: "en_US"))
        #expect(!result.isEmpty)
    }

    // MARK: - String Catalog

    @Test("PrismLocalizedKey stores key and comment")
    func localizedKeyStoresData() {
        let key = PrismLocalizedKey(key: "app.welcome", comment: "Welcome screen title", table: "Main")
        #expect(key.key == "app.welcome")
        #expect(key.comment == "Welcome screen title")
        #expect(key.table == "Main")
        #expect(key.id == "app.welcome")
    }

    @Test("PrismLocalizedKey default table is nil")
    func localizedKeyDefaultTable() {
        let key = PrismLocalizedKey(key: "test.key", comment: "A test key")
        #expect(key.table == nil)
    }

    @Test("PrismStringExporter registers and exports keys")
    func stringExporterRegistersKeys() {
        let exporter = PrismStringExporter()
        let key1 = PrismLocalizedKey(key: "module.title", comment: "Title")
        let key2 = PrismLocalizedKey(key: "module.subtitle", comment: "Subtitle")
        exporter.register(key1)
        exporter.register(key2)
        let exported = exporter.exportKeys(from: "module")
        #expect(exported.count == 2)
    }

    @Test("PrismStringExporter deduplicates keys")
    func stringExporterDeduplicates() {
        let exporter = PrismStringExporter()
        let key = PrismLocalizedKey(key: "dup.key", comment: "Duplicate")
        exporter.register(key)
        exporter.register(key)
        #expect(exporter.keys.count == 1)
    }

    // MARK: - Locale Preview

    @Test("PrismMultiLocalePreview is a View")
    func multiLocalePreviewIsView() {
        let preview = PrismMultiLocalePreview {
            Text("Hello")
        }
        #expect(type(of: preview) is any View.Type)
    }

    @Test("PrismMultiLocalePreview default locales has 6 entries")
    func multiLocalePreviewDefaultLocales() {
        let locales = PrismMultiLocalePreview<Text>.defaultLocales
        #expect(locales.count == 6)
    }

    @Test("prismPreviewLocales modifier applies without crash")
    func previewLocalesModifier() {
        let view = Text("Test").prismPreviewLocales()
        #expect(type(of: view) is any View.Type)
    }

    @Test("prismLocalized modifier applies without crash")
    func localizedModifier() {
        let view = Text("Hello").prismLocalized("greeting.hello", comment: "Greeting text")
        #expect(type(of: view) is any View.Type)
    }
}
