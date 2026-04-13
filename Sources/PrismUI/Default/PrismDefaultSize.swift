//
//  PrismDefaultSize.swift
//  Prism
//
//  Created by Rafael Escaleira on 06/06/25.
//

import SwiftUI

public struct PrismDefaultSize: PrismSizeProtocol {
    public var ultraSmall: CGFloat
    public var ultraSmall2: CGFloat
    public var extraSmall: CGFloat
    public var extraSmall2: CGFloat
    public var small: CGFloat
    public var small2: CGFloat
    public var medium: CGFloat
    public var medium2: CGFloat
    public var large: CGFloat
    public var large2: CGFloat
    public var extraLarge: CGFloat
    public var extraLarge2: CGFloat
    public var ultraLarge: CGFloat
    public var max: CGFloat

    public init(
        ultraSmall: CGFloat = 12,
        ultraSmall2: CGFloat = 16,
        extraSmall: CGFloat = 24,
        extraSmall2: CGFloat = 36,
        small: CGFloat = 56,
        small2: CGFloat = 72,
        medium: CGFloat = 96,
        medium2: CGFloat = 120,
        large: CGFloat = 144,
        large2: CGFloat = 176,
        extraLarge: CGFloat = 208,
        extraLarge2: CGFloat = 232,
        ultraLarge: CGFloat = 256,
        max: CGFloat = .infinity
    ) {
        self.ultraSmall = ultraSmall
        self.ultraSmall2 = ultraSmall2
        self.extraSmall = extraSmall
        self.extraSmall2 = extraSmall2
        self.small = small
        self.small2 = small2
        self.medium = medium
        self.medium2 = medium2
        self.large = large
        self.large2 = large2
        self.extraLarge = extraLarge
        self.extraLarge2 = extraLarge2
        self.ultraLarge = ultraLarge
        self.max = max
    }
}
