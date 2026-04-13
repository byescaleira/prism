//
//  PrismView.swift
//  Prism
//
//  Created by Rafael Escaleira on 12/06/25.
//

import SwiftUI

public protocol PrismView: View, PrismUIMock {
    var accessibility: PrismAccessibilityProperties? { get }
    var canAppear: Bool { get }
}

extension PrismView {
    public var accessibility: PrismAccessibilityProperties? { nil }
    public var canAppear: Bool { true }
}
