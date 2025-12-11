#==============================================================================
# Setup Script for SPI Master Synthesis
# Place this in scripts/setup_spi.tcl
#==============================================================================

# Set search paths for libraries
set_db init_lib_search_path {../input/libs/gsclib045/lef ../input/libs/gsclib045/timing ../input/libs/gsclib045/qrc/qx}

# Set timing libraries (slow and fast corners)
set_db library {slow_vdd1v0_basicCells.lib fast_vdd1v0_basicCells.lib}

# Set LEF libraries (include giolib045.lef for IO pads)
set_db lef_library {gsclib045_tech.lef gsclib045_macro.lef gsclib045_multibitsDFF.lef giolib045.lef}

# Set QRC tech file
set_db qrc_tech_file gpdk045.tch
