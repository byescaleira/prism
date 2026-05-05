import SwiftUI

/// Token-based gradient views using theme colors.
///
/// ```swift
/// PrismLinearGradient(from: .brand, to: .interactive)
/// PrismRadialGradient(colors: [.brand, .interactive, .background])
/// ```
public struct PrismLinearGradient: View {
    @Environment(\.prismTheme) private var theme

    private let colors: [ColorToken]
    private let startPoint: UnitPoint
    private let endPoint: UnitPoint

    /// Creates a linear gradient between two color tokens.
    public init(
        from start: ColorToken,
        to end: ColorToken,
        startPoint: UnitPoint = .topLeading,
        endPoint: UnitPoint = .bottomTrailing
    ) {
        self.colors = [start, end]
        self.startPoint = startPoint
        self.endPoint = endPoint
    }

    /// Creates a linear gradient from an array of color tokens.
    public init(
        colors: [ColorToken],
        startPoint: UnitPoint = .top,
        endPoint: UnitPoint = .bottom
    ) {
        self.colors = colors
        self.startPoint = startPoint
        self.endPoint = endPoint
    }

    /// The content and behavior of the linear gradient.
    public var body: some View {
        LinearGradient(
            colors: colors.map { theme.color($0) },
            startPoint: startPoint,
            endPoint: endPoint
        )
    }
}

/// Token-based radial gradient.
public struct PrismRadialGradient: View {
    @Environment(\.prismTheme) private var theme

    private let colors: [ColorToken]
    private let center: UnitPoint
    private let startRadius: CGFloat
    private let endRadius: CGFloat

    /// Creates a radial gradient from color tokens with center and radius parameters.
    public init(
        colors: [ColorToken],
        center: UnitPoint = .center,
        startRadius: CGFloat = 0,
        endRadius: CGFloat = 200
    ) {
        self.colors = colors
        self.center = center
        self.startRadius = startRadius
        self.endRadius = endRadius
    }

    /// The content and behavior of the radial gradient.
    public var body: some View {
        RadialGradient(
            colors: colors.map { theme.color($0) },
            center: center,
            startRadius: startRadius,
            endRadius: endRadius
        )
    }
}

/// Token-based angular gradient.
public struct PrismAngularGradient: View {
    @Environment(\.prismTheme) private var theme

    private let colors: [ColorToken]
    private let center: UnitPoint

    /// Creates an angular gradient from color tokens around a center point.
    public init(
        colors: [ColorToken],
        center: UnitPoint = .center
    ) {
        self.colors = colors
        self.center = center
    }

    /// The content and behavior of the angular gradient.
    public var body: some View {
        AngularGradient(
            colors: colors.map { theme.color($0) },
            center: center
        )
    }
}

/// Material wrapper with PrismUI token naming.
public enum PrismMaterial: Sendable {
    /// Represents an ultra-thin material blur.
    case ultraThin
    /// Represents a thin material blur.
    case thin
    /// Represents a regular-weight material blur.
    case regular
    /// Represents a thick material blur.
    case thick
    /// Represents an ultra-thick material blur.
    case ultraThick
    /// Represents a navigation/tab bar material.
    case bar

    /// The SwiftUI Material value corresponding to this token.
    public var material: Material {
        switch self {
        case .ultraThin: .ultraThinMaterial
        case .thin: .thinMaterial
        case .regular: .regularMaterial
        case .thick: .thickMaterial
        case .ultraThick: .ultraThickMaterial
        case .bar: .bar
        }
    }
}

extension View {

    /// Applies a themed material background.
    public func prismMaterial(_ material: PrismMaterial, in shape: some Shape = Rectangle()) -> some View {
        self.background(material.material, in: shape)
    }
}
