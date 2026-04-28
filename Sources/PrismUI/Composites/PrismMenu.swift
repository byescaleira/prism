import SwiftUI

/// Themed context menu with sections, icons, and destructive actions.
public struct PrismMenu<Label: View>: View {
    private let label: Label
    private let items: [MenuItem]

    public init(
        items: [MenuItem],
        @ViewBuilder label: () -> Label
    ) {
        self.items = items
        self.label = label()
    }

    public init(
        _ title: LocalizedStringKey,
        items: [MenuItem]
    ) where Label == SwiftUI.Label<Text, Image> {
        self.items = items
        self.label = SwiftUI.Label(title, systemImage: "ellipsis.circle")
    }

    public var body: some View {
        Menu {
            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                leafItem(item)
            }
        } label: {
            label
        }
        .menuStyle(.borderlessButton)
    }

    @ViewBuilder
    private func leafItem(_ item: MenuItem) -> some View {
        switch item {
        case .button(let title, let icon, let role, let action):
            Button(role: role) {
                action()
            } label: {
                if let icon {
                    SwiftUI.Label(title, systemImage: icon)
                } else {
                    Text(title)
                }
            }

        case .section(let title, let sectionItems):
            Section(title) {
                ForEach(Array(sectionItems.enumerated()), id: \.offset) { _, subItem in
                    if case .button(let t, let i, let r, let a) = subItem {
                        Button(role: r) { a() } label: {
                            if let i {
                                SwiftUI.Label(t, systemImage: i)
                            } else {
                                Text(t)
                            }
                        }
                    }
                }
            }

        case .divider:
            Divider()

        case .picker(let title, let selection, let options):
            Picker(title, selection: selection) {
                ForEach(Array(options.enumerated()), id: \.offset) { _, option in
                    Text(option).tag(option)
                }
            }
        }
    }
}

// MARK: - Menu Item

extension PrismMenu {

    public enum MenuItem {
        case button(LocalizedStringKey, icon: String? = nil, role: ButtonRole? = nil, action: () -> Void)
        case section(LocalizedStringKey, items: [MenuItem])
        case divider
        case picker(LocalizedStringKey, selection: Binding<String>, options: [String])

        public static func destructive(
            _ title: LocalizedStringKey,
            icon: String? = nil,
            action: @escaping () -> Void
        ) -> MenuItem {
            .button(title, icon: icon, role: .destructive, action: action)
        }
    }
}
