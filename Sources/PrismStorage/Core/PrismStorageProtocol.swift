import Foundation

/// Universal storage interface — every engine conforms.
public protocol PrismStorageProtocol: Sendable {
    func save<T: Codable & Sendable>(_ value: T, forKey key: String) throws
    func load<T: Codable & Sendable>(_ type: T.Type, forKey key: String) throws -> T?
    func delete(forKey key: String) throws
    func exists(forKey key: String) throws -> Bool
    func clear() throws
    func keys() throws -> [String]
}

/// Async variant for actor-based stores.
public protocol PrismAsyncStorageProtocol: Sendable {
    func save<T: Codable & Sendable>(_ value: T, forKey key: String) async throws
    func load<T: Codable & Sendable>(_ type: T.Type, forKey key: String) async throws -> T?
    func delete(forKey key: String) async throws
    func exists(forKey key: String) async throws -> Bool
    func clear() async throws
    func keys() async throws -> [String]
}
