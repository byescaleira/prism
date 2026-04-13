//
//  PrismRouter.swift
//  Prism
//
//  Created by Rafael Escaleira on 03/04/25.
//

import Observation

@Observable
@MainActor
public final class PrismRouter<Route: PrismRoutable>: Equatable {
    public var path: [Route]
    public var presentedRoute: Route?
    public var fullScreenRoute: Route?

    @ObservationIgnored
    private let onDismiss: @MainActor @Sendable () -> Void

    public var isPresenting: Bool {
        if presentedRoute != nil {
            return true
        }

        return fullScreenRoute != nil
    }

    public var topRoute: Route? {
        if let route = path.last {
            return route
        }

        if let route = fullScreenRoute {
            return route
        }

        return presentedRoute
    }

    public init() {
        self.path = []
        self.presentedRoute = nil
        self.fullScreenRoute = nil
        self.onDismiss = {}
    }

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

    public func root() {
        path.removeAll()
    }

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

    public func push(_ route: Route) {
        path.append(route)
    }

    public func present(_ route: Route) {
        presentedRoute = route
    }

    public func fullScreen(_ route: Route) {
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
