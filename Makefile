SIM ?= verilator
TOPLEVEL_LANG ?= verilog
WAVES = 1 			# waveform dumping enabled
VERILOG_SOURCES += $(PWD)/rtl/*.sv
VERILOG_SOURCES += $(PWD)/rtl/core/*.sv
EXTRA_ARGS += --trace --trace-structs --trace-fst --timing -j 8
TOPLEVEL = TB 		# top module name
MODULE = test 		# referring to test.py for Cocotb

all: code.mem data.mem sim

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
include $(shell cocotb-config --makefiles)/Makefile.sim

# delete generated files
clean_build: 
	rm -rf *.mem *.bin *.elf *dump* 

