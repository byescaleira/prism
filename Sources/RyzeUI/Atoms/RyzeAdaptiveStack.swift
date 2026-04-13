//
//  RyzeAdaptiveStack.swift
//  Ryze
//
//  Created by Rafael Escaleira on 09/04/26.
//

import SwiftUI

public enum RyzeAdaptiveStackStyle: Sendable {
    case automatic
    case form
    case content
    case actions
}

public struct RyzeAdaptiveStack<Content: View>: View {
    @Environment(\.platformContext) private var platformContext
    @Environment(\.theme) private var theme

    private let style: RyzeAdaptiveStackStyle
    private let horizontalAlignment: HorizontalAlignment
    private let verticalAlignment: VerticalAlignment
    private let spacing: RyzeSpacing?
    private let content: () -> Content

    public init(
        style: RyzeAdaptiveStackStyle = .automatic,
        horizontalAlignment: HorizontalAlignment = .leading,
        verticalAlignment: VerticalAlignment = .center,
        spacing: RyzeSpacing? = .medium,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.style = style
        self.horizontalAlignment = horizontalAlignment
        self.verticalAlignment = verticalAlignment
        self.spacing = spacing
        self.content = content
    }

    public var body: some View {
        adaptiveLayout {
            content()
        }
    }

    internal static func resolvedAxis(
        style: RyzeAdaptiveStackStyle,
        platformContext: RyzePlatformContext
    ) -> Axis {
        switch style {
        case .automatic:
            switch platformContext.platform {
            case .watchOS:
                .vertical
            case .macOS, .visionOS:
                platformContext.layoutTier == .compact ? .vertical : .horizontal
            default:
                .vertical
            }

        case .form, .content:
            switch platformContext.platform {
            case .macOS, .visionOS:
                platformContext.layoutTier == .expansive ? .horizontal : .vertical
            default:
                .vertical
            }

        case .actions:
            switch platformContext.platform {
            case .macOS:
                .horizontal
            case .iOS:
                platformContext.layoutTier == .compact ? .vertical : .horizontal
            case .visionOS:
                .horizontal
            case .tvOS, .watchOS:
                .vertical
            }
        }
    }

    private var adaptiveLayout: AnyLayout {
        let resolvedSpacing = spacing?.rawValue(for: theme.spacing)

        return switch axis {
        case .horizontal:
            AnyLayout(
                HStackLayout(
                    alignment: verticalAlignment,
                    spacing: resolvedSpacing
                )
            )
        case .vertical:
            AnyLayout(
                VStackLayout(
                    alignment: horizontalAlignment,
                    spacing: resolvedSpacing
                )
            )
        }
    }

    private var axis: Axis {
        Self.resolvedAxis(
            style: style,
            platformContext: platformContext
        )
    }
}
