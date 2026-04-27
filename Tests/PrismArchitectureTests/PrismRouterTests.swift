import Testing

@testable import PrismArchitecture

@MainActor
struct PrismRouterTests {
    @Test
    func routeUsesExplicitStyleToChooseDestination() {
        let router = PrismRouter<SampleRoute>()

        router.route(to: .details(id: 7))
        router.route(
            to: .modal,
            style: .present
        )

        #expect(router.path == [.details(id: 7)])
        #expect(router.presentedRoute == .modal)
        #expect(router.fullScreenRoute == nil)
        #expect(router.topRoute == .details(id: 7))

        router.route(
            to: .fullScreen,
            style: .full
        )

        #expect(router.presentedRoute == nil)
        #expect(router.fullScreenRoute == .fullScreen)
    }

    @Test
    func dismissPrefersPathThenModalThenFullScreenThenParent() {
        var dismissCount = 0
        let router = PrismRouter<SampleRoute>(
            path: [.home, .details(id: 1)],
            presentedRoute: .modal,
            fullScreenRoute: .fullScreen,
            onDismiss: {
                dismissCount += 1
            }
        )

        router.dismiss()
        #expect(router.path == [.home])
        #expect(router.presentedRoute == .modal)

        router.root()
        router.dismiss()
        #expect(router.presentedRoute == nil)
        #expect(router.fullScreenRoute == .fullScreen)

        router.dismiss()
        #expect(router.fullScreenRoute == nil)

        router.dismiss()
        #expect(dismissCount == 1)
    }

    @Test
    func explicitPushPresentAndFullScreenAreAvailable() {
        let router = PrismRouter<SampleRoute>()

        router.push(.home)
        router.present(.modal)
        router.fullScreen(.fullScreen)

        #expect(router.path == [.home])
        #expect(router.isPresenting)
        #expect(router.topRoute == .home)
    }

    @Test
    func emptyAndModalOnlyRoutersExposeExpectedTopRouteState() {
        let emptyRouter = PrismRouter<SampleRoute>()
        let fullScreenRouter = PrismRouter<SampleRoute>(
            path: [],
            fullScreenRoute: .fullScreen
        )
        let modalRouter = PrismRouter<SampleRoute>(
            path: [],
            presentedRoute: .modal
        )

        #expect(emptyRouter.isPresenting == false)
        #expect(emptyRouter.topRoute == nil)
        #expect(fullScreenRouter.topRoute == .fullScreen)
        #expect(modalRouter.topRoute == .modal)
    }

    @Test
    func equalityIgnoresDismissClosureAndTracksRoutingState() {
        let lhs = PrismRouter<SampleRoute>(
            path: [.home],
            presentedRoute: .modal
        )
        let rhs = PrismRouter<SampleRoute>(
            path: [.home],
            presentedRoute: .modal,
            onDismiss: {}
        )
        let different = PrismRouter<SampleRoute>(
            path: [.details(id: 1)]
        )

        #expect(lhs == rhs)
        #expect(lhs != different)
    }

    @Test
    func routableDefaultIdAndHashableConformanceStayStable() {
        let routes: Set<SampleRoute> = [.home, .home, .details(id: 2)]

        #expect(SampleRoute.modal.id == .modal)
        #expect(routes.count == 2)
    }
}
