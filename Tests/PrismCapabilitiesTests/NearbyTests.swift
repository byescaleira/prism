import Foundation
import Testing

@testable import PrismCapabilities

// MARK: - NearbyInteraction Tests

@Suite("PrismNearbyInteraction")
struct PrismNearbyInteractionTests {

    @Test("PrismNearbySessionState has 4 cases")
    func sessionStateCaseCount() {
        #expect(PrismNearbySessionState.allCases.count == 4)
    }

    @Test("PrismNearbySessionState includes all expected cases")
    func sessionStateCases() {
        let cases = PrismNearbySessionState.allCases
        #expect(cases.contains(.idle))
        #expect(cases.contains(.running))
        #expect(cases.contains(.suspended))
        #expect(cases.contains(.invalidated))
    }

    @Test("PrismNearbyObject stores peerToken")
    func nearbyObjectPeerToken() {
        let token = Data([0xAA, 0xBB, 0xCC])
        let obj = PrismNearbyObject(peerToken: token)
        #expect(obj.peerToken == token)
    }

    @Test("PrismNearbyObject stores distance")
    func nearbyObjectDistance() {
        let obj = PrismNearbyObject(peerToken: Data([0x01]), distance: 2.5)
        #expect(obj.distance == 2.5)
    }

    @Test("PrismNearbyObject stores direction")
    func nearbyObjectDirection() {
        let dir = SIMD3<Float>(0.0, 1.0, 0.0)
        let obj = PrismNearbyObject(peerToken: Data([0x01]), direction: dir)
        #expect(obj.direction == dir)
    }

    @Test("PrismNearbyObject defaults distance and direction to nil")
    func nearbyObjectDefaults() {
        let obj = PrismNearbyObject(peerToken: Data([0x01]))
        #expect(obj.distance == nil)
        #expect(obj.direction == nil)
    }

    @Test("PrismNearbyObject stores all properties together")
    func nearbyObjectAllProperties() {
        let token = Data([0xDE, 0xAD])
        let distance: Float = 1.75
        let direction = SIMD3<Float>(0.5, 0.5, 0.0)
        let obj = PrismNearbyObject(peerToken: token, distance: distance, direction: direction)
        #expect(obj.peerToken == token)
        #expect(obj.distance == distance)
        #expect(obj.direction == direction)
    }
}

// MARK: - MultipeerConnectivity Tests

@Suite("PrismMultipeerConnectivity")
struct PrismMultipeerConnectivityTests {

    @Test("PrismMultipeerState has 3 cases")
    func multipeerStateCaseCount() {
        #expect(PrismMultipeerState.allCases.count == 3)
    }

    @Test("PrismMultipeerState includes all expected cases")
    func multipeerStateCases() {
        let cases = PrismMultipeerState.allCases
        #expect(cases.contains(.notConnected))
        #expect(cases.contains(.connecting))
        #expect(cases.contains(.connected))
    }

    @Test("PrismPeer stores id")
    func peerStoresId() {
        let peer = PrismPeer(id: "peer-001", displayName: "Alice")
        #expect(peer.id == "peer-001")
    }

    @Test("PrismPeer stores displayName")
    func peerStoresDisplayName() {
        let peer = PrismPeer(id: "peer-002", displayName: "Bob's iPhone")
        #expect(peer.displayName == "Bob's iPhone")
    }

    @Test("PrismPeer stores isConnected")
    func peerStoresIsConnected() {
        let peer = PrismPeer(id: "peer-003", displayName: "Carol", isConnected: true)
        #expect(peer.isConnected == true)
    }

    @Test("PrismPeer defaults isConnected to false")
    func peerDefaultIsConnected() {
        let peer = PrismPeer(id: "peer-004", displayName: "Dave")
        #expect(peer.isConnected == false)
    }

    @Test("PrismPeer stores all properties together")
    func peerAllProperties() {
        let peer = PrismPeer(id: "peer-005", displayName: "Eve's iPad", isConnected: true)
        #expect(peer.id == "peer-005")
        #expect(peer.displayName == "Eve's iPad")
        #expect(peer.isConnected == true)
    }
}
