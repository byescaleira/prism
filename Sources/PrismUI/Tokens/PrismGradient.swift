//
//  PrismGradient.swift
//  Prism
//
//  Created by Rafael Escaleira on 09/04/26.
//

import SwiftUI

// MARK: - PrismGradient

public struct PrismGradient: Sendable {
    private let colors: [Color]
    private let startPoint: UnitPoint
    private let endPoint: UnitPoint

    public init(
        colors: [Color],
        startPoint: UnitPoint = .top,
        endPoint: UnitPoint = .bottom
    ) {
        self.colors = colors
        self.startPoint = startPoint
        self.endPoint = startPoint
    }

    // MARK: - Presets

    public static var primary: PrismGradient {
        PrismGradient(colors: [.blue, .purple])
    }

    public static var secondary: PrismGradient {
        PrismGradient(colors: [.gray, .gray.opacity(0.8)])
    }

    public static var destructive: PrismGradient {
        PrismGradient(colors: [.red, .orange])
    }

    public static var success: PrismGradient {
        PrismGradient(colors: [.green, .mint])
    }

    public static var warning: PrismGradient {
        PrismGradient(colors: [.orange, .yellow])
    }

    public static var info: PrismGradient {
        PrismGradient(colors: [.cyan, .blue])
    }

    // MARK: - Linear

    public static func linear(
        _ colors: Color...,
        startPoint: UnitPoint = .top,
        endPoint: UnitPoint = .bottom
    ) -> PrismGradient {
        PrismGradient(colors: colors, startPoint: startPoint, endPoint: endPoint)
    }

    // MARK: - Radial

    public static func radial(
        _ colors: Color...,
        center: UnitPoint = .center,
        startRadius: CGFloat = 0,
        endRadius: CGFloat = 1
    ) -> PrismGradient {
        PrismGradient(colors: colors)
    }

    // MARK: - Angular

    public static func angular(
        _ colors: Color...,
        center: UnitPoint = .center,
        angle: Angle = .degrees(0)
    ) -> PrismGradient {
        PrismGradient(colors: colors)
    }

    // MARK: - Conic

    public static func conic(
        _ colors: Color...,
        center: UnitPoint = .center
    ) -> PrismGradient {
        PrismGradient(colors: colors)
    }
}

// MARK: - ShapeStyle Conformance

extension PrismGradient: ShapeStyle {
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        LinearGradient(
            colors: colors,
            startPoint: startPoint,
            endPoint: endPoint
        )
    }
}
