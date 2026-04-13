//
//  RyzeView.swift
//  Ryze
//
//  Created by Rafael Escaleira on 12/06/25.
//

import SwiftUI

public protocol RyzeView: View, RyzeUIMock {
    var accessibility: RyzeAccessibilityProperties? { get }
    var canAppear: Bool { get }
}

extension RyzeView {
    public var accessibility: RyzeAccessibilityProperties? { nil }
    public var canAppear: Bool { true }
}
