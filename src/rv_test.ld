
RAM_SIZE   = 0x1000; /* 4KB */
IMEM_SIZE  = 0x200;  /* 512B */
DMEM_SIZE  = 0x400;  /* 1KB */

MEMORY 
{
    I_RAM    (rwx) : ORIGIN = 0x0,   LENGTH = IMEM_SIZE
    DATA_RAM (rwx) : ORIGIN = 0x400, LENGTH = DMEM_SIZE
}

SECTIONS
{
    .text :
    {
        . = ALIGN(4);
        *(.text*)
    }  > I_RAM

    .data : 
    { 
        . = ALIGN(4);
        *(.data)
    
    } > DATA_RAM

    .bss(NOLOAD) : 
    { 
        *(.bss*) 

    } > DATA_RAM

    .stack (NOLOAD):
    {
        . = ALIGN(16);
        __stacktop = ORIGIN(ram) + LENGTH(ram);
        . = . + STACK_SIZE;
        . = ALIGN(16);
    } > DATA_RAM

}
