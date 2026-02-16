# ===============================================================
# MS3 Overlay for Sky130 / OpenLane (APR-Focused)
# ---------------------------------------------------------------
# This file controls floorplan, routing, CTS, PDN, and LVS
# behavior for MS3 (APR milestone).
#
# IMPORTANT:
# - Do NOT change timing here. Timing must be edited ONLY in
#   config.tcl + dnn.sdc.
# - This file is for physical design tuning only.
# ===============================================================

source $::env(DESIGN_DIR)/config.tcl

# ===============================================================
# 1) Floorplan / Placement Control
# ===============================================================

# Core utilization (% of core filled with stdcells)
# Lower value = easier routing, larger die
# Higher value = smaller die, harder routing
# Typical safe range: 35–55
set ::env(FP_CORE_UTIL) 40

# Placement density target
# Lower → safer routing
# Higher → more compact but may cause congestion
# Recommended range: 0.50–0.65
set ::env(PL_TARGET_DENSITY) 0.55

# ===============================================================
# 2) Global Routing Congestion Control
# ===============================================================

# Reserves routing resources to avoid congestion.
# Higher value = more conservative routing.
# If routing fails, increase slightly (e.g., 0.4).
set ::env(GRT_ADJUSTMENT) 0.35

# ===============================================================
# 3) Die Sizing Strategy
# ===============================================================

# ===============================================================
# Floorplanning Strategy (Sky130 / OpenLane)
#
# By default, we use:
#   set ::env(FP_SIZING) "relative"
#
# In this mode, OpenLane automatically computes the core size
# based on:
#   - Synthesized standard cell area
#   - Target utilization (FP_CORE_UTIL)
#   - Aspect ratio (FP_ASPECT_RATIO)
#
# This follows the same principle as the manual die-area
# calculation used in the ASAP flow, but the geometry math
# is handled internally by OpenLane.
#
# ---------------------------------------------------------------
# OPTIONAL (For Manual Floorplan Experiments)
#
# You may switch to explicit die/core geometry control:
#
#   set ::env(FP_SIZING) "absolute"
#   set ::env(DIE_AREA)  {0 0 300 300}
#   set ::env(CORE_AREA) {20 20 280 280}
#
# This enables manual die-dimension experimentation similar to
# the ASAP TCL-based floorplan scripting.
#
# NOTE:
# - Larger DIE_AREA improves routing robustness.
# - Too small DIE_AREA may cause congestion or DRC failure.
# ===============================================================

# "relative" automatically sizes die based on
# synthesized cell area, FP_CORE_UTIL, and FP_ASPECT_RATIO.
set ::env(FP_SIZING) "relative"

# Keep square core (1.0). Change only if experimenting.
set ::env(FP_ASPECT_RATIO) 1.0

# Margin between core and die boundary (microns)
# Increase if PDN ring overlaps IO or routing congestion appears.
set ::env(FP_CORE_MARGIN) 10

# ===============================================================
# 4) Router Runtime Control
# ===============================================================

# Number of CPU cores used (runtime only, no QoR impact)
set ::env(ROUTING_CORES) 4

# ===============================================================
# 5) Pin Placement (ASAP-style layout intent)
# ===============================================================

# ===============================================================
# Pin Placement Configuration (MS3)
#
# #W = West  (left side of die)
# #E = East  (right side of die)
# #N = North (top side)
# #S = South (bottom side)
#
# You MAY:
#   - Move signal groups between sides to study routing impact.
#   - Reorder pins within a side.
#
# You MUST NOT:
#   - Modify bus index patterns (e.g., x0\[[0-4]\]).
#   - Remove escape characters '\' in bus names.
#   - Add power nets (VPWR/VGND) here.
#   - Do NOT simplify bus patterns (e.g., x0\[[0-4]\] matches x0[0]–x0[4]).
#
# Changing pin placement can affect:
#   - Wirelength
#   - Congestion
#   - Timing
#   - Area
#
# ===============================================================

# Pin ordering file controls physical pin placement.
# You may modify pin_order.cfg to explore floorplan impact.
set ::env(FP_PIN_ORDER_CFG) $::env(DESIGN_DIR)/pin_order.cfg

# ===============================================================
# 6) Power Delivery Network (PDN)
# ===============================================================

# ---------------------------------------------------------------
# OPTIONAL: Custom PDN (Advanced Experiment)
#
# Uncomment the line below to use explicit PDN configuration:
#
#   set ::env(PDN_CFG) $::env(DESIGN_DIR)/pdn.tcl
#
# This enables manual PDN control similar in spirit to the
# ASAP manual stripe scripting.
#
# Default configuration uses parameter-controlled PDN for stability.
# ---------------------------------------------------------------

# By default, we do NOT override the PDN engine manually.

# Standard cell power nets
set ::env(VDD_NETS) "VPWR"
set ::env(GND_NETS) "VGND"

# Allow OpenLane to auto-adjust PDN based on floorplan
set ::env(FP_PDN_AUTO_ADJUST) 1

# Enable core ring
set ::env(FP_PDN_CORE_RING) 1

# Stripe widths (microns)
# Increase to reduce IR drop but may increase routing blockage
set ::env(FP_PDN_VWIDTH) 2
set ::env(FP_PDN_HWIDTH) 2

# Stripe pitch (microns)
# Lower pitch = denser mesh = lower IR drop but more blockage
# Safe range: 15–30
set ::env(FP_PDN_VPITCH) 20
set ::env(FP_PDN_HPITCH) 20

# ===============================================================
# 7) Clock Tree Synthesis
# ===============================================================

# CTS must remain enabled for APR milestone.
set ::env(RUN_CTS) 1

# ===============================================================
# 8) LVS Configuration (Do NOT modify unless debugging LVS)
# ===============================================================

# Match layout and schematic nets by label
set ::env(LVS_CONNECT_BY_LABEL) 1

# Define power/ground nets for LVS
set ::env(LVS_POWER_NETS) "VPWR"
set ::env(LVS_GROUND_NETS) "VGND"

# Exclude filler/decap/tap cells (non-functional cells)
set ::env(LVS_EXCLUDE_CELL_LIST) "sky130_fd_sc_hd__fill_* sky130_fd_sc_hd__decap_* sky130_fd_sc_hd__tap* sky130_ef_sc_hd__decap_*"

# Explicitly declare global power nets for netgen
set ::env(LVS_NETGEN_EXTRA_ARGS) \
"-global VPWR -global VGND -global VPB -global VNB"

# ===============================================================
# 9) Magic Extraction Settings
# ===============================================================

# Use GDS for extraction (more accurate for signoff)
set ::env(MAGIC_EXT_USE_GDS) 1

# Do not use abstract views for extraction
set ::env(MAGIC_EXT_ABSTRACT) 0
