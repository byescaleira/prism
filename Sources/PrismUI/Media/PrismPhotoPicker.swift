import SwiftUI

#if canImport(PhotosUI)
    import PhotosUI

    /// Themed photo picker wrapping PhotosUI `PhotosPicker`.
    ///
    /// ```swift
    /// @State private var selectedPhoto: PhotosPickerItem?
    ///
    /// PrismPhotoPicker(selection: $selectedPhoto) {
    ///     Label("Choose Photo", systemImage: "photo")
    /// }
    /// ```
    public struct PrismPhotoPicker<Label: View>: View {
        @Environment(\.prismTheme) private var theme

        @Binding private var selection: PhotosPickerItem?
        private let matching: PHPickerFilter
        private let label: Label

        /// Creates a photo picker with a selection binding, filter, and custom label.
        public init(
            selection: Binding<PhotosPickerItem?>,
            matching filter: PHPickerFilter = .images,
            @ViewBuilder label: () -> Label
        ) {
            self._selection = selection
            self.matching = filter
            self.label = label()
        }

        /// The content and behavior of the photo picker.
        public var body: some View {
            PhotosPicker(selection: $selection, matching: matching) {
                label
            }
            .tint(theme.color(.interactive))
        }
    }

    extension PrismPhotoPicker where Label == SwiftUI.Label<Text, Image> {

        /// Creates a photo picker with a localized title and system image.
        public init(
            _ title: LocalizedStringKey,
            systemImage: String = "photo.on.rectangle",
            selection: Binding<PhotosPickerItem?>,
            matching filter: PHPickerFilter = .images
        ) {
            self._selection = selection
            self.matching = filter
            self.label = SwiftUI.Label(title, systemImage: systemImage)
        }
    }

    /// Multi-selection photo picker.
    public struct PrismMultiPhotoPicker<Label: View>: View {
        @Environment(\.prismTheme) private var theme

        @Binding private var selection: [PhotosPickerItem]
        private let maxCount: Int
        private let matching: PHPickerFilter
        private let label: Label

        /// Creates a multi-selection photo picker with a max count, filter, and label.
        public init(
            selection: Binding<[PhotosPickerItem]>,
            maxSelectionCount: Int = 0,
            matching filter: PHPickerFilter = .images,
            @ViewBuilder label: () -> Label
        ) {
            self._selection = selection
            self.maxCount = maxSelectionCount
            self.matching = filter
            self.label = label()
        }

        /// The content and behavior of the multi photo picker.
        public var body: some View {
            PhotosPicker(
                selection: $selection,
                maxSelectionCount: maxCount > 0 ? maxCount : nil,
                matching: matching
            ) {
                label
            }
            .tint(theme.color(.interactive))
        }
    }
#endif
