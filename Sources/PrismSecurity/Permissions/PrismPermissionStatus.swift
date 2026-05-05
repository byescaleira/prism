import Foundation

/// Authorization status for a system permission.
public enum PrismPermissionStatus: String, Sendable, Hashable, CaseIterable {
    case notDetermined
    case authorized
    case denied
    case restricted
    case limited
    case provisional

    /// Whether access is currently granted.
    public var isGranted: Bool {
        switch self {
        case .authorized, .limited, .provisional: true
        case .notDetermined, .denied, .restricted: false
        }
    }

    /// Whether the user can be prompted for permission.
    public var canRequest: Bool {
        self == .notDetermined
    }
}
