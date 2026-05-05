import SwiftUI

/// Developer tool that lists all PrismUI components with live previews and toggles.
///
/// Not a demo app — a debugging/review tool for development builds.
///
/// ```swift
/// #if DEBUG
/// PrismComponentBrowser()
/// #endif
/// ```
public struct PrismComponentBrowser: View {
    @Environment(\.prismTheme) private var theme
    @State private var searchText = ""
    @State private var selectedCategory: ComponentCategory?

    /// Creates a component browser instance.
    public init() {}

    /// The view body.
    public var body: some View {
        NavigationStack {
            List {
                ForEach(filteredCategories, id: \.self) { category in
                    Section(category.rawValue) {
                        ForEach(category.components, id: \.name) { component in
                            NavigationLink(value: component) {
                                HStack(spacing: SpacingToken.md.rawValue) {
                                    Image(systemName: component.icon)
                                        .font(.system(size: 16))
                                        .foregroundStyle(theme.color(.interactive))
                                        .frame(width: 28)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(component.name)
                                            .font(TypographyToken.body.font(weight: .medium))
                                        Text(component.summary)
                                            .font(TypographyToken.caption.font)
                                            .foregroundStyle(theme.color(.onBackgroundSecondary))
                                    }
                                }
                            }
                        }
                    }
                }
            }
            #if os(iOS) || os(visionOS)
                .listStyle(.insetGrouped)
            #else
                .listStyle(.sidebar)
            #endif
            .searchable(text: $searchText, prompt: "Search components")
            .navigationTitle("Component Browser")
            .navigationDestination(for: ComponentEntry.self) { entry in
                ComponentDetailView(entry: entry)
            }
        }
    }

    private var filteredCategories: [ComponentCategory] {
        if searchText.isEmpty {
            return ComponentCategory.allCases
        }
        let query = searchText.lowercased()
        return ComponentCategory.allCases.filter { category in
            category.components.contains { $0.name.lowercased().contains(query) }
        }
    }
}

// MARK: - Data

enum ComponentCategory: String, CaseIterable, Sendable {
    case primitives = "Primitives"
    case composites = "Composites"
    case forms = "Forms"
    case layout = "Layout"
    case navigation = "Navigation"
    case feedback = "Feedback"
    case dataDisplay = "Data Display"

    var components: [ComponentEntry] {
        switch self {
        case .primitives:
            return [
                ComponentEntry(name: "PrismButton", icon: "hand.tap", summary: "Themed button with variants"),
                ComponentEntry(name: "PrismIcon", icon: "star", summary: "SF Symbol with token styling"),
                ComponentEntry(name: "PrismCard", icon: "rectangle", summary: "Surface container with elevation"),
                ComponentEntry(name: "PrismTag", icon: "tag", summary: "Labeled tag with semantic colors"),
                ComponentEntry(name: "PrismChip", icon: "capsule", summary: "Selectable chip with toggle"),
                ComponentEntry(name: "PrismAvatar", icon: "person.circle", summary: "Image/initials with status"),
                ComponentEntry(name: "PrismDivider", icon: "minus", summary: "Themed separator"),
            ]
        case .composites:
            return [
                ComponentEntry(
                    name: "PrismAlert", icon: "exclamationmark.triangle", summary: "Alert dialog with actions"),
                ComponentEntry(name: "PrismBanner", icon: "flag", summary: "Dismissable banner"),
                ComponentEntry(name: "PrismToast", icon: "bubble.left", summary: "Auto-dismissing notification"),
                ComponentEntry(
                    name: "PrismBottomSheet", icon: "rectangle.bottomhalf.filled", summary: "Draggable sheet"),
                ComponentEntry(name: "PrismTooltip", icon: "text.bubble", summary: "Contextual info popup"),
                ComponentEntry(name: "PrismMenu", icon: "ellipsis.circle", summary: "Context menu"),
                ComponentEntry(name: "PrismEmptyState", icon: "tray", summary: "Placeholder for empty views"),
                ComponentEntry(name: "PrismSearchBar", icon: "magnifyingglass", summary: "Themed search field"),
            ]
        case .forms:
            return [
                ComponentEntry(name: "PrismTextField", icon: "textformat", summary: "Themed text input"),
                ComponentEntry(name: "PrismTextArea", icon: "doc.text", summary: "Multi-line text editor"),
                ComponentEntry(name: "PrismToggle", icon: "switch.2", summary: "Toggle with label"),
                ComponentEntry(name: "PrismPicker", icon: "list.bullet", summary: "Selection picker"),
                ComponentEntry(name: "PrismSlider", icon: "slider.horizontal.3", summary: "Range slider"),
                ComponentEntry(name: "PrismStepper", icon: "plus.forwardslash.minus", summary: "Increment/decrement"),
                ComponentEntry(name: "PrismRating", icon: "star.fill", summary: "Star rating input"),
                ComponentEntry(name: "PrismPinField", icon: "number", summary: "OTP/PIN entry"),
                ComponentEntry(name: "PrismColorWell", icon: "paintpalette", summary: "Color picker with swatches"),
            ]
        case .layout:
            return [
                ComponentEntry(name: "PrismGrid", icon: "square.grid.2x2", summary: "Adaptive grid layout"),
                ComponentEntry(name: "PrismSection", icon: "rectangle.split.3x1", summary: "Themed section container"),
                ComponentEntry(name: "PrismScaffold", icon: "sidebar.left", summary: "Page scaffolding"),
                ComponentEntry(name: "PrismSpacer", icon: "arrow.up.and.down", summary: "Token-based spacing"),
            ]
        case .navigation:
            return [
                ComponentEntry(name: "PrismNavigationView", icon: "sidebar.left", summary: "Split navigation"),
                ComponentEntry(name: "PrismTabView", icon: "square.stack", summary: "Tab bar navigation"),
            ]
        case .feedback:
            return [
                ComponentEntry(name: "PrismLoadingState", icon: "progress.indicator", summary: "Loading spinner"),
                ComponentEntry(name: "PrismProgressBar", icon: "chart.bar", summary: "Progress indicator"),
                ComponentEntry(name: "PrismCountdownTimer", icon: "timer", summary: "Circular countdown"),
            ]
        case .dataDisplay:
            return [
                ComponentEntry(name: "PrismRow", icon: "list.dash", summary: "List row with icon"),
                ComponentEntry(name: "PrismList", icon: "list.bullet.rectangle", summary: "Themed list"),
                ComponentEntry(name: "PrismBadge", icon: "seal", summary: "Count/status badge"),
            ]
        }
    }
}

struct ComponentEntry: Hashable, Sendable {
    let name: String
    let icon: String
    let summary: String
}

// MARK: - Detail View

private struct ComponentDetailView: View {
    @Environment(\.prismTheme) private var theme
    let entry: ComponentEntry
    @State private var isDarkMode = false
    @State private var isLargeText = false
    @State private var isDisabled = false

    var body: some View {
        ScrollView {
            VStack(spacing: SpacingToken.lg.rawValue) {
                togglesSection

                previewSection
            }
            .padding(SpacingToken.lg.rawValue)
        }
        .navigationTitle(entry.name)
    }

    @ViewBuilder
    private var togglesSection: some View {
        VStack(spacing: SpacingToken.sm.rawValue) {
            Toggle("Dark Mode", isOn: $isDarkMode)
            Toggle("Large Text", isOn: $isLargeText)
            Toggle("Disabled", isOn: $isDisabled)
        }
        .padding(SpacingToken.md.rawValue)
        .background(theme.color(.surface), in: RadiusToken.md.shape)
    }

    @ViewBuilder
    private var previewSection: some View {
        VStack(alignment: .leading, spacing: SpacingToken.sm.rawValue) {
            Text("Preview")
                .font(TypographyToken.headline.font)

            Text(entry.summary)
                .font(TypographyToken.body.font)
                .foregroundStyle(theme.color(.onBackgroundSecondary))

            HStack {
                Image(systemName: entry.icon)
                    .font(.system(size: 40))
                    .foregroundStyle(theme.color(.interactive))
                Text(entry.name)
                    .font(TypographyToken.title2.font)
            }
            .frame(maxWidth: .infinity)
            .padding(SpacingToken.xl.rawValue)
            .background(theme.color(.surface), in: RadiusToken.lg.shape)
            .disabled(isDisabled)
            .dynamicTypeSize(isLargeText ? .xxxLarge : .medium)
            .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
}
