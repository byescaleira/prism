//
//  PrismThemeProtocol.swift
//  Prism
//
//  Created by Rafael Escaleira on 19/04/25.
//

import PrismFoundation
import SwiftUI

public protocol PrismThemeProtocol: Sendable {
    // MARK: - Core Properties

    var color: PrismColorProtocol { get }
    var spacing: PrismSpacingProtocol { get }
    var radius: PrismRadiusProtocol { get }
    var size: PrismSizeProtocol { get }
    var locale: PrismLocale { get }

    // MARK: - Motion & Feedback

    var animation: Animation? { get }
    var feedback: SensoryFeedback { get }

    // MARK: - Appearance

    var colorScheme: ColorScheme? { get }

    // MARK: - Design Tokens

    var tokens: PrismDesignTokens { get }
}
