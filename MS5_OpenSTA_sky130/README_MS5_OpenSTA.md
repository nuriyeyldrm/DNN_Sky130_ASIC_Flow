# MS5 – Sky130 Post-Route Evaluation (OpenLane / OpenSTA)

This milestone performs post-route timing and power evaluation using OpenSTA
as the Sky130 equivalent of the ASAP PrimeTime MS5 flow.

Timing evaluation uses RC-extracted parasitics (post-route SPEF) 
to ensure signoff-accurate delay estimation.

This document assumes MS3 (APR) has successfully completed in OpenLane.

---------------------------------------------------------------------

## 1. Required Inputs (From MS3)

All required files are located under:

designs/dnn/runs/MS3/results/final/

You must copy the following files into:

MS5/inputs/

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

```bash
find / -name "sky130_fd_sc_hd__tt_025C_1v80.lib" 2>/dev/null
find / -name "sky130_fd_sc_hd__ss_100C_1v60.lib" 2>/dev/null
find / -name "sky130_fd_sc_hd__ff_n40C_1v95.lib" 2>/dev/null
```

---------------------------------------------------------------------

## Example Copy Commands (Inside OpenLane Container)

``` bash    
cd runs
mkdir -p MS5/inputs

cp MS3/results/final/verilog/gl/top.v MS5/inputs/top.v
cp MS3/results/final/spef/top.spef MS5/inputs/top.spef
cp MS3/results/final/sdc/top.sdc MS5/inputs/top.sdc

cp <TT_path> MS5/inputs/sky130_tt.lib
cp <SS_path> MS5/inputs/sky130_ss.lib
cp <FF_path> MS5/inputs/sky130_ff.lib
```

---------------------------------------------------------------------

## Final MS5 Directory Structure

MS5/
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

### Run Individual Corners (Single Corner)

``` bash
make sta_tt
make sta_ss
make sta_ff
```

Each command performs:

- Liberty loading
- Post-route netlist loading
- SPEF loading
- SDC loading
- Design linking
- RC-aware timing update
- Worst slack extraction

Reports are generated in:

    outputs/

Expected files:

- wns.rpt
- timing.rpt
- tns.rpt

> Note: Area and power are not recomputed in MS5. 
> They are extracted from MS3 signoff reports to ensure physical consistency.

---------------------------------------------------------------------

## 3. Automated Maximum Frequency Search (Binary Search)

Maximum safe frequency is determined automatically using a binary search algorithm.

The script:
1. Searches between 1 ns and 60 ns
2. Iteratively halves the search window
3. Stops when slack ≈ 0
4. Converges within ~13–15 STA runs
5. Timing is considered met when:
    slack ≥ 0

This method provides higher precision and significantly fewer STA runs than linear sweeping.

---------------------------------------------------------------------

## 4. Automated Multi-Corner Evaluation

### Step 1 – Generate Sweep Results

Run Complete Sweep:

```bash
make sweep_all
```

This performs:
- Binary-search timing for TT, SS, FF
- Extracts physical area from MS3 metrics
- Extracts post-route power from MS3 signoff
- Computes:
    - Fmax
    - Latency
    - Energy
    - EDAP
- Automatically detects worst-case corner

Results are saved to:

    results_summary.csv

The script prints:
- Convergence iterations
- Final period per corner
- Worst-case operating corner

### Step 2 – Generate Report

```bash
make report
```

### Step 3 – Generate Plots

Plot generation must be executed outside the OpenLane Docker container.

The container does not include matplotlib.

```bash
pip3 install matplotlib
make plot
```

This generates:
    edap_plot.png
    frequency_plot.png 

### Run Entire Flow

```bash
make full_analysis
```

Execution Order:

1. sweep_all
2. report
3. plot

(full_analysis runs all three in order)

---------------------------------------------------------------------

## 5. Metrics Computed

The automated flow computes:

- Area (mm²) – extracted from MS3 metrics.csv
- Post-route power (mW) – extracted from MS3 typical corner signoff report (31-rcx_sta.power.rpt)
- Multi-corner Fmax (MHz)
- Worst Slack (ns)
- Latency (ns)
- Energy (pJ)
- EDAP (pJ·ns·mm²)

Worst-case signoff frequency is automatically determined from the corner with the minimum converged Fmax (typically SS for Sky130).
Power is taken from MS3 typical corner signoff and assumed constant across PVT.

---------------------------------------------------------------------

## 6. Latency Calculation

Latency (ns):

    Latency = #cycles × Clock_Period(ns)

Clock period is determined automatically via binary-search timing convergence.

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
