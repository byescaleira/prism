//
//  PrismAdaptiveScreen.swift
//  Prism
//
//  Created by Rafael Escaleira on 09/04/26.
//

import SwiftUI

public struct PrismAdaptiveScreen<Content: View>: View {
    @Environment(\.platformContext) private var platformContext

    private let scrollable: Bool
    private let showsIndicators: Bool
    private let content: () -> Content

    public init(
        scrollable: Bool = true,
        showsIndicators: Bool = false,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.scrollable = scrollable
        self.showsIndicators = showsIndicators
        self.content = content
    }

    public var body: some View {
        Group {
            if scrollable {
                ScrollView(.vertical, showsIndicators: showsIndicators) {
                    screenContent
                }
            } else {
                screenContent
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        #if os(tvOS)
            .focusSection()
        #endif
    }

    private var outerAlignment: Alignment {
        platformContext.prefersCenteredCanvas ? .top : .topLeading
    }

    private var readableWidth: CGFloat {
        platformContext.maxReadableWidth ?? .infinity
    }

    private var screenContent: some View {
        content()
            .controlSize(platformContext.controlSize)
            .frame(
                maxWidth: readableWidth,
                alignment: .topLeading
            )
            .padding(
                .horizontal,
                platformContext.contentMargins.horizontal
            )
            .padding(
                .vertical,
                platformContext.contentMargins.vertical
            )
            .frame(
                maxWidth: .infinity,
                alignment: outerAlignment
            )
    }
}
