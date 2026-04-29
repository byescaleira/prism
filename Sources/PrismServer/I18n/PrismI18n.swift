import Foundation

// MARK: - Pluralization

public enum PrismPluralCategory: String, Sendable {
    case zero, one, two, few, many, other
}

public struct PrismPluralRule: Sendable {
    public let categories: [PrismPluralCategory: String]

    public init(_ categories: [PrismPluralCategory: String]) {
        self.categories = categories
    }

    public func resolve(count: Int) -> String? {
        if count == 0, let zero = categories[.zero] { return zero }
        if count == 1, let one = categories[.one] { return one }
        if count == 2, let two = categories[.two] { return two }
        if count >= 3 && count <= 10, let few = categories[.few] { return few }
        if count >= 11 && count <= 99, let many = categories[.many] { return many }
        return categories[.other]
    }
}

// MARK: - Translation Store

public actor PrismTranslationStore {
    private var translations: [String: [String: String]] = [:]
    private var plurals: [String: [String: PrismPluralRule]] = [:]

    public init() {}

    public func load(locale: String, translations dict: [String: String]) {
        var current = translations[locale] ?? [:]
        for (key, value) in dict {
            current[key] = value
        }
        translations[locale] = current
    }

    public func loadJSON(locale: String, data: Data) throws {
        guard let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw PrismI18nError.invalidFormat
        }
        let flat = flattenDict(dict, prefix: "")
        load(locale: locale, translations: flat)
    }

    public func loadJSONFile(locale: String, path: String) throws {
        let data = try Data(contentsOf: URL(fileURLWithPath: path))
        try loadJSON(locale: locale, data: data)
    }

    public func loadDirectory(_ path: String) throws {
        let fm = FileManager.default
        guard let files = try? fm.contentsOfDirectory(atPath: path) else { return }
        for file in files {
            guard file.hasSuffix(".json") else { continue }
            let locale = String(file.dropLast(5))
            let filePath = (path as NSString).appendingPathComponent(file)
            try loadJSONFile(locale: locale, path: filePath)
        }
    }

    public func addPlural(locale: String, key: String, rule: PrismPluralRule) {
        var locPlurals = plurals[locale] ?? [:]
        locPlurals[key] = rule
        plurals[locale] = locPlurals
    }

    public func translate(
        key: String,
        locale: String,
        fallbacks: [String] = [],
        params: [String: String] = [:]
    ) -> String {
        let chain = [locale] + fallbacks
        for loc in chain {
            if let value = translations[loc]?[key] {
                return interpolate(value, params: params)
            }
        }
        return key
    }

    public func translatePlural(
        key: String,
        count: Int,
        locale: String,
        fallbacks: [String] = [],
        params: [String: String] = [:]
    ) -> String {
        let chain = [locale] + fallbacks
        for loc in chain {
            if let rule = plurals[loc]?[key], let resolved = rule.resolve(count: count) {
                var allParams = params
                allParams["count"] = "\(count)"
                return interpolate(resolved, params: allParams)
            }
        }
        return translate(key: key, locale: locale, fallbacks: fallbacks, params: params)
    }

    public func hasTranslation(key: String, locale: String) -> Bool {
        translations[locale]?[key] != nil
    }

    public func availableLocales() -> [String] {
        Array(translations.keys).sorted()
    }

    public func allKeys(for locale: String) -> [String] {
        Array(translations[locale]?.keys ?? [String: String]().keys).sorted()
    }

    // MARK: - Private

    private func interpolate(_ template: String, params: [String: String]) -> String {
        var result = template
        for (key, value) in params {
            result = result.replacingOccurrences(of: "{{\(key)}}", with: value)
        }
        return result
    }

    private func flattenDict(_ dict: [String: Any], prefix: String) -> [String: String] {
        var result: [String: String] = [:]
        for (key, value) in dict {
            let fullKey = prefix.isEmpty ? key : "\(prefix).\(key)"
            if let str = value as? String {
                result[fullKey] = str
            } else if let nested = value as? [String: Any] {
                let sub = flattenDict(nested, prefix: fullKey)
                for (k, v) in sub { result[k] = v }
            }
        }
        return result
    }
}

// MARK: - Locale Detection

public struct PrismLocaleDetector: Sendable {
    public init() {}

    public func detect(from request: PrismHTTPRequest, supportedLocales: [String], defaultLocale: String) -> String {
        guard let acceptLanguage = request.headers.value(for: "Accept-Language") else {
            return defaultLocale
        }
        let preferred = parseAcceptLanguage(acceptLanguage)
        for (locale, _) in preferred {
            if supportedLocales.contains(locale) { return locale }
            let base = String(locale.prefix(2))
            if supportedLocales.contains(base) { return base }
        }
        return defaultLocale
    }

    public func parseAcceptLanguage(_ header: String) -> [(String, Double)] {
        var result: [(String, Double)] = []
        let parts = header.split(separator: ",")
        for part in parts {
            let trimmed = part.trimmingCharacters(in: .whitespaces)
            let components = trimmed.split(separator: ";")
            let locale = String(components[0]).trimmingCharacters(in: .whitespaces)
            var quality = 1.0
            if components.count > 1 {
                let qPart = String(components[1]).trimmingCharacters(in: .whitespaces)
                if qPart.hasPrefix("q=") {
                    quality = Double(qPart.dropFirst(2)) ?? 1.0
                }
            }
            result.append((locale, quality))
        }
        return result.sorted { $0.1 > $1.1 }
    }
}

// MARK: - I18n Middleware

public struct PrismI18nMiddleware: PrismMiddleware, Sendable {
    private let supportedLocales: [String]
    private let defaultLocale: String
    private let detector: PrismLocaleDetector

    public init(supportedLocales: [String], defaultLocale: String = "en") {
        self.supportedLocales = supportedLocales
        self.defaultLocale = defaultLocale
        self.detector = PrismLocaleDetector()
    }

    public func handle(_ request: PrismHTTPRequest, next: @escaping PrismRouteHandler) async throws -> PrismHTTPResponse {
        var req = request
        let locale = detector.detect(from: request, supportedLocales: supportedLocales, defaultLocale: defaultLocale)
        req.userInfo["locale"] = locale
        var response = try await next(req)
        response.headers.set(name: "Content-Language", value: locale)
        return response
    }
}

// MARK: - Errors

public enum PrismI18nError: Error, Sendable {
    case invalidFormat
    case fileNotFound(String)
    case localeNotFound(String)
}
