```
┌──────────────────────────────────────────────────────────────────┐
│                                                                  │
│   Prism                                                          │
│   Modular Swift SDK for Apple platforms and servers               │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

[![Swift](https://img.shields.io/badge/Swift-6.3-FF5C00?style=flat-square&logo=swift&logoColor=white)](https://swift.org)
[![Platform](https://img.shields.io/badge/iOS_|_macOS_|_tvOS_|_watchOS_|_visionOS-FF5C00?style=flat-square&logo=apple&logoColor=white)](https://developer.apple.com)
[![Architecture](https://img.shields.io/badge/Clean_Architecture-FF5C00?style=flat-square)]()
[![License](https://img.shields.io/badge/MIT-FF5C00?style=flat-square)](LICENSE)
[![CI](https://img.shields.io/github/actions/workflow/status/byescaleira/prism/ci.yml?style=flat-square&label=CI)](https://github.com/byescaleira/prism/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/byescaleira/prism?style=flat-square&color=FF5C00)](https://github.com/byescaleira/prism/releases)
[![Docs](https://img.shields.io/badge/Docs-Mintlify-FF5C00?style=flat-square)](https://byescaleira.github.io/prism/)

[Documentation](https://byescaleira.github.io/prism/) · [Report Bug](https://github.com/byescaleira/prism/issues/new?template=bug_report.yml) · [Request Feature](https://github.com/byescaleira/prism/issues/new?template=feature_request.yml)

---

## Features

```
12 Modules          foundation, network, architecture, UI, video, intelligence,
                    gamification, security, capabilities, server, preview, umbrella
2900+ Tests         Swift Testing framework, strict concurrency
Swift 6.3           actors, async/await, Sendable, structured concurrency
Design System       80+ components, 4 themes, token-driven, Apple HIG
Security            permissions, Face ID, keychain, encryption, cert pinning,
                    ECDH transport, audit log, JWT, PII redaction
Server              HTTP, WebSocket, SSE, GraphQL, MCP, jobs, caching, auth
Intelligence        CoreML, Apple Intelligence, remote LLM, RAG, NLP, vision
Gamification        challenges, streaks, badges, leaderboards, AI messages
Accessible          VoiceOver, Dynamic Type, Reduce Motion, WCAG contrast
Mintlify Docs       40+ pages, Stripe-quality, task-oriented
Zero Tolerance      no warnings, no force unwraps, no dead code
```

---

## Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                           Prism                              │  ← umbrella
├──────────┬──────────┬────────────┬───────────┬──────────────┤
│ PrismUI  │PrismVideo│PrismIntel. │PrismArch. │PrismCapabil. │  ← client
├──────────┴──────────┴────────────┴───────────┴──────────────┤
│                    PrismGamification                         │  ← engagement
│              (PrismFoundation + PrismIntelligence)           │
├──────────────────────────────────────────────────────────────┤
│                      PrismSecurity                           │  ← security
│   Permissions · Biometrics · Keychain · Encryption · Pinning │
│   Integrity · Secure Transport · Audit Log · Token · Privacy │
├──────────────────────────────────────────────────────────────┤
│                      PrismServer                             │  ← server
├──────────────────────────────────────────────────────────────┤
│                     PrismNetwork                             │  ← transport
├──────────────────────────────────────────────────────────────┤
│                    PrismFoundation                            │  ← zero-dep core
└──────────────────────────────────────────────────────────────┘
```

```
Module              Role
──────────────────  ──────────────────────────────────────────────────────────
PrismFoundation     Entities, logging, analytics, locale, resources, defaults
PrismNetwork        HTTP client, socket, endpoints, caching, retry, GraphQL
PrismArchitecture   Store, reducer, middleware, router — UDF with time-travel
PrismUI             Token-driven design system — 80+ components, 4 themes
PrismVideo          Video download helpers and media entities
PrismIntelligence   CreateML, CoreML, Apple Intelligence, remote LLM, RAG, NLP
PrismCapabilities   StoreKit, HealthKit, CloudKit, Camera, Bluetooth, NFC, etc.
PrismServer         HTTP server — routing, middleware, WebSocket, GraphQL, MCP
PrismGamification   Challenges, streaks, badges, leaderboards, AI messages
PrismSecurity       Permissions, Face ID, keychain, encryption, cert pinning,
                    ECDH transport, audit log, JWT tokens, PII redaction
PrismPreview        Interactive component catalog
Prism               Umbrella — import Prism gives you everything
```

---

## Quick start

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/byescaleira/prism.git", from: "1.0.0")
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

## PrismSecurity

Full security stack — from permissions to encrypted transport, audit logging, and PII protection.

```swift
import PrismSecurity

// Permissions + Biometrics
let client = PrismPermissionClient()
let status = try await client.request(.camera)

let bio = PrismBiometricAuth()
try await bio.authenticate(reason: "Access your vault")

// Encrypt + Store
let store = PrismSecureStore(configuration: .biometricProtected)
try store.save(credentials, forKey: "userCredentials")

// Certificate Pinning
let pin = PrismCertificatePin(host: "api.example.com", publicKeyHash: "sha256/...")
let validator = PrismPinningValidator(pins: [pin])
let delegate = PrismCertificatePinningDelegate(validator: validator)

// Secure Transport — ECDH + encrypted channel
let alice = PrismSecureChannel()
let bob = PrismSecureChannel()
try alice.establish(with: bob.publicKeyData)
let encrypted = try alice.encrypt(Data("Hello".utf8))

// JWT Token Manager — auto-refresh, actor-based
let tokenManager = PrismTokenManager()
let token = try await tokenManager.validAccessToken { try await refresh() }

// Audit Log — hash-chain tamper detection
let auditLog = PrismSecurityAuditLog()
auditLog.record(PrismSecurityEvent(kind: .biometricSuccess, detail: "Face ID"))
assert(auditLog.verifyIntegrity())

// Privacy — PII redaction + screen protection
let guard_ = PrismPrivacyGuard()
let safe = guard_.redact("Email: john@example.com")  // "Email: j***@***.***"
SensitiveView().prismScreenProtection()
```

---

## PrismGamification

Duolingo-style gamification with SwiftData persistence and CloudKit sync.

```swift
import PrismGamification

enum AppChallenge: String, PrismChallenge, CaseIterable {
    case firstLogin, tenWorkouts
    var title: String { ... }
    var type: PrismChallengeType { ... }
    var goal: Int { ... }
    var points: Int { ... }
}

let manager = PrismChallengeManager(container: container)
try await manager.register(AppChallenge.self)
try await manager.increment(AppChallenge.tenWorkouts)
try await manager.complete(AppChallenge.firstLogin)

// Streaks, badges, leaderboards
try await manager.recordStreakActivity("daily")
try await manager.registerBadges(AppBadge.self)
try await manager.submitScore(userID: "u1", displayName: "Alice", score: 500, period: .weekly)

// AI-powered messages via Apple Intelligence
let intelligence = PrismGamificationIntelligence()
let message = await intelligence.messageWithFallback(kind: .challengeCompleted, context: ctx)
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

```
Token             Purpose                   Values
────────────────  ──────────────────────    ──────────────────────────
ColorToken        28 semantic color roles   brand, surfaces, feedback
TypographyToken   Text styles + weights     largeTitle → caption2
SpacingToken      4pt grid system           0–64pt
RadiusToken       Continuous corners         sm(8) → full(1000)
ElevationToken    Shadow hierarchy           flat → overlay
MotionToken       Reduce-motion-aware        instant → expressive
```

### Themes

| Theme | Description |
|-------|-------------|
| `DefaultTheme` | Apple HIG system colors, auto light/dark |
| `DarkTheme` | Always-dark, ignores system appearance |
| `HighContrastTheme` | Maximum contrast for accessibility |
| `BrandTheme` | Configurable primary/secondary/accent |

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
let result = await training.trainRegressor(id: "price", name: "House Price", target: \.price)

// Remote LLM
let remote = PrismIntelligenceClient.remote(endpoint: url, token: "sk-...", model: "gpt-4")
```

---

## Testing

```
Layer               Target  Framework       Pattern
──────────────────  ──────  ──────────────  ──────────────────────────
Foundation          ≥95%    Swift Testing   Protocol mocks, edge cases
Network             ≥95%    Swift Testing   Mock transport, offline
Architecture        ≥80%    Swift Testing   Store + reducer + middleware
Security            ≥95%    Swift Testing   CryptoKit, keychain sandbox
Gamification        ≥95%    Swift Testing   SwiftData in-memory
Server              ≥80%    Swift Testing   Test client, assertions
```

<details>
<summary><b>Test example</b></summary>

```swift
import Testing
@testable import PrismSecurity

@Suite("SecChan")
struct PrismSecureChannelTests {
    @Test("Channel encrypt/decrypt round trip")
    func roundTrip() throws {
        let alice = PrismSecureChannel()
        let bob = PrismSecureChannel()

        try alice.establish(with: bob.publicKeyData)
        try bob.establish(with: alice.publicKeyData)

        let plaintext = Data("Hello Bob!".utf8)
        let encrypted = try alice.encrypt(plaintext)
        let decrypted = try bob.decrypt(encrypted)

        #expect(decrypted == plaintext)
    }
}
```

</details>

---

## Development

```bash
pnpm swift-cli              # interactive menu
pnpm swift-cli validate     # format → lint → build → test
pnpm swift-cli format       # auto-format
pnpm swift-cli lint         # strict lint
pnpm swift-cli build        # build -warnings-as-errors
pnpm swift-cli test         # test + coverage
```

---

## CI/CD

```
PR → branch guard → lint (--strict) → build (-warnings-as-errors) → test (+coverage) → merge
                                                                                          │
                                                              auto release → tag + changelog + docs
```

---

## Commit convention

```
Type      Description       Version Bump
────────  ────────────────  ────────────
feat      new feature       minor (0.X.0)
feat!     breaking change   major (X.0.0)
fix       bug fix           patch (0.0.X)
refactor  restructure       patch
perf      performance       patch
test      tests only        —
docs      documentation     —
chore     maintenance       patch
ci        CI/CD changes     —
```

---

## Quality

```
Check            Status
───────────────  ──────────────────────────────────────────
Tests            2900+ across 250+ suites
Modules          12 independent, composable
Concurrency      Strict — Sendable, @MainActor, actors
Formatting       swift-format enforced in CI
Docs             Mintlify with 40+ pages
Themes           4 built-in + custom theme protocol
Accessibility    VoiceOver, Dynamic Type, contrast, motion
WCAG             Contrast ratio validation (AA/AAA)
```

---

## Documentation

```
Resource            Description                          Path
──────────────────  ─────────────────────────────────    ────────────────
Full docs           Mintlify (Stripe-style)              docs/
API Reference       type-safe docs with examples         docs/
Project Memory      architecture decisions               .memory/
```

---

```
MIT License © 2025 byescaleira
https://github.com/byescaleira
```
