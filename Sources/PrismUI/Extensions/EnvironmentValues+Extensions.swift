//
//  EnvironmentValues+Extensions.swift
//  Prism
//
//  Created by Rafael Escaleira on 19/04/25.
//

import PrismFoundation
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

    @Entry public var theme: PrismTheme = .default
    @Entry public var designTokens: PrismDesignTokens = .default

    // MARK: - Layout

    @Entry public var platform: PrismPlatform = .current
    @Entry public var platformContext: PrismPlatformContext = .default
    @Entry public var layoutTier: PrismLayoutTier = .compact
    @Entry public var isPinnedToTop: Bool = false
    @Entry public var isPinnedToBottom: Bool = false
}
