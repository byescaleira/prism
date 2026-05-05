import SwiftUI
import UniformTypeIdentifiers

/// Protocol extending FileDocument with PrismUI themed document scaffolding.
///
/// ```swift
/// struct MyDocument: PrismDocument {
///     static var readableContentTypes: [UTType] { [.plainText] }
///     var text: String = ""
///
///     init(configuration: ReadConfiguration) throws {
///         guard let data = configuration.file.regularFileContents else {
///             throw CocoaError(.fileReadCorruptFile)
///         }
///         text = String(data: data, encoding: .utf8) ?? ""
///     }
///
///     func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
///         FileWrapper(regularFileWithContents: Data(text.utf8))
///     }
/// }
/// ```
public protocol PrismDocument: FileDocument {}

/// Themed document editor scaffold with toolbar and auto-save indicator.
public struct PrismDocumentView<Content: View>: View {
    @Environment(\.prismTheme) private var theme
    @Environment(\.undoManager) private var undoManager

    private let title: LocalizedStringKey
    private let content: Content

    /// Creates a document view with a title and content.
    public init(
        _ title: LocalizedStringKey = "Document",
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.content = content()
    }

    /// The document view body with navigation, undo/redo toolbar, and content.
    public var body: some View {
        NavigationStack {
            content
                .navigationTitle(title)
                .toolbarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        HStack(spacing: SpacingToken.sm.rawValue) {
                            if let undoManager {
                                Button {
                                    undoManager.undo()
                                } label: {
                                    Image(systemName: "arrow.uturn.backward")
                                }
                                .disabled(!undoManager.canUndo)

                                Button {
                                    undoManager.redo()
                                } label: {
                                    Image(systemName: "arrow.uturn.forward")
                                }
                                .disabled(!undoManager.canRedo)
                            }
                        }
                        .foregroundStyle(theme.color(.interactive))
                    }
                }
        }
    }
}
