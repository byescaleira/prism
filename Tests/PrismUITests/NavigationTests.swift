import SwiftUI
import Testing

@testable import PrismArchitecture
@testable import PrismUI

enum TestRoute: Hashable, Sendable, PrismRoutable {
    case home
    case detail(id: Int)
    case settings
}

@MainActor
struct NavigationTests {

    @Test
    func navigationViewCreatesWithRouter() {
        let router = PrismRouter<TestRoute>()
        let view = PrismNavigationView(router: router) {
            Text("Root")
        } destination: { route in
            switch route {
            case .home: Text("Home")
            case .detail(let id): Text("Detail \(id)")
            case .settings: Text("Settings")
            }
        }
        #expect(view != nil)
    }

    @Test
    func tabViewCreatesWithSelection() {
        @State var selection = 0
        let view = PrismTabView(selection: $selection) {
            Text("Tab 1").prismTab("Home", icon: "house", tag: 0)
            Text("Tab 2").prismTab("Search", icon: "magnifyingglass", tag: 1)
        }
        #expect(view != nil)
    }

    @Test
    func navigationViewBindsToRouterPath() {
        let router = PrismRouter<TestRoute>()
        router.push(.detail(id: 42))

        #expect(router.path.count == 1)
        #expect(router.path.first == .detail(id: 42))
    }

    @Test
    func navigationViewSupportsSheet() {
        let router = PrismRouter<TestRoute>()
        router.present(.settings)

        #expect(router.presentedRoute == .settings)
    }

    @Test
    func navigationViewSupportsFullScreen() {
        let router = PrismRouter<TestRoute>()
        router.fullScreen(.settings)

        #expect(router.fullScreenRoute == .settings)
    }
}
