# Project Name
PROJECT = blink
# Source files
SOURCES = lpc13xx/system_LPC13xx.c startup.c main.c
# Linker script
LINKER_SCRIPT = lpc1313.dld

#########################################################################

OBJDIR = obj
OBJECTS = $(patsubst %.c,$(OBJDIR)/%.o,$(SOURCES))

#########################################################################

OPT = -Os
DEBUG = -g
INCLUDES = -Icore/ -Ilpc13xx/

#########################################################################

# Compiler Options
CFLAGS = -fno-common -mcpu=cortex-m3 -mthumb
CFLAGS += $(OPT) $(DEBUG) $(INCLUDES)
CFLAGS += -Wall -Wextra
CFLAGS += -Wcast-align -Wcast-qual -Wimplicit -Wpointer-arith -Wswitch -Wredundant-decls -Wreturn-type -Wshadow -Wunused
# Linker options
LDFLAGS = -mcpu=cortex-m3 -mthumb $(OPT) -nostartfiles -Wl,-Map=$(OBJDIR)/$(PROJECT).map -T$(LINKER_SCRIPT) -nostdlib
# Assembler options
ASFLAGS = -ahls -mcpu=cortex-m3 -mthumb

# Compiler/Assembler/Linker Paths
CROSS = arm-none-eabi-
CC = $(CROSS)gcc
AS = $(CROSS)as
LD = $(CROSS)ld
OBJDUMP = $(CROSS)objdump
OBJCOPY = $(CROSS)objcopy
SIZE = $(CROSS)size
REMOVE = rm -f

#########################################################################

.PHONY: all
all: $(PROJECT).hex $(PROJECT).bin

$(PROJECT).bin: $(PROJECT).elf
	$(OBJCOPY) -R .stack -R .bss -O binary -S $(PROJECT).elf $(PROJECT).bin

$(PROJECT).hex: $(PROJECT).elf
	$(OBJCOPY) -R .stack -R .bss -O ihex $(PROJECT).elf $(PROJECT).hex

$(PROJECT).elf: $(OBJECTS) $(LINKER_SCRIPT)
	$(CC) $(LDFLAGS) $(OBJECTS) -o $(PROJECT).elf

.PHONY: stats
stats: $(PROJECT).elf
	$(OBJDUMP) -th $(PROJECT).elf
	$(SIZE) $(PROJECT).elf

.PHONY: clean
clean:
	$(REMOVE) -r $(OBJDIR)
	$(REMOVE) $(PROJECT).elf
	$(REMOVE) $(PROJECT).hex
	$(REMOVE) $(PROJECT).bin

#########################################################################

$(OBJDIR)/%.o : %.c
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -c $< -o $@

