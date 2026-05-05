import SwiftUI

/// Ephemeral notification that appears briefly and auto-dismisses.
public struct PrismToast: View {
    @Environment(\.prismTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let message: LocalizedStringKey
    private let icon: String?
    private let style: Style

    /// Creates a toast with message, optional icon, and visual style.
    public init(
        _ message: LocalizedStringKey,
        icon: String? = nil,
        style: Style = .neutral
    ) {
        self.message = message
        self.icon = icon
        self.style = style
    }

    /// The toast view body with icon, message, and material background.
    public var body: some View {
        HStack(spacing: SpacingToken.sm.rawValue) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(style.foreground(theme))
            }

            Text(message)
                .font(TypographyToken.subheadline.font(weight: .medium))
                .foregroundStyle(theme.color(.onSurface))
                .lineLimit(2)
        }
        .padding(.horizontal, SpacingToken.lg.rawValue)
        .padding(.vertical, SpacingToken.md.rawValue)
        .background(.ultraThinMaterial, in: Capsule())
        .prismElevation(.high)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isStaticText)
    }
}

// MARK: - Style

extension PrismToast {

    /// Visual style for the toast foreground color.
    public enum Style: Sendable {
        /// Default neutral color.
        case neutral
        /// Success green color.
        case success
        /// Error red color.
        case error
        /// Informational blue color.
        case info

        @MainActor
        func foreground(_ theme: any PrismTheme) -> Color {
            switch self {
            case .neutral: theme.color(.onSurface)
            case .success: theme.color(.success)
            case .error: theme.color(.error)
            case .info: theme.color(.info)
            }
        }
    }
}

// MARK: - View Modifier

private struct PrismToastModifier: ViewModifier {
    @Binding var isPresented: Bool
    let message: LocalizedStringKey
    let icon: String?
    let style: PrismToast.Style
    let edge: VerticalEdge
    let duration: TimeInterval

    @State private var task: Task<Void, Never>?

    func body(content: Content) -> some View {
        content.overlay(alignment: edge == .top ? .top : .bottom) {
            if isPresented {
                PrismToast(message, icon: icon, style: style)
                    .padding(SpacingToken.lg.rawValue)
                    .transition(.move(edge: edge == .top ? .top : .bottom).combined(with: .opacity))
                    .onAppear { scheduleAutoDismiss() }
                    .onDisappear { task?.cancel() }
            }
        }
        .animation(.spring(duration: 0.35), value: isPresented)
    }

    private func scheduleAutoDismiss() {
        task?.cancel()
        task = Task { @MainActor in
            try? await Task.sleep(for: .seconds(duration))
            guard !Task.isCancelled else { return }
            isPresented = false
        }
    }
}

extension View {

    /// Shows an auto-dismissing toast notification.
    public func prismToast(
        isPresented: Binding<Bool>,
        _ message: LocalizedStringKey,
        icon: String? = nil,
        style: PrismToast.Style = .neutral,
        edge: VerticalEdge = .bottom,
        duration: TimeInterval = 3
    ) -> some View {
        modifier(PrismToastModifier(
            isPresented: isPresented,
            message: message,
            icon: icon,
            style: style,
            edge: edge,
            duration: duration
        ))
    }
}
