#!/usr/bin/env bash
set -euo pipefail

# Resolve project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "[STA] Running multi-corner STA checks..."

MAKEFILE="$ROOT_DIR/runs/MS5/Makefile"
TCL="$ROOT_DIR/runs/MS5/run_opensta.tcl"

if [[ ! -f "$MAKEFILE" ]]; then
  echo "[STA] FAIL Missing Makefile in project root: $MAKEFILE"
  exit 1
fi

if [[ ! -f "$TCL" ]]; then
  echo "[STA] FAIL Missing run_opensta.tcl: $TCL"
  exit 1
fi

cd "$ROOT_DIR"

required_inputs=(
  "$ROOT_DIR/runs/MS5/inputs/top.v"
  "$ROOT_DIR/runs/MS5/inputs/top.spef"
  "$ROOT_DIR/runs/MS5/inputs/top.sdc"
  "$ROOT_DIR/runs/MS5/inputs/sky130_tt.lib"
  "$ROOT_DIR/runs/MS5/inputs/sky130_ss.lib"
  "$ROOT_DIR/runs/MS5/inputs/sky130_ff.lib"
)

for f in "${required_inputs[@]}"; do
  if [[ ! -f "$f" ]]; then
    echo "[STA] FAIL Missing MS5 input: $f"
    exit 1
  fi
done

check_corner () {
  local target="$1"
  local label="$2"

  echo "[STA] Running $label ..."
  make -C "$ROOT_DIR/runs/MS5" "$target"

  if [[ ! -f "$ROOT_DIR/runs/MS5/outputs/wns.rpt" ]]; then
    echo "[STA] FAIL Missing outputs/wns.rpt after $label"
    exit 1
  fi

  if [[ ! -f "$ROOT_DIR/runs/MS5/outputs/tns.rpt" ]]; then
    echo "[STA] FAIL Missing outputs/tns.rpt after $label"
    exit 1
  fi

  local wns
  local tns

  wns="$(grep -i wns "$ROOT_DIR/runs/MS5/outputs/wns.rpt" | awk '{print $2}')"
  tns="$(grep -i tns "$ROOT_DIR/runs/MS5/outputs/tns.rpt" | awk '{print $2}')"

  echo "[STA] $label WNS = $wns"
  echo "[STA] $label TNS = $tns"

  python3 - "$wns" "$tns" <<'PY'
import sys
wns = float(sys.argv[1])
tns = float(sys.argv[2])

if wns < 0:
    print("[STA] FAIL Negative WNS")
    sys.exit(1)

if tns != 0.0:
    print("[STA] FAIL Non-zero TNS")
    sys.exit(1)

print("[STA] PASS")
PY
}

check_corner "sta_tt" "TT"
check_corner "sta_ss" "SS"
check_corner "sta_ff" "FF"

echo "[STA] All corners PASS"