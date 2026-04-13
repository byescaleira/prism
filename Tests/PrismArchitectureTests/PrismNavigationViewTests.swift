import PrismArchitecture
import SwiftUI
import Testing

@testable import PrismUI

@MainActor
struct PrismNavigationViewTests {
    @Test
    func navigationViewBuildsBodyAndDestinations() {
        let router = PrismRouter<SampleRoute>()
        let view = PrismNavigationView(
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
        let router = PrismRouter<SampleRoute>(
            path: [.details(id: 1)]
        )
        let view = PrismNavigationView(
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
        let desktop = PrismPlatformContext.resolve(
            platform: .macOS,
            layoutTier: .regular
        )
        let tv = PrismPlatformContext.resolve(
            platform: .tvOS,
            layoutTier: .regular
        )

        #expect(
            PrismNavigationView<Text, SampleRoute, Text>.prefersSplitNavigation(
                platformContext: desktop,
                hasSidebar: true
            )
        )
        #expect(
            !PrismNavigationView<Text, SampleRoute, Text>.prefersSplitNavigation(
                platformContext: desktop,
                hasSidebar: false
            )
        )
        #expect(
            !PrismNavigationView<Text, SampleRoute, Text>.prefersSplitNavigation(
                platformContext: tv,
                hasSidebar: true
            )
        )
    }
}
