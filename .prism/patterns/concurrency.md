# Pattern: Swift 6 Concurrency

## Actor Isolation
```swift
// Prefer actor for mutable shared state
public actor PrismConnectionPool {
    private var connections: [Connection] = []

    public func acquire() async -> Connection { ... }
    public func release(_ conn: Connection) { ... }
}
```

## Sendable Conformance
```swift
// Value types: automatic if all stored properties Sendable
public struct PrismConfig: Sendable { ... }

// Reference types: must prove safety
public final class PrismCache: Sendable {
    private let storage: OSAllocatedUnfairLock<[String: Data]>
}
```

## AsyncSequence
```swift
// Prefer over Combine for new async streams
public func events() -> AsyncStream<PrismEvent> {
    AsyncStream { continuation in
        // setup
        continuation.onTermination = { _ in /* cleanup */ }
    }
}
```

## Task Management
```swift
// Store task handles for cancellation
private var task: Task<Void, Never>?

func start() {
    task = Task {
        for await event in eventStream {
            guard !Task.isCancelled else { break }
            process(event)
        }
    }
}

func stop() {
    task?.cancel()
    task = nil
}
```

## Never Block
- No `DispatchSemaphore` in async context
- No `Thread.sleep` — use `Task.sleep`
- No `DispatchQueue.sync` from actor
