import SwiftUI

/// Fixed-size spacer using spacing tokens.
public struct PrismSpacer: View {
    private let token: SpacingToken
    private let axis: Axis?

    /// Creates a spacer with a spacing token and optional axis constraint.
    public init(_ token: SpacingToken = .md, axis: Axis? = nil) {
        self.token = token
        self.axis = axis
    }

    /// The content and behavior of the spacer.
    public var body: some View {
        switch axis {
        case .horizontal:
            Spacer()
                .frame(width: token.rawValue)
        case .vertical:
            Spacer()
                .frame(height: token.rawValue)
        case nil:
            Spacer()
                .frame(width: token.rawValue, height: token.rawValue)
        }
    }
}
