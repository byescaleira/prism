---
name: module-dependencies
description: Actual Prism module dependency graph from Package.swift.
type: project
---

## Module Dependency Graph (Actual)

```
Prism (umbrella)
├── PrismFoundation
├── PrismNetwork        → PrismFoundation
├── PrismArchitecture   → PrismFoundation
├── PrismUI             → PrismFoundation, PrismArchitecture
├── PrismVideo          → PrismFoundation
├── PrismIntelligence   → PrismFoundation
├── PrismCapabilities   → PrismFoundation

PrismServer             → PrismFoundation (standalone)
PrismPreview            → Prism (umbrella, dev only)
```

## Dependency Rules

| Module | Depends On | CANNOT Import |
|--------|-----------|---------------|
| PrismFoundation | Nothing | Everything else |
| PrismNetwork | PrismFoundation | UI, Architecture, Video, Intelligence, Capabilities, Server |
| PrismArchitecture | PrismFoundation | Network, UI, Video, Intelligence, Capabilities, Server |
| PrismUI | PrismFoundation, PrismArchitecture | Network, Video, Intelligence, Capabilities, Server |
| PrismVideo | PrismFoundation | Network, Architecture, UI, Intelligence, Capabilities, Server |
| PrismIntelligence | PrismFoundation | Network, Architecture, UI, Video, Capabilities, Server |
| PrismCapabilities | PrismFoundation | Network, Architecture, UI, Video, Intelligence, Server |
| PrismServer | PrismFoundation | Client-side modules |
| Prism | All client modules | Server |

## Design

PrismFoundation = core layer (zero deps). All modules depend on it.
Modules are siblings — no cross-deps except UI→Architecture.
Server completely isolated from client modules.

**Why:** Library consumers pick modules they need. Minimal transitive deps.

**How to apply:** Before adding import, check this table. Cross-module deps = architecture violation unless explicitly planned.
