import SwiftUI

/// SF Symbols wrapper with semantic sizing, variable value, and symbol effects.
public struct PrismIcon: View {
    @Environment(\.prismTheme) private var theme

    private let name: String
    private let size: Size
    private let colorToken: ColorToken
    private let renderingMode: SymbolRenderingMode
    private let variableValue: Double?

    /// Creates an icon from an SF Symbol name with size, color, and rendering options.
    public init(
        _ systemName: String,
        size: Size = .medium,
        color: ColorToken = .onBackground,
        rendering: SymbolRenderingMode = .monochrome,
        variableValue: Double? = nil
    ) {
        self.name = systemName
        self.size = size
        self.colorToken = color
        self.renderingMode = rendering
        self.variableValue = variableValue
    }

    /// The content and behavior of the icon.
    public var body: some View {
        image
            .symbolRenderingMode(renderingMode)
            .font(.system(size: size.points))
            .foregroundStyle(theme.color(colorToken))
            .accessibilityHidden(true)
    }

    private var image: Image {
        if let variableValue {
            Image(systemName: name, variableValue: variableValue)
        } else {
            Image(systemName: name)
        }
    }
}

// MARK: - Size

extension PrismIcon {

    /// Predefined icon sizes.
    public enum Size: Sendable {
        /// Represents a 14pt icon.
        case small
        /// Represents an 18pt icon.
        case medium
        /// Represents a 24pt icon.
        case large
        /// Represents a 32pt icon.
        case xLarge
        /// Represents a custom-sized icon.
        case custom(CGFloat)

        var points: CGFloat {
            switch self {
            case .small: 14
            case .medium: 18
            case .large: 24
            case .xLarge: 32
            case .custom(let size): size
            }
        }
    }
}
