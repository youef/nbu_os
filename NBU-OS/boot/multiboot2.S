.section .multiboot
.global multiboot_start
multiboot_start:
.align 8
.long 0xe85250d6
.long 0
.long multiboot_end - multiboot_start
.long -(0xe85250d6 + 0 + (multiboot_end - multiboot_start))
.short 0
.short 0
.long 8
multiboot_end:

.section .text
.global _start
.type _start, @function
_start:
    cli
    mov $stack_top, %esp
    push %ebx
    push %eax
    call kernel_main
1:
    hlt
    jmp 1b

.section .bss
.align 16
stack_bottom:
    .skip 16384
stack_top:

.section .note.GNU-stack,"",@progbits
