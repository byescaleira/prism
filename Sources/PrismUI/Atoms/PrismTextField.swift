//
//  PrismTextField.swift
//  Prism
//
//  Created by Rafael Escaleira on 07/06/25.
//

import PrismFoundation
import SwiftUI

/// Styled text field for the PrismUI Design System.
///
/// `PrismTextField` is a text input component with:
/// - Floating label (automatic animation on focus/typing)
/// - Integrated validation with error display
/// - Optional icon
/// - Clear button (appears when typing)
/// - Full accessibility support (VoiceOver/TalkBack)
/// - UI testing (XCUITest) via stable testIDs
///
/// ## Basic Usage
/// ```swift
/// @State var email = ""
/// PrismTextField(
///     text: $email,
///     configuration: PrismDefaultTextFieldConfiguration.email
/// )
/// ```
///
/// ## With testID
/// ```swift
/// PrismTextField(
///     text: $email,
///     label: "Email",
///     testID: "email_field",
///     configuration: .email
/// )
/// ```
///
/// ## With Accessibility Builder
/// ```swift
/// PrismTextField(
///     text: $email,
///     configuration: .email,
///     accessibility: {
///         $0.label("Email")
///             .hint("Enter your corporate email")
///             .testID("email_field")
///     }
/// )
/// ```
///
/// ## Automatic Validation
/// The field validates automatically based on the configuration:
/// - `.email` - Validates email format
/// - `.phone` - Validates phone format
/// - `.cpf` - Validates Brazilian CPF
/// - etc.
///
/// - Note: Errors are automatically displayed below the field with an icon and message.
public struct PrismTextField: PrismView {
    @Environment(\.theme) var theme
    @Environment(\.platformContext) private var platformContext
    @FocusState var isFocused: Bool
    @Binding var text: String
    @State var error: PrismError?

    let configuration: PrismTextFieldConfiguration
    public var accessibility: PrismAccessibilityProperties?

    // MARK: - Initialization

    public init(
        text: Binding<String>,
        _ accessibility: PrismAccessibilityProperties? = nil,
        configuration: PrismTextFieldConfiguration
    ) {
        self._text = text
        self.accessibility = accessibility
        self.configuration = configuration
    }

    /// Quick initializer with accessibility convenience.
    public init(
        text: Binding<String>,
        configuration: PrismTextFieldConfiguration,
        accessibility: (PrismAccessibilityConfig) -> PrismAccessibilityConfig = { $0 }
    ) {
        self._text = text
        self.configuration = configuration
        self.accessibility = accessibility(PrismAccessibilityConfig()).build()
    }

    /// Initializer with static convenience.
    public init(
        text: Binding<String>,
        label: LocalizedStringKey,
        testID: String,
        configuration: PrismTextFieldConfiguration
    ) {
        self._text = text
        self.configuration = configuration
        self.accessibility = PrismAccessibility.textField(label, testID: testID)
    }

    var needFocus: Bool {
        isFocused || !text.isEmpty
    }

    var stateColor: PrismColor {
        error == nil && !text.isEmpty ? .success : error == nil ? .secondary : .error
    }

    /// Vertical offset for the floating label when focused.
    ///
    /// macOS text fields are shorter than iOS, so a smaller offset
    /// prevents the label from overlapping the field chrome.
    private var floatingLabelOffset: CGFloat {
        switch platformContext.platform {
        case .macOS:
            -32
        case .watchOS:
            -28
        default:
            -40
        }
    }

    public var body: some View {
        PrismVStack(alignment: .leading, spacing: .small) {
            contentTextField
                .overlay(alignment: .topLeading) { placeholderView }
                .contentShape(.rect)
                .onTapGesture {
                    isFocused = true
                }
                .prism(accessibility: accessibility ?? defaultAccessibility)

            errorView
        }
        .animation(theme.animation, value: isFocused)
        .animation(theme.animation, value: text.isEmpty)
        .animation(theme.animation, value: error?.localizedDescription)
        .onChange(of: text) { validate() }
    }

    // MARK: - Default Accessibility

    private var defaultAccessibility: PrismAccessibilityProperties {
        PrismAccessibility.textField(
            LocalizedStringKey(configuration.placeholder.value),
            testID: ""
        )
    }

    var contentTextField: some View {
        TextField(
            "",
            text: $text,
            axis: .vertical
        )
        .focused($isFocused)
        .autocorrectionDisabled()
        #if os(iOS)
            .keyboardType(configuration.contentType.rawValue)
            .textInputAutocapitalization(configuration.autocapitalizationType.rawValue)
        #endif
        #if os(macOS)
            // macOS adds its own bezel by default; `.plain` removes it so
            // `.prismBackgroundSecondary()` is the sole background provider.
            .textFieldStyle(.plain)
        #endif
        .submitLabel(configuration.submitLabel)
        .prism(alignment: .leading)
        .prismPadding(.horizontal, .extraLarge)
        .prismPadding(.horizontal, .small)
        .overlay(alignment: .leading) { iconView }
        .overlay(alignment: .trailing) { clearButton }
        .prismPadding()
        .prismBackgroundSecondary()
        .prism(clip: .rounded(radius: theme.radius.large))
    }

    func validate() {
        do {
            try configuration.validate(text: text)
            self.error = nil
        } catch let error as PrismError {
            self.error = error
        } catch {

        }
    }

    var clearButton: some View {
        Button {
            text = ""
            isFocused = true
        } label: {
            PrismSymbol(
                "xmark.circle.fill",
                mode: .hierarchical
            )
            .prism(font: .body)
            .prism(color: .textSecondary)
            // Opacity + scale replaces the hardcoded 50pt offset so the
            // transition works identically across macOS and iOS.
            .opacity(needFocus && !text.isEmpty ? 0.5 : 0)
            .scaleEffect(needFocus && !text.isEmpty ? 0.8 : 0.4)
        }
        .disabled(text.isEmpty)
        .accessibilityHidden(text.isEmpty)
    }

    @ViewBuilder
    var iconView: some View {
        if let icon = configuration.icon {
            PrismSymbol(icon)
                .prism(font: .footnote)
                .prism(color: stateColor)
                .prismGlow(for: error == nil ? nil : theme.color.error)
                // Opacity + scale replaces the hardcoded -50pt offset for
                // reliable cross-platform icon reveal.
                .opacity(needFocus ? 1 : 0)
                .scaleEffect(needFocus ? 1 : 0.4)
        }
    }

    @ViewBuilder
    var placeholderView: some View {
        PrismText(configuration.placeholder)
            .prism(font: needFocus ? .footnote : .body)
            .prism(color: .disabled)
            .lineLimit(1)
            .prismPadding()
            .offset(y: needFocus ? floatingLabelOffset : .zero)
    }

    @ViewBuilder
    var errorView: some View {
        if error != nil {
            PrismVStack(alignment: .leading) {
                failureReasonView
                recoverySuggestionView
            }
            .prism(width: .max)
            .transition(.blurReplace)
        }
    }

    @ViewBuilder
    var failureReasonView: some View {
        if let failureReason = error?.failureReason {
            PrismHStack(spacing: .small) {
                PrismSymbol(
                    "xmark.circle.fill",
                    mode: .hierarchical
                )
                .prism(font: .footnote)
                .prism(color: .error)

                PrismText(failureReason)
                    .prism(font: needFocus ? .footnote : .body)
                    .prism(color: .disabled)
                    .prism(alignment: .leading)
            }
        }
    }

    @ViewBuilder
    var recoverySuggestionView: some View {
        if let recoverySuggestion = error?.recoverySuggestion {
            PrismHStack(spacing: .small) {
                PrismSymbol(
                    "lightbulb.max.fill",
                    mode: .hierarchical
                )
                .prism(font: .footnote)
                .prism(color: .success)

                PrismText(recoverySuggestion)
                    .prism(font: needFocus ? .footnote : .body)
                    .prism(color: .disabled)
                    .prism(alignment: .leading)
            }
        }
    }

    public static func mocked() -> some View {
        PrismTextField(
            text: .constant(""),
            configuration: PrismDefaultTextFieldConfiguration.email,
            accessibility: { $0 }
        )
    }
}

#Preview {
    @Previewable @State var text: String = ""
    PrismTextField(
        text: $text,
        configuration: PrismDefaultTextFieldConfiguration.email,
        accessibility: { $0 }
    )
    .prismPadding()
}
