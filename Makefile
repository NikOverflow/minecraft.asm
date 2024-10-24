AS = nasm
CC = gcc

ASFLAGS = -f elf64
CFLAGS = -m64 -nostartfiles -fPIE -z noexecstack -z relro -z now

SRC = ./src
BUILD = ./build

ASSEMBLY_FILES = $(SRC)/*

$(BUILD)/%.o: $(SRC)/%.asm
	@mkdir -p $(dir $@)
	$(AS) $(ASFLAGS) -o $@ $<

$(BUILD)/test: $(BUILD)/start.o
	$(CC) $(CFLAGS) -o $@ $^
