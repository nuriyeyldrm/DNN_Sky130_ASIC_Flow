# MS5 – Sky130 Post-Route Evaluation (OpenLane / OpenSTA)

This milestone performs post-route timing and power evaluation using OpenSTA
as the Sky130 equivalent of the ASAP PrimeTime MS5 flow.

This document assumes MS3 (APR) has successfully completed in OpenLane.

---------------------------------------------------------------------

## 1. Required Inputs (From MS3)

All required files are located under:

designs/dnn/runs/MS3/results/final/

You must copy the following files into:

MS5_Sky130/inputs/

### Required Files

1. **Post-route netlist**
   Source:
   results/final/verilog/gl/top.v

2. **Extracted parasitics (SPEF)**
   Source:
   results/final/spef/top.spef

3. **Final SDC**
   Source:
   results/final/sdc/top.sdc

4. **Standard Cell Liberty Files (Multi-Corner)**

Use the following recommended corners:

- TT: sky130_fd_sc_hd__tt_025C_1v80.lib  
- SS: sky130_fd_sc_hd__ss_100C_1v60.lib  
- FF: sky130_fd_sc_hd__ff_n40C_1v95.lib  

To locate these inside the OpenLane container:

    find / -name "sky130_fd_sc_hd__tt_025C_1v80.lib" 2>/dev/null
    find / -name "sky130_fd_sc_hd__ss_100C_1v60.lib" 2>/dev/null
    find / -name "sky130_fd_sc_hd__ff_n40C_1v95.lib" 2>/dev/null

---------------------------------------------------------------------

## Example Copy Commands (Inside OpenLane Container)

    mkdir -p MS5_Sky130/inputs

    cp results/final/verilog/gl/top.v MS5_Sky130/inputs/top.v
    cp results/final/spef/top.spef MS5_Sky130/inputs/top.spef
    cp results/final/sdc/top.sdc MS5_Sky130/inputs/top.sdc

    cp <TT_path> MS5_Sky130/inputs/sky130_tt.lib
    cp <SS_path> MS5_Sky130/inputs/sky130_ss.lib
    cp <FF_path> MS5_Sky130/inputs/sky130_ff.lib

---------------------------------------------------------------------

## Final MS5 Directory Structure

MS5_Sky130/
│
├── inputs/
│   ├── top.v
│   ├── top.spef
│   ├── top.sdc
│   ├── sky130_tt.lib
│   ├── sky130_ss.lib
│   └── sky130_ff.lib
│
├── outputs/
├── run_opensta.tcl
├── corner_sweep.py
├── generate_report.py
├── plot_results.py
└── Makefile

---------------------------------------------------------------------

## 2. Running Static Timing Analysis

### Run Individual Corners

    make sta_tt
    make sta_ss
    make sta_ff

Each command performs:

- Liberty loading
- Netlist loading
- SDC loading
- SPEF loading
- Design linking
- Timing update
- Area report
- Timing report
- Power report

Reports are generated in:

    outputs/

Expected files:

- area.rpt
- timing.rpt
- power.rpt

---------------------------------------------------------------------

## 3. Maximum Frequency Determination (Manual)

Fmax is computed as:

    Fmax = 1000 / (Clock_Period_ns − Worst_Slack)

Manual process:

1. Reduce clock period in top.sdc
2. Rerun make sta_tt
3. Stop when slack becomes negative
4. The last clock period with positive slack defines Fmax

---------------------------------------------------------------------

## 4. Automated Multi-Corner Sweep

### Step 1 – Generate Sweep Results

    make sweep_all

This generates:

    results_summary.csv

### Step 2 – Generate Report

    make report

### Step 3 – Generate Plots

    make plot

### Run Entire Flow

    make full_analysis

Execution Order:

1. sweep_all
2. report
3. plot

(full_analysis runs all three in order)

---------------------------------------------------------------------

## 5. Metrics Computed

The automated flow computes:

- Area (mm²)
- Worst Slack (ns)
- Fmax (MHz)
- Latency (ns)
- Power (mW)
- Energy (pJ)
- EDAP

---------------------------------------------------------------------

## 6. Latency Calculation

Latency (ns):

    Latency = (#cycles × 1000) / Fmax(MHz)

The number of clock cycles must be obtained from simulation.

---------------------------------------------------------------------

## 7. Energy and EDAP

Energy (pJ):

    Energy = Power(mW) × Latency(ns) / 1000

EDAP metric:

    EDAP = Energy × Latency × Area

Goal: Minimize EDAP.

---------------------------------------------------------------------

## 8. Final Report Template

### MS5 – Sky130 Evaluation Report

#### Design Overview
- Architecture description
- Pipeline depth
- Optimization strategies
- APR or synthesis adjustments

---------------------------------------------------------------------

### Results

| Metric | Value |
|--------|-------|
| Area (mm²) | |
| Fmax (MHz) | |
| Latency (ns) | |
| Power (mW) | |
| Energy (pJ) | |
| EDAP (pJ·ns·mm²) | |

---------------------------------------------------------------------

### Critical Path Analysis

- Critical path location:
- Dominant cell type:
- Setup slack at Fmax:
- Hold violations (if any):

---------------------------------------------------------------------

### Optimization Discussion

Discuss:

- Area reduction techniques
- Timing improvement techniques
- Power optimization techniques

---------------------------------------------------------------------
