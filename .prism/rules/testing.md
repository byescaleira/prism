# Testing Rules

## Coverage Requirements
- Every module MUST have matching test target
- New public API = new test. No exceptions
- Target: >80% line coverage (tracked by CI badge)

## Test Structure
```
Tests/
├── PrismFoundationTests/
│   ├── TestSupport.swift       ← shared helpers/mocks
│   ├── StringExtensionsTests.swift
│   └── ...
├── PrismServerTests/
└── ...
```

## Naming
```swift
func test_methodName_condition_expectedResult()
// e.g.:
func test_parse_invalidJSON_throwsDecodingError()
func test_router_duplicateRoute_lastWins()
```

## Patterns
- **Unit tests**: pure logic, no I/O, no network. Fast (<0.1s each)
- **Integration tests**: real I/O (DB, HTTP). Marked with `@Test(.tags(.integration))`
- **Snapshot tests**: PrismUI visual regression (future)

## Assertions
- Prefer Swift Testing (`#expect`, `#require`) over XCTest for new tests
- One logical assertion per test. Multiple `#expect` OK if testing same behavior
- Always test error paths, not just happy path

## Mocking
- Use protocols for dependencies → inject mocks in tests
- Mock structs live in `TestSupport.swift` per test target
- Never mock what you own — test real impl when possible

## Concurrency Tests
- Use `@Test(.serialized)` for tests with shared mutable state
- Test actor isolation explicitly
- Verify `Sendable` conformance compiles (no runtime test needed)

## CI Integration
- `swift test --enable-code-coverage --xunit-output`
- Test results: `.build/artifacts/test-results.xml`
- Failure = PR blocked

## What NOT to Test
- Private implementation details
- Swift standard library behavior
- Pure UI layout (use previews + snapshot tests instead)
