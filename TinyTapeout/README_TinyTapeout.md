# TinyTapeout Support Notes

This repository includes an optional TinyTapeout-style APR configuration for Sky130.
Ref: https://github.com/TinyTapeout/tt-support-tools/tree/main/tech/sky130A/def 

## Files
- `MS3_APR_sky130/config_ms3_tt_1x1.tcl`  
  Applies a 1x1 TinyTapeout-sized die area for APR experiments.

## Important
This TCL file only applies the physical 1x1 area constraint.
A real TinyTapeout submission also requires:

- a TinyTapeout-compatible top module interface
- an `info.yaml` file
- a valid top module name in `tt_um_*` style

## Recommended flow
1. Write a TT-compatible wrapper top module.
2. Set `tiles: "1x1"` in `info.yaml`.
3. Run APR with the TinyTapeout config.
4. Verify functionality and reports before submission.