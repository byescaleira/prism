import Foundation
import Testing

@testable import PrismCapabilities

// MARK: - Motion Tests

@Suite("PrismMotion")
struct PrismMotionTests {

    // MARK: - Accelerometer Data

    @Test("PrismAccelerometerData stores properties correctly")
    func accelerometerDataProperties() {
        let now = Date()
        let data = PrismAccelerometerData(x: 0.1, y: -0.5, z: 9.8, timestamp: now)
        #expect(data.x == 0.1)
        #expect(data.y == -0.5)
        #expect(data.z == 9.8)
        #expect(data.timestamp == now)
    }

    @Test("PrismAccelerometerData supports zero values")
    func accelerometerDataZero() {
        let data = PrismAccelerometerData(x: 0, y: 0, z: 0, timestamp: Date())
        #expect(data.x == 0)
        #expect(data.y == 0)
        #expect(data.z == 0)
    }

    // MARK: - Gyroscope Data

    @Test("PrismGyroscopeData stores properties correctly")
    func gyroscopeDataProperties() {
        let now = Date()
        let data = PrismGyroscopeData(x: 1.2, y: -0.3, z: 0.7, timestamp: now)
        #expect(data.x == 1.2)
        #expect(data.y == -0.3)
        #expect(data.z == 0.7)
        #expect(data.timestamp == now)
    }

    @Test("PrismGyroscopeData supports negative values")
    func gyroscopeDataNegative() {
        let data = PrismGyroscopeData(x: -3.14, y: -2.71, z: -1.0, timestamp: Date())
        #expect(data.x == -3.14)
        #expect(data.y == -2.71)
        #expect(data.z == -1.0)
    }

    // MARK: - Attitude

    @Test("PrismAttitude stores properties correctly")
    func attitudeProperties() {
        let attitude = PrismAttitude(roll: 0.5, pitch: -0.3, yaw: 1.57)
        #expect(attitude.roll == 0.5)
        #expect(attitude.pitch == -0.3)
        #expect(attitude.yaw == 1.57)
    }

    @Test("PrismAttitude supports full rotation values")
    func attitudeFullRotation() {
        let attitude = PrismAttitude(roll: .pi, pitch: -.pi, yaw: 2 * .pi)
        #expect(attitude.roll == .pi)
        #expect(attitude.pitch == -.pi)
        #expect(attitude.yaw == 2 * .pi)
    }

    // MARK: - Device Motion

    @Test("PrismDeviceMotion stores properties correctly")
    func deviceMotionProperties() {
        let now = Date()
        let attitude = PrismAttitude(roll: 0.1, pitch: 0.2, yaw: 0.3)
        let rotation = PrismGyroscopeData(x: 0.4, y: 0.5, z: 0.6, timestamp: now)
        let gravity = PrismAccelerometerData(x: 0.0, y: 0.0, z: -9.8, timestamp: now)
        let userAccel = PrismAccelerometerData(x: 0.1, y: -0.1, z: 0.0, timestamp: now)

        let motion = PrismDeviceMotion(
            attitude: attitude,
            rotationRate: rotation,
            gravity: gravity,
            userAcceleration: userAccel
        )

        #expect(motion.attitude.roll == 0.1)
        #expect(motion.attitude.pitch == 0.2)
        #expect(motion.attitude.yaw == 0.3)
        #expect(motion.rotationRate.x == 0.4)
        #expect(motion.rotationRate.y == 0.5)
        #expect(motion.rotationRate.z == 0.6)
        #expect(motion.gravity.z == -9.8)
        #expect(motion.userAcceleration.x == 0.1)
        #expect(motion.userAcceleration.y == -0.1)
    }

    // MARK: - Pedometer Data

    @Test("PrismPedometerData stores properties correctly")
    func pedometerDataProperties() {
        let start = Date()
        let end = Date().addingTimeInterval(3600)
        let data = PrismPedometerData(
            steps: 5000,
            distance: 3200.5,
            floorsAscended: 3,
            floorsDescended: 1,
            startDate: start,
            endDate: end
        )
        #expect(data.steps == 5000)
        #expect(data.distance == 3200.5)
        #expect(data.floorsAscended == 3)
        #expect(data.floorsDescended == 1)
        #expect(data.startDate == start)
        #expect(data.endDate == end)
    }

    @Test("PrismPedometerData defaults optional fields to nil")
    func pedometerDataDefaults() {
        let start = Date()
        let end = Date().addingTimeInterval(1800)
        let data = PrismPedometerData(steps: 100, startDate: start, endDate: end)
        #expect(data.distance == nil)
        #expect(data.floorsAscended == nil)
        #expect(data.floorsDescended == nil)
    }

    // MARK: - Activity Type

    @Test("PrismActivityType has 6 cases")
    func activityTypeCaseCount() {
        #expect(PrismActivityType.allCases.count == 6)
    }

    @Test("PrismActivityType includes all expected cases")
    func activityTypeCases() {
        let cases = PrismActivityType.allCases
        #expect(cases.contains(.stationary))
        #expect(cases.contains(.walking))
        #expect(cases.contains(.running))
        #expect(cases.contains(.cycling))
        #expect(cases.contains(.automotive))
        #expect(cases.contains(.unknown))
    }

    // MARK: - Altitude Data

    @Test("PrismAltitudeData stores properties correctly")
    func altitudeDataProperties() {
        let now = Date()
        let data = PrismAltitudeData(relativeAltitude: 12.5, pressure: 101.3, timestamp: now)
        #expect(data.relativeAltitude == 12.5)
        #expect(data.pressure == 101.3)
        #expect(data.timestamp == now)
    }

    @Test("PrismAltitudeData supports negative altitude")
    func altitudeDataNegative() {
        let data = PrismAltitudeData(relativeAltitude: -5.0, pressure: 102.1, timestamp: Date())
        #expect(data.relativeAltitude == -5.0)
        #expect(data.pressure == 102.1)
    }
}
