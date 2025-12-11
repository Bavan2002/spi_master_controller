#==============================================================================
# Place and Route Script for SPI Master - Lab 3
# Run this script in Innovus
#==============================================================================

# This script should be executed interactively or step-by-step in Innovus
# Based on the Lab 3 manual procedures

# 1. Import Design
# File -> Import Design
#   - Verilog: ../input/spi_master_dft.v
#   - Top Cell: spi_master
#   - LEF Files: gsclib045_tech.lef, gsclib045_multibitsDFF.lef, gsclib045_macro.lef
#   - Power: VDD, GND
#   - MMMC: ../input/spi_master.view

# 2. Read scanDEF
defIn ../input/spi_master_dft.scandef

# 3. Set design mode
setDesignMode -process 45

# 4. Specify floorplan
# Floorplan -> Specify Floorplan
#   - Aspect Ratio: 1.0
#   - Core Utilization: 0.4
#   - Core Margins: 5 microns all sides

# 5. Add power rings
# Power Planning -> Add Rings
#   - Nets: VDD GND
#   - Width: 1.0, Spacing: 0.8, Offset: 0.8

# 6. Add power stripes
# Power Planning -> Add Stripes
#   - Horizontal (Metal 7): Width 1.0, Spacing 0.8
#   - Vertical (Metal 8): Width 1.0, Spacing 0.8

# 7. Pin placement
# Edit -> Pin Editor
# Assign pins to edges with 5 micron spacing

# 8. Place standard cells
# Place -> Place Standard Cell
#   - Run Full Placement
#   - Include Pre-Place Optimization

# 9. Route power nets
# Route -> Special Route
#   - Nets: VDD GND

# 10. Clock Tree Synthesis
ccopt_design

# 11. Scan reorder
# Place -> Scan Chain -> Reorder

# 12. Post-CTS timing analysis
# Timing -> Report Timing (Hold analysis)

# 13. Signal routing
# Route -> NanoRoute -> Route

# 14. Post-route timing analysis
setAnalysisMode -analysisType onChipVariation
# Timing -> Report Timing

# 15. Place filler cells
# Place -> Physical Cell -> Add Filler

# 16. Verification
# Verify -> Verify Geometry
# Verify -> Verify Connectivity

# 17. Export GDSII
# File -> Save GDS/OASIS
# Output: ../output/spi_master.gds
