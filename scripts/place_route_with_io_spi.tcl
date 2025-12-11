#==============================================================================
# Modified Place & Route Script with IO Area - Lab 3
# For SPI Master with IO Pads
#==============================================================================

# This script should be run interactively in Innovus
# Follow along with the commands step-by-step

#------------------------------------------------------------------------------
# PRELIMINARY SETUP
#------------------------------------------------------------------------------

# 1. Import design (File -> Import Design)
#    OR use command:
# set init_verilog ../input/spi_master_with_pads.v
# set init_top_cell spi_master_chip
# set init_lef_file {../input/libs/gsclib045/lef/gsclib045_tech.lef \
#                    ../input/libs/gsclib045/lef/gsclib045_multibitsDFF.lef \
#                    ../input/libs/gsclib045/lef/gsclib045_macro.lef}
# set init_pwr_net VDD
# set init_gnd_net GND
# set init_mmmc_file ../input/spi_master.view
# init_design

# 2. Read scanDEF
defIn ../input/spi_master_dft.scandef

# 3. Set design mode
setDesignMode -process 45

#------------------------------------------------------------------------------
# FLOORPLAN WITH IO AREA
#------------------------------------------------------------------------------

# METHOD 1: Load IO placement file and specify floorplan
# -------------------------------------------------------
puts "INFO: Creating floorplan with IO area..."

# Load IO placement file
loadIoFile ../input/spi_master.io

# Calculate die size based on core requirements + IO area
# Assuming:
#   - Core area needed: ~800 x 800 um (based on 0.4 utilization)
#   - Pad width: ~120 um
#   - Core-to-IO margin: 150 um for routing
#   - Total margin per side: 150 um (core margin) + 120 um (pad) = 270 um
#   - Die size: 800 + 2*270 = ~1340 um per side

# Specify floorplan with IO boundary
floorPlan -site CoreSite \
    -r 1.0 \
    -coreUtilization 0.4 \
    -coreMargins 150 150 150 150 \
    -coreSpacing 10 \
    -coreMarginsBy io

# Alternative: Specify absolute sizes
# floorPlan -d 1340 1340 150 150 150 150

puts "Floorplan created with IO area"

# Commit IO placement from .io file
commitIoPlacement

# Check IO placement
checkPlace -ioPlacement

# OR METHOD 2: GUI-based IO placement
# ------------------------------------
# If not using .io file, place IOs via GUI:
# 1. Floorplan -> Specify Floorplan
#    - Select "Specify by: Die Size"
#    - Width: 1340, Height: 1340
#    - Core Margins by: Core to IO Boundary
#    - Core to Left/Right/Top/Bottom: 150 microns
#
# 2. Edit -> Pin Editor
#    - Place pins around the perimeter with spacing

#------------------------------------------------------------------------------
# CREATE PAD RING AREA
#------------------------------------------------------------------------------

# Define IO row for pad placement (if using pad cells)
# This creates a ring around the core for IO pads
puts "INFO: Creating IO pad rows..."

# Create IO rows on all four sides
# Note: Adjust coordinates based on your floorplan
createIoRow -site IOSite -bottom
createIoRow -site IOSite -top
createIoRow -site IOSite -left
createIoRow -site IOSite -right

# Place IO pad instances
# Note: This assumes pads are already instantiated in top-level netlist
placeInstance corner_ll -fixed 0 0
placeInstance corner_lr -fixed [expr [dbGet top.fPlan.box_urx]] 0
placeInstance corner_ul -fixed 0 [expr [dbGet top.fPlan.box_ury]]
placeInstance corner_ur -fixed [expr [dbGet top.fPlan.box_urx]] [expr [dbGet top.fPlan.box_ury]]

#------------------------------------------------------------------------------
# POWER PLANNING (Including IO Ring)
#------------------------------------------------------------------------------

puts "INFO: Adding power rings and stripes..."

# Add core power rings
addRing -nets {VDD GND} \
    -type core_rings \
    -layer {top Metal7 bottom Metal7 left Metal8 right Metal8} \
    -width 2.0 \
    -spacing 1.0 \
    -offset 1.0

# Add IO ring (separate from core ring)
# This connects power to IO pads
addRing -nets {VDDIO GNDIO} \
    -type pad_rings \
    -layer {top Metal8 bottom Metal8 left Metal7 right Metal7} \
    -width 3.0 \
    -spacing 1.5 \
    -offset 0.5

# Add power stripes (as before)
addStripe -nets {VDD GND} \
    -layer Metal7 \
    -direction horizontal \
    -width 1.0 \
    -spacing 0.8 \
    -number_of_sets 3 \
    -start_from bottom

addStripe -nets {VDD GND} \
    -layer Metal8 \
    -direction vertical \
    -width 1.0 \
    -spacing 0.8 \
    -number_of_sets 3 \
    -start_from left

# Connect power to IO pads
sroute -nets {VDD GND VDDIO GNDIO} -padPinUse power

puts "Power planning with IO rings completed"

#------------------------------------------------------------------------------
# REST OF PLACE & ROUTE FLOW (As before)
#------------------------------------------------------------------------------

# 5. Place standard cells (core cells only, not pads)
setPlaceMode -place_global_place_io_pins false
placeDesign -prePlaceOpt

# 6. Route power
sroute -nets {VDD GND}

# 7. Clock Tree Synthesis
ccopt_design

# 8. Scan reorder
ecoScanReorder -clockTreeAware

# 9. Timing analysis
timeDesign -postCTS -hold

# 10. Signal routing
routeDesign

# 11. Timing analysis
setAnalysisMode -analysisType onChipVariation
timeDesign -postRoute

# 12. Place filler cells (core area only)
addFiller -cell {FILL*} -prefix FILLER

# 13. Verification
verifyGeometry
verifyConnectivity

# 14. Export GDSII with IO pads
streamOut ../output/spi_master_with_pads.gds \
    -mapFile ../input/streamOut.map \
    -libName spilib \
    -merge {../input/libs/gsclib045/gds/io_pads.gds}

puts "Place & Route with IO area completed successfully!"

#==============================================================================
# VERIFICATION CHECKS
#==============================================================================

# Check that IO pads are properly placed
report_io > ../report/io_placement.rpt

# Check pad ring integrity
checkPlace -all

# Verify power connections to pads
verifyPower -rails VDD -verbose

puts "All checks completed!"
