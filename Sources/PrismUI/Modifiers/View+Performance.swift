import SwiftUI
import os.log

private let performanceLog = Logger(subsystem: "PrismUI", category: "Performance")

/// Deferred loading modifier that only renders content when visible.
private struct PrismLazyModifier<Placeholder: View>: ViewModifier {
    @State private var isVisible = false
    let placeholder: Placeholder

    func body(content: Content) -> some View {
        if isVisible {
            content
        } else {
            placeholder
                .onAppear { isVisible = true }
        }
    }
}

/// Debug modifier that logs body evaluation count in DEBUG builds.
private struct PrismBodyCountModifier: ViewModifier {
    let label: String
    @State private var count = 0

    func body(content: Content) -> some View {
        #if DEBUG
        let _ = {
            count += 1
            performanceLog.debug("\(label) body evaluated \(count) time(s)")
        }()
        #endif
        content
    }
}

extension View {

    /// Defers rendering until the view appears on screen.
    ///
    /// Useful for expensive views in lists or scroll views. Shows a placeholder
    /// until the view enters the visible area.
    public func prismLazy<Placeholder: View>(
        @ViewBuilder placeholder: () -> Placeholder = { ProgressView() }
    ) -> some View {
        modifier(PrismLazyModifier(placeholder: placeholder()))
    }

    /// Logs body evaluation count in DEBUG builds for performance profiling.
    public func prismBodyCount(_ label: String) -> some View {
        modifier(PrismBodyCountModifier(label: label))
    }
}
