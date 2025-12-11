#==============================================================================
# Makefile for PWM Controller Design
# For EN4603 Digital IC Design Assignment
#==============================================================================

# Simulation tool
SIM = xsim
VLOG = xvlog
XELAB = xelab

# Source files
RTL_DIR = input/rtl
TB_DIR = tb
OUTPUT_DIR = output
LOG_DIR = log

RTL_SOURCES = $(RTL_DIR)/timer_module.v \
              $(RTL_DIR)/pwm_generator.v \
              $(RTL_DIR)/pwm_controller.v

TB_SOURCE = $(TB_DIR)/tb_pwm_controller.v

# Testbench top module
TB_TOP = tb_pwm_controller

# Default target
.PHONY: all
all: run

# Compile and run simulation
.PHONY: run
run: compile elaborate simulate

# Compile Verilog sources
.PHONY: compile
compile:
	@echo "Compiling RTL and testbench..."
	@mkdir -p $(LOG_DIR)
	$(VLOG) --sv $(RTL_SOURCES) $(TB_SOURCE) 2>&1 | tee $(LOG_DIR)/compile.log

# Elaborate design
.PHONY: elaborate
elaborate:
	@echo "Elaborating design..."
	$(XELAB) $(TB_TOP) -s sim_snapshot 2>&1 | tee -a $(LOG_DIR)/compile.log

# Run simulation
.PHONY: simulate
simulate:
	@echo "Running simulation..."
	$(SIM) sim_snapshot -runall 2>&1 | tee $(LOG_DIR)/simulation.log
	@echo ""
	@echo "=========================================="
	@echo "Simulation complete! Check $(LOG_DIR)/simulation.log for results"
	@echo "Waveform: pwm_controller.vcd"
	@echo "=========================================="

# Clean generated files
.PHONY: clean
clean:
	@echo "Cleaning generated files..."
	rm -rf xsim.dir
	rm -f *.jou *.log *.pb *.wdb *.vcd
	rm -f $(LOG_DIR)/*.log
	rm -f webtalk*.jou webtalk*.log
	@echo "Clean complete!"

# Help target
.PHONY: help
help:
	@echo "PWM Controller Makefile"
	@echo "======================="
	@echo "Targets:"
	@echo "  make           - Compile and run simulation (default)"
	@echo "  make run       - Compile and run simulation"
	@echo "  make compile   - Compile Verilog sources only"
	@echo "  make elaborate - Elaborate design only"
	@echo "  make simulate  - Run simulation only"
	@echo "  make clean     - Remove generated files"
	@echo "  make help      - Show this help message"

