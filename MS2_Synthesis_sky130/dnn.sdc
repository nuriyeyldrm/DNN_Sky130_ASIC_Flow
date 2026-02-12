# ============================================================
# dnn.sdc — Timing Constraints for DNN (MS2 / Sky130)
#
# READ ME:
# - This SDC defines the timing assumptions used for synthesis,
#   APR, and timing analysis in the Sky130/OpenLane flow.
# - The values here are chosen to closely match the intent of the
#   ASAP7 MS2 (Design Compiler) constraints used earlier.
#
# WHAT YOU MAY CHANGE:
# - The clock period is automatically taken from config.tcl (CLOCK_PERIOD).
#
# WHAT YOU SHOULD NOT CHANGE:
# - Clock uncertainty, transition, I/O delays, or load values,
#   unless you fully understand the timing impact.
#
# NOTE:
# - All values are in nanoseconds (ns).
# - These are simple, project-prep-friendly constraints intended
#   for functional correctness rather than aggressive optimization.
# ============================================================

# ---------- Clock definition ----------
# Main system clock driving the DNN
create_clock -name clk -period $::env(CLOCK_PERIOD) -waveform {0 [expr $::env(CLOCK_PERIOD)/2]} [get_ports clk]

# Conservative clock uncertainty to account for jitter and skew
set_clock_uncertainty 0.01 [get_clocks clk]

# Clock transition (32 ps), equivalent to ASAP7 MS2 assumption
set_clock_transition 0.032 [get_clocks clk]

# ---------- Input / Output timing ----------
# Apply I/O delays to all primary inputs except the clock
set prim_inputs [remove_from_collection [all_inputs] [get_ports clk]]
set_input_delay 0.1 -clock clk $prim_inputs

# Apply output delay relative to the same clock
set_output_delay 0.1 -clock clk [all_outputs]

# ---------- Output load ----------
# Light capacitive load to model downstream logic
set_load 0.010 [all_outputs]
