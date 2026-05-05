import SwiftUI

/// Declarative keyframe animation builder using SwiftUI's KeyframeAnimator.
///
/// ```swift
/// PrismKeyframeView(trigger: showItem) { value in
///     Text("Hello")
///         .scaleEffect(value.scale)
///         .opacity(value.opacity)
/// } keyframes: {
///     PrismKeyframeView.Keyframe(at: 0, scale: 0.5, opacity: 0)
///     PrismKeyframeView.Keyframe(at: 0.3, scale: 1.1, opacity: 1)
///     PrismKeyframeView.Keyframe(at: 0.5, scale: 1, opacity: 1)
/// }
/// ```
@MainActor
public struct PrismKeyframeView<Content: View>: View {

    /// Animatable values tracked across keyframe interpolation.
    public struct Values: Sendable {
        /// Scale factor applied to the content.
        public var scale: Double
        /// Opacity level of the content.
        public var opacity: Double
        /// Horizontal offset in points.
        public var offsetX: Double
        /// Vertical offset in points.
        public var offsetY: Double
        /// Rotation angle in degrees.
        public var rotation: Double

        /// Creates keyframe values with the given transform properties.
        public init(
            scale: Double = 1,
            opacity: Double = 1,
            offsetX: Double = 0,
            offsetY: Double = 0,
            rotation: Double = 0
        ) {
            self.scale = scale
            self.opacity = opacity
            self.offsetX = offsetX
            self.offsetY = offsetY
            self.rotation = rotation
        }
    }

    private let trigger: Bool
    private let content: (Values) -> Content
    private let frames: [KeyframeFrame]

    /// Creates a keyframe animation view triggered by a boolean change.
    public init(
        trigger: Bool,
        @ViewBuilder content: @escaping (Values) -> Content,
        frames: () -> [KeyframeFrame]
    ) {
        self.trigger = trigger
        self.content = content
        self.frames = frames()
    }

    /// The keyframe-animated view body driven by the trigger boolean.
    public var body: some View {
        KeyframeAnimator(
            initialValue: frames.first.map { Values(scale: $0.scale, opacity: $0.opacity, offsetX: $0.offsetX, offsetY: $0.offsetY, rotation: $0.rotation) } ?? Values(),
            trigger: trigger
        ) { value in
            content(value)
        } keyframes: { _ in
            KeyframeTrack(\.scale) {
                for frame in frames {
                    SpringKeyframe(frame.scale, duration: frame.duration, spring: .snappy)
                }
            }
            KeyframeTrack(\.opacity) {
                for frame in frames {
                    LinearKeyframe(frame.opacity, duration: frame.duration)
                }
            }
            KeyframeTrack(\.offsetX) {
                for frame in frames {
                    SpringKeyframe(frame.offsetX, duration: frame.duration, spring: .snappy)
                }
            }
            KeyframeTrack(\.offsetY) {
                for frame in frames {
                    SpringKeyframe(frame.offsetY, duration: frame.duration, spring: .snappy)
                }
            }
            KeyframeTrack(\.rotation) {
                for frame in frames {
                    SpringKeyframe(frame.rotation, duration: frame.duration, spring: .snappy)
                }
            }
        }
    }
}

extension PrismKeyframeView {

    /// A single frame in a keyframe animation sequence.
    public struct KeyframeFrame: Sendable {
        /// Duration of this keyframe segment in seconds.
        public let duration: Double
        /// Scale factor at this keyframe.
        public let scale: Double
        /// Opacity at this keyframe.
        public let opacity: Double
        /// Horizontal offset at this keyframe.
        public let offsetX: Double
        /// Vertical offset at this keyframe.
        public let offsetY: Double
        /// Rotation angle in degrees at this keyframe.
        public let rotation: Double

        /// Creates a keyframe frame with the given transform values and duration.
        public init(
            duration: Double = 0.3,
            scale: Double = 1,
            opacity: Double = 1,
            offsetX: Double = 0,
            offsetY: Double = 0,
            rotation: Double = 0
        ) {
            self.duration = duration
            self.scale = scale
            self.opacity = opacity
            self.offsetX = offsetX
            self.offsetY = offsetY
            self.rotation = rotation
        }
    }
}

/// Preset keyframe sequences.
extension PrismKeyframeView {

    /// Returns a pop-in keyframe sequence with overshoot bounce.
    public static func popIn() -> [KeyframeFrame] {
        [
            KeyframeFrame(duration: 0, scale: 0.3, opacity: 0),
            KeyframeFrame(duration: 0.2, scale: 1.1, opacity: 1),
            KeyframeFrame(duration: 0.15, scale: 0.95, opacity: 1),
            KeyframeFrame(duration: 0.1, scale: 1, opacity: 1),
        ]
    }

    /// Returns a drop-in keyframe sequence that falls from above.
    public static func dropIn() -> [KeyframeFrame] {
        [
            KeyframeFrame(duration: 0, scale: 0.8, opacity: 0, offsetY: -40),
            KeyframeFrame(duration: 0.25, scale: 1.05, opacity: 1, offsetY: 5),
            KeyframeFrame(duration: 0.15, scale: 1, opacity: 1, offsetY: 0),
        ]
    }

    /// Returns a flip-in keyframe sequence with rotation entrance.
    public static func flipIn() -> [KeyframeFrame] {
        [
            KeyframeFrame(duration: 0, scale: 0.5, opacity: 0, rotation: -15),
            KeyframeFrame(duration: 0.3, scale: 1.05, opacity: 1, rotation: 3),
            KeyframeFrame(duration: 0.15, scale: 1, opacity: 1, rotation: 0),
        ]
    }

    /// Returns a heartbeat keyframe sequence with pulsing scale.
    public static func heartbeat() -> [KeyframeFrame] {
        [
            KeyframeFrame(duration: 0, scale: 1),
            KeyframeFrame(duration: 0.15, scale: 1.2),
            KeyframeFrame(duration: 0.1, scale: 0.95),
            KeyframeFrame(duration: 0.15, scale: 1.15),
            KeyframeFrame(duration: 0.15, scale: 1),
        ]
    }
}
