import SwiftUI

/// Type-safe navigation path wrapper with convenience push/pop.
///
/// ```swift
/// @State private var path = PrismNavigationPath<Route>()
///
/// NavigationStack(path: $path.raw) {
///     content
///         .navigationDestination(for: Route.self) { route in ... }
/// }
///
/// path.push(.detail(id: 42))
/// path.pop()
/// path.popToRoot()
/// ```
@MainActor
@Observable
public final class PrismNavigationPath<Route: Hashable>: @unchecked Sendable {
    /// The underlying array of routes in the navigation stack.
    public var raw: [Route] = []

    /// Creates a navigation path with an optional initial set of routes.
    public init(_ initial: [Route] = []) {
        self.raw = initial
    }

    /// The number of routes currently in the navigation stack.
    public var count: Int { raw.count }
    /// Whether the navigation stack is empty.
    public var isEmpty: Bool { raw.isEmpty }
    /// The topmost route in the navigation stack, or nil if empty.
    public var current: Route? { raw.last }

    /// Pushes a new route onto the navigation stack.
    public func push(_ route: Route) {
        raw.append(route)
    }

    /// Pops the topmost route from the navigation stack.
    public func pop() {
        guard !raw.isEmpty else { return }
        raw.removeLast()
    }

    /// Removes all routes, returning to the root of the navigation stack.
    public func popToRoot() {
        raw.removeAll()
    }

    /// Replaces the entire navigation stack with the given routes.
    public func replace(with routes: [Route]) {
        raw = routes
    }
}
