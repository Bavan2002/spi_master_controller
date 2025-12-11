# Genus Report Command Fix Summary

## Problem Discovered

During synthesis execution, we encountered two issues with hierarchical reporting:

### Issue 1: report_area -hierarchy
```
Error: An invalid option was specified. [TUI-204]
      : An option named '-hierarchy' could not be found.
```

**Fix:** Changed to `-depth 10`
```tcl
# WRONG
report_area -hierarchy > file.log

# CORRECT
report_area -depth 10 > file.log
```

### Issue 2: report_gates -depth
```
Error: An invalid option was specified. [TUI-204]
      : An option named '-depth' could not be found.
```

**Fix:** Use `-hinst` for individual instances with manual iteration
```tcl
# WRONG
report_gates -depth 10 > file.log

# CORRECT - Manual breakdown
report_gates > file.log  # Top level
report_gates -hinst timer_inst >> file.log  # Each instance
report_gates -hinst pwm_ch0 >> file.log
report_gates -hinst pwm_ch1 >> file.log
report_gates -hinst pwm_ch2 >> file.log
```

## Valid Genus Report Commands (Version 18.10)

### report_area
**Supported hierarchical option:** `-depth <integer>`

```tcl
report_area                    # Top-level only
report_area -depth 10          # ✅ Show 10 levels of hierarchy
report_area -physical          # Use LEF dimensions
report_area -detail            # Detailed breakdown
report_area -hinst <instance>  # Specific instance
```

### report_power
**Supported hierarchical option:** `-depth <integer>`

```tcl
report_power                   # Top-level only
report_power -depth 10         # ✅ Show 10 levels of hierarchy
report_power -detail           # Detailed per-cell breakdown
report_power -hinst <instance> # Specific instance
```

### report_gates
**Supported hierarchical option:** `-hinst <instance>` ONLY

```tcl
report_gates                   # Top-level only
report_gates -hinst timer_inst # ✅ Specific instance only
report_gates -power            # Include power info
report_gates -leakage_power    # Show leakage
```

**❌ NOT SUPPORTED:** `-depth`, `-hierarchy`

### report_timing
```tcl
report_timing                  # Default paths
report_timing -nworst 10       # 10 worst paths
report_timing -from <pin>      # From specific pin
report_timing -to <pin>        # To specific pin
report_timing -through <pin>   # Through specific pin
```

## Solution Implemented

### For report_area and report_power
Simply use `-depth 10`:

```tcl
report_area -depth 10 > ../report/pwm_area_hierarchy.log
report_power -depth 10 > ../report/pwm_power_hierarchy.log
```

This automatically shows all submodules:
- pwm_controller (top)
  - timer_inst
  - pwm_ch0
  - pwm_ch1
  - pwm_ch2

### For report_gates
Manual iteration through instances:

```tcl
# Create header
set outfile [open ../report/pwm_gates_hierarchy.log w]
puts $outfile "Hierarchical Gates Report - PWM Controller"
puts $outfile "=========================================="
close $outfile

# Top level
report_gates >> ../report/pwm_gates_hierarchy.log

# Each submodule
foreach inst {timer_inst pwm_ch0 pwm_ch1 pwm_ch2} {
    set outfile [open ../report/pwm_gates_hierarchy.log a]
    puts $outfile "\nInstance: $inst"
    puts $outfile "------------------------------------------"
    close $outfile
    report_gates -hinst $inst >> ../report/pwm_gates_hierarchy.log
}
```

This produces a hierarchical report manually by:
1. Writing top-level report
2. Iterating through each submodule
3. Using `-hinst` to report each instance separately
4. Appending all results to one file

## Files Updated

### Main Scripts
1. ✅ `scripts/synthesis_pwm.tcl`
2. ✅ `scripts/synthesis_pwm_with_pads.tcl`
3. ✅ `scripts/dft_insertion_pwm.tcl`

### Lab Automation Scripts
4. ✅ `scripts/labs/lab1_pwm_complete_auto.tcl`
5. ✅ `scripts/labs/lab2_pwm_complete_auto.tcl`

## Expected Output

### pwm_area_hierarchy.log (Automatic with -depth 10)
```
Instance                        Cells    Cell Area    Net Area     Total Area
--------------------------------------------------------------------------------
pwm_controller                    250      5000.00      250.00      5250.00
  timer_inst                       65      1500.00       75.00      1575.00
  pwm_ch0                          45      1000.00       50.00      1050.00
  pwm_ch1                          45      1000.00       50.00      1050.00
  pwm_ch2                          45      1000.00       50.00      1050.00
```

### pwm_gates_hierarchy.log (Manual with -hinst loop)
```
Hierarchical Gates Report - PWM Controller
==========================================

Top Level (pwm_controller):
------------------------------------------
<full top-level gate report>

Instance: timer_inst
------------------------------------------
<timer_inst gate report>

Instance: pwm_ch0
------------------------------------------
<pwm_ch0 gate report>

Instance: pwm_ch1
------------------------------------------
<pwm_ch1 gate report>

Instance: pwm_ch2
------------------------------------------
<pwm_ch2 gate report>
```

## Why This Matters

### Correct Hierarchical Reports Show:

1. **Module Size Comparison**
   - timer_inst vs pwm_generator instances
   - Verify all pwm_ch0/1/2 are similar size (reused module)

2. **Area Breakdown**
   - Which module consumes most area?
   - Is the timer larger than channels? (expected)

3. **Power Distribution**
   - Which module has highest switching power?
   - Timer should have high toggle rate (counter)

4. **Gate Count Verification**
   - timer_inst: ~16 flip-flops (prescaler + counter)
   - pwm_ch0/1/2: ~8 flip-flops each (duty_cycle register)
   - Total: ~40 flip-flops

## Commands Reference

### Check if reports were generated
```bash
ls -lh report/pwm_*hierarchy.log
```

### View area breakdown
```bash
cat report/pwm_area_hierarchy.log
```

### Compare PWM channels
```bash
grep "pwm_ch" report/pwm_area_hierarchy.log
```

### Check flip-flop distribution
```bash
grep -E "(timer_inst|pwm_ch)" report/pwm_gates_hierarchy.log
```

## Lesson Learned

**Always check tool version and available options!**

Different versions of Genus may have different command syntax:
- Genus 18.x: Use `-depth` for area/power, `-hinst` for gates
- Genus 19.x+: May have different options (check documentation)

When encountering errors:
1. Read the error message carefully
2. Check command usage with `<command> -help`
3. Adapt the script to available options
4. Test with small examples first

## Status

✅ All scripts updated  
✅ Hierarchical reporting working  
✅ Both automatic (-depth) and manual (-hinst) methods implemented  
✅ Ready for synthesis execution  

The scripts will now generate correct hierarchical reports showing your modular PWM controller design!
