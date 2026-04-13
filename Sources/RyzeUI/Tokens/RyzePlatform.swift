//
//  RyzePlatform.swift
//  Ryze
//
//  Created by Rafael Escaleira on 09/04/26.
//

import SwiftUI

public enum RyzePlatform: String, CaseIterable, Sendable {
    case iOS
    case macOS
    case tvOS
    case watchOS
    case visionOS

    public static var current: Self {
        #if os(visionOS)
            .visionOS
        #elseif os(tvOS)
            .tvOS
        #elseif os(watchOS)
            .watchOS
        #elseif os(macOS)
            .macOS
        #else
            .iOS
        #endif
    }
}

public enum RyzeNavigationModel: String, Sendable {
    case stack
    case tabBar
    case splitView
}

public struct RyzeContentMargins: Sendable {
    public let horizontal: CGFloat
    public let vertical: CGFloat

    public init(
        horizontal: CGFloat,
        vertical: CGFloat
    ) {
        self.horizontal = horizontal
        self.vertical = vertical
    }
}

public struct RyzePlatformContext: Sendable {
    public let platform: RyzePlatform
    public let layoutTier: RyzeLayoutTier
    public let navigationModel: RyzeNavigationModel
    public let contentMargins: RyzeContentMargins
    public let maxReadableWidth: CGFloat?
    public let prefersCenteredCanvas: Bool
    public let prefersEdgeToEdgeContent: Bool
    public let prefersFocusNavigation: Bool
    public let controlSize: ControlSize

    public init(
        platform: RyzePlatform,
        layoutTier: RyzeLayoutTier,
        navigationModel: RyzeNavigationModel,
        contentMargins: RyzeContentMargins,
        maxReadableWidth: CGFloat?,
        prefersCenteredCanvas: Bool,
        prefersEdgeToEdgeContent: Bool,
        prefersFocusNavigation: Bool,
        controlSize: ControlSize
    ) {
        self.platform = platform
        self.layoutTier = layoutTier
        self.navigationModel = navigationModel
        self.contentMargins = contentMargins
        self.maxReadableWidth = maxReadableWidth
        self.prefersCenteredCanvas = prefersCenteredCanvas
        self.prefersEdgeToEdgeContent = prefersEdgeToEdgeContent
        self.prefersFocusNavigation = prefersFocusNavigation
        self.controlSize = controlSize
    }

    public static let `default` = resolve(
        platform: .current,
        layoutTier: .compact
    )

    public static func resolve(
        platform: RyzePlatform,
        layoutTier: RyzeLayoutTier
    ) -> Self {
        switch platform {
        case .iOS:
            Self(
                platform: platform,
                layoutTier: layoutTier,
                navigationModel: layoutTier == .compact ? .tabBar : .splitView,
                contentMargins: RyzeContentMargins(
                    horizontal: layoutTier.horizontalPadding,
                    vertical: max(16, layoutTier.verticalPadding)
                ),
                maxReadableWidth: layoutTier == .compact ? nil : 760,
                prefersCenteredCanvas: false,
                prefersEdgeToEdgeContent: false,
                prefersFocusNavigation: false,
                controlSize: layoutTier.controlSize
            )

        case .macOS:
            Self(
                platform: platform,
                layoutTier: layoutTier,
                navigationModel: .splitView,
                contentMargins: RyzeContentMargins(
                    horizontal: max(24, layoutTier.horizontalPadding),
                    vertical: 20
                ),
                maxReadableWidth: 820,
                prefersCenteredCanvas: false,
                prefersEdgeToEdgeContent: false,
                prefersFocusNavigation: false,
                controlSize: .large
            )

        case .tvOS:
            Self(
                platform: platform,
                layoutTier: layoutTier,
                navigationModel: .stack,
                contentMargins: RyzeContentMargins(
                    horizontal: 80,
                    vertical: 60
                ),
                maxReadableWidth: nil,
                prefersCenteredCanvas: false,
                prefersEdgeToEdgeContent: false,
                prefersFocusNavigation: true,
                controlSize: .extraLarge
            )

        case .watchOS:
            Self(
                platform: platform,
                layoutTier: .compact,
                navigationModel: .stack,
                contentMargins: RyzeContentMargins(
                    horizontal: 8,
                    vertical: 8
                ),
                maxReadableWidth: nil,
                prefersCenteredCanvas: false,
                prefersEdgeToEdgeContent: true,
                prefersFocusNavigation: false,
                controlSize: .small
            )

        case .visionOS:
            Self(
                platform: platform,
                layoutTier: layoutTier,
                navigationModel: .splitView,
                contentMargins: RyzeContentMargins(
                    horizontal: max(28, layoutTier.horizontalPadding),
                    vertical: max(24, layoutTier.verticalPadding)
                ),
                maxReadableWidth: 900,
                prefersCenteredCanvas: true,
                prefersEdgeToEdgeContent: false,
                prefersFocusNavigation: false,
                controlSize: .large
            )
        }
    }
}
