#==============================================================================
# PWM Controller Place and Route Script with IO Pads
# Based on EN4603 Lab 3 Instructions
# Run in Innovus: cd work && innovus -files ../scripts/place_route_pwm_with_io_auto.tcl
#==============================================================================

puts "=========================================="
puts "PWM Controller Place & Route with IO Pads"
puts "=========================================="

# Create base directories
exec mkdir -p ../output
exec mkdir -p ../report
exec mkdir -p ../log

#==============================================================================
# CONFIGURATION - Set to 1 to enable IO pad wrapper, 0 for core-only
#==============================================================================
set USE_IO_WRAPPER 1

# Step 1: Set up library paths
puts "Step 1: Setting up library paths..."
set TECH_LEF "../input/libs/gsclib045/lef/gsclib045_tech.lef"
set MACRO_LEF "../input/libs/gsclib045/lef/gsclib045_macro.lef"
set MBDFF_LEF "../input/libs/gsclib045/lef/gsclib045_multibitsDFF.lef"
set IOPAD_LEF "../input/libs/gsclib045/lef/giolib045.lef"

# Step 2: Import design
puts "Step 2: Importing design..."
if {$USE_IO_WRAPPER} {
    puts "INFO: Using IO wrapper design (pwm_controller_chip with pads)"
    set init_verilog "../output/pwm_controller_chip.v"
    set init_design_name "pwm_controller_chip"
    set init_top_cell "pwm_controller_chip"
} else {
    puts "INFO: Using core-only design (pwm_controller without pads)"
    set init_verilog "../output/pwm_controller_2.v"
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

# Step 3: Set design mode
puts "Step 3: Setting design mode for 45nm process..."
setDesignMode -process 45

# Step 4: Load IO placement file (if using IO wrapper)
if {$USE_IO_WRAPPER} {
    puts "Step 4: Loading IO placement file..."
    if {[file exists "../input/pwm_controller.io"]} {
        loadIoFile ../input/pwm_controller.io
        puts "INFO: IO placement file loaded successfully"
    } else {
        puts "WARNING: IO file not found, will use auto-placement"
    }
}

# Step 5: Create floorplan with IO area
puts "Step 5: Creating floorplan with IO area..."

if {$USE_IO_WRAPPER} {
    # Core utilization 0.4 for IO wrapper design
    # Large margins (150um) for IO pad placement
    floorPlan -r 1.0 0.4 150 150 150 150
    puts "INFO: Floorplan created with IO pad margins"
} else {
    floorPlan -r 1.0 0.4 5 5 5 5
    puts "INFO: Floorplan created for core-only design"
}

puts "Floorplan configuration:"
puts "  - Core utilization: 0.4 (40%)"
puts "  - Aspect ratio: 1.0"
if {$USE_IO_WRAPPER} {
    puts "  - Core margins: 150um (for IO pads)"
} else {
    puts "  - Core margins: 5um (core-only)"
}

# Step 6: Commit IO pad placement (if using IO wrapper)
if {$USE_IO_WRAPPER} {
    puts "Step 6: Committing IO pad placement..."
    if {[catch {commitIoPlacement} result]} {
        puts "WARNING: IO placement commit failed or not needed: $result"
    } else {
        puts "INFO: IO pads placed successfully"
    }
}

# Step 7: Add power rings
puts "Step 7: Adding power rings..."
addRing -nets {VDD VSS} -type core_rings -follow core \
    -layer {top Metal7 bottom Metal7 left Metal8 right Metal8} \
    -width {top 2.0 bottom 2.0 left 2.0 right 2.0} \
    -spacing {top 1.0 bottom 1.0 left 1.0 right 1.0} \
    -offset {top 1.0 bottom 1.0 left 1.0 right 1.0}

# Step 8: Add power stripes
puts "Step 8: Adding power stripes..."
addStripe -nets {VDD VSS} -layer Metal7 -direction horizontal \
    -width 1.0 -spacing 0.8 -set_to_set_distance 20 -start_from left

addStripe -nets {VDD VSS} -layer Metal8 -direction vertical \
    -width 1.0 -spacing 0.8 -set_to_set_distance 20 -start_from bottom

# Step 9: Place pins
puts "Step 9: Placing pins..."
editPin -pin * -edge 0 -spacing 10 -layer 3 -spreadType side -unit MICRON

# Step 10: Place standard cells with pre-place optimization
puts "Step 10: Placing standard cells with pre-place optimization..."
setPlaceMode -place_global_reorder_scan false
placeDesign -prePlaceOpt

# Step 11: Pre-CTS optimization
puts "Step 11: Running pre-CTS optimization..."
setOptMode -fixCap true -fixTran true -fixFanoutLoad false
optDesign -preCTS

# Step 12: Route power nets
puts "Step 12: Routing power nets..."
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

# Step 13: Clock tree synthesis
puts "Step 13: Running clock tree synthesis..."
create_ccopt_clock_tree_spec
ccopt_design

# Step 14: Post-CTS optimization
puts "Step 14: Running post-CTS optimization..."
optDesign -postCTS -hold

# Step 15: Post-CTS timing analysis
puts "Step 15: Post-CTS timing analysis..."
exec mkdir -p ../report/post_CTS
timeDesign -postCTS -hold -outDir ../report/post_CTS

# Step 16: Signal routing
puts "Step 16: Running signal routing..."
setNanoRouteMode -quiet -routeWithTimingDriven true
setNanoRouteMode -quiet -routeWithSiDriven true
routeDesign -globalDetail

# Step 17: Post-route timing analysis
puts "Step 17: Post-route timing analysis (OCV)..."
setAnalysisMode -analysisType onChipVariation
timeDesign -postRoute -outDir ../report

# Step 18: Post-route optimization
puts "Step 18: Post-route optimization..."
optDesign -postRoute -hold

# Step 19: Place filler cells
puts "Step 19: Placing filler cells..."
addFiller -cell FILL1 FILL2 FILL4 FILL8 FILL16 FILL32 FILL64 -prefix FILLER -fitGap

# Step 20: Verify geometry
puts "Step 20: Verifying geometry..."
verifyGeometry -report ../report/pwm_io_geometry.rpt

# Step 21: Verify connectivity
puts "Step 21: Verifying connectivity..."
verifyConnectivity -report ../report/pwm_io_connectivity.rpt

# Step 22: Generate final reports
puts "Step 22: Generating final reports..."
report_area > ../report/pwm_io_final_area.log
report_power > ../report/pwm_io_final_power.log
report_timing > ../report/pwm_io_final_timing.log
summaryReport -noHtml -outfile ../report/pwm_io_summary.rpt

# Step 23: Save design database
puts "Step 23: Saving design database..."
saveDesign ../output/pwm_controller_with_io.enc

# Step 24: Export GDSII
puts "Step 24: Exporting GDSII layout..."
# Check if map file exists
if {[file exists "../input/streamOut.map"]} {
    streamOut ../output/pwm_controller_with_io.gds \
        -mapFile ../input/streamOut.map \
        -libName pwm_lib \
        -structureName pwm_controller_chip \
        -units 1000 \
        -mode ALL
} else {
    streamOut ../output/pwm_controller_with_io.gds \
        -libName pwm_lib \
        -structureName pwm_controller_chip \
        -units 1000 \
        -mode ALL
}

puts "\n=========================================="
puts "PWM Controller P&R with IO Pads Complete!"
puts "=========================================="
puts "GDSII:    ../output/pwm_controller_with_io.gds"
puts "Database: ../output/pwm_controller_with_io.enc"
puts "Reports:  ../report/pwm_io_*.log"
puts "=========================================="

exit

