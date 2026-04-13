//
//  RyzeTabView.swift
//  Ryze
//
//  Created by Rafael Escaleira on 03/07/25.
//

import RyzeFoundation
import SwiftUI

/// View de abas do Design System RyzeUI.
///
/// `RyzeTabView` é um wrapper do `TabView` nativo com:
/// - Seleção tipada via binding
/// - Busca integrada (searchable)
/// - View acessória adaptativa em iOS, macOS e visionOS
/// - Minimização automática da tab bar ao scrollar quando a plataforma suporta esse padrão
/// - Minimização da search toolbar no iOS
/// - Acessibilidade completa (VoiceOver/TalkBack)
/// - Testes de UI (XCUITest) via testIDs estáveis
///
/// ## Uso Básico
/// ```swift
/// @State var selected: Int = 0
/// RyzeTabView(selection: $selected) {
///     HomeView()
///         .tabItem {
///             RyzeLabel("Início", symbol: "house")
///         }
///     SettingsView()
///         .tabItem {
///             RyzeLabel("Ajustes", symbol: "gear")
///         }
/// }
/// ```
///
/// ## Com Busca
/// ```swift
/// @State var searchText = ""
/// RyzeTabView(
///     selection: $selected,
///     searchText: $searchText,
///     searchPrompt: RyzeUIString.searchPlaceholder
/// ) {
///     ContentView()
/// }
/// ```
///
/// ## Com View Acessória
/// ```swift
/// RyzeTabView(
///     selection: $selected,
///     accessoryView: {
///         RyzePrimaryButton("Ação") { }
///     }
/// ) {
///     ContentView()
/// }
/// ```
///
/// ## Com testID para Testes
/// ```swift
/// RyzeTabView(
///     selection: $selected,
///     testID: "main_tabs"
/// ) {
///     TabContent()
/// }
/// ```
///
/// - Note: Mantém a mesma API entre plataformas e adapta o chrome conforme o `RyzePlatformContext`.
public struct RyzeTabView<SelectionValue: Hashable>: RyzeView {
    @Environment(\.platformContext) private var platformContext

    @Binding var selection: SelectionValue
    var searchText: Binding<String>?
    var searchPrompt: RyzeResourceString?
    @ViewBuilder let content: any View
    let accessoryView: (any View)?
    public var accessibility: RyzeAccessibilityProperties?

    public init(
        _ accessibility: RyzeAccessibilityProperties? = nil,
        selection: Binding<SelectionValue>,
        searchText: Binding<String>? = nil,
        searchPrompt: RyzeResourceString? = nil,
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
        searchPrompt: RyzeResourceString? = nil,
        accessoryView: (() -> any View)? = nil,
        @ViewBuilder content: () -> any View,
    ) {
        self.accessibility = RyzeAccessibility.custom(label: "", testID: testID)
        self._selection = selection
        self.searchText = searchText
        self.searchPrompt = searchPrompt
        self.content = content()
        self.accessoryView = accessoryView?()
    }

    public var body: some View {
        tabView
            .ryze(accessibility)
    }

    internal static func showsBottomAccessory(
        in platform: RyzePlatform
    ) -> Bool {
        switch platform {
        case .iOS, .macOS, .visionOS:
            true
        case .tvOS, .watchOS:
            false
        }
    }

    internal static func minimizesChromeOnScroll(
        in platform: RyzePlatform
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
            .ryze(item: searchText) {
                searchable(
                    view: $0,
                    searchText: $1
                )
            }
            .ryze(item: accessoryView) { view, accessoryView in
                accessoryContainer(
                    for: view,
                    accessoryView: accessoryView
                )
            }
            .ryze(tint: .primary)
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
        RyzeAdaptiveStack(
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
        RyzeTabView<Int>(
            selection: .constant(1),
            searchText: .constant(""),
            searchPrompt: RyzeUIString.ryzePreviewTitle,
            accessoryView: nil
        ) {
            ForEach((1...3).map { $0 }, id: \.self) { index in
                RyzeList.mocked()
                    .searchable(text: .constant(""))
                    .tabItem {
                        RyzeLabel.mocked()
                    }
            }
        }
    }
}

#Preview {
    RyzeTabView<Int>.mocked()
}
