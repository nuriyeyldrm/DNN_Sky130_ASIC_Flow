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

START_PERIOD = 20.0
END_PERIOD = 1.0
STEP = -0.5

# TODO: MUST BE UPDATED BY USER
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
    subprocess.run(
        ["opensta", "run_opensta.tcl", lib],
        stdout=subprocess.DEVNULL
    )


def parse_timing():
    with open("outputs/timing.rpt") as f:
        text = f.read()

    slack_match = re.search(r"slack.*?(-?\d+\.\d+)", text)
    delay_match = re.search(r"data arrival time\s+(\d+\.\d+)", text)

    slack = float(slack_match.group(1)) if slack_match else None
    delay = float(delay_match.group(1)) if delay_match else None

    return slack, delay


def parse_power():
    with open("outputs/power.rpt") as f:
        text = f.read()

    power_match = re.search(r"Total\s+(-?\d+\.\d+)", text)
    return float(power_match.group(1)) if power_match else None


def parse_area():
    with open("outputs/area.rpt") as f:
        text = f.read()

    area_match = re.search(r"Total cell area:\s+(\d+\.\d+)", text)
    return float(area_match.group(1)) / 1e6 if area_match else None


# ---------------------------
# Sweep Function
# ---------------------------

def sweep_corner(corner, lib):

    print(f"\n===== Sweeping Corner: {corner} =====")

    best_period = None
    best_slack = None
    best_delay = None
    best_power = None
    area_mm2 = None

    period = START_PERIOD

    while period >= END_PERIOD:

        update_clock(period)
        run_sta(lib)

        slack, delay = parse_timing()

        if slack is None:
            break

        if slack < 0:
            break

        best_period = period
        best_slack = slack
        best_delay = delay
        best_power = parse_power()
        area_mm2 = parse_area()

        period += STEP

    if best_period is None:
        print(f"No valid operating point found for {corner}")
        return None

    fmax = 1000 / best_period
    latency_ns = (CYCLES * 1000) / fmax
    energy_pj = best_power * latency_ns / 1000
    edap = energy_pj * latency_ns * area_mm2
    margin = (best_slack / best_period) * 100

    return [
        corner,
        round(best_period,3),
        round(fmax,2),
        round(best_slack,4),
        round(best_delay,4),
        round(best_power,4),
        round(latency_ns,4),
        round(energy_pj,4),
        round(area_mm2,6),
        round(edap,6),
        round(margin,2)
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

        for corner, lib in selected_corners.items():
            result = sweep_corner(corner, lib)
            if result:
                results.append(result)

    finally:
        restore_sdc()

    if results:
        with open("results_summary.csv", "w", newline="") as f:
            writer = csv.writer(f)
            writer.writerow([
                "Corner","Period(ns)","Fmax(MHz)","Slack(ns)",
                "Delay(ns)","Power(mW)","Latency(ns)",
                "Energy(pJ)","Area(mm2)","EDAP","Margin(%)"
            ])
            writer.writerows(results)

        print("\nResults written to results_summary.csv")