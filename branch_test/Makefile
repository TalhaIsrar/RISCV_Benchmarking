

# disassembly dump (debug helper)
rv32i_test.dump: rv32i_test.elf
		riscv64-unknown-elf-objdump -D ../rv32i_test.elf > ../rv32i_test.dump

# building the executable
rv32i_test.elf:link.ld boot.s test.c
		riscv64-unknown-elf-gcc -nostdlib -nostartfiles -O3 -march=rv32i_zicsr -mabi=ilp32 -T link.ld boot.s test.c -o ../rv32i_test.elf
# No C standard lib + No def startup code + high optim + isa + memory map + boot + C program + output elf
