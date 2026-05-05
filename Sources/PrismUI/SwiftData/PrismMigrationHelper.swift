#if canImport(SwiftData)
    import SwiftData

    /// Represents a single migration stage with version metadata.
    public struct PrismMigrationStage: Sendable {
        /// The schema version identifier for this stage.
        public let version: String
        /// Human-readable description of what this migration does.
        public let description: String
        /// The underlying SwiftData migration plan, if any.
        public let migrationPlan: (any SchemaMigrationPlan.Type)?

        /// Creates a migration stage definition.
        public init(
            version: String,
            description: String,
            migrationPlan: (any SchemaMigrationPlan.Type)? = nil
        ) {
            self.version = version
            self.description = description
            self.migrationPlan = migrationPlan
        }
    }

    /// Manages ordered migration stages for SwiftData schema evolution.
    public struct PrismMigrationHelper: Sendable {
        /// Ordered sequence of migration stages from oldest to newest.
        public let stages: [PrismMigrationStage]

        /// Creates a migration helper with an ordered list of stages.
        public init(stages: [PrismMigrationStage]) {
            self.stages = stages
        }

        /// Returns the current (latest) schema version string.
        public func currentVersion() -> String {
            stages.last?.version ?? "0.0.0"
        }

        /// Returns whether a migration is needed between two versions.
        public func needsMigration(from: String, to: String) -> Bool {
            guard from != to else { return false }
            let fromIndex = stages.firstIndex(where: { $0.version == from })
            let toIndex = stages.firstIndex(where: { $0.version == to })
            guard let start = fromIndex, let end = toIndex else { return false }
            return start < end
        }

        /// Returns the migration stages needed to move from one version to another.
        public func migrationStages(from: String, to: String) -> [PrismMigrationStage] {
            guard let fromIndex = stages.firstIndex(where: { $0.version == from }),
                let toIndex = stages.firstIndex(where: { $0.version == to }),
                fromIndex < toIndex
            else {
                return []
            }
            return Array(stages[(fromIndex + 1)...toIndex])
        }
    }
#endif
