import Foundation
import Testing

@testable import PrismCapabilities

// MARK: - Location Permission Tests

@Suite("PrismLocationPermission")
struct PrismLocationPermissionTests {

    @Test("PrismLocationPermission has 5 cases")
    func permissionCaseCount() {
        #expect(PrismLocationPermission.allCases.count == 5)
    }

    @Test("PrismLocationPermission includes all expected cases")
    func permissionCases() {
        let cases = PrismLocationPermission.allCases
        #expect(cases.contains(.notDetermined))
        #expect(cases.contains(.restricted))
        #expect(cases.contains(.denied))
        #expect(cases.contains(.authorizedWhenInUse))
        #expect(cases.contains(.authorizedAlways))
    }
}

// MARK: - Location Accuracy Tests

@Suite("PrismLocationAccuracy")
struct PrismLocationAccuracyTests {

    @Test("PrismLocationAccuracy has 5 cases")
    func accuracyCaseCount() {
        let cases: [PrismLocationAccuracy] = [.best, .nearestTenMeters, .hundredMeters, .kilometer, .threeKilometers]
        #expect(cases.count == 5)
    }
}

// MARK: - Location Tests

@Suite("PrismLocation")
struct PrismLocationTests {

    @Test("PrismLocation stores properties correctly")
    func locationProperties() {
        let date = Date()
        let location = PrismLocation(
            latitude: 37.7749,
            longitude: -122.4194,
            altitude: 15.5,
            horizontalAccuracy: 10.0,
            timestamp: date
        )
        #expect(location.latitude == 37.7749)
        #expect(location.longitude == -122.4194)
        #expect(location.altitude == 15.5)
        #expect(location.horizontalAccuracy == 10.0)
        #expect(location.timestamp == date)
    }

    @Test("PrismLocation defaults")
    func locationDefaults() {
        let location = PrismLocation(latitude: 0.0, longitude: 0.0)
        #expect(location.altitude == nil)
        #expect(location.horizontalAccuracy == 0)
    }
}

// MARK: - Geofence Region Tests

@Suite("PrismGeofenceRegion")
struct PrismGeofenceRegionTests {

    @Test("PrismGeofenceRegion stores properties correctly")
    func regionProperties() {
        let region = PrismGeofenceRegion(
            id: "office",
            latitude: 40.7128,
            longitude: -74.0060,
            radius: 200,
            notifyOnEntry: true,
            notifyOnExit: false
        )
        #expect(region.id == "office")
        #expect(region.latitude == 40.7128)
        #expect(region.longitude == -74.0060)
        #expect(region.radius == 200)
        #expect(region.notifyOnEntry == true)
        #expect(region.notifyOnExit == false)
    }

    @Test("PrismGeofenceRegion defaults")
    func regionDefaults() {
        let region = PrismGeofenceRegion(id: "test", latitude: 0, longitude: 0, radius: 100)
        #expect(region.notifyOnEntry == true)
        #expect(region.notifyOnExit == true)
    }
}

// MARK: - Geocoding Result Tests

@Suite("PrismGeocodingResult")
struct PrismGeocodingResultTests {

    @Test("PrismGeocodingResult stores properties correctly")
    func resultProperties() {
        let coord = PrismLocation(latitude: 48.8566, longitude: 2.3522)
        let result = PrismGeocodingResult(
            name: "Eiffel Tower",
            locality: "Paris",
            administrativeArea: "Ile-de-France",
            country: "France",
            postalCode: "75007",
            coordinate: coord
        )
        #expect(result.name == "Eiffel Tower")
        #expect(result.locality == "Paris")
        #expect(result.administrativeArea == "Ile-de-France")
        #expect(result.country == "France")
        #expect(result.postalCode == "75007")
        #expect(result.coordinate?.latitude == 48.8566)
        #expect(result.coordinate?.longitude == 2.3522)
    }

    @Test("PrismGeocodingResult defaults")
    func resultDefaults() {
        let result = PrismGeocodingResult()
        #expect(result.name == nil)
        #expect(result.locality == nil)
        #expect(result.administrativeArea == nil)
        #expect(result.country == nil)
        #expect(result.postalCode == nil)
        #expect(result.coordinate == nil)
    }
}

// MARK: - Map Transport Type Tests

@Suite("PrismMapTransportType")
struct PrismMapTransportTypeTests {

    @Test("PrismMapTransportType has 4 cases")
    func transportTypeCaseCount() {
        #expect(PrismMapTransportType.allCases.count == 4)
    }

    @Test("PrismMapTransportType includes all expected cases")
    func transportTypeCases() {
        let cases = PrismMapTransportType.allCases
        #expect(cases.contains(.automobile))
        #expect(cases.contains(.walking))
        #expect(cases.contains(.transit))
        #expect(cases.contains(.cycling))
    }
}

// MARK: - Map Route Tests

@Suite("PrismMapRoute")
struct PrismMapRouteTests {

    @Test("PrismMapRoute stores properties correctly")
    func routeProperties() {
        let route = PrismMapRoute(
            distance: 15200.5,
            expectedTravelTime: 1800,
            name: "I-280 S"
        )
        #expect(route.distance == 15200.5)
        #expect(route.expectedTravelTime == 1800)
        #expect(route.name == "I-280 S")
    }
}

// MARK: - POI Tests

@Suite("PrismPOI")
struct PrismPOITests {

    @Test("PrismPOI stores properties correctly")
    func poiProperties() {
        let coord = PrismLocation(latitude: 34.0522, longitude: -118.2437)
        let poi = PrismPOI(name: "Coffee Shop", coordinate: coord, category: "cafe")
        #expect(poi.name == "Coffee Shop")
        #expect(poi.coordinate.latitude == 34.0522)
        #expect(poi.coordinate.longitude == -118.2437)
        #expect(poi.category == "cafe")
    }

    @Test("PrismPOI defaults")
    func poiDefaults() {
        let coord = PrismLocation(latitude: 0, longitude: 0)
        let poi = PrismPOI(name: "Test", coordinate: coord)
        #expect(poi.category == nil)
    }
}
