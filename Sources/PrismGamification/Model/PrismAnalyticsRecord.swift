#if canImport(SwiftData)
    import Foundation
    import SwiftData

    /// Persisted analytics record for gamification events.
    @Model
    public final class PrismAnalyticsRecord {
        /// Unique record identifier.
        @Attribute(.unique)
        public var recordID: String

        /// Event type name (e.g. "challenge_started").
        public var eventType: String

        /// Identifier of the related entity.
        public var entityID: String

        /// When the event occurred.
        public var timestamp: Date

        /// JSON-encoded extra data.
        public var metadata: String

        /// Duration for completion events.
        public var completionDuration: Double?

        /// Creates a new `PrismAnalyticsRecord` with the specified configuration.
        public init(
            recordID: String = UUID().uuidString,
            eventType: String,
            entityID: String,
            timestamp: Date = .now,
            metadata: String = "{}",
            completionDuration: Double? = nil
        ) {
            self.recordID = recordID
            self.eventType = eventType
            self.entityID = entityID
            self.timestamp = timestamp
            self.metadata = metadata
            self.completionDuration = completionDuration
        }
    }
#endif
