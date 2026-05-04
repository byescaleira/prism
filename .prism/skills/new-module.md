# Skill: Create New Prism Module

## Steps

### 1. Package.swift
```swift
// Add product
.library(name: "PrismXxx", targets: ["PrismXxx"]),

// Add target
.target(
    name: "PrismXxx",
    dependencies: ["PrismFoundation"],  // minimal deps
    swiftSettings: swiftSettings
),

// Add test target
.testTarget(
    name: "PrismXxxTests",
    dependencies: ["PrismXxx"],
),
```

### 2. Directory Structure
```
Sources/PrismXxx/
├── Core/
│   └── PrismXxx.swift          ← main entry type
├── Feature/
│   └── PrismFeature.swift
└── Resource/
    └── PrismXxxString.xcstrings  ← if localized

Tests/PrismXxxTests/
├── TestSupport.swift
└── PrismXxxTests.swift
```

### 3. Umbrella Re-export (if client module)
```swift
// Sources/Prism/Prism.swift — add:
@_exported import PrismXxx
```

### 4. Documentation
- DocC catalog on all public APIs
- Mintlify section in `docs/mint.json`
- At least 3 tutorial pages

### 5. CI
- Verify module builds: `swift build --target PrismXxx`
- Verify tests pass: `swift test --filter PrismXxxTests`
- Add to DocC workflow if client module

### 6. Validation
- [ ] Compiles independently
- [ ] Tests pass
- [ ] No circular deps
- [ ] DocC generates
- [ ] README updated with module description
