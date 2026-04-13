//
//  RyzeScreenSizeModifier.swift
//  Ryze
//
//  Created by Rafael Escaleira on 01/08/25.
//

import SwiftUI

/// Modificador de observação de screen do Design System RyzeUI.
///
/// `RyzeScreenModifier` monitora tamanho da tela e scroll position:
/// - Disponibiliza `screenSize` no environment
/// - Disponibiliza `isLargeScreen` no environment (configurável)
/// - Disponibiliza `scrollPosition` no environment
/// - Usa `PreferenceKey` para propagação eficiente
///
/// ## Uso Básico
/// ```swift
/// MyView()
///     .ryzeScreenObserve(minimumWidthScreen: 430)
/// ```
///
/// ## Acessando no Environment
/// ```swift
/// struct MyView: View {
///     @Environment(\.screenSize) var screenSize
///     @Environment(\.isLargeScreen) var isLargeScreen
///     @Environment(\.scrollPosition) var scrollPosition
///
///     var body: some View {
///         if isLargeScreen {
///             TabletLayout()
///         } else {
///             PhoneLayout()
///         }
///     }
/// }
/// ```
///
/// ## Preferências Internas
/// - `RyzeScreenSizePreferenceKey` - Propaga tamanho da tela
/// - `RyzeScreenScrollOffsetPreferenceKey` - Propaga offset de scroll
///
/// - Note: O threshold padrão para `isLargeScreen` é 430pt (iPhone 14 Pro Max).
private struct RyzeScreenSizePreferenceKey: @MainActor PreferenceKey {
    @MainActor static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

private struct RyzeScreenScrollOffsetPreferenceKey: @MainActor PreferenceKey {
    @MainActor static var defaultValue: CGPoint = .zero

    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
        value = nextValue()
    }
}

struct RyzeScreenModifier: ViewModifier {
    @Environment(\.theme) private var theme

    @State var size: CGSize = .zero
    @State var origin: CGPoint = .zero

    let minimumWidthScreen: CGFloat

    public func body(content: Content) -> some View {
        let layoutTier = theme.tokens.layoutTier(for: size.width)
        let platform = RyzePlatform.current
        let platformContext = RyzePlatformContext.resolve(
            platform: platform,
            layoutTier: layoutTier
        )
        let adaptiveLargeScreenThreshold = max(
            minimumWidthScreen,
            theme.tokens.breakpoint(for: .tabletCompact)
        )

        content
            .environment(\.screenSize, size)
            .environment(\.isLargeScreen, size.width >= adaptiveLargeScreenThreshold)
            .environment(\.scrollPosition, origin)
            .environment(\.platform, platform)
            .environment(\.platformContext, platformContext)
            .environment(\.layoutTier, layoutTier)
            .background {
                GeometryReader { proxy in
                    Color.clear
                        .preference(
                            key: RyzeScreenSizePreferenceKey.self,
                            value: proxy.size
                        )
                        .preference(
                            key: RyzeScreenScrollOffsetPreferenceKey.self,
                            value: proxy.frame(in: .named("scroll")).origin
                        )
                }
            }
            .onPreferenceChange(RyzeScreenSizePreferenceKey.self) { newSize in
                size = newSize
            }
            .onPreferenceChange(RyzeScreenScrollOffsetPreferenceKey.self) { newOrigin in
                origin = newOrigin
            }
    }

    static func mocked() -> some View {
        RyzeHStack.mocked()
            .ryze(width: .max, height: .max)
            .ryzePadding()
            .ryzeScreenObserve()
    }
}

#Preview {
    RyzeScreenModifier.mocked()
}
