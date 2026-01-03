# -------------------------------------------------
# Toolchain
# -------------------------------------------------
GCC_DIR    = /opt/riscv
GCC_PREFIX = riscv32-unknown-elf
GCC_VER    = 15.1.0

CC      = $(GCC_PREFIX)-gcc
OBJDUMP = $(GCC_PREFIX)-objdump
SIZE    = $(GCC_PREFIX)-size
READELF = $(GCC_PREFIX)-readelf

# -------------------------------------------------
# Target configuration
# -------------------------------------------------
ARCH    = rv32i_zicsr
ABI     = ilp32

PRJNAME = rv32i_test
TARGET  = $(PRJNAME).elf
LINKER_SCRIPT = link.ld
PORT_DIR = barebones

# -------------------------------------------------
# CoreMark configuration
# -------------------------------------------------
ITERATIONS     = 400
CLOCKS_PER_SEC = 12000000
FLAGS_STR      = ""

# -------------------------------------------------
# Compiler flags
# -------------------------------------------------
COMMON_CFLAGS = \
	-march=$(ARCH) \
	-mabi=$(ABI) \
	-O3 \
	-ffreestanding \
	-nostdlib \
	-fno-builtin \
	-fno-stack-protector \
	-mstrict-align \
	-g

XCFLAGS = \
	-DITERATIONS=$(ITERATIONS) \
	-DCLOCKS_PER_SEC=$(CLOCKS_PER_SEC) \
	-DFLAGS_STR=\"$(FLAGS_STR)\" \
	-I . \
	-I $(PORT_DIR)

# -------------------------------------------------
# Source files
# -------------------------------------------------
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

SRCS = $(STARTUP) $(CORE_SRC) $(PORT_SRC)
OBJS = $(SRCS:.c=.o)
OBJS := $(OBJS:.s=.o)

# -------------------------------------------------
# Build rules
# -------------------------------------------------

# Compile C source files
%.o: %.c
	$(CC) $(COMMON_CFLAGS) $(XCFLAGS) -c $< -o $@

# Compile assembly source files
%.o: %.s
	$(CC) $(COMMON_CFLAGS) -c $< -o $@

# Build target
all: $(TARGET)

$(TARGET): $(OBJS) $(LINKER_SCRIPT)
	$(CC) \
		-march=$(ARCH) \
		-mabi=$(ABI) \
		-mcmodel=medany \
		-ffreestanding -nostdlib \
		$(OBJS) \
		-Wl,-Map=$(PRJNAME).map -static -T $(LINKER_SCRIPT) \
		-lgcc \
		-o $(TARGET)

	# Optional: show ELF info and size
	$(READELF) -h $@
	$(SIZE) $@

	rm -f *.o $(PORT_DIR)/*.o $(PRJNAME).map

# Clean
clean:
	rm -f *.o $(PORT_DIR)/*.o $(TARGET) $(PRJNAME).map
