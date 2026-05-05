import SwiftUI

/// Stores debug metadata for a single PrismUI component.
public struct PrismDebugInfo: Sendable {
    /// The component display name.
    public let componentName: String
    /// The number of times this component has rendered.
    public var renderCount: Int
    /// The measured frame size.
    public var frameSize: CGSize
    /// The accessibility label, if any.
    public var accessibilityLabel: String?

    /// Creates debug info for a component.
    public init(
        componentName: String,
        renderCount: Int = 1,
        frameSize: CGSize = .zero,
        accessibilityLabel: String? = nil
    ) {
        self.componentName = componentName
        self.renderCount = renderCount
        self.frameSize = frameSize
        self.accessibilityLabel = accessibilityLabel
    }
}

/// Collects and manages debug information for registered PrismUI components.
@Observable
@MainActor
public final class PrismComponentDebugger {
    /// All registered component debug entries.
    public private(set) var components: [PrismDebugInfo] = []

    /// Creates an empty component debugger.
    public init() {}

    /// Registers or updates a component entry with its current size and label.
    public func register(component name: String, size: CGSize, label: String? = nil) {
        if let index = components.firstIndex(where: { $0.componentName == name }) {
            components[index].renderCount += 1
            components[index].frameSize = size
            components[index].accessibilityLabel = label
        } else {
            components.append(
                PrismDebugInfo(
                    componentName: name,
                    renderCount: 1,
                    frameSize: size,
                    accessibilityLabel: label
                )
            )
        }
    }

    /// Clears all registered components.
    public func reset() {
        components.removeAll()
    }
}

// MARK: - Debug View Modifier

/// Modifier that draws a red outline and name overlay on components in DEBUG builds.
private struct PrismDebugModifier: ViewModifier {
    let debugger: PrismComponentDebugger
    let name: String

    func body(content: Content) -> some View {
        #if DEBUG
        content
            .overlay(
                GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            debugger.register(component: name, size: geometry.size)
                        }
                        .onChange(of: geometry.size) { _, newSize in
                            debugger.register(component: name, size: newSize)
                        }
                }
            )
            .overlay(alignment: .topLeading) {
                Text(name)
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(.red.opacity(0.85))
                    .clipShape(RoundedRectangle(cornerRadius: 3, style: .continuous))
                    .allowsHitTesting(false)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .strokeBorder(.red, lineWidth: 1)
                    .allowsHitTesting(false)
            )
        #else
        content
        #endif
    }
}

extension View {
    /// Adds a red debug outline and name overlay in DEBUG builds.
    public func prismDebug(debugger: PrismComponentDebugger, name: String) -> some View {
        modifier(PrismDebugModifier(debugger: debugger, name: name))
    }
}

// MARK: - Debug Overlay View

/// Lists all components currently registered in the debugger.
public struct PrismDebugOverlay: View {
    let debugger: PrismComponentDebugger

    /// Creates a debug overlay listing registered components.
    public init(debugger: PrismComponentDebugger) {
        self.debugger = debugger
    }

    /// The debug overlay view body listing all registered components.
    public var body: some View {
        List {
            Section("Registered Components (\(debugger.components.count))") {
                ForEach(debugger.components, id: \.componentName) { info in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(info.componentName)
                            .font(.system(.body, design: .monospaced, weight: .semibold))
                        HStack(spacing: SpacingToken.md.rawValue) {
                            Label(
                                "\(info.renderCount)x",
                                systemImage: "arrow.clockwise"
                            )
                            Label(
                                "\(Int(info.frameSize.width))x\(Int(info.frameSize.height))",
                                systemImage: "rectangle"
                            )
                            if let label = info.accessibilityLabel {
                                Label(label, systemImage: "accessibility")
                            }
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(
                        "\(info.componentName), rendered \(info.renderCount) times"
                    )
                }
            }
        }
    }
}
