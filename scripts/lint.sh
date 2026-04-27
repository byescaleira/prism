#!/usr/bin/env bash
#
# Lint all Swift sources with swift-format (strict mode).

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT_DIR"

swift format lint --strict --parallel Package.swift
swift format lint --strict --parallel --recursive Sources Tests
