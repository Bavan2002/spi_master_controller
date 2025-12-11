#==============================================================================
# Timing Constraints for PWM Controller
# Target: 50MHz operation (20ns period)
# For EN4603 Digital IC Design Assignment
#==============================================================================

# Clock definition - 50MHz system clock
create_clock -name clk -period 20.0 -waveform {0 10.0} [get_ports clk]

# Clock uncertainty (jitter + skew)
set_clock_uncertainty 0.5 [get_clocks clk]

# Clock transition time
set_clock_transition 0.1 [get_clocks clk]

#==============================================================================
# Input Delays
#==============================================================================
# Set input delay for all inputs except clock
set input_delay 5.0

# Timer configuration inputs
set_input_delay $input_delay -clock clk [get_ports period]
set_input_delay $input_delay -clock clk [get_ports prescaler]
set_input_delay $input_delay -clock clk [get_ports timer_enable]

# Channel 0 inputs
set_input_delay $input_delay -clock clk [get_ports ch0_enable]
set_input_delay $input_delay -clock clk [get_ports ch0_duty_cycle]

# Channel 1 inputs
set_input_delay $input_delay -clock clk [get_ports ch1_enable]
set_input_delay $input_delay -clock clk [get_ports ch1_duty_cycle]

# Channel 2 inputs
set_input_delay $input_delay -clock clk [get_ports ch2_enable]
set_input_delay $input_delay -clock clk [get_ports ch2_duty_cycle]

#==============================================================================
# Output Delays
#==============================================================================
# Set output delay for all outputs
set output_delay 5.0

# PWM outputs
set_output_delay $output_delay -clock clk [get_ports pwm_out_0]
set_output_delay $output_delay -clock clk [get_ports pwm_out_1]
set_output_delay $output_delay -clock clk [get_ports pwm_out_2]

# Status outputs
set_output_delay $output_delay -clock clk [get_ports period_complete]
set_output_delay $output_delay -clock clk [get_ports timer_overflow]

#==============================================================================
# Reset Path (Asynchronous)
#==============================================================================
# Reset is asynchronous, set as false path
set_false_path -from [get_ports reset]

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
set_load 0.1 [all_outputs]

#==============================================================================
# Operating Conditions
#==============================================================================
# These will be set by library (slow/fast corners)
# Commented out as they may cause issues with some tools
# set_operating_conditions typical
# set_wire_load_model -name typical

#==============================================================================
# Area Constraints
#==============================================================================
# No specific area constraint - let tool optimize

#==============================================================================
# Design Information
#==============================================================================
# Design: PWM Controller
# Ports:
#   Inputs:  11 (clk, reset, period[7:0], prescaler[7:0], timer_enable,
#                ch0_enable, ch0_duty_cycle[7:0],
#                ch1_enable, ch1_duty_cycle[7:0],
#                ch2_enable, ch2_duty_cycle[7:0])
#   Outputs: 5 (pwm_out_0, pwm_out_1, pwm_out_2,
#                period_complete, timer_overflow)
#
# Clock: 50MHz (20ns period)
# Input/Output delays: 5ns (25% of clock period)
# Clock uncertainty: 0.5ns
#==============================================================================
