import SwiftUI

/// Themed sheet presentation with configurable detents.
private struct PrismSheetModifier<SheetContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let detents: Set<PresentationDetent>
    let showDragIndicator: Bool
    let sheetContent: () -> SheetContent

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                sheetContent()
                    .presentationDetents(detents)
                    .presentationDragIndicator(showDragIndicator ? .visible : .hidden)
            }
    }
}

extension View {

    /// Presents a themed sheet with configurable detents.
    public func prismSheet<Content: View>(
        isPresented: Binding<Bool>,
        detents: Set<PresentationDetent> = [.large],
        showDragIndicator: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        modifier(PrismSheetModifier(
            isPresented: isPresented,
            detents: detents,
            showDragIndicator: showDragIndicator,
            sheetContent: content
        ))
    }
}
