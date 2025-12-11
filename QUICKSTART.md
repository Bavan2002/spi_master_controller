# PWM Controller - Quick Start Guide

## ✅ Project Complete - All 11 Tests Passed!

---

## 🚀 Run Commands

### Simulation
```bash
cd /home/akitha/Desktop/spi_master_controller
make              # Run all 11 tests
make clean        # Clean generated files
```

### Lab 1: Synthesis
```bash
cd work
genus -f ../scripts/synthesis_pwm.tcl
# Output: ../output/pwm_controller.v
```

### Lab 2: DFT Insertion
```bash
genus -f ../scripts/dft_insertion_pwm.tcl
# Output: ../output/pwm_controller_dft.v, pwm_controller_dft.scandef
```

### Lab 3: P&R with IO Pads
```bash
# Step 1: Synthesize wrapper with pads
genus -f ../scripts/synthesis_pwm_with_pads.tcl
# Output: ../output/pwm_controller_chip.v

# Step 2: Place & Route
innovus -f ../scripts/place_route_pwm_with_io_auto.tcl
# Output: ../output/pwm_controller_with_io.gds
```

---

## 📊 Design Summary

**Module:** pwm_controller (3-channel PWM with timer)

**Hierarchy:**
- pwm_controller_chip (wrapper with 50 IO pads)
  - pwm_controller (core)
    - timer_module (1× shared timer)
    - pwm_generator (3× channels)

**Specs:**
- Clock: 50MHz
- Channels: 3 independent PWM outputs
- Resolution: 8-bit duty cycle (0-255)
- I/O: 38 inputs + 5 outputs = 43 signals
- Pads: 50 total (43 signal + 6 power + 4 corners)

---

## 📁 Key Files

| File | Purpose |
|------|---------|
| `input/rtl/pwm_controller.v` | Top core module |
| `input/rtl/timer_module.v` | Timer with prescaler |
| `input/rtl/pwm_generator.v` | Single PWM channel |
| `input/rtl/pwm_controller_chip.v` | Wrapper with IO pads |
| `tb/tb_pwm_controller.v` | Testbench (11 tests) |
| `input/constraints_pwm.tcl` | Timing constraints |
| `input/pwm_controller.view` | MMMC view file |
| `input/pwm_controller.io` | 50-pad placement |

---

## 🧪 Test Results

**11/11 Tests Passed ✅**

1. Timer period complete ✅
2. Channel 0 @ 25% duty ✅
3. Channel 1 @ 50% duty ✅
4. Channel 2 @ 75% duty ✅
5. All channels active ✅
6. Dynamic duty change ✅
7. Individual disable ✅
8. Prescaler function ✅
9. 0% duty cycle ✅
10. 100% duty cycle ✅
11. Timer disable ✅

---

## 💡 Applications

- RGB LED control (3 color channels)
- 3-phase motor control
- DC-DC converter regulation
- Multi-servo control

---

## 📝 Lab Report Tips

**Hierarchy Explanation:**
"The PWM controller uses a 3-level hierarchical architecture. A shared timer_module provides the timing base for three instantiated pwm_generator modules, demonstrating code reuse and modular design principles."

**Key Benefits:**
- Modularity for easier debugging
- Reusability (pwm_generator used 3×)
- Scalability (easy to add channels)
- Clear interfaces between modules

---

## ✨ Status: READY FOR LABS 1, 2, 3

All files created, tested, and verified.
Proceed with synthesis → DFT → P&R!
