# Changelog

All notable changes to Prism will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- **New Module**: `PrismGamification` — Duolingo-style gamification system with SwiftData persistence and CloudKit sync
- **Challenges**: `PrismChallenge` protocol — define challenges as enums with title, type (counter/milestone), goal, points, category
- **Streaks**: Daily streak tracking with `recordStreakActivity`, automatic streak break detection, longest streak records
- **Badges**: `PrismBadge` protocol with 5 tiers (bronze→diamond), auto-evaluation via `evaluateBadges` for challenge/points/streak conditions
- **Leaderboards**: Multi-period (daily/weekly/monthly/allTime) scored leaderboards with rank computation
- **Gamification Analytics**: Event recording, aggregated snapshots, completion rates, average durations
- **Notifications**: `PrismNotificationScheduling` protocol with streak and challenge reminders
- **AI-Powered Messages**: `PrismGamificationIntelligence` — Apple Intelligence integration for personalized challenge celebrations, streak motivation, badge congratulations, leaderboard commentary
- **Prompt Builder**: `PrismGamificationPromptBuilder` — context-aware prompt generation for 7 message kinds
- **Fallback Messages**: `PrismGamificationFallbacks` — static messages when AI is unavailable
- **Batch Generation**: `generateMessages` for multiple gamification events
- **Auto-Fallback**: `messageWithFallback` — AI when available, static otherwise
- **New Module**: `PrismSecurity` — unified security layer for Apple platforms
- **Permissions**: `PrismPermissionClient` — unified API for 16 system permissions with request/check/monitor
- **Biometric Auth**: `PrismBiometricAuth` — simplified Face ID / Touch ID / Optic ID with result-based API
- **Keychain**: `PrismKeychain` — full CRUD wrapper with access control, Codable support, and iCloud sync option
- **Secure Enclave**: `PrismSecureEnclave` — P256 key generation, signing, and verification via hardware
- **Encryption**: `PrismEncryptor` — AES-GCM and ChaChaPoly symmetric encryption via CryptoKit
- **Hashing**: `PrismHasher` — SHA256/384/512 hashing and HMAC authentication/verification
- **Key Derivation**: `PrismKeyDerivation` — HKDF and password-based key derivation with salt generation
- **Secure Storage**: `PrismSecureStore` — high-level encrypt + keychain with preset configurations (default, biometric, high-security)
- **Permission Monitor**: `PrismPermissionMonitor` — AsyncStream of permission status changes
- 85 tests across 15 suites for PrismSecurity
- **Certificate Pinning**: `PrismCertificatePin`, `PrismPinningValidator`, `PrismCertificatePinningDelegate` — SHA-256 public key pinning with strict/reportOnly/TOFU policies
- **Data Integrity**: `PrismIntegrityChecker` — jailbreak, debugger, simulator, reverse engineering detection; `PrismDataSeal` — HMAC-SHA256 tamper-evident sealing; `PrismFileIntegrity` — SHA-256 file verification
- **Secure Transport**: `PrismKeyAgreement` — P256 ECDH + HKDF; `PrismSecureEnvelope` — encrypt-then-sign with ephemeral keys (forward secrecy); `PrismSecureChannel` — bidirectional encrypted channel
- **Security Audit Log**: `PrismSecurityAuditLog` — hash-chain append-only log with tamper verification; `PrismAuditExporter` — JSON/summary export
- **Token Manager**: `PrismTokenManager` — actor-based JWT lifecycle with concurrent refresh; `PrismAccessToken` — JWT decode; `PrismTokenInterceptor` — auto-inject Bearer tokens
- **Privacy Guard**: `PrismRedactor` — regex PII detection (email/phone/SSN/credit card/IP); `PrismScreenProtection` — SwiftUI modifier; `PrismClipboardGuard` — auto-clearing clipboard; `PrismPrivacyGuard` — unified facade
- 101 additional tests across 19 suites for PrismSecurity Phase 2 (186 total)

### Changed

- Removed redundant `as? String` casts in PrismServer tracing and versioning
- Replaced force unwrap with safe binding in `PrismTreemap.currentItems`
- Increased timing tolerance in PrismScheduler test to fix flaky CI
- Updated README with all 11 modules, PrismGamification, PrismSecurity, and PrismServer sections
- Restructured Mintlify navigation for equal module coverage

### Refactored

- Extracted types and delegates from `PrismCameraClient` (544 → 274+189+75 lines)
- Extracted types from `PrismIntelligenceClient` (649 → 416+160 lines)
- Extracted types and delegates from `PrismBluetoothClient`
- Extracted types from `PrismMotionClient`
- Extracted training types and runtime from `PrismIntelligenceLocalTrainer`
- Extracted HTML templates from `PrismSwaggerUI`
- Extracted AST types from `PrismGraphQLParser`
- Extracted renderers and themes from PrismUI RichText

### Documentation

- Added `///` doc comments to all public APIs across all 8 modules (~2000+ APIs)

### Testing

- Added tests for PrismNetwork retry policies, cache, multipart upload, deduplicator, offline queue, and GraphQL types
- Added tests for PrismIntelligence types, training configurations, and result enums
- Added tests for PrismCapabilities Bluetooth, Motion, and Camera types
- Added tests for PrismArchitecture disk and UserDefaults persistence
- Added PrismVideo downloader status tests and edge cases
- Added PrismGamification test suites: challenges, streaks, badges, leaderboards, analytics, notifications, AI integration
- Total test count: 2357 → 2557 (+200 tests, 30 new suites)

## [4.4.0] - 2026-04-28

### Added

- **WebSocket Rooms**: `PrismWebSocketRoom`, `PrismRoomManager` — named rooms with broadcast, join/leave, and room-scoped messaging
- **Cron Scheduler**: `PrismCronScheduler`, `PrismCronExpression` — cron-style recurring task scheduling with expression parsing
- **Lifecycle Hooks**: `PrismHooks` — server lifecycle hooks for startup, shutdown, and request pipeline events
- **Content Negotiation**: `PrismContentNegotiation` — automatic response format selection based on `Accept` header
- **Relationships**: `PrismRelationship` — declarative model relationship definitions for eager/lazy loading
- **Rate Limiter v2**: `PrismRateLimitV2` — sliding window and token bucket algorithms with pluggable backends
- **Body Parser**: `PrismBodyParser` — streaming body parser for JSON, form-urlencoded, and multipart payloads
- **Cluster**: `PrismCluster` — multi-process clustering for utilizing all CPU cores

## [4.3.0] - 2026-04-28

### Added

- **GraphQL**: `PrismGraphQLSchema`, `PrismGraphQLParser`, `PrismGraphQLExecutor`, `PrismGraphQLMiddleware` — schema-first GraphQL execution engine
- **MCP (Model Context Protocol)**: `PrismMCPServer` — MCP server implementation for AI tool integration
- **Streaming**: `PrismStreamingResponse` — chunked transfer encoding and streaming response bodies
- **SSE (Server-Sent Events)**: `PrismSSE` — server-sent event streams with named events and retry
- **API Versioning**: `PrismVersioningMiddleware`, `PrismVersionedRouter` — URL prefix, header, and query param version extraction
- **Distributed Tracing**: `PrismTracingMiddleware`, `PrismTraceContext` — request ID propagation and correlation
- **Dependency Injection**: `PrismDI`, `PrismServiceContainer` — type-safe service registration and resolution
- **Background Tasks**: `PrismBackgroundTaskRunner` — async background task execution with lifecycle management
- **HTTP Client**: `PrismHTTPClient` — server-side HTTP client for service-to-service communication
- **Testing Utilities**: `PrismTestServer`, `PrismTestRequest` — in-process test helpers for server routes

## [4.2.0] - 2026-04-28

### Added

- **Validation**: `PrismValidator`, `PrismValidationRule` — composable request validation with built-in rules
- **Event System**: `PrismEventBus`, `PrismEvent` — pub/sub event bus for decoupled communication
- **Connection Pool**: `PrismConnectionPool` — generic connection pooling with health checks
- **File Upload**: `PrismFileUpload` — multipart file upload handling with size limits and type validation
- **Graceful Shutdown**: `PrismGracefulShutdown` — signal handling and in-flight request draining
- **Health Checks**: `PrismHealthCheck`, `PrismMetrics` — health endpoint and metrics collection
- **Configuration**: `PrismConfig` — environment-aware configuration loading from files and env vars
- **Error Handling**: `PrismErrorMiddleware` — structured error responses with custom error pages

## [4.1.0] - 2026-04-28

### Added

- **Cache**: `PrismCacheStore`, `PrismCache` — pluggable caching with in-memory and custom backends
- **Database**: `PrismDatabaseStore`, `PrismMigrationRunner` — database abstraction with migration support
- **Session**: `PrismSessionMiddleware`, `PrismSession` — server-side session management with pluggable stores
- **Template Engine**: `PrismTemplateEngine` — HTML template rendering with variable interpolation
- **Job Queue**: `PrismJobQueue`, `PrismJobStore` — async background job processing with retry and scheduling
- **OpenAPI**: `PrismOpenAPIGenerator`, `PrismSwaggerUI` — automatic OpenAPI spec generation with Swagger UI
- **HTTP/2**: HTTP/2 support via TLS configuration
- **CLI Scaffold**: `PrismCLI` — command-line interface for server management

## [4.0.0] - 2026-04-28

### Added

- **New Module**: `PrismServer` — fully native Swift 6.3 HTTP server framework with zero external dependencies
- `PrismHTTPServer` — async/await HTTP server with configurable host, port, and TLS
- `PrismRouter` — path-based request routing with parameter extraction and middleware support
- `PrismMiddleware` (server) — composable request/response pipeline
- `PrismHTTPRequest`, `PrismHTTPResponse` — typed request and response models
- `PrismWebSocket` — WebSocket upgrade and bidirectional messaging
- `PrismStaticFiles` — static file serving with MIME type detection
- `PrismCORS` — configurable CORS middleware
- `PrismCSRF` — CSRF protection middleware
- `PrismJWT` — JSON Web Token signing and verification
- `PrismRateLimit` — request rate limiting with configurable windows
- `PrismSecurityHeaders` — security header middleware (HSTS, CSP, etc.)
- `PrismProxy` — reverse proxy middleware
- `PrismCircuitBreaker` — circuit breaker pattern for resilient service calls
- `PrismPasswordHashing` — bcrypt and scrypt password hashing
- `PrismMailer` — SMTP email sending
- `PrismLogger` (server) — structured JSON logging
- `PrismI18n` — server-side internationalization
- `PrismFeatureFlags` — runtime feature flag management
- `PrismSeeder` — database seeding utilities
- `PrismRedirects` — URL redirect middleware
- `PrismRequestTimeout` — request timeout enforcement
- `PrismResponseCompression` — gzip/deflate response compression
- `PrismTLS` — TLS certificate configuration
- 69 test files with comprehensive server test coverage

## [3.2.0] - 2026-04-28

### Added

- **Core Location**: `PrismLocationClient` — authorization, continuous updates, geofencing, geocoding, and reverse geocoding
- **MapKit**: `PrismMapClient` — directions, estimated travel time, and point-of-interest search
- **CoreBluetooth**: `PrismBluetoothClient` — BLE scanning, connect, services, characteristics, notifications
- **NearbyInteraction**: `PrismNearbyClient` — UWB peer discovery, distance and direction ranging
- **MultipeerConnectivity**: `PrismMultipeerClient` — advertising, browsing, peer invitations, data exchange
- **CallKit**: `PrismCallClient` — incoming/outgoing call reporting, call actions (answer, end, hold, mute)
- **Core NFC**: `PrismNFCClient` — NDEF read/write, ISO 7816 tag commands
- **Biometrics**: `PrismBiometricClient` — Face ID, Touch ID, Optic ID, passcode fallback via LocalAuthentication
- **App Intents**: `PrismAppIntentClient` — intent donation, deletion, Siri shortcut suggestions
- **Core Motion**: `PrismMotionClient` — accelerometer, gyroscope, device motion, pedometer, activity recognition, altimeter
- **Camera**: `PrismCameraClient` — AVFoundation capture session, photo/video, barcode scanning, zoom, torch
- **GameKit**: `PrismGameCenterClient` — authentication, leaderboards, achievements, matchmaking
- `PrismLocationPermission`, `PrismLocationAccuracy`, `PrismLocation`, `PrismGeofenceRegion`, `PrismGeocodingResult` value types
- `PrismMapRoute`, `PrismMapTransportType`, `PrismPOI` value types
- `PrismBluetoothState`, `PrismPeripheral`, `PrismBLEService`, `PrismBLECharacteristic`, `PrismCharacteristicProperties` value types
- `PrismNearbyObject`, `PrismNearbySessionState`, `PrismPeer`, `PrismMultipeerState` value types
- `PrismCallType`, `PrismCallEndReason`, `PrismCallInfo`, `PrismBlockedCaller`, `PrismCallAction` value types
- `PrismNFCTagType`, `PrismNDEFTypeNameFormat`, `PrismNDEFRecord`, `PrismNDEFMessage`, `PrismNFCReadResult` value types
- `PrismBiometricType`, `PrismBiometricPolicy`, `PrismBiometricError`, `PrismBiometricResult` value types
- `PrismIntentDonation`, `PrismShortcutPhrase`, `PrismIntentPrediction`, `PrismSiriTipStyle` value types
- `PrismAccelerometerData`, `PrismGyroscopeData`, `PrismDeviceMotion`, `PrismPedometerData`, `PrismActivityType`, `PrismAltitudeData` value types
- `PrismCameraPosition`, `PrismCaptureMode`, `PrismFlashMode`, `PrismCameraPermission`, `PrismPhotoSettings`, `PrismVideoSettings`, `PrismCapturedPhoto`, `PrismBarcodeSymbology`, `PrismBarcodeResult` value types
- `PrismGameCenterPlayer`, `PrismLeaderboardScore`, `PrismLeaderboardScope`, `PrismAchievement`, `PrismMatchRequest`, `PrismMatchStatus` value types
- 134 new tests across 10 capability suites

## [3.1.0] - 2026-04-28

### Added

- **New Module**: `PrismCapabilities` — Apple Developer Program capability wrappers
- **StoreKit 2**: `PrismStoreKitClient` — products, purchases, subscriptions, transaction listener
- **MetricKit**: `PrismMetricKitClient` — app metrics and crash diagnostics via MXMetricManager
- **Device Activity**: `PrismDeviceActivityClient` — Screen Time monitoring schedules and events
- **Background Tasks**: `PrismBackgroundTaskClient` — BGTaskScheduler registration and scheduling
- **Apple Pay**: `PrismApplePayClient` — payment requests with PKPaymentAuthorizationController
- **App Clips**: `PrismAppClipClient` — invocation handling, location verification, full app install
- **Sign in with Apple**: `PrismSignInWithAppleClient` — authentication with credential state checking
- **Push Notifications**: `PrismPushNotificationClient` — permissions, local/remote, rich notifications
- **CloudKit**: `PrismCloudKitClient` — record CRUD, queries, subscriptions, account status
- **HealthKit**: `PrismHealthKitClient` — authorization, samples, statistics, background delivery
- **WidgetKit**: `PrismWidgetCenter` — timeline reloading and configuration queries
- 40+ new tests

## [0.16.0] - 2026-04-28

### Added

- feat(ui): add developer experience tooling — code generator, token inspector, debugger, live reload, prototyper, environment debugger
- feat(ui): add deep SwiftData integration — model view, form builder, migration helper, cloud sync, predicate builder
- feat(ui): add Internationalization V2 — RTL layout, pluralization, locale formatters, string catalog, multi-locale preview
- feat(ui): add accessibility v3 — color blindness simulation, contrast checker, focus order, voice control, announcements
- feat(ui): add performance toolkit — lazy views, render profiler, memory tracker, image downsampler, prefetch coordinator

### Changed

- Merge feature/developer-experience into main
- Merge feature/swiftdata-integration into main
- Merge feature/internationalization-v2 into main
- chore: ignore worktree dirs
- Merge feature/performance-toolkit into main

## [2.1.0] - 2026-04-28

### Added

- **Heatmap**: `PrismHeatmapCell`, `PrismHeatmap` — colored grid from 2D numeric data with color interpolation and optional row/column labels
- **Treemap**: `PrismTreemapItem`, `PrismTreemap` — squarified treemap layout with drill-down navigation and breadcrumb trail
- **Radar Chart**: `PrismRadarAxis`, `PrismRadarDataSet`, `PrismRadarChart` — polygon overlay with multiple data sets, axis labels, and grid lines
- **Sparkline**: `PrismSparklineStyle`, `PrismSparkline` — inline mini chart with line, area, and bar styles plus min/max markers and trend coloring
- **Funnel Chart**: `PrismFunnelStage`, `PrismFunnelChart` — tapered trapezoid stages with conversion rate labels
- **Candlestick Chart**: `PrismCandlestick`, `PrismCandlestickChart` — standard OHLC candles with green/red bullish/bearish coloring
- 28 new tests

## [2.2.0] - 2026-04-28

### Added

- **Markdown Renderer**: `PrismMarkdownView` — renders Markdown strings as styled SwiftUI with headings, bold, italic, code blocks, inline code, links, lists, blockquotes, images, and horizontal rules
- **Markdown Styles**: `PrismMarkdownStyle` — default, compact, and documentation rendering modes
- **Rich Text Editor**: `PrismRichTextEditor` — attributed string editor with `PrismFormattingToolbar` for bold, italic, underline, strikethrough, code, headings, links, and lists
- **Attributed String Builder**: `PrismAttributedStringBuilder` — chainable API for composing styled text with `.text()`, `.bold()`, `.italic()`, `.code()`, `.link()`, `.colored()`, `.newline()`
- **Result Builder**: `@PrismTextBuilder` — declarative attributed string composition using Swift result builder syntax
- **Syntax Highlighter**: `PrismSyntaxHighlighter` — token-based syntax coloring for Swift, JSON, HTML, CSS, JavaScript, and Python
- **Code Block View**: `PrismCodeBlock` — themed code display with line numbers, syntax highlighting, and copy-to-clipboard button
- 22 new tests

## [2.3.0] - 2026-04-28

### Added

- **Chat Bubble**: `PrismChatBubble` — message bubble with sender alignment, timestamp, and delivery status
- **Bubble Styles**: `PrismBubbleStyle` — filled, outlined, and glass visual variants
- **Message List**: `PrismMessageList` — scrollable conversation view with date separators and auto-scroll
- **Message Model**: `PrismMessage` and `PrismMessageStatus` — chat message data with 5-state delivery tracking
- **Message Grouping**: `PrismMessageGroup` — groups consecutive messages from the same sender
- **Typing Indicator**: `PrismTypingIndicator` — animated bouncing dots with staggered animation
- **Typing Bubble**: `PrismTypingBubble` — typing indicator inside a chat bubble
- **Reaction Picker**: `PrismReactionPicker` — horizontal emoji strip with pop-in animation
- **Reaction Bar**: `PrismReactionBar` — displays emoji reactions with counts below a message
- **Reaction Model**: `PrismReaction` — emoji, count, and selection state
- **Thread View**: `PrismThreadView` — root message with indented, collapsible replies
- **Thread Model**: `PrismThread` — root message, replies, and reply count
- **Read Receipts**: `PrismReadReceiptIndicator` — checkmark icons for sent, delivered, and read status
- **Read Receipt List**: `PrismReadReceiptList` — expandable list of who read a message
- **Read Receipt Model**: `PrismReadReceipt` — userId, name, and readAt timestamp
- 35 new tests

## [2.4.0] - 2026-04-28

### Added

- **KPI Card**: `PrismKPICard` — metric card with title, value, trend, change percentage, sparkline, compact/expanded sizes
- **Trend Enum**: `PrismTrend` — up/down/flat direction with semantic color coding (green/red/gray)
- **Stat Grid**: `PrismStatGrid`, `PrismStatItem` — responsive grid of stat items with adaptive columns
- **Activity Feed**: `PrismActivityFeed`, `PrismActivity`, `PrismActivityGroup` — chronological feed with avatars, relative timestamps, date grouping
- **Timeline**: `PrismTimeline`, `PrismTimelineEvent`, `PrismEventStatus` — vertical timeline with connecting line and status dots (completed/current/upcoming/failed)
- **Comparison Table**: `PrismComparisonTable`, `PrismComparisonFeature`, `PrismComparisonColumn`, `PrismFeatureValue` — feature comparison grid with highlighted column
- **Sparkline Row**: `PrismSparklineRow` — inline label + value + sparkline with optional trend indicator
- 30 new tests across all dashboard components

## [2.5.0] - 2026-04-28

### Added

- **Retry Policies**: `PrismRetryPolicy` protocol, `PrismExponentialBackoff` (exponential backoff with jitter), `PrismLinearRetry` (fixed delay), `PrismRetryableRequest` wrapper
- **Request Deduplication**: `PrismRequestDeduplicator` actor — coalesces identical in-flight requests by key (URL + method + body hash)
- **Offline Queue**: `PrismQueuedRequest` struct, `PrismOfflineQueue` actor with priority-based dequeue and auto-flush via `PrismConnectivityMonitor` (NWPathMonitor)
- **Response Caching**: `PrismCachePolicy` enum (4 strategies), `PrismCacheEntry` with TTL, `PrismResponseCache` actor with LRU eviction
- **GraphQL Support**: `PrismGraphQLQuery`, `PrismGraphQLResponse<T>`, `PrismGraphQLError`, `PrismGraphQLClient` actor for typed query/mutation execution
- **Multipart Upload**: `PrismMultipartFormData` builder, `PrismUploadProgress` tracker, `PrismUploadTask` actor with AsyncStream progress
- 27 new tests

## [2.6.0] - 2026-04-28

### Added

- **Time-Travel Debugging**: `PrismStateSnapshot`, `PrismTimeTravelDebugger` — record, navigate, and jump through state history with configurable snapshot limits
- **State Persistence**: `PrismPersistenceStrategy` protocol with `PrismDiskPersistence`, `PrismKeychainPersistence`, `PrismUserDefaultsPersistence` — pluggable state saving strategies
- **Persist Middleware**: `PrismPersistMiddleware` — auto-saves state changes via any persistence strategy
- **Derived Stores**: `PrismDerivedStore` — read-only projected view of parent store with Equatable-based change detection
- **Store Scope**: `PrismStoreScope` — scoped store for child features with action mapping
- **Middleware Chaining DSL**: `PrismChainableMiddleware` protocol, `PrismLoggingMiddleware`, `PrismThrottleMiddleware`, `PrismMiddlewareChain` builder
- **Undo/Redo Stack**: `PrismUndoRedoStack` — configurable undo/redo state management with stack size limits
- 30 new tests

## [2.7.0] - 2026-04-28

### Added

- **Embedding Store**: `PrismEmbedding`, `PrismEmbeddingStore` actor — vector storage with cosine similarity search
- **RAG Pipeline**: `PrismRAGConfig`, `PrismTextChunker`, `PrismRAGPipeline` — chunk, embed, store, retrieve, generate workflow
- **Vision Classifier**: `PrismVisionClassifier` — image classification via Vision framework (`VNClassifyImageRequest`)
- **NLP Actions**: `PrismNLPActions` — sentiment analysis, entity extraction, language detection, tokenization via NaturalLanguage
- **Structured Output**: `PrismStructuredParser`, `PrismOutputValidator` — JSON extraction, key-value parsing, schema validation
- **Model Manager**: `PrismModelManager` actor — model lifecycle management with register, unload, and hot-swap
- 22+ new tests (Swift Testing)

## [2.5.0] - 2026-04-28

### Added

- **Retry Policies**: `PrismRetryPolicy` protocol, `PrismExponentialBackoff` (exponential backoff with jitter), `PrismLinearRetry` (fixed delay), `PrismRetryableRequest` wrapper
- **Request Deduplication**: `PrismRequestDeduplicator` actor — coalesces identical in-flight requests by key (URL + method + body hash)
- **Offline Queue**: `PrismQueuedRequest` struct, `PrismOfflineQueue` actor with priority-based dequeue and auto-flush via `PrismConnectivityMonitor` (NWPathMonitor)
- **Response Caching**: `PrismCachePolicy` enum (4 strategies), `PrismCacheEntry` with TTL, `PrismResponseCache` actor with LRU eviction
- **GraphQL Support**: `PrismGraphQLQuery`, `PrismGraphQLResponse<T>`, `PrismGraphQLError`, `PrismGraphQLClient` actor for typed query/mutation execution
- **Multipart Upload**: `PrismMultipartFormData` builder, `PrismUploadProgress` tracker, `PrismUploadTask` actor with AsyncStream progress
- 27 new tests

## [2.8.0] - 2026-04-28

### Added

- **Structured Logging**: `PrismStructuredLogger` actor — level-filtered, buffered logging with `PrismLogLevel`, `PrismLogEntry`, and pluggable `PrismLogDestination` protocol
- **Crash Reporter**: `PrismCrashReporter` actor — collects `PrismCrashReport` structs with stack traces, app version, metadata, and optional callback
- **Performance Traces**: `PrismPerformanceTracer` actor — hierarchical `PrismTraceSpan` with `beginSpan`/`endSpan` and auto-traced `measure()` helper
- **Network Inspector**: `PrismNetworkInspector` actor — records `PrismNetworkLog` entries with aggregate `averageLatency` and `errorRate` metrics
- **Analytics Funnel**: `PrismAnalyticsFunnel` actor — define ordered steps, record unique users per step, generate conversion rate reports
- 25 new tests (785 total)

## [1.10.0] - 2026-04-28

### Added

- **Component Generator**: `PrismComponentGenerator` — code generation from 6 templates (button, card, form, list, detail, settings)
- **Token Inspector**: `PrismTokenInspector` — debug panel showing active theme tokens
- **Component Debugger**: `PrismComponentDebugger` — render tracking with debug overlay
- **Live Reload**: `PrismLiveReloadServer` — protocol-based live reload coordination
- **Quick Prototyper**: `PrismPrototyper` — interactive screen builder with flow navigation
- **Environment Debugger**: `PrismEnvironmentDebugger` — floating badge showing environment state
- 24 new tests

## [1.9.0] - 2026-04-28

### Added

- **Model View**: `PrismModelView` — generic SwiftData CRUD list with detail view
- **Model Form Builder**: `PrismModelFormBuilder` — declarative form generation from field definitions
- **Migration Helper**: `PrismMigrationHelper` — ordered migration stage management
- **CloudKit Sync**: `PrismCloudSyncMonitor` — sync state monitoring with status indicator view
- **Predicate Builder**: `PrismPredicateBuilder` — chainable filter API with `PrismFilterBar` UI
- 28 new tests

## [1.8.0] - 2026-04-28

### Added

- **RTL Layout**: `PrismLayoutDirection`, `PrismBidirectionalStack` — automatic RTL/LTR layout handling
- **Pluralization**: `PrismPluralRule` — locale-aware plural categories with English, Arabic, Russian, Japanese rules
- **Locale Formatters**: `PrismNumberFormatter`, `PrismDateFormatter`, `PrismRelativeTimeFormatter` — locale-sensitive formatting
- **String Catalog**: `PrismLocalizedKey`, `PrismStringExporter` — localization key management
- **Multi-Locale Preview**: `PrismMultiLocalePreview` — side-by-side locale comparison
- 28 new tests

## [1.7.0] - 2026-04-28

### Added

- **Lazy View**: `PrismLazyView` — deferred body evaluation with placeholder support
- **Render Profiler**: `PrismRenderProfiler` — real-time render count and timing with debug overlay
- **Memory Tracker**: `PrismMemoryTrackerV2` — mach_task_basic_info memory snapshots
- **Image Downsampler**: `PrismImageDownsampler` — CGImageSource-based downsampling for memory efficiency
- **Prefetch Coordinator**: `PrismPrefetchCoordinator` — protocol-based prefetch task management
- 29 new tests

## [1.6.0] - 2026-04-28

### Added

- **Color Blindness Simulation**: `PrismColorBlindnessSimulator` — 7 vision type simulations with view modifier
- **Focus Order Validation**: `PrismFocusOrderValidator` — priority-based focus order checking
- **Voice Control Labels**: `PrismVoiceControlGroup` + modifiers for voice control accessibility
- **WCAG Contrast Checker V2**: `PrismContrastChecker` — contrast ratio, level compliance, auto color suggestion
- **Accessibility Announcements**: `PrismAccessibilityAnnouncer` — priority-based screen reader announcements
- 25 new tests

## [1.5.0] - 2026-04-28

### Added

- **Migration Guide**: DocC article — step-by-step migration from raw SwiftUI to PrismUI tokens and components
- **Plugin Guide**: DocC article — creating, installing, and querying plugins
- **Architecture Guide**: DocC article — module graph, selective imports, design token flow, ecosystem split guidance

### Changed

- DocC catalog updated with 3 new guides (7 total)

## [0.15.0] - 2026-04-28

### Added

- feat(ui): add plugin architecture — extensible themes, tokens, components without forking
## [1.4.0] - 2026-04-28

### Added

- **Plugin Architecture**: `PrismPlugin` protocol + `PrismPluginRegistry` — register custom themes, color/spacing/radius overrides, and component factories without forking
- `prismPlugin(theme:)` modifier to apply plugin-registered themes
- 16 new tests (626 total, 129 suites)

### Changed

- DocC catalog updated with Plugin Architecture section

## [0.14.0] - 2026-04-28

### Added

- feat(ui): add comprehensive preview catalog — 13 preview providers for every component category

### Changed

- Merge pull request #19 from rafaelesantos/feature/previews-catalog
## [1.3.0] - 2026-04-28

### Added

- **Preview Catalog**: `PrismPreviews` — 13 ready-to-use preview providers covering buttons, text fields, cards, tags, avatars, loading states, banners, search, forms, layout, elevation, motion, and multi-theme comparison
- 15 new tests (610 total, 128 suites)

### Changed

- DocC catalog updated with PrismPreviews in Preview Tools section

## [0.13.0] - 2026-04-28

### Added

- feat(ui): add component variants v2 — icon button, expandable card, skeleton, search suggestions

### Changed

- Merge pull request #18 from rafaelesantos/feature/component-variants-v2
## [1.2.0] - 2026-04-28

### Added

- **Icon Button**: `PrismIconButton` — compact circular icon button with 3 sizes (small/regular/large), destructive role support
- **Expandable Card**: `PrismExpandableCard` — tap-to-expand card with spring animation, chevron indicator, accessibility hints
- **Skeleton View**: `PrismSkeletonView` — shimmer loading placeholders with 5 layouts (text, avatar, card, list, custom)
- **Search Suggestions**: `PrismSearchSuggestions` — autocomplete search with dropdown suggestion list, max items control
- **Button Group**: `PrismButtonGroup` — horizontal button container with alignment and spacing control
- **Segmented Buttons**: `PrismSegmentedButtons` — mutually exclusive option strip with animated selection

### Changed

- DocC catalog updated with Component Variants V2 section

## [0.12.0] - 2026-04-28

### Added

- feat(ui): add deep animation system — springs, keyframes, gestures, physics, staggering

### Changed

- Merge pull request #17 from rafaelesantos/feature/animation-system
## [1.1.0] - 2026-04-28

### Added

- **Spring Configs**: `PrismSpringConfig` — 7 named presets (snappy, gentle, bouncy, stiff, dramatic, critical, rubber) with `prismSpring` modifier
- **Keyframe Builder**: `PrismKeyframeView` — declarative keyframe animations with 4 preset sequences (popIn, dropIn, flipIn, heartbeat)
- **Gesture Animations**: `PrismDraggable`, `PrismPinchable`, `PrismRotatable` — spring-back gesture-driven interactive animations
- **Shared Transitions**: `PrismSharedElement`, `PrismHeroTransition` — matchedGeometryEffect wrappers with hero transition container
- **Physics Animations**: `PrismGravityDrop`, `PrismMomentumScroll`, `PrismFloat`, `PrismParticleEffect` — gravity, momentum, bobbing, particle celebration effects
- **Staggered Animations**: `PrismStaggeredList`, `prismStagger` modifier — 5 stagger styles (slideUp, slideLeft, fadeIn, scaleIn, slideRight)

### Changed

- DocC catalog updated with Animation System section

## [0.11.1] - 2026-04-28

### Changed

- Merge pull request #16 from rafaelesantos/feature/production-ship

### Fixed

- fix: stabilize flaky async tests, eliminate all compiler warnings
## [0.11.0] - 2026-04-28

### Added

- feat(ui): add theme editor, auto theme generation, Figma sync, interactive storybook
- feat(ui): add accessibility v2, localization, performance, style protocols, environment setup, preview blocks, navigation path, observable, watchOS complications, visionOS volumes, macOS menu bar
- feat(ui): add context menu, gauge, group box, label styles, content transitions, sensory feedback, image resource, table, paste button, refreshable, TipKit, timeline, settings
- feat(ui): add map, photos, document, headers, gradients, toolbar, validation, previews, onboarding, redacted styles, notification banner
- feat(ui): align with Apple reference projects — glass, mesh gradient, transitions, split view, responsive layout
- feat(ui): add haptics, drag/drop, keyboard shortcuts, focus, undo, theme persistence, component browser
- feat(ui): add widgets, live activities, charts, animations, token export, SwiftData integration
- feat(ui): infrastructure polish — localization, visionOS, accessibility, performance
- feat(ui): add theme variants, snapshot testing, DocC guides, README/CHANGELOG update
- feat(ui): add 16 new components — primitives, composites, forms, modifiers
- feat(ui): add Phases 7-10 — Composites, Forms, Lists, Polish
- feat(ui): add Phase 5 navigation + Phase 6 testing infrastructure
- feat(ui): add Phase 4 accessibility tools + update DocC
- feat(ui): add Phase 3 layout system — Stack, Grid, Section, Scaffold, Spacer
- feat(ui): add Phase 2 primitives — Button, Icon, Image, TextField, Card, Tag, Divider, LoadingState
- feat(ui): rewrite PrismUI design system from scratch — Phase 1

### Changed

- Merge pull request #3 from rafaelesantos/dependabot/github_actions/actions/upload-artifact-7
- Merge pull request #2 from rafaelesantos/dependabot/github_actions/actions/checkout-6
- Merge pull request #15 from rafaelesantos/feature/advanced-features
- chore(release): update changelog for v0.10.0
- Merge pull request #14 from rafaelesantos/feature/quality-dx-platform
- chore(release): update changelog for v0.9.0
- Merge pull request #13 from rafaelesantos/feature/final-gaps-polish
- chore(release): update changelog for v0.8.0
- Merge pull request #12 from rafaelesantos/feature/comprehensive-expansion
- chore(release): update changelog for v0.7.0
- Merge pull request #11 from rafaelesantos/feature/apple-reference-upgrades
- chore(release): update changelog for v0.6.0
- Merge pull request #10 from rafaelesantos/feature/platform-interactions
- chore(release): update changelog for v0.5.0
- Merge pull request #9 from rafaelesantos/feature/advanced-integrations
- chore: resolve merge conflict in CHANGELOG.md
- chore(release): update changelog for v0.4.0
- Merge pull request #8 from rafaelesantos/feature/infra-polish
- chore(release): update changelog for v0.3.0
- Merge pull request #7 from rafaelesantos/feature/polish-and-docs
- chore: resolve merge conflict in CHANGELOG.md
- chore(release): update changelog for v0.2.0
- Merge pull request #6 from rafaelesantos/feature/new-components
- chore(release): update changelog for v0.1.0
- Merge pull request #5 from rafaelesantos/feature/design-system-v2
- docs(ui): update DocC with composites, forms, and lists sections
- docs(ui): update DocC catalog with navigation and testing sections
- chore(docs): remove debug step from docs workflow
- debug(docs): add archive structure inspection step
- ci: update coverage badge to -%
- Bump actions/checkout from 4 to 6
- Bump actions/upload-artifact from 4 to 7

### Fixed

- fix(docs): add hosting-base-path for DocC static hosting
- fix(test): increase settleTasks delay for CI reliability
- fix(ci): use macos-26 runner for Swift 6.3 and platform v26
- fix(ci): lower swift-tools-version to 6.2 for CI compatibility
- fix(ci): auto-detect Xcode with Swift 6.3 on runner
- fix(ci): use swift-actions/setup-swift with Swift 6.3
- fix(ci): use Xcode 26.3 for Swift 6.3 toolchain
- fix(ci): pin Xcode 26.4 for Swift 6.3 toolchain
- fix(ci): pin Xcode 26.0 for Swift 6.3 compatibility
- fix(ci): use setup-xcode action to install latest Xcode
- fix(ci): allow dependabot PRs to merge into main
## [0.11.0] - 2026-04-28

### Added

- **Theme Editor**: `PrismThemeEditor` — live runtime theme builder with color pickers, spacing/radius/elevation/motion previews, dark mode toggle, and JSON export
- **Auto Theme Generation**: `PrismAutoTheme` — generate `BrandTheme` from a single color using 4 color harmony strategies (complementary, analogous, triadic, split-complementary) with HSL color math
- **Figma Sync**: `PrismFigmaSync` — bidirectional token sync: export to Figma Variables format, import from Figma JSON to `BrandTheme`, plus W3C DTCG format for cross-tool compatibility
- **Storybook**: `PrismStorybook` — interactive Storybook-style component explorer with NavigationSplitView sidebar, theme switching, dark mode/large text toggles, and live component stories across 5 categories
- 20 new tests (542 total, 113 suites)

### Changed

- DocC catalog updated with Theme Editor, Auto Theme, Figma Sync, Storybook sections

## [0.10.0] - 2026-04-28

### Added

- feat(ui): add accessibility v2, localization, performance, style protocols, environment setup, preview blocks, navigation path, observable, watchOS complications, visionOS volumes, macOS menu bar

### Changed

- Merge pull request #14 from rafaelesantos/feature/quality-dx-platform
## [0.10.0] - 2026-04-28

### Added

- **Accessibility v2**: `prismAccessibility(label:hint:value:traits:)`, `prismAccessibilityHeader()`, `prismAccessibilityGroup()`, `prismAccessibilityAction()`, `prismAccessibilitySortPriority()`, `prismAnnounce()`
- **Localization expansion**: 18 new `PrismStrings` keys (continue, getStarted, paste, save, done, edit, add, close, back, next, previous, share, settings, selectPhoto, untitled, noResults, tryAgain, errorOccurred)
- **Performance benchmarks**: `prismBenchmark()` modifier with OSSignposter + render counting, `PrismMemoryTracker` for DEBUG memory profiling
- **Style protocol system**: `PrismCustomButtonStyle`, `PrismCustomCardStyle` protocols with 3 built-in card styles (elevated, outlined, flat)
- **Environment catalog**: `prismEnvironment(theme:colorScheme:)` single-call setup
- **Preview blocks**: `PrismPreviewBlocks` with 6 ready-made previews (buttons, typography, colors, spacing, themes, radii)
- **watchOS complications**: `PrismComplicationGauge`, `PrismComplicationText` with themed styling
- **visionOS volumes**: `PrismVolumeView` for spatial content, `PrismOrnamentView` for glass ornaments
- **macOS menu bar**: `PrismMenuBarContent`, `PrismMenuBarButton` with themed styling
- **Navigation path**: `PrismNavigationPath` — type-safe push/pop/popToRoot/replace with `@Observable`
- **Observable helpers**: `PrismViewModel` protocol, `prismObservable()` modifier for `@Observable` injection
- 29 new tests (522 total, 108 suites)

### Changed

- DocC catalog updated with Accessibility Modifiers, Style Protocols, Navigation Path, Observable, Preview Blocks, Performance, Complications, Volumes, Menu Bar sections

## [0.9.0] - 2026-04-28

### Added

- feat(ui): add context menu, gauge, group box, label styles, content transitions, sensory feedback, image resource, table, paste button, refreshable, TipKit, timeline, settings

### Changed

- Merge pull request #13 from rafaelesantos/feature/final-gaps-polish
## [0.9.0] - 2026-04-28

### Added

- **Context Menu**: `prismContextMenu()` with optional preview support
- **Gauge**: `PrismGauge` with semantic color tinting (error/warning/success by value range)
- **GroupBox**: `PrismGroupBox` with themed background and optional label/title
- **Label Style**: `PrismLabelStyle` (automatic/iconOnly/titleOnly/titleAndIcon) with `prismLabelStyle()` modifier
- **Content Transition**: `PrismContentTransition` (numericText/countdown/interpolate/opacity/identity) with `prismContentTransition()` modifier
- **Sensory Feedback**: `PrismSensoryFeedback` (11 types) with `prismSensoryFeedback()` modifier (iOS 17+)
- **Image Resource**: `PrismImageResource` for system/catalog images with token-based tinting
- **Table**: `PrismTable` themed wrapper for macOS Table views
- **Paste Button**: `PrismPasteButton` with platform-adaptive implementation (PasteButton on iOS/macOS, fallback on others)
- **Refreshable**: `prismRefreshable()` modifier for pull-to-refresh
- **TipKit Integration**: `PrismTipView` and `prismPopoverTip()` with themed tip background and tint (iOS 17+)
- **Timeline View**: `PrismTimelineView` with `PrismTimelineSchedule` (animation/everySecond/custom/explicit)
- **Settings**: `PrismSettingsView` and `PrismSettingsSection` for themed preferences forms
- 30 new tests (493 total, 98 suites)

### Changed

- DocC catalog updated with Context Menu, Gauge, GroupBox, Label Style, Content Transition, Sensory Feedback, Image Resource, Table, Paste, Timeline, TipKit, Settings sections

## [0.8.0] - 2026-04-28

### Added

- feat(ui): add map, photos, document, headers, gradients, toolbar, validation, previews, onboarding, redacted styles, notification banner

### Changed

- Merge pull request #12 from rafaelesantos/feature/comprehensive-expansion
## [0.8.0] - 2026-04-28

### Added

- **Map Integration**: `PrismMap`, `PrismMapMarker`, `PrismMapAnnotation` with MapKit and themed tints
- **Photo Picker**: `PrismPhotoPicker`, `PrismMultiPhotoPicker` wrapping PhotosUI
- **Document Support**: `PrismDocument` protocol and `PrismDocumentView` scaffold
- **Flexible Headers**: `PrismFlexibleHeader` (stretchy), `PrismParallaxHeader` (parallax + overlay)
- **Gradients & Materials**: `PrismLinearGradient`, `PrismRadialGradient`, `PrismAngularGradient`, `PrismMaterial` (6 cases) with `prismMaterial()` modifier
- **Toolbar**: `PrismToolbarPlacement` (7 presets), `PrismToolbarButton`, `PrismToolbarMenu` with themed styling
- **Form Validation**: `PrismValidationRule` (required/email/minLength/maxLength/range/regex/custom), `PrismValidatedField`
- **Preview Tools**: `PrismDevicePreview`, `PrismLocalePreview` for multi-device and RTL previews
- **Onboarding**: `PrismOnboarding` paged walkthrough with progress dots and themed CTA
- **Redacted Styles**: `PrismRedactedStyle` (shimmer/pulse/blur) with `prismRedacted()` modifier
- **Notification Banner**: `PrismNotificationBanner` with swipe-to-dismiss, auto-timeout, 4 styles (info/success/warning/error)
- 42 new tests (463 total, 85 suites)

### Changed

- DocC catalog updated with Map, Photos, Document, Headers, Gradients, Toolbar, Validation, Preview, Onboarding, Redacted, Banner sections

## [0.7.0] - 2026-04-28

### Added

- feat(ui): align with Apple reference projects — glass, mesh gradient, transitions, split view, responsive layout

### Changed

- Merge pull request #11 from rafaelesantos/feature/apple-reference-upgrades

## [0.7.0] - 2026-04-28

### Added

- **Liquid Glass**: `PrismGlassContainer` (coordinated glass layout), `prismGlassID()` (glass animation identity), `prismBackgroundExtension()`, `prismGlass(cornerRadius:)`
- **Glass buttons**: `.glass` and `.glassProminent` variants use native `buttonStyle(.glass)` / `.glassProminent`
- **MeshGradient**: `PrismMeshGradient` with 4 presets (aurora, sunset, ocean, subtle) + custom points
- **Navigation transitions**: `prismZoomTransition()`, `prismTransitionSource()` for hero animations
- **Scroll transitions**: `prismScrollTransition()` (scale), `prismScrollTransitionFade()`, `prismScrollEdge()` soft edge
- **NavigationSplitView**: `PrismSplitView` (2-column), `PrismThreeColumnView` (3-column) wrappers
- **Typography width**: `prismFontWidth()`, `.font(weight:width:)` for expanded/condensed text
- **Spring motion tokens**: `.snappy`, `.bouncy`, `.smooth` using SwiftUI's built-in spring animations
- **Responsive layout**: `prismContainerFrame()`, `PrismScaledView`, `prismGeometry()`, `prismContentMargins()`
- **Sheet upgrades**: item-based presentation, `interactiveDismiss`, `PrismSheetBackground` (material/clear)
- **Confirmation dialog**: `prismConfirmationDialog()` with actions and message
- **Inspector**: `prismInspector()` for iPad/macOS sidebar
- **ContentUnavailableView**: `PrismContentUnavailable`, `PrismSearchUnavailable` wrapping native iOS 17+ views
- **ShareLink**: `PrismShareButton` for text, URL, and Transferable sharing
- **Searchable**: `prismSearchable()` with keyboard dismiss
- **Scroll control**: `prismScrollTarget()` (viewAligned/paging), `prismScrollIndicators()`, `prismScrollClipDisabled()`
- **Symbol transitions**: `prismSymbolTransition()` for animated SF Symbol content
- **Toolbar**: `prismToolbarBackground()` visibility control
- 54 new tests (421 total, 73 suites)

### Changed

- `PrismButton` glass variant now uses native `buttonStyle(.glass)` instead of custom style
- `MotionToken` now has 8 cases (added snappy, bouncy, smooth)
- Existing motion duration test updated from "strictly increasing" to "positive" to accommodate spring tokens
- DocC catalog updated with Glass Effects, Mesh Gradients, Split View, Responsive, Sharing, Empty States sections

## [0.6.0] - 2026-04-28

### Added

- feat(ui): add haptics, drag/drop, keyboard shortcuts, focus, undo, theme persistence, component browser

### Changed

- Merge pull request #10 from rafaelesantos/feature/platform-interactions

## [0.6.0] - 2026-04-28

### Added

- **Haptics**: `PrismHaptics` engine with platform-adaptive feedback (UIKit/AppKit/WatchKit), `.prismHaptic()` modifier
- **Drag & Drop**: `prismDraggable()` / `prismDropTarget()` with themed indicators, `PrismReorderableList` with `onMove`
- **Keyboard Shortcuts**: `PrismShortcut` with 8 presets (save/undo/redo/delete/search/new/refresh/close), `PrismShortcutGroup`
- **Focus Management**: `PrismFocusStyle` (ring/highlight/scale/subtle), `PrismFocusSection` for tvOS/macOS, `.prismFocusable()`
- **Undo/Redo**: `.prismUndoable()` modifier with `UndoManager` integration, `PrismUndoButtons` toolbar component
- **Theme Persistence**: `PrismThemeStore` with `@AppStorage` persistence, runtime registration, animated switching
- **Component Browser**: `PrismComponentBrowser` dev tool — searchable catalog of all components with live toggles
- 35 new tests (367 total, 60 suites)

### Changed

- DocC catalog updated with Haptics, Drag & Drop, Keyboard Shortcuts, Focus, Undo/Redo, Theme Persistence, Component Browser sections

## [0.5.0] - 2026-04-28

### Added

- feat(ui): add widgets, live activities, charts, animations, token export, SwiftData integration

### Changed

- Merge pull request #9 from rafaelesantos/feature/advanced-integrations
- chore: resolve merge conflict in CHANGELOG.md

## [0.4.0] - 2026-04-28

### Added

- **Widget support**: PrismWidgetView (theme container), PrismWidgetGauge (circular progress), PrismWidgetStat (compact stat with trend)
- **Live Activities**: PrismLiveActivityCompact, PrismLiveActivityExpanded, PrismLiveActivityMinimal for Dynamic Island / Lock Screen
- **App Intents**: PrismIntentResult protocol, PrismIntentSnippet (themed snippet), PrismIntentConfirmation (success dialog)
- **Charts**: PrismBarChart, PrismLineChart (with area fill), PrismDonutChart — all themed with token styling
- **Animation presets**: 8 presets (bounce, wiggle, pulse, shake, fadeIn, slideUp, scaleIn, springIn), `.prismAnimate()` trigger, `.prismPulse()` continuous loop
- **SwiftData integration**: PrismModelList (generic list with empty state), PrismModelForm (themed Form)
- **Design token export**: PrismTokenExport with JSON and Figma DTCG format export for all 6 token types
- 42 new tests (332 total, 52 suites)

### Changed

- DocC catalog updated with Widgets, Live Activities, App Intents, Charts, Animations, SwiftData, Token Export sections
## [0.3.0] - 2026-04-28

### Added

- feat(ui): add theme variants, snapshot testing, DocC guides, README/CHANGELOG update

### Changed

- Merge pull request #7 from rafaelesantos/feature/polish-and-docs
- chore: resolve merge conflict in CHANGELOG.md

### Added

- **Theme variants**: DarkTheme (always-dark), HighContrastTheme (WCAG AAA), BrandTheme (configurable primary/secondary/accent)
- **Snapshot testing**: PrismSnapshotTest with render, renderAll, and pixel-by-pixel compare — light, dark, large text, high contrast configurations
- **DocC guides**: Getting Started, Using Tokens, Component Guide, Theming Guide — all with code examples
- **Localization**: All hardcoded UI strings extracted to PrismStrings with Bundle.module support
- **visionOS polish**: PrismDepthStack, prismDepth(), prismOrnament(), prismHover() with spatial layout support
- **Accessibility audit**: Systematic WCAG contrast, tap target, and theme completeness tests
- **Performance tooling**: prismLazy() for deferred rendering, prismBodyCount() for DEBUG profiling
- **Package.swift**: StrictConcurrency experimental feature enabled across all targets

### Changed

- README rewritten with updated test counts (290/44), component list, theme table, and usage examples
- DocC catalog updated with all new components, theme variants, guides section, and PrismSnapshotTest
- HighContrastTheme success/warning colors darkened to pass WCAG large text on white

## [0.2.0] - 2026-04-28

### Added

- feat(ui): add 16 new components — primitives, composites, forms, modifiers

### Changed

- Merge pull request #6 from rafaelesantos/feature/new-components

## [0.1.0] - 2026-04-28

### Added

- feat(ui): add Phases 7-10 — Composites, Forms, Lists, Polish
- feat(ui): add Phase 5 navigation + Phase 6 testing infrastructure
- feat(ui): add Phase 4 accessibility tools + update DocC
- feat(ui): add Phase 3 layout system — Stack, Grid, Section, Scaffold, Spacer
- feat(ui): add Phase 2 primitives — Button, Icon, Image, TextField, Card, Tag, Divider, LoadingState
- feat(ui): rewrite PrismUI design system from scratch — Phase 1

### Changed

- Merge pull request #5 from rafaelesantos/feature/design-system-v2
- docs(ui): update DocC with composites, forms, and lists sections
- docs(ui): update DocC catalog with navigation and testing sections

## [1.0.0] - 2026-04-27

### Added

- **PrismCodableTrainingData**: Generic adapter that converts any `Codable` struct into feature rows for tabular classification and regression training via Mirror-based reflection.
- **Provider-agnostic analytics**: `PrismAnalyticsProvider` protocol and `PrismAnalyticsEvent` with automatic tracking in `PrismButton`, `PrismTextField`, `PrismCarousel`, `PrismTabView`, and `PrismNavigationView`.
- **Runtime locale switching**: `PrismLocaleManager` observable class with persistence support and SwiftUI environment integration.
- **Remote auth token convenience**: `PrismIntelligenceClient.remote(endpoint:token:model:)` factory with automatic Bearer header.
- **Training configuration enhancements**: `featureColumns`, `earlyStoppingRounds`, `rowSubsample`, `columnSubsample` on `PrismTabularTrainingConfiguration`.
- **Explicit locale parameter**: `PrismTextIntelligence.trainingTextClassifier()` accepts optional `PrismLocale` instead of hardcoding current locale.
- **DocC documentation**: Full catalog for all 7 modules with articles for analytics, locale, codable training, local training, remote models, and platform availability.
- **GitHub Actions**: CI workflow with SPM caching, docs workflow with GitHub Pages deploy, release workflow with automatic changelog extraction.
- **Release workflow**: Automated GitHub Release creation from git tags with changelog body extraction.
- `PrismDivider`, `PrismMenu`, and `PrismAlert` UI components.
- `PrismUIPrefixAliases.swift` with Nova-prefixed typealiases and view modifier wrappers for brand customization.
- Cross-platform macOS adaptations for all PrismUI components.
- 154 tests across 31 suites covering all modules.

### Changed

- **README**: Rewritten with module table, architecture diagram, usage examples, badges, and development instructions.
- **CHANGELOG**: Restructured to Keep a Changelog format with semantic versioning.
- **.gitignore**: Hardened with patterns for credentials, secrets, API keys, IDE files, and OS artifacts.
- **CI workflow**: Pinned to `macos-15`, added SPM caching, dynamic Xcode selection.
- **Docs workflow**: Added SPM caching, dynamic Xcode selection.
- Package manifest updated for Swift 6.3 with strict concurrency.
- Documentation infrastructure consolidated to DocC (removed legacy Next.js docs-site and markdown docs).
- Scripts standardized with `set -euo pipefail` and `ROOT_DIR` pattern.

### Fixed

- `PrismVideoEntity.id` was a computed property generating a new UUID on every access; changed to stored `let`.
- `PrismStore.send(_:)` replaced force-unwrap with safe `guard let`.
- `PrismRouter.present(_:)` and `fullScreen(_:)` enforce mutual exclusivity.

## [0.0.5] - 2025-09-14

### Added

- Initial PrismIntelligence module with CreateML training, CoreML inference.
- PrismArchitecture store, reducer, and middleware primitives.
- PrismNetwork HTTP client and socket transport.

## [0.0.4] - 2025-09-13

### Added

- Initial PrismFoundation, PrismUI, and PrismVideo modules.
- Basic Swift Package Manager setup.
