//
//  PrismEntity.swift
//  Prism
//
//  Created by Rafael Escaleira on 24/03/25.
//

import Foundation

public protocol PrismEntity:
    Codable,
    Equatable,
    Hashable,
    CustomStringConvertible,
    PrismLogger
{
}

extension PrismEntity {
    public func log() {
        let logger = PrismFoundationLogger()
        do {
            let content = try json
            logger.info(.message(content))
        } catch {
            logger.error(.error(error))
        }
    }

    public var description: String {
        do {
            return try json
        } catch {
            return error.localizedDescription
        }
    }
}

extension Array: PrismEntity where Element: PrismEntity {}

extension Array: PrismLogger where Element: PrismEntity {
    public func log() {
        let logger = PrismFoundationLogger()
        do {
            let content = try json
            logger.info(.message(content))
        } catch {
            logger.error(.error(error))
        }
    }
}
