import SwiftUI

/// Themed sheet presentation with configurable detents, sizing, and dismiss control.
private struct PrismSheetModifier<SheetContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let detents: Set<PresentationDetent>
    let showDragIndicator: Bool
    let interactiveDismiss: Bool
    let backgroundStyle: PrismSheetBackground
    let sheetContent: () -> SheetContent

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                sheetContent()
                    .presentationDetents(detents)
                    .presentationDragIndicator(showDragIndicator ? .visible : .hidden)
                    .interactiveDismissDisabled(!interactiveDismiss)
                    .modifier(SheetBackgroundModifier(style: backgroundStyle))
            }
    }
}

/// Sheet background style options.
public enum PrismSheetBackground: Sendable {
    /// Represents the system-default sheet background.
    case automatic
    /// Represents an ultra-thin material sheet background.
    case material
    /// Represents a transparent sheet background.
    case clear
}

private struct SheetBackgroundModifier: ViewModifier {
    let style: PrismSheetBackground

    func body(content: Content) -> some View {
        switch style {
        case .automatic:
            content
        case .material:
            content
                .presentationBackground(.ultraThinMaterial)
        case .clear:
            content
                .presentationBackground(.clear)
        }
    }
}

/// Item-based sheet presentation.
private struct PrismItemSheetModifier<Item: Identifiable, SheetContent: View>: ViewModifier {
    @Binding var item: Item?
    let detents: Set<PresentationDetent>
    let showDragIndicator: Bool
    let sheetContent: (Item) -> SheetContent

    func body(content: Content) -> some View {
        content
            .sheet(item: $item) { item in
                sheetContent(item)
                    .presentationDetents(detents)
                    .presentationDragIndicator(showDragIndicator ? .visible : .hidden)
            }
    }
}

/// Confirmation dialog with themed presentation.
private struct PrismConfirmationDialogModifier<Actions: View, Message: View>: ViewModifier {
    let title: LocalizedStringKey
    @Binding var isPresented: Bool
    let actions: () -> Actions
    let message: (() -> Message)?

    func body(content: Content) -> some View {
        if let message {
            content
                .confirmationDialog(title, isPresented: $isPresented) {
                    actions()
                } message: {
                    message()
                }
        } else {
            content
                .confirmationDialog(title, isPresented: $isPresented) {
                    actions()
                }
        }
    }
}

/// Inspector sidebar presentation for iPad/macOS.
private struct PrismInspectorModifier<InspectorContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let inspectorContent: () -> InspectorContent

    func body(content: Content) -> some View {
        content
            .inspector(isPresented: $isPresented) {
                inspectorContent()
            }
    }
}

extension View {

    /// Presents a themed sheet with configurable detents.
    public func prismSheet<Content: View>(
        isPresented: Binding<Bool>,
        detents: Set<PresentationDetent> = [.large],
        showDragIndicator: Bool = true,
        interactiveDismiss: Bool = true,
        background: PrismSheetBackground = .automatic,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        modifier(PrismSheetModifier(
            isPresented: isPresented,
            detents: detents,
            showDragIndicator: showDragIndicator,
            interactiveDismiss: interactiveDismiss,
            backgroundStyle: background,
            sheetContent: content
        ))
    }

    /// Presents a sheet bound to an optional identifiable item.
    public func prismSheet<Item: Identifiable, Content: View>(
        item: Binding<Item?>,
        detents: Set<PresentationDetent> = [.large],
        showDragIndicator: Bool = true,
        @ViewBuilder content: @escaping (Item) -> Content
    ) -> some View {
        modifier(PrismItemSheetModifier(
            item: item,
            detents: detents,
            showDragIndicator: showDragIndicator,
            sheetContent: content
        ))
    }

    /// Presents a confirmation dialog with themed actions.
    public func prismConfirmationDialog<Actions: View>(
        _ title: LocalizedStringKey,
        isPresented: Binding<Bool>,
        @ViewBuilder actions: @escaping () -> Actions
    ) -> some View {
        modifier(PrismConfirmationDialogModifier(
            title: title,
            isPresented: isPresented,
            actions: actions,
            message: nil as (() -> EmptyView)?
        ))
    }

    /// Presents a confirmation dialog with message.
    public func prismConfirmationDialog<Actions: View, Message: View>(
        _ title: LocalizedStringKey,
        isPresented: Binding<Bool>,
        @ViewBuilder actions: @escaping () -> Actions,
        @ViewBuilder message: @escaping () -> Message
    ) -> some View {
        modifier(PrismConfirmationDialogModifier(
            title: title,
            isPresented: isPresented,
            actions: actions,
            message: message
        ))
    }

    /// Presents an inspector sidebar (iPad/macOS).
    public func prismInspector<Content: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        modifier(PrismInspectorModifier(
            isPresented: isPresented,
            inspectorContent: content
        ))
    }
}
