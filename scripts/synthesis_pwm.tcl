#==============================================================================
# Synthesis Script for PWM Controller
# Run this script in Genus: genus -f synthesis_pwm.tcl
#==============================================================================

puts "=========================================="
puts "PWM Controller Synthesis"
puts "=========================================="

# 1. Setup libraries
source ../scripts/setup_pwm.tcl

# 2. Read RTL design
puts "\n[1] Reading RTL files..."
read_hdl ../input/rtl/timer_module.v
read_hdl ../input/rtl/pwm_generator.v
read_hdl ../input/rtl/pwm_controller.v

# 3. Elaborate the design
puts "\n[2] Elaborating pwm_controller..."
elaborate pwm_controller

# 4. Check design
puts "\n[3] Checking design..."
check_design > ../log/checkdesign_pwm.log

# 5. Apply constraints
puts "\n[4] Applying constraints..."
source ../input/constraints_pwm.tcl

# 6. Synthesize
puts "\n[5] Running synthesis..."
set_db syn_generic_effort medium
syn_generic

set_db syn_map_effort medium
syn_map

# 7. Optimize
puts "\n[6] Running optimization..."
set_db syn_opt_effort medium
syn_opt

# 8. Write outputs
puts "\n[7] Writing outputs..."
write_hdl > ../output/pwm_controller.v
write_sdc > ../output/pwm_controller.sdc

# 9. Generate reports
puts "\n[8] Generating reports..."
report_area > ../report/pwm_area.log
report_timing -nworst 10 > ../report/pwm_timing.log
report_power > ../report/pwm_power.log
report_gates > ../report/pwm_gates.log

# 10. Summary
puts "\n=========================================="
puts "PWM Controller Synthesis completed!"
puts "=========================================="
puts "Output files:"
puts "  Netlist: ../output/pwm_controller.v"
puts "  SDC:     ../output/pwm_controller.sdc"
puts "Reports:"
puts "  Area:    ../report/pwm_area.log"
puts "  Timing:  ../report/pwm_timing.log"
puts "  Power:   ../report/pwm_power.log"
puts "  Gates:   ../report/pwm_gates.log"
puts "=========================================="

exit
