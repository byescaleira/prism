#if canImport(SwiftData)
    import Foundation
    import SwiftData

    /// Generic CRUD operations for any PersistentModel.
    @ModelActor
    public actor PrismModelStore<T: PersistentModel> {
        /// Inserts a model into the context.
        public func insert(_ model: T) {
            modelContext.insert(model)
            try? modelContext.save()
        }

        /// Inserts multiple models in a batch.
        public func insertBatch(_ models: [T]) {
            for model in models {
                modelContext.insert(model)
            }
            try? modelContext.save()
        }

        /// Fetches all models matching the descriptor.
        public func fetch(
            _ descriptor: FetchDescriptor<T> = FetchDescriptor<T>()
        ) throws -> [T] {
            try modelContext.fetch(descriptor)
        }

        /// Fetches models with a predicate.
        public func fetch(
            predicate: Predicate<T>? = nil,
            sortBy: [SortDescriptor<T>] = [],
            limit: Int? = nil
        ) throws -> [T] {
            var descriptor = FetchDescriptor<T>(
                predicate: predicate,
                sortBy: sortBy
            )
            descriptor.fetchLimit = limit
            return try modelContext.fetch(descriptor)
        }

        /// Counts models matching the predicate.
        public func count(predicate: Predicate<T>? = nil) throws -> Int {
            var descriptor = FetchDescriptor<T>(predicate: predicate)
            descriptor.fetchLimit = 0
            return try modelContext.fetchCount(descriptor)
        }

        /// Deletes a model.
        public func delete(_ model: T) {
            modelContext.delete(model)
            try? modelContext.save()
        }

        /// Deletes all models matching the predicate.
        public func deleteAll(predicate: Predicate<T>? = nil) throws {
            let models = try fetch(predicate: predicate)
            for model in models {
                modelContext.delete(model)
            }
            try modelContext.save()
        }

        /// Saves pending changes.
        public func save() throws {
            try modelContext.save()
        }

        /// Performs a transaction — saves on success, context reverts on throw.
        public func transaction(_ work: (ModelContext) throws -> Void) throws {
            try work(modelContext)
            try modelContext.save()
        }

        /// Checks if any model matches the predicate.
        public func exists(predicate: Predicate<T>? = nil) throws -> Bool {
            try count(predicate: predicate) > 0
        }
    }
#endif
