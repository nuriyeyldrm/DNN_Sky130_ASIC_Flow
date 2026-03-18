#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

RTL_TOP="$ROOT_DIR/src/top.sv"
TB="$ROOT_DIR/src/top_tb_scoreboard.sv"

BUILD_DIR="$ROOT_DIR/build"
mkdir -p "$BUILD_DIR"

OUT="$BUILD_DIR/scoreboard_rtl.out"
LOG="$BUILD_DIR/scoreboard_rtl.log"
VEC_FILE="$BUILD_DIR/scoreboard_vectors.txt"
OBS_FILE="$BUILD_DIR/scoreboard_observed.txt"

echo "[RTL-SB] Running scoreboard RTL simulation..."

if [[ ! -f "$RTL_TOP" ]]; then
  echo "[RTL-SB] ERROR: Missing RTL: $RTL_TOP"
  exit 1
fi

if [[ ! -f "$TB" ]]; then
  echo "[RTL-SB] ERROR: Missing TB: $TB"
  exit 1
fi

rm -f "$OUT" "$LOG" "$OBS_FILE"

python3 "$ROOT_DIR/Verification/golden_model/golden_model.py"

if [[ ! -f "$VEC_FILE" ]]; then
  echo "[RTL-SB] ERROR: Missing generated vector file: $VEC_FILE"
  exit 1
fi

iverilog -g2012 -o "$OUT" "$TB" "$RTL_TOP"

vvp "$OUT" +VEC_FILE="$VEC_FILE" +OUT_FILE="$OBS_FILE" | tee "$LOG"

python3 "$ROOT_DIR/Verification/golden_model/test_compare.py"

echo "[RTL-SB] PASS"