//
//  RyzeDefaultSpacing.swift
//  Ryze
//
//  Created by Rafael Escaleira on 19/04/25.
//

import SwiftUI

public struct RyzeDefaultSpacing: RyzeSpacingProtocol {
    public var none: CGFloat = .zero
    public var extraSmall: CGFloat
    public var small: CGFloat
    public var medium: CGFloat
    public var large: CGFloat
    public var extraLarge: CGFloat
    public var ultraLarge: CGFloat
    public var section: CGFloat

    public init(
        extraSmall: CGFloat = 4,
        small: CGFloat = 8,
        medium: CGFloat = 16,
        large: CGFloat = 24,
        extraLarge: CGFloat = 32,
        ultraLarge: CGFloat = 48,
        section: CGFloat = 64
    ) {
        self.extraSmall = extraSmall
        self.small = small
        self.medium = medium
        self.large = large
        self.extraLarge = extraLarge
        self.ultraLarge = ultraLarge
        self.section = section
    }
}
