# Pattern: Error Handling

## Module Error Enum
```swift
public enum PrismXxxError: Error, Sendable, LocalizedError {
    case invalidInput(String)
    case networkUnavailable
    case timeout(duration: TimeInterval)
    case unexpected(underlying: any Error & Sendable)

    public var errorDescription: String? {
        switch self {
        case .invalidInput(let detail): "Invalid input: \(detail)"
        case .networkUnavailable: "Network unavailable"
        case .timeout(let duration): "Operation timed out after \(duration)s"
        case .unexpected(let error): "Unexpected error: \(error.localizedDescription)"
        }
    }
}
```

## Rules
- One error enum per module
- Always `Sendable` + `LocalizedError`
- Never `fatalError()` or `try!` in library code
- Wrap unknown errors in `.unexpected(underlying:)`
- Propagate errors up — let consumer decide handling strategy

## Async Error Pattern
```swift
public func fetch() async throws(PrismNetworkError) -> Data {
    // Typed throws (Swift 6.3)
}
```

## Result Pattern (when caller needs explicit handling)
```swift
public func validate(_ input: String) -> Result<ValidatedInput, PrismValidationError> {
    // When caller must handle both paths explicitly
}
```
