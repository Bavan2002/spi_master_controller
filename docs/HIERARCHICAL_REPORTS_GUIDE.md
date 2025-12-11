# Understanding Hierarchical Reports in PWM Controller

## Overview

The PWM controller synthesis now generates **hierarchical reports** that show area, power, and gate count breakdowns for each submodule. This allows you to see exactly how much each component contributes to the total design.

## Report Files Generated

After synthesis, you'll find these report pairs:

### Standard Reports (Top-Level Only)
- `pwm_area.log` - Total area only
- `pwm_power.log` - Total power only  
- `pwm_gates.log` - Total gates only

### Hierarchical Reports (With Module Breakdown)
- `pwm_area_hierarchy.log` - Area per submodule
- `pwm_power_hierarchy.log` - Power per submodule
- `pwm_gates_hierarchy.log` - Gates per submodule

## Design Hierarchy

The PWM controller has this structure:

```
pwm_controller (TOP)
├── timer_inst (timer_module)
│   ├── prescaler_count[7:0]
│   ├── counter[7:0]
│   └── period_complete logic
├── pwm_ch0 (pwm_generator)
│   ├── duty_cycle[7:0]
│   └── compare logic
├── pwm_ch1 (pwm_generator)
│   ├── duty_cycle[7:0]
│   └── compare logic
└── pwm_ch2 (pwm_generator)
    ├── duty_cycle[7:0]
    └── compare logic
```

## Example Hierarchical Area Report

A typical `pwm_area_hierarchy.log` will show:

```
Instance                        Cells    Cell Area    Net Area     Total Area
--------------------------------------------------------------------------------
pwm_controller                    XXX      YYYY.YY      ZZZ.ZZ      TTTT.TT
  timer_inst                       XX       YYY.YY       ZZ.ZZ       TTT.TT
  pwm_ch0                          XX       YYY.YY       ZZ.ZZ       TTT.TT
  pwm_ch1                          XX       YYY.YY       ZZ.ZZ       TTT.TT
  pwm_ch2                          XX       YYY.YY       ZZ.ZZ       TTT.TT
  (top-level logic)                XX       YYY.YY       ZZ.ZZ       TTT.TT
```

## What Each Section Means

### 1. **timer_inst (timer_module)**
- **Purpose:** Shared timer for all PWM channels
- **Contains:** 8-bit prescaler, 8-bit counter, period comparison
- **Expected Size:** ~40-60 gates
- **Why it matters:** Shows cost of timing infrastructure

### 2. **pwm_ch0, pwm_ch1, pwm_ch2 (pwm_generator instances)**
- **Purpose:** Individual PWM channel logic
- **Contains:** 8-bit duty cycle register, comparator
- **Expected Size:** ~30-40 gates each
- **Why it matters:** Should be nearly identical sizes (reused module)

### 3. **Top-level logic**
- **Purpose:** Signal routing, enable logic, output buffers
- **Contains:** Input/output registers, glue logic
- **Expected Size:** ~20-40 gates
- **Why it matters:** Overhead of integration

## Using the -depth Option

The `-depth 10` flag tells Genus to recurse 10 levels deep in the hierarchy:

```tcl
report_area -depth 10 > ../report/pwm_area_hierarchy.log
```

- **depth 0:** Top-level only (same as no flag)
- **depth 1:** Shows first level of instances
- **depth 10:** Shows up to 10 levels (overkill for our 3-level design)

For PWM controller, depth 2-3 is sufficient, but we use 10 to be safe.

## Analyzing the Results

### Expected Area Distribution

For a typical PWM controller:

| Module | % of Total | Notes |
|--------|-----------|-------|
| timer_inst | 25-30% | Largest single module |
| pwm_ch0 | 15-20% | Should match ch1 & ch2 |
| pwm_ch1 | 15-20% | Should match ch0 & ch2 |
| pwm_ch2 | 15-20% | Should match ch0 & ch1 |
| Top-level | 20-25% | Integration overhead |

### What to Look For

**✅ Good Signs:**
- Three PWM channels have similar area (within 5-10%)
- Timer is the largest single component
- No unexpectedly large areas

**⚠️ Warning Signs:**
- One PWM channel much larger than others (synthesis issue?)
- Top-level logic > 30% (too much glue logic)
- Timer < 20% (might not be synthesized properly)

## Hierarchical Power Report

`pwm_power_hierarchy.log` shows power breakdown:

```
Instance                    Internal    Switching    Leakage      Total
------------------------------------------------------------------------
pwm_controller                X.XXe-03    X.XXe-03    X.XXe-06    X.XXe-03
  timer_inst                  X.XXe-04    X.XXe-04    X.XXe-07    X.XXe-04
  pwm_ch0                     X.XXe-04    X.XXe-04    X.XXe-07    X.XXe-04
  pwm_ch1                     X.XXe-04    X.XXe-04    X.XXe-07    X.XXe-04
  pwm_ch2                     X.XXe-04    X.XXe-04    X.XXe-07    X.XXe-04
```

**Key Insights:**
- **Internal Power:** Power consumed by cell switching
- **Switching Power:** Power for charging/discharging nets
- **Leakage Power:** Static power when idle
- **High switching power:** Indicates high toggle rate (expected for counters)

## Hierarchical Gates Report

`pwm_gates_hierarchy.log` shows gate count breakdown:

```
Instance                    Sequential    Combinational    Total
------------------------------------------------------------------
pwm_controller                    XX              XXX        XXX
  timer_inst                      16               XX         XX
  pwm_ch0                          8               XX         XX
  pwm_ch1                          8               XX         XX
  pwm_ch2                          8               XX         XX
```

**Expected Flip-Flop Counts:**
- **timer_inst:** 16 FFs (8-bit prescaler + 8-bit counter)
- **pwm_ch0/1/2:** 8 FFs each (8-bit duty_cycle register)
- **Total:** ~40 FFs

## Commands for Quick Analysis

### Find Total Area
```bash
grep "Total" report/pwm_area.log
```

### Find Largest Module
```bash
grep -A 10 "Instance" report/pwm_area_hierarchy.log | sort -k4 -rn | head -5
```

### Compare PWM Channels
```bash
grep "pwm_ch" report/pwm_area_hierarchy.log
```

### Check Flip-Flop Distribution
```bash
grep -E "(timer_inst|pwm_ch)" report/pwm_gates_hierarchy.log
```

## Why Hierarchical Reports Matter

### For Design Analysis
1. **Identify bottlenecks:** Which module consumes most area/power?
2. **Verify hierarchy:** Are submodules synthesized correctly?
3. **Check reuse:** Do identical modules have similar metrics?

### For Optimization
1. **Target largest modules** for area/power reduction
2. **Verify synthesis decisions** at module level
3. **Compare against specifications** module by module

### For Lab Reports
1. **Show hierarchy** in your design explanation
2. **Provide detailed metrics** per module
3. **Demonstrate modularity** with consistent pwm_generator sizes
4. **Justify design decisions** with quantitative data

## Genus Report Commands Reference

### Area Reports
```tcl
report_area                          # Top-level summary
report_area -depth 10                # Hierarchical (10 levels)
report_area -physical                # Physical (LEF-based) area
report_area -detail                  # Detailed breakdown
report_area -gates                   # Show all cell types
```

### Power Reports
```tcl
report_power                         # Top-level summary
report_power -depth 10               # Hierarchical (10 levels)
report_power -detail                 # Detailed per-cell breakdown
```

### Gates Reports
```tcl
report_gates                         # Top-level summary
report_gates -depth 10               # Hierarchical (10 levels)
```

## Summary

The hierarchical reports with `-depth 10` allow you to:

✅ See **exact area/power/gates per submodule**  
✅ Verify **timer_module and 3× pwm_generator** are synthesized correctly  
✅ Confirm **pwm_generator reuse** (all 3 should be similar size)  
✅ Identify **optimization opportunities** at module level  
✅ Provide **detailed analysis** in lab reports  

This level of detail is essential for understanding how your hierarchical design is implemented in gates and how each module contributes to the overall chip.
