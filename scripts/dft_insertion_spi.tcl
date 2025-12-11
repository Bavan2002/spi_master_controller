#==============================================================================
# DFT Insertion Script for SPI Master - Lab 2
# Run this script in Genus: genus -f dft_insertion_spi.tcl
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

# 7. Set DFT scan style
set_db dft_scan_style muxed_scan

# 8. Set DFT prefix
set_db dft_prefix dft_

# 9. Define shift enable signal
define_shift_enable -name SE -active high -create_port SE

# 10. Run DFT rule checker
check_dft_rules > ../log/dft_check_pre.log

# 11. Synthesize with scan
set_db syn_generic_effort medium
syn_generic
set_db syn_map_effort medium
syn_map

# 12. Write scan synthesized netlist
write_hdl > ../output/spi_master_scan.v

# 13. Generate reports after scan synthesis
report_area > ../report/afterscan_synthesis/area.log
report_timing -nworst 10 > ../report/afterscan_synthesis/timing.log
report_gates > ../report/afterscan_synthesis/gates.log
report_power > ../report/afterscan_synthesis/power.log

# 14. Define scan chain (single clock domain)
define_scan_chain -name spi_chain \
    -sdi scan_in \
    -sdo scan_out \
    -non_shared_output \
    -create_ports \
    -domain clk

# 15. Preview scan chains
connect_scan_chains -preview -auto_create_chains

# 16. Connect scan chains
connect_scan_chains -auto_create_chains

# 17. Perform incremental synthesis
syn_opt -incr

# 18. Check DFT rules after scan connect
check_dft_rules > ../log/dft_check_post.log

# 19. Report scan setup
report_scan_setup > ../report/scan_setup.log
report_scan_chains > ../report/scan_chains.log

# 20. Write final netlist with scan
write_hdl > ../output/spi_master_dft.v
write_sdc > ../output/spi_master_dft.sdc

# 21. Write scanDEF file for Place & Route
write_scandef > ../output/spi_master_dft.scandef

# 22. Generate final reports
report_area > ../report/afterscan_connect/area.log
report_timing -nworst 10 > ../report/afterscan_connect/timing.log
report_gates > ../report/afterscan_connect/gates.log
report_power > ../report/afterscan_connect/power.log

# 23. Write ATPG scripts
write_dft_atpg -library ../input/libs/gsclib045/timing/slow_vdd1v0_basicCells.lib

puts "DFT insertion completed successfully!"
