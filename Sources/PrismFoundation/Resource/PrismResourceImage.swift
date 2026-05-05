//
//  PrismResourceImage.swift
//  Prism
//
//  Created by Rafael Escaleira on 14/07/25.
//

import SwiftUI

/// A protocol for asset catalog image resources.
public protocol PrismResourceImage {
    /// The SwiftUI image loaded from the asset catalog.
    var image: Image { get }
}
