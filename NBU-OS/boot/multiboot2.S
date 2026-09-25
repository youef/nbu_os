.section .multiboot,"a"
.align 8
multiboot_header:
    .long 0xe85250d6
    .long 0
    .long multiboot_header_end - multiboot_header
    .long -(0xe85250d6 + (multiboot_header_end - multiboot_header))
    .short 0
    .short 0
    .long 8
multiboot_header_end:

.section .text,"ax"
.code32
.global multiboot_start
.global _start
.type multiboot_start, @function
multiboot_start:
_start:
    cli
    cld
    movl %eax, boot_magic
    movl %ebx, boot_info
    movl $stack_top, %esp

    movl $1, %eax
    cpuid
    testl $(1 << 6), %edx
    jz boot_error
    testl $(1 << 3), %edx
    jz boot_error

    movl $0x80000000, %eax
    cpuid
    cmpl $0x80000001, %eax
    jb boot_error
    movl $0x80000001, %eax
    cpuid
    testl $(1 << 29), %edx
    jz boot_error

    movl $pdpt_table, %eax
    orl $3, %eax
    movl %eax, pml4_table
    movl $pd_table, %eax
    orl $3, %eax
    movl %eax, pdpt_table

    xorl %ecx, %ecx
1:
    movl %ecx, %eax
    shll $21, %eax
    orl $0x83, %eax
    movl %eax, pd_table(,%ecx,8)
    movl $0, pd_table+4(,%ecx,8)
    incl %ecx
    cmpl $512, %ecx
    jne 1b

    movl %cr4, %eax
    orl $0x30, %eax
    movl %eax, %cr4
    movl $pml4_table, %eax
    movl %eax, %cr3
    movl $0xc0000080, %ecx
    rdmsr
    orl $(1 << 8), %eax
    wrmsr
    movl %cr0, %eax
    orl $(1 << 31), %eax
    movl %eax, %cr0
    lgdt gdt64_pointer
    ljmp $0x08, $long_mode_start

boot_error:
    movl $boot_error_message, %esi
    movl $0xb8000, %edi
2:
    lodsb
    testb %al, %al
    jz 3f
    movb $0x4f, %ah
    movw %ax, (%edi)
    addl $2, %edi
    jmp 2b
3:
    cli
    hlt
    jmp 3b

.code64
long_mode_start:
    movw $0x10, %ax
    movw %ax, %ds
    movw %ax, %es
    movw %ax, %ss
    movq $stack_top, %rsp
    andq $-16, %rsp
    movl boot_magic(%rip), %edi
    movl boot_info(%rip), %esi
    call kernel_main
4:
    cli
    hlt
    jmp 4b

.section .rodata,"a"
.align 8
gdt64:
    .quad 0
    .quad 0x00af9a000000ffff
    .quad 0x00cf92000000ffff
gdt64_end:
gdt64_pointer:
    .word gdt64_end - gdt64 - 1
    .long gdt64
boot_error_message:
    .asciz "NBU-OS: x86_64 long mode unavailable"

.section .data,"aw"
.align 4
boot_magic:
    .long 0
boot_info:
    .long 0

.section .bss,"aw",@nobits
.align 4096
pml4_table:
    .skip 4096
.align 4096
pdpt_table:
    .skip 4096
.align 4096
pd_table:
    .skip 4096
.align 16
stack_bottom:
    .skip 16384
stack_top:

.section .note.GNU-stack,"",@progbits
