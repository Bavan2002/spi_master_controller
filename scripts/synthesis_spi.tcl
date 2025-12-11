#==============================================================================
# Synthesis Script for SPI Master - Lab 1
# Run this script in Genus: genus -f synthesis_spi.tcl
#==============================================================================

# 1. Setup libraries
source ../scripts/setup_spi.tcl

# 2. Read RTL design
read_hdl ../input/rtl/spi_master.v

# 3. Elaborate the design
elaborate spi_master

# 4. Check design
check_design > ../log/checkdesign.log

# 5. Uniquify
uniquify spi_master

# 6. Apply constraints
source ../input/constraints_spi.tcl

# 7. Synthesize to mapped netlist
syn_generic
syn_map

# 8. Optimize
syn_opt

# 9. Write outputs
write_hdl > ../output/spi_master.v
write_sdc > ../output/spi_master.sdc

# 10. Generate reports
report_area > ../report/area.log
report_timing -nworst 10 > ../report/timing.log
report_power > ../report/power.log
report_gates > ../report/gates.log
report_qor > ../report/qor.log

# 11. Summary
puts "=========================================="
puts "Synthesis Summary"
puts "=========================================="
report_area
puts "=========================================="
report_gates
puts "=========================================="
report_timing -summary
puts "=========================================="
puts "Synthesis completed successfully!"
puts "Outputs: ../output/spi_master.v, ../output/spi_master.sdc"
puts "Reports: ../report/*.log"
puts "==========================================="
