# NBU-EXEC-1

NBU-EXEC-1 is the private application interface for NBU-OS. It is independent from Linux `execve`, Linux ELF ABI, and Windows EXE.

The current implementation resolves `/system/hello` from the kernel program registry. The future external format is NBUX and will require a validated loader, user-mode isolation, and NBUFS storage.
