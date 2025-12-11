#!/bin/bash

# Script to run Vivado xsim simulation for SPI Master Controller

echo "========================================="
echo "  SPI Master Controller - xsim Test"
echo "========================================="
echo ""

# Clean previous simulation files
echo "Cleaning previous simulation files..."
rm -rf xsim.dir .Xil *.jou *.log *.pb *.wdb *.vcd 2>/dev/null

# Check if Vivado is available
if ! command -v xvlog &> /dev/null; then
    echo "ERROR: Vivado xsim not found in PATH"
    echo "Please source Vivado settings: source /path/to/Vivado/settings64.sh"
    exit 1
fi

echo "Step 1: Compiling RTL (spi_master.v)..."
xvlog --work work input/rtl/spi_master.v
if [ $? -ne 0 ]; then
    echo "ERROR: RTL compilation failed"
    exit 1
fi

echo ""
echo "Step 2: Compiling Testbench (tb_spi_master.v)..."
xvlog --work work tb_spi_master.v
if [ $? -ne 0 ]; then
    echo "ERROR: Testbench compilation failed"
    exit 1
fi

echo ""
echo "Step 3: Elaborating design..."
xelab -debug typical work.tb_spi_master -s tb_spi_master_sim
if [ $? -ne 0 ]; then
    echo "ERROR: Elaboration failed"
    exit 1
fi

echo ""
echo "Step 4: Running simulation..."
echo "========================================="
xsim tb_spi_master_sim -runall -log xsim_output.log

echo ""
echo "========================================="
echo "Simulation completed!"
echo "Check xsim_output.log for detailed results"
echo "Waveform saved to: spi_master_sim.vcd"
echo "========================================="

# Display test summary from log
if [ -f xsim_output.log ]; then
    echo ""
    echo "Test Summary:"
    grep -A 10 "TEST RESULTS SUMMARY" xsim_output.log
fi
