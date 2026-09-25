PROJECT := NBU-OS
BUILD := build
DIST := dist
CC ?= gcc
AS ?= as
LD ?= ld
CFLAGS := -m32 -ffreestanding -fno-pie -fno-stack-protector -fno-builtin -Wall -Wextra -O2 -Iinclude
LDFLAGS := -m elf_i386 -T linker.ld -nostdlib

.PHONY: all iso clean
all: $(BUILD)/nbu-kernel.elf

$(BUILD):
	mkdir -p $(BUILD)

$(BUILD)/multiboot2.o: boot/multiboot2.S | $(BUILD)
	$(AS) --32 $< -o $@

$(BUILD)/kernel.o: kernel/kernel.c include/nbu/security.h | $(BUILD)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD)/security.o: kernel/security.c include/nbu/security.h | $(BUILD)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD)/nbu-kernel.elf: $(BUILD)/multiboot2.o $(BUILD)/kernel.o $(BUILD)/security.o linker.ld
	$(LD) $(LDFLAGS) -o $@ $(BUILD)/multiboot2.o $(BUILD)/kernel.o $(BUILD)/security.o

iso: all
	rm -rf $(BUILD)/iso
	mkdir -p $(BUILD)/iso/boot/grub
	cp $(BUILD)/nbu-kernel.elf $(BUILD)/iso/boot/nbu-kernel.elf
	printf "set timeout=3\\nset default=0\\nmenuentry \\"NBU-OS - Digital Transformation\\" {\\n  multiboot2 /boot/nbu-kernel.elf\\n  boot\\n}\\n" > $(BUILD)/iso/boot/grub/grub.cfg
	grub-mkrescue -o $(DIST)/NBU-OS.iso $(BUILD)/iso

clean:
	rm -rf $(BUILD) $(DIST)

