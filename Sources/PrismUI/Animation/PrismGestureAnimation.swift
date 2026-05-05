import SwiftUI

/// Gesture-driven interactive animations with spring-back behavior.
///
/// ```swift
/// PrismDraggable {
///     PrismCard { Text("Drag me") }
/// }
/// ```
@MainActor
public struct PrismDraggable<Content: View>: View {
    @GestureState private var dragOffset: CGSize = .zero
    @State private var finalOffset: CGSize = .zero

    private let springBack: Bool
    private let axis: Axis.Set
    private let spring: PrismSpringConfig
    private let content: Content

    /// Creates a draggable wrapper with configurable spring-back, axis lock, and spring preset.
    public init(
        springBack: Bool = true,
        axis: Axis.Set = [.horizontal, .vertical],
        spring: PrismSpringConfig = .rubber,
        @ViewBuilder content: () -> Content
    ) {
        self.springBack = springBack
        self.axis = axis
        self.spring = spring
        self.content = content()
    }

    /// The draggable view body with gesture-driven offset and spring animation.
    public var body: some View {
        content
            .offset(
                x: axis.contains(.horizontal) ? dragOffset.width + finalOffset.width : 0,
                y: axis.contains(.vertical) ? dragOffset.height + finalOffset.height : 0
            )
            .gesture(
                DragGesture()
                    .updating($dragOffset) { value, state, _ in
                        state = value.translation
                    }
                    .onEnded { value in
                        if springBack {
                            withAnimation(spring.animation) {
                                finalOffset = .zero
                            }
                        } else {
                            finalOffset = CGSize(
                                width: finalOffset.width + value.translation.width,
                                height: finalOffset.height + value.translation.height
                            )
                        }
                    }
            )
            .animation(spring.animation, value: dragOffset)
    }
}

/// Pinch-to-scale with spring reset.
@MainActor
public struct PrismPinchable<Content: View>: View {
    @State private var currentScale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0

    private let minScale: CGFloat
    private let maxScale: CGFloat
    private let spring: PrismSpringConfig
    private let content: Content

    /// Creates a pinchable wrapper with configurable scale limits and spring preset.
    public init(
        minScale: CGFloat = 0.5,
        maxScale: CGFloat = 3.0,
        spring: PrismSpringConfig = .gentle,
        @ViewBuilder content: () -> Content
    ) {
        self.minScale = minScale
        self.maxScale = maxScale
        self.spring = spring
        self.content = content()
    }

    /// The pinchable view body with magnification gesture and spring animation.
    public var body: some View {
        content
            .scaleEffect(currentScale)
            .gesture(
                MagnifyGesture()
                    .onChanged { value in
                        let delta = value.magnification / lastScale
                        lastScale = value.magnification
                        currentScale = min(max(currentScale * delta, minScale), maxScale)
                    }
                    .onEnded { _ in
                        lastScale = 1.0
                        withAnimation(spring.animation) {
                            currentScale = 1.0
                        }
                    }
            )
            .animation(spring.animation, value: currentScale)
    }
}

/// Rotation gesture with spring-back.
@MainActor
public struct PrismRotatable<Content: View>: View {
    @State private var currentAngle: Angle = .zero
    @State private var lastAngle: Angle = .zero

    private let snapsToAxis: Bool
    private let spring: PrismSpringConfig
    private let content: Content

    /// Creates a rotatable wrapper with optional axis snapping and spring preset.
    public init(
        snapsToAxis: Bool = false,
        spring: PrismSpringConfig = .gentle,
        @ViewBuilder content: () -> Content
    ) {
        self.snapsToAxis = snapsToAxis
        self.spring = spring
        self.content = content()
    }

    /// The rotatable view body with rotation gesture and optional axis snapping.
    public var body: some View {
        content
            .rotationEffect(currentAngle)
            .gesture(
                RotateGesture()
                    .onChanged { value in
                        currentAngle = lastAngle + value.rotation
                    }
                    .onEnded { _ in
                        if snapsToAxis {
                            let snapped = snapToNearest90(currentAngle)
                            lastAngle = snapped
                            withAnimation(spring.animation) {
                                currentAngle = snapped
                            }
                        } else {
                            lastAngle = currentAngle
                        }
                    }
            )
    }

    private func snapToNearest90(_ angle: Angle) -> Angle {
        let degrees = angle.degrees.truncatingRemainder(dividingBy: 360)
        let snapped = (degrees / 90).rounded() * 90
        return .degrees(snapped)
    }
}
