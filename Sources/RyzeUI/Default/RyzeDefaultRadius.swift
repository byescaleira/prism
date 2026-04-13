//
//  RyzeDefaultRadius.swift
//  Ryze
//
//  Created by Rafael Escaleira on 19/04/25.
//

import SwiftUI

public struct RyzeDefaultRadius: RyzeRadiusProtocol {
    public var none: CGFloat
    public var small: CGFloat
    public var medium: CGFloat
    public var large: CGFloat
    public var extraLarge: CGFloat
    public var circle: CGFloat

    public init(
        none: CGFloat = .zero,
        small: CGFloat = 4,
        medium: CGFloat = 8,
        large: CGFloat = 16,
        extraLarge: CGFloat = 24,
        circle: CGFloat = .infinity
    ) {
        self.none = none
        self.small = small
        self.medium = medium
        self.large = large
        self.extraLarge = extraLarge
        self.circle = circle
    }
}
