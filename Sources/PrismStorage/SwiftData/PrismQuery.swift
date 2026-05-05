#if canImport(SwiftData)
    import Foundation
    import SwiftData

    /// Fluent query builder for SwiftData models.
    public struct PrismQuery<T: PersistentModel>: Sendable {
        private var predicate: Predicate<T>?
        private var sortDescriptors: [SortDescriptor<T>] = []
        private var fetchLimit: Int?
        private var fetchOffset: Int?

        public init() {}

        /// Adds a predicate filter.
        public func `where`(_ predicate: Predicate<T>) -> PrismQuery<T> {
            var copy = self
            copy.predicate = predicate
            return copy
        }

        /// Adds a sort descriptor.
        public func sort(_ descriptor: SortDescriptor<T>) -> PrismQuery<T> {
            var copy = self
            copy.sortDescriptors.append(descriptor)
            return copy
        }

        /// Sets the fetch limit.
        public func limit(_ count: Int) -> PrismQuery<T> {
            var copy = self
            copy.fetchLimit = count
            return copy
        }

        /// Sets the fetch offset.
        public func offset(_ count: Int) -> PrismQuery<T> {
            var copy = self
            copy.fetchOffset = count
            return copy
        }

        /// Builds a FetchDescriptor from this query.
        public func build() -> FetchDescriptor<T> {
            var descriptor = FetchDescriptor<T>(
                predicate: predicate,
                sortBy: sortDescriptors
            )
            descriptor.fetchLimit = fetchLimit
            descriptor.fetchOffset = fetchOffset
            return descriptor
        }
    }
#endif
