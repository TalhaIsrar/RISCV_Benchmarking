PORT_DIR = barebones

ITERATIONS     = 2
CLOCKS_PER_SEC = 120
FLAGS_STR      = ""

XCFLAGS = \
	-DITERATIONS=$(ITERATIONS) \
	-DCLOCKS_PER_SEC=$(CLOCKS_PER_SEC) \
	-DFLAGS_STR=\"$(FLAGS_STR)\" \
	-I . \
	-I $(PORT_DIR)

DHRY-CFLAGS := -O1 -DNOENUM -Wno-implicit
DHRY-CFLAGS += -fno-builtin-printf -fno-common -falign-functions=4
DHRY-CFLAGS += -ffreestanding -fno-stack-protector

XCFLAGS += $(DHRY-CFLAGS)

LDFLAGS = -nostartfiles

GCC-FLAGS = -march=rv32i -mabi=ilp32

CORE_SRC = \
	core_list_join.c \
	core_main.c \
	core_matrix.c \
	core_state.c \
	core_util.c

PORT_SRC = \
	$(PORT_DIR)/core_portme.c \
	$(PORT_DIR)/ee_printf.c

STARTUP = start.s

SRC = $(STARTUP) $(CORE_SRC) $(PORT_SRC)

RISCV-GCC = riscv-none-elf-gcc

override CFLAGS += $(XCFLAGS)

rv32i_test.elf: $(SRC) link.ld
	$(RISCV-GCC) $(GCC-FLAGS) $(CFLAGS) $(SRC) $(LDFLAGS) -T link.ld -o ../rv32i_test.elf
	riscv64-unknown-elf-objdump -D ../rv32i_test.elf > ../rv32i_test.dump

clean:
	rm -f *.o $(PORT_DIR)/*.o ../rv32i_test.elf ../rv32i_test.dump
