# Makefile is just set of rules
# boot.s is run before test.c
# link.ld decides where code and data live
# boot.s calls main explicitely
# boot.s is needed because C assumes Stack pointer is valid and memory is initialized

# Format:
#target: dependency1 dependency2
#<TAB>command to build target

# ?= means set only if not already set
# Next 3 are for cocotb
SIM ?= verilator
TOPLEVEL_LANG ?= verilog
# WAVES = 1 			# waveform dumping enabled
WAVES = 0
VERILOG_SOURCES := $(shell find $(PWD)/rtl -type f \( -name "*.v" -o -name "*.sv" \))
VERILOG_INCLUDE := $(shell find $(PWD)/rtl -type d -printf '-I%p ')

# VERILOG_SOURCES := $(shell find $(PWD)/rtl -type f \( -name "*.v" -o -name "*.sv" -o -name "*.vh" -o -name "*.svh" \))
# INCDIRS := $(shell find $(PWD)/rtl -type f \( -name "*.vh" -o -name "*.svh" \) -exec dirname {} \; | sort -u)
# VERILATOR_INC := $(foreach dir,$(INCDIRS),-I$(dir))
# EXTRA_ARGS += $(VERILATOR_INC) -j 8

# Include directories for macros

# Extra args for Verilator


# This tells Verilator: Generate waveforms (--trace)
# Include structs in waves
# Use .fst format (fast)
# Enable timing
# Use 8 threads
# EXTRA_ARGS += --trace --trace-structs --trace-fst --timing -j 8 # DEBUGGING
EXTRA_ARGS += -j 8


# Connects cocotb test.py -> TB in verilog
TOPLEVEL = TB
MODULE = test

all:
	@echo "Select out of following options:"
	@echo "  make coremark"
	@echo "  make dhrystone"
	@echo "  make riscv-tests"
	@echo "  make branch_test"

.PHONY: custom coremark dhrystone riscv-tests branch_test
custom: del
	$(MAKE) -C custom_c_test
	$(MAKE) mems

coremark: del
	$(MAKE) -C coremark
	$(MAKE) mems

dhrystone: del
	$(MAKE) -C dhrystone
	$(MAKE) mems

riscv-tests: del
	$(MAKE) -C riscv-tests
	$(MAKE) mems

branch_test: del
	$(MAKE) -C branch_test
	$(MAKE) mems

# If you type make: it runs first target
mems: code.mem data.mem sim

# C/ASM → ELF → binary → hex → loaded into Verilog memories → executed by your CPU
# ELF -> Executable and Linkable Format -> Final compiled programme -> A complete description of a program and how it should live in memory.
# We extract pieces from elf as needed
# Dump is disassembled instructions in human readable hex -> Used for debugging

# dump .text section as raw bytes to code.bin - Extracts instructions only
code.bin:
		riscv32-unknown-elf-objcopy -O binary --only-section=.text rv32i_test.elf code.bin

# dump .data and .sdata sections to data.bin (RAM image) (doesn't extract .bss as it's zero-init by def)
data.bin: 
		riscv32-unknown-elf-objcopy -O binary -j .data -j .sdata rv32i_test.elf data.bin

# read code.bin as 4-byte words and print each word as 8 hex digits per line, so code.mem has 32-bit word per line
code.mem: code.bin rv32i_test.dump
		hexdump -v -e '1/4 "%08x\n"' code.bin > code.mem

# produce one byte per line (2 hex digits) - suggests data memory is byte-addressable
data.mem: data.bin
		hexdump -v -e '1/4 "%08x\n"' data.bin > data.mem

# Cocotb's makefile calls verilator and runs Python against the build simulation
sim: code.mem data.mem
	$(MAKE) -f $(shell cocotb-config --makefiles)/Makefile.sim \
		SIM=$(SIM) \
		TOPLEVEL_LANG=$(TOPLEVEL_LANG) \
		TOPLEVEL=$(TOPLEVEL) \
		MODULE=$(MODULE) \
		WAVES=$(WAVES) \
		VERILOG_SOURCES="$(VERILOG_SOURCES)" \
		EXTRA_ARGS="$(EXTRA_ARGS)"

del:
	-rm -rf *.o *.mem *.bin *.elf *dump* *.xml sim_build

.DEFAULT_GOAL := all
