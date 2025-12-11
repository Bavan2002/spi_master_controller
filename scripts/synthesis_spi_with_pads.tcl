#==============================================================================
# Synthesis Script for SPI Master with IO Pads - Lab 3
# Run this script in Genus: genus -f synthesis_spi_with_pads.tcl
#==============================================================================

puts "=========================================="
puts "SPI Master Synthesis with IO Pads"
puts "=========================================="

# 1. Setup libraries
source ../scripts/setup_spi.tcl

# 2. Read RTL design - Both core and wrapper
puts "\n[1] Reading RTL files..."
read_hdl ../input/rtl/spi_master.v
read_hdl ../input/rtl/spi_master_chip.v

# 3. Elaborate the wrapper design (top-level with IO pads)
puts "\n[2] Elaborating spi_master_chip (wrapper with IO pads)..."
elaborate spi_master_chip

# 4. Check design
puts "\n[3] Checking design..."
check_design > ../log/checkdesign_with_pads.log

# 5. Apply constraints
puts "\n[4] Applying constraints..."
source ../input/constraints_spi.tcl

# 6. Synthesize
puts "\n[5] Running synthesis..."
set_db syn_generic_effort medium
syn_generic

set_db syn_map_effort medium
syn_map

# 7. Optimize
puts "\n[6] Running optimization..."
set_db syn_opt_effort medium
syn_opt

# 8. Write outputs
puts "\n[7] Writing outputs..."
write_hdl > ../output/spi_master_chip.v
write_sdc > ../output/spi_master_chip.sdc

# 9. Generate reports
puts "\n[8] Generating reports..."
report_area > ../report/synthesis_with_pads_area.log
report_timing -nworst 10 > ../report/synthesis_with_pads_timing.log
report_power > ../report/synthesis_with_pads_power.log
report_gates > ../report/synthesis_with_pads_gates.log

# 10. Summary
puts "\n=========================================="
puts "Synthesis with IO Pads completed!"
puts "=========================================="
puts "Output files:"
puts "  Netlist: ../output/spi_master_chip.v"
puts "  SDC:     ../output/spi_master_chip.sdc"
puts "Reports:"
puts "  Area:    ../report/synthesis_with_pads_area.log"
puts "  Timing:  ../report/synthesis_with_pads_timing.log"
puts "  Power:   ../report/synthesis_with_pads_power.log"
puts "  Gates:   ../report/synthesis_with_pads_gates.log"
puts "=========================================="
puts ""
puts "Next steps:"
puts "  1. Review timing report to ensure constraints are met"
puts "  2. Run Place & Route with: cd work && innovus -files ../scripts/place_route_with_io_auto.tcl"
puts "=========================================="

# Exit Genus
exit
