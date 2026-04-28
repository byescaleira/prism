# Using Design Tokens

Build consistent UIs with the PrismUI token system.

## Overview

Design tokens are the atomic values that drive every visual decision in PrismUI.
Instead of hardcoded colors, sizes, and durations, you reference semantic tokens
that the theme resolves at runtime.

### Color Tokens

``ColorToken`` provides 28 semantic roles organized by purpose:

```swift
// Brand
theme.color(.brand)         // Primary brand color
theme.color(.brandVariant)  // Secondary brand variant

// Surfaces
theme.color(.surface)           // Card/container background
theme.color(.surfaceElevated)   // Elevated content background

// Content
theme.color(.onBackground)      // Primary text on background
theme.color(.onSurface)         // Primary text on surface

// Feedback
theme.color(.success)  // Green — positive actions
theme.color(.warning)  // Orange — caution
theme.color(.error)    // Red — errors
theme.color(.info)     // Blue — informational
```

### Typography Tokens

``TypographyToken`` maps to Apple's text styles with semantic weight defaults:

```swift
Text("Headline")
    .prismFont(.title)          // Large Title style
    .prismFont(.headline)       // Bold headline
    .prismFont(.body)           // Regular body text
    .prismFont(.caption)        // Small captions
```

### Spacing Tokens

``SpacingToken`` follows a 4pt grid system:

```swift
.prismPadding(.xs)   //  4pt
.prismPadding(.sm)   //  8pt
.prismPadding(.md)   // 12pt
.prismPadding(.lg)   // 16pt
.prismPadding(.xl)   // 24pt
.prismPadding(.xxl)  // 32pt
```

### Radius Tokens

``RadiusToken`` uses continuous (squircle) corners matching Apple's design:

```swift
.prismRadius(.sm)   //  8pt squircle
.prismRadius(.md)   // 12pt squircle
.prismRadius(.lg)   // 16pt squircle
.prismRadius(.xl)   // 24pt squircle
```

### Elevation Tokens

``ElevationToken`` creates visual depth with shadows:

```swift
.prismElevation(.flat)     // No shadow
.prismElevation(.low)      // Subtle lift
.prismElevation(.medium)   // Card-level
.prismElevation(.high)     // Floating elements
.prismElevation(.overlay)  // Modal/sheet level
```

### Motion Tokens

``MotionToken`` provides duration-appropriate animations that respect Reduce Motion:

```swift
.prismAnimation(.fast, value: isExpanded)    // 150ms quick interactions
.prismAnimation(.normal, value: isExpanded)  // 250ms standard transitions
.prismAnimation(.slow, value: isExpanded)    // 350ms emphasis
```

## Topics

### Token Types

- ``ColorToken``
- ``TypographyToken``
- ``SpacingToken``
- ``RadiusToken``
- ``ElevationToken``
- ``MotionToken``
