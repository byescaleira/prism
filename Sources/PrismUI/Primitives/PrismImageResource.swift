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

    public init(
        _ source: Source,
        color: ColorToken? = nil,
        renderingMode: Image.TemplateRenderingMode? = nil
    ) {
        self.source = source
        self.colorToken = color
        self.renderingMode = renderingMode
    }

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

    public enum Source: Sendable {
        case system(String)
        case catalog(String, bundle: Bundle? = nil)
    }
}
