# PWM Controller - Manual Synthesis Guide (Genus Interactive Mode)

## Overview
This guide walks through synthesis of the PWM controller using Genus in interactive mode, following the standard lab procedure.

---

## Step-by-Step Interactive Synthesis

### Step 1: Navigate to Working Directory
```bash
cd /home/akitha/Desktop/spi_master_controller/work
```

### Step 2: Start Genus
```bash
genus
```
Your prompt will change to `genus:>`

---

## In Genus Interactive Mode

### Step 3: Set Library Search Paths
```tcl
genus:1> set_db init_lib_search_path [list ../input/libs/gsclib045/lef ../input/libs/gsclib045/timing ../input/libs/gsclib045/qrc/qx]
```

### Step 4: Load Timing Libraries
```tcl
genus:2> set_db library {slow_vdd1v0_basicCells.lib fast_vdd1v0_basicCells.lib}
```

**Note:** You'll see warnings about inconsistent operating conditions - this is normal for educational libraries.

### Step 5: Load LEF Files
```tcl
genus:3> set_db lef_library {gsclib045_tech.lef gsclib045_macro.lef gsclib045_multibitsDFF.lef}
```

### Step 6: Load QRC Technology File
```tcl
genus:4> set_db qrc_tech_file gpdk045.tch
```

### Step 7: Read RTL Design Files

**Option A: Read all Verilog files at once**
```tcl
genus:5> read_hdl [glob ../input/rtl/*.v]
```

**Option B: Read files individually (preferred for seeing hierarchy)**
```tcl
genus:5> read_hdl ../input/rtl/timer_module.v
genus:6> read_hdl ../input/rtl/pwm_generator.v
genus:7> read_hdl ../input/rtl/pwm_controller.v
```

### Step 8: Elaborate the Design
```tcl
genus:8> elaborate pwm_controller
```

**What happens:**
- Tool reads through design
- Reports syntax errors (if any)
- Creates design hierarchy
- Applies parameters
- Connects signals

**Expected output:**
```
Elaborating design: pwm_controller
  Reading module: timer_module
  Reading module: pwm_generator
  Instantiating module: timer_inst (timer_module)
  Instantiating module: pwm_ch0 (pwm_generator)
  Instantiating module: pwm_ch1 (pwm_generator)
  Instantiating module: pwm_ch2 (pwm_generator)
```

### Step 9: Check Design
```tcl
genus:9> check_design > ../log/check_design.log
```

**What it checks:**
- Undriven pins
- Unloaded ports
- Unresolved references
- Empty modules
- Syntax errors

**View the log (in another terminal):**
```bash
vim ../log/check_design.log
# or
cat ../log/check_design.log
```

### Step 10: Uniquify the Design
```tcl
genus:10> uniquify pwm_controller
```

**What it does:**
- Eliminates sharing of subdesigns between instances
- Creates unique copies of instantiated modules
- Prevents optimization issues

### Step 11: Apply Timing Constraints

**First, view the constraints (in another terminal):**
```bash
vim ../input/constraints_pwm.tcl
# Press [esc] :q [enter] to quit
```

**Then source the constraints in Genus:**
```tcl
genus:11> source ../input/constraints_pwm.tcl
```

**What's in constraints_pwm.tcl:**
- Clock period: 20ns (50MHz)
- Clock uncertainty: 0.5ns
- Input delays: 5ns
- Output delays: 5ns
- False paths (reset)
- Load capacitance: 0.5pF

### Step 12: Synthesize the Design

**Generic + Mapping + Optimization:**
```tcl
genus:12> syn_generic
genus:13> syn_map
genus:14> syn_opt
```

**Or use single command (older style):**
```tcl
genus:12> synthesize -to_mapped -effort medium
```

**What happens:**
- **syn_generic:** RTL → generic gates (AND, OR, NOT, FF)
- **syn_map:** Generic gates → technology cells (NAND2X1, DFF...)
- **syn_opt:** Optimize for area, timing, power

**Synthesis will take ~1-2 minutes. Watch for:**
- Area reduction messages
- Timing optimization
- Gate count changes

### Step 13: Write Outputs

**Write mapped netlist:**
```tcl
genus:15> write_hdl > ../output/pwm_controller.v
```

**Write SDC constraints:**
```tcl
genus:16> write_sdc > ../output/pwm_controller.sdc
```

**View outputs (in another terminal):**
```bash
vim ../output/pwm_controller.v
vim ../output/pwm_controller.sdc
```

The netlist will show your behavioral RTL mapped to standard cells like:
- `DFFRHQX1` - D flip-flops
- `NAND2X1` - 2-input NAND gates
- `INVX1` - Inverters
- `ADDFHX1` - Adders
- etc.

### Step 14: Generate Reports

**Create report directory:**
```tcl
genus:17> exec mkdir -p ../report
```

**Area report:**
```tcl
genus:18> report_area > ../report/pwm_area.log
```

**Hierarchical area report:**
```tcl
genus:19> report_area -depth 10 > ../report/pwm_area_hierarchy.log
```

**Timing report (10 worst paths):**
```tcl
genus:20> report_timing -nworst 10 > ../report/pwm_timing.log
```

**Power report:**
```tcl
genus:21> report_power > ../report/pwm_power.log
```

**Hierarchical power report:**
```tcl
genus:22> report_power -depth 10 > ../report/pwm_power_hierarchy.log
```

**Gates report:**
```tcl
genus:23> report_gates > ../report/pwm_gates.log
```

**Ports report:**
```tcl
genus:24> report_port * > ../report/pwm_ports.log
```

**Quality of Results (QoR) summary:**
```tcl
genus:25> report_qor > ../report/pwm_qor.log
```

### Step 15: View Reports

**In another terminal:**
```bash
cd /home/akitha/Desktop/spi_master_controller/report

# View area
vim pwm_area.log
# or
cat pwm_area.log | grep -A 10 "Instance"

# View timing
vim pwm_timing.log
# or
cat pwm_timing.log | grep -E "(slack|WNS|TNS)"

# View power
vim pwm_power.log

# View QoR summary
vim pwm_qor.log
```

### Step 16: View Design in GUI

**Start GUI:**
```tcl
genus:26> gui_show
```

**In the GUI:**
1. **Left panel (Hierarchy):** Shows pwm_controller → timer_inst, pwm_ch0/1/2
2. **Right-click on any module** → "Schematic View" → "New"
3. **View menu:**
   - Reports → Area
   - Reports → Timing
   - Reports → Power
4. **Zoom:** Scroll wheel or View menu
5. **Close schematic:** File → Close

**Useful GUI views:**
- Schematic of timer_module
- Schematic of pwm_generator (should all look similar)
- Critical path highlighting (Tools → Timing → Show Critical Paths)

### Step 17: Exit Genus

```tcl
genus:27> exit
```

Or press `Ctrl+D`

---

## Expected Results

### Area Report (pwm_area.log)
```
Total Area: ~4000-6000 um²
  timer_inst: ~1500 um² (25-30%)
  pwm_ch0: ~1000 um² (15-20%)
  pwm_ch1: ~1000 um² (15-20%)
  pwm_ch2: ~1000 um² (15-20%)
```

### Timing Report (pwm_timing.log)
```
Clock period: 20.0 ns (50 MHz)
Worst Negative Slack (WNS): > 0 ns (MET)
Total Negative Slack (TNS): 0.0 ns (MET)
```

### Power Report (pwm_power.log)
```
Total Power: ~1-3 mW
  Internal: ~0.5-1.5 mW
  Switching: ~0.3-0.8 mW
  Leakage: ~0.01-0.05 mW
```

### Gates Report (pwm_gates.log)
```
Total Gates: ~200-400
  Sequential: ~40 (flip-flops)
  Combinational: ~160-360
```

---

## Quick Command Sequence (Copy-Paste)

For quick synthesis, copy this entire block into Genus:

```tcl
# Setup
set_db init_lib_search_path [list ../input/libs/gsclib045/lef ../input/libs/gsclib045/timing ../input/libs/gsclib045/qrc/qx]
set_db library {slow_vdd1v0_basicCells.lib fast_vdd1v0_basicCells.lib}
set_db lef_library {gsclib045_tech.lef gsclib045_macro.lef gsclib045_multibitsDFF.lef}
set_db qrc_tech_file gpdk045.tch

# Read RTL
read_hdl ../input/rtl/timer_module.v
read_hdl ../input/rtl/pwm_generator.v
read_hdl ../input/rtl/pwm_controller.v

# Elaborate and check
elaborate pwm_controller
check_design > ../log/check_design.log
uniquify pwm_controller

# Constraints
source ../input/constraints_pwm.tcl

# Synthesize
syn_generic
syn_map
syn_opt

# Write outputs
exec mkdir -p ../output ../report
write_hdl > ../output/pwm_controller.v
write_sdc > ../output/pwm_controller.sdc

# Reports
report_area > ../report/pwm_area.log
report_area -depth 10 > ../report/pwm_area_hierarchy.log
report_timing -nworst 10 > ../report/pwm_timing.log
report_power > ../report/pwm_power.log
report_power -depth 10 > ../report/pwm_power_hierarchy.log
report_gates > ../report/pwm_gates.log
report_port * > ../report/pwm_ports.log
report_qor > ../report/pwm_qor.log

puts "Synthesis complete! Check ../report/ for results."
```

---

## Common Commands Reference

### During Synthesis

**Check current database settings:**
```tcl
get_db init_lib_search_path
get_db library
```

**List designs:**
```tcl
get_db designs
```

**List instances:**
```tcl
get_db [current_design] .hinsts
```

**Check hierarchy:**
```tcl
report_hierarchy
```

**Check timing constraints:**
```tcl
report_clocks
report_timing -lint
```

### After Synthesis

**Check for timing violations:**
```tcl
report_timing -summary
```

**Show critical paths:**
```tcl
report_timing -nworst 5 -path_type full_clock
```

**Area by module:**
```tcl
report_area -depth 10
```

**Power by module:**
```tcl
report_power -depth 10
```

---

## Troubleshooting

### Issue: Library not found
```
Error: Cannot find library file 'slow_vdd1v0_basicCells.lib'
```
**Solution:** Check that `init_lib_search_path` is set correctly

### Issue: Module not found during elaborate
```
Error: Cannot find module 'timer_module'
```
**Solution:** Ensure you read all RTL files before elaborate

### Issue: Timing violations
```
WNS: -2.5 ns (VIOLATED)
```
**Solution:** 
- Check constraints are realistic
- Increase synthesis effort: `set_db syn_opt_effort high`
- Reduce clock frequency for initial testing

### Issue: Undriven pins warning
```
Warning: Port 'xyz' is undriven
```
**Solution:** Check RTL for missing connections

---

## Automated Script vs. Interactive

**Interactive Mode (this guide):**
- ✅ Learn each synthesis step
- ✅ Inspect design at each stage
- ✅ Debug issues easily
- ✅ Experiment with different options
- ⏱️ Takes ~10-15 minutes

**Automated Script:**
```bash
cd work
genus -f ../scripts/synthesis_pwm.tcl
```
- ✅ Fast and repeatable
- ✅ Complete log file
- ✅ All reports generated
- ⏱️ Takes ~2-3 minutes

---

## What to Submit in Lab Report

1. **Check design log** - Show no critical errors
2. **Area report** - Total area and per-module breakdown
3. **Timing report** - WNS, TNS, critical path
4. **Power report** - Total power breakdown
5. **QoR report** - Overall quality metrics
6. **Schematic screenshots** - From GUI
7. **Analysis** - Compare with specifications

---

## Next Steps

After successful synthesis:
1. **Lab 2:** Add DFT (scan chains) → `genus -f ../scripts/dft_insertion_pwm.tcl`
2. **Lab 3:** Place & Route → `innovus -f ../scripts/place_route_pwm.tcl`
3. **Lab 3:** Generate GDSII for fabrication

---

**Ready to synthesize!** 🚀

Start with `genus` command and follow the steps above.
