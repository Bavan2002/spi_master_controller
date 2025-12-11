#==============================================================================
# PWM Controller Synthesis Script
# Based on EN4603 Lab Instructions
# Run in Genus: cd work && genus -f ../scripts/synthesis_pwm.tcl
#==============================================================================

# Step 1: Start Genus (done externally)
# Command: cd work && genus -f ../scripts/synthesis_pwm.tcl

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

# Step 5: Check design
puts "Step 5: Checking design integrity..."
check_design > ../log/checkdesign_pwm.log

# Step 6: Uniquify the design
puts "Step 6: Uniquifying design..."
uniquify pwm_controller

# Step 7: Apply timing constraints
puts "Step 7: Applying timing constraints..."
source ../input/constraints_pwm.tcl

# Step 8: Synthesize the design
puts "Step 8: Running synthesis (generic -> map -> optimize)..."
set_db syn_generic_effort medium
syn_generic

set_db syn_map_effort medium
syn_map

set_db syn_opt_effort medium
syn_opt

# Step 9: Write netlist and constraints
puts "Step 9: Writing netlist and SDC files..."
exec mkdir -p ../output
exec mkdir -p ../report
exec mkdir -p ../log
write -mapped > ../output/pwm_controller.v
write_sdc > ../output/pwm_controller.sdc

# Step 10: Generate reports
puts "Step 10: Generating synthesis reports..."

# Basic reports (as per lab instructions)
report_area > ../report/pwm_area.log
report_timing -nworst 10 > ../report/pwm_timing.log
report_port * > ../report/pwm_ports.log
report_power > ../report/pwm_power.log
report_gates > ../report/pwm_gates.log

# Additional hierarchical reports for detailed analysis
report_area -depth 10 > ../report/pwm_area_hierarchy.log
report_power -depth 10 > ../report/pwm_power_hierarchy.log

# Step 11: Optional GUI (uncomment to launch)
# gui_show

puts "\n=========================================="
puts "PWM Controller Synthesis Complete!"
puts "=========================================="
puts "Netlist:  ../output/pwm_controller.v"
puts "SDC:      ../output/pwm_controller.sdc"
puts "Reports:  ../report/pwm_*.log"
puts "=========================================="

gui_show
