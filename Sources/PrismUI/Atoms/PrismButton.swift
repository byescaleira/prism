//
//  PrismButton.swift
//  Prism
//
//  Created by Rafael Escaleira on 18/06/25.
//

import PrismFoundation
import SwiftUI

/// A styled button for the PrismUI Design System.
///
/// `PrismButton` is the base component for interactive buttons, with native support for
/// accessibility (VoiceOver/TalkBack) and UI testing (XCUITest) via stable testIDs.
///
/// ## Basic Usage
/// ```swift
/// PrismButton("Sign In", testID: "login_button") {
///     // login action
/// }
/// ```
///
/// ## With Accessibility Builder
/// ```swift
/// PrismButton(
///     accessibility: {
///         $0.label("Sign In")
///             .hint("Tap to sign in")
///             .testID("login_button")
///     }
/// ) {
///     PrismText("Sign In")
/// }
/// ```
///
/// - Important: For UI testing, always provide a unique and stable `testID`.
/// - Note: The button provides haptic feedback on iOS.
public struct PrismButton: PrismView {
    @Environment(\.analyticsProvider) private var analyticsProvider

    let role: ButtonRole?
    let action: () async -> Void
    let label: any View
    public var accessibility: PrismAccessibilityProperties?

    // MARK: - Initialization

    /// Default initializer with explicit accessibility properties.
    /// - Parameters:
    ///   - accessibility: Optional accessibility properties.
    ///   - role: Button role (`.none`, `.cancel`, `.destructive`).
    ///   - action: Async action performed on tap.
    ///   - label: Visual content of the button.
    public init(
        accessibility: PrismAccessibilityProperties? = nil,
        role: ButtonRole? = .none,
        action: @escaping () async -> Void,
        @ViewBuilder label: () -> some View
    ) {
        self.accessibility = accessibility
        self.role = role
        self.action = action
        self.label = label()
    }

    /// Initializer with accessibility properties as the first parameter.
    /// - Parameters:
    ///   - accessibility: Optional accessibility properties.
    ///   - role: Button role (`.none`, `.cancel`, `.destructive`).
    ///   - action: Async action performed on tap.
    ///   - label: Visual content of the button.
    public init(
        _ accessibility: PrismAccessibilityProperties? = nil,
        role: ButtonRole? = .none,
        action: @escaping () async -> Void,
        @ViewBuilder label: () -> some View
    ) {
        self.accessibility = accessibility
        self.role = role
        self.action = action
        self.label = label()
    }

    /// Quick initializer with accessibility builder.
    /// - Parameters:
    ///   - role: Button role (`.none`, `.cancel`, `.destructive`).
    ///   - action: Async action performed on tap.
    ///   - label: Visual content of the button.
    ///   - accessibility: Closure that configures `PrismAccessibilityConfig`.
    public init(
        role: ButtonRole? = .none,
        action: @escaping () async -> Void,
        @ViewBuilder label: () -> some View,
        accessibility: (PrismAccessibilityConfig) -> PrismAccessibilityConfig = { $0 }
    ) {
        self.accessibility = accessibility(PrismAccessibilityConfig()).build()
        self.role = role
        self.action = action
        self.label = label()
    }

    /// Quick initializer with static accessibility convenience.
    /// - Parameters:
    ///   - label: Button text (LocalizedStringKey).
    ///   - testID: Unique identifier for UI testing (non-localizable).
    ///   - role: Button role (`.none`, `.cancel`, `.destructive`).
    ///   - hint: Additional VoiceOver hint (optional).
    ///   - action: Async action performed on tap.
    public init(
        _ label: LocalizedStringKey,
        testID: String,
        role: ButtonRole? = .none,
        hint: LocalizedStringKey? = nil,
        action: @escaping () async -> Void
    ) {
        self.accessibility = PrismAccessibility.button(label, testID: testID, hint: hint)
        self.role = role
        self.action = action
        self.label = PrismText(label)
    }

    // MARK: - Body

    public var body: some View {
        Button(role: role) {
            #if os(iOS)
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            #endif
            trackTap()
            Task { await action() }
        } label: {
            AnyView(label)
        }
        .prism(accessibility: accessibility ?? defaultAccessibility)
    }

    private func trackTap() {
        guard let analyticsProvider else { return }
        let props = accessibility ?? defaultAccessibility
        analyticsProvider.track(
            .buttonTap(
                label: props.testID,
                testID: props.testID
            )
        )
    }

    // MARK: - Default Accessibility

    private var defaultAccessibility: PrismAccessibilityProperties {
        PrismAccessibility.button(
            "Button",
            testID: ""
        )
    }

    // MARK: - Mock

    public static func mocked() -> some View {
        PrismButton(
            accessibility: nil,
            role: .none,
            action: {},
            label: {
                PrismText.mocked()
            }
        )
    }
}

// MARK: - Previews

#Preview("Default") {
    PrismButton.mocked()
        .prismPadding()
}

#Preview("With Accessibility") {
    PrismButton(
        "Entrar",
        testID: "login_button",
        hint: "Toque para fazer login"
    ) {
        // action
    }
    .prismPadding()
}
