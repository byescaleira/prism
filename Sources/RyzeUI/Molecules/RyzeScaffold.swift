//
//  RyzeScaffold.swift
//  Ryze
//
//  Created by Rafael Escaleira on 09/04/26.
//

import RyzeFoundation
import SwiftUI

public struct RyzeScaffold<Content: View, Actions: View>: View {
    @Environment(\.platformContext) private var platformContext

    private let title: RyzeTextContent?
    private let subtitle: RyzeTextContent?
    private let scrollable: Bool
    private let content: () -> Content
    private let actions: () -> Actions

    public init(
        _ title: String? = nil,
        subtitle: String? = nil,
        scrollable: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) where Actions == EmptyView {
        self.title = RyzeTextContent(title)
        self.subtitle = RyzeTextContent(subtitle)
        self.scrollable = scrollable
        self.content = content
        self.actions = { EmptyView() }
    }

    public init(
        _ title: String? = nil,
        subtitle: String? = nil,
        scrollable: Bool = true,
        @ViewBuilder actions: @escaping () -> Actions,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = RyzeTextContent(title)
        self.subtitle = RyzeTextContent(subtitle)
        self.scrollable = scrollable
        self.content = content
        self.actions = actions
    }

    public init(
        _ title: LocalizedStringKey,
        subtitle: LocalizedStringKey? = nil,
        scrollable: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) where Actions == EmptyView {
        self.title = RyzeTextContent(title)
        self.subtitle = subtitle.map(RyzeTextContent.init)
        self.scrollable = scrollable
        self.content = content
        self.actions = { EmptyView() }
    }

    public init(
        _ title: LocalizedStringKey,
        subtitle: LocalizedStringKey? = nil,
        scrollable: Bool = true,
        @ViewBuilder actions: @escaping () -> Actions,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = RyzeTextContent(title)
        self.subtitle = subtitle.map(RyzeTextContent.init)
        self.scrollable = scrollable
        self.content = content
        self.actions = actions
    }

    public init(
        _ title: RyzeResourceString?,
        subtitle: RyzeResourceString? = nil,
        scrollable: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) where Actions == EmptyView {
        self.title = RyzeTextContent(title?.value)
        self.subtitle = RyzeTextContent(subtitle?.value)
        self.scrollable = scrollable
        self.content = content
        self.actions = { EmptyView() }
    }

    public init(
        _ title: RyzeResourceString?,
        subtitle: RyzeResourceString? = nil,
        scrollable: Bool = true,
        @ViewBuilder actions: @escaping () -> Actions,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = RyzeTextContent(title?.value)
        self.subtitle = RyzeTextContent(subtitle?.value)
        self.scrollable = scrollable
        self.content = content
        self.actions = actions
    }

    public var body: some View {
        RyzeAdaptiveScreen(scrollable: scrollable) {
            RyzeAdaptiveStack(
                style: .content,
                verticalAlignment: .top,
                spacing: .large
            ) {
                if title != nil || subtitle != nil {
                    header
                }

                content()
            }
        }
    }

    internal static func headerLayoutStyle(
        for platformContext: RyzePlatformContext
    ) -> RyzeAdaptiveStackStyle {
        switch platformContext.platform {
        case .macOS, .visionOS:
            .actions
        case .iOS:
            platformContext.layoutTier == .compact ? .content : .actions
        case .tvOS, .watchOS:
            .content
        }
    }

    private var titleFont: Font {
        switch platformContext.platform {
        case .watchOS:
            .headline
        case .tvOS:
            .largeTitle
        case .iOS:
            platformContext.layoutTier == .compact ? .largeTitle : .title
        case .macOS, .visionOS:
            .title
        }
    }

    private var subtitleFont: Font {
        switch platformContext.platform {
        case .watchOS:
            .footnote
        case .tvOS:
            .title3
        default:
            .body
        }
    }

    @ViewBuilder
    private var header: some View {
        RyzeAdaptiveStack(
            style: Self.headerLayoutStyle(for: platformContext),
            verticalAlignment: .top,
            spacing: .large
        ) {
            VStack(alignment: .leading, spacing: 8) {
                if let title {
                    RyzeText(content: title)
                        .ryze(font: titleFont, weight: .semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                if let subtitle {
                    RyzeText(content: subtitle)
                        .ryze(font: subtitleFont)
                        .ryze(color: .textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if Actions.self != EmptyView.self {
                RyzeAdaptiveStack(
                    style: .actions,
                    spacing: .medium
                ) {
                    actions()
                }
                .frame(
                    maxWidth: platformContext.platform == .watchOS ? .infinity : nil,
                    alignment: .trailing
                )
            }
        }
    }
}

#Preview {
    RyzeScaffold(
        String("Dashboard"),
        subtitle: "A mesma tela se adapta ao contexto da plataforma."
    ) {
        RyzeAdaptiveStack(style: .actions) {
            RyzePrimaryButton("Continuar") {}
            RyzeSecondaryButton("Agora não") {}
        }
    } content: {
        RyzeSection {
            RyzeBodyText("Conteúdo principal da tela")
        }
    }
}
