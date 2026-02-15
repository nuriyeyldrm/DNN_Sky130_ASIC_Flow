# --------------------------------------------------
# MS5 Sky130 Post-Route OpenSTA Script
# Multi-Corner Enabled
# --------------------------------------------------
#
# PURPOSE:
# This script performs post-route static timing analysis (STA)
# using OpenSTA with extracted parasitics (SPEF).
#
# It is intended to replicate PrimeTime-style signoff timing
# for the Sky130 flow.
#
# --------------------------------------------------
# HOW TO USE:
#
# The liberty file is passed via environment variable:
#
#   make sta_tt
#   make sta_ss
#   make sta_ff
#
# Each Makefile target sets $LIB accordingly.
#
# If you want to manually test:
#   export LIB=inputs/sky130_tt.lib
#   sta -exit run_opensta.tcl
#
# --------------------------------------------------

set liberty_file $::env(LIB)
set design_name top

puts "-----------------------------------------"
puts "Running STA with liberty: $liberty_file"
puts "-----------------------------------------"

# --------------------------------------------------
# 1. Read Liberty (Timing Models)
# --------------------------------------------------
#
# You can change the liberty file to analyze
# different PVT corners.
#
# Examples:
#   TT → typical
#   SS → worst-case slow silicon
#   FF → fastest silicon
#
# Changing the liberty changes:
#   - Cell delays
#   - Setup/hold behavior
#   - Overall Fmax
#

read_liberty $liberty_file

# --------------------------------------------------
# 2. Read Post-Route Netlist
# --------------------------------------------------
#
# This must be the GL (gate-level) netlist from MS3.
#
# If you modify synthesis or APR, regenerate MS3 first.
#

read_verilog inputs/top.v

# --------------------------------------------------
# 3. Link Design
# --------------------------------------------------
#
# Resolves standard cells against liberty models.
#
# If this fails:
#   - Liberty mismatch
#   - Wrong design name
#

link_design $design_name

# --------------------------------------------------
# 4. Read Timing Constraints
# --------------------------------------------------
#
# The clock period inside top.sdc determines
# target operating frequency.
#
# You can experiment by:
#   - Reducing clock period
#   - Adding multicycle constraints
#   - Adding false paths
#
# Changing constraints affects:
#   - Slack
#   - Fmax
#   - Critical path
#

read_sdc inputs/top.sdc

# --------------------------------------------------
# 5. Read Extracted Parasitics (SPEF)
# --------------------------------------------------
#
# This step enables RC-aware timing.
#
# If you comment this out,
# you will get optimistic (pre-route) timing.
#
# ALWAYS include SPEF for signoff-quality results.
#

read_spef inputs/top.spef

# --------------------------------------------------
# 6. Timing Reports
# --------------------------------------------------
#
# - report_checks: detailed path report
# - report_tns: total negative slack
# - report_wns: worst negative slack (critical metric)
#
# Binary search script reads wns.rpt.
#

report_checks -path_delay max -group_count 10 -digits 4 > outputs/timing.rpt
report_tns > outputs/tns.rpt
report_wns > outputs/wns.rpt

puts "STA Completed"

# Extract worst slack directly
set worst_slack [report_wns]

puts "Worst slack summary:"
puts $worst_slack
