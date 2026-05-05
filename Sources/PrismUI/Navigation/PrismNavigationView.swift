import PrismArchitecture
import SwiftUI

/// SwiftUI navigation container that binds to a `PrismRouter`.
///
/// Bridges the Architecture module's `PrismRouter` with SwiftUI's
/// `NavigationStack`, sheet, and full-screen cover presentations.
public struct PrismNavigationView<Content: View, Route: PrismRoutable, Destination: View>: View {
    @Bindable private var router: PrismRouter<Route>

    private let content: Content
    private let destination: (Route) -> Destination

    /// Creates a navigation view bound to a router with content and destination builders.
    public init(
        router: PrismRouter<Route>,
        @ViewBuilder content: () -> Content,
        @ViewBuilder destination: @escaping (Route) -> Destination
    ) {
        self.router = router
        self.content = content()
        self.destination = destination
    }

    /// The content and behavior of the navigation view.
    public var body: some View {
        NavigationStack(path: $router.path) {
            content
                .navigationDestination(for: Route.self, destination: destination)
        }
        .sheet(item: $router.presentedRoute) { route in
            destination(route)
        }
        #if !os(macOS) && !os(watchOS)
        .fullScreenCover(item: $router.fullScreenRoute) { route in
            destination(route)
        }
        #endif
    }
}
