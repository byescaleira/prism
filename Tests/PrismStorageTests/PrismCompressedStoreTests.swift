import Foundation
import Testing

@testable import PrismStorage

@Suite("CmpStore")
struct PrismCompressedStoreTests {
    func makeStore(
        algorithm: NSData.CompressionAlgorithm = .lzfse
    ) -> PrismCompressedStore {
        let defaults = PrismDefaultsStore(
            suite: "CmpTest-\(UUID().uuidString)"
        )
        return PrismCompressedStore(wrapping: defaults, algorithm: algorithm)
    }

    @Test("Compress and decompress string")
    func roundTrip() throws {
        let store = makeStore()
        let text = String(repeating: "PrismStorage rocks! ", count: 100)
        try store.save(text, forKey: "big")
        let loaded = try store.load(String.self, forKey: "big")
        #expect(loaded == text)
    }

    @Test("Compress and decompress codable")
    func codableRoundTrip() throws {
        struct Payload: Codable, Sendable, Equatable {
            let items: [Int]
        }
        let store = makeStore()
        let payload = Payload(items: Array(0..<1000))
        try store.save(payload, forKey: "arr")
        let loaded = try store.load(Payload.self, forKey: "arr")
        #expect(loaded == payload)
    }

    @Test("Load missing returns nil")
    func loadMissing() throws {
        let store = makeStore()
        #expect(try store.load(String.self, forKey: "nope") == nil)
    }

    @Test("Delete removes value")
    func deleteWorks() throws {
        let store = makeStore()
        try store.save("x", forKey: "d")
        try store.delete(forKey: "d")
        #expect(try store.load(String.self, forKey: "d") == nil)
    }

    @Test("Clear removes all")
    func clearWorks() throws {
        let store = makeStore()
        try store.save("a", forKey: "c1")
        try store.save("b", forKey: "c2")
        try store.clear()
        #expect(try store.keys().isEmpty)
    }

    @Test("LZMA algorithm")
    func lzmaAlgorithm() throws {
        let store = makeStore(algorithm: .lzma)
        try store.save("lzma test data", forKey: "lz")
        #expect(try store.load(String.self, forKey: "lz") == "lzma test data")
    }

    @Test("Zlib algorithm")
    func zlibAlgorithm() throws {
        let store = makeStore(algorithm: .zlib)
        try store.save("zlib test data", forKey: "zl")
        #expect(try store.load(String.self, forKey: "zl") == "zlib test data")
    }

    @Test("LZ4 algorithm")
    func lz4Algorithm() throws {
        let store = makeStore(algorithm: .lz4)
        try store.save("lz4 test data", forKey: "l4")
        #expect(try store.load(String.self, forKey: "l4") == "lz4 test data")
    }
}
