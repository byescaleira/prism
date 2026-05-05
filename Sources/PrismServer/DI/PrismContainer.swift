import Foundation

/// Lifetime of a registered service.
public enum PrismServiceLifetime: Sendable {
    /// A single shared instance for the container's lifetime.
    case singleton
    /// A new instance is created for each resolution.
    case transient
    /// A single instance per request scope.
    case scoped
}

/// Errors during service resolution.
public enum PrismServiceError: Error, Sendable {
    /// No service was registered for the requested type.
    case notRegistered(String)
    /// The service factory returned an incompatible type.
    case resolutionFailed(String)
}

/// Dependency injection container.
public actor PrismContainer {
    private var registrations: [String: ServiceRegistration] = [:]
    private var singletons: [String: Any] = [:]

    /// Creates an empty dependency injection container.
    public init() {}

    /// Registers a service factory with a given lifetime.
    public func register<T>(
        _ type: T.Type,
        lifetime: PrismServiceLifetime = .singleton,
        factory: @escaping @Sendable () async throws -> T
    ) {
        let key = String(describing: type)
        registrations[key] = ServiceRegistration(lifetime: lifetime, factory: factory)
    }

    /// Resolves a service by type.
    public func resolve<T>(_ type: T.Type) async throws -> T {
        let key = String(describing: type)
        guard let registration = registrations[key] else {
            throw PrismServiceError.notRegistered(key)
        }

        switch registration.lifetime {
        case .singleton:
            if let cached = singletons[key] as? T {
                return cached
            }
            let instance = try await registration.factory()
            guard let typed = instance as? T else {
                throw PrismServiceError.resolutionFailed(key)
            }
            singletons[key] = typed
            return typed
        case .transient, .scoped:
            let instance = try await registration.factory()
            guard let typed = instance as? T else {
                throw PrismServiceError.resolutionFailed(key)
            }
            return typed
        }
    }

    /// Creates a child scope for request-scoped services.
    public func createScope() -> PrismScope {
        PrismScope(registrations: registrations)
    }
}

/// A scoped child container for request-lifetime services.
public actor PrismScope {
    private let registrations: [String: ServiceRegistration]
    private var scopedInstances: [String: Any] = [:]

    init(registrations: [String: ServiceRegistration]) {
        self.registrations = registrations
    }

    /// Resolves a scoped or transient service.
    public func resolve<T>(_ type: T.Type) async throws -> T {
        let key = String(describing: type)
        guard let registration = registrations[key] else {
            throw PrismServiceError.notRegistered(key)
        }

        switch registration.lifetime {
        case .singleton:
            throw PrismServiceError.resolutionFailed("Resolve singletons from PrismContainer directly")
        case .scoped:
            if let cached = scopedInstances[key] as? T {
                return cached
            }
            let instance = try await registration.factory()
            guard let typed = instance as? T else {
                throw PrismServiceError.resolutionFailed(key)
            }
            scopedInstances[key] = typed
            return typed
        case .transient:
            let instance = try await registration.factory()
            guard let typed = instance as? T else {
                throw PrismServiceError.resolutionFailed(key)
            }
            return typed
        }
    }
}

struct ServiceRegistration: Sendable {
    let lifetime: PrismServiceLifetime
    let factory: @Sendable () async throws -> Any
}

/// Convenience for resolving services in route handlers.
extension PrismContainer {
    /// Creates a scoped resolution block.
    public func scoped<T: Sendable>(_ block: (PrismScope) async throws -> T) async throws -> T {
        let scope = createScope()
        return try await block(scope)
    }
}
