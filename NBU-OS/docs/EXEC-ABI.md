# NBU-EXEC-1

NBU-OS uses a private program interface. It is not the Linux `execve` ABI and it does not promise to run Linux ELF files or Windows EXE files.

## Current contract

- Program names are private paths such as `/system/hello`.
- The kernel resolves the path in its program registry.
- Each registered program has a `program_entry_t` entry function.
- `nbu_exec(path)` invokes the entry and returns `0` on success or `-1` when the path is unknown.
- `/system/hello` is the first built-in program and can be launched from the desktop with key `1`.

## Planned external format

The next executable format will be `NBUX`, with a fixed header, segment table, entry address, required memory size, and ABI version. The loader must validate all offsets and sizes before mapping a program. User programs will run in a separate address space after paging, interrupts, system calls, and a filesystem are implemented.

This staged design keeps the project independent from Linux while allowing a stable program ecosystem owned by NBU-OS.
