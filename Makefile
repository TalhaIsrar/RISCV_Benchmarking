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
<<<<<<< HEAD
WAVES = 1 			# waveform dumping enabled
=======
WAVES = 1 # Enable waveform ddebugging

# Files passed to verilator
>>>>>>> 0cff64f (Added comments)
VERILOG_SOURCES += $(PWD)/rtl/*.sv
VERILOG_SOURCES += $(PWD)/rtl/core/*.sv

# This tells Verilator: Generate waveforms (--trace)
# Include structs in waves
# Use .fst format (fast)
# Enable timing
# Use 8 threads
EXTRA_ARGS += --trace --trace-structs --trace-fst --timing -j 8
<<<<<<< HEAD
TOPLEVEL = TB 		# top module name
MODULE = test 		# referring to test.py for Cocotb
=======

# Connects cocotb test.py -> TB in verilog
TOPLEVEL = TB
MODULE = test
>>>>>>> 0cff64f (Added comments)

# If you type make: it runs first target
all: code.mem data.mem sim

<<<<<<< HEAD
# building the executable
rv32i_test.elf:link.ld boot.s test.c 
		riscv64-unknown-elf-gcc -nostdlib -nostartfiles -O3 -march=rv32i_zicsr -mabi=ilp32 -T link.ld boot.s test.c -o rv32i_test.elf
# disassembly dump (debug helper)
rv32i_test.dump: rv32i_test.elf 
		riscv64-unknown-elf-objdump -D rv32i_test.elf > rv32i_test.dump
# dump .text section as raw bytes to code.bin
code.bin:rv32i_test.elf 
		riscv64-unknown-elf-objcopy -O binary --only-section=.text rv32i_test.elf code.bin
# dump .data and .sdata sections to data.bin (doesn't extract .bss as it's zero-init by def)
data.bin: rv32i_test.elf 
		riscv64-unknown-elf-objcopy -O binary -j .data -j .sdata rv32i_test.elf data.bin
# read code.bin as 4-byte words and print each word as 8 hex digits per line, so code.mem has 32-bit word per line
code.mem: code.bin rv32i_test.dump 
		hexdump -v -e '1/4 "%08x\n"' code.bin > code.mem
# produce one byte per line (2 hex digits) - suggests data memory is byte-addressable
data.mem: data.bin 
		hexdump -v -e '1/1 "%02x\n"' data.bin > data.mem

# Cocotb's makefile calls verilator and runs Python against the build simulation
sim: code.mem data.mem 
=======
# C/ASM → ELF → binary → hex → loaded into Verilog memories → executed by your CPU
# ELF -> Executable and Linkable Format -> Final compiled programme -> A complete description of a program and how it should live in memory.
# We extract pieces from elf as needed
# Dump is disassembled instructions in human readable hex -> Used for debugging

# building the executable
rv32i_test.elf:link.ld boot.s test.c
		riscv64-unknown-elf-gcc -nostdlib -nostartfiles -O3 -march=rv32i_zicsr -mabi=ilp32 -T link.ld boot.s test.c -o rv32i_test.elf
# No C standard lib + No def startup code + high optim + isa + memory map + boot + C program + output elf

# disassembly dump (debug helper)
rv32i_test.dump: rv32i_test.elf
		riscv64-unknown-elf-objdump -D rv32i_test.elf > rv32i_test.dump

# dump .text section as raw bytes to code.bin - Extracts instructions only
code.bin:rv32i_test.elf
		riscv64-unknown-elf-objcopy -O binary --only-section=.text rv32i_test.elf code.bin

# dump .data and .sdata sections to data.bin (RAM image) (doesn't extract .bss as it's zero-init by def)
data.bin: rv32i_test.elf
		riscv64-unknown-elf-objcopy -O binary -j .data -j .sdata rv32i_test.elf data.bin

# read code.bin as 4-byte words and print each word as 8 hex digits per line, so code.mem has 32-bit word per line
code.mem: code.bin rv32i_test.dump
		hexdump -v -e '1/4 "%08x\n"' code.bin > code.mem

# produce one byte per line (2 hex digits) - suggests data memory is byte-addressable
data.mem: data.bin
		hexdump -v -e '1/1 "%02x\n"' data.bin > data.mem

# Cocotb's makefile calls verilator and runs Python against the build simulation
sim: code.mem data.mem
include $(shell cocotb-config --makefiles)/Makefile.sim

# delete generated files
clean_build: 
	rm -rf *.mem *.bin *.elf *dump* 

