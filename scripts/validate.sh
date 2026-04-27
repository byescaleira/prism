#!/usr/bin/env bash
#
# Full validation pipeline: lint → build → test.
# Use this before pushing or in CI.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT_DIR"

echo "=== Lint ==="
./scripts/lint.sh

echo ""
echo "=== Build ==="
./scripts/build.sh

echo ""
echo "=== Test ==="
./scripts/test.sh

echo ""
echo "All checks passed."
