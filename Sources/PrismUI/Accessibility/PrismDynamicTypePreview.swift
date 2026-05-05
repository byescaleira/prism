import SwiftUI

/// Preview helper that renders a view at multiple Dynamic Type sizes.
///
/// Use in SwiftUI Previews to verify typography adapts correctly:
/// ```swift
/// #Preview {
///     PrismDynamicTypePreview {
///         MyComponent()
///     }
/// }
/// ```
public struct PrismDynamicTypePreview<Content: View>: View {
    private let content: Content

    private let sizes: [DynamicTypeSize] = [
        .xSmall,
        .medium,
        .large,
        .xxxLarge,
        .accessibility3,
    ]

    /// Creates a dynamic type preview with the given content.
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    /// The preview body rendering content at multiple dynamic type sizes.
    public var body: some View {
        ScrollView {
            VStack(spacing: SpacingToken.xl.rawValue) {
                ForEach(sizes, id: \.self) { size in
                    VStack(alignment: .leading, spacing: SpacingToken.xs.rawValue) {
                        Text(String(describing: size))
                            .font(.caption2)
                            .foregroundStyle(.secondary)

                        content
                            .dynamicTypeSize(size)
                    }
                    .padding(SpacingToken.md.rawValue)
                    .background(.quaternary, in: RadiusToken.md.shape)
                }
            }
            .padding(SpacingToken.lg.rawValue)
        }
    }
}
