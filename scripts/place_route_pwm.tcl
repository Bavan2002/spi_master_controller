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

# Step 5: Specify floorplan (SQUARE aspect ratio)
puts "\nStep 5: Creating square floorplan..."
# Aspect ratio: 1.0 (SQUARE)
# Core Utilization: 0.4 (40%)
# Core margins: 5 microns (EQUAL on all sides for square chip)
floorPlan -r 1.0 0.4 5 5 5 5

# Verify and report floorplan dimensions
set core_box [dbGet top.fPlan.coreBox]
set die_box [dbGet top.fPlan.box]
set core_width [expr {[lindex $core_box 2] - [lindex $core_box 0]}]
set core_height [expr {[lindex $core_box 3] - [lindex $core_box 1]}]
set die_width [expr {[lindex $die_box 2] - [lindex $die_box 0]}]
set die_height [expr {[lindex $die_box 3] - [lindex $die_box 1]}]

puts "INFO: Floorplan created:"
puts "      Core: [format %.2f $core_width]um x [format %.2f $core_height]um (aspect: [format %.3f [expr {$core_width/$core_height}]])"
puts "      Die:  [format %.2f $die_width]um x [format %.2f $die_height]um (aspect: [format %.3f [expr {$die_width/$die_height}]])"
if {abs($core_width - $core_height) < 1.0 && abs($die_width - $die_height) < 1.0} {
    puts "      ✓ SQUARE chip achieved!"
} else {
    puts "      ⚠ Note: Chip is slightly rectangular (tool adjusted for standard cell rows)"
}

# Step 6: Add power rings (as per lab instructions)
# Metal 7 for horizontal, Metal 8 for vertical
puts "\nStep 6: Adding power rings..."
puts "INFO: Ring configuration - Width: 1.0, Spacing: 0.8, Offset: 0.8"
addRing -nets {VDD VSS} -type core_rings -follow core \
    -layer {top Metal7 bottom Metal7 left Metal8 right Metal8} \
    -width {top 1.0 bottom 1.0 left 1.0 right 1.0} \
    -spacing {top 0.8 bottom 0.8 left 0.8 right 0.8} \
    -offset {top 0.8 bottom 0.8 left 0.8 right 0.8}

# Step 7: Add power stripes (calculated for even coverage across entire core)
puts "\nStep 7: Calculating and adding power stripes for full core coverage..."

# Get core area dimensions
set core_box [dbGet top.fPlan.coreBox]
set core_llx [lindex $core_box 0]
set core_lly [lindex $core_box 1]
set core_urx [lindex $core_box 2]
set core_ury [lindex $core_box 3]
set core_width [expr {$core_urx - $core_llx}]
set core_height [expr {$core_ury - $core_lly}]

puts "INFO: Core dimensions: ${core_width}um x ${core_height}um"

# Power stripe parameters
set stripe_width 1.0
set stripe_spacing 1.2  ;# Spacing between VDD and VSS within a set
set target_num_sets 8   ;# Target number of stripe sets for good coverage

# Calculate set-to-set distance for even distribution
# Each set takes: stripe_width + spacing + stripe_width = 2*width + spacing
set set_size [expr {2.0 * $stripe_width + $stripe_spacing}]

# Calculate optimal spacing to cover entire core
set horizontal_set_distance [expr {$core_height / double($target_num_sets)}]
set vertical_set_distance [expr {$core_width / double($target_num_sets)}]

puts "INFO: Stripe configuration:"
puts "      Width: ${stripe_width}um, VDD-VSS spacing: ${stripe_spacing}um"
puts "      Set size: ${set_size}um"
puts "      Target sets: $target_num_sets per direction"
puts "      Horizontal set spacing: [format %.2f $horizontal_set_distance]um"
puts "      Vertical set spacing: [format %.2f $vertical_set_distance]um"

# Add horizontal stripes on Metal 7 (evenly distributed from bottom to top)
puts "INFO: Adding horizontal stripes (Metal 7)..."
addStripe -nets {VDD VSS} -layer Metal7 -direction horizontal \
    -width $stripe_width -spacing $stripe_spacing \
    -set_to_set_distance $horizontal_set_distance \
    -start_from bottom

# Add vertical stripes on Metal 8 (evenly distributed from left to right)
puts "INFO: Adding vertical stripes (Metal 8)..."
addStripe -nets {VDD VSS} -layer Metal8 -direction vertical \
    -width $stripe_width -spacing $stripe_spacing \
    -set_to_set_distance $vertical_set_distance \
    -start_from left

puts "INFO: Power mesh created with full core coverage"

# Step 8: Pin placement - Distribute equally across all 4 edges
puts "\nStep 8: Placing pins equally on all four edges..."
# Edge 0 = Bottom, Edge 1 = Right, Edge 2 = Top, Edge 3 = Left
# Using layer 3 (Metal3) for pin access

# Get all pin names
set all_pins [dbGet top.terms.name]
set num_pins [llength $all_pins]
set pins_per_edge [expr {$num_pins / 4}]
set remainder [expr {$num_pins % 4}]

puts "INFO: Total pins: $num_pins"
puts "INFO: Distributing $pins_per_edge pins per edge (with $remainder extra)"

# Distribute pins equally across 4 edges
set edge0_pins {}
set edge1_pins {}
set edge2_pins {}
set edge3_pins {}

set idx 0
foreach pin $all_pins {
    set edge [expr {$idx % 4}]
    if {$edge == 0} {
        lappend edge0_pins $pin
    } elseif {$edge == 1} {
        lappend edge1_pins $pin
    } elseif {$edge == 2} {
        lappend edge2_pins $pin
    } else {
        lappend edge3_pins $pin
    }
    incr idx
}

# Place pins on each edge
if {[llength $edge0_pins] > 0} {
    puts "INFO: Placing [llength $edge0_pins] pins on Bottom edge (Edge 0)"
    editPin -pin $edge0_pins -edge 0 -spacing 5 -layer 3 -spreadType side -unit MICRON
}

if {[llength $edge1_pins] > 0} {
    puts "INFO: Placing [llength $edge1_pins] pins on Right edge (Edge 1)"
    editPin -pin $edge1_pins -edge 1 -spacing 5 -layer 3 -spreadType side -unit MICRON
}

if {[llength $edge2_pins] > 0} {
    puts "INFO: Placing [llength $edge2_pins] pins on Top edge (Edge 2)"
    editPin -pin $edge2_pins -edge 2 -spacing 5 -layer 3 -spreadType side -unit MICRON
}

if {[llength $edge3_pins] > 0} {
    puts "INFO: Placing [llength $edge3_pins] pins on Left edge (Edge 3)"
    editPin -pin $edge3_pins -edge 3 -spacing 5 -layer 3 -spreadType side -unit MICRON
}

# Step 8b: Mark clock pin as CLOCK type
puts "\nStep 8b: Setting clock pin attribute..."
if {[catch {
    set clk_term [dbGet top.terms.name clk -p]
    if {$clk_term != ""} {
        dbSet [dbGet top.terms.name clk -p].use clock
        puts "INFO: Clock pin 'clk' marked as CLOCK (not SIGNAL)"
    } else {
        puts "WARNING: Could not find 'clk' pin"
    }
} err]} {
    puts "WARNING: Could not set clock attribute: $err"
}

# Step 8c: Save design checkpoint (prePlacement)
puts "\nStep 8c: Saving design checkpoint (prePlacement)..."
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
