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
- <doc:MigrationGuide>
- <doc:PluginGuide>
- <doc:ArchitectureGuide>

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

### Component Variants V2

- ``PrismIconButton``
- ``PrismExpandableCard``
- ``PrismSkeletonView``
- ``PrismSearchSuggestions``
- ``PrismButtonGroup``
- ``PrismSegmentedButtons``

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

### Accessibility V3

- ``PrismColorBlindnessSimulator``
- ``PrismColorBlindnessType``
- ``PrismFocusOrderValidator``
- ``PrismFocusOrderItem``
- ``PrismVoiceControlGroup``
- ``PrismContrastChecker``
- ``PrismContrastLevel``
- ``PrismAccessibilityAnnouncer``
- ``PrismAnnouncementPriority``

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
- ``PrismSpringConfig``
- ``PrismKeyframeView``
- ``PrismDraggable``
- ``PrismPinchable``
- ``PrismRotatable``
- ``PrismSharedElement``
- ``PrismHeroTransition``
- ``PrismGravityDrop``
- ``PrismMomentumScroll``
- ``PrismFloat``
- ``PrismParticleEffect``
- ``PrismStaggeredList``
- ``PrismStaggerStyle``

### SwiftData Integration

- ``PrismModelList``
- ``PrismModelForm``

### Design Token Export

- ``PrismTokenExport``

### Haptics

- ``PrismHaptics``
- ``PrismHapticType``
- ``PrismImpactWeight``
- ``PrismNotificationStyle``

### Drag & Drop

- ``PrismReorderableList``

### Keyboard Shortcuts

- ``PrismShortcut``
- ``PrismShortcutGroup``

### Focus

- ``PrismFocusStyle``
- ``PrismFocusSection``

### Undo/Redo

- ``PrismUndoButtons``

### Theme Persistence

- ``PrismThemeStore``

### Glass Effects

- ``PrismGlassContainer``

### Mesh Gradients

- ``PrismMeshGradient``

### Navigation Split View

- ``PrismSplitView``
- ``PrismThreeColumnView``

### Responsive Layout

- ``PrismResponsiveSize``
- ``PrismScaledView``

### Sharing

- ``PrismShareButton``

### Empty States

- ``PrismContentUnavailable``
- ``PrismSearchUnavailable``

### Map Integration

- ``PrismMap``
- ``PrismMapMarker``
- ``PrismMapAnnotation``

### Photo Picker

- ``PrismPhotoPicker``
- ``PrismMultiPhotoPicker``

### Document Support

- ``PrismDocumentView``

### Flexible Headers

- ``PrismFlexibleHeader``
- ``PrismParallaxHeader``

### Gradients & Materials

- ``PrismLinearGradient``
- ``PrismRadialGradient``
- ``PrismAngularGradient``
- ``PrismMaterial``

### Toolbar

- ``PrismToolbarPlacement``
- ``PrismToolbarButton``
- ``PrismToolbarMenu``

### Form Validation

- ``PrismValidationRule``
- ``PrismValidatedField``

### Preview Tools

- ``PrismDevicePreview``
- ``PrismLocalePreview``
- ``PrismPreviews``

### Onboarding

- ``PrismOnboarding``

### Redacted Styles

- ``PrismRedactedStyle``

### Notification Banner

- ``PrismNotificationBanner``

### Context Menu

### Content Transition

- ``PrismContentTransition``

### Sensory Feedback

- ``PrismSensoryFeedback``

### Gauge

- ``PrismGauge``

### GroupBox

- ``PrismGroupBox``

### Label Style

- ``PrismLabelStyle``

### Image Resource

- ``PrismImageResource``

### Table (macOS)

- ``PrismTable``

### Paste Button

- ``PrismPasteButton``

### Timeline View

- ``PrismTimelineSchedule``
- ``PrismTimelineView``

### TipKit Integration

- ``PrismTipView``

### Settings

- ``PrismSettingsView``
- ``PrismSettingsSection``

### Accessibility Modifiers

### Style Protocols

- ``PrismCustomButtonStyle``
- ``PrismCustomCardStyle``
- ``PrismElevatedCardStyle``
- ``PrismOutlinedCardStyle``
- ``PrismFlatCardStyle``

### Navigation Path

- ``PrismNavigationPath``

### Observable Helpers

- ``PrismViewModel``

### Preview Blocks

- ``PrismPreviewBlocks``

### Performance

- ``PrismPerformanceBenchmark``
- ``PrismMemoryTracker``

### watchOS Complications

- ``PrismComplicationGauge``
- ``PrismComplicationText``

### visionOS Volumes

- ``PrismVolumeView``
- ``PrismOrnamentView``

### macOS Menu Bar

- ``PrismMenuBarContent``
- ``PrismMenuBarButton``

### Theme Editor

- ``PrismThemeEditor``

### Auto Theme Generation

- ``PrismAutoTheme``

### Figma Sync

- ``PrismFigmaSync``

### Storybook

- ``PrismStorybook``

### Plugin Architecture

- ``PrismPlugin``
- ``PrismPluginRegistry``

### Testing

- ``PrismPreviewCatalog``
- ``PrismThemeTest``
- ``PrismAccessibilityTest``
- ``PrismSnapshotTest``
- ``PrismComponentBrowser``
