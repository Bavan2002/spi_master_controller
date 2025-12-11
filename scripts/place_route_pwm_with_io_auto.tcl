#==============================================================================
# Automated Place and Route Script with IO Area for PWM Controller - Lab 3
#==============================================================================

puts "=========================================="
puts "PWM Controller Place and Route Flow with IO Area"
puts "=========================================="

#==============================================================================
# CONFIGURATION - Set to 1 to enable IO pad wrapper, 0 for core-only
#==============================================================================
set USE_IO_WRAPPER 1

# 1. Set up library paths
set TECH_LEF "../input/libs/gsclib045/lef/gsclib045_tech.lef"
set MACRO_LEF "../input/libs/gsclib045/lef/gsclib045_macro.lef"
set MBDFF_LEF "../input/libs/gsclib045/lef/gsclib045_multibitsDFF.lef"
set IOPAD_LEF "../input/libs/gsclib045/lef/giolib045.lef"

# 2. Import design
puts "\n[1] Importing design..."
if {$USE_IO_WRAPPER} {
    puts "INFO: Using IO wrapper design (pwm_controller_chip with pads)"
    set init_verilog "../output/pwm_controller_chip.v"
    set init_design_name "pwm_controller_chip"
    set init_top_cell "pwm_controller_chip"
} else {
    puts "INFO: Using core-only design (pwm_controller without pads)"
    set init_verilog "../output/pwm_controller.v"
    set init_design_name "pwm_controller"
    set init_top_cell "pwm_controller"
}

if {$USE_IO_WRAPPER} {
    set init_lef_file "$TECH_LEF $MACRO_LEF $MBDFF_LEF $IOPAD_LEF"
    puts "INFO: Including IO pad LEF file (giolib045.lef)"
} else {
    set init_lef_file "$TECH_LEF $MACRO_LEF $MBDFF_LEF"
}
set init_mmmc_file "../input/pwm_controller.view"
set init_pwr_net "VDD"
set init_gnd_net "VSS"

init_design

# 3. Set design mode
puts "\n[2] Setting design mode..."
setDesignMode -process 45

# 4. Load IO placement file (if using IO wrapper)
if {$USE_IO_WRAPPER} {
    puts "\n[3a] Loading IO placement file..."
    if {[file exists "../input/pwm_controller.io"]} {
        loadIoFile ../input/pwm_controller.io
        puts "INFO: IO placement file loaded successfully"
    } else {
        puts "WARNING: IO file not found, will use auto-placement"
    }
}

# 5. Floorplan with IO area margins
puts "\n[3] Creating floorplan with IO area..."

if {$USE_IO_WRAPPER} {
    floorPlan -r 1.0 0.30 \
        -coreMargins 150 150 150 150 \
        -coreMarginsBy io
    puts "Floorplan created with IO pad ring support"
} else {
    floorPlan -r 1.0 0.30 150 150 150 150
    puts "Floorplan created with IO margins (core-only)"
}

puts "Floorplan configuration:"
puts "  - Core utilization: 0.30 (30%)"
puts "  - Core margins: 150um (all sides)"
puts "  - Aspect ratio: 1.0"

# 6. Commit IO pad placement (if using IO wrapper)
if {$USE_IO_WRAPPER} {
    puts "\n[4a] Committing IO pad placement..."
    if {[catch {commitIoPlacement} result]} {
        puts "WARNING: IO placement commit failed or not needed: $result"
    } else {
        puts "INFO: IO pads placed successfully"
    }
}

# 7. Add power rings
puts "\n[4] Adding power rings..."
addRing -nets {VDD VSS} -type core_rings -follow core \
    -layer {top Metal7 bottom Metal7 left Metal8 right Metal8} \
    -width {top 2.0 bottom 2.0 left 2.0 right 2.0} \
    -spacing {top 1.0 bottom 1.0 left 1.0 right 1.0} \
    -offset {top 1.0 bottom 1.0 left 1.0 right 1.0}

# 8. Add power stripes
puts "\n[5] Adding power stripes..."
addStripe -nets {VDD VSS} -layer Metal7 -direction horizontal \
    -width 1.0 -spacing 0.8 -set_to_set_distance 20 -start_from left

addStripe -nets {VDD VSS} -layer Metal8 -direction vertical \
    -width 1.0 -spacing 0.8 -set_to_set_distance 20 -start_from bottom

# 9. Place pins
puts "\n[6] Placing pins..."
editPin -pin * -edge 0 -spacing 10 -layer 3 -spreadType side -unit MICRON

# 10. Place standard cells
puts "\n[7] Placing standard cells..."
setPlaceMode -place_global_reorder_scan false
placeDesign -prePlaceOpt

# 11. Pre-CTS optimization
puts "\n[8] Pre-CTS optimization..."
setOptMode -fixCap true -fixTran true -fixFanoutLoad false
optDesign -preCTS

# 12. Route power
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

# 13. Clock tree synthesis
puts "\n[11] Clock tree synthesis..."
create_ccopt_clock_tree_spec
ccopt_design

# 14. Post-CTS optimization
puts "\n[12] Post-CTS optimization..."
optDesign -postCTS -hold

# 15. Signal routing
puts "\n[14] Signal routing..."
setNanoRouteMode -quiet -routeWithTimingDriven true
setNanoRouteMode -quiet -routeWithSiDriven true
routeDesign -globalDetail

# 16. Post-route optimization
puts "\n[15] Post-route optimization..."
setAnalysisMode -analysisType onChipVariation
optDesign -postRoute -hold

# 17. Add filler cells
puts "\n[17] Adding filler cells..."
addFiller -cell FILL1 FILL2 FILL4 FILL8 FILL16 FILL32 FILL64 -prefix FILLER

# 18. Verify geometry and connectivity
puts "\n[18] Running verification..."
verifyGeometry > ../report/pwm_io_geometry.rpt
verifyConnectivity > ../report/pwm_io_connectivity.rpt

# 19. Final reports
puts "\n[19] Generating final reports..."
report_area > ../report/pwm_io_final_area.log
report_power > ../report/pwm_io_final_power.log
report_timing > ../report/pwm_io_final_timing.log
summaryReport -noHtml -outfile ../report/pwm_io_summary.rpt

# 20. Save design
puts "\n[21] Saving design..."
saveDesign ../output/pwm_controller_with_io.enc

# 21. Export GDSII
puts "\n[22] Exporting GDSII..."
streamOut ../output/pwm_controller_with_io.gds \
    -libName pwm_controller_io \
    -structureName pwm_controller \
    -units 1000 \
    -mode ALL

puts "\n=========================================="
puts "Place and Route with IO Area completed!"
puts "=========================================="
puts "Output Files:"
puts "  GDS: ../output/pwm_controller_with_io.gds"
puts "  Design: ../output/pwm_controller_with_io.enc"
puts "=========================================="

