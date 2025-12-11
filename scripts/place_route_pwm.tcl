#==============================================================================
# PWM Controller Place and Route Script
# Based on EN4603 Lab 3 Instructions - Exact Lab Setup
# Run in Innovus: cd work && innovus -files ../scripts/place_route_pwm.tcl
#==============================================================================

puts "=========================================="
puts "PWM Controller Place and Route Flow"
puts "=========================================="

# Create base directories
exec mkdir -p ../output
exec mkdir -p ../report
exec mkdir -p ../report/pre_CTS
exec mkdir -p ../report/post_CTS
exec mkdir -p ../log

# Step 1: Set up library paths
puts "\nStep 1: Setting up library paths..."
set TECH_LEF "../input/libs/gsclib045/lef/gsclib045_tech.lef"
set MACRO_LEF "../input/libs/gsclib045/lef/gsclib045_macro.lef"
set MBDFF_LEF "../input/libs/gsclib045/lef/gsclib045_multibitsDFF.lef"

# Step 2: Import design
puts "\nStep 2: Importing design..."
set init_verilog "../output/pwm_controller_2.v"
set init_design_name "pwm_controller"
set init_top_cell "pwm_controller"
set init_lef_file "$TECH_LEF $MACRO_LEF $MBDFF_LEF"
set init_mmmc_file "../input/pwm_controller.view"
set init_pwr_net "VDD"
set init_gnd_net "VSS"

init_design

# Step 3: Read scanDEF
puts "\nStep 3: Reading scanDEF file..."
defIn ../output/pwm_controller_2_scanDEF.scandef

# Step 4: Set design mode
puts "\nStep 4: Setting design mode for 45nm process..."
setDesignMode -process 45

# Step 5: Specify floorplan (as per lab instructions)
puts "\nStep 5: Creating floorplan..."
# Aspect ratio: 1.0
# Core Utilization: 0.4 (40%)
# Core margins: 5 microns from core to IO boundary (all sides)
floorPlan -r 1.0 0.4 5 5 5 5

# Step 6: Add power rings (as per lab instructions)
# Metal 7 for horizontal, Metal 8 for vertical
puts "\nStep 6: Adding power rings..."
puts "INFO: Ring configuration - Width: 1.0, Spacing: 0.8, Offset: 0.8"
addRing -nets {VDD VSS} -type core_rings -follow core \
    -layer {top Metal7 bottom Metal7 left Metal8 right Metal8} \
    -width {top 1.0 bottom 1.0 left 1.0 right 1.0} \
    -spacing {top 0.8 bottom 0.8 left 0.8 right 0.8} \
    -offset {top 0.8 bottom 0.8 left 0.8 right 0.8}

# Step 7: Add power stripes (as per lab instructions)
puts "\nStep 7: Adding power stripes..."

# Horizontal stripes on Metal 7
puts "INFO: Adding horizontal stripes - Metal 7, Width: 1.0, Spacing: 0.8, Sets: 3"
addStripe -nets {VDD VSS} -layer Metal7 -direction horizontal \
    -width 1.0 -spacing 0.8 -number_of_sets 3 \
    -start_from bottom -start_offset 15 -stop_offset 15

# Vertical stripes on Metal 8
puts "INFO: Adding vertical stripes - Metal 8, Width: 1.0, Spacing: 0.8, Sets: 3"
addStripe -nets {VDD VSS} -layer Metal8 -direction vertical \
    -width 1.0 -spacing 0.8 -number_of_sets 3 \
    -start_from left -start_offset 15 -stop_offset 15

# Step 8: Pin placement
puts "\nStep 8: Placing pins..."
# Spread all pins on edge 0 (top) with 5um spacing
editPin -pin * -edge 0 -spacing 5 -layer 3 -spreadType side -unit MICRON

# Step 8b: Save design checkpoint (prePlacement)
puts "\nStep 8b: Saving design checkpoint (prePlacement)..."
saveDesign ../output/pwm_controller_prePlacement.enc

# Step 9: Place standard cells
puts "\nStep 9: Placing standard cells..."
# Run full placement with pre-place optimization
# Place IO pins is NOT selected (already placed)
setPlaceMode -place_global_reorder_scan false
placeDesign -prePlaceOpt

# Step 10: Report gate count and area
puts "\nStep 10: Reporting gate count and area..."
summaryReport -noHtml -outfile ../report/pwm_optPlace_summary.rpt

# Step 11: Pre-CTS setup time analysis
puts "\nStep 11: Pre-CTS setup time analysis..."
timeDesign -preCTS -outDir ../report/pre_CTS

# Step 12: Route power nets
puts "\nStep 12: Routing power nets (special route)..."
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
puts "\nStep 13: Running clock tree synthesis..."
create_ccopt_clock_tree_spec
ccopt_design

# Step 14: Scan chain reorder (clock tree aware)
puts "\nStep 14: Performing clock tree aware scan chain reordering..."
ecoScanReorder -clk_tree_aware

# Step 15: Post-CTS hold time analysis
puts "\nStep 15: Post-CTS hold time analysis..."
timeDesign -postCTS -hold -outDir ../report/post_CTS

# Step 15b: Post-CTS hold optimization (if violations exist)
puts "\nStep 15b: Post-CTS hold time optimization..."
optDesign -postCTS -hold

# Step 16: Signal routing
puts "\nStep 16: Running signal routing (NanoRoute)..."
setNanoRouteMode -quiet -routeWithTimingDriven true
setNanoRouteMode -quiet -routeWithSiDriven true
routeDesign -globalDetail

# Step 17: Post-route timing analysis (OCV)
puts "\nStep 17: Post-route timing analysis (OCV)..."
setAnalysisMode -analysisType onChipVariation
timeDesign -postRoute -outDir ../report

# Step 17b: Post-route optimization (if needed)
puts "\nStep 17b: Post-route optimization..."
optDesign -postRoute -hold

# Step 18: Place filler cells
puts "\nStep 18: Placing filler cells..."
# Select all cells with "FILL" prefix
# Prefix: FILLER, Do DRC, Fit Gap
addFiller -cell FILL1 FILL2 FILL4 FILL8 FILL16 FILL32 FILL64 \
    -prefix FILLER -fitGap

# Step 19: Verification
puts "\nStep 19: Running design verification..."

# Geometry verification
puts "INFO: Verifying geometry (DRC)..."
verifyGeometry -report ../report/pwm_controller.geom.rpt

# Connectivity verification
puts "INFO: Verifying connectivity..."
verifyConnectivity -report ../report/pwm_controller.conn.rpt

# Step 20: GDSII export
puts "\nStep 20: Exporting GDSII layout..."
# Output format: GDSII/Stream
# Map file: streamOut.map
# Library name: pwm_lib
streamOut ../output/pwm_controller.gds \
    -mapFile ../input/streamOut.map \
    -libName pwm_lib \
    -structureName pwm_controller \
    -units 1000 \
    -mode ALL

# Final: Save design database
puts "\nFinal: Saving final design database..."
saveDesign ../output/pwm_controller_final.enc

# Generate final summary reports
puts "\nGenerating final summary reports..."
report_area > ../report/pwm_final_area.log
report_power > ../report/pwm_final_power.log
report_timing > ../report/pwm_final_timing.log
summaryReport -noHtml -outfile ../report/pwm_final_summary.rpt

puts "\n=========================================="
puts "PWM Controller Place & Route Complete!"
puts "=========================================="
puts "Output Files:"
puts "  GDSII:    ../output/pwm_controller.gds"
puts "  Database: ../output/pwm_controller_final.enc"
puts "  Netlist:  ../output/pwm_controller_2.v"
puts "Reports:"
puts "  Pre-CTS:  ../report/pre_CTS/"
puts "  Post-CTS: ../report/post_CTS/"
puts "  Geometry: ../report/pwm_controller.geom.rpt"
puts "  Connect:  ../report/pwm_controller.conn.rpt"
puts "  Summary:  ../report/pwm_final_summary.rpt"
puts "=========================================="

exit
