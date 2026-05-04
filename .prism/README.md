# .prism — Project Intelligence

Session-persistent rules, trackers, and patterns for Prism development.
Every Claude session MUST read this directory before starting work.

## Structure

```
.prism/
├── README.md              ← this file
├── profile.md             ← project identity & philosophy
├── rules/
│   ├── swift.md           ← Swift code rules
│   ├── git.md             ← Git flow & commit rules
│   ├── testing.md         ← test standards
│   ├── naming.md          ← naming conventions
│   ├── architecture.md    ← module boundaries & deps
│   ├── review.md          ← PR review checklist
│   └── workflow.md        ← phase execution protocol (PLAN→EXECUTE→TEST→DOC→MERGE→RELEASE)
├── skills/
│   ├── new-module.md      ← how to create a new Prism module
│   ├── new-component.md   ← how to add a PrismUI component
│   └── new-middleware.md  ← how to add PrismServer middleware
├── trackers/
│   ├── roadmap.md         ← phase tracker with status
│   ├── tech-debt.md       ← known debt items
│   └── changelog-next.md  ← unreleased changes staging
├── templates/
│   ├── store.swift        ← PrismArchitecture store template
│   ├── endpoint.swift     ← PrismNetwork endpoint template
│   └── middleware.swift   ← PrismServer middleware template
└── patterns/
    ├── error-handling.md  ← error pattern reference
    ├── concurrency.md     ← Swift 6 concurrency patterns
    └── di.md              ← dependency injection patterns
```
