import SwiftUI

/// Physics-based animation utilities — gravity, friction, momentum.
///
/// ```swift
/// PrismGravityDrop(isActive: showItem) {
///     PrismCard { Text("Falls in") }
/// }
/// ```
@MainActor
public struct PrismGravityDrop<Content: View>: View {
    @State private var offset: CGFloat = -200
    @State private var hasAppeared = false

    let isActive: Bool
    let gravity: CGFloat
    let bounce: CGFloat
    let content: Content

    /// Creates a gravity drop with configurable gravity strength and bounce amount.
    public init(
        isActive: Bool = true,
        gravity: CGFloat = 1.0,
        bounce: CGFloat = 0.3,
        @ViewBuilder content: () -> Content
    ) {
        self.isActive = isActive
        self.gravity = gravity
        self.bounce = bounce
        self.content = content()
    }

    /// The gravity drop view body that animates content from above on appear.
    public var body: some View {
        content
            .offset(y: hasAppeared ? 0 : offset)
            .opacity(hasAppeared ? 1 : 0)
            .onAppear {
                guard isActive else {
                    hasAppeared = true
                    return
                }
                withAnimation(.spring(response: 0.6 / gravity, dampingFraction: 1 - bounce)) {
                    hasAppeared = true
                }
            }
    }
}

/// Momentum-based scroll decay. Wraps content with velocity tracking.
@MainActor
public struct PrismMomentumScroll<Content: View>: View {
    @State private var scrollOffset: CGFloat = 0
    @State private var velocity: CGFloat = 0
    @State private var isDragging = false

    let friction: CGFloat
    let axis: Axis
    let content: Content

    /// Creates a momentum scroll with configurable friction and axis.
    public init(
        friction: CGFloat = 0.95,
        axis: Axis = .vertical,
        @ViewBuilder content: () -> Content
    ) {
        self.friction = friction
        self.axis = axis
        self.content = content()
    }

    /// The momentum scroll view body with velocity-based decay on drag end.
    public var body: some View {
        content
            .offset(
                x: axis == .horizontal ? scrollOffset : 0,
                y: axis == .vertical ? scrollOffset : 0
            )
            .gesture(
                DragGesture()
                    .onChanged { value in
                        isDragging = true
                        let translation = axis == .vertical ? value.translation.height : value.translation.width
                        scrollOffset = translation
                        velocity = axis == .vertical ? value.velocity.height : value.velocity.width
                    }
                    .onEnded { _ in
                        isDragging = false
                        let decayDistance = velocity * friction * 0.3
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                            scrollOffset += decayDistance
                        }
                    }
            )
    }
}

/// Floating/bobbing animation — simulates gentle wave motion.
@MainActor
public struct PrismFloat<Content: View>: View {
    @State private var phase: Double = 0

    let amplitude: CGFloat
    let frequency: Double
    let content: Content

    /// Creates a floating animation with configurable amplitude and frequency.
    public init(
        amplitude: CGFloat = 8,
        frequency: Double = 1.5,
        @ViewBuilder content: () -> Content
    ) {
        self.amplitude = amplitude
        self.frequency = frequency
        self.content = content()
    }

    /// The floating view body with continuous sinusoidal offset.
    public var body: some View {
        TimelineView(.animation) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            content
                .offset(y: sin(time * frequency * .pi * 2) * amplitude)
        }
    }
}

/// Particle-like scatter animation for celebration effects.
@MainActor
public struct PrismParticleEffect: View {
    @State private var particles: [Particle] = []

    let count: Int
    let isActive: Bool
    let color: Color

    /// Creates a particle effect with the given count, activation state, and color.
    public init(count: Int = 20, isActive: Bool, color: Color = .blue) {
        self.count = count
        self.isActive = isActive
        self.color = color
    }

    /// The particle effect view body that emits and scatters circles when activated.
    public var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Circle()
                    .fill(color.opacity(particle.opacity))
                    .frame(width: particle.size, height: particle.size)
                    .offset(x: particle.x, y: particle.y)
            }
        }
        .onChange(of: isActive) { _, active in
            if active { emit() }
        }
    }

    private func emit() {
        particles = (0..<count).map { i in
            Particle(
                id: i,
                x: 0, y: 0,
                size: CGFloat.random(in: 4...10),
                opacity: 1
            )
        }

        withAnimation(.easeOut(duration: 1.0)) {
            particles = particles.map { p in
                Particle(
                    id: p.id,
                    x: CGFloat.random(in: -120...120),
                    y: CGFloat.random(in: -150...50),
                    size: p.size * 0.3,
                    opacity: 0
                )
            }
        }
    }

    struct Particle: Identifiable {
        let id: Int
        var x: CGFloat
        var y: CGFloat
        var size: CGFloat
        var opacity: Double
    }
}
