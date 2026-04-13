//
//  EnvironmentValues+Extensions.swift
//  Ryze
//
//  Created by Rafael Escaleira on 19/04/25.
//

import RyzeFoundation
import SwiftUI

extension EnvironmentValues {

    // MARK: - State

    @Entry public var isLoading: Bool = false
    @Entry public var isDisabled: Bool = false

    // MARK: - Screen

    @Entry public var screenSize: CGSize = .zero
    @Entry public var scrollPosition: CGPoint = .zero
    @Entry public var isLargeScreen: Bool = false

    // MARK: - Theme

    @Entry public var theme: RyzeTheme = .default
    @Entry public var designTokens: RyzeDesignTokens = .default

    // MARK: - Layout

    @Entry public var platform: RyzePlatform = .current
    @Entry public var platformContext: RyzePlatformContext = .default
    @Entry public var layoutTier: RyzeLayoutTier = .compact
    @Entry public var isPinnedToTop: Bool = false
    @Entry public var isPinnedToBottom: Bool = false
}
