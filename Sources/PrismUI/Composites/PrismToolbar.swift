import SwiftUI

/// Contextual toolbar with themed action items.
public struct PrismToolbar: ViewModifier {
    private let leading: [ToolbarItem]
    private let trailing: [ToolbarItem]
    private let title: LocalizedStringKey?

    public init(
        title: LocalizedStringKey? = nil,
        leading: [ToolbarItem] = [],
        trailing: [ToolbarItem] = []
    ) {
        self.title = title
        self.leading = leading
        self.trailing = trailing
    }

    public func body(content: Content) -> some View {
        content
            .toolbar {
                if let title {
                    ToolbarItemGroup(placement: .principal) {
                        Text(title)
                            .font(TypographyToken.headline.font)
                    }
                }

                if !leading.isEmpty {
                    ToolbarItemGroup(placement: .cancellationAction) {
                        ForEach(Array(leading.enumerated()), id: \.offset) { _, item in
                            toolbarButton(item)
                        }
                    }
                }

                if !trailing.isEmpty {
                    ToolbarItemGroup(placement: .primaryAction) {
                        ForEach(Array(trailing.enumerated()), id: \.offset) { _, item in
                            toolbarButton(item)
                        }
                    }
                }
            }
    }

    @ViewBuilder
    private func toolbarButton(_ item: ToolbarItem) -> some View {
        Button(action: item.action) {
            if let icon = item.icon {
                Label(item.title, systemImage: icon)
            } else {
                Text(item.title)
            }
        }
        .accessibilityLabel(item.title)
    }
}

// MARK: - ToolbarItem

extension PrismToolbar {

    public struct ToolbarItem: @unchecked Sendable {
        let title: LocalizedStringKey
        let icon: String?
        let action: @MainActor @Sendable () -> Void

        public init(
            _ title: LocalizedStringKey,
            icon: String? = nil,
            action: @escaping @MainActor @Sendable () -> Void
        ) {
            self.title = title
            self.icon = icon
            self.action = action
        }
    }
}

extension View {

    /// Applies a themed toolbar with leading and trailing items.
    public func prismToolbar(
        title: LocalizedStringKey? = nil,
        leading: [PrismToolbar.ToolbarItem] = [],
        trailing: [PrismToolbar.ToolbarItem] = []
    ) -> some View {
        modifier(PrismToolbar(title: title, leading: leading, trailing: trailing))
    }
}
