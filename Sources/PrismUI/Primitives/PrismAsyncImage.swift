import SwiftUI

/// Async image loader with placeholder, error state, and themed styling.
public struct PrismAsyncImage<Placeholder: View>: View {
    @Environment(\.prismTheme) private var theme

    private let url: URL?
    private let contentMode: ContentMode
    private let radius: RadiusToken
    private let placeholder: Placeholder

    /// Creates an async image with a URL, content mode, radius, and custom placeholder.
    public init(
        url: URL?,
        contentMode: ContentMode = .fill,
        radius: RadiusToken = .md,
        @ViewBuilder placeholder: () -> Placeholder
    ) {
        self.url = url
        self.contentMode = contentMode
        self.radius = radius
        self.placeholder = placeholder()
    }

    /// The content and behavior of the async image.
    public var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                    .clipShape(radius.shape)

            case .failure:
                errorView

            case .empty:
                placeholder

            @unknown default:
                placeholder
            }
        }
    }

    private var errorView: some View {
        ZStack {
            theme.color(.surfaceSecondary)
            Image(systemName: "photo")
                .font(.title2)
                .foregroundStyle(theme.color(.onBackgroundTertiary))
        }
        .clipShape(radius.shape)
    }
}

extension PrismAsyncImage where Placeholder == PrismAsyncImageDefaultPlaceholder {

    /// Creates an async image with a URL using the default progress placeholder.
    public init(
        url: URL?,
        contentMode: ContentMode = .fill,
        radius: RadiusToken = .md
    ) {
        self.url = url
        self.contentMode = contentMode
        self.radius = radius
        self.placeholder = PrismAsyncImageDefaultPlaceholder()
    }
}

/// Default placeholder view showing a progress spinner on a themed surface.
public struct PrismAsyncImageDefaultPlaceholder: View {
    @Environment(\.prismTheme) private var theme

    /// The content and behavior of the default placeholder.
    public var body: some View {
        ZStack {
            theme.color(.surfaceSecondary)
            ProgressView()
        }
    }
}
