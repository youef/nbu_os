ENTRY(_start)
PHDRS
{
  text PT_LOAD FLAGS(5);
  data PT_LOAD FLAGS(6);
}
SECTIONS
{
  . = 1M;
  .multiboot : { KEEP(*(.multiboot)) } :text
  .text : { *(.text*) } :text
  .rodata : { *(.rodata*) } :text
  .data : { *(.data*) } :data
  .bss : { *(COMMON) *(.bss*) } :data
  /DISCARD/ : { *(.eh_frame*) *(.comment*) *(.note*) }
}

