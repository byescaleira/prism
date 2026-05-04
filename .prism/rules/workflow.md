# Workflow Rules — Phase Execution Protocol

Every project follows strict phased execution. No skipping steps.

## Phase Lifecycle

```
┌─────────────────────────────────────────────────────────┐
│  1. PLAN        ultrathink before each phase            │
│  ────────────────────────────────────────────────────── │
│  2. EXECUTE     git flow (feature branch → develop)     │
│  ────────────────────────────────────────────────────── │
│  3. TEST        full quality gate                       │
│  ────────────────────────────────────────────────────── │
│  4. DOCUMENT    functional + aesthetic (not verbose)     │
│  ────────────────────────────────────────────────────── │
│  5. MERGE       MR with full explanation                │
│  ────────────────────────────────────────────────────── │
│  6. RELEASE     changelog + tag + GitHub release        │
└─────────────────────────────────────────────────────────┘
```

## Step 1 — PLAN (ultrathink)
- Use ultrathink to deeply reason about the phase scope
- Define what will be built, why, and how
- Identify risks, dependencies, edge cases
- Output: clear task list for the phase
- NO code until plan is approved

## Step 2 — EXECUTE (git flow)
- Create feature branch: `feature/<target>-<description>`
- Follow conventional commits: `feat(scope): description`
- Small, atomic commits — one concern per commit
- Follow all rules in `rules/swift.md`, `rules/architecture.md`, `rules/naming.md`
- Commit frequently, not at the end

## Step 3 — TEST (quality gate)
- All new code has tests
- `swift format lint --strict` passes
- `swift build --build-tests` passes
- `swift test` — all green
- Follow `rules/testing.md` conventions
- No skipping — broken tests = phase not done

## Step 4 — DOCUMENT (aesthetic + functional)
- Update relevant docs (DocC, Mintlify, README)
- Style: practical, visual, creative — NOT verbose
- Use badges, tables, diagrams, code examples
- If new module/feature: update architecture diagram
- If new API: usage example required

## Step 5 — MERGE (explained MR)
- PR title: conventional commit format
- PR body: `## Summary` (bullets) + `## Test Plan` (checklist)
- Target: feature → develop (or main if no develop)
- CI must pass
- Follow `rules/review.md` checklist

## Step 6 — RELEASE (tag + changelog)
- Update `trackers/changelog-next.md`
- Merge to main triggers auto-release (or manual if needed)
- Semantic version: feat=minor, fix=patch, breaking=major
- GitHub Release with generated notes
- Update `trackers/roadmap.md` — mark phase tasks as ✅ DONE

## Rules
- NEVER start a phase without ultrathink planning first
- NEVER skip testing — it's not optional
- NEVER merge without passing CI
- NEVER write verbose docs — aesthetic + functional only
- Phases are sequential — finish one before starting next
- Update trackers after every phase completion
