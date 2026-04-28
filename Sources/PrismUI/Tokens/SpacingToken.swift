import SwiftUI

/// Spacing scale based on a 4pt base grid.
///
/// Use semantic names instead of raw CGFloat values
/// to maintain consistent rhythm across all layouts.
public enum SpacingToken: CGFloat, Sendable, CaseIterable {
    case none = 0
    case xxs = 2
    case xs = 4
    case sm = 8
    case md = 12
    case lg = 16
    case xl = 24
    case xxl = 32
    case xxxl = 48
    case section = 64
}
