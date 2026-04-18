# ===============================================================
# MS3 TinyTapeout 1x1 Overlay for Sky130 / OpenLane
# ---------------------------------------------------------------
# Based on tt_block_1x1_pg.def:
#   UNITS DISTANCE MICRONS 1000 ;
#   DIEAREA ( 0 0 ) ( 161000 111520 ) ;
#
# => DIE_AREA = 161.00 um x 111.52 um
#
# NOTE:
# - This applies TinyTapeout-like 1x1 AREA constraint only.
# - It does NOT convert the design to full TinyTapeout wrapper pins.
# ===============================================================

source $::env(DESIGN_DIR)/config.tcl

# ===============================================================
# 1) Floorplan / Placement Control
# ===============================================================
set ::env(FP_CORE_UTIL) 40
set ::env(PL_TARGET_DENSITY) 0.55

# ===============================================================
# 2) Global Routing Congestion Control
# ===============================================================
set ::env(GRT_ADJUSTMENT) 0.35

# ===============================================================
# 3) TinyTapeout 1x1 Die Sizing
# ===============================================================
set ::env(FP_SIZING) "absolute"
set ::env(DIE_AREA) "0 0 161 111.52"

# Keep square-style intent only if needed by tool flow
set ::env(FP_ASPECT_RATIO) 1.0

# Leave margin for routing / PDN
set ::env(FP_CORE_MARGIN) 10

# ===============================================================
# 4) Router Runtime Control
# ===============================================================
set ::env(ROUTING_CORES) 4

# ===============================================================
# 5) Pin Placement
# ===============================================================
set ::env(FP_PIN_ORDER_CFG) $::env(DESIGN_DIR)/pin_order.cfg

# ===============================================================
# 6) Power Delivery Network (PDN)
# ===============================================================
set ::env(VDD_NETS) "VPWR"
set ::env(GND_NETS) "VGND"

set ::env(FP_PDN_AUTO_ADJUST) 1
set ::env(FP_PDN_CORE_RING) 1

set ::env(FP_PDN_VWIDTH) 2
set ::env(FP_PDN_HWIDTH) 2
set ::env(FP_PDN_VPITCH) 20
set ::env(FP_PDN_HPITCH) 20

# ===============================================================
# 7) Clock Tree Synthesis
# ===============================================================
set ::env(RUN_CTS) 1

# ===============================================================
# 8) LVS Configuration
# ===============================================================
set ::env(LVS_CONNECT_BY_LABEL) 1
set ::env(LVS_POWER_NETS) "VPWR"
set ::env(LVS_GROUND_NETS) "VGND"

set ::env(LVS_EXCLUDE_CELL_LIST) "sky130_fd_sc_hd__fill_* sky130_fd_sc_hd__decap_* sky130_fd_sc_hd__tap* sky130_ef_sc_hd__decap_*"

set ::env(LVS_NETGEN_EXTRA_ARGS) \
"-global VPWR -global VGND -global VPB -global VNB"

# ===============================================================
# 9) Magic Extraction Settings
# ===============================================================
set ::env(MAGIC_EXT_USE_GDS) 1
set ::env(MAGIC_EXT_ABSTRACT) 0