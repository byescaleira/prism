//
//  PrismUITests.swift
//  PrismUITests
//
//  Created by Rafael Escaleira on 09/04/26.
//

import SwiftUI
import XCTest

@testable import PrismUI

@MainActor
final class PrismUITests: XCTestCase {
    func testThemeCopyingPreservesExistingValues() {
        let base = PrismTheme.default
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
        let theme = PrismTheme.expanded.with(colorScheme: .dark)
        let erased = theme.eraseToAnyTheme()

        XCTAssertEqual(erased.tokens, .expanded)
        XCTAssertEqual(erased.colorScheme, .dark)
    }

    func testDesignTokensResolveAdaptiveLayoutTiers() {
        let tokens = PrismDesignTokens.default

        XCTAssertEqual(tokens.layoutTier(for: 320), .compact)
        XCTAssertEqual(tokens.layoutTier(for: 834), .regular)
        XCTAssertEqual(tokens.layoutTier(for: 1600), .expansive)
    }

    func testSemanticStylesResolveAgainstTheme() {
        let theme = PrismTheme.default

        XCTAssertEqual(PrismSpacing.medium.rawValue(for: theme.spacing), theme.spacing.medium)
        XCTAssertEqual(PrismSpacing.negative(.small).rawValue(for: theme.spacing), -theme.spacing.small)
        XCTAssertEqual(PrismRadius.capsule.rawValue(for: theme.radius), theme.radius.circle)
        XCTAssertEqual(PrismSize.medium.rawValue(for: theme.size), theme.size.medium)
        XCTAssertNil(PrismSize.none.rawValue(for: theme.size))
    }

    func testLayoutTierProvidesProgressiveMetrics() {
        XCTAssertTrue(PrismLayoutTier.compact.horizontalPadding < PrismLayoutTier.regular.horizontalPadding)
        XCTAssertTrue(PrismLayoutTier.regular.horizontalPadding < PrismLayoutTier.expansive.horizontalPadding)
        XCTAssertTrue(PrismLayoutTier.compact.verticalPadding < PrismLayoutTier.expansive.verticalPadding)
    }

    func testPlatformContextResolvesPerPlatformExpectations() {
        let ios = PrismPlatformContext.resolve(
            platform: .iOS,
            layoutTier: .compact
        )
        let macOS = PrismPlatformContext.resolve(
            platform: .macOS,
            layoutTier: .expansive
        )
        let tvOS = PrismPlatformContext.resolve(
            platform: .tvOS,
            layoutTier: .regular
        )
        let watchOS = PrismPlatformContext.resolve(
            platform: .watchOS,
            layoutTier: .compact
        )
        let visionOS = PrismPlatformContext.resolve(
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
        let compactPhone = PrismPlatformContext.resolve(
            platform: .iOS,
            layoutTier: .compact
        )
        let regularPhone = PrismPlatformContext.resolve(
            platform: .iOS,
            layoutTier: .regular
        )
        let desktop = PrismPlatformContext.resolve(
            platform: .macOS,
            layoutTier: .expansive
        )

        XCTAssertEqual(
            PrismAdaptiveStack<Text>.resolvedAxis(
                style: .actions,
                platformContext: compactPhone
            ),
            .vertical
        )
        XCTAssertEqual(
            PrismAdaptiveStack<Text>.resolvedAxis(
                style: .actions,
                platformContext: regularPhone
            ),
            .horizontal
        )
        XCTAssertEqual(
            PrismAdaptiveStack<Text>.resolvedAxis(
                style: .content,
                platformContext: desktop
            ),
            .horizontal
        )
    }

    func testScaffoldHeaderLayoutFollowsPlatformModel() {
        let compactPhone = PrismPlatformContext.resolve(
            platform: .iOS,
            layoutTier: .compact
        )
        let desktop = PrismPlatformContext.resolve(
            platform: .macOS,
            layoutTier: .regular
        )

        XCTAssertEqual(
            PrismScaffold<Text, EmptyView>.headerLayoutStyle(for: compactPhone),
            .content
        )
        XCTAssertEqual(
            PrismScaffold<Text, EmptyView>.headerLayoutStyle(for: desktop),
            .actions
        )
    }

    func testTabViewPlatformChromeRulesStayPredictable() {
        XCTAssertTrue(PrismTabView<Int>.showsBottomAccessory(in: .iOS))
        XCTAssertTrue(PrismTabView<Int>.showsBottomAccessory(in: .macOS))
        XCTAssertFalse(PrismTabView<Int>.showsBottomAccessory(in: .watchOS))
        XCTAssertTrue(PrismTabView<Int>.minimizesChromeOnScroll(in: .iOS))
        XCTAssertFalse(PrismTabView<Int>.minimizesChromeOnScroll(in: .visionOS))
    }

    func testAdaptiveScaffoldBuildsWithoutHostApplication() {
        let view = PrismScaffold(
            String("Painel"),
            subtitle: "Resumo"
        ) {
            Text("Conteúdo")
        }

        _ = view.body
    }
}
