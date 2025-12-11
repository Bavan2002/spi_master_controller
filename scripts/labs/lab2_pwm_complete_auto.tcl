#==============================================================================
# LAB 2 COMPLETE - PWM Controller DFT Insertion with Exercises
# Run: genus -f lab2_pwm_complete_auto.tcl | tee ../log/lab2_pwm_execution.log
#==============================================================================

puts "=========================================================================="
puts "LAB 2: PWM CONTROLLER DFT INSERTION - AUTOMATED EXECUTION"
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

puts ">>> Reading RTL design..."
read_hdl ../input/rtl/timer_module.v
read_hdl ../input/rtl/pwm_generator.v
read_hdl ../input/rtl/pwm_controller.v
elaborate pwm_controller
uniquify pwm_controller
source ../input/constraints_pwm.tcl

#------------------------------------------------------------------------------
# DFT INSERTION - SINGLE CHAIN
#------------------------------------------------------------------------------
puts "\n>>> Configuring DFT..."
set_db dft_scan_style muxed_scan
set_db dft_prefix dft_
define_shift_enable -name SE -active high -create_port SE

puts ">>> Running DFT rule checker..."
check_dft_rules > ../log/dft_check_pre.log

puts ">>> Synthesizing with scan..."
syn_generic
syn_map

exec mkdir -p ../output/part1
exec mkdir -p ../report/part1_afterscan_synthesis
write_hdl > ../output/part1/pwm_controller_scan.v
report_area > ../report/part1_afterscan_synthesis/area.log
report_gates > ../report/part1_afterscan_synthesis/gates.log
report_port > ../report/part1_afterscan_synthesis/ports.log

puts ">>> Defining scan chain..."
define_scan_chain -name pwm_chain \
    -sdi scan_in \
    -sdo scan_out \
    -non_shared_output \
    -create_ports \
    -domain clk

puts ">>> Connecting scan chains..."
connect_scan_chains -preview -auto_create_chains > ../log/scan_preview.log
connect_scan_chains -auto_create_chains

puts ">>> Incremental optimization..."
syn_opt -incr

puts ">>> Post-scan checking..."
check_dft_rules > ../log/dft_check_post.log

exec mkdir -p ../report/part1_afterscan_connect
report_scan_setup > ../report/part1_scan_setup.log
report_scan_chains > ../report/part1_scan_chains.log
report_area > ../report/part1_afterscan_connect/area.log
report_port > ../report/part1_afterscan_connect/ports.log

write_hdl > ../output/part1/pwm_controller_dft.v
write_sdc > ../output/part1/pwm_controller_dft.sdc
write_scandef > ../output/part1/pwm_controller_dft.scandef

puts ">>> Writing ATPG files..."
write_dft_atpg -library ../input/libs/gsclib045/timing/slow_vdd1v0_basicCells.lib

#------------------------------------------------------------------------------
# EXERCISE: Multiple Scan Chains (2 chains)
#------------------------------------------------------------------------------
puts "\n=========================================================================="
puts "EXERCISE: Multiple Scan Chains (2 Chains)"
puts "=========================================================================="

delete_obj [get_db designs]
read_hdl ../input/rtl/timer_module.v
read_hdl ../input/rtl/pwm_generator.v
read_hdl ../input/rtl/pwm_controller.v
elaborate pwm_controller
uniquify pwm_controller
source ../input/constraints_pwm.tcl

set_db dft_scan_style muxed_scan
set_db dft_prefix dft_
define_shift_enable -name SE -active high -create_port SE

syn_generic
syn_map

puts ">>> Defining 2 scan chains..."
define_scan_chain -name pwm_chain_a \
    -sdi scan_in_a -sdo scan_out_a \
    -non_shared_output -create_ports \
    -domain clk -max_length 100

define_scan_chain -name pwm_chain_b \
    -sdi scan_in_b -sdo scan_out_b \
    -non_shared_output -create_ports \
    -domain clk -max_length 100

connect_scan_chains -auto_create_chains
syn_opt -incr

exec mkdir -p ../output/exercise_2chains
exec mkdir -p ../report/exercise_2chains
report_scan_chains > ../report/exercise_2chains/scan_chains.log
report_area > ../report/exercise_2chains/area.log
write_hdl > ../output/exercise_2chains/pwm_controller_dft_2chains.v
write_scandef > ../output/exercise_2chains/pwm_controller_dft_2chains.scandef

puts "\n>>> LAB 2 COMPLETED!"
puts "=========================================================================="
exit
