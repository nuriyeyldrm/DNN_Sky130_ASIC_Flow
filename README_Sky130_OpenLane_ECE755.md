# Sky130 / OpenLane Local Setup Guide (ECE755)

This document describes how to set up and run the SkyWater 130nm (Sky130) ASIC flow
locally using **Docker** and **OpenLane**.

> Note: Due to system restrictions, this flow does **not** run directly on CAE machines.
> It is intended to be run on personal machines using Docker.

---

## Prerequisites

- Docker Desktop (or Docker Engine)
- Git
- ~20 GB free disk space
- No GUI tools required

---

## Step 1: Install Docker

### macOS
Download and install **Docker Desktop**:
https://www.docker.com/products/docker-desktop/

Verify installation:
```bash
docker --version
docker run --rm hello-world
```

---

### Linux (Ubuntu example)
```bash
sudo apt update
sudo apt install -y docker.io git
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
```

Log out and log back in, then verify:
```bash
docker --version
docker run --rm hello-world
```

---

### Windows (Docker Desktop + WSL2)
1. Install **Docker Desktop for Windows**
2. Enable **WSL2** when prompted
3. Open a WSL terminal (Ubuntu recommended)

Verify:
```bash
docker --version
docker run --rm hello-world
```

---

## Step 2: Clone OpenLane

```bash
mkdir -p ~/sky130
cd ~/sky130
git clone https://github.com/The-OpenROAD-Project/OpenLane.git
cd OpenLane
```

---

## Step 3: Download Sky130 PDK

From the OpenLane directory:
```bash
make pdk
```

This installs the Sky130 PDK under:
```
~/.ciel/sky130A
```

Verify:
```bash
ls -ld ~/.ciel/sky130A
```

---

## Step 4: Start the OpenLane Docker Container

```bash
make mount
```

You should now be inside the OpenLane container shell.

---

## Step 5: Run a Test Design (Sanity Check)

From inside the container:
```bash
cd /openlane
./flow.tcl -design spm
```

If the flow completes with a **SUCCESS** message, the setup is correct.

Warnings during the flow are normal for initial runs.

---

## Outputs

Design outputs are generated under:
```
/openlane/designs/spm/runs/
```

Including:
- GDS (:q:final layout)
- Timing reports
- Area reports
- Logs

---

## Accessing and Downloading Results

The OpenLane flow runs inside a Docker container, so output files are not directly visible on the host machine.

Step 1: Find the running container

On your host machine (outside the container), run:
```
docker ps
```

Copy the CONTAINER ID of the OpenLane container.

Step 2: Copy results from the container to your local machine

```
docker cp <CONTAINER_ID>:/openlane/designs/spm/runs ~/Downloads/spm_runs
```

This copies all generated outputs (GDS, reports, logs) to your local system.
---

## Installing Icarus Verilog (iverilog)

Gate-level simulation and RTL simulation for MS2 require **Icarus Verilog (`iverilog`)**
to be installed on the **local machine**.  
This tool is **not included** in the OpenLane Docker container.

### macOS (Homebrew)
```bash
brew install iverilog
```

### Linux (Ubuntu / Debian) 
```bash
sudo apt update
sudo apt install -y iverilog
```

> If you’re on Windows, install iverilog inside your WSL Ubuntu using the Linux command.

### Verify installation
```bash
iverilog -V
```

## Installing KLayout (Layout Viewer for MS4)

MS4 requires viewing the generated GDS layout file.\
The recommended cross-platform viewer is **KLayout**.

### macOS

1.  Download from: https://www.klayout.de/build.html
2.  Choose the macOS build matching your system:
    -   Apple Silicon (M1/M2/M3): arm64
    -   Intel Mac: x86_64
3.  Install the `.dmg` file and drag `klayout.app` into Applications.
4.  If macOS blocks the app:
    -   System Settings -> Privacy & Security -> Open Anyway

Optional (remove quarantine warning):

``` bash
sudo xattr -rd com.apple.quarantine /Applications/klayout.app
```

------------------------------------------------------------------------

### Linux (Ubuntu example)

``` bash
sudo apt update
sudo apt install -y klayout
```

Verify:

``` bash
klayout -v
```

------------------------------------------------------------------------

### Windows

1.  Download the Windows installer from:
    https://www.klayout.de/build.html
2.  Run the `.exe` installer.
3.  Launch KLayout from the Start Menu.

------------------------------------------------------------------------

## Opening the GDS Layout

After MS3 completes, open:

    runs/MS3/results/final/gds/top.gds

macOS / Windows: - Open KLayout - File -> Open -> select `top.gds`

Linux:

``` bash
cd runs/MS3/results/final/gds
klayout top.gds
```

Press **F** to zoom to the full chip layout.

------------------------------------------------------------------------

## Notes

- This flow is fully command-line based.
- No Cadence or Synopsys tools are required.
- The generated GDS is manufacturable in the Sky130 process.
- This setup will be extended later for custom designs (e.g., DNN).

---

## Troubleshooting

- Ensure Docker Desktop is running
- Restart Docker if mount issues occur
- Verify that `~/.ciel/sky130A` exists
