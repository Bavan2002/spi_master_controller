#==============================================================================
# Synthesis Script for PWM Controller with IO Pads - Lab 3
#==============================================================================

puts "=========================================="
puts "PWM Controller Synthesis with IO Pads"
puts "=========================================="

source ../scripts/setup_pwm.tcl

puts "\n[1] Reading RTL files..."
read_hdl ../input/rtl/timer_module.v
read_hdl ../input/rtl/pwm_generator.v
read_hdl ../input/rtl/pwm_controller.v
read_hdl ../input/rtl/pwm_controller_chip.v

puts "\n[2] Elaborating pwm_controller_chip (wrapper with IO pads)..."
elaborate pwm_controller_chip

puts "\n[3] Checking design..."
check_design > ../log/checkdesign_pwm_pads.log

puts "\n[4] Applying constraints..."
source ../input/constraints_pwm.tcl

puts "\n[5] Running synthesis..."
set_db syn_generic_effort medium
syn_generic
set_db syn_map_effort medium
syn_map

puts "\n[6] Running optimization..."
set_db syn_opt_effort medium
syn_opt

puts "\n[7] Writing outputs..."
write_hdl > ../output/pwm_controller_chip.v
write_sdc > ../output/pwm_controller_chip.sdc

puts "\n[8] Generating reports..."
report_area > ../report/pwm_pads_area.log
report_area -depth 10 > ../report/pwm_pads_area_hierarchy.log
report_timing -nworst 10 > ../report/pwm_pads_timing.log
report_power > ../report/pwm_pads_power.log
report_power -depth 10 > ../report/pwm_pads_power_hierarchy.log
report_gates > ../report/pwm_pads_gates.log

# Gates report (top-level only - hierarchy may be flattened)
puts "\n\[8a\] Gates report generated"
puts "  For hierarchical breakdown, see area/power hierarchy reports"

puts "\n\[9\] All reports generated"
puts "  Area breakdown: ../report/pwm_pads_area_hierarchy.log"
puts "  Power breakdown: ../report/pwm_pads_power_hierarchy.log"
puts "  Gates report:   ../report/pwm_pads_gates.log"

puts "\n=========================================="
puts "PWM Controller Synthesis with Pads completed!"
puts "=========================================="
exit
