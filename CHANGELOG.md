# Changelog

All notable changes to Prism will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
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
