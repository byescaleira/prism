# Swift Code Rules

## Language
- Swift 6.3, strict concurrency mode always ON
- `@Sendable` compliance — no `@unchecked Sendable` unless documented reason
- Prefer `async/await` over callbacks. Prefer `AsyncSequence` over `Combine` for new code
- Use `sending` parameter modifier where applicable (Swift 6.3)

## Formatting
- `swift format --strict` — enforced by CI
- No manual formatting overrides
- Max line length: 120 chars (soft limit, format handles it)

## Types
- Prefer `struct` over `class`. Use `class` only for reference semantics or inheritance
- Prefer `enum` with associated values over optional-heavy structs
- All public types: `Sendable` conformance required
- Use `@Observable` (Observation framework) over `ObservableObject` for new code

## Access Control
- Default `internal`. Only expose what consumers need
- `public` = part of module API contract, needs DocC
- `package` = shared across Prism modules but not public
- Never `open` unless inheritance is explicitly designed

## Naming
- See `naming.md` for full conventions
- Prefix all public types with `Prism` (e.g., `PrismRouter`, `PrismHTTPClient`)
- Protocol names: capability nouns (`Storable`, `Routable`) or `Protocol` suffix if ambiguous

## Error Handling
- Module errors: one `enum PrismXxxError: Error, Sendable` per module
- Always `LocalizedError` conformance with `errorDescription`
- Never `try!` or `fatalError` in library code. Only in tests or `PrismPreview`

## Dependencies
- Zero third-party runtime deps. Only `swift-docc-plugin` as dev dep
- Inter-module deps follow strict DAG (see `profile.md`)
- New dep = requires justification + team approval

## Performance
- No force unwraps in hot paths
- Prefer `ContiguousArray` for perf-critical collections
- Use `@inlinable` sparingly — only on proven bottlenecks
- Lazy properties for expensive initialization
