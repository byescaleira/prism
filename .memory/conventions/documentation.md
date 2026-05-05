---
name: documentation
description: Documentation conventions — Mintlify standard, page structure, component usage, anti-Apple patterns.
type: project
---

## Platform: Mintlify

All external documentation lives in `docs/` directory. Configured via `docs.json`.

## Documentation Style: Stripe/Vercel (NOT Apple)

### Core Principles
1. **Minimize time-to-first-success** — every page gets reader from "want to do X" to "did X" fastest path
2. **Task-oriented** — organize by developer goals, not API surface
3. **Code-first** — every concept has copy-paste-ready examples (< 20 lines)
4. **Progressive disclosure** — summary first, details in Tabs/Accordions
5. **Never "No overview available"** — every type has WHY, WHEN, and HOW

### What Apple Does Wrong (Don't Repeat)
- Empty doc pages with no examples → Always provide examples
- API-surface organization → Organize by task/goal
- No error documentation → Every error type has solutions
- Separate docs from engineering → Docs updated in same PR as code
- No cross-linking → Aggressively link related concepts
- No task-oriented guides → Every feature has a "How do I..." guide

## File Structure

```
docs/
├── docs.json              # Mintlify config, navigation, theme (#FF5C00)
├── index.mdx              # Landing page with CardGroups
├── quickstart.mdx         # 5-minute first success
├── installation.mdx       # Requirements, setup, troubleshooting
├── changelog.mdx          # Keep a Changelog format
├── favicon.svg            # Brand-colored SVG
├── logo/                  # Light/dark SVG logos
├── images/                # Screenshots, diagrams
├── guides/                # Task-oriented walkthroughs
│   ├── architecture.mdx
│   ├── modules.mdx
│   ├── patterns.mdx
│   ├── dependency-rules.mdx
│   ├── clean-code.mdx
│   ├── concurrency.mdx
│   ├── testing.mdx
│   ├── performance.mdx
│   ├── design-system.mdx
│   ├── accessibility.mdx
│   ├── localization.mdx
│   ├── animations.mdx
│   ├── logging.mdx
│   ├── analytics.mdx
│   ├── error-handling.mdx
│   ├── di-container.mdx
│   ├── gitflow.mdx
│   ├── ci-cd.mdx
│   ├── releases.mdx
│   └── contributing.mdx
└── api-reference/         # Type-safe API docs with examples
    ├── domain-entities.mdx
    ├── domain-usecases.mdx
    ├── domain-repositories.mdx
    ├── data-sources.mdx
    ├── data-network.mdx
    ├── viewmodels.mdx
    ├── coordinators.mdx
    ├── logger.mdx
    └── analytics.mdx
```

## Mintlify Components to Use

| Component | When |
|-----------|------|
| `<CardGroup>` | Navigation hubs, feature showcases |
| `<Tabs>` | Multiple implementations (per layer, per approach) |
| `<Steps>` | Sequential workflows, setup guides |
| `<Accordion>` | FAQ, troubleshooting, verbose details |
| `<Note>` / `<Warning>` / `<Tip>` | Callouts for important info |
| `<CodeGroup>` | Multi-language code blocks |
| Mermaid diagrams | Architecture, data flow, state machines |

## Page Template

```mdx
---
title: "Page Title"
description: "One-line description for search and SEO"
icon: "icon-name"
---

<Info>
  **What you'll learn:** Brief promise of value.
</Info>

## Main Content

[Concept explanation with code example]

<Tabs>
  <Tab title="Approach A">
    ```swift
    // Code example
    ```
  </Tab>
  <Tab title="Approach B">
    ```swift
    // Alternative
    ```
  </Tab>
</Tabs>

## Next

<CardGroup cols={2}>
  <Card title="Related Topic" icon="icon" href="/path">
    Why reader should go here next
  </Card>
</CardGroup>
```

## Rules

- Update docs in SAME PR as code changes
- Every new public API → add to relevant api-reference page
- Every new feature → add/update relevant guide page
- Brand color `#FF5C00` in all diagrams and visual elements
- All placeholders use `{{TEMPLATE_VAR}}` pattern
- Test docs build locally before pushing

**Why:** Documentation is a product feature, not an afterthought. Bad docs = unusable code. Stripe proved this with 25% engineer time on docs.

**How to apply:** When implementing any feature, ask "which docs page does this affect?" Update it in the same commit. Never merge code without corresponding doc updates.
