# PWM Controller - ASIC Design Project Summary

## Project Overview
**Module:** 3-Channel PWM Controller with Timer  
**Technology:** 45nm GPDK (gsclib045)  
**Clock:** 50MHz (20ns period)  
**Course:** EN4603 Digital IC Design Assignment

## Module Hierarchy

```
pwm_controller_chip (TOP - with IO pads)
├── pwm_controller (Core module)
│   ├── timer_module
│   │   ├── prescaler counter logic
│   │   └── period counter logic
│   ├── pwm_generator (Channel 0)
│   ├── pwm_generator (Channel 1)
│   └── pwm_generator (Channel 2)
└── IO Pad Ring
    ├── 38 input pads (PADDI)
    ├── 5 output pads (PADDO)
    ├── 6 power pads (PADVDD, PADVSS, etc.)
    └── 4 corner cells (padIORINGCORNER)
```

## Port Summary

### Inputs (38 signals):
- **System:** clk, reset (2)
- **Timer Config:** period[7:0], prescaler[7:0], timer_enable (17)
- **Channel 0:** ch0_enable, ch0_duty_cycle[7:0] (9)
- **Channel 1:** ch1_enable, ch1_duty_cycle[7:0] (9)
- **Channel 2:** ch2_enable, ch2_duty_cycle[7:0] (9)

### Outputs (5 signals):
- **PWM Outputs:** pwm_out_0, pwm_out_1, pwm_out_2 (3)
- **Status:** period_complete, timer_overflow (2)

**Total I/O:** 43 signals + power = 50 pads

## Features

1. **3 Independent PWM Channels**
   - Individual enable control per channel
   - 8-bit duty cycle resolution (0-255 = 0-100%)
   - Synchronized to shared timer

2. **Configurable Timer**
   - 8-bit period control (1-256 counts)
   - 8-bit prescaler (clock division)
   - Period complete pulse output
   - Overflow detection

3. **Hierarchical Design**
   - Reusable pwm_generator module (instantiated 3 times)
   - Separate timer_module for timing base
   - Clean module interfaces

4. **IO Pad Ring**
   - Complete pad ring with power distribution
   - Organized signal placement by function
   - gsclib045 IO pads (60um × 240um each)

## File Structure

```
spi_master_controller/  (NOTE: Will rename to pwm_controller)
├── input/
│   ├── rtl/
│   │   ├── timer_module.v              # Timer with prescaler
│   │   ├── pwm_generator.v             # Single PWM channel
│   │   ├── pwm_controller.v            # Top core module
│   │   └── pwm_controller_chip.v       # Wrapper with IO pads
│   ├── constraints_pwm.tcl             # Timing constraints
│   ├── pwm_controller.io               # IO pad placement
│   ├── pwm_controller.view             # MMMC view file
│   └── libs/gsclib045/                 # Technology library
├── tb/
│   └── tb_pwm_controller.v             # Comprehensive testbench
├── scripts/
│   ├── synthesis_pwm.tcl               # Core synthesis
│   ├── synthesis_pwm_with_pads.tcl     # Synthesis with pads
│   └── place_route_pwm_with_io_auto.tcl # P&R with IO area
├── output/                              # Generated netlists
├── report/                              # Synthesis/P&R reports
└── Makefile                            # Simulation automation
```

## Lab Workflow

### Lab 1: Synthesis
```bash
cd work
genus -f ../scripts/synthesis_pwm.tcl
```
**Outputs:** pwm_controller.v (netlist), timing/area/power reports

### Lab 2: DFT Insertion
```bash
genus -f ../scripts/dft_insertion_pwm.tcl
```
**Outputs:** pwm_controller_dft.v (with scan chains)

### Lab 3: Place & Route with IO Pads
```bash
# Step 1: Synthesize with pads
genus -f ../scripts/synthesis_pwm_with_pads.tcl

# Step 2: Place & Route
innovus -files ../scripts/place_route_pwm_with_io_auto.tcl
```
**Outputs:** pwm_controller_with_io.gds (final GDS II)

## Simulation

```bash
make                    # Compile and run testbench
make clean              # Clean generated files
```

**Tests performed:**
1. Timer period complete signal
2. Channel 0 - 25% duty cycle
3. Channel 1 - 50% duty cycle
4. Channel 2 - 75% duty cycle
5. All channels active simultaneously
6. Dynamic duty cycle changes
7. Individual channel disable
8. Prescaler functionality
9. 0% and 100% duty cycles
10. Timer disable

## Design Specifications

| Parameter | Value |
|-----------|-------|
| Clock Frequency | 50 MHz |
| Period | 20 ns |
| Input Delay | 5 ns (25%) |
| Output Delay | 5 ns (25%) |
| Clock Uncertainty | 0.5 ns |
| Duty Cycle Resolution | 8-bit (256 steps) |
| Number of PWM Channels | 3 |
| Core Utilization | 30% |
| IO Margin | 150 μm (all sides) |

## Applications

- **LED Control:** RGB LED dimming/color mixing
- **Motor Control:** 3-phase motor speed control
- **Power Regulation:** DC-DC converter control
- **Signal Generation:** Test signal generation

## Why This Design?

✅ **Hierarchical:** Clear module hierarchy with reusable components  
✅ **Practical:** Real-world application (motor/LED control)  
✅ **Educational:** Shows module instantiation and parameter passing  
✅ **Scalable:** Easy to add more channels  
✅ **Testable:** Comprehensive testbench with 11 test cases  
✅ **Complete:** Full ASIC flow from RTL to GDSII with IO pads

