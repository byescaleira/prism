import Foundation
import Testing

@testable import PrismServer

@Suite("PrismContainer Tests")
struct PrismContainerTests {

    @Test("Register and resolve singleton")
    func resolveSingleton() async throws {
        let container = PrismContainer()
        await container.register(Int.self, lifetime: .singleton) { 42 }
        let value = try await container.resolve(Int.self)
        #expect(value == 42)
    }

    @Test("Singleton returns same value on multiple resolves")
    func singletonSameValue() async throws {
        let container = PrismContainer()
        await container.register(String.self, lifetime: .singleton) {
            UUID().uuidString
        }
        let first = try await container.resolve(String.self)
        let second = try await container.resolve(String.self)
        #expect(first == second)
    }

    @Test("Transient creates new instance each time")
    func transientNewEachTime() async throws {
        let container = PrismContainer()
        await container.register(String.self, lifetime: .transient) {
            UUID().uuidString
        }
        let first = try await container.resolve(String.self)
        let second = try await container.resolve(String.self)
        #expect(first != second)
    }

    @Test("Resolve unregistered throws notRegistered")
    func unregisteredThrows() async {
        let container = PrismContainer()
        do {
            _ = try await container.resolve(Double.self)
            #expect(Bool(false), "Should have thrown")
        } catch let error as PrismServiceError {
            if case .notRegistered = error {
                // expected
            } else {
                #expect(Bool(false), "Wrong error type")
            }
        } catch {
            #expect(Bool(false), "Unexpected error")
        }
    }

    @Test("createScope returns a scope")
    func createScope() async {
        let container = PrismContainer()
        await container.register(Int.self, lifetime: .scoped) { 99 }
        let scope = await container.createScope()
        let value = try? await scope.resolve(Int.self)
        #expect(value == 99)
    }

    @Test("Scoped convenience method")
    func scopedConvenience() async throws {
        let container = PrismContainer()
        await container.register(String.self, lifetime: .scoped) { "hello" }
        let result = try await container.scoped { scope in
            try await scope.resolve(String.self)
        }
        #expect(result == "hello")
    }
}

@Suite("PrismScope Tests")
struct PrismScopeTests {

    @Test("Scoped returns same instance on second call")
    func scopedSameInstance() async throws {
        let container = PrismContainer()
        await container.register(String.self, lifetime: .scoped) {
            UUID().uuidString
        }
        let scope = await container.createScope()
        let first = try await scope.resolve(String.self)
        let second = try await scope.resolve(String.self)
        #expect(first == second)
    }

    @Test("Transient from scope creates new each time")
    func transientFromScope() async throws {
        let container = PrismContainer()
        await container.register(String.self, lifetime: .transient) {
            UUID().uuidString
        }
        let scope = await container.createScope()
        let first = try await scope.resolve(String.self)
        let second = try await scope.resolve(String.self)
        #expect(first != second)
    }

    @Test("Singleton from scope throws resolutionFailed")
    func singletonFromScopeThrows() async {
        let container = PrismContainer()
        await container.register(Int.self, lifetime: .singleton) { 1 }
        let scope = await container.createScope()
        do {
            _ = try await scope.resolve(Int.self)
            #expect(Bool(false), "Should have thrown")
        } catch let error as PrismServiceError {
            if case .resolutionFailed = error {
                // expected
            } else {
                #expect(Bool(false), "Wrong error type")
            }
        } catch {
            #expect(Bool(false), "Unexpected error")
        }
    }

    @Test("Resolve unregistered from scope throws")
    func unregisteredFromScope() async {
        let container = PrismContainer()
        let scope = await container.createScope()
        do {
            _ = try await scope.resolve(Double.self)
            #expect(Bool(false), "Should have thrown")
        } catch is PrismServiceError {
            // expected
        } catch {
            #expect(Bool(false), "Unexpected error")
        }
    }
}
