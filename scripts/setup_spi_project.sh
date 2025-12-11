#!/bin/bash
#==============================================================================
# SPI Master Project - Automated Directory Setup
# Run: bash setup_spi_project.sh
#==============================================================================

echo "=========================================="
echo "SPI Master Project - Directory Setup"
echo "=========================================="
echo ""

# Project directory name
PROJECT_DIR="spi_master_project"

echo "Creating project directory structure..."

# Create all necessary directories
mkdir -p ${PROJECT_DIR}/{input/rtl,input/libs,scripts,output,report,log,work}
mkdir -p ${PROJECT_DIR}/output/{part1,exercise1_without_preopt,exercise3_with_io}
mkdir -p ${PROJECT_DIR}/output/{exercise_2chains,part1_with_preopt}
mkdir -p ${PROJECT_DIR}/report/{initial,part1_afterscan_synthesis,part1_afterscan_connect}
mkdir -p ${PROJECT_DIR}/report/{part1_preCTS,part1_postCTS,part1_postRoute}
mkdir -p ${PROJECT_DIR}/report/{part1_with_preopt,exercise1_without_preopt,exercise3_with_io}
mkdir -p ${PROJECT_DIR}/report/{exercise1_25MHz,exercise1_50MHz,exercise1_75MHz,exercise1_100MHz}
mkdir -p ${PROJECT_DIR}/report/{exercise2_low_effort,exercise2_medium_effort,exercise2_high_effort}

echo "✓ Directory structure created"

# Check if library files exist
LIB_PATH="../labs/input/libs"
if [ -d "$LIB_PATH" ]; then
    echo ""
    echo "Found library files, copying..."
    cp -r $LIB_PATH ${PROJECT_DIR}/input/
    echo "✓ Libraries copied"
else
    echo ""
    echo "⚠ Library files not found at $LIB_PATH"
    echo "  Please manually copy gsclib045 library to:"
    echo "  ${PROJECT_DIR}/input/libs/"
fi

echo ""
echo "=========================================="
echo "Directory structure ready!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Copy these files to their locations:"
echo "   - spi_master.v           → ${PROJECT_DIR}/input/rtl/"
echo "   - tb_spi_master.v        → ${PROJECT_DIR}/input/rtl/"
echo "   - constraints_spi.tcl    → ${PROJECT_DIR}/input/"
echo "   - spi_master.view        → ${PROJECT_DIR}/input/"
echo "   - setup_spi.tcl          → ${PROJECT_DIR}/scripts/"
echo "   - lab1_spi_complete_auto.tcl → ${PROJECT_DIR}/scripts/"
echo "   - lab2_spi_complete_auto.tcl → ${PROJECT_DIR}/scripts/"
echo "   - lab3_spi_complete_auto.tcl → ${PROJECT_DIR}/scripts/"
echo ""
echo "2. Copy library files (if not done automatically):"
echo "   - gsclib045/            → ${PROJECT_DIR}/input/libs/"
echo ""
echo "3. Run the labs:"
echo "   $ cd ${PROJECT_DIR}/work"
echo "   $ genus -f ../scripts/lab1_spi_complete_auto.tcl | tee ../log/lab1_spi_execution.log"
echo ""
echo "=========================================="
