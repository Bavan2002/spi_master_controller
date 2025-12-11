#==============================================================================
# Automated Place and Route Script with IO Area for SPI Master - Lab 3
# Run this script in Innovus: innovus -files place_route_with_io_auto.tcl
#==============================================================================

puts "=========================================="
puts "SPI Master Place and Route Flow with IO Area"
puts "=========================================="

#==============================================================================
# CONFIGURATION - Set to 1 to enable IO pad wrapper, 0 for core-only
#==============================================================================
set USE_IO_WRAPPER 1
# NOTE: Set USE_IO_WRAPPER to 1 if:
#   1. You have synthesized spi_master_chip.v (the wrapper with pads)
#   2. You have the actual pad cell libraries available in gsclib045
#   3. You want to include actual IO pad instances in the layout
#
# Set to 0 (default) to:
#   1. Use core-only design (spi_master.v)
#   2. Reserve IO area margins but use regular I/O pins
#   3. Run without needing actual pad cell libraries

# 1. Set up library paths
set TECH_LEF "../input/libs/gsclib045/lef/gsclib045_tech.lef"
set MACRO_LEF "../input/libs/gsclib045/lef/gsclib045_macro.lef"
set MBDFF_LEF "../input/libs/gsclib045/lef/gsclib045_multibitsDFF.lef"
set IOPAD_LEF "../input/libs/gsclib045/lef/giolib045.lef"

set TIMING_SLOW "../input/libs/gsclib045/timing/slow_vdd1v0_basicCells.lib"
set TIMING_FAST "../input/libs/gsclib045/timing/fast_vdd1v0_basicCells.lib"

# 2. Import design
puts "\n[1] Importing design..."
if {$USE_IO_WRAPPER} {
    puts "INFO: Using IO wrapper design (spi_master_chip with pads)"
    set init_verilog "../output/spi_master_chip.v"
    set init_design_name "spi_master_chip"
    set init_top_cell "spi_master_chip"
} else {
    puts "INFO: Using core-only design (spi_master without pads)"
    set init_verilog "../output/spi_master.v"
    set init_design_name "spi_master"
    set init_top_cell "spi_master"
}

if {$USE_IO_WRAPPER} {
    set init_lef_file "$TECH_LEF $MACRO_LEF $MBDFF_LEF $IOPAD_LEF"
    puts "INFO: Including IO pad LEF file (giolib045.lef)"
} else {
    set init_lef_file "$TECH_LEF $MACRO_LEF $MBDFF_LEF"
}
set init_mmmc_file "../input/spi_master.view"
set init_pwr_net "VDD"
set init_gnd_net "VSS"

init_design

# 3. Set design mode
puts "\n[2] Setting design mode..."
setDesignMode -process 45

# 4. Load IO placement file (if using IO wrapper)
if {$USE_IO_WRAPPER} {
    puts "\n[3a] Loading IO placement file..."
    if {[file exists "../input/spi_master.io"]} {
        loadIoFile ../input/spi_master.io
        puts "INFO: IO placement file loaded successfully"
    } else {
        puts "WARNING: IO file not found, will use auto-placement"
    }
}

# 5. Floorplan with IO area margins (150um for IO placement)
puts "\n[3] Creating floorplan with IO area..."
# Using larger margins (150um) to leave space for IO pads/rings
# Core utilization reduced to 0.30 to ensure enough space for hold fixing

if {$USE_IO_WRAPPER} {
    # Floorplan for design with IO pads
    # Margins are from core to IO boundary
    floorPlan -r 1.0 0.30 \
        -coreMargins 150 150 150 150 \
        -coreMarginsBy io
    puts "Floorplan created with IO pad ring support"
} else {
    # Floorplan for core-only design
    floorPlan -r 1.0 0.30 150 150 150 150
    puts "Floorplan created with IO margins (core-only)"
}

puts "Floorplan configuration:"
puts "  - Core utilization: 0.30 (30%)"
puts "  - Core margins: 150um (all sides)"
puts "  - Aspect ratio: 1.0"
if {$USE_IO_WRAPPER} {
    puts "  - Mode: With IO pads (pad ring)"
} else {
    puts "  - Mode: Core-only (standard pins)"
}

# 6. Commit IO pad placement (if using IO wrapper)
if {$USE_IO_WRAPPER} {
    puts "\n[4a] Committing IO pad placement..."
    if {[catch {commitIoPlacement} result]} {
        puts "WARNING: IO placement commit failed or not needed: $result"
    } else {
        puts "INFO: IO pads placed successfully"
        # Verify IO placement
        if {[catch {checkPlace -ioPlacement} result]} {
            puts "WARNING: IO placement check had issues: $result"
        }
    }
}

# 7. Add power rings (larger for IO area)
puts "\n[4] Adding power rings..."
addRing -nets {VDD VSS} -type core_rings -follow core \
    -layer {top Metal7 bottom Metal7 left Metal8 right Metal8} \
    -width {top 2.0 bottom 2.0 left 2.0 right 2.0} \
    -spacing {top 1.0 bottom 1.0 left 1.0 right 1.0} \
    -offset {top 1.0 bottom 1.0 left 1.0 right 1.0}

# 6. Add power stripes
puts "\n[5] Adding power stripes..."
addStripe -nets {VDD VSS} -layer Metal7 -direction horizontal \
    -width 1.0 -spacing 0.8 -set_to_set_distance 20 -start_from left

addStripe -nets {VDD VSS} -layer Metal8 -direction vertical \
    -width 1.0 -spacing 0.8 -set_to_set_distance 20 -start_from bottom

# 7. Place pins with more spacing for IO area
puts "\n[6] Placing pins..."
# Pins placed further from core to allow IO pad insertion
editPin -pin * -edge 0 -spacing 10 -layer 3 -spreadType side -unit MICRON

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
report_timing > ../report/io_preCTS_timing.log
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
report_timing > ../report/io_postCTS_timing.log
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
report_timing > ../report/io_postRoute_timing.log
report_timing -summary

# 18. Add filler cells
puts "\n[17] Adding filler cells..."
addFiller -cell FILL1 FILL2 FILL4 FILL8 FILL16 FILL32 FILL64 -prefix FILLER

# 19. Verify geometry and connectivity
puts "\n[18] Running verification..."
verifyGeometry > ../report/io_geometry.rpt
verifyConnectivity > ../report/io_connectivity.rpt

# 20. Final reports
puts "\n[19] Generating final reports..."
report_area > ../report/io_final_area.log
report_power > ../report/io_final_power.log
summaryReport -noHtml -outfile ../report/io_summary.rpt

# 21. Report IO placement (pin information)
puts "\n[20] Generating IO placement report..."
# Create a simple IO report
set io_report [open "../report/io_placement.rpt" w]
puts $io_report "=========================================="
puts $io_report "IO Placement Report"
puts $io_report "=========================================="
puts $io_report "Design: spi_master with IO area"
puts $io_report "IO Margin: 150um (all sides)"
puts $io_report "Pin spacing: 10um"
puts $io_report "=========================================="
close $io_report

# 22. Save design
puts "\n[21] Saving design..."
saveDesign ../output/spi_master_with_io.enc

# 23. Export GDSII
puts "\n[22] Exporting GDSII..."
# Export without map file (will use default layer mapping)
streamOut ../output/spi_master_with_io.gds \
    -libName spi_master_io \
    -structureName spi_master \
    -units 1000 \
    -mode ALL

puts "\n=========================================="
puts "Place and Route with IO Area completed!"
puts "=========================================="
puts "Configuration:"
puts "  Core Utilization: 0.30 (30%)"
puts "  IO Margins: 150um (all sides)"
puts "  Power Ring Width: 2.0um"
if {$USE_IO_WRAPPER} {
    puts "  Design Type: With IO pads (spi_master_chip)"
    puts "  IO Pads: Placed in pad ring"
} else {
    puts "  Design Type: Core-only (spi_master)"
    puts "  IO Pads: Reserved area (no physical pads)"
}
puts "=========================================="
puts "Output Files:"
puts "  GDS: ../output/spi_master_with_io.gds"
puts "  Design: ../output/spi_master_with_io.enc"
puts "  Reports: ../report/io_*.log"
puts "=========================================="
if {$USE_IO_WRAPPER} {
    puts "Note: Design includes physical IO pad cells in pad ring"
} else {
    puts "Note: IO area reserved for potential pad insertion"
}
puts "      Lower utilization (30%) allows hold fixing"
puts "=========================================="
puts ""
puts "TO USE WITH IO PADS:"
puts "  1. Check gsclib045 library for actual pad cell names"
puts "  2. Update spi_master_chip.v with correct pad cell names"
puts "  3. Synthesize spi_master_chip.v to create the wrapper netlist"
puts "  4. Set USE_IO_WRAPPER=1 in this script"
puts "  5. Re-run this script"
puts "=========================================="
