//
//  PrismSizeProtocol.swift
//  Prism
//
//  Created by Rafael Escaleira on 06/06/25.
//

import SwiftUI

public protocol PrismSizeProtocol: Sendable {
    var ultraSmall: CGFloat { get }
    var ultraSmall2: CGFloat { get }
    var extraSmall: CGFloat { get }
    var extraSmall2: CGFloat { get }
    var small: CGFloat { get }
    var small2: CGFloat { get }
    var medium: CGFloat { get }
    var medium2: CGFloat { get }
    var large: CGFloat { get }
    var large2: CGFloat { get }
    var extraLarge: CGFloat { get }
    var extraLarge2: CGFloat { get }
    var ultraLarge: CGFloat { get }
    var max: CGFloat { get }
}
