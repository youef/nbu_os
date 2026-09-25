# Boot system

The current entry path is `boot/multiboot2.S`. GRUB is only a loader contract; the NBU-OS kernel owns the runtime after `kernel_main` receives the Multiboot2 hand-off.

Production tasks: native UEFI entry, signed boot metadata, memory-map validation, and recovery boot mode.
