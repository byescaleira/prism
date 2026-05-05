#if canImport(SwiftData)
    import Foundation
    import SwiftData

    /// Unified SwiftData container creation with CloudKit and migration support.
    public struct PrismContainer: Sendable {
        /// Creates a model container for the given schema.
        public static func create(
            for types: [any PersistentModel.Type],
            inMemory: Bool = false,
            cloudKitContainerID: String? = nil,
            migrationPlan: (any SchemaMigrationPlan.Type)? = nil
        ) throws -> ModelContainer {
            let schema = Schema(types)
            var config = ModelConfiguration(
                isStoredInMemoryOnly: inMemory
            )

            if let cloudKitID = cloudKitContainerID {
                config = ModelConfiguration(
                    cloudKitDatabase: .automatic
                )
            }

            if let migrationPlan {
                return try ModelContainer(
                    for: schema,
                    migrationPlan: migrationPlan,
                    configurations: [config]
                )
            }

            return try ModelContainer(
                for: schema,
                configurations: [config]
            )
        }

        /// Creates an in-memory container for testing.
        public static func inMemory(
            for types: [any PersistentModel.Type]
        ) throws -> ModelContainer {
            try create(for: types, inMemory: true)
        }
    }
#endif
