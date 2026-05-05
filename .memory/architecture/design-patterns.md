---
name: design-patterns
description: Required design patterns per layer — Repository, UseCase, Coordinator, Actor, Factory.
type: project
---

## Required Design Patterns

### Repository (Data ↔ Domain)
- Protocol defined in Domain
- Implementation in Data (often as actor)
- Abstracts data source (network, cache, DB)
- Enables testing with mock implementations

### UseCase (Domain)
- Single business operation
- One `execute()` method
- Injectable dependencies via init
- `Sendable` conformance
- Composable: complex ops combine multiple UseCases

### Coordinator (Presentation)
- Owns `NavigationPath`
- Typed route enum (`Hashable`)
- Decouples navigation from views
- `@MainActor @Observable`

### Actor (Shared State)
- Any mutable state accessed from multiple contexts
- Caches, session management, counters
- Prefer over locks/semaphores
- `nonisolated` for immutable properties

### Factory/Container (Infrastructure)
- Protocol-based DI
- No external DI framework
- Lazy initialization for expensive objects
- Single composition root in App layer

### Observer/Observable (Presentation)
- `@Observable` macro for ViewModels
- `AsyncStream` for event-driven data
- No Combine in new code (prefer structured concurrency)

### Adapter (Data)
- DTO → Entity mapping (`toDomain()`)
- Entity → DTO mapping (`toDTO()`)
- Keeps layers decoupled
- Each direction explicit method

### Strategy (Domain)
- Interchangeable algorithms via protocol
- Pricing, sorting, filtering, validation
- Injectable at runtime

**Why:** Consistency. Same patterns everywhere → predictable code → easy onboarding → fewer bugs.

**How to apply:** When implementing new feature, identify which patterns apply per layer. grep existing code for pattern examples before creating new ones.
