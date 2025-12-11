# Quick Start - SPI Master Simulation

## Quick Run

```bash
make all
```

## What Was Added

### 1. Automatic Test Assertions (tb_spi_master.v)
- Test pass/fail checking for each transaction
- Expected vs actual data comparison
- Automatic test counting and reporting
- Final status summary with clear PASS/FAIL indication

### 2. Simulation Scripts
- **Makefile** - Easy `make all` command
- **run_sim.sh** - Bash script for manual control
- **run_xsim.tcl** - TCL script for Vivado

### 3. Enhanced Testbench Features
```verilog
// Test tracking variables
integer test_count;
integer pass_count;
integer fail_count;
reg [7:0] expected_rx;

// Automatic assertion after each test
if (rx_data == expected_rx) begin
    pass_count = pass_count + 1;
    $display("TEST PASSED");
end else begin
    fail_count = fail_count + 1;
    $display("TEST FAILED: Expected 0x%h, got 0x%h", expected_rx, rx_data);
end
```

### 4. Final Report
```
========================================
===      TEST RESULTS SUMMARY       ===
========================================
Total Tests: 9
Passed:      1
Failed:      8
========================================
*** SOME TESTS FAILED ***
Status: FAILURE
========================================
```

## Current Test Results

| Metric | Value |
|--------|-------|
| Total Tests | 9 |
| Passed | 1 |
| Failed | 8 |
| Pass Rate | 11% |

## Why Tests Are Failing

The SPI master has a bug in data shifting for modes 0, 1, and 2. Only Mode 3 works correctly. This is a timing issue in how MISO is sampled relative to the SPI clock edges.

## Files Modified

1. **tb_spi_master.v** - Added assertions and test tracking
2. **input/rtl/spi_master.v** - Added `timescale` directive (required for xsim)

## Files Created

1. **Makefile** - Build automation
2. **run_sim.sh** - Bash script
3. **run_xsim.tcl** - TCL script
4. **SIMULATION_REPORT.md** - Detailed analysis
5. **QUICKSTART.md** - This file

## View Waveforms

```bash
gtkwave spi_master_sim.vcd
```

## Clean Build Artifacts

```bash
make clean
```
