#==============================================================================
# Library Setup Script
# This script sets up the library paths and files for synthesis
#==============================================================================

puts ">>> Setting up library paths..."
set_db init_lib_search_path {../input/libs/gsclib045/lef ../input/libs/gsclib045/timing ../input/libs/gsclib045/qrc/qx}

puts ">>> Setting up timing libraries..."
set_db library {slow_vdd1v0_basicCells.lib fast_vdd1v0_basicCells.lib}

puts ">>> Setting up LEF libraries (including IO pads)..."
set_db lef_library {gsclib045_tech.lef gsclib045_macro.lef gsclib045_multibitsDFF.lef giolib045.lef}

puts ">>> Setting up QRC technology file..."
set_db qrc_tech_file gpdk045.tch

puts "Library setup complete!"
