//
//  RyzeGradient.swift
//  Ryze
//
//  Created by Rafael Escaleira on 09/04/26.
//

import SwiftUI

// MARK: - RyzeGradient

public struct RyzeGradient: Sendable {
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

    public static var primary: RyzeGradient {
        RyzeGradient(colors: [.blue, .purple])
    }

    public static var secondary: RyzeGradient {
        RyzeGradient(colors: [.gray, .gray.opacity(0.8)])
    }

    public static var destructive: RyzeGradient {
        RyzeGradient(colors: [.red, .orange])
    }

    public static var success: RyzeGradient {
        RyzeGradient(colors: [.green, .mint])
    }

    public static var warning: RyzeGradient {
        RyzeGradient(colors: [.orange, .yellow])
    }

    public static var info: RyzeGradient {
        RyzeGradient(colors: [.cyan, .blue])
    }

    // MARK: - Linear

    public static func linear(
        _ colors: Color...,
        startPoint: UnitPoint = .top,
        endPoint: UnitPoint = .bottom
    ) -> RyzeGradient {
        RyzeGradient(colors: colors, startPoint: startPoint, endPoint: endPoint)
    }

    // MARK: - Radial

    public static func radial(
        _ colors: Color...,
        center: UnitPoint = .center,
        startRadius: CGFloat = 0,
        endRadius: CGFloat = 1
    ) -> RyzeGradient {
        RyzeGradient(colors: colors)
    }

    // MARK: - Angular

    public static func angular(
        _ colors: Color...,
        center: UnitPoint = .center,
        angle: Angle = .degrees(0)
    ) -> RyzeGradient {
        RyzeGradient(colors: colors)
    }

    // MARK: - Conic

    public static func conic(
        _ colors: Color...,
        center: UnitPoint = .center
    ) -> RyzeGradient {
        RyzeGradient(colors: colors)
    }
}

// MARK: - ShapeStyle Conformance

extension RyzeGradient: ShapeStyle {
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        LinearGradient(
            colors: colors,
            startPoint: startPoint,
            endPoint: endPoint
        )
    }
}
