import SwiftUI

/// Interactive, selectable chip for filtering and multi-select scenarios.
public struct PrismChip: View {
    @Environment(\.prismTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @Binding private var isSelected: Bool
    private let label: LocalizedStringKey
    private let icon: String?
    private let onRemove: (() -> Void)?

    public init(
        _ label: LocalizedStringKey,
        isSelected: Binding<Bool>,
        icon: String? = nil,
        onRemove: (() -> Void)? = nil
    ) {
        self.label = label
        self._isSelected = isSelected
        self.icon = icon
        self.onRemove = onRemove
    }

    public var body: some View {
        Button {
            isSelected.toggle()
        } label: {
            HStack(spacing: SpacingToken.xs.rawValue) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 12, weight: .medium))
                }

                Text(label)
                    .font(TypographyToken.subheadline.font(weight: .medium))
                    .lineLimit(1)

                if onRemove != nil && isSelected {
                    Button {
                        onRemove?()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(PrismStrings.remove)
                }
            }
            .foregroundStyle(isSelected ? theme.color(.onBrand) : theme.color(.onSurface))
            .padding(.horizontal, SpacingToken.md.rawValue)
            .padding(.vertical, SpacingToken.sm.rawValue)
            .background(chipBackground, in: Capsule())
            .overlay(
                Capsule()
                    .stroke(
                        isSelected ? Color.clear : theme.color(.border),
                        lineWidth: 1
                    )
            )
            .animation(
                reduceMotion ? nil : MotionToken.fast.animation,
                value: isSelected
            )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityLabel(label)
    }

    private var chipBackground: Color {
        isSelected ? theme.color(.interactive) : theme.color(.surface)
    }
}

// MARK: - Chip Group

/// Horizontal scrolling group of chips for filter scenarios.
public struct PrismChipGroup<Data: RandomAccessCollection, ID: Hashable, Content: View>: View {
    private let data: Data
    private let id: KeyPath<Data.Element, ID>
    private let content: (Data.Element) -> Content

    public init(
        _ data: Data,
        id: KeyPath<Data.Element, ID>,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.data = data
        self.id = id
        self.content = content
    }

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: SpacingToken.sm.rawValue) {
                ForEach(data, id: id) { item in
                    content(item)
                }
            }
            .padding(.horizontal, SpacingToken.lg.rawValue)
        }
    }
}
