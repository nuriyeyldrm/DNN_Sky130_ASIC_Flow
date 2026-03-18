#!/usr/bin/env bash
set -euo pipefail

# Resolve project root (designs/dnn)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

BASE="$ROOT_DIR/runs/MS3"

echo "[APR] Checking APR outputs..."

required_dirs=(
  "$BASE/results/placement"
  "$BASE/results/cts"
  "$BASE/results/routing"
  "$BASE/reports/placement"
  "$BASE/reports/cts"
  "$BASE/reports/routing"
  "$BASE/results/final/gds"
  "$BASE/results/final/verilog/gl"
  "$BASE/results/final/spef"
  "$BASE/results/final/sdc"
)

for d in "${required_dirs[@]}"; do
  if [[ ! -d "$d" ]]; then
    echo "[APR] FAIL Missing directory: $d"
    exit 1
  fi
done

required_files=(
  "$BASE/results/final/gds/top.gds"
  "$BASE/results/final/verilog/gl/top.v"
  "$BASE/results/final/spef/top.spef"
  "$BASE/results/final/sdc/top.sdc"
)

for f in "${required_files[@]}"; do
  if [[ ! -f "$f" ]]; then
    echo "[APR] FAIL Missing file: $f"
    exit 1
  fi
done

echo "[APR] PASS"