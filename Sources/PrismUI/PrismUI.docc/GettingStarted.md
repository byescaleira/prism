# Getting Started with PrismUI

Set up PrismUI in your app and start using themed components.

## Overview

PrismUI is a token-driven design system for Apple platforms. Add it to your
project, inject a theme, and every component adapts automatically.

### Installation

Add Prism to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/rafaelesantos/prism.git", from: "1.0.0")
]
```

Import just the design system:

```swift
import PrismUI
```

### Inject a Theme

Wrap your root view with a theme. ``DefaultTheme`` follows Apple HIG system colors:

```swift
@main struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .prismTheme(DefaultTheme())
        }
    }
}
```

### Use Components

PrismUI components read the theme from the environment automatically:

```swift
VStack(spacing: SpacingToken.lg.rawValue) {
    PrismButton("Sign In", variant: .filled) {
        await signIn()
    }

    PrismTextField("Email", text: $email, validation: .pattern(
        "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}",
        "Enter a valid email"
    ))

    PrismToggle("Remember me", isOn: $remember)
}
.prismPadding(.lg)
```

### Apply Modifiers

Use semantic modifiers instead of raw SwiftUI values:

```swift
Text("Welcome")
    .prismFont(.title)
    .prismColor(.onBackground)
    .prismPadding(.md)
    .prismSurface(.surfaceSecondary, radius: .lg)
    .prismElevation(.low)
```

### Custom Themes

Implement ``PrismTheme`` to create brand-specific themes:

```swift
struct MyBrandTheme: PrismTheme {
    func color(_ token: ColorToken) -> Color {
        switch token {
        case .brand: Color("BrandPrimary")
        case .interactive: Color("BrandAccent")
        default: DefaultTheme().color(token)
        }
    }
}
```

Or use the built-in ``BrandTheme`` for quick customization:

```swift
let theme = BrandTheme(
    primary: .indigo,
    secondary: .mint,
    accent: .orange
)
```

## Topics

### Essentials

- ``PrismTheme``
- ``DefaultTheme``
- ``BrandTheme``
- ``DarkTheme``
- ``HighContrastTheme``
