//
//  PrismRoutable.swift
//  Prism
//
//  Created by Rafael Escaleira on 03/04/25.
//

public protocol PrismRoutable: Hashable, Identifiable, Sendable {}

extension PrismRoutable {
    public var id: Self {
        self
    }
}
