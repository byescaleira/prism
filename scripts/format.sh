#!/usr/bin/env bash
#
# Auto-format all Swift sources with swift-format.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT_DIR"

swift format format --in-place --parallel Package.swift
swift format format --in-place --parallel --recursive Sources Tests
