import SwiftUI

/// Themed image that supports both system symbols and catalog resources.
///
/// ```swift
/// PrismImageResource(.system("star.fill"), color: .interactive)
/// PrismImageResource(.catalog("logo"), renderingMode: .template)
/// ```
public struct PrismImageResource: View {
    @Environment(\.prismTheme) private var theme

    private let source: Source
    private let colorToken: ColorToken?
    private let renderingMode: Image.TemplateRenderingMode?

    /// Creates a themed image from a source with optional color and rendering mode.
    public init(
        _ source: Source,
        color: ColorToken? = nil,
        renderingMode: Image.TemplateRenderingMode? = nil
    ) {
        self.source = source
        self.colorToken = color
        self.renderingMode = renderingMode
    }

    /// The content and behavior of the image resource.
    public var body: some View {
        resolvedImage
            .renderingMode(renderingMode ?? .template)
            .foregroundStyle(colorToken.map { theme.color($0) } ?? theme.color(.onBackground))
    }

    private var resolvedImage: Image {
        switch source {
        case .system(let name):
            Image(systemName: name)
        case .catalog(let name, let bundle):
            Image(name, bundle: bundle)
        }
    }

    /// The source of an image resource.
    public enum Source: Sendable {
        /// Represents an SF Symbol by name.
        case system(String)
        /// Represents an asset catalog image by name and optional bundle.
        case catalog(String, bundle: Bundle? = nil)
    }
}
