# Component Guide

Build interfaces with PrismUI's primitive, composite, form, list, and layout components.

## Overview

PrismUI components are organized in layers of increasing complexity:
**Primitives** → **Forms** → **Composites** → **Lists** → **Layout** → **Navigation**.

### Buttons

``PrismButton`` supports five variants with async actions, loading state, and haptics:

```swift
PrismButton("Primary", variant: .filled) { await save() }
PrismButton("Secondary", variant: .tinted) { await save() }
PrismButton("Outline", variant: .bordered) { await save() }
PrismButton("Plain", variant: .plain) { await save() }
PrismButton("Glass", variant: .glass) { await save() }
```

### Text Input

```swift
// Single-line with validation
PrismTextField("Email", text: $email, validation: .pattern(
    "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}",
    "Enter a valid email"
))

// Multi-line with character count
PrismTextArea("Bio", text: $bio, maxCharacters: 300)

// Secure input with visibility toggle
PrismSecureField("Password", text: $password)

// PIN/OTP entry
PrismPinField(code: $otp, length: 6)
```

### Avatars

```swift
PrismAvatar(initials: "JD", size: .large, status: .online)
PrismAvatar(url: user.avatarURL, size: .medium)
PrismAvatar(image: Image("profile"), status: .busy)
```

### Tags and Chips

```swift
// Static label
PrismTag("New", style: .success, icon: "sparkles")

// Interactive selection
PrismChip("Swift", isSelected: $isSwift, icon: "swift")
```

### Cards

```swift
PrismCard {
    VStack(alignment: .leading, spacing: SpacingToken.sm.rawValue) {
        Text("Card Title").prismFont(.headline)
        Text("Description").prismFont(.body).prismColor(.onSurfaceSecondary)
    }
    .prismPadding(.lg)
}
```

### Progress

```swift
// Determinate
PrismProgressBar(value: 0.65, label: "Uploading")

// Indeterminate
PrismProgressBar(label: "Loading")
```

### Forms

```swift
Form {
    PrismToggle("Notifications", isOn: $notifications, icon: "bell.fill")
    PrismSlider("Volume", value: $volume, in: 0...100)
    PrismStepper("Quantity", value: $qty, in: 1...99, icon: "number")
    PrismPicker("Theme", selection: $theme, icon: "paintbrush") {
        Text("Light").tag(0)
        Text("Dark").tag(1)
    }
    PrismDatePicker("Birthday", selection: $date, icon: "calendar")
    PrismSegmentedControl("View", selection: $viewMode) {
        Text("List").tag(0)
        Text("Grid").tag(1)
    }
    PrismRating(value: $rating, allowHalf: true)
    PrismColorWell("Accent", selection: $color)
}
```

### Lists

```swift
PrismList(items, empty: .empty(title: "No items", message: nil, icon: "tray")) { item in
    PrismRow(item.title, subtitle: item.subtitle, icon: item.icon)
        .prismSwipeActions(trailing: [.delete { delete(item) }])
}
```

### Feedback

```swift
// Toast notification
.prismToast(isPresented: $showToast, "Saved!", icon: "checkmark", style: .success)

// Banner
PrismBanner("Update available", style: .info, onDismiss: { /* ... */ })

// Empty state
PrismEmptyState(icon: "magnifyingglass", title: "No results", message: "Try a different search") {
    PrismButton("Clear filters") { clearFilters() }
}
```

### Navigation

```swift
PrismNavigationView(router: router) { route in
    switch route {
    case .home: HomeView()
    case .detail(let id): DetailView(id: id)
    }
}

PrismTabView(selection: $tab) {
    HomeView().prismTab("Home", icon: "house", tag: 0)
    SearchView().prismTab("Search", icon: "magnifyingglass", tag: 1)
}
```

## Topics

### Primitives

- ``PrismButton``
- ``PrismTextField``
- ``PrismAvatar``
- ``PrismProgressBar``
- ``PrismChip``
- ``PrismTag``
- ``PrismCard``
- ``PrismIcon``

### Composites

- ``PrismToast``
- ``PrismBanner``
- ``PrismMenu``
- ``PrismEmptyState``
- ``PrismBottomSheet``
- ``PrismSearchBar``
