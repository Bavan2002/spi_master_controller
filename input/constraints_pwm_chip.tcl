#==============================================================================
# Timing Constraints for PWM Controller Chip (with IO Pads)
# Target: 50MHz operation (20ns period)
# For EN4603 Digital IC Design Assignment - Lab 3
#==============================================================================

# Clock definition - 50MHz system clock (on PAD_clk)
create_clock -name clk -period 20.0 -waveform {0 10.0} [get_ports PAD_clk]

# Clock uncertainty (jitter + skew)
set_clock_uncertainty 0.5 [get_clocks clk]

# Clock transition time
set_clock_transition 0.1 [get_clocks clk]

#==============================================================================
# Input Delays
#==============================================================================
# Set input delay for all inputs except clock
set input_delay 5.0

# Timer configuration inputs (PAD ports)
set_input_delay $input_delay -clock clk [get_ports PAD_period_*]
set_input_delay $input_delay -clock clk [get_ports PAD_prescaler_*]
set_input_delay $input_delay -clock clk [get_ports PAD_timer_enable]

# Channel 0 inputs (PAD ports)
set_input_delay $input_delay -clock clk [get_ports PAD_ch0_enable]
set_input_delay $input_delay -clock clk [get_ports PAD_ch0_duty_*]

# Channel 1 inputs (PAD ports)
set_input_delay $input_delay -clock clk [get_ports PAD_ch1_enable]
set_input_delay $input_delay -clock clk [get_ports PAD_ch1_duty_*]

# Channel 2 inputs (PAD ports)
set_input_delay $input_delay -clock clk [get_ports PAD_ch2_enable]
set_input_delay $input_delay -clock clk [get_ports PAD_ch2_duty_*]

#==============================================================================
# Output Delays
#==============================================================================
# Set output delay for all outputs
set output_delay 5.0

# PWM outputs (PAD ports)
set_output_delay $output_delay -clock clk [get_ports PAD_pwm_out_*]

# Status outputs (PAD ports)
set_output_delay $output_delay -clock clk [get_ports PAD_period_complete]
set_output_delay $output_delay -clock clk [get_ports PAD_timer_overflow]

#==============================================================================
# Reset Path (Asynchronous)
#==============================================================================
# Reset is asynchronous, set as false path
set_false_path -from [get_ports PAD_reset]

#==============================================================================
# Design Rule Constraints
#==============================================================================
# Set maximum fanout
set_max_fanout 10 [current_design]

# Set maximum transition time
set_max_transition 0.5 [current_design]

#==============================================================================
# Load Constraints
#==============================================================================
# Set output load (capacitance in pF)
# Note: IO pads have their own output drivers, so load is minimal
set_load 0.05 [all_outputs]

#==============================================================================
# False Paths for Power Supply Signals
#==============================================================================
# Power supply nets are not timing paths
# These are supply1/supply0 nets connected to power pads

#==============================================================================
# Design Information
#==============================================================================
# Design: PWM Controller Chip (with IO Pads)
# Top Module: pwm_controller_chip
# 
# External PAD Ports:
#   Inputs:  38 PAD ports (system + configuration + 3 channels)
#   Outputs: 5 PAD ports (3 PWM + 2 status)
#
# Power Pads: 6 (PADVDD x2, PADVSS x2, PADVDDIOR x1, PADVSSIOR x1)
# Corner Pads: 4 (padIORINGCORNER)
#
# Clock: 50MHz (20ns period) on PAD_clk
# Input/Output delays: 5ns (25% of clock period)
# Clock uncertainty: 0.5ns
#==============================================================================
