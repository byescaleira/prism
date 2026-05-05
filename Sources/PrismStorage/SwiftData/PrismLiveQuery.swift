#if canImport(SwiftData)
    import Foundation
    import SwiftData

    /// Provides an AsyncStream that emits the count of matching models at a polling interval.
    public struct PrismLiveQuery<T: PersistentModel>: Sendable {
        private let container: ModelContainer
        private let descriptor: FetchDescriptor<T>
        private let interval: TimeInterval

        public init(
            container: ModelContainer,
            descriptor: FetchDescriptor<T> = FetchDescriptor<T>(),
            interval: TimeInterval = 1.0
        ) {
            self.container = container
            self.descriptor = descriptor
            self.interval = interval
        }

        /// Stream of result counts — use to trigger re-fetches from the main context.
        public func countStream() -> AsyncStream<Int> {
            let container = self.container
            let descriptor = self.descriptor
            let interval = self.interval

            return AsyncStream { continuation in
                let task = Task.detached {
                    let context = ModelContext(container)
                    var lastCount = -1
                    while !Task.isCancelled {
                        let count = (try? context.fetchCount(descriptor)) ?? 0
                        if count != lastCount {
                            lastCount = count
                            continuation.yield(count)
                        }
                        try? await Task.sleep(for: .seconds(interval))
                    }
                    continuation.finish()
                }
                continuation.onTermination = { _ in task.cancel() }
            }
        }
    }
#endif
