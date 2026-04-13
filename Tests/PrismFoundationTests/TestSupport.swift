import Foundation

@testable import PrismFoundation

struct StubDateFormatter: PrismDateFormatter {
    let rawValue: DateFormatter

    init(
        format: String = "yyyy-MM-dd",
        locale: Locale = Locale(identifier: "en_US_POSIX"),
        timeZone: TimeZone = TimeZone(secondsFromGMT: 0)!
    ) {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = locale
        formatter.timeZone = timeZone
        self.rawValue = formatter
    }
}

struct SampleSettings: Codable, Equatable {
    let username: String
    let launchCount: Int
}

struct SampleModel: Codable, Equatable {
    let name: String
    let count: Int
}

struct SampleDatedModel: Codable, Equatable {
    let name: String
    let date: Date
}

enum BrokenEncodingError: Error, LocalizedError {
    case forced

    var errorDescription: String? {
        "Encoding failed"
    }
}

struct BrokenEncodable: Encodable {
    func encode(to encoder: Encoder) throws {
        throw BrokenEncodingError.forced
    }
}

struct BrokenCodable: Codable {
    init() {}

    init(from decoder: Decoder) throws {
        self.init()
    }

    func encode(to encoder: Encoder) throws {
        throw BrokenEncodingError.forced
    }
}

final class MissingSizeAttributeFileManager: FileManager {
    override func attributesOfItem(atPath path: String) throws -> [FileAttributeKey: Any] {
        [:]
    }
}

struct SampleEntity: PrismEntity, Sendable {
    let name: String
    let count: Int
}

struct BrokenEntity: PrismEntity, Sendable {
    init() {}

    init(from decoder: Decoder) throws {
        self.init()
    }

    func encode(to encoder: Encoder) throws {
        throw BrokenEncodingError.forced
    }
}

enum SamplePrismError: PrismError {
    case detailed
    case minimal

    var description: String {
        errorDescription ?? "Unknown error"
    }

    var errorDescription: String? {
        "Something went wrong"
    }

    var failureReason: String? {
        switch self {
        case .detailed:
            "A recoverable failure happened"
        case .minimal:
            nil
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .detailed:
            "Try again later"
        case .minimal:
            nil
        }
    }
}

struct SampleMockValue: PrismMock, Equatable {
    let value: Int

    static var mock: SampleMockValue {
        .init(value: 42)
    }
}
