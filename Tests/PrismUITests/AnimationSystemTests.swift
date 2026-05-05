import SwiftUI
import Testing

@testable import PrismUI

@MainActor
@Suite("Animation System")
struct AnimationSystemTests {

    // MARK: - Spring Config

    @Suite("Spring Config")
    struct SpringConfigTests {

        @Test("predefined configs have valid parameters")
        @MainActor func presets() {
            let configs: [PrismSpringConfig] = [.snappy, .gentle, .bouncy, .stiff, .dramatic, .critical, .rubber]
            for config in configs {
                #expect(config.response > 0)
                #expect(config.dampingFraction > 0)
                #expect(config.dampingFraction <= 1.0)
            }
        }

        @Test("custom config initializer")
        @MainActor func customInit() {
            let config = PrismSpringConfig(response: 0.3, dampingFraction: 0.6, blendDuration: 0.1)
            #expect(config.response == 0.3)
            #expect(config.dampingFraction == 0.6)
            #expect(config.blendDuration == 0.1)
        }

        @Test("animation produces non-nil Animation")
        @MainActor func animation() {
            let config = PrismSpringConfig.bouncy
            let anim = config.animation
            _ = anim
        }

        @Test("spring configs are Hashable")
        @MainActor func hashable() {
            let a = PrismSpringConfig.snappy
            let b = PrismSpringConfig.snappy
            #expect(a == b)
            #expect(a.hashValue == b.hashValue)
        }

        @Test("different configs are not equal")
        @MainActor func notEqual() {
            #expect(PrismSpringConfig.snappy != PrismSpringConfig.gentle)
        }

        @Test("prismSpring modifier exists")
        @MainActor func modifier() {
            #expect(PrismSpringConfig.bouncy.dampingFraction == 0.5)
        }
    }

    // MARK: - Keyframe Builder

    @Suite("Keyframe Builder")
    struct KeyframeTests {

        @Test("KeyframeFrame defaults")
        @MainActor func frameDefaults() {
            let frame = PrismKeyframeView<Text>.KeyframeFrame()
            #expect(frame.duration == 0.3)
            #expect(frame.scale == 1)
            #expect(frame.opacity == 1)
            #expect(frame.offsetX == 0)
            #expect(frame.offsetY == 0)
            #expect(frame.rotation == 0)
        }

        @Test("popIn preset has 4 frames")
        @MainActor func popIn() {
            let frames = PrismKeyframeView<Text>.popIn()
            #expect(frames.count == 4)
            #expect(frames.first?.scale == 0.3)
            #expect(frames.last?.scale == 1)
        }

        @Test("dropIn preset has 3 frames")
        @MainActor func dropIn() {
            let frames = PrismKeyframeView<Text>.dropIn()
            #expect(frames.count == 3)
            #expect(frames.first?.offsetY == -40)
        }

        @Test("flipIn preset has 3 frames")
        @MainActor func flipIn() {
            let frames = PrismKeyframeView<Text>.flipIn()
            #expect(frames.count == 3)
            #expect(frames.first?.rotation == -15)
        }

        @Test("heartbeat preset has 5 frames")
        @MainActor func heartbeat() {
            let frames = PrismKeyframeView<Text>.heartbeat()
            #expect(frames.count == 5)
        }

        @Test("Values defaults")
        @MainActor func valuesDefaults() {
            let v = PrismKeyframeView<Text>.Values()
            #expect(v.scale == 1)
            #expect(v.opacity == 1)
            #expect(v.offsetX == 0)
            #expect(v.offsetY == 0)
            #expect(v.rotation == 0)
        }

        @Test("PrismKeyframeView renders")
        @MainActor func renders() {
            let frames = PrismKeyframeView<Text>.popIn()
            #expect(frames.count == 4)
        }
    }

    // MARK: - Gesture Animation

    @Suite("Gesture Animation")
    struct GestureTests {

        @Test("PrismDraggable renders")
        @MainActor func draggable() {
            let view = PrismDraggable { Text("Drag") }
            _ = view.body
        }

        @Test("PrismDraggable with axis constraint")
        @MainActor func draggableAxis() {
            let view = PrismDraggable(axis: .horizontal) { Text("H only") }
            _ = view.body
        }

        @Test("PrismPinchable renders")
        @MainActor func pinchable() {
            let view = PrismPinchable { Text("Pinch") }
            _ = view.body
        }

        @Test("PrismPinchable with custom bounds")
        @MainActor func pinchableBounds() {
            let view = PrismPinchable(minScale: 0.3, maxScale: 5.0) { Text("Zoom") }
            _ = view.body
        }

        @Test("PrismRotatable renders")
        @MainActor func rotatable() {
            let view = PrismRotatable { Text("Rotate") }
            _ = view.body
        }

        @Test("PrismRotatable with snap")
        @MainActor func rotatableSnap() {
            let view = PrismRotatable(snapsToAxis: true) { Text("Snap") }
            _ = view.body
        }
    }

    // MARK: - Shared Transition

    @Suite("Shared Transition")
    struct SharedTransitionTests {

        @Test("PrismSharedElement initializes")
        @MainActor func sharedElement() {
            #expect(PrismSharedElement<Text>.self is any View.Type)
        }

        @Test("PrismHeroTransition initializes collapsed")
        @MainActor func heroCollapsed() {
            #expect(PrismHeroTransition<Text, Text>.self is any View.Type)
        }

        @Test("hero spring configs")
        @MainActor func heroSpring() {
            let config = PrismSpringConfig.dramatic
            #expect(config.response == 0.7)
            #expect(config.dampingFraction == 0.65)
        }
    }

    // MARK: - Physics Animation

    @Suite("Physics Animation")
    struct PhysicsTests {

        @Test("PrismGravityDrop renders")
        @MainActor func gravityDrop() {
            let view = PrismGravityDrop { Text("Fall") }
            _ = view.body
        }

        @Test("PrismGravityDrop with custom params")
        @MainActor func gravityCustom() {
            let view = PrismGravityDrop(gravity: 2.0, bounce: 0.5) { Text("Heavy") }
            _ = view.body
        }

        @Test("PrismFloat renders")
        @MainActor func float() {
            let view = PrismFloat { Text("Float") }
            _ = view.body
        }

        @Test("PrismFloat custom params")
        @MainActor func floatCustom() {
            let view = PrismFloat(amplitude: 12, frequency: 2.0) { Text("Bob") }
            _ = view.body
        }

        @Test("PrismMomentumScroll renders")
        @MainActor func momentum() {
            let view = PrismMomentumScroll { Text("Scroll") }
            _ = view.body
        }

        @Test("PrismParticleEffect renders inactive")
        @MainActor func particlesInactive() {
            let view = PrismParticleEffect(isActive: false, color: .red)
            _ = view.body
        }

        @Test("PrismParticleEffect renders active")
        @MainActor func particlesActive() {
            let view = PrismParticleEffect(count: 10, isActive: true, color: .blue)
            _ = view.body
        }
    }

    // MARK: - Staggered Animation

    @Suite("Staggered Animation")
    struct StaggerTests {

        struct Item: Identifiable {
            let id: Int
            let name: String
        }

        @Test("PrismStaggeredList renders")
        @MainActor func staggeredList() {
            let items = (0..<5).map { Item(id: $0, name: "Item \($0)") }
            let view = PrismStaggeredList(items: items) { item, _ in
                Text(item.name)
            }
            _ = view.body
        }

        @Test("all stagger styles")
        @MainActor func staggerStyles() {
            let items = [Item(id: 0, name: "A")]
            let styles: [PrismStaggerStyle] = [
                .slideUp, .slideLeft, .fadeIn, .scaleIn, .slideRight,
            ]
            for style in styles {
                let view = PrismStaggeredList(items: items, animation: style) { item, _ in
                    Text(item.name)
                }
                _ = view.body
            }
        }

        @Test("prismStagger modifier exists")
        @MainActor func staggerModifier() {
            #expect(PrismStaggerStyle.slideUp != PrismStaggerStyle.fadeIn)
        }

        @Test("custom spring and delay")
        @MainActor func customParams() {
            let items = (0..<3).map { Item(id: $0, name: "\($0)") }
            let view = PrismStaggeredList(
                items: items,
                staggerDelay: 0.1,
                spring: .bouncy,
                animation: .scaleIn
            ) { item, _ in
                Text(item.name)
            }
            _ = view.body
        }
    }
}
