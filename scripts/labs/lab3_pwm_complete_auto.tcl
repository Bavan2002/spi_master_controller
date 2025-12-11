#==============================================================================
# LAB 3 COMPLETE - PWM Controller Place & Route with Exercises
# Run in Innovus: source lab3_pwm_complete_auto.tcl
#==============================================================================

puts "=========================================================================="
puts "LAB 3: PWM CONTROLLER PLACE & ROUTE - AUTOMATED EXECUTION"
puts "=========================================================================="
puts "Start Time: [clock format [clock seconds]]"
puts ""

#------------------------------------------------------------------------------
# PART 1: Baseline P&R with Pre-Place Optimization
#------------------------------------------------------------------------------
puts ">>> Importing design..."
set init_verilog ../output/part1/pwm_controller_dft.v
set init_top_cell pwm_controller
set init_lef_file {../input/libs/gsclib045/lef/gsclib045_tech.lef \
                   ../input/libs/gsclib045/lef/gsclib045_multibitsDFF.lef \
                   ../input/libs/gsclib045/lef/gsclib045_macro.lef}
set init_pwr_net VDD
set init_gnd_net VSS
set init_mmmc_file ../input/pwm_controller.view
init_design

puts ">>> Reading scanDEF..."
defIn ../output/part1/pwm_controller_dft.scandef

puts ">>> Setting design mode..."
setDesignMode -process 45

puts ">>> Creating floorplan..."
floorPlan -site CoreSite -r 1.0 -coreUtilization 0.3 -coreSpacing 5 5 5 5

puts ">>> Adding power rings..."
addRing -nets {VDD VSS} -type core_rings \
    -layer {top Metal7 bottom Metal7 left Metal8 right Metal8} \
    -width 1.0 -spacing 0.8 -offset 0.8

puts ">>> Adding power stripes..."
addStripe -nets {VDD VSS} -layer Metal7 -direction horizontal \
    -width 1.0 -spacing 0.8 -number_of_sets 3
addStripe -nets {VDD VSS} -layer Metal8 -direction vertical \
    -width 1.0 -spacing 0.8 -number_of_sets 3

puts ">>> Placing IO pins..."
editPin -side Top -spreadType center -spacing 5 -pin {clk reset SE}
editPin -side Left -spreadType center -spacing 5 -pin {period* prescaler* timer_enable}
editPin -side Bottom -spreadType center -spacing 5 -pin {ch0_* ch1_* scan_in}
editPin -side Right -spreadType center -spacing 5 -pin {ch2_* pwm_out_* period_complete timer_overflow scan_out}

puts ">>> Saving pre-placement state..."
exec mkdir -p ../output/part1_with_preopt
saveDesign ../output/part1_prePlacement.enc

puts ">>> Placing standard cells (WITH pre-place opt)..."
placeDesign -prePlaceOpt

exec mkdir -p ../report/part1_with_preopt
summaryReport -outfile ../report/part1_with_preopt/placement_summary.rpt

puts ">>> Pre-CTS timing analysis..."
exec mkdir -p ../report/part1_preCTS
timeDesign -preCTS -outDir ../report/part1_preCTS

puts ">>> Routing power..."
sroute -nets {VDD VSS}

puts ">>> Clock Tree Synthesis..."
ccopt_design

puts ">>> Scan reordering..."
ecoScanReorder -clockTreeAware

puts ">>> Post-CTS timing analysis..."
exec mkdir -p ../report/part1_postCTS
timeDesign -postCTS -hold -outDir ../report/part1_postCTS

puts ">>> Signal routing..."
routeDesign

puts ">>> Post-route timing analysis..."
setAnalysisMode -analysisType onChipVariation
exec mkdir -p ../report/part1_postRoute
timeDesign -postRoute -outDir ../report/part1_postRoute

puts ">>> Placing filler cells..."
addFiller -cell {FILL*} -prefix FILLER

puts ">>> Verification..."
verifyGeometry -report ../report/part1_verify_geometry.rpt
verifyConnectivity -report ../report/part1_verify_connectivity.rpt

puts ">>> Exporting GDSII..."
streamOut ../output/part1_with_preopt/pwm_controller.gds \
    -mapFile ../input/streamOut.map -libName pwmlib -mode ALL

saveDesign ../output/part1_with_preopt/final_design.enc

#------------------------------------------------------------------------------
# EXERCISE 1: Without Pre-Place Optimization
#------------------------------------------------------------------------------
puts "\n=========================================================================="
puts "EXERCISE 1: Without Pre-Place Optimization"
puts "=========================================================================="

restoreDesign ../output/part1_prePlacement.enc.dat pwm_controller
placeDesign

exec mkdir -p ../output/exercise1_without_preopt
exec mkdir -p ../report/exercise1_without_preopt
summaryReport -outfile ../report/exercise1_without_preopt/placement_summary.rpt

sroute -nets {VDD VSS}
ccopt_design
routeDesign
addFiller -cell {FILL*} -prefix FILLER

saveDesign ../output/exercise1_without_preopt/final_design.enc
streamOut ../output/exercise1_without_preopt/pwm_controller.gds \
    -mapFile ../input/streamOut.map -libName pwmlib -mode ALL

#------------------------------------------------------------------------------
# EXERCISE 3: With IO Area
#------------------------------------------------------------------------------
puts "\n=========================================================================="
puts "EXERCISE 3: Floorplan with IO Area"
puts "=========================================================================="

init_design
defIn ../output/part1/pwm_controller_dft.scandef
setDesignMode -process 45

puts ">>> Creating floorplan with IO area (150um margin)..."
floorPlan -site CoreSite -r 1.0 -coreUtilization 0.3 \
    -coreMargins 150 150 150 150 -coreMarginsBy io

addRing -nets {VDD VSS} -type core_rings \
    -layer {top Metal7 bottom Metal7 left Metal8 right Metal8} \
    -width 2.0 -spacing 1.0 -offset 1.0

addStripe -nets {VDD VSS} -layer Metal7 -direction horizontal \
    -width 1.0 -spacing 0.8 -number_of_sets 3
addStripe -nets {VDD VSS} -layer Metal8 -direction vertical \
    -width 1.0 -spacing 0.8 -number_of_sets 3

editPin -side Top -spreadType center -spacing 5 -pin {clk reset SE}
editPin -side Left -spreadType center -spacing 5 -pin {period* prescaler* timer_enable}
editPin -side Bottom -spreadType center -spacing 5 -pin {ch0_* ch1_* scan_in}
editPin -side Right -spreadType center -spacing 5 -pin {ch2_* pwm_out_* period_complete timer_overflow scan_out}

placeDesign -prePlaceOpt
sroute -nets {VDD VSS}
ccopt_design
routeDesign
addFiller -cell {FILL*} -prefix FILLER

exec mkdir -p ../output/exercise3_with_io
exec mkdir -p ../report/exercise3_with_io
verifyGeometry -report ../report/exercise3_with_io/verify_geometry.rpt
verifyConnectivity -report ../report/exercise3_with_io/verify_connectivity.rpt

saveDesign ../output/exercise3_with_io/final_design.enc
streamOut ../output/exercise3_with_io/pwm_controller.gds \
    -mapFile ../input/streamOut.map -libName pwmlib -mode ALL

puts "\n>>> LAB 3 COMPLETED!"
puts "All GDSII files generated in ../output/"
puts "=========================================================================="
