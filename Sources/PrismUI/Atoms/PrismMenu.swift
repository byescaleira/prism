//
//  PrismMenu.swift
//  Prism
//
//  Created by Rafael Escaleira on 27/04/26.
//

import SwiftUI

/// Context menu / dropdown for the PrismUI Design System.
///
/// `PrismMenu` wraps SwiftUI's `Menu` with design-system styling and accessibility.
/// On macOS it renders as a native dropdown; on iOS it presents a context menu sheet.
///
/// ## Basic Usage
/// ```swift
/// PrismMenu("Options") {
///     Button("Edit") { }
///     Button("Delete", role: .destructive) { }
/// }
/// ```
///
/// ## With Symbol
/// ```swift
/// PrismMenu(symbol: "ellipsis.circle") {
///     Button("Share") { }
///     Button("Archive") { }
/// }
/// ```
///
/// ## With Picker
/// ```swift
/// PrismMenu("Sort by") {
///     Picker("Sort", selection: $sort) {
///         Text("Name").tag(Sort.name)
///         Text("Date").tag(Sort.date)
///     }
/// }
/// ```
///
/// - Note: Uses the theme's primary color for the menu label.
public struct PrismMenu<MenuContent: View>: PrismView {
    @Environment(\.theme) private var theme

    private let label: AnyView
    private let content: () -> MenuContent
    public var accessibility: PrismAccessibilityProperties?

    /// Creates a menu with a text label.
    ///
    /// - Parameters:
    ///   - title: The menu button title.
    ///   - content: The menu items presented on activation.
    public init(
        _ title: String,
        _ accessibility: PrismAccessibilityProperties? = nil,
        @ViewBuilder content: @escaping () -> MenuContent
    ) {
        self.label = AnyView(
            PrismText(title)
                .prism(font: .body, weight: .medium)
        )
        self.accessibility = accessibility
        self.content = content
    }

    /// Creates a menu with an SF Symbol label.
    ///
    /// - Parameters:
    ///   - symbol: The SF Symbol name for the menu button.
    ///   - content: The menu items presented on activation.
    public init(
        symbol: String,
        _ accessibility: PrismAccessibilityProperties? = nil,
        @ViewBuilder content: @escaping () -> MenuContent
    ) {
        self.label = AnyView(
            PrismSymbol(symbol)
                .prism(font: .body)
        )
        self.accessibility = accessibility
        self.content = content
    }

    /// Creates a menu with a custom label view.
    ///
    /// - Parameters:
    ///   - content: The menu items presented on activation.
    ///   - label: A custom view used as the menu button.
    public init(
        _ accessibility: PrismAccessibilityProperties? = nil,
        @ViewBuilder content: @escaping () -> MenuContent,
        @ViewBuilder label: () -> some View
    ) {
        self.label = AnyView(label())
        self.accessibility = accessibility
        self.content = content
    }

    public var body: some View {
        Menu {
            content()
        } label: {
            label
                .prism(color: .primary)
        }
        .prism(accessibility: accessibility ?? defaultAccessibility)
    }

    private var defaultAccessibility: PrismAccessibilityProperties {
        PrismAccessibility.custom(label: "Menu", testID: "")
    }

    public enum MockView: View {
        case empty
        public var body: some View {
            PrismMenu<TupleView<(Button<Text>, Button<Text>)>>("Options") {
                Button("Edit") {}
                Button("Delete", role: .destructive) {}
            }
        }
    }

    public static func mocked() -> MockView { .empty }
}

#Preview {
    PrismMenu("Options") {
        Button("Edit") {}
        Button("Delete", role: .destructive) {}
    }
    .prismPadding()
}
