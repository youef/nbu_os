# Private kernel

The kernel implementation is in `kernel/kernel.c` and `kernel/security.c`.

Subsystem responsibilities:

- boot hand-off validation
- VGA text output and keyboard input
- installer and login flow
- private terminal
- NBU-EXEC-1 program registry
- password digest and constant-time comparison

Production tasks: paging, user mode, interrupts, scheduler, process table, and system calls.
