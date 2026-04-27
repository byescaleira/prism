//
//  PrismAlert.swift
//  Prism
//
//  Created by Rafael Escaleira on 27/04/26.
//

import PrismFoundation
import SwiftUI

/// Unified alert and confirmation dialog for the PrismUI Design System.
///
/// `PrismAlert` adapts its presentation style per platform:
/// - **iOS / watchOS**: Native alert or confirmation dialog depending on style.
/// - **macOS**: Native `NSAlert`-style dialog with proper button ordering.
/// - **tvOS**: Alert with focus-based button selection.
///
/// ## Basic Alert
/// ```swift
/// @State var showAlert = false
///
/// PrismAlert(
///     "Delete Item",
///     message: "This action cannot be undone.",
///     isPresented: $showAlert
/// ) {
///     Button("Cancel", role: .cancel) { }
///     Button("Delete", role: .destructive) { deleteItem() }
/// }
/// ```
///
/// ## Confirmation Dialog
/// ```swift
/// PrismAlert(
///     "Share",
///     message: "Choose how to share this item.",
///     style: .confirmationDialog,
///     isPresented: $showShare
/// ) {
///     Button("Copy Link") { }
///     Button("Share via Email") { }
///     Button("Cancel", role: .cancel) { }
/// }
/// ```
///
/// - Note: On iOS, `.confirmationDialog` presents as an action sheet.
///   On macOS, both styles present as a centered alert dialog.
public struct PrismAlert<Actions: View, Content: View>: View {
    private let title: String
    private let message: String?
    private let style: Style
    @Binding private var isPresented: Bool
    private let actions: () -> Actions
    private let content: () -> Content

    /// Presentation style for the alert.
    public enum Style: Sendable {
        /// Standard centered alert dialog.
        case alert
        /// Action sheet / confirmation dialog.
        case confirmationDialog
    }

    /// Creates an alert that wraps existing content.
    ///
    /// - Parameters:
    ///   - title: The alert title.
    ///   - message: An optional message displayed below the title.
    ///   - style: The presentation style. Defaults to `.alert`.
    ///   - isPresented: A binding that controls the alert's visibility.
    ///   - actions: The alert's action buttons.
    ///   - content: The view to which the alert is attached.
    public init(
        _ title: String,
        message: String? = nil,
        style: Style = .alert,
        isPresented: Binding<Bool>,
        @ViewBuilder actions: @escaping () -> Actions,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.message = message
        self.style = style
        self._isPresented = isPresented
        self.actions = actions
        self.content = content
    }

    /// Creates an alert without wrapping content, using `EmptyView` as the body.
    ///
    /// Attach this to an existing view hierarchy with `.overlay`.
    ///
    /// - Parameters:
    ///   - title: The alert title.
    ///   - message: An optional message displayed below the title.
    ///   - style: The presentation style. Defaults to `.alert`.
    ///   - isPresented: A binding that controls the alert's visibility.
    ///   - actions: The alert's action buttons.
    public init(
        _ title: String,
        message: String? = nil,
        style: Style = .alert,
        isPresented: Binding<Bool>,
        @ViewBuilder actions: @escaping () -> Actions
    ) where Content == EmptyView {
        self.title = title
        self.message = message
        self.style = style
        self._isPresented = isPresented
        self.actions = actions
        self.content = { EmptyView() }
    }

    public var body: some View {
        switch style {
        case .alert:
            content()
                .alert(title, isPresented: $isPresented) {
                    actions()
                } message: {
                    messageView
                }

        case .confirmationDialog:
            content()
                .confirmationDialog(
                    title,
                    isPresented: $isPresented,
                    titleVisibility: .visible
                ) {
                    actions()
                } message: {
                    messageView
                }
        }
    }

    @ViewBuilder
    private var messageView: some View {
        if let message {
            Text(message)
        }
    }
}

#Preview("Alert") {
    @Previewable @State var show = true
    PrismAlert(
        "Delete Item",
        message: "This action cannot be undone.",
        isPresented: $show
    ) {
        Button("Cancel", role: .cancel) {}
        Button("Delete", role: .destructive) {}
    } content: {
        PrismPrimaryButton("Show Alert") { show = true }
            .prismPadding()
    }
}

#Preview("Confirmation") {
    @Previewable @State var show = true
    PrismAlert(
        "Share",
        message: "Choose how to share.",
        style: .confirmationDialog,
        isPresented: $show
    ) {
        Button("Copy Link") {}
        Button("Email") {}
        Button("Cancel", role: .cancel) {}
    } content: {
        PrismSecondaryButton("Share") { show = true }
            .prismPadding()
    }
}
