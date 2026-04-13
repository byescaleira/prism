//
//  RyzeThemeProtocol.swift
//  Ryze
//
//  Created by Rafael Escaleira on 19/04/25.
//

import RyzeFoundation
import SwiftUI

public protocol RyzeThemeProtocol: Sendable {
    // MARK: - Core Properties

    var color: RyzeColorProtocol { get }
    var spacing: RyzeSpacingProtocol { get }
    var radius: RyzeRadiusProtocol { get }
    var size: RyzeSizeProtocol { get }
    var locale: RyzeLocale { get }

    // MARK: - Motion & Feedback

    var animation: Animation? { get }
    var feedback: SensoryFeedback { get }

    // MARK: - Appearance

    var colorScheme: ColorScheme? { get }

    // MARK: - Design Tokens

    var tokens: RyzeDesignTokens { get }
}
