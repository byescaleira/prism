import SwiftUI

/// Represents a single screen in a prototype flow.
public struct PrismPrototypeScreen: Identifiable, @unchecked Sendable {
    /// Unique identifier for this screen.
    public let id: String
    /// Human-readable screen name.
    public let name: String
    /// View builders for the screen content.
    public let views: [AnyView]

    /// Creates a prototype screen with the given name and views.
    @MainActor
    public init(id: String = UUID().uuidString, name: String, views: [AnyView] = []) {
        self.id = id
        self.name = name
        self.views = views
    }
}

/// Links prototype screens together into a navigable flow with directional arrows.
public struct PrismPrototypeFlow: View {
    let screens: [PrismPrototypeScreen]

    /// Creates a flow visualization from the given screens.
    public init(screens: [PrismPrototypeScreen]) {
        self.screens = screens
    }

    /// The prototype flow view body with horizontal scroll and navigation arrows.
    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: SpacingToken.lg.rawValue) {
                ForEach(Array(screens.enumerated()), id: \.element.id) { index, screen in
                    HStack(spacing: SpacingToken.sm.rawValue) {
                        screenCard(screen)

                        if index < screens.count - 1 {
                            Image(systemName: "arrow.right")
                                .font(TypographyToken.title3.font)
                                .foregroundStyle(.secondary)
                                .accessibilityLabel("navigates to next screen")
                        }
                    }
                }
            }
            .padding(SpacingToken.lg.rawValue)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Prototype flow with \(screens.count) screens")
    }

    @ViewBuilder
    private func screenCard(_ screen: PrismPrototypeScreen) -> some View {
        VStack(spacing: SpacingToken.sm.rawValue) {
            RoundedRectangle(cornerRadius: RadiusToken.md.rawValue)
                .fill(.quaternary)
                .frame(width: 120, height: 200)
                .overlay(
                    VStack {
                        ForEach(0..<screen.views.count, id: \.self) { idx in
                            screen.views[idx]
                        }
                    }
                )
                .accessibilityHidden(true)

            Text(screen.name)
                .font(TypographyToken.caption.font)
                .lineLimit(1)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Screen: \(screen.name)")
    }
}

/// Interactive screen builder for rapid prototyping.
@MainActor
public struct PrismPrototyper: View {
    @State private var screens: [PrismPrototypeScreen]
    @State private var selectedScreenID: String?

    /// Creates a prototyper with optional initial screens.
    public init(screens: [PrismPrototypeScreen] = []) {
        _screens = State(initialValue: screens)
    }

    /// The prototyper view body with flow visualization and screen management.
    public var body: some View {
        NavigationStack {
            prototyperContent
                .navigationTitle("Prototyper")
                .toolbar { prototyperToolbar }
        }
    }

    @ViewBuilder
    private var prototyperContent: some View {
        VStack(spacing: 0) {
            if !screens.isEmpty {
                PrismPrototypeFlow(screens: screens)
                    .frame(height: 280)
                Divider()
            }
            screenList
        }
    }

    @ViewBuilder
    private var screenList: some View {
        List {
            Section("Screens (\(screens.count))") {
                ForEach(screens) { screen in
                    screenRow(screen)
                }
                .onDelete { indexSet in
                    screens.remove(atOffsets: indexSet)
                }
                .onMove { from, to in
                    screens.move(fromOffsets: from, toOffset: to)
                }
            }
        }
        #if os(iOS) || os(visionOS)
            .listStyle(.insetGrouped)
        #endif
    }

    @ViewBuilder
    private func screenRow(_ screen: PrismPrototypeScreen) -> some View {
        let isSelected = selectedScreenID == screen.id
        Button {
            selectedScreenID = screen.id
        } label: {
            HStack {
                Text(screen.name)
                    .font(TypographyToken.body.font)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(Color.accentColor)
                }
            }
        }
        .accessibilityLabel("Select \(screen.name)")
    }

    @ToolbarContentBuilder
    private var prototyperToolbar: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button {
                addScreen()
            } label: {
                Image(systemName: "plus")
            }
            .accessibilityLabel("Add screen")
        }
        #if os(iOS) || os(visionOS)
            ToolbarItem(placement: .automatic) {
                EditButton()
                    .accessibilityLabel("Reorder screens")
            }
        #endif
    }

    private func addScreen() {
        let index = screens.count + 1
        let screen = PrismPrototypeScreen(name: "Screen \(index)")
        screens.append(screen)
    }
}
