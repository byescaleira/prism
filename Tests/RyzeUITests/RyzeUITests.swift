//
//  RyzeUITests.swift
//  RyzeUITests
//
//  Created by Rafael Escaleira on 09/04/26.
//

import SwiftUI
import XCTest

@testable import RyzeUI

@MainActor
final class RyzeUITests: XCTestCase {
    func testThemeCopyingPreservesExistingValues() {
        let base = RyzeTheme.default
        let compact = base.with(tokens: .compact)
        let dark = compact.with(colorScheme: .dark)
        let animated = dark.with(animation: .linear(duration: 0.15))

        XCTAssertEqual(compact.tokens, .compact)
        XCTAssertNil(base.colorScheme)
        XCTAssertEqual(dark.tokens, .compact)
        XCTAssertEqual(dark.colorScheme, .dark)
        XCTAssertEqual(animated.colorScheme, .dark)
        XCTAssertNotNil(animated.animation)
    }

    func testThemeErasurePreservesTokens() {
        let theme = RyzeTheme.expanded.with(colorScheme: .dark)
        let erased = theme.eraseToAnyTheme()

        XCTAssertEqual(erased.tokens, .expanded)
        XCTAssertEqual(erased.colorScheme, .dark)
    }

    func testDesignTokensResolveAdaptiveLayoutTiers() {
        let tokens = RyzeDesignTokens.default

        XCTAssertEqual(tokens.layoutTier(for: 320), .compact)
        XCTAssertEqual(tokens.layoutTier(for: 834), .regular)
        XCTAssertEqual(tokens.layoutTier(for: 1600), .expansive)
    }

    func testSemanticStylesResolveAgainstTheme() {
        let theme = RyzeTheme.default

        XCTAssertEqual(RyzeSpacing.medium.rawValue(for: theme.spacing), theme.spacing.medium)
        XCTAssertEqual(RyzeSpacing.negative(.small).rawValue(for: theme.spacing), -theme.spacing.small)
        XCTAssertEqual(RyzeRadius.capsule.rawValue(for: theme.radius), theme.radius.circle)
        XCTAssertEqual(RyzeSize.medium.rawValue(for: theme.size), theme.size.medium)
        XCTAssertNil(RyzeSize.none.rawValue(for: theme.size))
    }

    func testLayoutTierProvidesProgressiveMetrics() {
        XCTAssertTrue(RyzeLayoutTier.compact.horizontalPadding < RyzeLayoutTier.regular.horizontalPadding)
        XCTAssertTrue(RyzeLayoutTier.regular.horizontalPadding < RyzeLayoutTier.expansive.horizontalPadding)
        XCTAssertTrue(RyzeLayoutTier.compact.verticalPadding < RyzeLayoutTier.expansive.verticalPadding)
    }

    func testPlatformContextResolvesPerPlatformExpectations() {
        let ios = RyzePlatformContext.resolve(
            platform: .iOS,
            layoutTier: .compact
        )
        let macOS = RyzePlatformContext.resolve(
            platform: .macOS,
            layoutTier: .expansive
        )
        let tvOS = RyzePlatformContext.resolve(
            platform: .tvOS,
            layoutTier: .regular
        )
        let watchOS = RyzePlatformContext.resolve(
            platform: .watchOS,
            layoutTier: .compact
        )
        let visionOS = RyzePlatformContext.resolve(
            platform: .visionOS,
            layoutTier: .regular
        )

        XCTAssertEqual(ios.navigationModel, .tabBar)
        XCTAssertEqual(macOS.navigationModel, .splitView)
        XCTAssertEqual(tvOS.controlSize, .extraLarge)
        XCTAssertTrue(tvOS.prefersFocusNavigation)
        XCTAssertTrue(watchOS.prefersEdgeToEdgeContent)
        XCTAssertTrue(visionOS.prefersCenteredCanvas)
        XCTAssertEqual(visionOS.navigationModel, .splitView)
        XCTAssertEqual(watchOS.layoutTier, .compact)
    }

    func testAdaptiveStackResolvesAxisPerPlatformContext() {
        let compactPhone = RyzePlatformContext.resolve(
            platform: .iOS,
            layoutTier: .compact
        )
        let regularPhone = RyzePlatformContext.resolve(
            platform: .iOS,
            layoutTier: .regular
        )
        let desktop = RyzePlatformContext.resolve(
            platform: .macOS,
            layoutTier: .expansive
        )

        XCTAssertEqual(
            RyzeAdaptiveStack<Text>.resolvedAxis(
                style: .actions,
                platformContext: compactPhone
            ),
            .vertical
        )
        XCTAssertEqual(
            RyzeAdaptiveStack<Text>.resolvedAxis(
                style: .actions,
                platformContext: regularPhone
            ),
            .horizontal
        )
        XCTAssertEqual(
            RyzeAdaptiveStack<Text>.resolvedAxis(
                style: .content,
                platformContext: desktop
            ),
            .horizontal
        )
    }

    func testScaffoldHeaderLayoutFollowsPlatformModel() {
        let compactPhone = RyzePlatformContext.resolve(
            platform: .iOS,
            layoutTier: .compact
        )
        let desktop = RyzePlatformContext.resolve(
            platform: .macOS,
            layoutTier: .regular
        )

        XCTAssertEqual(
            RyzeScaffold<Text, EmptyView>.headerLayoutStyle(for: compactPhone),
            .content
        )
        XCTAssertEqual(
            RyzeScaffold<Text, EmptyView>.headerLayoutStyle(for: desktop),
            .actions
        )
    }

    func testTabViewPlatformChromeRulesStayPredictable() {
        XCTAssertTrue(RyzeTabView<Int>.showsBottomAccessory(in: .iOS))
        XCTAssertTrue(RyzeTabView<Int>.showsBottomAccessory(in: .macOS))
        XCTAssertFalse(RyzeTabView<Int>.showsBottomAccessory(in: .watchOS))
        XCTAssertTrue(RyzeTabView<Int>.minimizesChromeOnScroll(in: .iOS))
        XCTAssertFalse(RyzeTabView<Int>.minimizesChromeOnScroll(in: .visionOS))
    }

    func testAdaptiveScaffoldBuildsWithoutHostApplication() {
        let view = RyzeScaffold(
            String("Painel"),
            subtitle: "Resumo"
        ) {
            Text("Conteúdo")
        }

        _ = view.body
    }
}
