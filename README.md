<p align="center">
  <img src="https://img.shields.io/github/v/release/rafaelesantos/prism?style=flat-square&color=blue" alt="Release">
  <img src="https://github.com/rafaelesantos/prism/actions/workflows/ci.yml/badge.svg" alt="CI">
  <img src="https://img.shields.io/badge/Swift-6.3-F05138?style=flat-square&logo=swift&logoColor=white" alt="Swift 6.3">
  <img src="https://img.shields.io/badge/Platforms-iOS_|_macOS_|_tvOS_|_watchOS_|_visionOS-blue?style=flat-square" alt="Platforms">
  <img src="https://img.shields.io/badge/Architecture-Clean_+_UDF-purple?style=flat-square" alt="Architecture">
  <img src="https://img.shields.io/badge/Concurrency-Strict-orange?style=flat-square" alt="Concurrency">
  <img src="https://img.shields.io/badge/coverage--%25-red?style=flat-square
  <img src="https://img.shields.io/badge/License-MIT-green?style=flat-square" alt="License">
</p>

# Prism

A modular Swift package for building Apple-platform apps — shared foundation, networking, architecture, adaptive UI, media, and on-device intelligence.

> **154 tests** · **31 suites** · **7 modules** · **Swift 6.3 strict concurrency** · **DocC on every public API**

---

## Architecture

```
┌─────────────────────────────────────────────────┐
│                    Prism                        │  ← umbrella re-export
├──────────┬──────────┬───────────┬───────────────┤
│ PrismUI  │PrismVideo│PrismIntel.│PrismArchitect.│  ← feature modules
├──────────┴──────────┴───────────┴───────────────┤
│                PrismNetwork                     │  ← transport layer
├─────────────────────────────────────────────────┤
│               PrismFoundation                   │  ← zero-dep core
└─────────────────────────────────────────────────┘
```

| Module | Role |
|--------|------|
| `PrismFoundation` | Entities, logging, analytics, locale, resources, defaults, formatting |
| `PrismNetwork` | HTTP client, socket transport, endpoints, caching, FIX protocol |
| `PrismArchitecture` | Router, store, reducer, middleware — unidirectional data flow |
| `PrismUI` | Design tokens, atoms, molecules, modifiers, accessibility, theming |
| `PrismVideo` | Video download helpers and media entities |
| `PrismIntelligence` | CreateML training, CoreML inference, Apple Intelligence, remote LLM |
| `Prism` | Umbrella — `import Prism` gives you everything |

---

## Install

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/rafaelesantos/prism.git", from: "1.0.0")
]
```

```swift
import Prism          // everything
import PrismUI        // just design system
import PrismNetwork   // just networking
```

**Requires:** Swift 6.3 · Xcode 16.4+ · iOS 26 · macOS 26 · tvOS 26 · watchOS 26 · visionOS 26

---

## Usage

### UI Components

```swift
PrismButton("Sign In", variant: .primary) {
    await viewModel.signIn()
}
.prism(testID: "sign_in_button")
```

### State Management

```swift
let store = PrismStore(
    initialState: AppState(),
    reducer: appReducer
)

store.send(.loadData)
```

### Analytics

```swift
ContentView()
    .prism(analytics: FirebaseAnalytics())
// button_tap, screen_view, field_interaction — automatic
```

### Intelligence

```swift
// Train from any Codable
let training = PrismCodableTrainingData(data: houses)
let result = await training.trainRegressor(
    id: "price", name: "House Price", target: \.price
)

// Predict
let client = try await PrismIntelligenceClient.local(modelID: "price")
let prediction = try await client.regress(
    features: ["rooms": .int(3), "area": .double(120)]
)

// Remote LLM
let remote = PrismIntelligenceClient.remote(
    endpoint: url, token: "sk-...", model: "gpt-4"
)
let answer = try await remote.generate("Summarize this document.")
```

### Locale

```swift
@main struct MyApp: App {
    @State private var localeManager = PrismLocaleManager(initial: .englishUS)

    var body: some Scene {
        WindowGroup {
            ContentView()
                .prism(localeManager: localeManager)
        }
    }
}
```

---

## Development

```bash
make format          # swift-format in-place
make lint            # strict lint check
make build           # build all targets + tests
make test            # test with coverage
make validate        # format → lint → build → test
make docs            # generate DocC
make docs-serve      # DocC + local server at :8000
```

### Prefix Customization

```swift
public typealias AppButton = PrismButton
public typealias AppText   = PrismText
// PrismUIPrefixAliases.swift — copy and rename
```

---

## GitFlow

```
feature/xyz ──→ develop ──→ release/1.2.0 ──→ main ──→ tag + release
                   ↑                              │
                   └──────── back-merge ──────────┘
                                                  │
hotfix/1.2.1 ─────────────────────────────────────→ main + develop
```

| Branch | Purpose | Target |
|--------|---------|--------|
| `main` | Production | protected |
| `develop` | Integration | `main` via `release/*` |
| `feature/*` | New work | `develop` |
| `release/*` | Release prep | `main` + `develop` |
| `hotfix/*` | Urgent fixes | `main` + `develop` |

```bash
make feature name=my-feature
make release version=1.2.0
make hotfix  version=1.2.1
make finish-release
make finish-hotfix
```

**On merge to `main`:** version bump → CHANGELOG → tag → GitHub Release → DocC deploy → back-merge `develop`

**Commits:** [Conventional Commits](https://www.conventionalcommits.org/) — `feat:` minor · `fix:` patch · `!:` major

---

## Quality

| Check | Status |
|-------|--------|
| Tests | 154 across 31 suites |
| Concurrency | Strict — `Sendable`, `@MainActor`, actor isolation |
| Formatting | `swift-format` enforced in CI |
| Imports | Explicit target dependency checks |
| Docs | DocC on all public APIs |
| Branch guard | GitFlow + Conventional Commits enforced |
| Accessibility | VoiceOver, Dynamic Type, contrast ratios |
| Localization | Runtime switching, locale-aware formatting |

---

## License

[MIT](LICENSE)

---

<p align="center">
  <sub>swift · swiftui · ios · macos · swift-package-manager · clean-architecture · design-system · coreml · accessibility · localization · analytics · gitflow</sub>
</p>
