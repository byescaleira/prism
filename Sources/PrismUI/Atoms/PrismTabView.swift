//
//  PrismTabView.swift
//  Prism
//
//  Created by Rafael Escaleira on 03/07/25.
//

import PrismFoundation
import SwiftUI

/// Tab view for the PrismUI Design System.
///
/// `PrismTabView` is a wrapper around the native `TabView` with:
/// - Typed selection via binding
/// - Integrated search (searchable)
/// - Adaptive accessory view on iOS, macOS, and visionOS
/// - Automatic tab bar minimization on scroll when the platform supports this pattern
/// - Search toolbar minimization on iOS
/// - Full accessibility support (VoiceOver/TalkBack)
/// - UI testing (XCUITest) via stable testIDs
///
/// ## Basic Usage
/// ```swift
/// @State var selected: Int = 0
/// PrismTabView(selection: $selected) {
///     HomeView()
///         .tabItem {
///             PrismLabel("Home", symbol: "house")
///         }
///     SettingsView()
///         .tabItem {
///             PrismLabel("Settings", symbol: "gear")
///         }
/// }
/// ```
///
/// ## With Search
/// ```swift
/// @State var searchText = ""
/// PrismTabView(
///     selection: $selected,
///     searchText: $searchText,
///     searchPrompt: PrismUIString.searchPlaceholder
/// ) {
///     ContentView()
/// }
/// ```
///
/// ## With Accessory View
/// ```swift
/// PrismTabView(
///     selection: $selected,
///     accessoryView: {
///         PrismPrimaryButton("Action") { }
///     }
/// ) {
///     ContentView()
/// }
/// ```
///
/// ## With testID for Testing
/// ```swift
/// PrismTabView(
///     selection: $selected,
///     testID: "main_tabs"
/// ) {
///     TabContent()
/// }
/// ```
///
/// - Note: Maintains the same API across platforms and adapts the chrome based on `PrismPlatformContext`.
public struct PrismTabView<SelectionValue: Hashable>: PrismView {
    @Environment(\.platformContext) private var platformContext
    @Environment(\.analyticsProvider) private var analyticsProvider

    @Binding var selection: SelectionValue
    var searchText: Binding<String>?
    var searchPrompt: PrismResourceString?
    @ViewBuilder let content: any View
    let accessoryView: (any View)?
    public var accessibility: PrismAccessibilityProperties?

    public init(
        _ accessibility: PrismAccessibilityProperties? = nil,
        selection: Binding<SelectionValue>,
        searchText: Binding<String>? = nil,
        searchPrompt: PrismResourceString? = nil,
        accessoryView: (() -> any View)? = nil,
        @ViewBuilder content: () -> any View,
    ) {
        self.accessibility = accessibility
        self._selection = selection
        self.searchText = searchText
        self.searchPrompt = searchPrompt
        self.content = content()
        self.accessoryView = accessoryView?()
    }

    public init(
        selection: Binding<SelectionValue>,
        testID: String,
        searchText: Binding<String>? = nil,
        searchPrompt: PrismResourceString? = nil,
        accessoryView: (() -> any View)? = nil,
        @ViewBuilder content: () -> any View,
    ) {
        self.accessibility = PrismAccessibility.custom(label: "", testID: testID)
        self._selection = selection
        self.searchText = searchText
        self.searchPrompt = searchPrompt
        self.content = content()
        self.accessoryView = accessoryView?()
    }

    public var body: some View {
        tabView
            .prism(accessibility)
            .onChange(of: selection) { _, newValue in
                trackTabSelect(newValue)
            }
    }

    private func trackTabSelect(_ value: SelectionValue) {
        guard let analyticsProvider else { return }
        let testID = (accessibility ?? PrismAccessibility.custom(label: "", testID: "")).testID
        analyticsProvider.track(
            .tabSelect(testID: testID, tab: String(describing: value))
        )
    }

    internal static func showsBottomAccessory(
        in platform: PrismPlatform
    ) -> Bool {
        switch platform {
        case .iOS, .macOS, .visionOS:
            true
        case .tvOS, .watchOS:
            false
        }
    }

    internal static func minimizesChromeOnScroll(
        in platform: PrismPlatform
    ) -> Bool {
        switch platform {
        case .iOS:
            true
        case .macOS, .tvOS, .watchOS, .visionOS:
            false
        }
    }

    @ViewBuilder
    var tabView: some View {
        baseTabView
            .prism(item: searchText) {
                searchable(
                    view: $0,
                    searchText: $1
                )
            }
            .prism(item: accessoryView) { view, accessoryView in
                accessoryContainer(
                    for: view,
                    accessoryView: accessoryView
                )
            }
            .prism(tint: .primary)
            .controlSize(platformContext.controlSize)
    }

    @ViewBuilder
    private var baseTabView: some View {
        let tabView = TabView(selection: $selection) {
            AnyView(content)
        }

        #if os(iOS)
            if Self.minimizesChromeOnScroll(in: platformContext.platform) {
                tabView
                    .tabBarMinimizeBehavior(.onScrollDown)
                    .searchToolbarBehavior(.minimize)
            } else {
                tabView
            }
        #else
            tabView
        #endif
    }

    @ViewBuilder
    func searchable(view: some View, searchText: Binding<String>) -> some View {
        if let searchPrompt {
            view.searchable(
                text: searchText,
                prompt: searchPrompt.value
            )
        } else {
            view.searchable(text: searchText)
        }
    }

    @ViewBuilder
    private func accessoryContainer(
        for view: some View,
        accessoryView: any View
    ) -> some View {
        if Self.showsBottomAccessory(in: platformContext.platform) {
            #if os(iOS)
                if platformContext.platform == .iOS {
                    view.tabViewBottomAccessory {
                        AnyView(accessoryView)
                    }
                } else {
                    view.safeAreaInset(edge: .bottom) {
                        accessoryBar(accessoryView)
                    }
                }
            #else
                view.safeAreaInset(edge: .bottom) {
                    accessoryBar(accessoryView)
                }
            #endif
        } else {
            view
        }
    }

    private func accessoryBar(
        _ accessoryView: any View
    ) -> some View {
        PrismAdaptiveStack(
            style: .actions,
            spacing: .medium
        ) {
            AnyView(accessoryView)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.horizontal, platformContext.contentMargins.horizontal)
        .padding(.vertical, max(12, platformContext.contentMargins.vertical / 2))
        .background(.regularMaterial)
    }

    public static func mocked() -> some View {
        PrismTabView<Int>(
            selection: .constant(1),
            searchText: .constant(""),
            searchPrompt: PrismUIString.prismPreviewTitle,
            accessoryView: nil
        ) {
            ForEach((1...3).map { $0 }, id: \.self) { index in
                PrismList.mocked()
                    .searchable(text: .constant(""))
                    .tabItem {
                        PrismLabel.mocked()
                    }
            }
        }
    }
}

#Preview {
    PrismTabView<Int>.mocked()
}
