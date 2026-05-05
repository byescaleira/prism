# Project Memory Index

Persistent knowledge for Claude Code across sessions. NOT in .gitignore — shared with team.

## Architecture
- [Clean Architecture](architecture/clean-architecture.md) — Layer rules, dependency direction, module map
- [Design Patterns](architecture/design-patterns.md) — Required patterns per layer
- [Module Dependencies](architecture/module-dependencies.md) — Strict dependency graph

## Decisions
- [Initial Audit](decisions/initial-audit.md) — Full project audit 2026-05-05, state vs template
- [Migration Plan](decisions/migration-plan.md) — Phased plan to align with quality standards

## Conventions
- [Code Style](conventions/code-style.md) — Naming, sizing, formatting rules
- [Testing](conventions/testing.md) — Coverage targets, mock patterns, naming
- [Git Workflow](conventions/git-workflow.md) — GitFlow, commits, branching
- [Documentation](conventions/documentation.md) — Mintlify standard, page structure, component usage

## Project State
- Prism is a Swift library/framework, NOT an app — template rules adapted accordingly
- v4.4.0, Swift 6.3, platforms v26+, 10 modules, 409 source files, 2207 tests
- Build: passes with 5 warnings. Tests: 1 flaky failure (scheduler timing)
