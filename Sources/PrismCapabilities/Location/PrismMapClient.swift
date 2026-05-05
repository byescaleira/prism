#if canImport(MapKit)
    import MapKit

    // MARK: - Map Route

    /// A route calculated by MapKit with distance, travel time, and name.
    public struct PrismMapRoute: Sendable {
        /// The total route distance in meters.
        public let distance: Double
        /// The expected travel time in seconds.
        public let expectedTravelTime: TimeInterval
        /// The localized name of the route.
        public let name: String

        /// Creates a new map route with the given distance, travel time, and name.
        public init(distance: Double, expectedTravelTime: TimeInterval, name: String) {
            self.distance = distance
            self.expectedTravelTime = expectedTravelTime
            self.name = name
        }
    }

    // MARK: - Map Transport Type

    /// The mode of transportation for route calculations.
    public enum PrismMapTransportType: Sendable, CaseIterable {
        /// Driving directions by car.
        case automobile
        /// Walking directions on foot.
        case walking
        /// Public transit directions.
        case transit
        /// Cycling directions by bicycle.
        case cycling
    }

    // MARK: - Point of Interest

    /// A point of interest found via MapKit search.
    public struct PrismPOI: Sendable {
        /// The display name of the point of interest.
        public let name: String
        /// The geographic coordinate of the point of interest.
        public let coordinate: PrismLocation
        /// An optional category describing the point of interest.
        public let category: String?

        /// Creates a new point of interest with the given name, coordinate, and optional category.
        public init(name: String, coordinate: PrismLocation, category: String? = nil) {
            self.name = name
            self.coordinate = coordinate
            self.category = category
        }
    }

    // MARK: - Map Client

    /// Client for MapKit directions, travel time estimation, and point-of-interest search.
    public struct PrismMapClient: Sendable {

        /// Creates a new map client.
        public init() {}

        /// Calculates driving/walking/transit/cycling directions between two locations.
        public func directions(
            from origin: PrismLocation, to destination: PrismLocation,
            transportType: PrismMapTransportType = .automobile
        ) async throws -> [PrismMapRoute] {
            let request = MKDirections.Request()
            request.source = origin.mapItem
            request.destination = destination.mapItem
            request.transportType = transportType.mkTransportType

            let directions = MKDirections(request: request)
            let response = try await directions.calculate()
            return response.routes.map { route in
                PrismMapRoute(
                    distance: route.distance,
                    expectedTravelTime: route.expectedTravelTime,
                    name: route.name
                )
            }
        }

        /// Returns the estimated travel time in seconds between two locations.
        public func estimatedTravelTime(
            from origin: PrismLocation, to destination: PrismLocation,
            transportType: PrismMapTransportType = .automobile
        ) async throws -> TimeInterval {
            let request = MKDirections.Request()
            request.source = origin.mapItem
            request.destination = destination.mapItem
            request.transportType = transportType.mkTransportType

            let directions = MKDirections(request: request)
            let response = try await directions.calculateETA()
            return response.expectedTravelTime
        }

        /// Searches for points of interest matching a query near a location within a radius.
        public func searchPOI(query: String, near location: PrismLocation, radius: Double) async throws -> [PrismPOI] {
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = query
            request.region = MKCoordinateRegion(
                center: location.clCoordinate,
                latitudinalMeters: radius * 2,
                longitudinalMeters: radius * 2
            )

            let search = MKLocalSearch(request: request)
            let response = try await search.start()
            return response.mapItems.map { item in
                PrismPOI(
                    name: item.name ?? "",
                    coordinate: PrismLocation(
                        latitude: item.location.coordinate.latitude,
                        longitude: item.location.coordinate.longitude
                    ),
                    category: item.pointOfInterestCategory?.rawValue
                )
            }
        }
    }

    // MARK: - Private Extensions

    extension PrismLocation {
        fileprivate var clCoordinate: CLLocationCoordinate2D {
            CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }

        fileprivate var mapItem: MKMapItem {
            MKMapItem(location: CLLocation(latitude: latitude, longitude: longitude), address: nil)
        }
    }

    extension PrismMapTransportType {
        fileprivate var mkTransportType: MKDirectionsTransportType {
            switch self {
            case .automobile: .automobile
            case .walking: .walking
            case .transit: .transit
            case .cycling: .automobile  // MapKit does not have a dedicated cycling type
            }
        }
    }
#endif
