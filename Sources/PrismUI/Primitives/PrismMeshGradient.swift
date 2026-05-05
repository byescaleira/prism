import SwiftUI

/// Themed mesh gradient backgrounds using token colors.
///
/// Wraps SwiftUI `MeshGradient` with preset configurations
/// aligned with PrismUI color tokens.
///
/// ```swift
/// PrismMeshGradient(preset: .aurora)
///     .ignoresSafeArea()
/// ```
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public struct PrismMeshGradient: View {
    @Environment(\.prismTheme) private var theme

    private let preset: MeshPreset
    private let width: Int
    private let height: Int
    private let points: [SIMD2<Float>]?
    private let colors: [Color]?

    /// Creates a mesh gradient from a named preset.
    public init(preset: MeshPreset) {
        self.preset = preset
        self.width = 3
        self.height = 3
        self.points = nil
        self.colors = nil
    }

    /// Creates a custom mesh gradient with explicit grid dimensions, points, and colors.
    public init(
        width: Int,
        height: Int,
        points: [SIMD2<Float>],
        colors: [Color]
    ) {
        self.preset = .custom
        self.width = width
        self.height = height
        self.points = points
        self.colors = colors
    }

    /// The content and behavior of the mesh gradient.
    public var body: some View {
        if let points, let colors {
            MeshGradient(width: width, height: height, points: points, colors: colors)
        } else {
            MeshGradient(
                width: 3, height: 3,
                points: preset.points,
                colors: presetColors
            )
        }
    }

    private var presetColors: [Color] {
        switch preset {
        case .aurora:
            return [
                theme.color(.brand), theme.color(.interactive), theme.color(.info),
                theme.color(.success), theme.color(.brand).opacity(0.8), theme.color(.interactive),
                theme.color(.info).opacity(0.6), theme.color(.success).opacity(0.7), theme.color(.brand),
            ]
        case .sunset:
            return [
                theme.color(.warning), theme.color(.error), theme.color(.brand),
                theme.color(.error).opacity(0.7), theme.color(.warning).opacity(0.8), theme.color(.error),
                theme.color(.brand).opacity(0.6), theme.color(.warning), theme.color(.error).opacity(0.8),
            ]
        case .ocean:
            return [
                theme.color(.info), theme.color(.interactive), theme.color(.info).opacity(0.6),
                theme.color(.interactive).opacity(0.8), theme.color(.info), theme.color(.interactive),
                theme.color(.info).opacity(0.5), theme.color(.interactive).opacity(0.7), theme.color(.info),
            ]
        case .subtle:
            return [
                theme.color(.background), theme.color(.surface), theme.color(.background),
                theme.color(.surface), theme.color(.background), theme.color(.surface),
                theme.color(.background), theme.color(.surface), theme.color(.background),
            ]
        case .custom:
            return Array(repeating: theme.color(.background), count: 9)
        }
    }

    /// Named mesh gradient presets using theme colors.
    public enum MeshPreset: Sendable {
        /// Represents a cool aurora-inspired gradient.
        case aurora
        /// Represents a warm sunset-inspired gradient.
        case sunset
        /// Represents a deep ocean-inspired gradient.
        case ocean
        /// Represents a subtle background-to-surface gradient.
        case subtle
        /// Represents a user-defined custom gradient.
        case custom

        var points: [SIMD2<Float>] {
            [
                SIMD2(0.0, 0.0), SIMD2(0.5, 0.0), SIMD2(1.0, 0.0),
                SIMD2(0.0, 0.5), SIMD2(0.5, 0.5), SIMD2(1.0, 0.5),
                SIMD2(0.0, 1.0), SIMD2(0.5, 1.0), SIMD2(1.0, 1.0),
            ]
        }
    }
}
