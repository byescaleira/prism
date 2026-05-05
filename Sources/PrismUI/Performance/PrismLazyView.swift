import SwiftUI

/// A view that defers body evaluation until it appears on screen.
public struct PrismLazyView<Content: View>: View {
    @State private var shouldLoad = false

    private let placeholder: AnyView
    private let content: () -> Content

    /// Creates a lazy view with a custom placeholder shown before load.
    /// - Parameters:
    ///   - placeholder: View displayed while content has not yet appeared.
    ///   - content: The deferred content builder.
    public init<Placeholder: View>(
        @ViewBuilder placeholder: () -> Placeholder,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.placeholder = AnyView(placeholder())
        self.content = content
    }

    /// Creates a lazy view with a default `ProgressView` placeholder.
    /// - Parameter content: The deferred content builder.
    public init(@ViewBuilder content: @escaping () -> Content) {
        self.placeholder = AnyView(ProgressView())
        self.content = content
    }

    /// The content and behavior of the lazy view.
    public var body: some View {
        if shouldLoad {
            content()
        } else {
            placeholder
                .onAppear { shouldLoad = true }
        }
    }
}

/// A lazy wrapper for navigation destinations that defers body evaluation until appear.
public struct PrismLazyNavigationDestination<Content: View>: View {
    @State private var shouldLoad = false

    private let content: () -> Content

    /// Creates a lazy navigation destination.
    /// - Parameter content: The deferred destination content builder.
    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    /// The content and behavior of the lazy navigation destination.
    public var body: some View {
        if shouldLoad {
            content()
        } else {
            ProgressView()
                .onAppear { shouldLoad = true }
        }
    }
}
