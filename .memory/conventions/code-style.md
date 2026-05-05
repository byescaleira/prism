---
name: code-style
description: Code style conventions — naming, sizing limits, formatting, zero-tolerance rules.
type: project
---

## Size Limits

| Element | Max | Action if exceeded |
|---------|-----|-------------------|
| Function body | 20 lines | Extract helper |
| Type | 200 lines | Split into extensions |
| Line length | 120 characters | Break at argument |
| Parameters | 5 | Group into struct |
| Switch cases | 7 | Extract to method |

## Naming

- Types: `UpperCamelCase` — `UserRepository`, `FetchUserUseCase`
- Functions/properties: `lowerCamelCase` — `fetchUserProfile()`
- Constants: `lowerCamelCase` — `let maximumRetryCount = 3`
- Protocols: noun or adjective — `Repository`, `Sendable`, `Configurable`
- No abbreviations in code (ok in caveman communication)
- Boolean: `is/has/should` prefix — `isLoading`, `hasError`

## Zero Tolerance

- Force unwraps (`!`) → use `guard let` / `if let`
- Force try (`try!`) → propagate or handle
- `print()` → use `Logger`
- Dead code → delete (git has history)
- Magic numbers → named constant
- Hardcoded strings → `String(localized:)`
- Commented-out code → delete
- Unused imports → remove
- Warnings → treat as errors

## Formatting (swift-format enforced)

- 4 spaces indentation
- 120 char line length
- Trailing commas on multi-element collections
- One variable declaration per line
- Ordered imports
- Triple-slash for doc comments
- Early exits preferred (`guard`)

**Why:** Consistency reduces cognitive load. Zero tolerance prevents debt accumulation.

**How to apply:** Every PR must pass `make lint` (strict mode). CI blocks merge on violations.
