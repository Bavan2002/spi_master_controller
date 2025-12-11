#==============================================================================
# Timing Constraints for SPI Master Controller
# Based on EN4603-Lab1 constraints format
#==============================================================================

# Create system clock with 50MHz (20ns period)
create_clock -name clk -period 20 -waveform {0 10} [get_ports clk]

# Set clock uncertainty (jitter)
set_clock_uncertainty 0.5 [get_clocks clk]

# Set clock transition
set_clock_transition 0.1 [get_clocks clk]

# Input delays (assuming external logic provides data)
# Set input delay to 25% of clock period
set input_delay_value 5.0

# Control signals
set_input_delay -clock clk $input_delay_value [get_ports start]
set_input_delay -clock clk $input_delay_value [get_ports cpol]
set_input_delay -clock clk $input_delay_value [get_ports cpha]
set_input_delay -clock clk $input_delay_value [get_ports clk_div*]

# Data inputs
set_input_delay -clock clk $input_delay_value [get_ports tx_data*]

# SPI interface input (MISO)
set_input_delay -clock clk $input_delay_value [get_ports miso]

# Output delays (assuming external logic requires stable data)
# Set output delay to 25% of clock period
set output_delay_value 5.0

# Data outputs
set_output_delay -clock clk $output_delay_value [get_ports rx_data*]
set_output_delay -clock clk $output_delay_value [get_ports rx_valid]
set_output_delay -clock clk $output_delay_value [get_ports busy]

# SPI interface outputs
set_output_delay -clock clk $output_delay_value [get_ports sclk]
set_output_delay -clock clk $output_delay_value [get_ports mosi]
set_output_delay -clock clk $output_delay_value [get_ports ss_n]

# Set input transition time (slew rate)
set_input_transition 0.2 [all_inputs]

# Set load capacitance on outputs (in pF)
set_load 0.5 [all_outputs]

# Set operating conditions
set_operating_conditions typical

# Set wire load model
set_wire_load_model -name enclosed

# Set drive strength on inputs (assuming driven by standard buffer)
set_driving_cell -lib_cell BUFX2 [all_inputs]

# Set don't touch on clock network
set_dont_touch_network [get_clocks clk]

# Set max fanout
set_max_fanout 10 [current_design]

# Set max transition
set_max_transition 0.5 [current_design]

# Reset is asynchronous - set as false path
set_false_path -from [get_ports reset]

# SPI clock is generated internally - multicycle path consideration
# (Optional: Add if timing issues arise)
# set_multicycle_path 2 -setup -from [get_ports miso]
