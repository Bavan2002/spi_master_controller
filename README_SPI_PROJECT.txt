#==============================================================================
# SPI Master Controller - Complete ASIC Design Flow
# EN4603 Digital IC Design Assignment
#==============================================================================

PROJECT OVERVIEW:
=================
This project implements a complete ASIC design flow for an 8-bit SPI Master
Controller, including synthesis, DFT insertion, and place & route.

DESIGN SPECIFICATIONS:
======================
- Module: SPI Master Controller
- Data Width: 8-bit
- Technology: 45nm GPDK (gsclib045)
- Clock Frequency: 50 MHz (20ns period)
- SPI Modes: All 4 modes (CPOL/CPHA: 00, 01, 10, 11)
- Clock Divider: Configurable (/2, /4, /8, /16)
- Gate Count: ~500-700 gates
- Scan Chains: 1 chain (single clock domain)

FEATURES:
=========
✓ Full-duplex SPI communication
✓ Configurable clock polarity and phase
✓ Adjustable SPI clock frequency
✓ Automatic slave select control
✓ Busy/valid status signals
✓ DFT-ready with scan chain support

PROJECT STRUCTURE:
==================

spi_master_project/
├── input/
│   ├── rtl/
│   │   └── spi_master.v              # Main RTL design file
│   ├── libs/                          # Copy from lab folders
│   │   └── gsclib045/
│   │       ├── lef/
│   │       ├── timing/
│   │       └── qrc/
│   ├── constraints_spi.tcl            # Timing constraints
│   ├── spi_master_dft.v              # (Generated in Lab 2)
│   ├── spi_master_dft.sdc            # (Generated in Lab 2)
│   ├── spi_master_dft.scandef        # (Generated in Lab 2)
│   └── spi_master.view               # MMMC view definition
│
├── scripts/
│   ├── setup_spi.tcl                  # Library setup script
│   ├── lab1_spi_complete_auto.tcl     # Lab 1: Synthesis
│   ├── lab2_spi_complete_auto.tcl     # Lab 2: DFT insertion
│   └── lab3_spi_complete_auto.tcl     # Lab 3: Place & Route
│
├── output/
│   ├── spi_master_initial.v           # Synthesized netlist (Lab 1)
│   ├── part1/                         # Lab 2 outputs
│   │   ├── spi_master_dft.v
│   │   ├── spi_master_dft.sdc
│   │   └── spi_master_dft.scandef
│   └── part1_with_preopt/             # Lab 3 outputs
│       └── spi_master.gds
│
├── report/
│   ├── initial/
│   ├── exercise*/
│   ├── part1_*/
│   └── ...
│
├── log/
│   ├── lab1_spi_execution.log
│   ├── lab2_spi_execution.log
│   └── lab3_spi_execution.log
│
└── work/                              # Working directory

SETUP INSTRUCTIONS:
===================

1. Create Directory Structure:
   ----------------------------
   $ mkdir -p spi_master_project/{input/rtl,scripts,output,report,log,work}
   $ cd spi_master_project

2. Copy Library Files:
   -------------------
   $ cp -r /path/to/lab/input/libs input/

3. Place Design Files:
   -------------------
   - spi_master.v → input/rtl/
   - tb_spi_master.v → input/rtl/
   - constraints_spi.tcl → input/
   - spi_master.view → input/
   - setup_spi.tcl → scripts/
   - lab1_spi_complete_auto.tcl → scripts/
   - lab2_spi_complete_auto.tcl → scripts/
   - lab3_spi_complete_auto.tcl → scripts/

RUNNING THE LABS:
=================

LAB 1 - RTL SYNTHESIS:
----------------------
$ cd spi_master_project/work
$ genus -f ../scripts/lab1_spi_complete_auto.tcl | tee ../log/lab1_spi_execution.log

Execution Time: ~10-15 minutes

What it does:
- Initial synthesis at 50MHz
- Exercise 1: Multiple frequencies (25, 50, 75, 100 MHz)
- Exercise 2: Different efforts (low, medium, high)
- Generates: Netlists, timing/area/power reports

Outputs:
- output/spi_master_initial.v
- report/initial/*.log
- report/exercise1_*MHz/*.log
- report/exercise2_*_effort/*.log

LAB 2 - DFT INSERTION:
----------------------
$ cd spi_master_project/work
$ genus -f ../scripts/lab2_spi_complete_auto.tcl | tee ../log/lab2_spi_execution.log

Execution Time: ~8-12 minutes

What it does:
- DFT rule checking
- Scan flip-flop insertion
- Single scan chain definition and connection
- Exercise: Multiple scan chains (2 chains)
- ATPG file generation

Outputs:
- output/part1/spi_master_scan.v
- output/part1/spi_master_dft.v
- output/part1/spi_master_dft.sdc
- output/part1/spi_master_dft.scandef
- output/exercise_2chains/spi_master_dft_2chains.v

IMPORTANT: Copy DFT outputs for Lab 3:
$ cp output/part1/spi_master_dft.* input/

LAB 3 - PLACE & ROUTE:
----------------------
$ cd spi_master_project/work
$ innovus

innovus> source ../scripts/lab3_spi_complete_auto.tcl

Execution Time: ~20-30 minutes

What it does:
- Import DFT netlist
- Floorplanning with 40% utilization
- Power ring and stripe insertion
- Standard cell placement (with/without pre-opt)
- Clock tree synthesis
- Signal routing
- Exercise 1: Comparison with/without pre-place optimization
- Exercise 3: Floorplan with IO area (150um margin)
- DRC/LVS verification
- GDSII export

Outputs:
- output/part1_with_preopt/spi_master.gds
- output/exercise1_without_preopt/spi_master.gds
- output/exercise3_with_io/spi_master.gds
- report/part1_preCTS/*.tarpt
- report/part1_postCTS/*.tarpt
- report/part1_postRoute/*.tarpt

TESTING RTL BEFORE SYNTHESIS:
==============================
$ cd spi_master_project/input/rtl
$ iverilog -o spi_sim spi_master.v tb_spi_master.v
$ vvp spi_sim
$ gtkwave spi_master_sim.vcd

Expected Output:
- Tests all 4 SPI modes
- Tests clock dividers
- Loopback verification
- All tests should pass

SPI PROTOCOL DETAILS:
=====================

SPI Modes:
----------
Mode 0: CPOL=0, CPHA=0 - Sample on rising edge, shift on falling
Mode 1: CPOL=0, CPHA=1 - Shift on rising edge, sample on falling
Mode 2: CPOL=1, CPHA=0 - Sample on falling edge, shift on rising
Mode 3: CPOL=1, CPHA=1 - Shift on falling edge, sample on rising

Clock Divider Settings:
-----------------------
clk_div[1:0] = 00 → SPI clock = System clock / 2
clk_div[1:0] = 01 → SPI clock = System clock / 4
clk_div[1:0] = 10 → SPI clock = System clock / 8
clk_div[1:0] = 11 → SPI clock = System clock / 16

Transaction Flow:
-----------------
1. Assert start signal
2. Wait for busy=1
3. SPI transaction executes (8 clock cycles)
4. rx_valid asserts when complete
5. Read rx_data
6. Wait for busy=0 before next transaction

PIN DESCRIPTIONS:
=================

Input Pins:
-----------
clk         : System clock (50MHz)
reset       : Asynchronous reset (active high)
start       : Start SPI transaction (pulse)
cpol        : Clock polarity (0 or 1)
cpha        : Clock phase (0 or 1)
clk_div[1:0]: Clock divider select
tx_data[7:0]: Data to transmit
miso        : Master In Slave Out (SPI data input)

Output Pins:
------------
rx_data[7:0]: Received data
rx_valid    : Received data valid (pulse)
busy        : Transaction in progress
sclk        : SPI clock output
mosi        : Master Out Slave In (SPI data output)
ss_n        : Slave select (active low)

DFT Pins (added in Lab 2):
---------------------------
SE          : Scan enable
scan_in     : Scan chain input
scan_out    : Scan chain output

EXPECTED RESULTS:
=================

LAB 1 (Synthesis @ 50MHz):
---------------------------
Area: ~4000-6000 um²
Power: ~2-4 mW
Gate Count: ~500-700 gates
Timing: Should meet 50MHz with positive slack
Critical Path: Likely through state machine or shift register

LAB 2 (DFT):
------------
Area Overhead: +10-15% (due to scan flip-flops)
Additional Ports: +3 (SE, scan_in, scan_out)
Scan Chain Length: ~40-60 flip-flops
  - State machine registers: 3 bits
  - Shift registers: 16 bits (tx + rx)
  - Counters: ~12 bits
  - Control registers: ~10 bits

LAB 3 (Place & Route):
----------------------
Core Utilization: 40% (as specified)
Aspect Ratio: ~1.0
Die Size: ~800x800 um (without IO area)
         ~1100x1100 um (with IO area)
Metal Layers Used: M1-M8
Routing Congestion: Low
Final Area: 15-25% larger than synthesis estimate

TROUBLESHOOTING:
================

Issue: Timing violations at high frequencies
Solution: Reduce clock frequency or increase clock period
         Add pipelining to critical paths (advanced)

Issue: DFT violations
Solution: Check that all flip-flops have controllable clocks
         Ensure reset can be held inactive during scan

Issue: Routing congestion in Lab 3
Solution: Increase core utilization (try 0.5 or 0.6)
         Add more power stripes
         Increase floorplan size

Issue: Hold violations after CTS
Solution: Script includes optDesign -postCTS -hold
         This should fix most hold violations automatically

ASSIGNMENT REQUIREMENTS:
=========================

1. Select Functional Module: ✓ SPI Master Controller
2. Modify Lab 1 Scripts: ✓ Automated synthesis script
3. Modify Lab 2 Scripts: ✓ Automated DFT insertion script
4. Select IO Modules: ✓ Standard IO pads from gsclib045
5. Modify Lab 3 Scripts: ✓ Automated P&R with IO area

All requirements met with automated scripts!

DELIVERABLES:
=============

For Lab Report:
---------------
1. Screenshots:
   - Floorplan (before placement)
   - Placement (with and without nets)
   - Clock tree (before and after CTS)
   - Final layout with filler cells

2. Reports:
   - Area comparison (synthesis vs DFT vs P&R)
   - Timing reports (setup/hold analysis)
   - Power analysis
   - Gate count comparison
   - Scan chain details

3. Analysis:
   - Explain area overhead due to DFT
   - Compare different clock frequencies
   - Analyze impact of pre-place optimization
   - Discuss IO area requirements

4. Files to Submit:
   - Source code: spi_master.v
   - Final GDS: spi_master.gds (all 3 versions)
   - Reports: Key log files from report/ directory
   - Screenshots: As mentioned above
   - This README: Documentation

ADDITIONAL NOTES:
=================

Advantages of SPI Master for this project:
-------------------------------------------
✓ Industry-relevant communication protocol
✓ Similar complexity to UART (used in labs)
✓ Single clock domain (clean DFT insertion)
✓ State machine provides good synthesis challenge
✓ Real-world application in embedded systems
✓ Configurable parameters for various exercises

Comparison with Lab's UART:
----------------------------
                  UART          SPI Master
Clock Domains:    2             1
Gate Count:       ~1500         ~500-700
Complexity:       Higher        Moderate
Scan Chains:      2 (min)       1 (sufficient)
Use Case:         PC serial     Sensor/flash comm

Learning Outcomes:
------------------
✓ Understanding of SPI protocol
✓ Complete ASIC design flow experience
✓ Synthesis optimization techniques
✓ DFT methodology and scan chain insertion
✓ Physical design and timing closure
✓ Design rule checking and verification

REFERENCES:
===========
- EN4603 Lab Manuals (Lab1.pdf, Lab2.pdf, Lab3.pdf)
- SPI Protocol: https://www.analog.com/en/analog-dialogue/articles/introduction-to-spi-interface.html
- Cadence Genus User Guide
- Cadence Innovus User Guide
- gsclib045 Library Documentation

For questions or issues:
- Refer to lab manuals
- Check inline comments in scripts
- Review execution logs
- Contact lab instructors

Good luck with your assignment!
