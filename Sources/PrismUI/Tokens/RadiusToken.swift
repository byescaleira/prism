import SwiftUI

/// Corner radius tokens using Apple's continuous (squircle) corners.
///
/// All shapes should use `.continuous` corner style
/// to match Apple's design language.
public enum RadiusToken: CGFloat, Sendable, CaseIterable {
    case none = 0
    case xs = 4
    case sm = 8
    case md = 12
    case lg = 16
    case xl = 24
    case full = 9999
}

extension RadiusToken {
    /// A continuous-cornered rounded rectangle using this radius value.
    public var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: rawValue, style: .continuous)
    }

    /// An uneven rounded rectangle suitable for clipping with this radius on all corners.
    public var clipShape: UnevenRoundedRectangle {
        UnevenRoundedRectangle(
            cornerRadii: .init(
                topLeading: rawValue,
                bottomLeading: rawValue,
                bottomTrailing: rawValue,
                topTrailing: rawValue
            ),
            style: .continuous
        )
    }
}
