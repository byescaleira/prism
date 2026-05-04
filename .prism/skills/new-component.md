# Skill: Add PrismUI Component

## Steps

### 1. Create Component File
```
Sources/PrismUI/Components/Category/PrismComponentName.swift
```

### 2. Implementation Pattern
```swift
import SwiftUI
import PrismFoundation

/// Brief description of component purpose.
public struct PrismComponentName: View {
    @Environment(\.prismTheme) private var theme

    // Required props
    private let title: String

    // Optional config with defaults
    private let style: Style
    private let size: PrismSize

    public init(
        title: String,
        style: Style = .primary,
        size: PrismSize = .medium
    ) {
        self.title = title
        self.style = style
        self.size = size
    }

    public var body: some View {
        // Use tokens: theme.color, theme.typography, theme.spacing, etc.
    }
}

// MARK: - Style

extension PrismComponentName {
    public enum Style: Sendable {
        case primary, secondary, ghost
    }
}
```

### 3. Requirements
- [ ] Uses design tokens (no hardcoded colors/sizes)
- [ ] Works across all 4 themes
- [ ] `Sendable` conformance
- [ ] Keyboard navigable
- [ ] `accessibilityLabel` / `accessibilityHint`
- [ ] Preview with multiple variants
- [ ] DocC documentation

### 4. Testing
```swift
// Tests/PrismUITests/ComponentNameTests.swift
// Test: initialization, style variants, accessibility identifiers
```

### 5. Preview
```swift
#Preview("PrismComponentName") {
    VStack(spacing: 16) {
        PrismComponentName(title: "Primary", style: .primary)
        PrismComponentName(title: "Secondary", style: .secondary)
        PrismComponentName(title: "Ghost", style: .ghost)
    }
    .padding()
}
```
