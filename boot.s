.section .text // Tells this goes into instruction section
.global _start // Makes _start visible to linker

_start:
    li sp, 0x10003FFC // sp = x2, stack grows downwards so we start at top of DMEM (DMEM range was 0x10000000 – 0x10003FFF)
    call main // main function in C code
HALT:
    li t0,0xDEADC0DE // t0 = x5, after main CPU ends up here
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    j HALT
