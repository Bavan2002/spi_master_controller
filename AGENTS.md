# Agent Guidelines - PWM Controller ASIC Design

## Build/Test Commands
- **Run simulation**: `make` or `make run` (Vivado xsim required)
- **Single test**: Simulation runs all 11 tests automatically via `tb/tb_pwm_controller.v`
- **Clean**: `make clean`
- **Synthesis**: `cd work && genus -f ../scripts/synthesis_pwm.tcl`
- **Synthesis with pads**: `cd work && genus -f ../scripts/synthesis_pwm_with_pads.tcl`
- **Place & Route**: `cd work && innovus -f ../scripts/place_route_pwm_with_io_auto.tcl`

## Code Style - Verilog RTL

### Module Structure
- Header comment with module description and project context
- Timescale: `` `timescale 1ns/1ps ``
- Port declarations: Grouped by function (Clock/Reset, Configuration, Control, Outputs)
- Comment each port with its purpose

### Naming Conventions
- **Signals**: `snake_case` (e.g., `duty_cycle`, `timer_enable`, `period_complete`)
- **Modules**: `snake_case` (e.g., `pwm_controller`, `timer_module`, `pwm_generator`)
- **Parameters**: `UPPERCASE` with localparam (e.g., `MAX_COUNT`, `DEFAULT_PERIOD`)
- **Active-high signals**: Default (e.g., `reset`, `enable`)
- **Registers**: `reg` type with descriptive names
- **Wires**: Explicit `wire` for module interconnects

### Formatting
- **Indentation**: 4 spaces (no tabs)
- **Always blocks**: Separate sensitivity list style - `always @(posedge clk or posedge reset)` for sequential, `always @(*)` for combinational
- **Module instances**: Named instances with descriptive identifiers (e.g., `timer_inst`, `pwm_ch0`)
- **Comments**: `//` for single line, use section headers with `//===...===`

### Design Patterns
- **Hierarchy**: Top module instantiates submodules (timer + 3x PWM generators)
- **Reset**: Asynchronous active-high reset for all sequential elements
- **Clock domains**: Single clock domain design (50MHz system clock)
- **Reusability**: pwm_generator module instantiated 3 times
- **Parameterization**: 8-bit resolution for duty cycle and timer values

### Error Handling
- All registers initialized in reset condition
- Counter overflow detection
- Default values for all configuration registers
- Width matching: Explicit bit widths (e.g., `8'd0`, `8'd255`)

## Module Hierarchy

```
pwm_controller (TOP CORE)
├── timer_module
│   ├── prescaler_count (8-bit)
│   └── counter (8-bit)
├── pwm_generator (ch0)
├── pwm_generator (ch1)
└── pwm_generator (ch2)

pwm_controller_chip (WITH IO PADS)
├── 38x PADDI (input pads)
├── 5x PADDO (output pads)  
├── 6x Power pads (PADVDD, PADVSS, etc.)
├── 4x padIORINGCORNER
└── pwm_controller (core instance)
```

## Technology
- **Target**: 45nm GPDK (gsclib045) for synthesis/P&R
- **Clock**: 50MHz (20ns period) system clock
- **Resolution**: 8-bit duty cycle (0-255 = 0-100%)
- **Channels**: 3 independent PWM outputs
- **DFT**: Design supports scan chain insertion (Lab 2)
- **IO Pads**: giolib045 (60μm × 240μm per pad)

## Port Naming Conventions
- **System**: `clk`, `reset`
- **Timer**: `period[7:0]`, `prescaler[7:0]`, `timer_enable`
- **Channels**: `ch0_enable`, `ch0_duty_cycle[7:0]`, etc.
- **Outputs**: `pwm_out_0`, `pwm_out_1`, `pwm_out_2`
- **Status**: `period_complete`, `timer_overflow`
- **Pads**: `PAD_<signal_name>` for external pads

## Signal Descriptions

### Timer Configuration
- `period[7:0]`: PWM period in timer counts (1-256)
- `prescaler[7:0]`: Clock divider value (0 = no division)
- `timer_enable`: Master enable for timer

### Channel Control (per channel)
- `chN_enable`: Enable PWM output for channel N
- `chN_duty_cycle[7:0]`: Duty cycle (0-255)
  - 0 = always LOW (0%)
  - 128 = 50% duty
  - 255 = always HIGH (100%)

### Status Outputs
- `period_complete`: Single-cycle pulse when timer period completes
- `timer_overflow`: Flag when counter reaches 255 (max value)
- `pwm_out_N`: PWM output signal for channel N

## Applications
- RGB LED brightness/color control (3 channels)
- 3-phase motor speed control
- DC-DC converter switching control
- Multi-channel servo control
