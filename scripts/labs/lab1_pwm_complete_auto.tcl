#==============================================================================
# LAB 1 COMPLETE - PWM Controller Synthesis with Exercises
# Run: genus -f lab1_pwm_complete_auto.tcl | tee ../log/lab1_pwm_execution.log
#==============================================================================

puts "=========================================================================="
puts "LAB 1: PWM CONTROLLER SYNTHESIS - AUTOMATED EXECUTION"
puts "=========================================================================="
puts "Start Time: [clock format [clock seconds]]"
puts ""

#------------------------------------------------------------------------------
# SETUP
#------------------------------------------------------------------------------
puts ">>> Setting up libraries..."
set_db init_lib_search_path {../input/libs/gsclib045/lef ../input/libs/gsclib045/timing ../input/libs/gsclib045/qrc/qx}
set_db library {slow_vdd1v0_basicCells.lib fast_vdd1v0_basicCells.lib}
set_db lef_library {gsclib045_tech.lef gsclib045_macro.lef gsclib045_multibitsDFF.lef}
set_db qrc_tech_file gpdk045.tch

#------------------------------------------------------------------------------
# PART 1: INITIAL SYNTHESIS
#------------------------------------------------------------------------------
puts ">>> Reading RTL design..."
read_hdl ../input/rtl/timer_module.v
read_hdl ../input/rtl/pwm_generator.v
read_hdl ../input/rtl/pwm_controller.v

puts ">>> Elaborating design..."
elaborate pwm_controller

puts ">>> Checking design..."
check_design > ../log/checkdesign_initial.log

puts ">>> Uniquifying design..."
uniquify pwm_controller

puts ">>> Applying constraints (50MHz clock)..."
source ../input/constraints_pwm.tcl

puts ">>> Synthesizing design..."
set_db syn_generic_effort medium
syn_generic
syn_map
syn_opt

puts ">>> Writing outputs..."
exec mkdir -p ../output
exec mkdir -p ../report/initial
write_hdl > ../output/pwm_controller_initial.v
write_sdc > ../output/pwm_controller_initial.sdc

puts ">>> Generating reports..."
report_area > ../report/initial/area.log
report_area -depth 10 > ../report/initial/area_hierarchy.log
report_timing -nworst 10 > ../report/initial/timing.log
report_power > ../report/initial/power.log
report_power -depth 10 > ../report/initial/power_hierarchy.log
report_gates > ../report/initial/gates.log
report_gates > ../report/initial/gates_hierarchy.log
report_qor > ../report/initial/qor.log

set initial_area [join [lindex [split [exec grep -i "Total Area" ../report/initial/area.log] :] 1]]
set initial_gates [join [lindex [split [exec grep -i "Total Gates" ../report/initial/gates.log] :] 1]]
puts "\n>>> INITIAL SYNTHESIS SUMMARY:"
puts "  Area: $initial_area"
puts "  Gates: $initial_gates"

#------------------------------------------------------------------------------
# EXERCISE 1: Different Clock Frequencies
#------------------------------------------------------------------------------
puts "\n=========================================================================="
puts "EXERCISE 1: Clock Frequency Analysis"
puts "=========================================================================="

set freq_list {25 50 75 100}
foreach freq $freq_list {
    puts "\n>>> Testing $freq MHz..."
    delete_obj [get_db designs]
    read_hdl ../input/rtl/timer_module.v
    read_hdl ../input/rtl/pwm_generator.v
    read_hdl ../input/rtl/pwm_controller.v
    elaborate pwm_controller
    uniquify pwm_controller

    set period [expr 1000.0 / $freq]
    create_clock -name clk -period $period [get_ports clk]
    set_clock_uncertainty 0.5 [get_clocks clk]
    set io_delay [expr $period * 0.25]
    set_input_delay -clock clk $io_delay [all_inputs]
    set_output_delay -clock clk $io_delay [all_outputs]
    set_load 0.5 [all_outputs]
    set_false_path -from [get_ports reset]

    syn_generic
    syn_map
    syn_opt

    exec mkdir -p ../report/exercise1_${freq}MHz
    report_area > ../report/exercise1_${freq}MHz/area.log
    report_area -depth 10 > ../report/exercise1_${freq}MHz/area_hierarchy.log
    report_timing -nworst 5 > ../report/exercise1_${freq}MHz/timing.log
    report_power > ../report/exercise1_${freq}MHz/power.log
    report_power -depth 10 > ../report/exercise1_${freq}MHz/power_hierarchy.log

    puts "  $freq MHz: Check ../report/exercise1_${freq}MHz/"
}

#------------------------------------------------------------------------------
# EXERCISE 2: Different Synthesis Efforts
#------------------------------------------------------------------------------
puts "\n=========================================================================="
puts "EXERCISE 2: Synthesis Effort Comparison"
puts "=========================================================================="

set effort_list {low medium high}
foreach effort $effort_list {
    puts "\n>>> Testing $effort effort..."
    delete_obj [get_db designs]
    read_hdl ../input/rtl/timer_module.v
    read_hdl ../input/rtl/pwm_generator.v
    read_hdl ../input/rtl/pwm_controller.v
    elaborate pwm_controller
    uniquify pwm_controller
    source ../input/constraints_pwm.tcl

    set_db syn_generic_effort $effort
    set_db syn_map_effort $effort
    syn_generic
    syn_map
    syn_opt

    exec mkdir -p ../report/exercise2_${effort}_effort
    report_area > ../report/exercise2_${effort}_effort/area.log
    report_area -depth 10 > ../report/exercise2_${effort}_effort/area_hierarchy.log
    report_timing > ../report/exercise2_${effort}_effort/timing.log
    report_power > ../report/exercise2_${effort}_effort/power.log
    report_power -depth 10 > ../report/exercise2_${effort}_effort/power_hierarchy.log
}

puts "\n>>> LAB 1 COMPLETED!"
puts "=========================================================================="
exit
