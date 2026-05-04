# Architecture Rules

## Module Boundaries
- Modules MUST NOT have circular dependencies
- Dependency direction: always downward (see profile.md DAG)
- Cross-module communication: through protocols defined in lower module
- No module may import `Prism` umbrella — import specific modules

## Dependency Graph (enforced by `--explicit-target-dependency-import-check error`)
```
Layer 0: PrismFoundation (zero deps)
Layer 1: PrismNetwork, PrismArchitecture, PrismVideo, PrismIntelligence, PrismCapabilities, PrismServer
Layer 2: PrismUI (→ Foundation + Architecture)
Layer 3: Prism umbrella (→ all client modules)
```

## PrismFoundation
- Zero external deps, zero upward deps
- Contains: entities, extensions, logging, analytics, locale, formatting, defaults
- Any utility needed by 2+ modules belongs here
- NEVER import UIKit/SwiftUI/AppKit here

## PrismArchitecture — UDF (Unidirectional Data Flow)
```
View → Action → Store → Reducer → State → View
                         ↓
                     Middleware (side effects)
```
- Store: `@Observable`, holds state, dispatches to reducer
- Reducer: pure function `(State, Action) → State`
- Middleware: async side effects, returns actions
- Router: navigation state as data, not imperative

## PrismUI — Design System
- Token-driven: all visual decisions through tokens (color, typography, spacing, radius, elevation, motion)
- 4 themes: must work across all
- Accessibility: every component keyboard-navigable, VoiceOver-ready
- No hardcoded colors/sizes — always tokens

## PrismServer — HTTP Server
- Builder pattern for server config
- Middleware chain: request → middleware[] → handler → middleware[] → response
- DI via `PrismContainer`
- All I/O async, never blocking

## PrismNetwork — Client
- Endpoint protocol defines request
- Resource wraps endpoint + decode
- Retry, dedup, cache, offline queue as composable layers
- Socket adapter for persistent connections

## Adding New Module
- See `skills/new-module.md`
- Requires: Package.swift target + test target + DocC catalog + Mintlify section
