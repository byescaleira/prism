import SwiftUI

/// Named label style presets.
public enum PrismLabelStyle: Sendable {
    /// Represents the platform-default label style.
    case automatic
    /// Represents a label style showing only the icon.
    case iconOnly
    /// Represents a label style showing only the title.
    case titleOnly
    /// Represents a label style showing both title and icon.
    case titleAndIcon
}

extension View {

    /// Applies a named label style.
    @ViewBuilder
    public func prismLabelStyle(_ style: PrismLabelStyle) -> some View {
        switch style {
        case .automatic:
            self.labelStyle(.automatic)
        case .iconOnly:
            self.labelStyle(.iconOnly)
        case .titleOnly:
            self.labelStyle(.titleOnly)
        case .titleAndIcon:
            self.labelStyle(.titleAndIcon)
        }
    }
}
