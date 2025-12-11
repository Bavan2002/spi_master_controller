# Makefile for SPI Master Controller Simulation with Vivado xsim

# Design files
RTL_SRC = input/rtl/spi_master.v
TB_SRC = tb_spi_master.v

# Simulation settings
WORK_LIB = work
TOP_MODULE = tb_spi_master
SIM_NAME = tb_spi_master_sim

# Output files
VCD_FILE = spi_master_sim.vcd
LOG_FILE = xsim_output.log

.PHONY: all compile elaborate sim run clean help

# Default target
all: clean run

# Compile RTL and testbench
compile:
	@echo "Compiling RTL..."
	xvlog --work $(WORK_LIB) $(RTL_SRC)
	@echo "Compiling Testbench..."
	xvlog --work $(WORK_LIB) $(TB_SRC)

# Elaborate design
elaborate: compile
	@echo "Elaborating design..."
	xelab -debug typical $(WORK_LIB).$(TOP_MODULE) -s $(SIM_NAME)

# Run simulation
sim: elaborate
	@echo "Running simulation..."
	xsim $(SIM_NAME) -runall -log $(LOG_FILE)

# Complete flow
run: sim
	@echo ""
	@echo "========================================"
	@echo "Simulation Complete!"
	@echo "========================================"
	@if [ -f $(LOG_FILE) ]; then \
		echo ""; \
		grep -A 10 "TEST RESULTS SUMMARY" $(LOG_FILE) || echo "Check $(LOG_FILE) for results"; \
	fi
	@echo ""
	@echo "Waveform: $(VCD_FILE)"
	@echo "Log file: $(LOG_FILE)"

# Clean generated files
clean:
	@echo "Cleaning simulation files..."
	@rm -rf xsim.dir .Xil *.jou *.log *.pb *.wdb $(VCD_FILE) 2>/dev/null || true
	@echo "Clean complete."

# Help target
help:
	@echo "SPI Master Controller Simulation Makefile"
	@echo ""
	@echo "Targets:"
	@echo "  make all      - Clean and run complete simulation (default)"
	@echo "  make compile  - Compile RTL and testbench"
	@echo "  make elaborate- Elaborate design"
	@echo "  make sim      - Run simulation"
	@echo "  make run      - Compile, elaborate, and simulate"
	@echo "  make clean    - Remove generated files"
	@echo "  make help     - Show this help message"
	@echo ""
	@echo "Requirements:"
	@echo "  - Vivado must be installed and sourced"
	@echo "  - Source Vivado: source /path/to/Vivado/settings64.sh"
