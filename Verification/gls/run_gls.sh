#!/usr/bin/env bash
set -euo pipefail

# -----------------------------
# Resolve paths
# -----------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

GLS_SCRIPT="$ROOT_DIR/top_compile_run.sh"
NETLIST="$ROOT_DIR/runs/MS2/results/synthesis/top.v"
TB="$ROOT_DIR/src/top_tb_v1.sv"

BUILD_DIR="$ROOT_DIR/build"
mkdir -p "$BUILD_DIR"

LOG="$BUILD_DIR/gls.log"
VVP_LOG="$BUILD_DIR/vvp.log"

echo "[GLS] Running gate-level simulation..."

# -----------------------------
# File checks
# -----------------------------
if [[ ! -f "$GLS_SCRIPT" ]]; then
  echo "[GLS] ERROR: Missing $GLS_SCRIPT"
  exit 1
fi

if [[ ! -f "$NETLIST" ]]; then
  echo "[GLS] ERROR: Missing synthesized netlist:"
  echo "       $NETLIST"
  echo "[GLS] Run MS2 synthesis first."
  exit 1
fi

if [[ ! -f "$TB" ]]; then
  echo "[GLS] ERROR: Missing testbench: $TB"
  exit 1
fi

# -----------------------------
# Clean previous build
# -----------------------------
rm -f "$LOG" "$VVP_LOG" simv wave.vcd 2>/dev/null || true

# -----------------------------
# Run GLS
# -----------------------------
echo "[GLS] Launching top_compile_run.sh..."

if [[ -n "${PDK_ROOT:-}" ]]; then
  PDK_ROOT="$PDK_ROOT" NETLIST="$NETLIST" TB="$TB" bash "$GLS_SCRIPT" | tee "$LOG"
else
  NETLIST="$NETLIST" TB="$TB" bash "$GLS_SCRIPT" | tee "$LOG"
fi

# -----------------------------
# Move logs if generated elsewhere
# -----------------------------
if [[ -f "$ROOT_DIR/vvp.log" ]]; then
  mv "$ROOT_DIR/vvp.log" "$VVP_LOG"
fi

# -----------------------------
# Check result
# -----------------------------
if grep -q "ALL TESTS PASSED" "$LOG" || grep -q "ALL TESTS PASSED" "$VVP_LOG"; then
  echo "[GLS] PASS"
else
  echo "[GLS] FAIL"
  echo "[GLS] Expected 'ALL TESTS PASSED' in logs"
  exit 1
fi