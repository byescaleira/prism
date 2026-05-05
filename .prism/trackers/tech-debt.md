# Tech Debt Tracker

## Active Debt

| ID | Module | Description | Priority | Added |
|----|--------|-------------|----------|-------|
| TD-001 | README | GitHub URL mismatch: `rafaelesantos/prism` vs `byescaleira/prism` | HIGH | 2026-05-04 |
| TD-002 | PrismServer | No integration tests — only unit tests for 91 source files | HIGH | 2026-05-04 |
| TD-003 | PrismPreview | Minimal preview target — needs full component catalog | MEDIUM | 2026-05-04 |
| TD-004 | DocC | PrismServer + PrismCapabilities missing from docs.yml workflow | MEDIUM | 2026-05-04 |
| TD-005 | CI | Coverage extraction fragile (depends on profdata path heuristic) | LOW | 2026-05-04 |
| TD-006 | PrismGamification | SwiftData `@section` attribute bug forces short test suite names (≤12 chars) | LOW | 2026-05-05 |
| TD-008 | Mintlify | PrismSecurity docs pages not yet written | MEDIUM | 2026-05-05 |

## Resolved Debt

| ID | Module | Description | Resolved | How |
|----|--------|-------------|----------|-----|
| TD-007 | Mintlify | Gamification docs pages written | 2026-05-05 | 6 Mintlify pages committed |

---

**Rules**:
- HIGH = blocks production use or causes incorrect behavior
- MEDIUM = degrades DX or documentation quality
- LOW = cosmetic or minor optimization
- Remove from Active → Resolved when fixed (with commit ref)
