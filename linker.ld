ENTRY(_start)

SECTIONS
{
    . = 0x7C00; /* Bootloader starts at 0x7C00 */

    .boot :
    {
        *(.boot)
    }

    .text :
    {
        *(.text)
    }

    .data :
    {
        *(.data)
    }

    /* ... other sections ... */

    /DISCARD/ :
    {
        *(.comment)
    }
}