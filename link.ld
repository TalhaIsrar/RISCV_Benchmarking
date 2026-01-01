/* Define base addresses */
IMEM_BASE = 0x00000000;
DMEM_BASE = 0x10000000;

ENTRY(_start) /* Very first instruction CPU executes - defined in boot.s */

/* Tells where data and instructions go - matches RTL */
/* Contract b/w sw and hw*/

/*Harvard architecture*/
/*Both dont start at 0 otherwise instruction data overlap*/
MEMORY
{
  IMEM (rx) : ORIGIN = IMEM_BASE, LENGTH = 64K /*0x00000000 – 0x0000FFFF  rx - read-execute*/
  DMEM (rw) : ORIGIN = DMEM_BASE, LENGTH = 16K /*0x10000000 – 0x10003FFF  rw - read write*/
}
/*Permissions matter b/c it decides section placement and prevent data from going into instruction mem*/

SECTIONS
{
  . = 0x0000000; /*Start of next section - same as pc reset*/
    .text : { /*instructions*/
        *(.text._start) /*Startup code*/
        *(.text .text.*) /* .text is regular ftns and .text.* is compiler generated sections*/
    }> IMEM /*Place in Instruction memory*/

  .data : { /*Initliazed data*/
    *(.data*) /*like int x = 5*/
    *(.rodata*) /*string literals*/
  } > DMEM

  /*bss not in data.bin because its zero*/
  .bss : { /*Uninit data like int counter*/
    *(.bss*)
    *(COMMON) /*Globals like int x*/
    . = ALIGN(4);
    __bss_end = .; /*Symbol used by startup code to know where BSS ends and initalize stack above it*/
} > DMEM

}