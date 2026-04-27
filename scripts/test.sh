#!/usr/bin/env bash
#
# Run all Prism tests with code coverage and xUnit output.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT_DIR"

mkdir -p .build/artifacts

swift test \
    --enable-code-coverage \
    --xunit-output .build/artifacts/test-results.xml \
    --explicit-target-dependency-import-check error
