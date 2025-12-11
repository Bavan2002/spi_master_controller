#!/bin/bash
#==============================================================================
# Wrapper script to run Innovus P&R for PWM Controller with IO Pads
#==============================================================================

# Change to work directory
cd "$(dirname "$0")/../work" || exit 1

echo "=========================================="
echo "Running Innovus P&R for PWM Controller"
echo "=========================================="
echo ""
echo "Working directory: $(pwd)"
echo "Script: ../scripts/place_route_pwm_with_io_auto.tcl"
echo ""

# Run Innovus with the P&R script
# Use -files option (not -f) for Innovus v18.10
innovus -files ../scripts/place_route_pwm_with_io_auto.tcl

echo ""
echo "=========================================="
echo "P&R Complete - Check logs for results"
echo "=========================================="
