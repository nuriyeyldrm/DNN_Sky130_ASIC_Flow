# Milestone 2: Synthesis (Sky130 / OpenLane)

This milestone performs **logic synthesis** of the design using the
SkyWater **Sky130** PDK and the **OpenLane** flow.  
It is the Sky130/OpenLane equivalent of **MS2 (Synthesis)** in the ASAP7 flow.

The flow produces:
- A synthesized gate-level netlist
- Timing, area, and power reports
- An SDC file used for downstream physical design (APR)

---

## 1. Prerequisites

- Docker installed and running
- OpenLane Docker image pulled
- Sky130 PDK installed via `make pdk`
- Verified RTL (`top.sv`)

---

## 2. Directory Structure

```
designs/dnn/
├── config.tcl        # OpenLane design configuration
├── dnn.sdc 
├── top_compile_run.sh
├── src/
│   ├── top.sv        # RTL
└── └── top_tb_v1.sv  # Testbench        
```

---

## 3. Configuration Files

### `config.tcl`
Defines the design name, RTL sources, clock, and flow options.
This replaces:
- `syn_script.tcl`
- `.synopsys_dc.setup`
in the ASAP7 flow.

### `dnn.sdc`
Defines timing constraints (clock, I/O delays, loads).

This file is a **static SDC** and is explicitly referenced by `config.tcl`.

You should modify timing assumptions **only if needed**, and in a controlled manner
(e.g., adjusting the clock period if setup violations occur).

---

## 4. RTL Simulation (Pre-Synthesis Sanity Check)

Before running OpenLane, it is recommended to verify the RTL functionality
independently using Icarus Verilog.

From the `designs/dnn/` directory:

```bash
iverilog -g2012 -o rtl.out \
  src/top_tb_v1.sv \
  src/top.sv

vvp rtl.out | tee rtl.log
```

## 5. Running Synthesis

From inside the OpenLane Docker container:

```bash
cd /openlane
./flow.tcl -design dnn -tag MS2 -overwrite 
```

This command runs the complete OpenLane flow, including:
- RTL elaboration
- Logic synthesis
- Floorplanning
- Placement
- Clock tree synthesis
- Routing

For **Milestone 2**, only the **synthesis-stage outputs** are required and evaluated.

OpenLane does not support a synthesis-only mode; therefore, the **full flow is run intentionally**.
Outputs from floorplanning, placement, CTS, and routing are not required for MS2.
---

## 6. Outputs

After a successful run, results are located under:

```
designs/dnn/runs/MS2/
```

### Synthesized Netlist
```
results/synthesis/top.v
```

### Reports
```
reports/synthesis/
├── 1-synthesis.AREA_0.stat.rpt  # Area breakdown after logic synthesis
├── 2-syn_sta.summary.rpt        # High-level synthesis timing summary (WNS, TNS, path count)
├── 2-syn_sta.max.rpt            # Setup timing analysis (maximum delay paths)
└── 2-syn_sta.min.rpt            # Hold timing analysis (minimum delay paths)
└── 2-syn_sta.power.rpt          # Power estimation after synthesis
└── 2-syn_sta.skew.rpt           # Clock skew analysis
└── 2-syn_sta.checks.rpt         # Constraint and consistency checks
```

> Note: Exact report filenames may vary slightly across OpenLane versions.

---

## 7. Gate-Level Simulation (MS2 Functional Verification)

As in ASAP7 MS2, the synthesized netlist must be functionally verified using
gate-level simulation.

This project uses a Sky130-compatible gate-level simulation script
(`top_compile_run.sh`) as a replacement for the QuestaSim-based flow used in ASAP7.

### Purpose
- Verify that synthesis preserved functional correctness
- Generate waveforms for MS2 submission (if required)

### Running Gate-Level Simulation

Gate-level simulation using `top_compile_run.sh` is run **on the local machine**.
The OpenLane Docker container does not include `iverilog` by default.
After synthesis completes, copy the required design files (netlist, RTL, testbench,
and script) from the Docker environment and run the simulation locally.

```bash
chmod +x top_compile_run.sh
```

**Step 1: Locate the Sky130 PDK path**
The Sky130 PDK location may differ depending on the environment.
To find the correct path, run:

```bash
find / -path "*sky130A/libs.ref/sky130_fd_sc_hd/verilog/primitives.v" 2>/dev/null | head -n 1
```

The output will look similar to:
<PDK_ROOT>/libs.ref/sky130_fd_sc_hd/verilog/primitives.v

Use the directory containing libs.ref as PDK_ROOT.

**Step 2: Run gate-level simulation**

```bash
PDK_ROOT=<path-to-sky130A> \
NETLIST=runs/MS2/results/synthesis/top.v \
TB=src/top_tb_v1.sv \
./top_compile_run.sh
```

To generate and view waveforms (requires $dumpfile / $dumpvars in the testbench):

```bash
PDK_ROOT=<path-to-sky130A> \
NETLIST=runs/MS2/results/synthesis/top.v \
TB=src/top_tb_v1.sv \
./top_compile_run.sh -w
```

> Note: This gate-level simulation is functional only (no SDF back-annotation), matching the ASAP7 MS2 verification flow.
---

## 8. Mapping to ASAP7 MS2

| ASAP7 (Design Compiler) | Sky130 / OpenLane |
|-------------------------|-------------------|
| dc_shell synthesis | flow.tcl (synthesis stage) |
| top.vg simulation (Questa) | top.v simulation (Icarus Verilog) |
| constraints.tcl | dnn.sdc |
| syn_script.tcl | config.tcl |
