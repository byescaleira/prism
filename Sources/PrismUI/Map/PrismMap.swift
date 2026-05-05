import SwiftUI

#if canImport(MapKit)
    import MapKit

    /// Themed map view with PrismUI token styling.
    ///
    /// ```swift
    /// PrismMap(selection: $selected) {
    ///     ForEach(landmarks) { landmark in
    ///         PrismMapMarker(landmark.name, coordinate: landmark.coordinate)
    ///     }
    /// }
    /// ```
    @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
    public struct PrismMap<Content: MapContent>: View {
        @Environment(\.prismTheme) private var theme
        @Binding private var selection: MKMapItem?
        private let position: MapCameraPosition
        private let content: Content

        /// Creates a themed map with camera position, selection binding, and map content.
        public init(
            position: MapCameraPosition = .automatic,
            selection: Binding<MKMapItem?> = .constant(nil),
            @MapContentBuilder content: () -> Content
        ) {
            self.position = position
            self._selection = selection
            self.content = content()
        }

        /// The content and behavior of the map.
        public var body: some View {
            Map(initialPosition: position, selection: $selection) {
                content
            }
            .mapStyle(.standard(pointsOfInterest: .excludingAll))
        }
    }

    /// Themed map marker.
    @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
    public struct PrismMapMarker: MapContent {
        @Environment(\.prismTheme) private var theme

        private let title: String
        private let coordinate: CLLocationCoordinate2D
        private let tint: ColorToken

        /// Creates a themed map marker with a title, coordinate, and tint color.
        public init(
            _ title: String,
            coordinate: CLLocationCoordinate2D,
            tint: ColorToken = .interactive
        ) {
            self.title = title
            self.coordinate = coordinate
            self.tint = tint
        }

        /// The map content of the marker.
        public var body: some MapContent {
            Marker(title, coordinate: coordinate)
                .tint(theme.color(tint))
        }
    }

    /// Themed map annotation with custom content.
    @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
    public struct PrismMapAnnotation<Content: View>: MapContent {
        private let coordinate: CLLocationCoordinate2D
        private let anchor: UnitPoint
        private let content: Content

        /// Creates a map annotation with a coordinate, anchor point, and custom content.
        public init(
            coordinate: CLLocationCoordinate2D,
            anchor: UnitPoint = .bottom,
            @ViewBuilder content: () -> Content
        ) {
            self.coordinate = coordinate
            self.anchor = anchor
            self.content = content()
        }

        /// The map content of the annotation.
        public var body: some MapContent {
            Annotation("", coordinate: coordinate, anchor: anchor) {
                content
            }
        }
    }
#endif
