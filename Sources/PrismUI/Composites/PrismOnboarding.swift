import SwiftUI

/// Paged onboarding walkthrough with progress indicator.
///
/// ```swift
/// PrismOnboarding(pages: [
///     .init(icon: "star", title: "Welcome", message: "Get started"),
///     .init(icon: "heart", title: "Favorites", message: "Save items"),
/// ]) {
///     // completed
/// }
/// ```
public struct PrismOnboarding: View {
    @Environment(\.prismTheme) private var theme
    @State private var currentPage = 0

    private let pages: [Page]
    private let onComplete: () -> Void

    /// Creates an onboarding flow with the given pages and completion handler.
    public init(
        pages: [Page],
        onComplete: @escaping () -> Void
    ) {
        self.pages = pages
        self.onComplete = onComplete
    }

    /// The onboarding view body with paged tab view and progress indicators.
    public var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentPage) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                    pageView(page)
                        .tag(index)
                }
            }
            #if os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
            .tabViewStyle(.page(indexDisplayMode: .never))
            #endif

            bottomBar
        }
        .background(theme.color(.background))
    }

    @ViewBuilder
    private func pageView(_ page: Page) -> some View {
        VStack(spacing: SpacingToken.xl.rawValue) {
            Spacer()

            Image(systemName: page.icon)
                .font(.system(size: 72, weight: .light))
                .foregroundStyle(theme.color(.interactive))
                .symbolRenderingMode(.hierarchical)

            VStack(spacing: SpacingToken.sm.rawValue) {
                Text(page.title)
                    .font(TypographyToken.largeTitle.font)
                    .foregroundStyle(theme.color(.onBackground))
                    .multilineTextAlignment(.center)

                Text(page.message)
                    .font(TypographyToken.body.font)
                    .foregroundStyle(theme.color(.onBackgroundSecondary))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, SpacingToken.xxl.rawValue)

            Spacer()
            Spacer()
        }
    }

    @ViewBuilder
    private var bottomBar: some View {
        VStack(spacing: SpacingToken.lg.rawValue) {
            HStack(spacing: SpacingToken.sm.rawValue) {
                ForEach(0..<pages.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentPage
                              ? theme.color(.interactive)
                              : theme.color(.onBackgroundTertiary))
                        .frame(width: 8, height: 8)
                        .animation(.easeInOut(duration: 0.2), value: currentPage)
                }
            }

            Button {
                if currentPage < pages.count - 1 {
                    withAnimation(.snappy) {
                        currentPage += 1
                    }
                } else {
                    onComplete()
                }
            } label: {
                Text(currentPage < pages.count - 1 ? "Continue" : "Get Started")
                    .font(TypographyToken.headline.font)
                    .foregroundStyle(theme.color(.onBrand))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, SpacingToken.md.rawValue)
                    .background(theme.color(.interactive), in: Capsule())
            }
            .padding(.horizontal, SpacingToken.xl.rawValue)
        }
        .padding(.bottom, SpacingToken.xxl.rawValue)
    }

    /// A single page in the onboarding flow.
    public struct Page: @unchecked Sendable {
        /// SF Symbol name for the page illustration.
        public let icon: String
        /// Page headline.
        public let title: LocalizedStringKey
        /// Page description text.
        public let message: LocalizedStringKey

        /// Creates an onboarding page with icon, title, and message.
        public init(icon: String, title: LocalizedStringKey, message: LocalizedStringKey) {
            self.icon = icon
            self.title = title
            self.message = message
        }
    }
}
