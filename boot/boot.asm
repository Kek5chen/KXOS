;============================================================
; KXOS BOOTLOADER - 0.1
; Mainly made for the KXOS project by KX
;============================================================

bits 16									; boot into 16 bit real-mode.
org 0									; start at 0x0

mov si, msg_booting
call print_string
jmp start								; jump to start

;============================================================
; VALUE STORAGE
;============================================================
; PRESET VALUES
bytesPerSector	equ	512		 			; bytes per sector

; RUNTIME VALUES
bsDriveNum		db	0	  				; drive number

;============================================================
; FUNCTION: printString
; Prints a string to the screen.
; 16 bit real mode only.
; si: string to print
;============================================================
print_string:
	push si									; save si
	mov	ah, 0x0e							; set ah to 0x0e
	print_string_loop:
		lodsb								; load byte from si into al
		cmp	al, 0							; check if al is 0
		je	print_string_end				; if al is 0, jump to printStringEnd
		int	0x10							; print al to screen
		jmp	print_string_loop					; loop
	print_string_end:
		pop	si								; restore si
		ret									; return

;============================================================
; FUNCTION: start
; 16 bit real-mode only.
;============================================================

start:
										; print "Booting KXOS..."
	mov si, msg_booting					; set si to msg_setup
	call print_string					; print string
										; print "Setting up registers..."
	mov si, msg_setup					; set si to msg_setup
	call print_string					; print string
	cli									; disable interrupts
										; set up registers
	mov ax, 0x07C0						; set ax to 0x07C0
	mov ds, ax							; set default data segment to ax
	mov es, ax							; set extra segment to ax
	mov fs, ax							; set extra segment to ax
	mov gs, ax							; set stack segment to ax
										; set up stack
	mov ax, 0x0000						; set ax to 0x0000
	mov ss, ax							; set stack segment to 0x0000
	mov	sp, 0xFFFF						; set stack pointer to 0xFFFF
	sti									; enable interrupts since we're done with setup
	mov BYTE [bsDriveNum], dl			; store drive number in bsDrive
	jmp $								; infinite loop ( jump to current location )



;============================================================
; MESSAGES
;============================================================
msg_booting:
	db "Booting KXOS...", 0x0D, 0x0A, 0x00
msg_setup:
	db "Setting up registers...", 0x0D, 0x0A, 0x00
msg_kernel:
	db "Loading kernel...", 0x0D, 0x0A, 0x00

;============================================================
; END OF FILE
;============================================================

times 510-($-$$) db 0x00
dw 0xAA55