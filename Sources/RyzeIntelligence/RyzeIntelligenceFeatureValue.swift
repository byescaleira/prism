//
//  RyzeIntelligenceFeatureValue.swift
//  Ryze
//
//  Created by Rafael Escaleira on 11/04/26.
//

import Foundation

public enum RyzeIntelligenceFeatureValue: Codable, Equatable, Hashable, Sendable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)

    public init?(_ value: Any) {
        switch value {
        case let string as String:
            self = .string(string)
        case let int as Int:
            self = .int(int)
        case let double as Double:
            self = .double(double)
        case let float as Float:
            self = .double(Double(float))
        case let bool as Bool:
            self = .bool(bool)
        case let number as NSNumber:
            if CFGetTypeID(number) == CFBooleanGetTypeID() {
                self = .bool(number.boolValue)
            } else if number.doubleValue.rounded(.towardZero) == number.doubleValue {
                self = .int(number.intValue)
            } else {
                self = .double(number.doubleValue)
            }
        default:
            return nil
        }
    }

    var foundationValue: Any {
        switch self {
        case .string(let string):
            string
        case .int(let int):
            int
        case .double(let double):
            double
        case .bool(let bool):
            bool
        }
    }

    var doubleValue: Double? {
        switch self {
        case .double(let double):
            double
        case .int(let int):
            Double(int)
        case .string, .bool:
            nil
        }
    }
}

public typealias RyzeIntelligenceFeatureRow = [String: RyzeIntelligenceFeatureValue]

public struct RyzeTextTrainingSample: Codable, Equatable, Hashable, Sendable {
    public var text: String
    public var label: String

    public init(
        text: String,
        label: String
    ) {
        self.text = text
        self.label = label
    }
}
