import Foundation

#if canImport(CoreMotion) && (os(iOS) || os(watchOS))
    import CoreMotion

    /// Observable client for accessing CoreMotion sensors: accelerometer, gyroscope, device motion,
    /// pedometer, activity classification, and altimeter.
    ///
    /// `PrismMotionClient` wraps `CMMotionManager`, `CMPedometer`, `CMMotionActivityManager`, and
    /// `CMAltimeter` behind a single `@Observable` interface. Published properties update on the main
    /// actor so SwiftUI views can bind directly.
    ///
    /// ```swift
    /// @State private var motion = PrismMotionClient()
    ///
    /// var body: some View {
    ///     VStack {
    ///         if let accel = motion.latestAccelerometer {
    ///             Text("X: \(accel.x, specifier: "%.2f")")
    ///         }
    ///     }
    ///     .onAppear { motion.startAccelerometerUpdates(interval: 0.1) }
    ///     .onDisappear { motion.stopAccelerometerUpdates() }
    /// }
    /// ```
    @MainActor @Observable
    public final class PrismMotionClient {
        private let motionManager = CMMotionManager()
        private let pedometer = CMPedometer()
        private let activityManager = CMMotionActivityManager()
        private let altimeter = CMAltimeter()

        // MARK: - Availability

        /// Whether the accelerometer hardware is available on this device.
        public var isAccelerometerAvailable: Bool { motionManager.isAccelerometerAvailable }

        /// Whether the gyroscope hardware is available on this device.
        public var isGyroscopeAvailable: Bool { motionManager.isGyroscopeAvailable }

        /// Whether device motion (sensor fusion) is available on this device.
        public var isDeviceMotionAvailable: Bool { motionManager.isDeviceMotionAvailable }

        /// Whether pedometer step counting is available on this device.
        public var isPedometerAvailable: Bool { CMPedometer.isStepCountingAvailable() }

        // MARK: - Latest Readings

        /// The most recent accelerometer reading, or `nil` if updates have not started.
        public private(set) var latestAccelerometer: PrismAccelerometerData?

        /// The most recent gyroscope reading, or `nil` if updates have not started.
        public private(set) var latestGyroscope: PrismGyroscopeData?

        /// The most recent device motion reading, or `nil` if updates have not started.
        public private(set) var latestMotion: PrismDeviceMotion?

        /// The user's current activity classification.
        public private(set) var currentActivity: PrismActivityType = .unknown

        /// The most recent altitude reading, or `nil` if updates have not started.
        public private(set) var latestAltitude: PrismAltitudeData?

        /// Creates a new motion client.
        public init() {}

        // MARK: - Accelerometer

        /// Starts accelerometer updates at the specified interval in seconds.
        ///
        /// - Parameter interval: The time between updates in seconds (e.g., 0.1 for 10 Hz).
        public func startAccelerometerUpdates(interval: TimeInterval) {
            motionManager.accelerometerUpdateInterval = interval
            motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, _ in
                guard let self, let data else { return }
                MainActor.assumeIsolated {
                    self.latestAccelerometer = PrismAccelerometerData(
                        x: data.acceleration.x,
                        y: data.acceleration.y,
                        z: data.acceleration.z,
                        timestamp: Date(timeIntervalSinceReferenceDate: data.timestamp)
                    )
                }
            }
        }

        /// Stops accelerometer updates and clears the latest reading.
        public func stopAccelerometerUpdates() {
            motionManager.stopAccelerometerUpdates()
            latestAccelerometer = nil
        }

        // MARK: - Gyroscope

        /// Starts gyroscope updates at the specified interval in seconds.
        ///
        /// - Parameter interval: The time between updates in seconds.
        public func startGyroscopeUpdates(interval: TimeInterval) {
            motionManager.gyroUpdateInterval = interval
            motionManager.startGyroUpdates(to: .main) { [weak self] data, _ in
                guard let self, let data else { return }
                MainActor.assumeIsolated {
                    self.latestGyroscope = PrismGyroscopeData(
                        x: data.rotationRate.x,
                        y: data.rotationRate.y,
                        z: data.rotationRate.z,
                        timestamp: Date(timeIntervalSinceReferenceDate: data.timestamp)
                    )
                }
            }
        }

        /// Stops gyroscope updates and clears the latest reading.
        public func stopGyroscopeUpdates() {
            motionManager.stopGyroUpdates()
            latestGyroscope = nil
        }

        // MARK: - Device Motion

        /// Starts device motion updates at the specified interval in seconds.
        ///
        /// Device motion fuses accelerometer and gyroscope data for higher accuracy.
        ///
        /// - Parameter interval: The time between updates in seconds.
        public func startDeviceMotionUpdates(interval: TimeInterval) {
            motionManager.deviceMotionUpdateInterval = interval
            motionManager.startDeviceMotionUpdates(to: .main) { [weak self] data, _ in
                guard let self, let data else { return }
                let timestamp = Date(timeIntervalSinceReferenceDate: data.timestamp)
                MainActor.assumeIsolated {
                    self.latestMotion = PrismDeviceMotion(
                        attitude: PrismAttitude(
                            roll: data.attitude.roll,
                            pitch: data.attitude.pitch,
                            yaw: data.attitude.yaw
                        ),
                        rotationRate: PrismGyroscopeData(
                            x: data.rotationRate.x,
                            y: data.rotationRate.y,
                            z: data.rotationRate.z,
                            timestamp: timestamp
                        ),
                        gravity: PrismAccelerometerData(
                            x: data.gravity.x,
                            y: data.gravity.y,
                            z: data.gravity.z,
                            timestamp: timestamp
                        ),
                        userAcceleration: PrismAccelerometerData(
                            x: data.userAcceleration.x,
                            y: data.userAcceleration.y,
                            z: data.userAcceleration.z,
                            timestamp: timestamp
                        )
                    )
                }
            }
        }

        /// Stops device motion updates and clears the latest reading.
        public func stopDeviceMotionUpdates() {
            motionManager.stopDeviceMotionUpdates()
            latestMotion = nil
        }

        // MARK: - Pedometer

        /// Queries pedometer data for the specified date range.
        ///
        /// - Parameters:
        ///   - from: The start date of the query range.
        ///   - to: The end date of the query range.
        /// - Returns: Aggregated pedometer data for the period.
        /// - Throws: An error if pedometer data is unavailable or the query fails.
        public func queryPedometer(from: Date, to: Date) async throws -> PrismPedometerData {
            try await withCheckedThrowingContinuation { continuation in
                pedometer.queryPedometerData(from: from, to: to) { data, error in
                    if let error {
                        continuation.resume(throwing: error)
                        return
                    }
                    guard let data else {
                        continuation.resume(throwing: PrismMotionError.noData)
                        return
                    }
                    let result = PrismPedometerData(
                        steps: data.numberOfSteps.intValue,
                        distance: data.distance?.doubleValue,
                        floorsAscended: data.floorsAscended?.intValue,
                        floorsDescended: data.floorsDescended?.intValue,
                        startDate: data.startDate,
                        endDate: data.endDate
                    )
                    continuation.resume(returning: result)
                }
            }
        }

        // MARK: - Activity

        /// Starts activity classification updates (stationary, walking, running, etc.).
        public func startActivityUpdates() {
            activityManager.startActivityUpdates(to: .main) { [weak self] activity in
                guard let self, let activity else { return }
                MainActor.assumeIsolated {
                    self.currentActivity = activity.prismActivityType
                }
            }
        }

        /// Stops activity classification updates and resets to `.unknown`.
        public func stopActivityUpdates() {
            activityManager.stopActivityUpdates()
            currentActivity = .unknown
        }

        // MARK: - Altitude

        /// Starts relative altitude and pressure updates from the barometric altimeter.
        public func startAltitudeUpdates() {
            altimeter.startRelativeAltitudeUpdates(to: .main) { [weak self] data, _ in
                guard let self, let data else { return }
                MainActor.assumeIsolated {
                    self.latestAltitude = PrismAltitudeData(
                        relativeAltitude: data.relativeAltitude.doubleValue,
                        pressure: data.pressure.doubleValue,
                        timestamp: Date()
                    )
                }
            }
        }

        /// Stops altitude updates and clears the latest reading.
        public func stopAltitudeUpdates() {
            altimeter.stopRelativeAltitudeUpdates()
            latestAltitude = nil
        }
    }

    // MARK: - Motion Error

    /// Errors specific to PrismMotionClient operations.
    enum PrismMotionError: Error {
        case noData
    }

    // MARK: - Private Extensions

    extension CMMotionActivity {
        /// Maps a CoreMotion activity to the corresponding `PrismActivityType`.
        fileprivate var prismActivityType: PrismActivityType {
            if automotive { return .automotive }
            if cycling { return .cycling }
            if running { return .running }
            if walking { return .walking }
            if stationary { return .stationary }
            return .unknown
        }
    }
#endif
