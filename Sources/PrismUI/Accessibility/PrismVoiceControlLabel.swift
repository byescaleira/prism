import SwiftUI

/// View modifier applying voice control label and input labels.
private struct VoiceControlLabelModifier: ViewModifier {
    let label: String

    func body(content: Content) -> some View {
        content
            .accessibilityLabel(Text(label))
            .accessibilityInputLabels([Text(label)])
    }
}

/// View modifier applying a voice control hint.
private struct VoiceControlHintModifier: ViewModifier {
    let hint: String

    func body(content: Content) -> some View {
        content
            .accessibilityHint(Text(hint))
    }
}

extension View {

    /// Sets the voice control label and input labels for this view.
    public func prismVoiceControlLabel(_ label: String) -> some View {
        modifier(VoiceControlLabelModifier(label: label))
    }

    /// Sets the voice control hint for this view.
    public func prismVoiceControlHint(_ hint: String) -> some View {
        modifier(VoiceControlHintModifier(hint: hint))
    }
}

/// Container that groups child controls under a shared accessibility label.
public struct PrismVoiceControlGroup<Content: View>: View {
    private let label: String
    private let content: Content

    /// Creates a voice control group with a shared label for the contained controls.
    public init(_ label: String, @ViewBuilder content: () -> Content) {
        self.label = label
        self.content = content()
    }

    /// The group body with a shared accessibility label applied to the container.
    public var body: some View {
        Group {
            content
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text(label))
    }
}
