//
//  PrismScaffold.swift
//  Prism
//
//  Created by Rafael Escaleira on 09/04/26.
//

import PrismFoundation
import SwiftUI

public struct PrismScaffold<Content: View, Actions: View>: View {
    @Environment(\.platformContext) private var platformContext

    private let title: PrismTextContent?
    private let subtitle: PrismTextContent?
    private let scrollable: Bool
    private let content: () -> Content
    private let actions: () -> Actions

    public init(
        _ title: String? = nil,
        subtitle: String? = nil,
        scrollable: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) where Actions == EmptyView {
        self.title = PrismTextContent(title)
        self.subtitle = PrismTextContent(subtitle)
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
        self.title = PrismTextContent(title)
        self.subtitle = PrismTextContent(subtitle)
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
        self.title = PrismTextContent(title)
        self.subtitle = subtitle.map(PrismTextContent.init)
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
        self.title = PrismTextContent(title)
        self.subtitle = subtitle.map(PrismTextContent.init)
        self.scrollable = scrollable
        self.content = content
        self.actions = actions
    }

    public init(
        _ title: PrismResourceString?,
        subtitle: PrismResourceString? = nil,
        scrollable: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) where Actions == EmptyView {
        self.title = PrismTextContent(title?.value)
        self.subtitle = PrismTextContent(subtitle?.value)
        self.scrollable = scrollable
        self.content = content
        self.actions = { EmptyView() }
    }

    public init(
        _ title: PrismResourceString?,
        subtitle: PrismResourceString? = nil,
        scrollable: Bool = true,
        @ViewBuilder actions: @escaping () -> Actions,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = PrismTextContent(title?.value)
        self.subtitle = PrismTextContent(subtitle?.value)
        self.scrollable = scrollable
        self.content = content
        self.actions = actions
    }

    public var body: some View {
        PrismAdaptiveScreen(scrollable: scrollable) {
            PrismAdaptiveStack(
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
        for platformContext: PrismPlatformContext
    ) -> PrismAdaptiveStackStyle {
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
        PrismAdaptiveStack(
            style: Self.headerLayoutStyle(for: platformContext),
            verticalAlignment: .top,
            spacing: .large
        ) {
            VStack(alignment: .leading, spacing: 8) {
                if let title {
                    PrismText(content: title)
                        .prism(font: titleFont, weight: .semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                if let subtitle {
                    PrismText(content: subtitle)
                        .prism(font: subtitleFont)
                        .prism(color: .textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if Actions.self != EmptyView.self {
                PrismAdaptiveStack(
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
    PrismScaffold(
        String("Dashboard"),
        subtitle: "A mesma tela se adapta ao contexto da plataforma."
    ) {
        PrismAdaptiveStack(style: .actions) {
            PrismPrimaryButton("Continuar") {}
            PrismSecondaryButton("Agora não") {}
        }
    } content: {
        PrismSection {
            PrismBodyText("Conteúdo principal da tela")
        }
    }
}
