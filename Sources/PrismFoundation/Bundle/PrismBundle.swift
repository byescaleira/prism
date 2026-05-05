//
//  PrismBundle.swift
//  Prism
//
//  Created by Rafael Escaleira on 24/03/25.
//

import Foundation

/// Application bundle information.
public struct PrismBundle {
    private let infoDictionary: [String: Any]?
    private let operatingSystemVersionValue: OperatingSystemVersion

    /// The application's display name from the bundle's Info.plist.
    public var applicationName: String? {
        infoDictionary?["CFBundleName"] as? String
    }

    /// The application's bundle identifier (e.g., "com.example.app").
    public var applicationIdentifier: String? {
        infoDictionary?["CFBundleIdentifier"] as? String
    }

    /// The application's marketing version string (e.g., "1.2.0").
    public var applicationVersion: String? {
        infoDictionary?["CFBundleShortVersionString"] as? String
    }

    /// The application's build number string.
    public var applicationBuild: String? {
        infoDictionary?["CFBundleVersion"] as? String
    }

    /// The current operating system version.
    public var operatingSystemVersion: OperatingSystemVersion {
        operatingSystemVersionValue
    }

    /// Creates a bundle info wrapper from the given info dictionary and OS version.
    public init(
        infoDictionary: [String: Any]? = Bundle.main.infoDictionary,
        operatingSystemVersion: OperatingSystemVersion = ProcessInfo.processInfo.operatingSystemVersion
    ) {
        self.infoDictionary = infoDictionary
        self.operatingSystemVersionValue = operatingSystemVersion
    }
}
