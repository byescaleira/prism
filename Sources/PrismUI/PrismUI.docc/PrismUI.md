# ``PrismUI``

Apple-first design system with semantic tokens, adaptive theming, and accessibility built in.

## Overview

PrismUI provides a token-driven design foundation for building Apple-platform apps.
Instead of wrapping every SwiftUI view, it enhances native views through semantic
modifiers and a themeable token system. Complex components like buttons and text fields
earn their wrapper by adding behavior beyond what raw SwiftUI provides.

### Design Principles

- **Apple-native first** — use SwiftUI primitives, wrap only when adding value
- **Token-driven** — change the theme, change every component
- **Accessible by default** — every component respects accessibility settings
- **Platform-adaptive** — same API, platform-appropriate rendering
- **Liquid Glass ready** — iOS 26 glass effects with graceful fallbacks

## Topics

### Guides

- <doc:GettingStarted>
- <doc:UsingTokens>
- <doc:ComponentGuide>
- <doc:ThemingGuide>

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
- ``DarkTheme``
- ``HighContrastTheme``
- ``BrandTheme``

### Primitives

- ``PrismButton``
- ``PrismIcon``
- ``PrismAsyncImage``
- ``PrismTextField``
- ``PrismCard``
- ``PrismTag``
- ``PrismChip``
- ``PrismDivider``
- ``PrismLoadingState``
- ``PrismProgressBar``
- ``PrismAvatar``

### Composites

- ``PrismAlert``
- ``PrismBanner``
- ``PrismCarousel``
- ``PrismSearchBar``
- ``PrismToolbar``
- ``PrismToast``
- ``PrismMenu``
- ``PrismBottomSheet``
- ``PrismTooltip``
- ``PrismEmptyState``
- ``PrismCountdownTimer``

### Forms

- ``PrismToggle``
- ``PrismPicker``
- ``PrismSlider``
- ``PrismSecureField``
- ``PrismDatePicker``
- ``PrismSegmentedControl``
- ``PrismStepper``
- ``PrismTextArea``
- ``PrismRating``
- ``PrismPinField``
- ``PrismColorWell``

### Lists

- ``PrismRow``
- ``PrismDisclosureRow``
- ``PrismList``
- ``PrismBadge``
- ``PrismSwipeAction``

### Layout

- ``PrismAdaptiveStack``
- ``PrismGrid``
- ``PrismSection``
- ``PrismScaffold``
- ``PrismSpacer``

### Navigation

- ``PrismNavigationView``
- ``PrismTabView``

### Accessibility

- ``PrismAccessibilityAudit``
- ``PrismReduceMotion``
- ``PrismDynamicTypePreview``

### Widgets

- ``PrismWidgetView``
- ``PrismWidgetGauge``
- ``PrismWidgetStat``

### Live Activities

- ``PrismLiveActivityCompact``
- ``PrismLiveActivityExpanded``
- ``PrismLiveActivityMinimal``

### App Intents

- ``PrismIntentResult``
- ``PrismIntentSnippet``
- ``PrismIntentConfirmation``

### Charts

- ``PrismBarChart``
- ``PrismLineChart``
- ``PrismDonutChart``

### Animations

- ``PrismAnimationPreset``

### SwiftData Integration

- ``PrismModelList``
- ``PrismModelForm``

### Design Token Export

- ``PrismTokenExport``

### Testing

- ``PrismPreviewCatalog``
- ``PrismThemeTest``
- ``PrismAccessibilityTest``
- ``PrismSnapshotTest``
