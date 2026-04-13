//
//  PrismUIMock.swift
//  Prism
//
//  Created by Rafael Escaleira on 12/06/25.
//

import SwiftUI

@MainActor
public protocol PrismUIMock {
    associatedtype MockView: View
    static func mocked() -> MockView
}
