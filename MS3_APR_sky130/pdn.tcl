# ===============================================================
# Custom PDN Configuration (Sky130 / OpenLane)
# ---------------------------------------------------------------
# This file overrides the default OpenLane PDN generator.
# Use only for advanced experimentation.
# ===============================================================

# Define power and ground nets
set ::env(VDD_NETS) "VPWR"
set ::env(GND_NETS) "VGND"

# Enable core ring
set ::env(FP_PDN_CORE_RING) 1

# Ring configuration
set ::env(FP_PDN_CORE_RING_VWIDTH) 3
set ::env(FP_PDN_CORE_RING_HWIDTH) 3
set ::env(FP_PDN_CORE_RING_VSPACING) 2
set ::env(FP_PDN_CORE_RING_HSPACING) 2

# Vertical stripes
set ::env(FP_PDN_VWIDTH) 2
set ::env(FP_PDN_VPITCH) 20

# Horizontal stripes
set ::env(FP_PDN_HWIDTH) 2
set ::env(FP_PDN_HPITCH) 20

# Disable auto adjust (manual control)
set ::env(FP_PDN_AUTO_ADJUST) 0