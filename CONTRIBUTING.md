# Contributing

Thanks for contributing to Prism.

## Toolchain

- Swift 6.3
- Xcode 26.4 or newer
- Latest Apple SDK generation (`26.x`)

## Local Workflow

Run the project quality gates before opening a pull request:

```bash
make format
make validate
```

If you want the steps separately:

```bash
make lint
make build
make test
```

## Engineering Rules

- Keep imports explicit across targets. The package validation enforces this.
- Prefer modern Swift and SwiftUI APIs that match the package baseline.
- Keep public API additions intentional. If something does not need to be public, keep it internal.
- Preserve adaptive behavior across Apple platforms. Do not add platform-specific behavior without a clear fallback or rationale.
- Add tests whenever you change behavior in `PrismFoundation`, `PrismNetwork`, `PrismArchitecture`, or `PrismUI`.

## Pull Requests

Before opening a PR, make sure you have:

- A short summary of the change and why it exists
- Validation notes with the commands you ran
- A note about API impact if you changed public surface
- A note about platform impact if you changed cross-platform behavior
