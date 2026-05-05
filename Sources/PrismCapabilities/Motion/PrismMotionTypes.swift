import Foundation

// MARK: - Accelerometer Data

/// Represents a single accelerometer reading with x, y, z axes and timestamp.
///
/// Each axis value is measured in G-forces. Use with `PrismMotionClient.startAccelerometerUpdates(interval:)`
/// to receive continuous updates.
///
/// ```swift
/// let client = PrismMotionClient()
/// client.startAccelerometerUpdates(interval: 0.1)
/// if let data = client.latestAccelerometer {
///     print("X: \(data.x), Y: \(data.y), Z: \(data.z)")
/// }
/// ```
public struct PrismAccelerometerData: Sendable {
    /// Acceleration along the x-axis in G-forces.
    public let x: Double
    /// Acceleration along the y-axis in G-forces.
    public let y: Double
    /// Acceleration along the z-axis in G-forces.
    public let z: Double
    /// The timestamp when this reading was captured.
    public let timestamp: Date

    /// Creates a new accelerometer data point with the given axis values and timestamp.
    public init(x: Double, y: Double, z: Double, timestamp: Date) {
        self.x = x
        self.y = y
        self.z = z
        self.timestamp = timestamp
    }
}

// MARK: - Gyroscope Data

/// Represents a single gyroscope reading with rotation rates around x, y, z axes.
///
/// Each axis value is measured in radians per second. Use with
/// `PrismMotionClient.startGyroscopeUpdates(interval:)` for continuous rotation data.
public struct PrismGyroscopeData: Sendable {
    /// Rotation rate around the x-axis in radians/second.
    public let x: Double
    /// Rotation rate around the y-axis in radians/second.
    public let y: Double
    /// Rotation rate around the z-axis in radians/second.
    public let z: Double
    /// The timestamp when this reading was captured.
    public let timestamp: Date

    /// Creates a new gyroscope data point with the given rotation rates and timestamp.
    public init(x: Double, y: Double, z: Double, timestamp: Date) {
        self.x = x
        self.y = y
        self.z = z
        self.timestamp = timestamp
    }
}

// MARK: - Attitude

/// Represents the device's orientation in 3D space using Euler angles.
///
/// Roll, pitch, and yaw are measured in radians. Derived from the device motion
/// sensor fusion of accelerometer and gyroscope data.
public struct PrismAttitude: Sendable {
    /// Rotation around the longitudinal axis (front-to-back) in radians.
    public let roll: Double
    /// Rotation around the lateral axis (side-to-side) in radians.
    public let pitch: Double
    /// Rotation around the vertical axis (top-to-bottom) in radians.
    public let yaw: Double

    /// Creates a new attitude with the given Euler angles in radians.
    public init(roll: Double, pitch: Double, yaw: Double) {
        self.roll = roll
        self.pitch = pitch
        self.yaw = yaw
    }
}

// MARK: - Device Motion

/// Combined motion data from sensor fusion: attitude, rotation rate, gravity, and user acceleration.
///
/// Device motion provides higher-quality data than raw accelerometer or gyroscope alone
/// because CoreMotion fuses multiple sensor inputs to reduce noise.
///
/// ```swift
/// let client = PrismMotionClient()
/// client.startDeviceMotionUpdates(interval: 0.05)
/// if let motion = client.latestMotion {
///     print("Pitch: \(motion.attitude.pitch)")
///     print("User accel X: \(motion.userAcceleration.x)")
/// }
/// ```
public struct PrismDeviceMotion: Sendable {
    /// The device's current attitude (orientation) in 3D space.
    public let attitude: PrismAttitude
    /// The rotation rate as reported by the gyroscope, bias-removed via sensor fusion.
    public let rotationRate: PrismGyroscopeData
    /// The gravity vector, isolated from user acceleration.
    public let gravity: PrismAccelerometerData
    /// The acceleration the user applies to the device, with gravity removed.
    public let userAcceleration: PrismAccelerometerData

    /// Creates a new device motion reading with the given sensor fusion data.
    public init(
        attitude: PrismAttitude,
        rotationRate: PrismGyroscopeData,
        gravity: PrismAccelerometerData,
        userAcceleration: PrismAccelerometerData
    ) {
        self.attitude = attitude
        self.rotationRate = rotationRate
        self.gravity = gravity
        self.userAcceleration = userAcceleration
    }
}

// MARK: - Pedometer Data

/// Step counting and distance data from the device pedometer over a time range.
///
/// Query historical pedometer data with `PrismMotionClient.queryPedometer(from:to:)`.
public struct PrismPedometerData: Sendable {
    /// Total number of steps in the time range.
    public let steps: Int
    /// Estimated distance traveled in meters, if available.
    public let distance: Double?
    /// Number of floors ascended, if available.
    public let floorsAscended: Int?
    /// Number of floors descended, if available.
    public let floorsDescended: Int?
    /// The start of the measurement period.
    public let startDate: Date
    /// The end of the measurement period.
    public let endDate: Date

    /// Creates a new pedometer data snapshot with the given step count and optional metrics.
    public init(
        steps: Int,
        distance: Double? = nil,
        floorsAscended: Int? = nil,
        floorsDescended: Int? = nil,
        startDate: Date,
        endDate: Date
    ) {
        self.steps = steps
        self.distance = distance
        self.floorsAscended = floorsAscended
        self.floorsDescended = floorsDescended
        self.startDate = startDate
        self.endDate = endDate
    }
}

// MARK: - Activity Type

/// The user's current physical activity as classified by CoreMotion.
///
/// Use `PrismMotionClient.startActivityUpdates()` to receive continuous activity classification.
public enum PrismActivityType: Sendable, CaseIterable {
    /// The user is stationary (not moving).
    case stationary
    /// The user is walking.
    case walking
    /// The user is running.
    case running
    /// The user is cycling.
    case cycling
    /// The user is in a vehicle.
    case automotive
    /// The activity could not be determined.
    case unknown
}

// MARK: - Altitude Data

/// Relative altitude and barometric pressure data from the device altimeter.
///
/// Relative altitude is measured in meters from the point where updates began.
/// Pressure is measured in kilopascals (kPa).
public struct PrismAltitudeData: Sendable {
    /// Change in altitude (meters) since altitude updates started.
    public let relativeAltitude: Double
    /// Barometric pressure in kilopascals.
    public let pressure: Double
    /// The timestamp when this reading was captured.
    public let timestamp: Date

    /// Creates a new altitude data point with the given altitude change and pressure.
    public init(relativeAltitude: Double, pressure: Double, timestamp: Date) {
        self.relativeAltitude = relativeAltitude
        self.pressure = pressure
        self.timestamp = timestamp
    }
}
