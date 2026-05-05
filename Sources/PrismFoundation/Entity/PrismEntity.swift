//
//  PrismEntity.swift
//  Prism
//
//  Created by Rafael Escaleira on 24/03/25.
//

import Foundation

/// Base protocol for Codable entities with integrated logging.
public protocol PrismEntity:
    Codable,
    Equatable,
    Hashable,
    CustomStringConvertible,
    PrismLogger
{
}

extension PrismEntity {
    /// Logs the entity's JSON representation, or logs the error if encoding fails.
    public func log() {
        let logger = PrismFoundationLogger()
        do {
            let content = try json
            logger.info(.message(content))
        } catch {
            logger.error(.error(error))
        }
    }

    /// The JSON string representation of this entity, or the error description if encoding fails.
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
    /// Logs the array's JSON representation, or logs the error if encoding fails.
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
