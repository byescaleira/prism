<p align="center">
  <img src="https://img.shields.io/github/v/release/rafaelesantos/prism?style=flat-square&color=blue" alt="Release">
  <img src="https://github.com/rafaelesantos/prism/actions/workflows/ci.yml/badge.svg" alt="CI">
  <img src="https://img.shields.io/badge/Swift-6.3-F05138?style=flat-square&logo=swift&logoColor=white" alt="Swift 6.3">
  <img src="https://img.shields.io/badge/Platforms-iOS_|_macOS_|_tvOS_|_watchOS_|_visionOS-blue?style=flat-square" alt="Platforms">
  <img src="https://img.shields.io/badge/Architecture-Clean_+_UDF-purple?style=flat-square" alt="Architecture">
  <img src="https://img.shields.io/badge/Concurrency-Strict-orange?style=flat-square" alt="Concurrency">
  <img src="https://img.shields.io/badge/License-MIT-green?style=flat-square" alt="License">
</p>

# Prism

A modular Swift package for building Apple-platform apps — shared foundation, networking, architecture, adaptive UI, media, and on-device intelligence.

> **788 tests** · **149 suites** · **7 modules** · **Swift 6.3 strict concurrency** · **DocC on every public API**

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
| `PrismUI` | Token-driven design system — 80+ components, 4 themes, Apple HIG |
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

## PrismUI Design System

### Tokens

Six semantic token types drive every visual decision:

| Token | Purpose | Values |
|-------|---------|--------|
| `ColorToken` | 28 semantic color roles | brand, surfaces, content, feedback |
| `TypographyToken` | Text styles with weights | largeTitle → caption2 |
| `SpacingToken` | 4pt grid system | 0–64pt |
| `RadiusToken` | Continuous corners | sm(8) → full(1000) |
| `ElevationToken` | Shadow hierarchy | flat → overlay |
| `MotionToken` | Reduce-motion-aware | instant → expressive |

### Themes

| Theme | Description |
|-------|-------------|
| `DefaultTheme` | Apple HIG system colors, auto light/dark |
| `DarkTheme` | Always-dark, ignores system appearance |
| `HighContrastTheme` | Maximum contrast for accessibility |
| `BrandTheme` | Configurable primary/secondary/accent |

```swift
// Apply theme
ContentView()
    .prismTheme(DefaultTheme())

// Custom brand
let theme = BrandTheme(primary: .indigo, secondary: .mint, accent: .orange)
```

### Components (60+)

**Primitives:** Button, Icon, AsyncImage, TextField, Card, Tag, Chip, Divider, LoadingState, ProgressBar, Avatar

**Composites:** Alert, Banner, Carousel, SearchBar, Toolbar, Toast, Menu, BottomSheet, Tooltip, EmptyState, CountdownTimer

**Forms:** Toggle, Picker, Slider, SecureField, DatePicker, SegmentedControl, Stepper, TextArea, Rating, PinField, ColorWell

**Lists:** Row, DisclosureRow, List, Badge, SwipeActions

**Layout:** AdaptiveStack, Grid, Section, Scaffold, Spacer

**Navigation:** NavigationView, TabView, Sheet

### Usage

```swift
// Themed button with async action
PrismButton("Sign In", variant: .filled) {
    await viewModel.signIn()
}

// Validated text field
PrismTextField("Email", text: $email, validation: .pattern(
    "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}",
    "Enter a valid email"
))

// Semantic modifiers
Text("Welcome")
    .prismFont(.title)
    .prismColor(.onBackground)
    .prismPadding(.lg)
    .prismSurface(.surfaceSecondary, radius: .lg)

// Auto-dismissing toast
.prismToast(isPresented: $showToast, "Saved!", icon: "checkmark", style: .success)

// Avatar with status
PrismAvatar(initials: "JD", size: .large, status: .online)
```

---

## State Management

```swift
let store = PrismStore(
    initialState: AppState(),
    reducer: appReducer
)

store.send(.loadData)
```

## Analytics

```swift
ContentView()
    .prismAnalytics(FirebaseAnalytics())

// Track screen views
ContentView()
    .prismTrackScreen("Home")
```

## Intelligence

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

---

## Quality

| Check | Status |
|-------|--------|
| Tests | 275+ across 44 suites |
| Concurrency | Strict — `Sendable`, `@MainActor`, actor isolation |
| Formatting | `swift-format` enforced in CI |
| Docs | DocC with guides: Getting Started, Tokens, Components, Theming |
| Themes | 4 built-in + custom theme protocol |
| Accessibility | VoiceOver, Dynamic Type, contrast ratios, reduce motion |
| Snapshot Testing | Built-in `PrismSnapshotTest` for visual regression |
| WCAG | Contrast ratio validation (AA/AAA) via `PrismAccessibilityTest` |

---

## License

[MIT](LICENSE)

---

<p align="center">
  <sub>swift · swiftui · ios · macos · swift-package-manager · clean-architecture · design-system · coreml · accessibility · localization · analytics</sub>
</p>
