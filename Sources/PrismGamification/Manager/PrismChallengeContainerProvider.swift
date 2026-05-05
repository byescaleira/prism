#if canImport(SwiftData)
    import Foundation
    import SwiftData

    /// Creates a SwiftData ModelContainer configured for CloudKit sync.
    public enum PrismChallengeContainerProvider {
        /// Creates a ModelContainer for gamification models.
        ///
        /// - Parameters:
        ///   - cloudKitContainerIdentifier: CKContainer identifier for CloudKit sync. Pass `nil` for local-only.
        ///   - inMemory: Use in-memory store (for testing).
        public static func makeContainer(
            cloudKitContainerIdentifier: String? = nil,
            inMemory: Bool = false
        ) throws -> ModelContainer {
            let schema = Schema([
                PrismChallengeProgress.self,
                PrismStreakRecord.self,
            ])

            let configuration: ModelConfiguration
            if inMemory {
                configuration = ModelConfiguration(
                    schema: schema,
                    isStoredInMemoryOnly: true
                )
            } else if let containerID = cloudKitContainerIdentifier {
                configuration = ModelConfiguration(
                    containerID,
                    schema: schema,
                    cloudKitDatabase: .automatic
                )
            } else {
                configuration = ModelConfiguration(schema: schema)
            }

            return try ModelContainer(
                for: schema,
                configurations: [configuration]
            )
        }
    }
#endif
