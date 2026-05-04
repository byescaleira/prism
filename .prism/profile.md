# Prism — Project Profile

## Identity
- **Type**: Modular Swift package for Apple platforms + server
- **Author**: Rafael Escaleira (@byescaleira)
- **License**: MIT
- **Language**: Swift 6.3 (strict concurrency)
- **Min platforms**: iOS 26, macOS 26, tvOS 26, watchOS 26, visionOS 26

## Philosophy
1. **Modular over monolithic** — each module compiles independently, zero circular deps
2. **Apple-native over third-party** — Foundation, SwiftUI, Combine, Observation, CoreML first
3. **Strict concurrency** — `@Sendable`, actors, no data races. Zero `@unchecked` escapes
4. **Convention over configuration** — sensible defaults, override when needed
5. **Test everything** — no module ships without matching test target
6. **Documentation as code** — DocC on every public API, Mintlify for tutorials

## Modules (dependency order)
```
PrismFoundation         (zero deps)
├── PrismNetwork        (→ Foundation)
├── PrismArchitecture   (→ Foundation)
├── PrismVideo          (→ Foundation)
├── PrismIntelligence   (→ Foundation)
├── PrismCapabilities   (→ Foundation)
├── PrismServer         (→ Foundation)
└── PrismUI             (→ Foundation, Architecture)

Prism (umbrella)        → all client modules
PrismPreview            → Prism
```

## Current State (v4.4.0)
- 887 Swift files (738 src + 149 test)
- ~60k LOC source
- 1188 tests / 212 suites / 8 modules
- Mintlify docs: 96 pages
- DocC: auto-generated via GitHub Pages
- CI: lint → build → test → coverage → auto-release
- Landing: Vercel-hosted
