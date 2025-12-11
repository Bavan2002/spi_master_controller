#==============================================================================
# Automated Place and Route Script for PWM Controller - Lab 3
# Run this script in Innovus: innovus -files place_route_pwm.tcl
#==============================================================================

puts "=========================================="
puts "PWM Controller Place and Route Flow"
puts "=========================================="

# 1. Set up library paths
set TECH_LEF "../input/libs/gsclib045/lef/gsclib045_tech.lef"
set MACRO_LEF "../input/libs/gsclib045/lef/gsclib045_macro.lef"
set MBDFF_LEF "../input/libs/gsclib045/lef/gsclib045_multibitsDFF.lef"

set TIMING_SLOW "../input/libs/gsclib045/timing/slow_vdd1v0_basicCells.lib"
set TIMING_FAST "../input/libs/gsclib045/timing/fast_vdd1v0_basicCells.lib"

# 2. Import design
puts "\n[1] Importing design..."
set init_verilog "../output/pwm_controller_dft.v"
set init_design_name "pwm_controller"
set init_top_cell "pwm_controller"
set init_lef_file "$TECH_LEF $MACRO_LEF $MBDFF_LEF"
set init_mmmc_file "../input/pwm_controller.view"
set init_pwr_net "VDD"
set init_gnd_net "VSS"

init_design

# 3. Read scanDEF
puts "\n[2] Reading scanDEF..."
defIn ../output/pwm_controller_dft.scandef

# 4. Set design mode
puts "\n[3] Setting design mode..."
setDesignMode -process 45

# 5. Floorplan
puts "\n[4] Creating floorplan..."
# Reduced utilization from 0.4 to 0.35 to allow space for hold fixing buffers
floorPlan -r 1.0 0.35 5 5 5 5

# 6. Add power rings
puts "\n[5] Adding power rings..."
addRing -nets {VDD VSS} -type core_rings -follow core \
    -layer {top Metal7 bottom Metal7 left Metal8 right Metal8} \
    -width {top 1.0 bottom 1.0 left 1.0 right 1.0} \
    -spacing {top 0.8 bottom 0.8 left 0.8 right 0.8} \
    -offset {top 0.8 bottom 0.8 left 0.8 right 0.8}

# 7. Add power stripes
puts "\n[6] Adding power stripes..."
addStripe -nets {VDD VSS} -layer Metal7 -direction horizontal \
    -width 1.0 -spacing 0.8 -set_to_set_distance 20 -start_from left

addStripe -nets {VDD VSS} -layer Metal8 -direction vertical \
    -width 1.0 -spacing 0.8 -set_to_set_distance 20 -start_from bottom

# 8. Place pins
puts "\n[7] Placing pins..."
editPin -pin * -edge 0 -spacing 5 -layer 3 -spreadType side -unit MICRON

# 9. Place standard cells with pre-place optimization
puts "\n[8] Placing standard cells (with pre-place optimization)..."
setPlaceMode -place_global_reorder_scan false
placeDesign -prePlaceOpt

# 10. Pre-CTS optimization
puts "\n[9] Pre-CTS optimization..."
setOptMode -fixCap true -fixTran true -fixFanoutLoad false
optDesign -preCTS

# 11. Route power
puts "\n[10] Routing power nets..."
sroute -connect { blockPin padPin padRing corePin floatingStripe } \
    -layerChangeRange { Metal1 Metal11 } \
    -blockPinTarget { nearestTarget } \
    -padPinPortConnect { allPort oneGeom } \
    -padPinTarget { nearestTarget } \
    -corePinTarget { firstAfterRowEnd } \
    -floatingStripeTarget { blockring padring ring stripe ringpin blockpin followpin } \
    -allowJogging 1 \
    -crossoverViaLayerRange { Metal1 Metal11 } \
    -nets { VDD VSS } \
    -allowLayerChange 1 \
    -blockPin useLef \
    -targetViaLayerRange { Metal1 Metal11 }

# 12. Pre-CTS timing report
puts "\n[11] Pre-CTS timing report..."
exec mkdir -p ../report
report_timing > ../report/preCTS_timing.log
report_timing -summary

# 13. Clock tree synthesis
puts "\n[12] Clock tree synthesis..."
create_ccopt_clock_tree_spec
ccopt_design

# 14. Post-CTS optimization
puts "\n[13] Post-CTS optimization..."
optDesign -postCTS -hold

# 15. Post-CTS timing report
puts "\n[14] Post-CTS timing report..."
report_timing > ../report/postCTS_timing.log
report_timing -summary

# 16. Signal routing
puts "\n[15] Signal routing..."
setNanoRouteMode -quiet -routeWithTimingDriven true
setNanoRouteMode -quiet -routeWithSiDriven true
routeDesign -globalDetail

# 17. Post-route optimization
puts "\n[16] Post-route optimization..."
setAnalysisMode -analysisType onChipVariation
optDesign -postRoute -hold

# 18. Post-route timing report
puts "\n[17] Post-route timing report..."
report_timing > ../report/postRoute_timing.log
report_timing -summary

# 19. Add filler cells
puts "\n[18] Adding filler cells..."
addFiller -cell FILL1 FILL2 FILL4 FILL8 FILL16 FILL32 FILL64 -prefix FILLER

# 20. Verify geometry and connectivity
puts "\n[19] Running verification..."
verifyGeometry > ../report/geometry.rpt
verifyConnectivity > ../report/connectivity.rpt

# 21. Final reports
puts "\n[20] Generating final reports..."
report_area > ../report/final_area.log
report_power > ../report/final_power.log
summaryReport -noHtml -outfile ../report/summary.rpt

# 22. Save design
puts "\n[21] Saving design..."
saveDesign ../output/pwm_controller_final.enc

# 23. Export GDSII
puts "\n[22] Exporting GDSII..."
# Export without map file (will use default layer mapping)
streamOut ../output/pwm_controller.gds \
    -libName pwm_controller \
    -structureName pwm_controller \
    -units 1000 \
    -mode ALL

puts "\n=========================================="
puts "Place and Route completed successfully!"
puts "=========================================="
puts "GDS: ../output/pwm_controller.gds"
puts "Reports: ../report/*.log"
puts "=========================================="
