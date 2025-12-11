#==============================================================================
# Automated Place and Route Script for SPI Master - Lab 3
# Run this script in Innovus: innovus -files place_route_auto.tcl
#==============================================================================

puts "=========================================="
puts "SPI Master Place and Route Flow"
puts "=========================================="

# 1. Set up library paths
set TECH_LEF "../input/libs/gsclib045/lef/gsclib045_tech.lef"
set MACRO_LEF "../input/libs/gsclib045/lef/gsclib045_macro.lef"
set MBDFF_LEF "../input/libs/gsclib045/lef/gsclib045_multibitsDFF.lef"

set TIMING_SLOW "../input/libs/gsclib045/timing/slow_vdd1v0_basicCells.lib"
set TIMING_FAST "../input/libs/gsclib045/timing/fast_vdd1v0_basicCells.lib"

# 2. Import design
puts "\n[1] Importing design..."
set init_verilog "../output/spi_master.v"
set init_design_name "spi_master"
set init_top_cell "spi_master"
set init_lef_file "$TECH_LEF $MACRO_LEF $MBDFF_LEF"
set init_mmmc_file "../input/spi_master.view"
set init_pwr_net "VDD"
set init_gnd_net "VSS"

init_design

# 3. Set design mode
puts "\n[2] Setting design mode..."
setDesignMode -process 45

# 4. Floorplan
puts "\n[3] Creating floorplan..."
# Reduced utilization from 0.4 to 0.35 to allow space for hold fixing buffers
floorPlan -r 1.0 0.35 5 5 5 5

# 5. Add power rings
puts "\n[4] Adding power rings..."
addRing -nets {VDD VSS} -type core_rings -follow core \
    -layer {top Metal7 bottom Metal7 left Metal8 right Metal8} \
    -width {top 1.0 bottom 1.0 left 1.0 right 1.0} \
    -spacing {top 0.8 bottom 0.8 left 0.8 right 0.8} \
    -offset {top 0.8 bottom 0.8 left 0.8 right 0.8}

# 6. Add power stripes
puts "\n[5] Adding power stripes..."
addStripe -nets {VDD VSS} -layer Metal7 -direction horizontal \
    -width 1.0 -spacing 0.8 -set_to_set_distance 20 -start_from left

addStripe -nets {VDD VSS} -layer Metal8 -direction vertical \
    -width 1.0 -spacing 0.8 -set_to_set_distance 20 -start_from bottom

# 7. Place pins
puts "\n[6] Placing pins..."
editPin -pin * -edge 0 -spacing 5 -layer 3 -spreadType side -unit MICRON

# 8. Place standard cells with pre-place optimization
puts "\n[7] Placing standard cells (with pre-place optimization)..."
setPlaceMode -place_global_reorder_scan false
placeDesign -prePlaceOpt

# 9. Pre-CTS optimization
puts "\n[8] Pre-CTS optimization..."
setOptMode -fixCap true -fixTran true -fixFanoutLoad false
optDesign -preCTS

# 10. Route power
puts "\n[9] Routing power nets..."
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

# 11. Pre-CTS timing report
puts "\n[10] Pre-CTS timing report..."
report_timing > ../report/preCTS_timing.log
report_timing -summary

# 12. Clock tree synthesis
puts "\n[11] Clock tree synthesis..."
create_ccopt_clock_tree_spec
ccopt_design

# 13. Post-CTS optimization
puts "\n[12] Post-CTS optimization..."
optDesign -postCTS -hold

# 14. Post-CTS timing report
puts "\n[13] Post-CTS timing report..."
report_timing > ../report/postCTS_timing.log
report_timing -summary

# 15. Signal routing
puts "\n[14] Signal routing..."
setNanoRouteMode -quiet -routeWithTimingDriven true
setNanoRouteMode -quiet -routeWithSiDriven true
routeDesign -globalDetail

# 16. Post-route optimization
puts "\n[15] Post-route optimization..."
setAnalysisMode -analysisType onChipVariation
optDesign -postRoute -hold

# 17. Post-route timing report
puts "\n[16] Post-route timing report..."
report_timing > ../report/postRoute_timing.log
report_timing -summary

# 18. Add filler cells
puts "\n[17] Adding filler cells..."
addFiller -cell FILL1 FILL2 FILL4 FILL8 FILL16 FILL32 FILL64 -prefix FILLER

# 19. Verify geometry and connectivity
puts "\n[18] Running verification..."
verifyGeometry > ../report/geometry.rpt
verifyConnectivity > ../report/connectivity.rpt

# 20. Final reports
puts "\n[19] Generating final reports..."
report_area > ../report/final_area.log
report_power > ../report/final_power.log
summaryReport -noHtml -outfile ../report/summary.rpt

# 21. Save design
puts "\n[20] Saving design..."
saveDesign ../output/spi_master_final.enc

# 22. Export GDSII
puts "\n[21] Exporting GDSII..."
# Export without map file (will use default layer mapping)
streamOut ../output/spi_master.gds \
    -libName spi_master \
    -structureName spi_master \
    -units 1000 \
    -mode ALL

puts "\n=========================================="
puts "Place and Route completed successfully!"
puts "=========================================="
puts "GDS: ../output/spi_master.gds"
puts "Reports: ../report/*.log"
puts "=========================================="
