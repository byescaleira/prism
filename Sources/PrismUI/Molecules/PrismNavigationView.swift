//
//  PrismNavigationView.swift
//  Prism
//
//  Created by Rafael Escaleira on 05/04/25.
//

import Observation
import PrismArchitecture
import SwiftUI

/// Navigation container for the PrismUI Design System.
///
/// `PrismNavigationView` is a wrapper around `NavigationStack` with:
/// - Typed route support via `PrismRoutable`
/// - Push navigation (NavigationStack)
/// - Optional sidebar for split view adaptation on iOS, macOS, and visionOS
/// - Modal sheet (vertical presentation)
/// - Full screen cover
/// - Animated zoom transition (iOS)
/// - State management via `PrismRouter`
///
/// ## Basic Usage
/// ```swift
/// struct MyApp: App {
///     var body: some Scene {
///         WindowGroup {
///             PrismNavigationView(
///                 router: PrismRouter<AppRoute>()
///             ) { route in
///                 route.destinationView()
///             } content: {
///                 HomeView()
///             }
///         }
///     }
/// }
/// ```
///
/// ## Push Navigation
/// ```swift
/// router.navigate(to: .detail(id: 123))
/// ```
///
/// ## Modal Presentation
/// ```swift
/// router.present(.login)
/// ```
///
/// ## Full Screen
/// ```swift
/// router.presentFullScreen(.onboarding)
/// ```
///
/// - Note: On iOS, push transitions use `.zoom` with an animated namespace.
/// - Important: Requires routes to conform to `PrismRoutable`.
public struct PrismNavigationView<Content: View, Route: PrismRoutable, Destination: View>: View {
    @Environment(\.platformContext) private var platformContext
    @Environment(\.analyticsProvider) private var analyticsProvider
    @Namespace private var transitionNamespace

    @Bindable private var router: PrismRouter<Route>
    private let sidebar: (() -> AnyView)?
    private let content: () -> Content
    private let destination: (Route) -> Destination

    public init(
        router: PrismRouter<Route>,
        @ViewBuilder destination: @escaping (Route) -> Destination,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.router = router
        self.sidebar = nil
        self.destination = destination
        self.content = content
    }

    public init<Sidebar: View>(
        router: PrismRouter<Route>,
        @ViewBuilder sidebar: @escaping () -> Sidebar,
        @ViewBuilder destination: @escaping (Route) -> Destination,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.router = router
        self.sidebar = { AnyView(sidebar()) }
        self.destination = destination
        self.content = content
    }

    public var body: some View {
        navigationContainer
            .sheet(item: $router.presentedRoute, content: modalDestination)
            #if os(iOS)
                .fullScreenCover(item: $router.fullScreenRoute, content: fullScreenDestination)
            #else
                .sheet(
                    item: $router.fullScreenRoute,
                    content: { route in
                        fullScreenDestination(for: route)
                            .presentationSizing(.page)
                    }
                )
            #endif
    }

    internal static func prefersSplitNavigation(
        platformContext: PrismPlatformContext,
        hasSidebar: Bool
    ) -> Bool {
        hasSidebar
            && platformContext.navigationModel == .splitView
            && supportsSplitNavigation(on: platformContext.platform)
    }

    private static func supportsSplitNavigation(
        on platform: PrismPlatform
    ) -> Bool {
        switch platform {
        case .iOS, .macOS, .visionOS:
            true
        case .tvOS, .watchOS:
            false
        }
    }

    @ViewBuilder
    private var navigationContainer: some View {
        #if os(iOS) || os(macOS) || os(visionOS)
            if Self.prefersSplitNavigation(
                platformContext: platformContext,
                hasSidebar: sidebar != nil
            ) {
                splitNavigationView
            } else {
                stackNavigationView
            }
        #else
            stackNavigationView
        #endif
    }

    private var stackNavigationView: some View {
        NavigationStack(path: $router.path) {
            content()
                .navigationDestination(for: Route.self, destination: pushDestination)
        }
    }

    #if os(iOS) || os(macOS) || os(visionOS)
        private var splitNavigationView: some View {
            NavigationSplitView {
                if let sidebar {
                    sidebar()
                } else {
                    content()
                }
            } detail: {
                NavigationStack(path: detailPath) {
                    splitRootView
                        .navigationDestination(for: Route.self, destination: pushDestination)
                }
            }
        }

        private var splitRootView: some View {
            Group {
                if let selectedRoute = router.path.first {
                    pushDestination(for: selectedRoute)
                } else {
                    content()
                }
            }
        }

        private var detailPath: Binding<[Route]> {
            Binding(
                get: {
                    Array(router.path.dropFirst())
                },
                set: { newPath in
                    if let rootRoute = router.path.first {
                        router.path = [rootRoute] + newPath
                    } else {
                        router.path = newPath
                    }
                }
            )
        }
    #endif

    @ViewBuilder
    func pushDestination(for route: Route) -> some View {
        #if os(iOS)
            destination(route)
                .navigationTransition(.zoom(sourceID: route.id, in: transitionNamespace))
                .onAppear { trackScreenView(route) }
        #else
            destination(route)
                .onAppear { trackScreenView(route) }
        #endif
    }

    private func trackScreenView(_ route: Route) {
        guard let analyticsProvider else { return }
        analyticsProvider.track(
            .screenView(
                name: String(describing: type(of: route)),
                route: String(describing: route)
            )
        )
    }

    @ViewBuilder
    func modalDestination(for route: Route) -> some View {
        NavigationStack {
            destination(route)
        }
        #if os(macOS)
            .presentationSizing(.form)
        #endif
    }

    @ViewBuilder
    func fullScreenDestination(for route: Route) -> some View {
        NavigationStack {
            destination(route)
        }
    }
}
