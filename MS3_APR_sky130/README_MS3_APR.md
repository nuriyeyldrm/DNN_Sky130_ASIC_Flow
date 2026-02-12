# Milestone 3: Automatic Place & Route (APR)
**Sky130 / OpenLane**

This milestone performs **automatic place-and-route (APR)** of the synthesized DNN
using the **SkyWater Sky130 PDK** and the **OpenLane** physical design flow.

It is the Sky130/OpenLane equivalent of **MS3 (APR)** in the ASAP7 flow
(Design Compiler → Innovus).

---

## 1. Objective

The goals of Milestone 3 are to:

- Perform **floorplanning, placement, CTS, and routing**
- Apply **physical design constraints** appropriate for APR
- Generate post-layout reports (timing, area, routing)
- Ensure the design completes APR without fatal errors

The design must remain **functionally equivalent** to MS2.

---

## 2. Directory Structure

```
designs/dnn/
├── config.tcl        # OpenLane design configuration
├── config_ms3.tcl    # MS3 APR overlay (sources config.tcl)    
├── dnn.sdc 
├── pin_order.cfg
├── top_compile_run.sh
├── src/
│   ├── top.sv        # RTL
│   └── top_tb_v1.sv  # Testbench
└── runs/          
```

---

## 3. Inputs from MS2 (Reused)

Milestone 3 **reuses the same timing and design configuration files from MS2**:

- `config.tcl` – base OpenLane configuration  
- `dnn.sdc` – timing constraints (clock definition)

These files remain the **single source of truth** for timing across MS2–MS5.

> This mirrors the ASAP7 flow, where the same SDC is reused for synthesis and APR.

---

## 4. MS3-Specific Configuration (APR Constraints)

Unlike ASAP7 (which uses Innovus TCL scripts and MMMC files),
OpenLane applies APR constraints through **environment variables**.

To reflect the intent of ASAP7 MS3, we introduce a **Milestone 3 overlay config**.

### `config_ms3.tcl`

This file extends the MS2 configuration with **APR-focused constraints**
such as floorplan utilization, placement density, and pin placement.

---

## 5. Pin Placement Configuration

To mirror ASAP7 MS3 pin-side constraints (inputs on one side, outputs on another),
a pin order file is used.

### `pin_order.cfg`

## 5.1 Power Delivery Network (PDN) Configuration

In ASAP7 MS3, power delivery (power rings and stripes) is explicitly defined in the Innovus APR script.

In the Sky130/OpenLane flow, the same intent is captured using PDN parameters defined inside config_ms3.tcl.

## 6. Running APR (MS3)

From inside the OpenLane Docker container:

```bash
cd /openlane
./flow.tcl -design dnn -tag MS3 -overwrite -config_file designs/dnn/config_ms3.tcl
```

> OpenLane runs the **full flow by design**.  
> For Milestone 3, only **APR-related outputs** are evaluated.

---

## 7. Outputs

After completion, results are located under:

```
designs/dnn/runs/MS3/
```

### APR Results
```
results/placement/
results/cts/
results/routing/
```

### Reports
```
reports/placement/
reports/cts/
reports/routing/
```

Ensure:
- No fatal placement or routing errors
- CTS completed successfully
- Routing completed without tool failure

Exact report filenames may vary by OpenLane version.

---

## 8. Submission (MS3)

Create an `MS3_APR/` directory containing:

- `results/placement/`
- `results/cts/`
- `results/routing/`
- `reports/placement/`
- `reports/cts/`
- `reports/routing/`

This corresponds to the **APR outputs and reports** required in ASAP7 MS3.

---

## 9. Mapping to ASAP7 MS3

| ASAP7 (Innovus) | Sky130 / OpenLane |
|-----------------|------------------|
| top.vg + top.sdc | MS2 netlist + dnn.sdc |
| apr_reference.tcl (APR + PDN) | config_ms3.tcl |
| editPin constraints | pin_order.cfg |
| Innovus APR | OpenLane placement + CTS + routing |

---

## Final Notes

- **Yes**, MS3 continues to use `dnn.sdc` and `config.tcl` from MS2.
- MS3 only **adds APR constraints**, it does not redefine timing.
- This ensures consistent timing assumptions across MS2–MS5.
