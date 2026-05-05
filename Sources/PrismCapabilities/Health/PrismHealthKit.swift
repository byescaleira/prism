#if canImport(HealthKit)
    import HealthKit

    // MARK: - Health Data Type

    /// Supported HealthKit data types for reading and writing.
    public enum PrismHealthDataType: Sendable, CaseIterable {
        /// Number of steps taken.
        case stepCount
        /// Heart rate in beats per minute.
        case heartRate
        /// Active energy burned in kilocalories.
        case activeEnergy
        /// Sleep analysis data.
        case sleepAnalysis
        /// Body mass in kilograms.
        case bodyMass
        /// Body height in centimeters.
        case height
        /// Blood oxygen saturation percentage.
        case bloodOxygen
        /// Respiratory rate in breaths per minute.
        case respiratoryRate
    }

    // MARK: - Health Sample

    /// A single HealthKit sample with type, value, unit, and time range.
    public struct PrismHealthSample: Sendable {
        /// The health data type of this sample.
        public let type: PrismHealthDataType
        /// The numeric value of the sample.
        public let value: Double
        /// The unit string (e.g., "count", "BPM", "kcal").
        public let unit: String
        /// The start date of the sample period.
        public let startDate: Date
        /// The end date of the sample period.
        public let endDate: Date

        /// Creates a new health sample with the given type, value, unit, and time range.
        public init(type: PrismHealthDataType, value: Double, unit: String, startDate: Date, endDate: Date) {
            self.type = type
            self.value = value
            self.unit = unit
            self.startDate = startDate
            self.endDate = endDate
        }
    }

    // MARK: - Health Statistics

    /// Aggregated statistics for a HealthKit data type over a time range.
    public struct PrismHealthStatistics: Sendable {
        /// The health data type these statistics describe.
        public let type: PrismHealthDataType
        /// The sum of all values, if applicable.
        public let sum: Double?
        /// The average of all values, if applicable.
        public let average: Double?
        /// The minimum value, if applicable.
        public let min: Double?
        /// The maximum value, if applicable.
        public let max: Double?
        /// The unit string for the values.
        public let unit: String

        /// Creates a new health statistics value with the given aggregated data.
        public init(
            type: PrismHealthDataType, sum: Double? = nil, average: Double? = nil, min: Double? = nil,
            max: Double? = nil, unit: String
        ) {
            self.type = type
            self.sum = sum
            self.average = average
            self.min = min
            self.max = max
            self.unit = unit
        }
    }

    // MARK: - Delivery Frequency

    /// How often HealthKit delivers background updates for observed data types.
    public enum PrismHealthDeliveryFrequency: Sendable {
        /// Deliver updates as soon as new data is available.
        case immediate
        /// Deliver updates at most once per hour.
        case hourly
        /// Deliver updates at most once per day.
        case daily
        /// Deliver updates at most once per week.
        case weekly
    }

    // MARK: - HealthKit Client

    /// Actor-isolated client for HealthKit authorization, queries, saving, and background delivery.
    public actor PrismHealthKitClient {
        private let store = HKHealthStore()

        /// Creates a new HealthKit client.
        public init() {}

        /// Returns whether HealthKit is available on this device.
        public func isAvailable() -> Bool {
            HKHealthStore.isHealthDataAvailable()
        }

        /// Requests authorization to read and write the specified data types.
        public func requestAuthorization(toRead: [PrismHealthDataType], toWrite: [PrismHealthDataType]) async throws {
            let readTypes = Set(toRead.compactMap { $0.hkSampleType })
            let writeTypes = Set(toWrite.compactMap { $0.hkSampleType })
            try await store.requestAuthorization(toShare: writeTypes, read: readTypes)
        }

        /// Queries samples of the specified type within the date range.
        public func querySamples(type: PrismHealthDataType, from: Date, to: Date, limit: Int = 100) async throws
            -> [PrismHealthSample]
        {
            guard let sampleType = type.hkQuantityType else { return [] }
            let predicate = HKQuery.predicateForSamples(withStart: from, end: to, options: .strictStartDate)
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

            return try await withCheckedThrowingContinuation { continuation in
                let query = HKSampleQuery(
                    sampleType: sampleType,
                    predicate: predicate,
                    limit: limit,
                    sortDescriptors: [sortDescriptor]
                ) { _, samples, error in
                    if let error {
                        continuation.resume(throwing: error)
                        return
                    }
                    let unit = type.defaultUnit
                    let results = (samples as? [HKQuantitySample] ?? []).map { sample in
                        PrismHealthSample(
                            type: type,
                            value: sample.quantity.doubleValue(for: unit),
                            unit: unit.unitString,
                            startDate: sample.startDate,
                            endDate: sample.endDate
                        )
                    }
                    continuation.resume(returning: results)
                }
                store.execute(query)
            }
        }

        /// Queries aggregated statistics for the specified type within the date range.
        public func queryStatistics(type: PrismHealthDataType, from: Date, to: Date) async throws
            -> PrismHealthStatistics
        {
            guard let quantityType = type.hkQuantityType else {
                return PrismHealthStatistics(type: type, unit: "")
            }
            let predicate = HKQuery.predicateForSamples(withStart: from, end: to, options: .strictStartDate)
            let unit = type.defaultUnit

            return try await withCheckedThrowingContinuation { continuation in
                let query = HKStatisticsQuery(
                    quantityType: quantityType,
                    quantitySamplePredicate: predicate,
                    options: [.cumulativeSum, .discreteAverage, .discreteMin, .discreteMax]
                ) { _, statistics, error in
                    if let error {
                        continuation.resume(throwing: error)
                        return
                    }
                    let result = PrismHealthStatistics(
                        type: type,
                        sum: statistics?.sumQuantity()?.doubleValue(for: unit),
                        average: statistics?.averageQuantity()?.doubleValue(for: unit),
                        min: statistics?.minimumQuantity()?.doubleValue(for: unit),
                        max: statistics?.maximumQuantity()?.doubleValue(for: unit),
                        unit: unit.unitString
                    )
                    continuation.resume(returning: result)
                }
                store.execute(query)
            }
        }

        /// Saves a health sample to the HealthKit store.
        public func save(sample: PrismHealthSample) async throws {
            guard let quantityType = sample.type.hkQuantityType else { return }
            let unit = sample.type.defaultUnit
            let quantity = HKQuantity(unit: unit, doubleValue: sample.value)
            let hkSample = HKQuantitySample(
                type: quantityType, quantity: quantity, start: sample.startDate, end: sample.endDate)
            try await store.save(hkSample)
        }

        /// Enables background delivery for the specified data type at the given frequency.
        public func enableBackgroundDelivery(type: PrismHealthDataType, frequency: PrismHealthDeliveryFrequency)
            async throws
        {
            guard let sampleType = type.hkSampleType else { return }
            let hkFrequency: HKUpdateFrequency =
                switch frequency {
                case .immediate: .immediate
                case .hourly: .hourly
                case .daily: .daily
                case .weekly: .weekly
                }
            try await store.enableBackgroundDelivery(for: sampleType, frequency: hkFrequency)
        }
    }

    // MARK: - Private Extensions

    extension PrismHealthDataType {
        fileprivate var hkQuantityType: HKQuantityType? {
            switch self {
            case .stepCount: HKQuantityType(.stepCount)
            case .heartRate: HKQuantityType(.heartRate)
            case .activeEnergy: HKQuantityType(.activeEnergyBurned)
            case .sleepAnalysis: nil
            case .bodyMass: HKQuantityType(.bodyMass)
            case .height: HKQuantityType(.height)
            case .bloodOxygen: HKQuantityType(.oxygenSaturation)
            case .respiratoryRate: HKQuantityType(.respiratoryRate)
            }
        }

        fileprivate var hkSampleType: HKSampleType? {
            switch self {
            case .sleepAnalysis: HKCategoryType(.sleepAnalysis)
            default: hkQuantityType
            }
        }

        fileprivate var defaultUnit: HKUnit {
            switch self {
            case .stepCount: .count()
            case .heartRate: HKUnit.count().unitDivided(by: .minute())
            case .activeEnergy: .kilocalorie()
            case .sleepAnalysis: .minute()
            case .bodyMass: .gramUnit(with: .kilo)
            case .height: .meterUnit(with: .centi)
            case .bloodOxygen: .percent()
            case .respiratoryRate: HKUnit.count().unitDivided(by: .minute())
            }
        }
    }
#endif
