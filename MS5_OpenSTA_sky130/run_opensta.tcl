# --------------------------------------------------
# MS5 Sky130 Post-Route OpenSTA Script
# Multi-Corner Enabled
# --------------------------------------------------

# Usage:
# opensta run_opensta.tcl <liberty_file>

if { $argc < 1 } {
    puts "Usage: opensta run_opensta.tcl <liberty_file>"
    exit 1
}

set liberty_file [lindex $argv 0]
set design_name top

puts "-----------------------------------------"
puts "Running STA with liberty: $liberty_file"
puts "-----------------------------------------"

# Read liberty
read_liberty $liberty_file

# Read netlist
read_verilog inputs/top.v

# Read SDC
read_sdc inputs/top.sdc

# Read SPEF
read_spef inputs/top.spef

# Link design
link_design $design_name

update_timing

# Reports
report_area > outputs/area.rpt
report_timing -max_paths 10 -digits 4 > outputs/timing.rpt
report_power > outputs/power.rpt

puts "STA Completed"

# Extract worst slack directly
set worst_slack [report_tns]

puts "Worst slack summary:"
puts $worst_slack