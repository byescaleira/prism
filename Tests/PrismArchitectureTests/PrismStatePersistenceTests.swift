import Foundation
import Testing

@testable import PrismArchitecture

// MARK: - Test Helpers

private struct PersistenceTestState: Codable, Equatable, Sendable, PrismState {
    let name: String
    let count: Int
}

// MARK: - PrismDiskPersistence Tests

@Suite("Disk Persistence")
struct DiskPersistenceTests {
    private let directory: URL
    private let persistence: PrismDiskPersistence

    init() {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("DiskPersistenceTests-\(UUID().uuidString)")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        self.directory = dir
        self.persistence = PrismDiskPersistence(directory: dir)
    }

    private func cleanUp() {
        try? FileManager.default.removeItem(at: directory)
    }

    @Test
    func saveAndLoadRoundTrip() throws {
        defer { cleanUp() }
        let state = PersistenceTestState(name: "alpha", count: 42)

        try persistence.save(state, key: "roundtrip")
        let loaded: PersistenceTestState? = try persistence.load(key: "roundtrip")

        #expect(loaded == state)
    }

    @Test
    func loadReturnsNilForNonExistentKey() throws {
        defer { cleanUp() }
        let loaded: PersistenceTestState? = try persistence.load(key: "missing-key")

        #expect(loaded == nil)
    }

    @Test
    func clearRemovesSavedData() throws {
        defer { cleanUp() }
        let state = PersistenceTestState(name: "beta", count: 7)

        try persistence.save(state, key: "clearable")
        try persistence.clear(key: "clearable")
        let loaded: PersistenceTestState? = try persistence.load(key: "clearable")

        #expect(loaded == nil)
    }

    @Test
    func clearDoesNotThrowForNonExistentKey() throws {
        defer { cleanUp() }
        try persistence.clear(key: "never-saved")
    }
}

// MARK: - PrismUserDefaultsPersistence Tests

@Suite("UserDefaults Persistence")
struct UserDefaultsPersistenceTests {
    private let suiteName: String
    private let persistence: PrismUserDefaultsPersistence

    init() {
        let suite = "com.prism.tests.persistence.\(UUID().uuidString)"
        self.suiteName = suite
        self.persistence = PrismUserDefaultsPersistence(suiteName: suite)
    }

    private func cleanUp() {
        UserDefaults().removePersistentDomain(forName: suiteName)
    }

    @Test
    func saveAndLoadRoundTrip() throws {
        defer { cleanUp() }
        let state = PersistenceTestState(name: "gamma", count: 99)

        try persistence.save(state, key: "roundtrip")
        let loaded: PersistenceTestState? = try persistence.load(key: "roundtrip")

        #expect(loaded == state)
    }

    @Test
    func loadReturnsNilForMissingKey() throws {
        defer { cleanUp() }
        let loaded: PersistenceTestState? = try persistence.load(key: "absent-key")

        #expect(loaded == nil)
    }

    @Test
    func clearRemovesEntry() throws {
        defer { cleanUp() }
        let state = PersistenceTestState(name: "delta", count: 3)

        try persistence.save(state, key: "removable")
        try persistence.clear(key: "removable")
        let loaded: PersistenceTestState? = try persistence.load(key: "removable")

        #expect(loaded == nil)
    }
}

// MARK: - PrismPersistenceError Tests

@Suite("Persistence Error")
struct PersistenceErrorTests {
    @Test
    func keychainWriteFailedCarriesStatus() {
        let error = PrismPersistenceError.keychainWriteFailed(-25299)

        if case .keychainWriteFailed(let status) = error {
            #expect(status == -25299)
        } else {
            Issue.record("Expected .keychainWriteFailed")
        }
    }

    @Test
    func keychainReadFailedCarriesStatus() {
        let error = PrismPersistenceError.keychainReadFailed(-25300)

        if case .keychainReadFailed(let status) = error {
            #expect(status == -25300)
        } else {
            Issue.record("Expected .keychainReadFailed")
        }
    }

    @Test
    func keychainDeleteFailedCarriesStatus() {
        let error = PrismPersistenceError.keychainDeleteFailed(-25244)

        if case .keychainDeleteFailed(let status) = error {
            #expect(status == -25244)
        } else {
            Issue.record("Expected .keychainDeleteFailed")
        }
    }

    @Test
    func errorConformsToErrorProtocol() {
        let error: any Error = PrismPersistenceError.keychainWriteFailed(0)
        #expect(error is PrismPersistenceError)
    }

    @Test
    func errorConformsToSendable() {
        let error: any Sendable = PrismPersistenceError.keychainReadFailed(0)
        #expect(error is PrismPersistenceError)
    }
}
