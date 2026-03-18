# Verification Methodology

This repository implements a multi-stage verification flow for the Sky130/OpenLane DNN ASIC project.

## Stages

### 1. RTL functional verification
- Tool: Icarus Verilog  
- Files: `top.sv`, `top_tb_v1.sv`  
- Goal: verify basic logic correctness before synthesis  

### 2. RTL scoreboard verification (Python + RTL co-verification)
- Tool: Icarus Verilog + Python  
- Files: `top_tb_scoreboard.sv`, `golden_model.py`  
- Flow:
  - Python generates random test vectors  
  - Python computes expected outputs (golden model)  
  - RTL reads vectors and produces outputs  
  - Python compares expected vs observed results  
- Goal: ensure RTL matches mathematical model across multiple test cases  

### 3. Gate-level verification
- Tool: Icarus Verilog with Sky130 standard-cell models  
- Script: `top_compile_run.sh`  
- Netlist: `designs/dnn/runs/MS2/results/synthesis/top.v`  
- Goal: confirm synthesis preserves functionality  

### 4. APR output verification
- Checks that placement, CTS, routing, GDS, routed netlist, SPEF, and final SDC exist  
- Goal: confirm the MS3 physical flow completed successfully  

### 5. Physical signoff verification
- DRC report must show `COUNT: 0`  
- LVS report must show `Total errors = 0`  
- Goal: confirm the layout is physically valid and matches the intended design  

### 6. Post-route timing verification
- Tool: OpenSTA  
- Files: `inputs/top.v`, `inputs/top.spef`, `inputs/top.sdc`, corner liberty files  
- Goal: verify timing closure with extracted parasitics across TT/SS/FF corners  

---

## Run everything

```bash
bash run_all.sh