import Foundation

// MARK: - App Clip Region

/// A geographic region associated with an App Clip invocation.
public struct PrismAppClipRegion: Sendable {
    /// The latitude of the region center.
    public let latitude: Double
    /// The longitude of the region center.
    public let longitude: Double
    /// The radius of the region in meters.
    public let radius: Double

    /// Creates a new App Clip region with the given center and radius.
    public init(latitude: Double, longitude: Double, radius: Double) {
        self.latitude = latitude
        self.longitude = longitude
        self.radius = radius
    }
}

// MARK: - App Clip Invocation

/// Parsed data from an App Clip launch URL.
public struct PrismAppClipInvocation: Sendable {
    /// The URL that triggered the App Clip.
    public let url: URL
    /// The extracted payload string from the URL.
    public let payload: String?
    /// The geographic region associated with the invocation.
    public let region: PrismAppClipRegion?

    /// Creates a new App Clip invocation with the given URL and optional payload and region.
    public init(url: URL, payload: String? = nil, region: PrismAppClipRegion? = nil) {
        self.url = url
        self.payload = payload
        self.region = region
    }
}

// MARK: - App Clip Experience

/// The type of App Clip experience being presented.
public enum PrismAppClipExperience: Sendable {
    /// The default App Clip experience without additional configuration.
    case defaultExperience
    /// An advanced App Clip experience identified by a custom string.
    case advancedExperience(String)
}

// MARK: - App Clip Client

#if canImport(AppClip) && canImport(UIKit)
    import AppClip
    import CoreLocation
    import UIKit
    import StoreKit

    /// Client for handling App Clip invocations, location verification, and full app promotion.
    public final class PrismAppClipClient: Sendable {

        /// Creates a new App Clip client.
        public init() {}

        /// Parses an invocation URL into a structured App Clip invocation.
        public func handleInvocation(url: URL) -> PrismAppClipInvocation {
            let payload = url.query
            return PrismAppClipInvocation(url: url, payload: payload)
        }

        /// Verifies whether the user's location matches the expected App Clip region.
        public func verifyLocation(latitude: Double, longitude: Double) async -> Bool {
            await withCheckedContinuation { continuation in
                guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
                    continuation.resume(returning: false)
                    return
                }
                scene.confirmVerifiedPromptForExperience(
                    inRegion: CLCircularRegion(
                        center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                        radius: 100,
                        identifier: "prism-verify"
                    )
                ) { verified, _ in
                    continuation.resume(returning: verified)
                }
            }
        }

        /// Prompts the user to install the full app from the App Store.
        @MainActor
        public func requestFullAppInstall() {
            guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
                return
            }
            let overlay = SKOverlay(configuration: SKOverlay.AppClipConfiguration(position: .bottom))
            overlay.present(in: scene)
        }
    }
#endif
