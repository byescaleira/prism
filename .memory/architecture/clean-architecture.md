---
name: clean-architecture
description: Clean Architecture layer rules — dependency direction, responsibilities, module boundaries.
type: project
---

## Clean Architecture Rules

### Layer Hierarchy (dependencies point INWARD)
```
Presentation → Domain ← Data
                ↑
           Infrastructure
```

### Domain Layer (ZERO dependencies)
- Entities: business models (`Sendable`, `Equatable`, `Identifiable`)
- UseCases: single business operation (`execute()` method)
- Repository Protocols: data access contracts
- Errors: domain-specific `LocalizedError` types
- NO external imports. Pure Swift only.

### Data Layer (depends on Domain)
- Implements Repository protocols from Domain
- DTOs: network/persistence models (separate from Entities)
- DataSources: remote/local data access
- Mappers: DTO ↔ Entity transformation
- Uses actors for thread-safe caching

### Presentation Layer (depends on Domain)
- ViewModels: `@Observable`, `@MainActor`
- Coordinators: navigation logic, typed routes
- ViewState: `.idle`, `.loading`, `.loaded`, `.error`
- NO direct import of Data layer

### Infrastructure Layer (depends on Domain)
- Logger: structured os.Logger with categories
- Analytics: provider-agnostic protocol
- Localization: locale management
- DI Container: protocol-based factories

### App Layer (composition root)
- Wires all dependencies
- Knows about every layer
- Root coordinator
- Entry point

**Why:** Testability. Each layer testable in isolation with protocol mocks. Domain logic never coupled to framework details.

**How to apply:** Before writing code, identify which layer it belongs to. Never import upward.
