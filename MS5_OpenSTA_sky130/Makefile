# ==================================================
# MS5 – Sky130 OpenSTA Makefile
# ==================================================
#
# This Makefile provides:
#   - Manual single-corner STA
#   - Automated binary-search Fmax sweep
#   - Report + plot generation
#
# ==================================================

# --------------------------------------------------
# Liberty Files (Multi-Corner)
# --------------------------------------------------
# You can modify these paths if needed.
# Changing liberty changes timing behavior (PVT corner).

TT_LIB = inputs/sky130_tt.lib
SS_LIB = inputs/sky130_ss.lib
FF_LIB = inputs/sky130_ff.lib

# ==================================================
# Manual STA (Single Corner Run)
# ==================================================
#
# Runs ONE STA analysis using the selected corner.
# Useful for debugging or manual clock experiments.
#
# Example:
#   make sta_tt
#
# Outputs:
#   outputs/timing.rpt
#   outputs/wns.rpt
#   outputs/tns.rpt
#

sta_tt:
	mkdir -p outputs
	LIB=$(TT_LIB) sta -exit run_opensta.tcl

sta_ss:
	mkdir -p outputs
	LIB=$(SS_LIB) sta -exit run_opensta.tcl

sta_ff:
	mkdir -p outputs
	LIB=$(FF_LIB) sta -exit run_opensta.tcl

# ==================================================
# Automated Fmax Search (Binary Search)
# ==================================================
#
# Automatically finds maximum safe frequency
# where slack >= 0.
#

sweep_tt:
	python3 corner_sweep.py --corner TT

sweep_ss:
	python3 corner_sweep.py --corner SS

sweep_ff:
	python3 corner_sweep.py --corner FF

# ==================================================
# Full Multi-Corner Sweep
# ==================================================
#
# Runs binary search on TT, SS, FF.
# Automatically identifies worst-case corner.
#

sweep_all:
	python3 corner_sweep.py --corner ALL

# ==================================================
# Post-Processing
# ==================================================
#
# report  -> Generates MS5_Report.md
# plot    -> Generates EDAP & frequency plots
#
# NOTE:
# Plot requires matplotlib (run outside Docker).
#

report:
	python3 generate_report.py

plot:
	python3 plot_results.py

# ==================================================
# Complete Pipeline
# ==================================================
#
# Runs:
#   1. Multi-corner sweep
#   2. Report generation
#   3. Plot generation
#
# One-command signoff:
#   make full_analysis
#

full_analysis:
	python3 corner_sweep.py --corner ALL
	python3 generate_report.py
	python3 plot_results.py
