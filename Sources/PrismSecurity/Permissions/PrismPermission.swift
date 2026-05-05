import Foundation

/// Unified permission types supported by PrismSecurity.
public enum PrismPermission: String, Sendable, CaseIterable, Hashable {
    case camera
    case microphone
    case photoLibrary
    case photoLibraryAddOnly
    case contacts
    case calendars
    case reminders
    case locationWhenInUse
    case locationAlways
    case notifications
    case speechRecognition
    case motionAndFitness
    case bluetooth
    case mediaLibrary
    case tracking
    case faceID

    /// Human-readable display name.
    public var displayName: String {
        switch self {
        case .camera: "Camera"
        case .microphone: "Microphone"
        case .photoLibrary: "Photo Library"
        case .photoLibraryAddOnly: "Photo Library (Add Only)"
        case .contacts: "Contacts"
        case .calendars: "Calendars"
        case .reminders: "Reminders"
        case .locationWhenInUse: "Location (When In Use)"
        case .locationAlways: "Location (Always)"
        case .notifications: "Notifications"
        case .speechRecognition: "Speech Recognition"
        case .motionAndFitness: "Motion & Fitness"
        case .bluetooth: "Bluetooth"
        case .mediaLibrary: "Media Library"
        case .tracking: "App Tracking"
        case .faceID: "Face ID"
        }
    }

    /// The Info.plist usage description key required for this permission.
    public var usageDescriptionKey: String {
        switch self {
        case .camera: "NSCameraUsageDescription"
        case .microphone: "NSMicrophoneUsageDescription"
        case .photoLibrary: "NSPhotoLibraryUsageDescription"
        case .photoLibraryAddOnly: "NSPhotoLibraryAddUsageDescription"
        case .contacts: "NSContactsUsageDescription"
        case .calendars: "NSCalendarsUsageDescription"
        case .reminders: "NSRemindersUsageDescription"
        case .locationWhenInUse: "NSLocationWhenInUseUsageDescription"
        case .locationAlways: "NSLocationAlwaysAndWhenInUseUsageDescription"
        case .notifications: "NSUserNotificationsUsageDescription"
        case .speechRecognition: "NSSpeechRecognitionUsageDescription"
        case .motionAndFitness: "NSMotionUsageDescription"
        case .bluetooth: "NSBluetoothAlwaysUsageDescription"
        case .mediaLibrary: "NSAppleMusicUsageDescription"
        case .tracking: "NSUserTrackingUsageDescription"
        case .faceID: "NSFaceIDUsageDescription"
        }
    }
}
