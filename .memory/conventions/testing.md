---
name: testing
description: Testing conventions — coverage targets, framework, mock patterns, naming, organization.
type: project
---

## Coverage Targets

| Layer | Minimum | Rationale |
|-------|---------|-----------|
| Domain | 95% | Core business logic, highest risk |
| Data | 95% | Data integrity critical |
| Presentation | 80% | ViewModel state transitions |
| Infrastructure | 80% | Utilities, less risk |
| UI | 60%+ | Visual, harder to unit test |

## Framework: Swift Testing

```swift
import Testing

@Suite("FeatureName")
struct FeatureNameTests {
    @Test("description of what is tested")
    func test_unit_scenario_expectedResult() async throws {
        // Arrange → Act → Assert
    }
}
```

## Mock Patterns

### Protocol Mock (preferred)
```swift
struct MockUserRepository: UserRepository {
    let result: Result<User, Error>
    func fetch(id: UUID) async throws -> User { try result.get() }
}
```

### Spy (verify interactions)
```swift
final class SpyAnalytics: AnalyticsProvider, @unchecked Sendable {
    private(set) var events: [AnalyticsEvent] = []
    func track(_ event: AnalyticsEvent) { events.append(event) }
}
```

### Stub (fixed data)
```swift
extension User {
    static let stub = User(id: UUID(), name: "Test", email: "test@example.com")
}
```

## Naming Convention

```
test_[unit]_[scenario]_[expectedResult]
```

- `test_execute_validId_returnsUser`
- `test_fetch_networkError_throwsError`
- `test_load_emptyList_showsEmptyState`

## Rules

- Every public API → tests required
- Bug fix → regression test required
- Happy path + error path + edge cases
- Tests independent (no order dependency)
- No mocking frameworks (protocol-based only)
- Async tests use `async throws`

**Why:** 100% testable architecture is meaningless without actual tests. Tests are documentation of behavior.

**How to apply:** Write tests alongside implementation. Never merge without tests. CI blocks on coverage regression.
