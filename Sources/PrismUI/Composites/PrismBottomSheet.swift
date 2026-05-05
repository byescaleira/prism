import SwiftUI

/// Resizable bottom sheet with drag handle, snap points, and backdrop.
public struct PrismBottomSheet<Content: View>: View {
    @Environment(\.prismTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @Binding private var isPresented: Bool
    private let snapPoints: [CGFloat]
    private let showHandle: Bool
    private let content: Content

    @State private var currentHeight: CGFloat = 0
    @State private var dragOffset: CGFloat = 0
    @GestureState private var isDragging = false

    /// Creates a bottom sheet with configurable snap points and drag handle.
    public init(
        isPresented: Binding<Bool>,
        snapPoints: [CGFloat] = [0.4, 0.85],
        showHandle: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self._isPresented = isPresented
        self.snapPoints = snapPoints.sorted()
        self.showHandle = showHandle
        self.content = content()
    }

    /// The bottom sheet view body with backdrop, drag gesture, and snap behavior.
    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                if isPresented {
                    backdrop
                    sheetView(maxHeight: geometry.size.height)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
        }
        .animation(
            reduceMotion ? nil : .spring(duration: 0.35, bounce: 0.15),
            value: isPresented
        )
    }

    private var backdrop: some View {
        theme.color(.overlay)
            .onTapGesture { isPresented = false }
            .transition(.opacity)
            .accessibilityAddTraits(.isButton)
            .accessibilityLabel(PrismStrings.dismiss)
    }

    private func sheetView(maxHeight: CGFloat) -> some View {
        let initialHeight = (snapPoints.first ?? 0.4) * maxHeight

        return VStack(spacing: 0) {
            if showHandle {
                dragHandle
            }
            content
                .frame(maxWidth: .infinity)
        }
        .frame(height: max(effectiveHeight(initial: initialHeight, maxHeight: maxHeight), 0))
        .frame(maxWidth: .infinity)
        .background(theme.color(.surface))
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: RadiusToken.xl.rawValue,
                topTrailingRadius: RadiusToken.xl.rawValue,
                style: .continuous
            )
        )
        .prismElevation(.overlay)
        .gesture(dragGesture(maxHeight: maxHeight, initialHeight: initialHeight))
        .transition(.move(edge: .bottom))
        .onAppear { currentHeight = initialHeight }
    }

    private var dragHandle: some View {
        Capsule()
            .fill(theme.color(.onBackgroundTertiary))
            .frame(width: 36, height: 5)
            .padding(.top, SpacingToken.sm.rawValue)
            .padding(.bottom, SpacingToken.xs.rawValue)
    }

    private func effectiveHeight(initial: CGFloat, maxHeight: CGFloat) -> CGFloat {
        let base = isDragging ? currentHeight : currentHeight
        return min(max(base - dragOffset, 0), maxHeight)
    }

    private func dragGesture(maxHeight: CGFloat, initialHeight: CGFloat) -> some Gesture {
        DragGesture()
            .updating($isDragging) { _, state, _ in state = true }
            .onChanged { value in
                dragOffset = value.translation.height
            }
            .onEnded { value in
                let projected = currentHeight - value.translation.height
                let ratio = projected / maxHeight

                if value.translation.height > 100 && ratio < (snapPoints.first ?? 0.3) {
                    isPresented = false
                } else {
                    let closest =
                        snapPoints.min(by: {
                            abs($0 - ratio) < abs($1 - ratio)
                        }) ?? snapPoints.first ?? 0.4
                    currentHeight = closest * maxHeight
                }
                dragOffset = 0
            }
    }
}

// MARK: - View Extension

extension View {

    /// Presents a resizable bottom sheet.
    public func prismBottomSheet<Content: View>(
        isPresented: Binding<Bool>,
        snapPoints: [CGFloat] = [0.4, 0.85],
        showHandle: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        overlay {
            PrismBottomSheet(
                isPresented: isPresented,
                snapPoints: snapPoints,
                showHandle: showHandle,
                content: content
            )
        }
    }
}
