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

A modular Swift package for building Apple-platform apps and servers — foundation, networking, architecture, adaptive UI, media, on-device intelligence, gamification, security, device capabilities, and a native HTTP server.

> **2642+ tests** · **11 modules** · **Swift 6.3 strict concurrency** · **DocC on every public API**

---

## Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│                           Prism                                 │  ← umbrella
├──────────┬──────────┬────────────┬───────────┬──────────────────┤
│ PrismUI  │PrismVideo│PrismIntel. │PrismArch. │PrismCapabilities │  ← client
├──────────┴──────────┴────────────┴───────────┴──────────────────┤
│                    PrismGamification                            │  ← gamification
│              (PrismFoundation + PrismIntelligence)              │
├─────────────────────────────────────────────────────────────────┤
│                      PrismSecurity                              │  ← security
│     (Permissions, Biometrics, Keychain, Encryption, Enclave)    │
├─────────────────────────────────────────────────────────────────┤
│                      PrismServer                                │  ← server
├─────────────────────────────────────────────────────────────────┤
│                     PrismNetwork                                │  ← transport
├─────────────────────────────────────────────────────────────────┤
│                    PrismFoundation                               │  ← zero-dep core
└─────────────────────────────────────────────────────────────────┘
```

| Module | Role |
|--------|------|
| `PrismFoundation` | Entities, logging, analytics, locale, resources, defaults, formatting |
| `PrismNetwork` | HTTP client, socket transport, endpoints, caching, retry, offline queue, GraphQL |
| `PrismArchitecture` | Store, reducer, middleware, router — unidirectional data flow with time-travel |
| `PrismUI` | Token-driven design system — 80+ components, 4 themes, Apple HIG |
| `PrismVideo` | Video download helpers and media entities |
| `PrismIntelligence` | CreateML training, CoreML inference, Apple Intelligence, remote LLM, RAG, NLP, vision |
| `PrismCapabilities` | Apple capability wrappers — StoreKit, HealthKit, CloudKit, Camera, Bluetooth, Location, Motion, NFC, GameKit, Biometrics, and more |
| `PrismServer` | Native Swift HTTP server — routing, middleware, WebSocket, GraphQL, MCP, jobs, caching, auth |
| `PrismGamification` | Duolingo-style gamification — challenges, streaks, badges, leaderboards, analytics, AI-powered messages via Apple Intelligence |
| `PrismSecurity` | Unified permissions, Face ID/Touch ID, Keychain, AES-GCM/ChaChaPoly encryption, Secure Enclave, secure storage |
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
import Prism              // everything
import PrismUI            // design system
import PrismNetwork       // networking
import PrismServer        // HTTP server
import PrismGamification  // gamification
import PrismSecurity      // auth, encryption, keychain
import PrismIntelligence  // AI + ML
```

**Requires:** Swift 6.3 · Xcode 16.4+ · iOS 26 · macOS 26 · tvOS 26 · watchOS 26 · visionOS 26

---

## PrismGamification

Duolingo-style gamification with SwiftData persistence and CloudKit sync.

```swift
// Define challenges as an enum
enum AppChallenge: String, PrismChallenge, CaseIterable {
    case firstLogin, tenWorkouts

    var title: String { ... }
    var type: PrismChallengeType { ... }
    var goal: Int { ... }
    var points: Int { ... }
}

// Register and track
let manager = PrismChallengeManager(container: container)
try await manager.register(AppChallenge.self)
try await manager.increment(AppChallenge.tenWorkouts)
try await manager.complete(AppChallenge.firstLogin)

// Streaks
try await manager.recordStreakActivity("daily")
let streak = try await manager.currentStreak("daily")

// Badges with auto-evaluation
try await manager.registerBadges(AppBadge.self)
let unlocked = try await manager.evaluateBadges(AppBadge.self, currentPoints: 100)

// Leaderboards
try await manager.submitScore(userID: "u1", displayName: "Alice", score: 500, period: .weekly)
let board = try await manager.leaderboard(period: .weekly)

// AI-powered messages via Apple Intelligence
let intelligence = PrismGamificationIntelligence()
let message = await intelligence.messageWithFallback(
    kind: .challengeCompleted,
    context: PrismGamificationContext(
        entityID: "tenWorkouts",
        challengeTitle: "Ten Workouts",
        points: 50
    )
)
```

---

## PrismSecurity

Unified security layer — permissions, biometrics, keychain, encryption, and secure storage.

```swift
import PrismSecurity

// Permissions — unified API for all system permissions
let permissions = PrismPermissionClient()
let status = try await permissions.request(.camera)
let statuses = try await permissions.request([.camera, .microphone, .photoLibrary])

// Biometric auth — one-line Face ID / Touch ID
let biometric = PrismBiometricAuth()
try await biometric.authenticate(reason: "Access your vault")

// Keychain — typed, access-controlled storage
let keychain = PrismKeychain()
try keychain.save(string: "sk-secret", for: PrismKeychainItem(id: "apiKey"))
let key = try keychain.loadString(for: PrismKeychainItem(id: "apiKey"))

// Encryption — AES-GCM or ChaChaPoly
let encryptor = PrismEncryptor()
let symmetricKey = encryptor.generateKey()
let encrypted = try encryptor.encrypt(Data("secret".utf8), using: symmetricKey)
let decrypted = try encryptor.decrypt(encrypted, using: symmetricKey)

// Secure Store — encrypt + keychain in one call
let store = PrismSecureStore(configuration: .biometricProtected)
try store.save(credentials, forKey: "userCredentials")
let loaded = try store.load(Credentials.self, forKey: "userCredentials")
```

---

## PrismServer

Native Swift HTTP server with zero external dependencies.

```swift
let server = PrismHTTPServer(host: "0.0.0.0", port: 8080)

server.get("/hello") { req in
    PrismHTTPResponse(status: .ok, body: "Hello, Prism!")
}

server.use(PrismCORS())
server.use(PrismRateLimit(maxRequests: 100, window: 60))
server.use(PrismJWT(secret: "your-secret"))

try await server.start()
```

Features: routing, middleware, WebSocket, SSE, GraphQL, MCP, jobs, caching, sessions, templates, OpenAPI, rate limiting, distributed tracing, dependency injection, clustering.

---

## PrismUI Design System

### Tokens

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
ContentView()
    .prismTheme(DefaultTheme())
```

### Components (80+)

**Primitives:** Button, Icon, AsyncImage, TextField, Card, Tag, Chip, Divider, LoadingState, ProgressBar, Avatar

**Composites:** Alert, Banner, Carousel, SearchBar, Toolbar, Toast, Menu, BottomSheet, Tooltip, EmptyState, CountdownTimer

**Forms:** Toggle, Picker, Slider, SecureField, DatePicker, SegmentedControl, Stepper, TextArea, Rating, PinField, ColorWell

**Charts:** Bar, Line, Donut, Heatmap, Treemap, Radar, Sparkline, Funnel, Candlestick

**Chat:** ChatBubble, MessageList, TypingIndicator, ReactionPicker, ThreadView, ReadReceipts

**Dashboard:** KPICard, StatGrid, ActivityFeed, Timeline, ComparisonTable

---

## PrismIntelligence

```swift
// Apple Intelligence (on-device)
let client = PrismIntelligenceClient.apple()
let response = try await client.generate("Summarize this article.")

// Train from any Codable
let training = PrismCodableTrainingData(data: houses)
let result = await training.trainRegressor(
    id: "price", name: "House Price", target: \.price
)

// Remote LLM
let remote = PrismIntelligenceClient.remote(
    endpoint: url, token: "sk-...", model: "gpt-4"
)
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
| Tests | 2642+ across 215+ suites |
| Modules | 11 independent, composable modules |
| Concurrency | Strict — `Sendable`, `@MainActor`, actor isolation |
| Formatting | `swift-format` enforced in CI |
| Docs | DocC with guides on every public API |
| Themes | 4 built-in + custom theme protocol |
| Accessibility | VoiceOver, Dynamic Type, contrast ratios, reduce motion |
| WCAG | Contrast ratio validation (AA/AAA) |

---

## License

[MIT](LICENSE)

---

<p align="center">
  <sub>swift · swiftui · ios · macos · swift-package-manager · clean-architecture · design-system · coreml · gamification · security · keychain · faceid · encryption · server · apple-intelligence · accessibility · localization · analytics</sub>
</p>
