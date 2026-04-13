//
//  RyzeNavigationView.swift
//  Ryze
//
//  Created by Rafael Escaleira on 05/04/25.
//

import Observation
import RyzeArchitecture
import SwiftUI

/// Container de navegação do Design System RyzeUI.
///
/// `RyzeNavigationView` é um wrapper do `NavigationStack` com:
/// - Suporte a rotas tipadas via `RyzeRoutable`
/// - Navegação por push (NavigationStack)
/// - Sidebar opcional para adaptação a split view em iOS, macOS e visionOS
/// - Modal sheet (apresentação vertical)
/// - Full screen cover (tela cheia)
/// - Transição de zoom animada (iOS)
/// - Gerenciamento de estado via `RyzeRouter`
///
/// ## Uso Básico
/// ```swift
/// struct MyApp: App {
///     var body: some Scene {
///         WindowGroup {
///             RyzeNavigationView(
///                 router: RyzeRouter<AppRoute>()
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
/// ## Navegação por Push
/// ```swift
/// router.navigate(to: .detail(id: 123))
/// ```
///
/// ## Apresentação Modal
/// ```swift
/// router.present(.login)
/// ```
///
/// ## Full Screen
/// ```swift
/// router.presentFullScreen(.onboarding)
/// ```
///
/// - Note: Em iOS, as transições push usam `.zoom` com namespace animado.
/// - Important: Requer que as rotas conformem com `RyzeRoutable`.
public struct RyzeNavigationView<Content: View, Route: RyzeRoutable, Destination: View>: View {
    @Environment(\.platformContext) private var platformContext
    @Namespace private var transitionNamespace

    @Bindable private var router: RyzeRouter<Route>
    private let sidebar: (() -> AnyView)?
    private let content: () -> Content
    private let destination: (Route) -> Destination

    public init(
        router: RyzeRouter<Route>,
        @ViewBuilder destination: @escaping (Route) -> Destination,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.router = router
        self.sidebar = nil
        self.destination = destination
        self.content = content
    }

    public init<Sidebar: View>(
        router: RyzeRouter<Route>,
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
                .sheet(item: $router.fullScreenRoute, content: fullScreenDestination)
            #endif
    }

    internal static func prefersSplitNavigation(
        platformContext: RyzePlatformContext,
        hasSidebar: Bool
    ) -> Bool {
        hasSidebar
            && platformContext.navigationModel == .splitView
            && supportsSplitNavigation(on: platformContext.platform)
    }

    private static func supportsSplitNavigation(
        on platform: RyzePlatform
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
        #else
            destination(route)
        #endif
    }

    @ViewBuilder
    func modalDestination(for route: Route) -> some View {
        destination(route)
    }

    @ViewBuilder
    func fullScreenDestination(for route: Route) -> some View {
        destination(route)
    }
}
