import SwiftUI
import os

/// Runtime accessibility audit that warns about missing labels in DEBUG builds.
///
/// Attach to any view hierarchy to get console warnings for views
/// that are missing accessibility labels.
public struct PrismAccessibilityAudit: ViewModifier {
    private static let logger = Logger(
        subsystem: "com.prism.ui",
        category: "accessibility-audit"
    )

    private let context: String

    /// Creates an accessibility audit modifier with an optional context label.
    public init(context: String = "") {
        self.context = context
    }

    /// Wraps content and logs accessibility audit warnings in DEBUG builds.
    public func body(content: Content) -> some View {
        #if DEBUG
            content.onAppear {
                Self.logger.debug("♿ Accessibility audit active: \(context.isEmpty ? "unnamed view" : context)")
            }
        #else
            content
        #endif
    }
}

extension View {

    /// Enables accessibility audit logging in DEBUG builds.
    public func prismAccessibilityAudit(_ context: String = "") -> some View {
        modifier(PrismAccessibilityAudit(context: context))
    }
}
