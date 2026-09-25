# Production readiness

NBU-OS is an independent kernel and system. It is not based on Linux and does not use the Linux ABI.

## Current production foundations

- Reproducible project generation from `build_nbu.sh`.
- Freestanding kernel with explicit ELF segment permissions.
- Private `NBU-EXEC-1` program interface.
- SHA-256 password digest in memory instead of plaintext storage.
- Constant-time digest comparison.
- GitHub Actions build and ISO artifact generation.

## Required before a production release

- Persistent encrypted account database on `NBUFS`.
- Hardware-backed or signed boot chain.
- Real user mode and virtual memory isolation.
- Validated external `NBUX` executable loader.
- Interrupt controller, timer, process scheduler, and crash recovery.
- Drivers and tested hardware matrix.
- Reproducible toolchain pinned by version.
- Fuzzing, static analysis, threat model, and release signing.

The current password digest is a security improvement for the prototype, but credentials are still held only for the current boot. The system must not be used for real institutional credentials until persistent storage, recovery, and independent security review are complete.
