import Foundation
import Testing

@testable import PrismCapabilities

// MARK: - App Intent Tests

@Suite("PrismAppIntents")
struct PrismAppIntentTests {

    @Test("PrismIntentDonation stores properties correctly")
    func donationProperties() {
        let id = UUID()
        let timestamp = Date()
        let donation = PrismIntentDonation(
            id: id,
            intentType: "com.app.orderCoffee",
            title: "Order Latte",
            subtitle: "Grande, oat milk",
            timestamp: timestamp,
            metadata: ["size": "grande", "milk": "oat"]
        )
        #expect(donation.id == id)
        #expect(donation.intentType == "com.app.orderCoffee")
        #expect(donation.title == "Order Latte")
        #expect(donation.subtitle == "Grande, oat milk")
        #expect(donation.timestamp == timestamp)
        #expect(donation.metadata["size"] == "grande")
        #expect(donation.metadata["milk"] == "oat")
    }

    @Test("PrismIntentDonation has sensible defaults")
    func donationDefaults() {
        let donation = PrismIntentDonation(
            intentType: "com.app.test",
            title: "Test"
        )
        #expect(donation.subtitle == nil)
        #expect(donation.metadata.isEmpty)
    }

    @Test("PrismShortcutPhrase stores properties correctly")
    func shortcutPhraseProperties() {
        let phrase = PrismShortcutPhrase(
            phrase: "Order my usual",
            intentType: "com.app.orderCoffee"
        )
        #expect(phrase.phrase == "Order my usual")
        #expect(phrase.intentType == "com.app.orderCoffee")
    }

    @Test("PrismIntentPrediction stores properties correctly")
    func predictionProperties() {
        let prediction = PrismIntentPrediction(
            intentType: "com.app.startWorkout",
            title: "Start Morning Run",
            parameters: ["type": "running", "duration": "30"]
        )
        #expect(prediction.intentType == "com.app.startWorkout")
        #expect(prediction.title == "Start Morning Run")
        #expect(prediction.parameters["type"] == "running")
        #expect(prediction.parameters["duration"] == "30")
    }

    @Test("PrismIntentPrediction defaults parameters to empty")
    func predictionDefaults() {
        let prediction = PrismIntentPrediction(
            intentType: "com.app.test",
            title: "Test"
        )
        #expect(prediction.parameters.isEmpty)
    }

    @Test("PrismSiriTipStyle has 3 cases")
    func siriTipStyleCaseCount() {
        #expect(PrismSiriTipStyle.allCases.count == 3)
    }

    @Test("PrismSiriTipStyle includes all expected cases")
    func siriTipStyleCases() {
        let cases = PrismSiriTipStyle.allCases
        #expect(cases.contains(.automatic))
        #expect(cases.contains(.light))
        #expect(cases.contains(.dark))
    }

    @Test("PrismAppIntentClient initializes with empty predictions")
    @MainActor func clientInitialState() {
        let client = PrismAppIntentClient()
        #expect(client.predictions.isEmpty)
    }
}
