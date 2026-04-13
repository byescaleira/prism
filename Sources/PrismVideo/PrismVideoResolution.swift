//
//  PrismVideoResolution.swift
//  Prism
//
//  Created by Rafael Escaleira on 22/07/25.
//

import PrismFoundation

public enum PrismVideoResolution: Int, PrismEntity {
    case _4K
    case fullHD
    case HD
    case SD

    public var id: String { rawValue }
    public var rawValue: String {
        switch self {
        case ._4K: return "4K"
        case .fullHD: return "1080p HD"
        case .HD: return "720p HD"
        case .SD: return "SD"
        }
    }

    public init?(rawValue: Int) {
        switch rawValue {
        case 0..<720: self = .SD
        case 720..<1080: self = .HD
        case 1080..<2160: self = .fullHD
        default: self = ._4K
        }
    }
}
