# Vivado xsim simulation script for SPI Master Controller

# Create project directory
set project_dir "xsim_project"
file mkdir $project_dir

# Parse Verilog files
xvlog --work work input/rtl/spi_master.v
xvlog --work work tb_spi_master.v

# Elaborate the design
xelab -debug typical work.tb_spi_master -s tb_spi_master_sim

# Run simulation
xsim tb_spi_master_sim -runall

# Exit
quit
