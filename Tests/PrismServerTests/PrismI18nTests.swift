import Testing
import Foundation
@testable import PrismServer

@Suite("PrismPluralRule Tests")
struct PrismPluralRuleTests {

    @Test("Resolves zero category")
    func zero() {
        let rule = PrismPluralRule([.zero: "no items", .one: "1 item", .other: "{{count}} items"])
        #expect(rule.resolve(count: 0) == "no items")
    }

    @Test("Resolves one category")
    func one() {
        let rule = PrismPluralRule([.one: "1 item", .other: "{{count}} items"])
        #expect(rule.resolve(count: 1) == "1 item")
    }

    @Test("Resolves two category")
    func two() {
        let rule = PrismPluralRule([.one: "1 item", .two: "2 items", .other: "{{count}} items"])
        #expect(rule.resolve(count: 2) == "2 items")
    }

    @Test("Resolves few category (3-10)")
    func few() {
        let rule = PrismPluralRule([.few: "a few", .other: "many"])
        #expect(rule.resolve(count: 5) == "a few")
        #expect(rule.resolve(count: 10) == "a few")
    }

    @Test("Resolves many category (11-99)")
    func many() {
        let rule = PrismPluralRule([.many: "many", .other: "lots"])
        #expect(rule.resolve(count: 50) == "many")
        #expect(rule.resolve(count: 99) == "many")
    }

    @Test("Falls back to other category")
    func other() {
        let rule = PrismPluralRule([.other: "{{count}} items"])
        #expect(rule.resolve(count: 200) == "{{count}} items")
    }

    @Test("Returns nil when no matching category")
    func noMatch() {
        let rule = PrismPluralRule([.one: "1 item"])
        #expect(rule.resolve(count: 5) == nil)
    }
}

@Suite("PrismTranslationStore Tests")
struct PrismTranslationStoreTests {

    @Test("Load and translate simple key")
    func simpleTranslation() async {
        let store = PrismTranslationStore()
        await store.load(locale: "en", translations: ["greeting": "Hello"])
        let result = await store.translate(key: "greeting", locale: "en")
        #expect(result == "Hello")
    }

    @Test("Returns key when translation missing")
    func missingKey() async {
        let store = PrismTranslationStore()
        let result = await store.translate(key: "missing.key", locale: "en")
        #expect(result == "missing.key")
    }

    @Test("Fallback locale chain")
    func fallbackChain() async {
        let store = PrismTranslationStore()
        await store.load(locale: "en", translations: ["greeting": "Hello"])
        let result = await store.translate(key: "greeting", locale: "fr", fallbacks: ["en"])
        #expect(result == "Hello")
    }

    @Test("Parameter interpolation")
    func interpolation() async {
        let store = PrismTranslationStore()
        await store.load(locale: "en", translations: ["welcome": "Hello, {{name}}!"])
        let result = await store.translate(key: "welcome", locale: "en", params: ["name": "World"])
        #expect(result == "Hello, World!")
    }

    @Test("Multiple parameter interpolation")
    func multipleParams() async {
        let store = PrismTranslationStore()
        await store.load(locale: "en", translations: ["msg": "{{user}} has {{count}} items"])
        let result = await store.translate(key: "msg", locale: "en", params: ["user": "Alice", "count": "5"])
        #expect(result == "Alice has 5 items")
    }

    @Test("LoadJSON flattens nested keys")
    func loadJSON() async throws {
        let store = PrismTranslationStore()
        let json = """
        {
            "nav": {
                "home": "Home",
                "settings": "Settings"
            },
            "title": "My App"
        }
        """.data(using: .utf8)!
        try await store.loadJSON(locale: "en", data: json)
        #expect(await store.translate(key: "nav.home", locale: "en") == "Home")
        #expect(await store.translate(key: "nav.settings", locale: "en") == "Settings")
        #expect(await store.translate(key: "title", locale: "en") == "My App")
    }

    @Test("LoadJSON throws on invalid data")
    func loadJSONInvalid() async {
        let store = PrismTranslationStore()
        do {
            try await store.loadJSON(locale: "en", data: "not json".data(using: .utf8)!)
            Issue.record("Expected error")
        } catch {
            // Valid — JSONSerialization or PrismI18nError
        }
    }

    @Test("HasTranslation returns correct status")
    func hasTranslation() async {
        let store = PrismTranslationStore()
        await store.load(locale: "en", translations: ["key": "value"])
        #expect(await store.hasTranslation(key: "key", locale: "en") == true)
        #expect(await store.hasTranslation(key: "key", locale: "fr") == false)
        #expect(await store.hasTranslation(key: "other", locale: "en") == false)
    }

    @Test("AvailableLocales returns loaded locales")
    func availableLocales() async {
        let store = PrismTranslationStore()
        await store.load(locale: "en", translations: ["a": "b"])
        await store.load(locale: "pt", translations: ["a": "b"])
        let locales = await store.availableLocales()
        #expect(locales.contains("en"))
        #expect(locales.contains("pt"))
    }

    @Test("AllKeys returns keys for locale")
    func allKeys() async {
        let store = PrismTranslationStore()
        await store.load(locale: "en", translations: ["alpha": "a", "beta": "b"])
        let keys = await store.allKeys(for: "en")
        #expect(keys.contains("alpha"))
        #expect(keys.contains("beta"))
    }

    @Test("Plural translation with count interpolation")
    func pluralTranslation() async {
        let store = PrismTranslationStore()
        await store.addPlural(
            locale: "en",
            key: "items",
            rule: PrismPluralRule([.one: "{{count}} item", .other: "{{count}} items"])
        )
        #expect(await store.translatePlural(key: "items", count: 1, locale: "en") == "1 item")
        #expect(await store.translatePlural(key: "items", count: 5, locale: "en") == "5 items")
    }

    @Test("Plural falls back to regular translation")
    func pluralFallback() async {
        let store = PrismTranslationStore()
        await store.load(locale: "en", translations: ["items": "some items"])
        let result = await store.translatePlural(key: "items", count: 3, locale: "en")
        #expect(result == "some items")
    }

    @Test("Plural with fallback locale")
    func pluralFallbackLocale() async {
        let store = PrismTranslationStore()
        await store.addPlural(
            locale: "en",
            key: "count",
            rule: PrismPluralRule([.other: "{{count}} things"])
        )
        let result = await store.translatePlural(key: "count", count: 10, locale: "fr", fallbacks: ["en"])
        #expect(result == "10 things")
    }

    @Test("Load merges translations for same locale")
    func mergeTranslations() async {
        let store = PrismTranslationStore()
        await store.load(locale: "en", translations: ["a": "1"])
        await store.load(locale: "en", translations: ["b": "2"])
        #expect(await store.translate(key: "a", locale: "en") == "1")
        #expect(await store.translate(key: "b", locale: "en") == "2")
    }
}

@Suite("PrismLocaleDetector Tests")
struct PrismLocaleDetectorTests {

    @Test("Detects locale from Accept-Language")
    func detectFromHeader() {
        let detector = PrismLocaleDetector()
        var headers = PrismHTTPHeaders()
        headers.set(name: "Accept-Language", value: "pt-BR,pt;q=0.9,en;q=0.8")
        let request = PrismHTTPRequest(method: .GET, uri: "/", headers: headers)
        let locale = detector.detect(from: request, supportedLocales: ["en", "pt"], defaultLocale: "en")
        #expect(locale == "pt")
    }

    @Test("Falls back to default when no match")
    func fallbackToDefault() {
        let detector = PrismLocaleDetector()
        var headers = PrismHTTPHeaders()
        headers.set(name: "Accept-Language", value: "ja,zh;q=0.9")
        let request = PrismHTTPRequest(method: .GET, uri: "/", headers: headers)
        let locale = detector.detect(from: request, supportedLocales: ["en", "pt"], defaultLocale: "en")
        #expect(locale == "en")
    }

    @Test("Falls back to default when no Accept-Language")
    func noHeader() {
        let detector = PrismLocaleDetector()
        let request = PrismHTTPRequest(method: .GET, uri: "/")
        let locale = detector.detect(from: request, supportedLocales: ["en"], defaultLocale: "en")
        #expect(locale == "en")
    }

    @Test("Matches base language from full locale")
    func baseLanguageMatch() {
        let detector = PrismLocaleDetector()
        var headers = PrismHTTPHeaders()
        headers.set(name: "Accept-Language", value: "en-GB")
        let request = PrismHTTPRequest(method: .GET, uri: "/", headers: headers)
        let locale = detector.detect(from: request, supportedLocales: ["en", "fr"], defaultLocale: "fr")
        #expect(locale == "en")
    }

    @Test("Exact locale match preferred over base")
    func exactMatchPreferred() {
        let detector = PrismLocaleDetector()
        var headers = PrismHTTPHeaders()
        headers.set(name: "Accept-Language", value: "pt-BR")
        let request = PrismHTTPRequest(method: .GET, uri: "/", headers: headers)
        let locale = detector.detect(from: request, supportedLocales: ["pt-BR", "pt", "en"], defaultLocale: "en")
        #expect(locale == "pt-BR")
    }

    @Test("Parse Accept-Language with quality values")
    func parseQuality() {
        let detector = PrismLocaleDetector()
        let result = detector.parseAcceptLanguage("en;q=0.5, fr;q=0.9, pt;q=0.1")
        #expect(result[0].0 == "fr")
        #expect(result[0].1 == 0.9)
        #expect(result[1].0 == "en")
        #expect(result[2].0 == "pt")
    }

    @Test("Parse Accept-Language defaults quality to 1.0")
    func parseDefaultQuality() {
        let detector = PrismLocaleDetector()
        let result = detector.parseAcceptLanguage("en, fr;q=0.8")
        #expect(result[0].0 == "en")
        #expect(result[0].1 == 1.0)
    }
}

@Suite("PrismI18nMiddleware Tests")
struct PrismI18nMiddlewareTests {

    @Test("Sets locale in userInfo")
    func setsLocale() async throws {
        let middleware = PrismI18nMiddleware(supportedLocales: ["en", "pt"], defaultLocale: "en")
        var headers = PrismHTTPHeaders()
        headers.set(name: "Accept-Language", value: "pt")
        let request = PrismHTTPRequest(method: .GET, uri: "/", headers: headers)

        _ = try await middleware.handle(request) { req in
            #expect(req.userInfo["locale"] == "pt")
            return .text("ok")
        }
    }

    @Test("Sets Content-Language header in response")
    func setsContentLanguage() async throws {
        let middleware = PrismI18nMiddleware(supportedLocales: ["en"], defaultLocale: "en")
        let request = PrismHTTPRequest(method: .GET, uri: "/")
        let response = try await middleware.handle(request) { _ in .text("ok") }
        #expect(response.headers.value(for: "Content-Language") == "en")
    }

    @Test("Uses default locale when no header")
    func defaultLocale() async throws {
        let middleware = PrismI18nMiddleware(supportedLocales: ["en", "pt"], defaultLocale: "pt")
        let request = PrismHTTPRequest(method: .GET, uri: "/")
        let response = try await middleware.handle(request) { _ in .text("ok") }
        #expect(response.headers.value(for: "Content-Language") == "pt")
    }
}
