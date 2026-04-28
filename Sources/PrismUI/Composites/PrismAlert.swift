import SwiftUI

/// Themed alert with title, message, and configurable actions.
public struct PrismAlert: ViewModifier {
    @Binding private var isPresented: Bool
    private let title: LocalizedStringKey
    private let message: LocalizedStringKey?
    private let actions: [Action]

    public init(
        isPresented: Binding<Bool>,
        title: LocalizedStringKey,
        message: LocalizedStringKey? = nil,
        actions: [Action]
    ) {
        self._isPresented = isPresented
        self.title = title
        self.message = message
        self.actions = actions
    }

    public func body(content: Content) -> some View {
        content.alert(title, isPresented: $isPresented) {
            ForEach(Array(actions.enumerated()), id: \.offset) { _, action in
                Button(action.title, role: action.role, action: action.handler)
            }
        } message: {
            if let message {
                Text(message)
            }
        }
    }
}

// MARK: - Action

extension PrismAlert {

    public struct Action: @unchecked Sendable {
        let title: LocalizedStringKey
        let role: ButtonRole?
        let handler: @MainActor @Sendable () -> Void

        public init(
            _ title: LocalizedStringKey,
            role: ButtonRole? = nil,
            handler: @escaping @MainActor @Sendable () -> Void = {}
        ) {
            self.title = title
            self.role = role
            self.handler = handler
        }

        public static func destructive(
            _ title: LocalizedStringKey,
            handler: @escaping @MainActor @Sendable () -> Void
        ) -> Action {
            Action(title, role: .destructive, handler: handler)
        }

        public static func cancel(_ title: LocalizedStringKey = "Cancel") -> Action {
            Action(title, role: .cancel)
        }
    }
}

extension View {

    /// Presents a themed alert.
    public func prismAlert(
        isPresented: Binding<Bool>,
        title: LocalizedStringKey,
        message: LocalizedStringKey? = nil,
        actions: [PrismAlert.Action]
    ) -> some View {
        modifier(PrismAlert(
            isPresented: isPresented,
            title: title,
            message: message,
            actions: actions
        ))
    }

    /// Presents a simple confirmation alert with confirm + cancel.
    public func prismConfirmation(
        isPresented: Binding<Bool>,
        title: LocalizedStringKey,
        message: LocalizedStringKey? = nil,
        confirmTitle: LocalizedStringKey = "Confirm",
        confirmRole: ButtonRole? = nil,
        onConfirm: @escaping @MainActor @Sendable () -> Void
    ) -> some View {
        modifier(PrismAlert(
            isPresented: isPresented,
            title: title,
            message: message,
            actions: [
                PrismAlert.Action(confirmTitle, role: confirmRole, handler: onConfirm),
                .cancel(),
            ]
        ))
    }
}
