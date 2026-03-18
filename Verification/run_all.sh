#!/usr/bin/env bash
set -e

echo "=============================="
echo " ASIC VERIFICATION PIPELINE"
echo "=============================="

echo "[1] RTL Simulation..."
bash rtl/run_rtl.sh

echo "[2] RTL Scoreboard Simulation..."
bash rtl/run_scoreboard_rtl.sh

echo "[3] Gate-Level Simulation..."
bash gls/run_gls.sh

echo "[4] APR Output Verification..."
bash apr/check_apr_outputs.sh

echo "[5] Physical Verification (DRC/LVS)..."
bash physical/check_drc_lvs.sh

echo "[6] Timing Verification (STA)..."
bash timing/check_sta.sh

echo "=============================="
echo " ALL CHECKS PASSED"
echo "=============================="