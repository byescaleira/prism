//
//  PrismRouter.swift
//  Prism
//
//  Created by Rafael Escaleira on 03/04/25.
//

import Observation

/// An observable router that manages type-safe navigation with push, modal, and full-screen presentation styles.
///
/// `PrismRouter` maintains a navigation stack (`path`), a sheet (`presentedRoute`),
/// and a full-screen cover (`fullScreenRoute`). It provides a unified API for all
/// navigation operations.
///
/// ```swift
/// enum AppRoute: PrismRoutable {
///     case home
///     case detail(id: String)
///     case settings
/// }
///
/// let router = PrismRouter<AppRoute>()
/// router.push(.detail(id: "42"))
/// router.present(.settings)
/// router.dismiss()
/// ```
@Observable
@MainActor
public final class PrismRouter<Route: PrismRoutable>: Equatable {
    /// The navigation stack of pushed routes.
    public var path: [Route]
    /// The route currently presented as a sheet, or `nil` if none.
    public var presentedRoute: Route?
    /// The route currently presented as a full-screen cover, or `nil` if none.
    public var fullScreenRoute: Route?

    @ObservationIgnored
    private let onDismiss: @MainActor @Sendable () -> Void

    /// Whether the router has an active sheet or full-screen presentation.
    public var isPresenting: Bool {
        if presentedRoute != nil {
            return true
        }

        return fullScreenRoute != nil
    }

    /// The topmost visible route, checking the stack first, then full-screen, then sheet.
    public var topRoute: Route? {
        if let route = path.last {
            return route
        }

        if let route = fullScreenRoute {
            return route
        }

        return presentedRoute
    }

    /// Creates an empty router with no active navigation.
    public init() {
        self.path = []
        self.presentedRoute = nil
        self.fullScreenRoute = nil
        self.onDismiss = {}
    }

    /// Creates a router with the given initial navigation state.
    ///
    /// - Parameters:
    ///   - path: The initial navigation stack.
    ///   - presentedRoute: An optional route to present as a sheet.
    ///   - fullScreenRoute: An optional route to present as a full-screen cover.
    public init(
        path: [Route],
        presentedRoute: Route? = nil,
        fullScreenRoute: Route? = nil
    ) {
        self.path = path
        self.presentedRoute = presentedRoute
        self.fullScreenRoute = fullScreenRoute
        self.onDismiss = {}
    }

    /// Creates a router with the given initial navigation state and a dismiss callback.
    ///
    /// The `onDismiss` closure is invoked when ``dismiss()`` is called but there is
    /// nothing left to dismiss (empty stack and no presentations).
    ///
    /// - Parameters:
    ///   - path: The initial navigation stack.
    ///   - presentedRoute: An optional route to present as a sheet.
    ///   - fullScreenRoute: An optional route to present as a full-screen cover.
    ///   - onDismiss: A closure called when dismiss is invoked with no active navigation.
    public init(
        path: [Route],
        presentedRoute: Route? = nil,
        fullScreenRoute: Route? = nil,
        onDismiss: @escaping @MainActor @Sendable () -> Void
    ) {
        self.path = path
        self.presentedRoute = presentedRoute
        self.fullScreenRoute = fullScreenRoute
        self.onDismiss = onDismiss
    }

    /// Navigates to a destination using the specified navigation style.
    ///
    /// - Parameters:
    ///   - destination: The route to navigate to.
    ///   - style: The navigation style to use. Defaults to ``PrismNavigationStyle/push``.
    public func route(
        to destination: Route,
        style: PrismNavigationStyle = .push
    ) {
        switch style {
        case .push: push(destination)
        case .present: present(destination)
        case .full: fullScreen(destination)
        }
    }

    /// Pops all routes from the navigation stack, returning to the root.
    public func root() {
        path.removeAll()
    }

    /// Dismisses the topmost navigation layer.
    ///
    /// Pops the last route from the stack if non-empty, otherwise dismisses the
    /// presented sheet, then the full-screen cover. If nothing is active, calls
    /// the `onDismiss` closure provided at initialization.
    public func dismiss() {
        if !path.isEmpty {
            path.removeLast()
        } else if presentedRoute != nil {
            presentedRoute = nil
        } else if fullScreenRoute != nil {
            fullScreenRoute = nil
        } else {
            onDismiss()
        }
    }

    /// Pushes a route onto the navigation stack.
    ///
    /// - Parameter route: The route to push.
    public func push(_ route: Route) {
        path.append(route)
    }

    /// Presents a route as a sheet, dismissing any active full-screen cover first.
    ///
    /// - Parameter route: The route to present.
    public func present(_ route: Route) {
        fullScreenRoute = nil
        presentedRoute = route
    }

    /// Presents a route as a full-screen cover, dismissing any active sheet first.
    ///
    /// - Parameter route: The route to present.
    public func fullScreen(_ route: Route) {
        presentedRoute = nil
        fullScreenRoute = route
    }
}

extension PrismRouter {
    nonisolated public static func == (lhs: PrismRouter<Route>, rhs: PrismRouter<Route>) -> Bool {
        MainActor.assumeIsolated {
            lhs.path == rhs.path
                && lhs.presentedRoute == rhs.presentedRoute
                && lhs.fullScreenRoute == rhs.fullScreenRoute
        }
    }
}
