# --------------------------------------------------
# MS5 Multi-Corner Binary Search Timing Script
#
# This script:
#  - Performs RC-aware STA using OpenSTA
#  - Searches maximum safe frequency using binary search
#  - Extracts post-route power and area from MS3
#  - Computes Energy and EDAP
#
# You may modify:
#  - START_PERIOD / END_PERIOD (search window)
#  - CYCLES (pipeline latency)
# --------------------------------------------------

import subprocess
import re
import csv
import argparse
import shutil
import os

SDC_FILE = "inputs/top.sdc"
SDC_BACKUP = "inputs/top.sdc.bak"

CORNERS = {
    "TT": "inputs/sky130_tt.lib",
    "SS": "inputs/sky130_ss.lib",
    "FF": "inputs/sky130_ff.lib"
}

START_PERIOD = 60.0
END_PERIOD = 1.0

# Binary search window (ns)
# If timing fails even at START_PERIOD,
# increase START_PERIOD.
# If search is too slow, reduce window size.

# Number of clock cycles required to produce one output
# Must be obtained from simulation (pipeline depth).
# Used to compute latency and energy.
CYCLES = 2


# ---------------------------
# Utility Functions
# ---------------------------

def backup_sdc():
    shutil.copy(SDC_FILE, SDC_BACKUP)

def restore_sdc():
    shutil.copy(SDC_BACKUP, SDC_FILE)
    os.remove(SDC_BACKUP)

def update_clock(period):
    with open(SDC_FILE, "r") as f:
        lines = f.readlines()

    new_lines = []
    for line in lines:
        if "create_clock" in line:
            new_lines.append(
                f"create_clock [get_ports clk] -period {period} -waveform {{0 {period/2}}}\n"
            )
        else:
            new_lines.append(line)

    with open(SDC_FILE, "w") as f:
        f.writelines(new_lines)


def run_sta(lib):
    env = os.environ.copy()
    env["LIB"] = lib

    subprocess.run(
        ["sta", "-exit", "run_opensta.tcl"],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        env=env,
        check=True
    )


def parse_timing():
    try:
        with open("outputs/wns.rpt") as f:
            wns = float(f.read().split()[1])
    except:
        return None, None

    # We no longer extract delay reliably
    delay = None

    return wns, delay


def get_power_from_ms3():
    with open("../MS3/reports/signoff/31-rcx_sta.power.rpt") as f:
        text = f.read()

    match = re.search(r"Total\s+[\d\.e\+\-]+\s+[\d\.e\+\-]+\s+[\d\.e\+\-]+\s+([\d\.e\+\-]+)", text)

    if match:
        power_watts = float(match.group(1))
        return power_watts * 1000  # convert to mW

    return None


def get_area_from_ms3():
    with open("../MS3/reports/metrics.csv") as f:
        lines = f.readlines()

    header = lines[0].strip().split(",")
    values = lines[1].strip().split(",")

    idx = header.index("CoreArea_um^2")
    core_area_um2 = float(values[idx])

    return core_area_um2 / 1e6


# ---------------------------
# Sweep Function
# ---------------------------

def sweep_corner(corner, lib, power_mw, area_mm2):

    print(f"\n===== Sweeping Corner: {corner} =====")

    # Binary search for minimum clock period that satisfies slack >= 0
    # high = safe region
    # low  = violating region
    # Converges when search window < tolerance

    low = END_PERIOD
    high = START_PERIOD

    best_period = None
    best_slack = None

    tolerance = 0.01
    iterations = 0

    while (high - low) > tolerance:

        mid = (high + low) / 2.0
        iterations += 1

        update_clock(mid)
        run_sta(lib)

        slack, _ = parse_timing()

        if slack is None:
            break

        if slack >= 0:
            best_period = mid
            best_slack = slack
            high = mid
        else:
            low = mid

    if best_period is None:
        print(f"No valid operating point found for {corner}")
        return None

    # Remove negative zero
    if abs(best_slack) < 1e-6:
        best_slack = 0.0

    fmax = 1000 / best_period
    latency_ns = CYCLES * best_period
    energy_pj = power_mw * latency_ns / 1000
    
    # EDAP = Energy × Delay × Area
    # Used as composite optimization metric
    # Lower EDAP = better overall tradeoff
    edap = energy_pj * latency_ns * area_mm2
    margin = (best_slack / best_period) * 100 if best_period != 0 else 0

    print(f"  -> Converged in {iterations} iterations")
    print(f"  -> Final Period: {best_period:.4f} ns")
    print(f"  -> Fmax: {fmax:.2f} MHz")

    return [
        corner,
        round(best_period, 3),
        round(fmax, 2),
        round(best_slack, 4),
        round(power_mw, 4),
        round(latency_ns, 4),
        round(energy_pj, 4),
        round(area_mm2, 6),
        round(edap, 6),
        round(margin, 2)
    ]


# ---------------------------
# Main Execution
# ---------------------------

if __name__ == "__main__":

    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--corner",
        choices=["TT", "SS", "FF", "ALL"],
        default="ALL",
        help="Select corner to sweep"
    )

    args = parser.parse_args()

    backup_sdc()

    results = []

    try:

        if args.corner == "ALL":
            selected_corners = CORNERS
        else:
            selected_corners = {args.corner: CORNERS[args.corner]}

        power_mw = get_power_from_ms3()
        area_mm2 = get_area_from_ms3()

        if power_mw is None or area_mm2 is None:
            print("ERROR: Could not extract power or area from MS3.")
            exit(1)

        for corner, lib in selected_corners.items():
            result = sweep_corner(corner, lib, power_mw, area_mm2)
            if result:
                results.append(result)

    finally:
        restore_sdc()

    if results:
        with open("results_summary.csv", "w", newline="") as f:
            writer = csv.writer(f)
            writer.writerow([
                "Corner","Period(ns)","Fmax(MHz)","Slack(ns)",
                "Power(mW)","Latency(ns)",
                "Energy(pJ)","Area(mm2)","EDAP","Margin(%)"
            ])
            writer.writerows(results)
        
        worst = min(results, key=lambda x: x[2])  # smallest Fmax
        print("\n===== Worst Case Corner =====")
        print(f"Corner: {worst[0]}")
        print(f"Max Safe Frequency: {worst[2]} MHz")

        print("\nResults written to results_summary.csv")
