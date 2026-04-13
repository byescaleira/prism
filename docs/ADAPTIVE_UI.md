# Adaptive UI Guidelines

PrismUI should feel consistent across Apple platforms without pretending every platform behaves the same.

## Principles

- One design language, native interaction patterns
- Shared tokens for color, spacing, radius, and size
- Platform-aware wrappers when UIKit and AppKit diverge
- Respect focus, pointer, keyboard, touch, remote, and watch input models

## Implementation Direction

- Use SwiftUI first
- Add platform-specific adapters only when behavior or APIs truly diverge
- Prefer environment-driven theming and platform capability checks
- Keep component APIs stable while adapting internals per OS
- Resolve adaptive behavior through `PrismPlatformContext`
- Prefer `PrismAdaptiveScreen` for full-screen composition
- Prefer `PrismAdaptiveStack` for content/action groups that need to reflow between platforms
- Prefer `PrismScaffold` when a screen needs shared hierarchy, title, subtitle, and actions
- Use `PrismNavigationView` with an optional sidebar to scale from stack to split navigation
- Keep `PrismTabView` as the single tab API and let the component adapt its chrome per platform

## Platform Notes

- iOS and Mac Catalyst should prioritize touch plus pointer-friendly ergonomics
- macOS should feel native with keyboard, menu, and window behavior
- tvOS should optimize for focus and remote navigation
- watchOS should keep density, motion, and interaction lightweight
- visionOS should favor centered canvases and spacious readable layouts

## Suggested Composition

```swift
PrismNavigationView(
    router: router,
    sidebar: {
        SidebarView()
    },
    destination: { route in
        RouteView(route: route)
    },
    content: {
        PrismScaffold(
            "Workspace",
            subtitle: "Um único código com comportamento adaptativo"
        ) {
            PrismAdaptiveStack(style: .actions) {
                PrimaryAction()
                SecondaryAction()
            }
        } content: {
            MainContent()
        }
    }
)
```

## Review Checklist

- Does the component degrade gracefully on every supported Apple OS?
- Does it respect the correct interaction model for each platform?
- Is the design token-driven instead of hardcoded for one screen class?
- Is the public API platform-agnostic where possible?
- Can a feature screen be composed without scattering `#if os(...)` through product code?
