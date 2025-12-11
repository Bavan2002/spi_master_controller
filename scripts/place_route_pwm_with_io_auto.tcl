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
    set init_mmmc_file "../input/pwm_controller_chip.view"
    puts "INFO: Including IO pad LEF file (giolib045.lef)"
    puts "INFO: Using chip-level MMMC view file"
} else {
    set init_lef_file "$TECH_LEF $MACRO_LEF $MBDFF_LEF"
    set init_mmmc_file "../input/pwm_controller.view"
}
set init_pwr_net "VDD"
set init_gnd_net "VSS"

init_design

# Step 3: Set design mode
puts "Step 3: Setting design mode for 45nm process..."
setDesignMode -process 45

# Step 4: Load IO placement from file
if {$USE_IO_WRAPPER} {
    puts "Step 4: Loading IO pad placement from file..."
    
    # Try to load IO placement file (prioritize even distribution file)
    if {[file exists "../input/pwm_controller_even.io"]} {
        puts "INFO: Loading even distribution IO file..."
        loadIoFile ../input/pwm_controller_even.io
        puts "INFO: IO placement file loaded successfully"
        set IO_PADS_LOADED 1
    } elseif {[file exists "../input/pwm_controller.io"]} {
        puts "INFO: Loading standard IO placement file..."
        loadIoFile ../input/pwm_controller.io
        puts "INFO: IO placement file loaded successfully"
        set IO_PADS_LOADED 1
    } else {
        puts "ERROR: No IO placement file found!"
        puts "ERROR: Required file: ../input/pwm_controller_even.io or ../input/pwm_controller.io"
        exit 1
    }
}

# Step 5: Create SQUARE floorplan with IO area
puts "Step 5: Creating square floorplan with IO area..."

if {$USE_IO_WRAPPER} {
    # PAD-LIMITED DESIGN:
    # - IO pads: 60um (width) × 240um (height)
    # - Pad count: 15 pads per edge (max)
    # - Required spacing: 5um gaps between pads
    # - Calculation: 15×60um + 16×5um + 2×240um(corners) = 1460um die size
    # - IO margin: 250um (240um pad + 10um clearance)
    # 
    # Use fixed die size to ensure pads fit with proper spacing
    floorPlan -s 1.460 1.460 0.250 0.250 0.250 0.250
    puts "INFO: Fixed die size 1460um × 1460um (pad-limited design)"
    puts "INFO: IO margins: 250um (240um pad + 10um clearance)"
    puts "INFO: Core size: 960um × 960um (utilization ~0.1% - pad-limited)"
} else {
    floorPlan -r 1.0 0.4 5 5 5 5
    puts "INFO: Floorplan created for core-only design (SQUARE)"
}

# Verify and report floorplan dimensions
set core_box [dbGet top.fPlan.coreBox]
set die_box [dbGet top.fPlan.box]
set core_llx [lindex [lindex $core_box 0] 0]
set core_lly [lindex [lindex $core_box 0] 1]
set core_urx [lindex [lindex $core_box 0] 2]
set core_ury [lindex [lindex $core_box 0] 3]
set core_width [expr {$core_urx - $core_llx}]
set core_height [expr {$core_ury - $core_lly}]
set die_llx [lindex [lindex $die_box 0] 0]
set die_lly [lindex [lindex $die_box 0] 1]
set die_urx [lindex [lindex $die_box 0] 2]
set die_ury [lindex [lindex $die_box 0] 3]
set die_width [expr {$die_urx - $die_llx}]
set die_height [expr {$die_ury - $die_lly}]

puts "Floorplan configuration:"
puts "  - Aspect ratio: 1.0 (SQUARE target)"
puts "  - Core utilization: 0.4 (40%)"
if {$USE_IO_WRAPPER} {
    puts "  - Core margins: 250um (EQUAL on all 4 sides)"
    puts "  - IO pad size: 60um x 240um"
    puts "  - Clearance: 10um between pads and core"
} else {
    puts "  - Core margins: 5um (EQUAL on all 4 sides)"
}
puts ""
puts "Floorplan dimensions:"
puts "  - Core: [format %.2f $core_width]um x [format %.2f $core_height]um (aspect: [format %.3f [expr {$core_width/$core_height}]])"
puts "  - Die:  [format %.2f $die_width]um x [format %.2f $die_height]um (aspect: [format %.3f [expr {$die_width/$die_height}]])"
if {abs($core_width - $core_height) < 1.0 && abs($die_width - $die_height) < 1.0} {
    puts "  ✓ SQUARE chip achieved!"
} else {
    puts "  ⚠ Note: Chip is slightly rectangular (tool adjusted for standard cell rows)"
    puts "           This is normal - the tool rounds to fit standard cell site heights"
}

# Step 6: Commit IO pad placement
if {$USE_IO_WRAPPER && $IO_PADS_LOADED == 1} {
    puts "Step 6: Committing IO pad placement from loaded file..."
    
    # Commit the loaded IO placement
    if {[catch {commitIoPlacement} result]} {
        puts "WARNING: commitIoPlacement failed: $result"
        puts "INFO: Trying alternative method..."
        if {[catch {placeIoPins -commit} result2]} {
            puts "ERROR: Alternative commit also failed: $result2"
            puts "ERROR: IO pad placement could not be committed"
        } else {
            puts "INFO: IO pads committed successfully (alternative method)"
        }
    } else {
        puts "INFO: IO pads committed successfully"
    }
    
    # Save a copy of the IO placement for reference
    puts "INFO: Saving IO placement configuration..."
    saveIoFile ../output/pwm_controller_chip.io
    puts "INFO: IO placement saved to ../output/pwm_controller_chip.io"
}

# Step 7: Add power rings
puts "Step 7: Adding power rings..."
addRing -nets {VDD VSS} -type core_rings -follow core \
    -layer {top Metal7 bottom Metal7 left Metal8 right Metal8} \
    -width {top 2.0 bottom 2.0 left 2.0 right 2.0} \
    -spacing {top 1.0 bottom 1.0 left 1.0 right 1.0} \
    -offset {top 1.0 bottom 1.0 left 1.0 right 1.0}

# Step 8: Add power stripes (calculated for even coverage across entire core)
puts "Step 8: Calculating and adding power stripes for full core coverage..."

# Get core area dimensions (handle nested list properly)
set core_box_raw [dbGet top.fPlan.coreBox]
# Extract coordinates from nested list structure
set core_box [lindex $core_box_raw 0]
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

# Step 9: Mark clock pins and verify IO pad placement
if {$USE_IO_WRAPPER} {
    puts "Step 9: Configuring pin attributes and verifying placement..."
    
    # 9a. Mark clock pin as CLOCK (not SIGNAL)
    puts "INFO: Setting clock pin attribute..."
    if {[catch {
        set clk_pin [dbGet top.terms.name PAD_clk -p]
        if {$clk_pin != ""} {
            dbSet [dbGet top.terms.name PAD_clk -p].use clock
            puts "INFO: PAD_clk marked as CLOCK pin"
        } else {
            puts "WARNING: Could not find PAD_clk pin"
        }
    } err]} {
        puts "WARNING: Could not set clock attribute: $err"
    }
    
    # 9b. Check for any unplaced IO cells
    puts "INFO: Verifying IO pad placement..."
    set unplaced [selectInst -unplaced]
    if {[llength $unplaced] > 0} {
        puts "WARNING: Found [llength $unplaced] unplaced instances!"
        puts "WARNING: Unplaced instances: $unplaced"
    } else {
        puts "INFO: All IO pads placed successfully"
    }
    
    # 9c. Generate IO placement report
    exec mkdir -p ../report
    report_io > ../report/io_pad_placement.rpt
    puts "INFO: IO placement report saved to ../report/io_pad_placement.rpt"
}

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

# Step 12b: Connect power/ground pins to nets (for IO wrapper design)
if {$USE_IO_WRAPPER} {
    puts "Step 12b: Connecting power/ground pins to global nets..."
    
    # Connect VDD pins to VDD net
    globalNetConnect VDD -type pgpin -pin VDD -inst * -module {}
    globalNetConnect VDD -type tiehi -inst * -module {}
    
    # Connect VSS pins to VSS net  
    globalNetConnect VSS -type pgpin -pin VSS -inst * -module {}
    globalNetConnect VSS -type tielo -inst * -module {}
    
    # Connect VDDIOR pins to VDD (if not separately routed)
    catch {globalNetConnect VDD -type pgpin -pin VDDIOR -inst * -module {}}
    
    # Connect VSSIOR pins to VSS (if not separately routed)
    catch {globalNetConnect VSS -type pgpin -pin VSSIOR -inst * -module {}}
    
    puts "INFO: Power/ground connections established"
}

# Step 13: Clock tree synthesis
puts "Step 13: Running clock tree synthesis..."

# For IO wrapper design, handle clock pad (no timing library available)
if {$USE_IO_WRAPPER} {
    puts "INFO: Configuring CTS to bypass IO pad (no timing library)..."
    
    # SOLUTION: Treat the internal clock net as ideal network
    # This makes CTS ignore the pad and start from the internal connection point
    
    # Find the net connected to pad output (pad_clk/Y -> core_inst/clk)
    set pad_output_net [get_nets -of_objects [get_pins pad_clk/Y]]
    
    if {$pad_output_net != ""} {
        # Set this net as ideal - CTS will not try to optimize through the pad
        set_ideal_network $pad_output_net
        puts "INFO: Clock net '$pad_output_net' set as ideal network"
        puts "INFO: CTS will start from core clock pins, ignoring pad delay"
    } else {
        puts "WARNING: Could not find clock net from pad"
        # Fallback: try to find by hierarchy
        catch {
            set_ideal_network [get_nets core_inst/clk]
            puts "INFO: Set core_inst/clk as ideal network (fallback)"
        }
    }
    
    # Also set don't touch on pad to prevent any modifications
    catch {
        set_dont_touch [get_cells pad_clk]
        puts "INFO: Pad instance pad_clk marked as don't touch"
    }
}

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

