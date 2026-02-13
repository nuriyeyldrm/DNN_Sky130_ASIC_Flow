TT_LIB = inputs/sky130_tt.lib
SS_LIB = inputs/sky130_ss.lib
FF_LIB = inputs/sky130_ff.lib

# ----------------------------------
# Manual STA (Single Run)
# ----------------------------------

sta_tt:
	mkdir -p outputs
	opensta run_opensta.tcl $(TT_LIB)

sta_ss:
	mkdir -p outputs
	opensta run_opensta.tcl $(SS_LIB)

sta_ff:
	mkdir -p outputs
	opensta run_opensta.tcl $(FF_LIB)

# ----------------------------------
# Automated Sweep (Single Corner)
# ----------------------------------

sweep_tt:
	python3 corner_sweep.py --corner TT

sweep_ss:
	python3 corner_sweep.py --corner SS

sweep_ff:
	python3 corner_sweep.py --corner FF

# ----------------------------------
# Full Multi-Corner Analysis
# ----------------------------------

sweep_all:
	python3 corner_sweep.py --corner ALL

# ----------------------------------
# Post-Processing
# ----------------------------------

report:
	python3 generate_report.py

plot:
	python3 plot_results.py

# ----------------------------------
# Complete Pipeline
# ----------------------------------

full_analysis:
	python3 corner_sweep.py --corner ALL
	python3 generate_report.py
	python3 plot_results.py