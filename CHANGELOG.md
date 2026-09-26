# NBU-OS Changelog

## v0.5.0-alpha1 - 2026-09-26

### Added
- UEFI x86_64 GRUB removable boot path.
- Real GPT 128MB disk IMG with EFI System Partition and BIOS Boot Partition.
- UTM iOS configuration and usage guide.
- PS/2 mouse input path for QEMU/UTM.
- Build pipeline dependencies for UEFI, GPT and FAT image creation.

### Input
- iOS UTM on-screen keyboard is supported through the virtual keyboard path.
- Touch/drag can use UTM Touch Mode when an emulated USB tablet is available; PS/2 mouse is the fallback.


## v0.4.0-alpha1 - 2026-09-26

### Added
- Native 32-bit framebuffer GUI in the x86_64 kernel.
- Multiboot2 request for 1024x768x32 graphics.
- NBU-OS desktop with Files, Terminal, Settings, System, Status and Power panels.
- Keyboard navigation with 1, 2, 3, H and Q.
- VGA fallback when a framebuffer is unavailable.

### Changed
- GRUB build configuration now requests the graphical framebuffer.
- CI now builds the existing NBU-OS source directly and publishes both ISO and IMG artifacts.

### Known limitations
- BIOS/Multiboot2 path only.
- No persistent filesystem.
- No native UEFI path.
- No networking or complete user-mode isolation.
- Built-in ASCII bitmap font and keyboard-only interaction.
