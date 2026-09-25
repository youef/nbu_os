PROJECT := NBU-OS
BUILD := build
CC ?= gcc
AS ?= as
LD ?= ld
CFLAGS := -m64 -mcmodel=small -mno-red-zone -ffreestanding -fno-pie -fno-stack-protector -fno-builtin -Wall -Wextra -O2 -Iinclude
LDFLAGS := -m elf_x86_64 -T linker.ld -nostdlib -z max-page-size=0x1000

.PHONY: all iso clean
all: $(BUILD)/nbu-kernel.elf

$(BUILD):
	mkdir -p $(BUILD)

$(BUILD)/multiboot2.o: boot/multiboot2.S | $(BUILD)
	$(AS) --64 $< -o $@

$(BUILD)/kernel.o: kernel/kernel.c include/nbu/security.h include/nbu/system.h | $(BUILD)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD)/security.o: kernel/security.c include/nbu/security.h | $(BUILD)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD)/nbu-kernel.elf: $(BUILD)/multiboot2.o $(BUILD)/kernel.o $(BUILD)/security.o linker.ld
	$(LD) $(LDFLAGS) -o $@ $(BUILD)/multiboot2.o $(BUILD)/kernel.o $(BUILD)/security.o

iso: all
	command -v grub-mkrescue >/dev/null
	command -v grub-file >/dev/null
	command -v xorriso >/dev/null
	grub-file --is-x86-multiboot2 $(BUILD)/nbu-kernel.elf
	rm -rf $(BUILD)/iso
	mkdir -p $(BUILD)/iso/boot/grub
	cp $(BUILD)/nbu-kernel.elf $(BUILD)/iso/boot/nbu-kernel.elf
	cp VERSION $(BUILD)/iso/boot/NBU-OS.version
	printf '%s\n' 'set timeout=0' 'set default=0' 'serial --unit=0 --speed=115200' 'terminal_input console serial' 'terminal_output console serial' 'menuentry "NBU-OS" {' '  echo "Loading NBU-OS kernel..."' '  multiboot2 /boot/nbu-kernel.elf' '  boot' '}' > $(BUILD)/iso/boot/grub/grub.cfg
	grub-mkrescue -o $(BUILD)/NBU-OS.iso $(BUILD)/iso
	cp $(BUILD)/NBU-OS.iso $(BUILD)/NBU-OS.img

clean:
	rm -rf $(BUILD)

