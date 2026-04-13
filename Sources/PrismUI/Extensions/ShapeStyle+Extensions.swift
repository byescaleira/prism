//
//  ShapeStyle+Extensions.swift
//  Prism
//
//  Created by Rafael Escaleira on 01/07/25.
//

import SwiftUI

extension ShapeStyle where Self == PrismColor {
    public static var primary: PrismColor { .init(keyPath: \.primary) }
    public static var secondary: PrismColor { .init(keyPath: \.secondary) }
    public static var background: PrismColor { .init(keyPath: \.background) }
    public static var backgroundSecondary: PrismColor { .init(keyPath: \.backgroundSecondary) }
    public static var shadow: PrismColor { .init(keyPath: \.shadow) }
    public static var surface: PrismColor { .init(keyPath: \.surface) }
    public static var text: PrismColor { .init(keyPath: \.text) }
    public static var textSecondary: PrismColor { .init(keyPath: \.textSecondary) }
    public static var border: PrismColor { .init(keyPath: \.border) }
    public static var error: PrismColor { .init(keyPath: \.error) }
    public static var success: PrismColor { .init(keyPath: \.success) }
    public static var warning: PrismColor { .init(keyPath: \.warning) }
    public static var info: PrismColor { .init(keyPath: \.info) }
    public static var disabled: PrismColor { .init(keyPath: \.disabled) }
    public static var hover: PrismColor { .init(keyPath: \.hover) }
    public static var pressed: PrismColor { .init(keyPath: \.pressed) }
    public static var white: PrismColor { .init(keyPath: \.white) }
    public static var black: PrismColor { .init(keyPath: \.black) }

    public static func hex(_ hex: String?) -> PrismColor {
        guard let hex else { return .primary }
        return .init(rawValue: .init(hex: hex))
    }

    public static func color(_ color: Color?) -> PrismColor {
        guard let color else { return .primary }
        return .init(rawValue: color)
    }
}
