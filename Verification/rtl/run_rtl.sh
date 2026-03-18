#!/usr/bin/env bash
set -euo pipefail

# -----------------------------
# Resolve paths
# -----------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

RTL_TOP="$ROOT_DIR/src/top.sv"
TB="$ROOT_DIR/src/top_tb_v1.sv"

BUILD_DIR="$ROOT_DIR/build"
mkdir -p "$BUILD_DIR"

OUT="$BUILD_DIR/rtl.out"
LOG="$BUILD_DIR/rtl.log"
VCD="$BUILD_DIR/wave.vcd"

echo "[RTL] Running RTL simulation..."

# -----------------------------
# File checks
# -----------------------------
if [[ ! -f "$RTL_TOP" ]]; then
  echo "[RTL] ERROR: Missing RTL: $RTL_TOP"
  exit 1
fi

if [[ ! -f "$TB" ]]; then
  echo "[RTL] ERROR: Missing TB: $TB"
  exit 1
fi

# -----------------------------
# Clean previous build
# -----------------------------
rm -f "$OUT" "$LOG" "$VCD" 2>/dev/null || true

# -----------------------------
# Compile
# -----------------------------
echo "[RTL] Compiling..."
iverilog -g2012 -o "$OUT" "$TB" "$RTL_TOP"

# -----------------------------
# Run
# -----------------------------
echo "[RTL] Running..."
vvp "$OUT" | tee "$LOG"

# -----------------------------
# Check result
# -----------------------------
if grep -q "ALL TESTS PASSED" "$LOG"; then
  echo "[RTL] PASS"
else
  echo "[RTL] FAIL"
  echo "[RTL] Expected 'ALL TESTS PASSED' in rtl.log"
  exit 1
fi