# Git Flow Rules

## Branch Model (GitFlow)
```
main        ← production, always releasable
develop     ← integration branch
feature/*   ← new features (→ develop)
release/*   ← release prep (→ main + develop)
hotfix/*    ← urgent fixes (→ main + develop)
```

## Branch Naming
```
feature/module-short-description    e.g., feature/server-oauth2
fix/module-issue-description        e.g., fix/network-timeout-retry
hotfix/critical-description         e.g., hotfix/jwt-validation-bypass
release/X.Y.Z                      e.g., release/5.0.0
```

## Commits — Conventional Commits (enforced by branch-guard)
```
<type>(<scope>): <description>

Types: feat, fix, refactor, style, perf, build, ci, chore, docs, test, revert
Scope: module name lowercase (foundation, network, ui, server, etc.)
```

### Examples
```
feat(server): add OAuth2 middleware
fix(network): handle timeout on socket reconnect
test(architecture): add store lifecycle tests
docs(intelligence): update CoreML training guide
chore: bump swift-tools-version to 6.3
```

## PR Rules
- Title: conventional commit format (enforced by CI)
- Body: `## Summary` + `## Test plan`
- Target: feature → develop, release/hotfix → main
- Squash merge for features, merge commit for releases
- CI must pass (lint + build + test) before merge

## Release Flow (automated)
1. PR merged to `main` → release.yml triggers
2. Version bump via conventional commit analysis (feat=minor, fix=patch, `!`=major)
3. CHANGELOG.md updated automatically
4. Git tag created + GitHub Release published
5. Back-merge to `develop`

## Tags
- Semantic versioning: `MAJOR.MINOR.PATCH`
- No `v` prefix (e.g., `4.4.0` not `v4.4.0`)
- Created by CI only, never manually

## Protected Branches
- `main`: requires PR, CI pass, no direct push
- `develop`: requires PR, CI pass
