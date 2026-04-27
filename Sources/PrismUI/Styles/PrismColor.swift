//
//  PrismColor.swift
//  Prism
//
//  Created by Rafael Escaleira on 01/07/25.
//

import PrismFoundation
import SwiftUI

/// Semantic design system color as ShapeStyle.
///
/// Thread-safe: `storage` is immutable after init — `KeyPath` and `Color` are value types.
public struct PrismColor: ShapeStyle, @unchecked Sendable {
    private enum Storage {
        case themed(KeyPath<PrismColorProtocol, Color>)
        case custom(Color)
    }

    private let storage: Storage

    init(keyPath: KeyPath<PrismColorProtocol, Color>) {
        self.storage = .themed(keyPath)
    }

    /// Creates a color from a fixed `Color` value, bypassing theme resolution.
    public init(rawValue: Color) {
        self.storage = .custom(rawValue)
    }

    /// Resolves this semantic color into a concrete `Color` using the current environment's theme.
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        switch storage {
        case .themed(let keyPath):
            return environment.theme.color[keyPath: keyPath]
        case .custom(let color):
            return color
        }
    }

    /// Returns the resolved `Color` for the given theme color protocol.
    public func color(using theme: PrismColorProtocol) -> Color {
        switch storage {
        case .themed(let keyPath):
            return theme[keyPath: keyPath]
        case .custom(let color):
            return color
        }
    }
}
