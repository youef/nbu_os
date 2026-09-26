# NBU-OS Changelog

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
