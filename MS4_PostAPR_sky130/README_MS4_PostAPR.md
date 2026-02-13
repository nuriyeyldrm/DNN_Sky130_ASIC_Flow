# Milestone 4: Post-APR (Sky130 / OpenLane)

## Overview

In Milestone 4, the final physical layout generated during MS3 is
inspected and visualized.

Unlike the ASAP7 flow (which required manual `streamOut`, GDS merging,
and Virtuoso setup), the Sky130 OpenLane flow automatically generates a
complete GDS file during the MS3 run.

MS4 for Sky130 focuses on:

-   Verifying physical signoff results (DRC & LVS)
-   Verifying the final GDS file
-   Opening the layout using a layout viewer
-   Capturing a screenshot of the full chip layout

------------------------------------------------------------------------

## 1. Verify Signoff Reports

Before opening the GDS file, confirm that MS3 completed successfully.

Navigate to:

    runs/MS3/reports/signoff

Check the following files:

    drc.rpt  
    39-top.lvs.rpt 

Confirm:
- COUNT: 0 in drc.rpt
- Total errors = 0 in 39-top.lvs.rpt

If either report shows errors, MS3 must be fixed before proceeding.

------------------------------------------------------------------------

## 2. Locate the Final GDS File

After a successful MS3 run, the final GDS file is generated at:

    runs/MS3/results/final/gds/top.gds

This file contains:

-   All placed standard cells
-   Routed metal layers
-   Power distribution network
-   IO pins
-   Full chip layout hierarchy

No additional merging or mapping files are required.

------------------------------------------------------------------------

## 3. Open the Layout

The recommended layout viewer is **KLayout**, which is available for:

-   macOS\
-   Linux\
-   Windows

After installing KLayout, open the generated GDS file:

    runs/MS3/results/final/gds/top.gds

### macOS Users

**Option A (Recommended)**\
1. Open **KLayout** from the Applications folder.\
2. Click **File → Open**.\
3. Select `top.gds`.

**Option B (Terminal, if configured)**

``` bash
cd runs/MS3/results/final/gds
klayout top.gds
```

If the `klayout` command is not recognized, use the GUI method instead.

------------------------------------------------------------------------

### Linux Users

From the terminal:

``` bash
cd runs/MS3/results/final/gds
klayout top.gds
```

------------------------------------------------------------------------

### Windows Users

1.  Open **KLayout** from the Start Menu.\
2.  Click **File → Open**.\
3.  Navigate to:

```{=html}
<!-- -->
```
    runs/MS3/results/final/gds/top.gds

Alternatively, double-click `top.gds` if KLayout is associated with
`.gds` files.

------------------------------------------------------------------------

Once opened:

-   Press **F** to zoom to the full chip layout.
-   Verify that the entire chip boundary is visible.
-   Ensure standard cell rows and routed metal layers are visible.

------------------------------------------------------------------------

## 4. Export Layout Image

To generate a high-quality image:

1.  File → Save Image\
2.  Resolution: 3000x3000 (or higher)\
3.  Format: PNG\
4.  Enable anti-aliasing

Save the image as:

    MS4_Sky130_Layout.png

## Summary

ASAP7 MS4 required manual GDS export and Virtuoso import.

Sky130 MS4 verifies physical signoff (DRC & LVS) and visualizes the automatically generated GDS from OpenLane.

This reflects a simplified and fully open-source physical design flow.
