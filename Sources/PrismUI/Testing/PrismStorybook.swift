import SwiftUI

/// Interactive Storybook-style component explorer with live controls.
///
/// Each component gets a dedicated page with toggleable props,
/// theme switching, and accessibility overrides.
///
/// ```swift
/// #if DEBUG
/// PrismStorybook()
/// #endif
/// ```
@MainActor
public struct PrismStorybook: View {
    @State private var selectedStory: Story?
    @State private var isDarkMode = false
    @State private var isLargeText = false
    @State private var selectedTheme: ThemeChoice = .default

    public init() {}

    public var body: some View {
        NavigationSplitView {
            sidebar
        } detail: {
            if let story = selectedStory {
                storyDetail(story)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "rectangle.dashed")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text("Select a Component")
                        .font(.title2)
                    Text("Choose from the sidebar")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .dynamicTypeSize(isLargeText ? .xxxLarge : .medium)
    }

    @ViewBuilder
    private var sidebar: some View {
        List(selection: $selectedStory) {
            Section("Controls") {
                Toggle("Dark Mode", isOn: $isDarkMode)
                Toggle("Large Text", isOn: $isLargeText)
                Picker("Theme", selection: $selectedTheme) {
                    ForEach(ThemeChoice.allCases, id: \.self) { choice in
                        Text(choice.rawValue).tag(choice)
                    }
                }
            }

            ForEach(StoryCategory.allCases, id: \.self) { category in
                Section(category.rawValue) {
                    ForEach(category.stories, id: \.self) { story in
                        Label(story.name, systemImage: story.icon)
                            .tag(story)
                    }
                }
            }
        }
        .navigationTitle("Storybook")
        #if os(iOS) || os(visionOS)
        .listStyle(.insetGrouped)
        #else
        .listStyle(.sidebar)
        #endif
    }

    @ViewBuilder
    private func storyDetail(_ story: Story) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SpacingToken.lg.rawValue) {
                Text(story.name)
                    .font(TypographyToken.largeTitle.font)
                Text(story.description)
                    .font(TypographyToken.body.font)
                    .foregroundStyle(.secondary)

                Divider()

                story.content()
            }
            .padding(SpacingToken.xl.rawValue)
        }
        .environment(\.prismTheme, selectedTheme.theme)
    }
}

// MARK: - Data Model

extension PrismStorybook {

    enum ThemeChoice: String, CaseIterable, Sendable {
        case `default` = "Default"
        case dark = "Dark"
        case highContrast = "High Contrast"

        @MainActor var theme: any PrismTheme {
            switch self {
            case .default: DefaultTheme()
            case .dark: DarkTheme()
            case .highContrast: HighContrastTheme()
            }
        }
    }

    struct Story: Hashable, Identifiable, @unchecked Sendable {
        let id: String
        let name: String
        let icon: String
        let description: String
        let content: @MainActor () -> AnyView

        static func == (lhs: Story, rhs: Story) -> Bool { lhs.id == rhs.id }
        func hash(into hasher: inout Hasher) { hasher.combine(id) }
    }

    enum StoryCategory: String, CaseIterable, Sendable {
        case buttons = "Buttons"
        case inputs = "Inputs"
        case feedback = "Feedback"
        case layout = "Layout"
        case data = "Data Display"

        var stories: [Story] {
            switch self {
            case .buttons: Self.buttonStories
            case .inputs: Self.inputStories
            case .feedback: Self.feedbackStories
            case .layout: Self.layoutStories
            case .data: Self.dataStories
            }
        }

        static let buttonStories: [Story] = [
            Story(id: "button-filled", name: "Button (Variants)", icon: "hand.tap.fill", description: "Primary action button variants.") {
                AnyView(VStack(spacing: 12) {
                    PrismButton("Filled", variant: .filled) {}
                    PrismButton("Tinted", variant: .tinted) {}
                    PrismButton("Bordered", variant: .bordered) {}
                    PrismButton("Plain", variant: .plain) {}
                })
            },
        ]

        static let inputStories: [Story] = [
            Story(id: "textfield", name: "TextField", icon: "textformat", description: "Themed text input.") {
                AnyView(VStack(spacing: 12) {
                    PrismTextField("Email", text: .constant("user@example.com"))
                    PrismTextField("Empty", text: .constant(""))
                })
            },
            Story(id: "toggle", name: "Toggle", icon: "switch.2", description: "Themed toggle switch.") {
                AnyView(VStack(spacing: 12) {
                    PrismToggle("Notifications", isOn: .constant(true))
                    PrismToggle("Dark Mode", isOn: .constant(false))
                })
            },
            Story(id: "slider", name: "Slider", icon: "slider.horizontal.3", description: "Themed range slider.") {
                AnyView(PrismSlider("Volume", value: .constant(0.6)))
            },
        ]

        static let feedbackStories: [Story] = [
            Story(id: "loading", name: "Loading State", icon: "progress.indicator", description: "Loading spinner with label.") {
                AnyView(VStack(spacing: 16) {
                    PrismLoadingState(.loading)
                    PrismLoadingState(.empty(title: "No Items", message: nil, icon: "tray"))
                })
            },
            Story(id: "banner", name: "Banner", icon: "flag", description: "Themed alert banner.") {
                AnyView(VStack(spacing: 12) {
                    PrismBanner("Info message", style: .info)
                    PrismBanner("Success!", style: .success)
                    PrismBanner("Warning", style: .warning)
                    PrismBanner("Error occurred", style: .error)
                })
            },
        ]

        static let layoutStories: [Story] = [
            Story(id: "card", name: "Card", icon: "rectangle", description: "Surface container with elevation.") {
                AnyView(VStack(spacing: 16) {
                    PrismCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Card Title").font(TypographyToken.headline.font)
                            Text("Card description goes here.").font(TypographyToken.body.font)
                        }
                        .padding()
                    }
                })
            },
            Story(id: "divider", name: "Divider", icon: "minus", description: "Themed separator.") {
                AnyView(VStack(spacing: 16) {
                    Text("Above")
                    PrismDivider()
                    Text("Below")
                })
            },
        ]

        static let dataStories: [Story] = [
            Story(id: "tag", name: "Tag", icon: "tag", description: "Labeled tag with semantic colors.") {
                AnyView(HStack(spacing: 8) {
                    PrismTag("Default")
                    PrismTag("Info", style: .info)
                    PrismTag("Success", style: .success)
                    PrismTag("Warning", style: .warning)
                    PrismTag("Error", style: .error)
                })
            },
            Story(id: "avatar", name: "Avatar", icon: "person.circle", description: "Image/initials with status.") {
                AnyView(HStack(spacing: 16) {
                    PrismAvatar(initials: "AB", size: .small)
                    PrismAvatar(initials: "CD", size: .medium, status: .online)
                    PrismAvatar(initials: "EF", size: .large, status: .busy)
                })
            },
        ]
    }
}
