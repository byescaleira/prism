//
//  PrismBundle.swift
//  Prism
//
//  Created by Rafael Escaleira on 24/03/25.
//

import Foundation

public struct PrismBundle {
    private let infoDictionary: [String: Any]?
    private let operatingSystemVersionValue: OperatingSystemVersion

    public var applicationName: String? {
        infoDictionary?["CFBundleName"] as? String
    }

    public var applicationIdentifier: String? {
        infoDictionary?["CFBundleIdentifier"] as? String
    }

    public var applicationVersion: String? {
        infoDictionary?["CFBundleShortVersionString"] as? String
    }

    public var applicationBuild: String? {
        infoDictionary?["CFBundleVersion"] as? String
    }

    public var operatingSystemVersion: OperatingSystemVersion {
        operatingSystemVersionValue
    }

    public init(
        infoDictionary: [String: Any]? = Bundle.main.infoDictionary,
        operatingSystemVersion: OperatingSystemVersion = ProcessInfo.processInfo.operatingSystemVersion
    ) {
        self.infoDictionary = infoDictionary
        self.operatingSystemVersionValue = operatingSystemVersion
    }
}
