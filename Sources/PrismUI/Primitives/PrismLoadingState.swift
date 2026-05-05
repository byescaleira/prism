import SwiftUI

/// Standardized loading/empty/error state views.
public struct PrismLoadingState: View {

    private let state: State

    /// Creates a loading state view for the given state.
    public init(_ state: State) {
        self.state = state
    }

    /// The content and behavior of the loading state view.
    public var body: some View {
        switch state {
        case .loading:
            LoadingView()
        case .empty(let title, let message, let icon):
            EmptyStateView(title: title, message: message, icon: icon)
        case .error(let message, let retry):
            ErrorStateView(message: message, retry: retry)
        }
    }
}

// MARK: - State

extension PrismLoadingState {

    /// The possible loading state values.
    public enum State {
        /// Represents an active loading state with a spinner.
        case loading
        /// Represents an empty content state with title, message, and icon.
        case empty(title: LocalizedStringKey, message: LocalizedStringKey?, icon: String?)
        /// Represents an error state with a message and optional retry action.
        case error(LocalizedStringKey, retry: (() -> Void)?)
    }
}

// MARK: - Subviews

private struct LoadingView: View {
    var body: some View {
        VStack(spacing: SpacingToken.lg.rawValue) {
            ProgressView()
                .controlSize(.large)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct EmptyStateView: View {
    @Environment(\.prismTheme) private var theme
    let title: LocalizedStringKey
    let message: LocalizedStringKey?
    let icon: String?

    var body: some View {
        VStack(spacing: SpacingToken.lg.rawValue) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 48))
                    .foregroundStyle(theme.color(.onBackgroundTertiary))
            }

            Text(title)
                .font(TypographyToken.title3.font)
                .foregroundStyle(theme.color(.onBackground))

            if let message {
                Text(message)
                    .font(TypographyToken.body.font)
                    .foregroundStyle(theme.color(.onBackgroundSecondary))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(SpacingToken.xxl.rawValue)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct ErrorStateView: View {
    @Environment(\.prismTheme) private var theme
    let message: LocalizedStringKey
    let retry: (() -> Void)?

    var body: some View {
        VStack(spacing: SpacingToken.lg.rawValue) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundStyle(theme.color(.error))

            Text(message)
                .font(TypographyToken.body.font)
                .foregroundStyle(theme.color(.onBackgroundSecondary))
                .multilineTextAlignment(.center)

            if let retry {
                Button(action: retry) {
                    Text(PrismStrings.retry)
                        .font(TypographyToken.headline.font)
                        .foregroundStyle(theme.color(.interactive))
                }
            }
        }
        .padding(SpacingToken.xxl.rawValue)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
