//
//  PrismColor.swift
//  Prism
//
//  Created by Rafael Escaleira on 01/07/25.
//

import PrismFoundation
import SwiftUI

public struct PrismColor: ShapeStyle, @unchecked Sendable {
    private enum Storage {
        case themed(KeyPath<PrismColorProtocol, Color>)
        case custom(Color)
    }

    private let storage: Storage

    init(keyPath: KeyPath<PrismColorProtocol, Color>) {
        self.storage = .themed(keyPath)
    }

    public init(rawValue: Color) {
        self.storage = .custom(rawValue)
    }

    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        switch storage {
        case .themed(let keyPath):
            return environment.theme.color[keyPath: keyPath]
        case .custom(let color):
            return color
        }
    }

    public func color(using theme: PrismColorProtocol) -> Color {
        switch storage {
        case .themed(let keyPath):
            return theme[keyPath: keyPath]
        case .custom(let color):
            return color
        }
    }
}
