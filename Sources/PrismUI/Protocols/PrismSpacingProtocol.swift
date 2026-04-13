//
//  PrismSpacingProtocol.swift
//  Prism
//
//  Created by Rafael Escaleira on 19/04/25.
//

import SwiftUI

public protocol PrismSpacingProtocol: Sendable {
    var none: CGFloat { get }
    var extraSmall: CGFloat { get }
    var small: CGFloat { get }
    var medium: CGFloat { get }
    var large: CGFloat { get }
    var extraLarge: CGFloat { get }
    var ultraLarge: CGFloat { get }
    var section: CGFloat { get }
}
