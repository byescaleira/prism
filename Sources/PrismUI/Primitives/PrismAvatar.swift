import SwiftUI

/// User avatar with image, initials fallback, and optional status indicator.
public struct PrismAvatar: View {
    @Environment(\.prismTheme) private var theme

    private let content: Content
    private let size: Size
    private let status: Status?

    public init(
        image: Image,
        size: Size = .medium,
        status: Status? = nil
    ) {
        self.content = .image(image)
        self.size = size
        self.status = status
    }

    public init(
        url: URL?,
        size: Size = .medium,
        status: Status? = nil
    ) {
        self.content = .url(url)
        self.size = size
        self.status = status
    }

    public init(
        initials: String,
        size: Size = .medium,
        status: Status? = nil
    ) {
        self.content = .initials(String(initials.prefix(2)).uppercased())
        self.size = size
        self.status = status
    }

    public var body: some View {
        avatarContent
            .frame(width: size.dimension, height: size.dimension)
            .clipShape(Circle())
            .overlay(alignment: .bottomTrailing) {
                if let status {
                    statusDot(status)
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(accessibilityText)
    }

    @ViewBuilder
    private var avatarContent: some View {
        switch content {
        case .image(let image):
            image
                .resizable()
                .scaledToFill()

        case .url(let url):
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    placeholderView
                default:
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }

        case .initials(let text):
            ZStack {
                theme.color(.brand)
                Text(text)
                    .font(.system(size: size.dimension * 0.38, weight: .semibold, design: .rounded))
                    .foregroundStyle(theme.color(.onBrand))
            }
        }
    }

    private var placeholderView: some View {
        ZStack {
            theme.color(.surfaceSecondary)
            Image(systemName: "person.fill")
                .font(.system(size: size.dimension * 0.4))
                .foregroundStyle(theme.color(.onBackgroundTertiary))
        }
    }

    private func statusDot(_ status: Status) -> some View {
        Circle()
            .fill(status.color(theme))
            .frame(width: size.statusSize, height: size.statusSize)
            .overlay(
                Circle()
                    .stroke(theme.color(.background), lineWidth: 2)
            )
            .offset(x: 1, y: 1)
    }

    private var accessibilityText: String {
        var label = String.prismAvatar
        if case .initials(let text) = content { label = text }
        if let status { label += ", \(status.accessibilityLabel)" }
        return label
    }
}

// MARK: - Types

extension PrismAvatar {

    private enum Content {
        case image(Image)
        case url(URL?)
        case initials(String)
    }

    public enum Size: Sendable {
        case small
        case medium
        case large
        case xLarge
        case custom(CGFloat)

        var dimension: CGFloat {
            switch self {
            case .small: 32
            case .medium: 40
            case .large: 56
            case .xLarge: 80
            case .custom(let size): size
            }
        }

        var statusSize: CGFloat {
            switch self {
            case .small: 10
            case .medium: 12
            case .large: 14
            case .xLarge: 18
            case .custom(let size): size * 0.25
            }
        }
    }

    public enum Status: Sendable {
        case online
        case offline
        case busy
        case away

        @MainActor
        func color(_ theme: any PrismTheme) -> Color {
            switch self {
            case .online: theme.color(.success)
            case .offline: theme.color(.onBackgroundTertiary)
            case .busy: theme.color(.error)
            case .away: theme.color(.warning)
            }
        }

        var accessibilityLabel: String {
            switch self {
            case .online: .prismOnline
            case .offline: .prismOffline
            case .busy: .prismBusy
            case .away: .prismAway
            }
        }
    }
}
