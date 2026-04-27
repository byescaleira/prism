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

cat > "$OUTPUT_DIR/index.html" << 'HTML'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>Prism Documentation</title>
    <style>
        body { font-family: -apple-system, system-ui, sans-serif; max-width: 640px; margin: 4rem auto; padding: 0 1rem; }
        h1 { font-size: 1.5rem; }
        a { display: block; padding: 0.5rem 0; color: #0066cc; text-decoration: none; }
        a:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <h1>Prism Documentation</h1>
    <a href="Prism/documentation/prism/">Prism (umbrella)</a>
    <a href="PrismFoundation/documentation/prismfoundation/">PrismFoundation</a>
    <a href="PrismNetwork/documentation/prismnetwork/">PrismNetwork</a>
    <a href="PrismArchitecture/documentation/prismarchitecture/">PrismArchitecture</a>
    <a href="PrismUI/documentation/prismui/">PrismUI</a>
    <a href="PrismVideo/documentation/prismvideo/">PrismVideo</a>
    <a href="PrismIntelligence/documentation/prismintelligence/">PrismIntelligence</a>
</body>
</html>
HTML

echo ""
echo "Documentation built at $OUTPUT_DIR/"

if [ "${1:-}" = "serve" ]; then
    echo "Starting preview server at http://localhost:8000 ..."
    python3 -m http.server 8000 --directory "$OUTPUT_DIR"
fi
