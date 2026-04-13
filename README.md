# Ryze

Ryze is a modern Swift package for building Apple apps with a shared foundation layer, networking primitives, architecture building blocks, adaptive UI components, media helpers, and intelligence experiments.

## Vision

- Ship one professional core library that can support multiple Apple apps.
- Prefer modern Swift, modern SDKs, and explicit module boundaries.
- Keep the design system adaptive across iOS, macOS, Mac Catalyst, tvOS, and watchOS.
- Make quality gates first-class so the package can scale commercially.

## Requirements

- Swift 6.3
- Xcode 26.4 or newer
- Apple platform minimums:
  - iOS 26
  - macOS 26
  - Mac Catalyst 26
  - tvOS 26
  - watchOS 26

The current deployment targets intentionally follow the latest SDK generation because `RyzeUI` already adopts newer SwiftUI capabilities such as `glassEffect`.

## Public Products

- `Ryze`: umbrella module that re-exports the core Ryze modules for app-level convenience.
- `RyzeFoundation`: shared defaults, resources, formatting, logging, locale helpers, and lightweight entities.
- `RyzeNetwork`: HTTP/socket infrastructure, endpoints, caching, logging, and FIX transport support.
- `RyzeArchitecture`: router, store, reducer, and middleware primitives.
- `RyzeUI`: theme system, atoms, molecules, modifiers, accessibility helpers, and app-facing SwiftUI components.
- `RyzeVideo`: video download helpers and media-related entities.
- `RyzeIntelligence`: local training and prediction with CreateML/CoreML plus Apple Intelligence and remote language model providers.

The recommended entry point for app-side consumption is `RyzeIntelligenceClient`, which offers one simple facade across local, Apple Intelligence, and remote model backends.

## Adaptive UI Strategy

RyzeUI is being structured as a latest-SDK-first design system:

- Shared tokens for color, spacing, radius, and size.
- SwiftUI-first APIs that can adapt to touch, pointer, focus, and remote-based interaction models.
- Platform-aware wrappers for UIKit/AppKit differences when behavior diverges.
- Explicit compatibility decisions instead of pretending every component behaves the same on every Apple OS.

The next evolution of `RyzeUI` should continue in this direction: one visual language, native interaction patterns per platform.

## Quality Gates

The repository now has a standard quality workflow:

- `swift format` as the official formatter and style linter.
- Explicit target dependency import checks in `swift build` and `swift test`.
- Automated validation scripts in `scripts/`.
- GitHub Actions CI for lint, build, and test.
- Changelog, contribution, and security documentation for maintainability.

## Installation

Add the package with your repository URL:

```swift
dependencies: [
    .package(url: "<repository-url>", branch: "main")
]
```

Then depend on the product you need:

```swift
.product(name: "Ryze", package: "ryze")
```

You can import the umbrella module:

```swift
import Ryze
```

Or only the focused modules you want:

```swift
import RyzeFoundation
import RyzeUI
```

## Development

Ryze ships with a small command surface for day-to-day development:

```bash
make format
make lint
make build
make test
make validate
```

Those commands wrap the scripts in `scripts/` so the same checks run locally and in CI.

## Commercial Readiness Checklist

- Modular public products
- Modern Swift toolchain baseline
- Automated format/lint/build/test workflow
- MIT license
- Changelog and contribution workflow
- Security reporting guidance

Still recommended before calling the package production-ready:

- Expand tests across `RyzeNetwork`, `RyzeArchitecture`, and `RyzeUI`
- Validate the Apple platform matrix in dedicated Xcode builds outside this sandboxed environment
- Tighten the public API surface further and document stability guarantees

## License

Ryze is available under the MIT license. See [LICENSE](LICENSE).
