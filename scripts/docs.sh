#!/usr/bin/env bash
#
# Generate DocC documentation for all Prism modules.
# Usage: ./scripts/docs.sh [serve]
#   serve  — start a local preview server after building

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_DIR="$ROOT_DIR/docs-output"
BUILD_DIR="$ROOT_DIR/.build/plugins/Swift-DocC/outputs"

cd "$ROOT_DIR"

TARGETS=(
    PrismFoundation
    PrismNetwork
    PrismArchitecture
    PrismUI
    PrismVideo
    PrismIntelligence
    Prism
)

echo "Building DocC documentation..."

for target in "${TARGETS[@]}"; do
    echo "  → $target"
    swift package generate-documentation \
        --target "$target" \
        --disable-indexing \
        --transform-for-static-hosting
done

rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

for target in "${TARGETS[@]}"; do
    cp -R "$BUILD_DIR/$target.doccarchive" "$OUTPUT_DIR/$target"
done

cp "$ROOT_DIR/scripts/docs-index.html" "$OUTPUT_DIR/index.html"

echo ""
echo "Documentation built at $OUTPUT_DIR/"

if [ "${1:-}" = "serve" ]; then
    echo "Starting preview server at http://localhost:8000 ..."
    python3 -m http.server 8000 --directory "$OUTPUT_DIR"
fi
