---
name: git-workflow
description: GitFlow conventions — branching, commits, merging, release process.
type: project
---

## Branch Model (GitFlow)

| Branch | Purpose | Created from | Merges to |
|--------|---------|-------------|-----------|
| `main` | Production releases | — | — |
| `develop` | Integration | `main` | `main` (via release) |
| `feature/*` | New work | `develop` | `develop` |
| `release/*` | Release prep | `develop` | `main` + `develop` |
| `hotfix/*` | Urgent fix | `main` | `main` + `develop` |

## Commit Format (Conventional Commits)

```
type(scope): description

Types: feat, fix, chore, docs, style, refactor, perf, test, build, ci, revert
```

- `feat` → minor version bump
- `feat!` → major version bump (breaking)
- `fix` → patch version bump
- Others → patch version bump

## Merge Strategy

| Source | Target | Strategy |
|--------|--------|----------|
| `feature/*` | `develop` | Squash merge |
| `release/*` | `main` | Merge commit (--no-ff) |
| `hotfix/*` | `main` | Merge commit (--no-ff) |
| Back-merge | `develop` | Merge commit (--no-ff) |

## CI Requirements for Merge

- ✅ Branch guard passes (correct flow direction)
- ✅ PR title follows Conventional Commits
- ✅ Lint passes (strict)
- ✅ Build passes (warnings-as-errors)
- ✅ Tests pass (with coverage)
- ✅ At least 1 approval (if team)

## Release Process (Automated)

1. PR merged to `main` → triggers release workflow
2. Semantic version calculated from commits
3. CHANGELOG.md auto-updated
4. Git tag created and pushed
5. GitHub Release created
6. Back-merge to `develop`

**Why:** Predictable, automated releases. No manual version management. Clean history.

**How to apply:** Use `pnpm swift-cli feature/release/hotfix` commands. Never commit directly to main/develop.
