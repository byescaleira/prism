# Naming Conventions

## Files
```
Sources/PrismXxx/Feature/PrismFeatureName.swift
Tests/PrismXxxTests/FeatureNameTests.swift
```
- One primary type per file
- File name = primary type name
- Group by feature subdirectory, not by type (no `Models/`, `Protocols/` dirs)

## Types
| Kind | Pattern | Example |
|------|---------|---------|
| Public struct/class | `Prism` + PascalCase | `PrismRouter`, `PrismHTTPClient` |
| Public enum | `Prism` + PascalCase | `PrismHTTPMethod`, `PrismVideoError` |
| Public protocol | `Prism` + noun/adjective | `PrismStorable`, `PrismMiddleware` |
| Internal type | PascalCase (no prefix) | `RouteNode`, `TokenParser` |
| Test type | TypeName + `Tests` | `PrismRouterTests` |
| Mock type | `Mock` + TypeName | `MockHTTPClient`, `MockDatabase` |

## Functions & Properties
- camelCase always
- Boolean: `is`/`has`/`should` prefix → `isLoading`, `hasConnection`
- Factory: `make` prefix → `makeRequest()`, `makeStore()`
- Async: verb describing action → `fetch()`, `send()`, `process()`
- Callbacks: `on` prefix → `onComplete`, `onError`

## Modules
- `PrismXxx` — PascalCase after prefix
- No abbreviations except established ones (HTTP, URL, JWT, SSE, DI)

## Resources
```
Resource/PrismModuleNameString.xcstrings     ← localization
Resource/PrismModuleNameLogMessage.xcstrings ← log messages
Resources/Media.xcassets                     ← assets
Resources/Localizable.xcstrings              ← UI strings
```

## Git Branches
- lowercase, hyphen-separated after prefix
- `feature/module-description`
- `fix/module-description`
