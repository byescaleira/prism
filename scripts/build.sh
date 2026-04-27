#!/usr/bin/env bash
#
# Build all Prism targets (including tests) and verify strict imports.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT_DIR"

swift build \
    --build-tests \
    --explicit-target-dependency-import-check error
