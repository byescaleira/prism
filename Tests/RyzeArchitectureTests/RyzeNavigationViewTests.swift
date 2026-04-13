import RyzeArchitecture
import SwiftUI
import Testing

@testable import RyzeUI

@MainActor
struct RyzeNavigationViewTests {
    @Test
    func navigationViewBuildsBodyAndDestinations() {
        let router = RyzeRouter<SampleRoute>()
        let view = RyzeNavigationView(
            router: router,
            destination: { route in
                Text(String(describing: route))
            },
            content: {
                Text("Root")
            }
        )

        _ = view.body
        _ = view.pushDestination(for: .home)
        _ = view.modalDestination(for: .modal)
        _ = view.fullScreenDestination(for: .fullScreen)
    }

    @Test
    func navigationViewBuildsWithAdaptiveSidebarSupport() {
        let router = RyzeRouter<SampleRoute>(
            path: [.details(id: 1)]
        )
        let view = RyzeNavigationView(
            router: router,
            sidebar: {
                Text("Sidebar")
            },
            destination: { route in
                Text(String(describing: route))
            },
            content: {
                Text("Root")
            }
        )

        _ = view.body
        _ = view.pushDestination(for: .details(id: 2))
    }

    @Test
    func navigationViewPrefersSplitOnlyWhenPlatformAndSidebarAllowIt() {
        let desktop = RyzePlatformContext.resolve(
            platform: .macOS,
            layoutTier: .regular
        )
        let tv = RyzePlatformContext.resolve(
            platform: .tvOS,
            layoutTier: .regular
        )

        #expect(
            RyzeNavigationView<Text, SampleRoute, Text>.prefersSplitNavigation(
                platformContext: desktop,
                hasSidebar: true
            )
        )
        #expect(
            !RyzeNavigationView<Text, SampleRoute, Text>.prefersSplitNavigation(
                platformContext: desktop,
                hasSidebar: false
            )
        )
        #expect(
            !RyzeNavigationView<Text, SampleRoute, Text>.prefersSplitNavigation(
                platformContext: tv,
                hasSidebar: true
            )
        )
    }
}
