#==============================================================================
# PWM Controller DFT (Scan Test) Insertion Script
# Based on EN4603 Lab 2 Instructions
# Run in Genus: cd work && genus -f ../scripts/dft_insertion_pwm.tcl
#==============================================================================

# Step 1: Start Genus (done externally)
# Command: cd work && genus -f ../scripts/dft_insertion_pwm.tcl

# Step 2: Set library search paths and load technology libraries
puts "Step 2: Setting up library paths and technology files..."
set_db init_lib_search_path {../input/libs/gsclib045/lef ../input/libs/gsclib045/timing ../input/libs/gsclib045/qrc/qx}
set_db library {slow_vdd1v0_basicCells.lib fast_vdd1v0_basicCells.lib}
set_db lef_library {gsclib045_tech.lef gsclib045_macro.lef gsclib045_multibitsDFF.lef}
set_db qrc_tech_file gpdk045.tch

# Step 3: Read RTL design files
puts "Step 3: Reading RTL design files..."
read_hdl [glob ../input/rtl/*.v]

# Step 4: Elaborate the design
puts "Step 4: Elaborating pwm_controller..."
elaborate pwm_controller

# Step 5: Uniquify the top module
puts "Step 5: Uniquifying pwm_controller..."
uniquify pwm_controller

# Step 6: Set timing constraints
puts "Step 6: Applying timing constraints..."
source ../input/constraints_pwm.tcl

# Step 7: Set DFT scan style
puts "Step 7: Setting DFT scan style to muxed_scan..."
set_db dft_scan_style muxed_scan

# Step 8: Set prefix for DFT-generated modules/ports
puts "Step 8: Setting DFT prefix to 'dft_'..."
set_db dft_prefix dft_

# Step 9: Define shift_enable signal
puts "Step 9: Defining shift_enable signal (SE)..."
define_shift_enable -name SE -active high -create_port SE

# Step 10: Run DFT rule checker
puts "Step 10: Running DFT rule checker..."
check_dft_rules

# Create base directories
exec mkdir -p ../output
exec mkdir -p ../report
exec mkdir -p ../log

# Step 11: Synthesize design (replace non-scannable FFs with scannable FFs)
puts "Step 11: Synthesizing to generic logic and mapping to technology library..."
# Synthesize to generic logic with medium effort
set_db syn_generic_effort medium
syn_generic

# Map to technology library and re-synthesize with medium effort
set_db syn_map_effort medium
syn_map

# Step 12: Write scan synthesized netlist
puts "Step 12: Writing scan synthesized netlist..."
write_hdl > ../output/pwm_controller_1.v

# Step 13: Generate reports after scan synthesis
puts "Step 13: Generating reports after scan synthesis..."
exec mkdir -p ../report/after_scan_synthesis
report_area > ../report/after_scan_synthesis/area.log
report_timing -nworst 10 > ../report/after_scan_synthesis/timing.log
report_port * > ../report/after_scan_synthesis/ports.log
report_power > ../report/after_scan_synthesis/power.log

# Step 14: Set scan configuration (define scan chains)
puts "Step 14: Defining scan chain configuration..."
# PWM controller has single clock domain, so we need one scan chain
define_scan_chain -name pwm_chain \
    -sdi scan_in \
    -sdo scan_out \
    -non_shared_output \
    -create_ports \
    -domain clk

# Step 15: Preview scan chains
puts "Step 15: Previewing scan chains..."
connect_scan_chains -preview -auto_create_chains

# Step 16: Connect scan chains (scan stitching)
puts "Step 16: Connecting scan chains (scan stitching)..."
connect_scan_chains -auto_create_chains

# Step 17: Perform incremental synthesis
puts "Step 17: Performing incremental synthesis..."
syn_opt -incr

# Step 18: Perform DFT rule check after scan connecting
puts "Step 18: Running DFT rule check after scan connect..."
check_dft_rules

# Step 19: Report scan setup and scan chain information
puts "Step 19: Generating scan setup and chain reports..."
report_scan_setup > ../report/scan_setup.log
report_scan_chains > ../report/scan_chains.log

# Step 20: Write DFT (scan test) inserted netlist and constraints
puts "Step 20: Writing DFT inserted netlist and constraints..."
write_hdl > ../output/pwm_controller_2.v
write_sdc > ../output/pwm_controller_2.sdc

# Step 21: Write scanDEF file
puts "Step 21: Writing scanDEF file for Place&Route..."
write_scandef > ../output/pwm_controller_2_scanDEF.scandef

# Step 22: Generate reports after scan connect
puts "Step 22: Generating reports after scan connect..."
exec mkdir -p ../report/after_scan_connect
report_area > ../report/after_scan_connect/area.log
report_timing -nworst 10 > ../report/after_scan_connect/timing.log
report_port * > ../report/after_scan_connect/ports.log
report_power > ../report/after_scan_connect/power.log

# Step 23: Write scripts required for ATPG tool
puts "Step 23: Writing ATPG scripts for Cadence Modus..."
write_dft_atpg -library ../input/libs/gsclib045/timing/slow_vdd1v0_basicCells.lib

puts "\n=========================================="
puts "PWM Controller DFT Insertion Complete!"
puts "=========================================="
puts "Scan synthesized:  ../output/pwm_controller_1.v"
puts "DFT inserted:      ../output/pwm_controller_2.v"
puts "SDC:               ../output/pwm_controller_2.sdc"
puts "ScanDEF:           ../output/pwm_controller_2_scanDEF.scandef"
puts "Reports:           ../report/after_scan_synthesis/"
puts "                   ../report/after_scan_connect/"
puts "                   ../report/scan_setup.log"
puts "                   ../report/scan_chains.log"
puts "=========================================="

exit
