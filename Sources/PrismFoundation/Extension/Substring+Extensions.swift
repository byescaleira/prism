//
//  Substring+Extensions.swift
//  Prism
//
//  Created by Rafael Escaleira on 27/08/25.
//

import Foundation

extension Substring {
    public var string: String {
        String(self)
    }

    public var int: Int? {
        Int(self)
    }

    public var double: Double? {
        Double(self)
    }
}
