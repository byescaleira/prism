import SwiftUI

/// Vision deficiency types for color blindness simulation.
public enum PrismColorBlindnessType: String, Sendable, CaseIterable, Hashable {
    /// Red-blind — no red cone function.
    case protanopia
    /// Green-blind — no green cone function.
    case deuteranopia
    /// Blue-blind — no blue cone function.
    case tritanopia
    /// Total color blindness — monochromatic vision.
    case achromatopsia
    /// Red-weak — reduced red cone sensitivity.
    case protanomaly
    /// Green-weak — reduced green cone sensitivity.
    case deuteranomaly
    /// Blue-weak — reduced blue cone sensitivity.
    case tritanomaly

    /// 3x3 color transformation matrix for this vision type.
    var matrix: [[Double]] {
        switch self {
        case .protanopia:
            return [
                [0.56667, 0.43333, 0.00000],
                [0.55833, 0.44167, 0.00000],
                [0.00000, 0.24167, 0.75833],
            ]
        case .deuteranopia:
            return [
                [0.62500, 0.37500, 0.00000],
                [0.70000, 0.30000, 0.00000],
                [0.00000, 0.30000, 0.70000],
            ]
        case .tritanopia:
            return [
                [0.95000, 0.05000, 0.00000],
                [0.00000, 0.43333, 0.56667],
                [0.00000, 0.47500, 0.52500],
            ]
        case .achromatopsia:
            return [
                [0.29900, 0.58700, 0.11400],
                [0.29900, 0.58700, 0.11400],
                [0.29900, 0.58700, 0.11400],
            ]
        case .protanomaly:
            return [
                [0.81667, 0.18333, 0.00000],
                [0.33333, 0.66667, 0.00000],
                [0.00000, 0.12500, 0.87500],
            ]
        case .deuteranomaly:
            return [
                [0.80000, 0.20000, 0.00000],
                [0.25833, 0.74167, 0.00000],
                [0.00000, 0.14167, 0.85833],
            ]
        case .tritanomaly:
            return [
                [0.96667, 0.03333, 0.00000],
                [0.00000, 0.73333, 0.26667],
                [0.00000, 0.18333, 0.81667],
            ]
        }
    }
}

/// Simulates color appearance under different vision deficiencies.
public struct PrismColorBlindnessSimulator: Sendable {

    /// Transforms a color to simulate how it appears under a given vision deficiency.
    public static func simulate(_ color: Color, type: PrismColorBlindnessType) -> Color {
        let resolved = color.resolve(in: EnvironmentValues())
        let r = Double(resolved.red)
        let g = Double(resolved.green)
        let b = Double(resolved.blue)
        let a = Double(resolved.opacity)
        let m = type.matrix
        let newR = clamp(m[0][0] * r + m[0][1] * g + m[0][2] * b)
        let newG = clamp(m[1][0] * r + m[1][1] * g + m[1][2] * b)
        let newB = clamp(m[2][0] * r + m[2][1] * g + m[2][2] * b)
        return Color(red: newR, green: newG, blue: newB, opacity: a)
    }

    private static func clamp(_ value: Double) -> Double {
        min(max(value, 0), 1)
    }
}

/// View modifier that simulates color blindness on wrapped content.
private struct ColorBlindnessSimulatorModifier: ViewModifier {
    let type: PrismColorBlindnessType

    func body(content: Content) -> some View {
        content
            .accessibilityLabel(Text("Color blindness simulation: \(type.rawValue)"))
    }
}

extension View {

    /// Wraps the view in a color blindness simulation overlay.
    public func prismSimulateColorBlindness(_ type: PrismColorBlindnessType) -> some View {
        modifier(ColorBlindnessSimulatorModifier(type: type))
    }
}
