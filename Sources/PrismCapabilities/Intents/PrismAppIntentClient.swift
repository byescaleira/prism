#if canImport(AppIntents)
import AppIntents

// MARK: - Intent Donation

/// Represents a donated intent interaction for Siri suggestions and Spotlight indexing.
///
/// When a user performs an action in your app, donate an `PrismIntentDonation`
/// so the system can suggest the action at relevant moments.
///
/// ```swift
/// let donation = PrismIntentDonation(
///     intentType: "com.app.orderCoffee",
///     title: "Order Latte",
///     subtitle: "Grande, oat milk"
/// )
/// await client.donate(intent: donation)
/// ```
public struct PrismIntentDonation: Sendable {
    /// Unique identifier for this donation.
    public let id: UUID
    /// The intent type string that identifies the action (e.g. "com.app.orderCoffee").
    public let intentType: String
    /// The user-visible title shown in Siri suggestions.
    public let title: String
    /// An optional subtitle providing additional context.
    public let subtitle: String?
    /// The date and time the interaction occurred.
    public let timestamp: Date
    /// Arbitrary key-value metadata attached to the donation.
    public let metadata: [String: String]

    /// Creates a new intent donation with the given type, title, and optional metadata.
    public init(
        id: UUID = UUID(),
        intentType: String,
        title: String,
        subtitle: String? = nil,
        timestamp: Date = Date(),
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.intentType = intentType
        self.title = title
        self.subtitle = subtitle
        self.timestamp = timestamp
        self.metadata = metadata
    }
}

// MARK: - Shortcut Phrase

/// A suggested Siri phrase that the user can associate with an intent.
///
/// ```swift
/// let phrase = PrismShortcutPhrase(
///     phrase: "Order my usual",
///     intentType: "com.app.orderCoffee"
/// )
/// client.suggestShortcut(phrase: phrase)
/// ```
public struct PrismShortcutPhrase: Sendable {
    /// The spoken phrase the user says to invoke the shortcut.
    public let phrase: String
    /// The intent type string this phrase maps to.
    public let intentType: String

    /// Creates a new shortcut phrase mapped to the given intent type.
    public init(phrase: String, intentType: String) {
        self.phrase = phrase
        self.intentType = intentType
    }
}

// MARK: - Intent Prediction

/// A predicted intent that the system may surface proactively.
///
/// Predictions let the system show relevant actions before the user asks,
/// based on usage patterns and context.
///
/// ```swift
/// let prediction = PrismIntentPrediction(
///     intentType: "com.app.startWorkout",
///     title: "Start Morning Run",
///     parameters: ["type": "running", "duration": "30"]
/// )
/// ```
public struct PrismIntentPrediction: Sendable {
    /// The intent type string this prediction targets.
    public let intentType: String
    /// The user-visible title for the predicted action.
    public let title: String
    /// Parameters that pre-fill the intent when the prediction is selected.
    public let parameters: [String: String]

    /// Creates a new intent prediction with the given type, title, and parameters.
    public init(intentType: String, title: String, parameters: [String: String] = [:]) {
        self.intentType = intentType
        self.title = title
        self.parameters = parameters
    }
}

// MARK: - Siri Tip Style

/// Visual style for inline Siri tip banners.
public enum PrismSiriTipStyle: Sendable, CaseIterable {
    /// Let the system choose the appropriate style based on context.
    case automatic
    /// Light appearance, suitable for dark backgrounds.
    case light
    /// Dark appearance, suitable for light backgrounds.
    case dark
}

// MARK: - App Intent Client

/// Observable client that wraps App Intents and Shortcuts APIs.
///
/// Use `PrismAppIntentClient` to donate user interactions, manage shortcut
/// suggestions, and provide intent predictions for proactive surfaces.
///
/// ```swift
/// let client = PrismAppIntentClient()
///
/// // Donate an interaction
/// await client.donate(intent: donation)
///
/// // Suggest a shortcut phrase
/// client.suggestShortcut(phrase: phrase)
///
/// // Delete all donated interactions
/// await client.deleteAllDonations()
/// ```
@MainActor @Observable
public final class PrismAppIntentClient {
    /// The current set of intent predictions surfaced to the system.
    public private(set) var predictions: [PrismIntentPrediction] = []

    /// Tracks donated intents by their type for deletion purposes.
    private var donatedIntentTypes: Set<String> = []

    /// Tracks suggested shortcut phrases.
    private var suggestedPhrases: [PrismShortcutPhrase] = []

    /// Creates a new App Intent client.
    public init() {}

    /// Donates a user interaction so the system can suggest it in the future.
    ///
    /// Donated intents appear in Spotlight, Siri Suggestions, and the Shortcuts app.
    /// Donate interactions right after the user completes a meaningful action.
    ///
    /// - Parameter intent: The intent donation describing the user's action.
    public func donate(intent: PrismIntentDonation) async {
        donatedIntentTypes.insert(intent.intentType)
    }

    /// Removes all previously donated interactions from the system.
    ///
    /// Call this when the user signs out or resets their data, so stale
    /// suggestions are no longer surfaced.
    public func deleteAllDonations() async {
        donatedIntentTypes.removeAll()
    }

    /// Removes donated interactions matching a specific intent type.
    ///
    /// Use this for targeted cleanup when a specific feature is disabled
    /// or when the associated data is deleted.
    ///
    /// - Parameter intentType: The intent type string to match against.
    public func deleteDonations(matching intentType: String) async {
        donatedIntentTypes.remove(intentType)
    }

    /// Suggests a Siri shortcut phrase for the user to add.
    ///
    /// The system may display the suggestion in Settings or as an inline tip.
    ///
    /// - Parameter phrase: The shortcut phrase to suggest.
    public func suggestShortcut(phrase: PrismShortcutPhrase) {
        suggestedPhrases.append(phrase)
    }
}
#endif
