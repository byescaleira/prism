# Theming Guide

Customize PrismUI's appearance with built-in and custom themes.

## Overview

PrismUI ships with four themes and supports fully custom themes via the
``PrismTheme`` protocol. Every component reads the theme from the SwiftUI
environment, so switching themes changes the entire UI at once.

### Built-in Themes

| Theme | Purpose |
|-------|---------|
| ``DefaultTheme`` | Apple HIG system colors, adapts to light/dark mode |
| ``DarkTheme`` | Always-dark, ignores system appearance |
| ``HighContrastTheme`` | Maximized contrast for accessibility |
| ``BrandTheme`` | Configurable primary/secondary/accent colors |

### Applying a Theme

```swift
// App-wide
ContentView()
    .prismTheme(DefaultTheme())

// Per-section override
SettingsView()
    .prismTheme(DarkTheme())
```

### Using BrandTheme

``BrandTheme`` lets you inject your brand colors without implementing the full protocol:

```swift
let myTheme = BrandTheme(
    primary: Color("BrandPrimary"),    // .brand token
    secondary: Color("BrandSecondary"), // .brandVariant + .info tokens
    accent: Color("BrandAccent")        // .interactive tokens
)

ContentView()
    .prismTheme(myTheme)
```

### Custom Themes

Implement ``PrismTheme`` for full control. You can delegate to ``DefaultTheme``
for tokens you don't need to customize:

```swift
struct OceanTheme: PrismTheme {
    private let fallback = DefaultTheme()

    func color(_ token: ColorToken) -> Color {
        switch token {
        case .brand: Color(red: 0.0, green: 0.3, blue: 0.6)
        case .interactive: Color(red: 0.0, green: 0.5, blue: 0.8)
        case .success: .teal
        default: fallback.color(token)
        }
    }
}
```

### Theme Validation

Use ``PrismThemeTest`` to verify custom themes in your test suite:

```swift
@Test func oceanThemeIsComplete() {
    let issues = PrismThemeTest.validateAllColors(OceanTheme())
    #expect(issues.isEmpty)
}

@Test func feedbackColorsAreDistinct() {
    #expect(PrismThemeTest.validateFeedbackColorsDistinct(OceanTheme()))
}
```

### Visual Regression Testing

Use ``PrismSnapshotTest`` to catch unintended visual changes:

```swift
@Test func buttonSnapshotConsistency() {
    let snapshots = PrismSnapshotTest.renderAll {
        PrismButton("Test") {}
    }
    #expect(snapshots.count == 4) // light, dark, largeText, highContrast
}
```

## Topics

### Theme Types

- ``PrismTheme``
- ``DefaultTheme``
- ``DarkTheme``
- ``HighContrastTheme``
- ``BrandTheme``

### Testing

- ``PrismThemeTest``
- ``PrismSnapshotTest``
