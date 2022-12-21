[bits 16]
%include "boot/gdt.asm"						; global descriptor table

switch_to_32bit:
	cli
	lgdt [gdt_descriptor]
	mov eax, cr0
	or eax, 0x1
	mov cr0, eax
	jmp CODE_SEG:init_32bit



[bits 32]

init_32bit:
	jmp $
	mov ax, DATA_SEG + 0x7c00
	mov ds, ax
	mov ss, ax
	mov es, ax
	mov fs, ax
	mov gs, ax

	mov ebp, 0x90000
	mov esp, ebp

	jmp CODE_SEG:init_32bit

	call BEGIN_PM

[bits 16]