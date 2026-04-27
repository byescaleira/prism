import Foundation
import Testing

@testable import PrismFoundation

struct PrismAnalyticsTests {

    // MARK: - Event Construction

    @Test
    func buttonTapEventHasCorrectNameAndParameters() {
        let event = PrismAnalyticsEvent.buttonTap(label: "Sign In", testID: "login_btn")

        #expect(event.name == "button_tap")
        #expect(event.parameters["label"] == "Sign In")
        #expect(event.parameters["test_id"] == "login_btn")
    }

    @Test
    func screenViewEventHasCorrectNameAndParameters() {
        let event = PrismAnalyticsEvent.screenView(name: "Home", route: "home")

        #expect(event.name == "screen_view")
        #expect(event.parameters["screen_name"] == "Home")
        #expect(event.parameters["route"] == "home")
    }

    @Test
    func fieldInteractionEventHasCorrectNameAndParameters() {
        let event = PrismAnalyticsEvent.fieldInteraction(testID: "email_field", action: "focus")

        #expect(event.name == "field_interaction")
        #expect(event.parameters["test_id"] == "email_field")
        #expect(event.parameters["action"] == "focus")
    }

    @Test
    func carouselScrollEventHasCorrectNameAndParameters() {
        let event = PrismAnalyticsEvent.carouselScroll(testID: "featured", index: 3)

        #expect(event.name == "carousel_scroll")
        #expect(event.parameters["test_id"] == "featured")
        #expect(event.parameters["index"] == "3")
    }

    @Test
    func tabSelectEventHasCorrectNameAndParameters() {
        let event = PrismAnalyticsEvent.tabSelect(testID: "main_tabs", tab: "settings")

        #expect(event.name == "tab_select")
        #expect(event.parameters["test_id"] == "main_tabs")
        #expect(event.parameters["tab"] == "settings")
    }

    @Test
    func menuActionEventHasCorrectNameAndParameters() {
        let event = PrismAnalyticsEvent.menuAction(testID: "options_menu", action: "delete")

        #expect(event.name == "menu_action")
        #expect(event.parameters["test_id"] == "options_menu")
        #expect(event.parameters["action"] == "delete")
    }

    @Test
    func customEventHasCorrectNameAndParameters() {
        let event = PrismAnalyticsEvent.custom("purchase", parameters: ["sku": "ABC123"])

        #expect(event.name == "purchase")
        #expect(event.parameters["sku"] == "ABC123")
    }

    @Test
    func eventTimestampIsSetOnCreation() {
        let before = Date.now
        let event = PrismAnalyticsEvent(name: "test")
        let after = Date.now

        #expect(event.timestamp >= before)
        #expect(event.timestamp <= after)
    }

    @Test
    func eventEqualityComparesByNameAndParameters() {
        let a = PrismAnalyticsEvent(
            name: "tap",
            parameters: ["id": "1"],
            timestamp: .distantPast
        )
        let b = PrismAnalyticsEvent(
            name: "tap",
            parameters: ["id": "1"],
            timestamp: .distantFuture
        )
        #expect(a != b)

        let c = PrismAnalyticsEvent(name: "tap", parameters: ["id": "1"], timestamp: a.timestamp)
        #expect(a == c)
    }

    @Test
    func emptyParametersDefaultIsUsed() {
        let event = PrismAnalyticsEvent(name: "test_event")
        #expect(event.parameters.isEmpty)
    }

    // MARK: - Provider Protocol

    @Test
    func providerReceivesTrackedEvent() {
        let spy = SpyAnalyticsProvider()
        let event = PrismAnalyticsEvent.buttonTap(label: "OK", testID: "ok_btn")

        spy.track(event)

        #expect(spy.events.count == 1)
        #expect(spy.events.first?.name == "button_tap")
    }

    @Test
    func providerTracksMultipleEvents() {
        let spy = SpyAnalyticsProvider()

        spy.track(.buttonTap(label: "A", testID: "a"))
        spy.track(.screenView(name: "Home"))
        spy.track(.custom("custom"))

        #expect(spy.events.count == 3)
        #expect(spy.events.map(\.name) == ["button_tap", "screen_view", "custom"])
    }
}

// MARK: - Test Support

final class SpyAnalyticsProvider: PrismAnalyticsProvider, @unchecked Sendable {
    var events: [PrismAnalyticsEvent] = []

    func track(_ event: PrismAnalyticsEvent) {
        events.append(event)
    }
}
