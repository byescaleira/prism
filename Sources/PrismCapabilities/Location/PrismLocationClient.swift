#if canImport(CoreLocation)
    import CoreLocation
    #if canImport(MapKit)
        import MapKit
    #endif

    // MARK: - Location Permission

    /// Authorization status for Core Location services.
    public enum PrismLocationPermission: Sendable, CaseIterable {
        /// The user has not yet been asked for location access.
        case notDetermined
        /// Location access is restricted by the system.
        case restricted
        /// The user has explicitly denied location access.
        case denied
        /// The user has granted location access while the app is in use.
        case authorizedWhenInUse
        /// The user has granted location access at all times.
        case authorizedAlways
    }

    // MARK: - Location Accuracy

    /// Desired accuracy level for location updates.
    public enum PrismLocationAccuracy: Sendable {
        /// The highest level of accuracy available.
        case best
        /// Accurate to the nearest ten meters.
        case nearestTenMeters
        /// Accurate to the nearest hundred meters.
        case hundredMeters
        /// Accurate to the nearest kilometer.
        case kilometer
        /// Accurate to the nearest three kilometers.
        case threeKilometers
    }

    // MARK: - Location

    /// A geographic coordinate with altitude and accuracy metadata.
    public struct PrismLocation: Sendable {
        /// The latitude in degrees.
        public let latitude: Double
        /// The longitude in degrees.
        public let longitude: Double
        /// The altitude in meters above sea level, if available.
        public let altitude: Double?
        /// The radius of uncertainty for the location in meters.
        public let horizontalAccuracy: Double
        /// The time at which this location was determined.
        public let timestamp: Date

        /// Creates a new location with the given coordinate and optional metadata.
        public init(
            latitude: Double, longitude: Double, altitude: Double? = nil, horizontalAccuracy: Double = 0,
            timestamp: Date = Date()
        ) {
            self.latitude = latitude
            self.longitude = longitude
            self.altitude = altitude
            self.horizontalAccuracy = horizontalAccuracy
            self.timestamp = timestamp
        }
    }

    // MARK: - Geofence Region

    /// A circular geographic region used for geofence monitoring.
    public struct PrismGeofenceRegion: Sendable {
        /// Unique identifier for the geofence region.
        public let id: String
        /// The latitude of the region center in degrees.
        public let latitude: Double
        /// The longitude of the region center in degrees.
        public let longitude: Double
        /// The radius of the region in meters.
        public let radius: Double
        /// Whether to trigger notifications on entry.
        public let notifyOnEntry: Bool
        /// Whether to trigger notifications on exit.
        public let notifyOnExit: Bool

        /// Creates a new geofence region with the given center, radius, and notification triggers.
        public init(
            id: String, latitude: Double, longitude: Double, radius: Double, notifyOnEntry: Bool = true,
            notifyOnExit: Bool = true
        ) {
            self.id = id
            self.latitude = latitude
            self.longitude = longitude
            self.radius = radius
            self.notifyOnEntry = notifyOnEntry
            self.notifyOnExit = notifyOnExit
        }
    }

    // MARK: - Geocoding Result

    /// A result from forward or reverse geocoding containing address components.
    public struct PrismGeocodingResult: Sendable {
        /// The name of the place (e.g., building or landmark).
        public let name: String?
        /// The city or locality name.
        public let locality: String?
        /// The state or administrative area name.
        public let administrativeArea: String?
        /// The country name.
        public let country: String?
        /// The postal or ZIP code.
        public let postalCode: String?
        /// The coordinate associated with this geocoding result.
        public let coordinate: PrismLocation?

        /// Creates a new geocoding result with the given address components and coordinate.
        public init(
            name: String? = nil, locality: String? = nil, administrativeArea: String? = nil, country: String? = nil,
            postalCode: String? = nil, coordinate: PrismLocation? = nil
        ) {
            self.name = name
            self.locality = locality
            self.administrativeArea = administrativeArea
            self.country = country
            self.postalCode = postalCode
            self.coordinate = coordinate
        }
    }

    // MARK: - Location Client

    /// Observable client for Core Location authorization, updates, geofencing, and geocoding.
    @MainActor @Observable
    public final class PrismLocationClient: NSObject, Sendable {
        /// The most recently received location, or nil if unavailable.
        public private(set) var currentLocation: PrismLocation?
        /// The current location authorization status.
        public private(set) var permissionStatus: PrismLocationPermission = .notDetermined

        private let manager = CLLocationManager()

        private var permissionContinuation: CheckedContinuation<PrismLocationPermission, Never>?
        private var locationContinuation: CheckedContinuation<PrismLocation, any Error>?

        /// Creates a new location client and begins observing authorization changes.
        public override init() {
            super.init()
            manager.delegate = self
            syncPermissionStatus()
        }

        /// Requests location authorization, optionally requesting always-on access.
        public func requestPermission(always: Bool = false) async -> PrismLocationPermission {
            if always {
                manager.requestAlwaysAuthorization()
            } else {
                manager.requestWhenInUseAuthorization()
            }
            return await withCheckedContinuation { continuation in
                permissionContinuation = continuation
            }
        }

        /// Requests a single location fix and returns it.
        public func requestLocation() async throws -> PrismLocation {
            try await withCheckedThrowingContinuation { continuation in
                locationContinuation = continuation
                manager.requestLocation()
            }
        }

        /// Starts continuous location updates at the specified accuracy level.
        public func startUpdating(accuracy: PrismLocationAccuracy = .best) {
            manager.desiredAccuracy = accuracy.clAccuracy
            manager.startUpdatingLocation()
        }

        /// Stops continuous location updates.
        public func stopUpdating() {
            manager.stopUpdatingLocation()
        }

        /// Starts monitoring the specified geofence region for entry and exit events.
        public func startMonitoring(region: PrismGeofenceRegion) {
            let clRegion = CLCircularRegion(
                center: CLLocationCoordinate2D(latitude: region.latitude, longitude: region.longitude),
                radius: region.radius,
                identifier: region.id
            )
            clRegion.notifyOnEntry = region.notifyOnEntry
            clRegion.notifyOnExit = region.notifyOnExit
            manager.startMonitoring(for: clRegion)
        }

        /// Stops monitoring the specified geofence region.
        public func stopMonitoring(region: PrismGeofenceRegion) {
            let clRegion = CLCircularRegion(
                center: CLLocationCoordinate2D(latitude: region.latitude, longitude: region.longitude),
                radius: region.radius,
                identifier: region.id
            )
            manager.stopMonitoring(for: clRegion)
        }

        /// Geocodes an address string into geographic coordinates and address components.
        public func geocode(address: String) async throws -> [PrismGeocodingResult] {
            #if canImport(MapKit)
                guard let request = MKGeocodingRequest(addressString: address) else {
                    return []
                }
                let items = try await request.mapItems
                return items.map { $0.toPrismGeocodingResult() }
            #else
                return []
            #endif
        }

        /// Reverse-geocodes a location into address components.
        public func reverseGeocode(location: PrismLocation) async throws -> [PrismGeocodingResult] {
            #if canImport(MapKit)
                let clLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
                guard let request = MKReverseGeocodingRequest(location: clLocation) else {
                    return []
                }
                let items = try await request.mapItems
                return items.map { $0.toPrismGeocodingResult() }
            #else
                return []
            #endif
        }

        // MARK: - Private

        private func syncPermissionStatus() {
            permissionStatus = CLLocationManager().authorizationStatus.toPrismPermission()
        }
    }

    // MARK: - CLLocationManagerDelegate

    extension PrismLocationClient: CLLocationManagerDelegate {
        /// Responds to authorization status changes from the location manager.
        public nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
            let status = manager.authorizationStatus.toPrismPermission()
            MainActor.assumeIsolated {
                permissionStatus = status
                permissionContinuation?.resume(returning: status)
                permissionContinuation = nil
            }
        }

        /// Processes updated locations from the location manager.
        public nonisolated func locationManager(
            _ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]
        ) {
            MainActor.assumeIsolated {
                guard let clLocation = locations.last else { return }
                let location = clLocation.toPrismLocation()
                currentLocation = location
                locationContinuation?.resume(returning: location)
                locationContinuation = nil
            }
        }

        /// Handles location manager errors.
        public nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
            MainActor.assumeIsolated {
                locationContinuation?.resume(throwing: error)
                locationContinuation = nil
            }
        }
    }

    // MARK: - Private Extensions

    extension CLAuthorizationStatus {
        fileprivate func toPrismPermission() -> PrismLocationPermission {
            switch self {
            case .notDetermined: .notDetermined
            case .restricted: .restricted
            case .denied: .denied
            case .authorizedWhenInUse: .authorizedWhenInUse
            case .authorizedAlways: .authorizedAlways
            @unknown default: .notDetermined
            }
        }
    }

    extension CLLocation {
        fileprivate func toPrismLocation() -> PrismLocation {
            PrismLocation(
                latitude: coordinate.latitude,
                longitude: coordinate.longitude,
                altitude: altitude,
                horizontalAccuracy: horizontalAccuracy,
                timestamp: timestamp
            )
        }
    }

    #if canImport(MapKit)
        extension MKMapItem {
            fileprivate func toPrismGeocodingResult() -> PrismGeocodingResult {
                PrismGeocodingResult(
                    name: name,
                    coordinate: location.toPrismLocation()
                )
            }
        }
    #endif

    extension PrismLocationAccuracy {
        fileprivate var clAccuracy: CLLocationAccuracy {
            switch self {
            case .best: kCLLocationAccuracyBest
            case .nearestTenMeters: kCLLocationAccuracyNearestTenMeters
            case .hundredMeters: kCLLocationAccuracyHundredMeters
            case .kilometer: kCLLocationAccuracyKilometer
            case .threeKilometers: kCLLocationAccuracyThreeKilometers
            }
        }
    }
#endif
