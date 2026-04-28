# ``PrismUI``

Apple-first design system with semantic tokens, adaptive theming, and accessibility built in.

## Overview

PrismUI provides a token-driven design foundation for building Apple-platform apps.
Instead of wrapping every SwiftUI view, it enhances native views through semantic
modifiers and a themeable token system.

### Design Principles

- **Apple-native first** — use SwiftUI primitives, wrap only when adding value
- **Token-driven** — change the theme, change every component
- **Accessible by default** — every modifier respects accessibility settings
- **Platform-adaptive** — same API, platform-appropriate rendering

## Topics

### Tokens

- ``ColorToken``
- ``TypographyToken``
- ``SpacingToken``
- ``RadiusToken``
- ``MotionToken``
- ``ElevationToken``

### Theme

- ``PrismTheme``
- ``DefaultTheme``
