# Changelog

All notable changes to Prism will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
