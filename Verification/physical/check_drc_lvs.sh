#!/usr/bin/env bash
set -euo pipefail

# Resolve project root (designs/dnn)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

DRC_REPORT="$ROOT_DIR/runs/MS3/reports/signoff/drc.rpt"
LVS_REPORT="$ROOT_DIR/runs/MS3/reports/signoff/39-top.lvs.rpt"

echo "[PHY] Checking DRC/LVS signoff..."

if [[ ! -f "$DRC_REPORT" ]]; then
  echo "[PHY] FAIL Missing DRC report: $DRC_REPORT"
  exit 1
fi

if [[ ! -f "$LVS_REPORT" ]]; then
  echo "[PHY] FAIL Missing LVS report: $LVS_REPORT"
  exit 1
fi

if grep -Eq "COUNT:[[:space:]]*0" "$DRC_REPORT"; then
  echo "[PHY] DRC PASS"
else
  echo "[PHY] DRC FAIL"
  echo "[PHY] Expected 'COUNT: 0' in $DRC_REPORT"
  exit 1
fi

if grep -Eq "Total errors[[:space:]]*=[[:space:]]*0" "$LVS_REPORT"; then
  echo "[PHY] LVS PASS"
else
  echo "[PHY] LVS FAIL"
  echo "[PHY] Expected 'Total errors = 0' in $LVS_REPORT"
  exit 1
fi

echo "[PHY] PASS"