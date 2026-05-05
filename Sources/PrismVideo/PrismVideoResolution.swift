//
//  PrismVideoResolution.swift
//  Prism
//
//  Created by Rafael Escaleira on 22/07/25.
//

import PrismFoundation

/// Supported video resolutions.
public enum PrismVideoResolution: Int, PrismEntity, Sendable {
    /// 2160p Ultra HD resolution.
    case _4K
    /// 1080p Full HD resolution.
    case fullHD
    /// 720p HD resolution.
    case HD
    /// Standard definition resolution (below 720p).
    case SD

    /// The string identifier for this resolution, derived from its raw value.
    public var id: String { rawValue }
    /// A human-readable label for the resolution (e.g. "1080p HD").
    public var rawValue: String {
        switch self {
        case ._4K: return "4K"
        case .fullHD: return "1080p HD"
        case .HD: return "720p HD"
        case .SD: return "SD"
        }
    }

    /// Creates a resolution from a pixel-height value, mapping to the closest standard tier.
    public init?(rawValue: Int) {
        switch rawValue {
        case 0..<720: self = .SD
        case 720..<1080: self = .HD
        case 1080..<2160: self = .fullHD
        default: self = ._4K
        }
    }
}
