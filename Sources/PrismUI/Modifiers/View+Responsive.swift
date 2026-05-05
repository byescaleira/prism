import SwiftUI

/// Responsive sizing presets for container-relative frames.
public enum PrismResponsiveSize: Sendable {
    /// Represents 100% of the container width.
    case full
    /// Represents 50% of the container width.
    case half
    /// Represents one-third of the container width.
    case third
    /// Represents two-thirds of the container width.
    case twoThirds
    /// Represents 25% of the container width.
    case quarter
    /// Represents 75% of the container width.
    case threeQuarters
    /// Represents a custom fraction of the container width.
    case custom(CGFloat)

    var fraction: CGFloat {
        switch self {
        case .full: 1.0
        case .half: 0.5
        case .third: 1.0 / 3.0
        case .twoThirds: 2.0 / 3.0
        case .quarter: 0.25
        case .threeQuarters: 0.75
        case .custom(let value): value
        }
    }
}

// MARK: - Container Relative Frame

private struct PrismContainerFrameModifier: ViewModifier {
    let axes: Axis.Set
    let size: PrismResponsiveSize

    func body(content: Content) -> some View {
        content
            .containerRelativeFrame(axes) { length, _ in
                length * size.fraction
            }
    }
}

// MARK: - Geometry Observer

private struct PrismGeometryModifier: ViewModifier {
    let onChange: @MainActor (CGSize) -> Void

    func body(content: Content) -> some View {
        content
            .onGeometryChange(for: CGSize.self) { proxy in
                proxy.size
            } action: { size in
                onChange(size)
            }
    }
}

// MARK: - Scaled Metric

/// A view that renders content with a scaled metric value.
///
/// Wraps `@ScaledMetric` for use in view composition.
///
/// ```swift
/// PrismScaledView(baseSize: 44) { size in
///     Image(systemName: "star")
///         .frame(width: size, height: size)
/// }
/// ```
public struct PrismScaledView<Content: View>: View {
    @ScaledMetric private var scaledSize: CGFloat
    private let content: (CGFloat) -> Content

    /// Creates a scaled view that adapts a base size to Dynamic Type settings.
    public init(
        baseSize: CGFloat,
        relativeTo textStyle: Font.TextStyle = .body,
        @ViewBuilder content: @escaping (CGFloat) -> Content
    ) {
        self._scaledSize = ScaledMetric(wrappedValue: baseSize, relativeTo: textStyle)
        self.content = content
    }

    /// The content and behavior of the scaled view.
    public var body: some View {
        content(scaledSize)
    }
}

extension View {

    /// Sizes view relative to container (responsive layout).
    public func prismContainerFrame(
        _ axes: Axis.Set = .horizontal,
        size: PrismResponsiveSize = .full
    ) -> some View {
        modifier(PrismContainerFrameModifier(axes: axes, size: size))
    }

    /// Observes geometry changes using modern `onGeometryChange` API.
    public func prismGeometry(onChange: @MainActor @escaping (CGSize) -> Void) -> some View {
        modifier(PrismGeometryModifier(onChange: onChange))
    }

    /// Applies content margins for scroll views.
    public func prismContentMargins(_ edges: Edge.Set = .all, _ token: SpacingToken) -> some View {
        self.contentMargins(edges, token.rawValue, for: .scrollContent)
    }
}
