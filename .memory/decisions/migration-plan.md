---
name: migration-plan
description: Plan to align Prism with template quality standards (adapted for library, not app).
type: project
---

## Phase 1: Foundation (Critical)

- [ ] Fix 5 build warnings in PrismServer (casting issues in Tracing/Versioning)
- [ ] Fix 1 flaky test (PrismScheduler "Schedule after delay")
- [ ] Remove 4 print() statements → use PrismLogger
- [ ] Fix 1 force unwrap
- [ ] Replace `{{PROJECT_NAME}}` placeholders in .memory templates

## Phase 2: Code Quality

- [ ] Split files >400 lines (PrismIntelligenceClient 649, PrismCameraClient 544, etc.)
- [ ] Audit raw `Task {}` usage in PrismCapabilities → structured concurrency where possible
- [ ] Review non-final classes for Sendable compliance
- [ ] Ensure all public types are `Sendable` where appropriate

## Phase 3: Documentation

- [ ] Add `///` doc comments to public APIs (~4150 undocumented)
- [ ] Replace `{{TEMPLATE_VAR}}` placeholders in Mintlify docs
- [ ] Update README to reflect current v4.4.0 state
- [ ] Validate all 92 Mintlify pages build correctly

## Phase 4: Testing

- [ ] Identify source files without corresponding tests
- [ ] Priority: PrismServer (55 tests for ~70 files — good coverage)
- [ ] PrismIntelligence (2 test files for ~20 sources — low coverage)
- [ ] PrismVideo (1 test file for 5 sources — low coverage)
- [ ] PrismNetwork (6 test files — verify coverage)

## Phase 5: Polish

- [ ] Localization audit (defaultLocalization "pt" — verify all modules)
- [ ] Accessibility audit for PrismUI components
- [ ] CHANGELOG.md sync with current v4.4.0
- [ ] .swift-format configuration alignment
