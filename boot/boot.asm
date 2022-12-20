;============================================================
; KXOS BOOTLOADER - 0.1
; Mainly made for the KXOS project by KX
;============================================================

bits 16									; boot into 16 bit real-mode.
org 0x7c00								; start at 0x7c00

										; Set background and foreground colour
mov ah, 0x06							; Clear / scroll screen up function
xor al, al								; Number of lines by which to scroll up (00h = clear entire window)
mov bh, 0x30							; Background/foreground colour. (https://en.wikipedia.org/wiki/BIOS_color_attributes)
xor cx, cx								; Row,column of window's upper left corner
mov dx, 0x184f							; Row,column of window's lower right corner
int 0x10								; Issue BIOS video services interrupt with function 0x06
										; Set cursor position to 0,0
mov ah, 0x02							; Set cursor position function
mov bh, 0x00							; Page number (00h = active page)
mov dh, 0x00							; Row number (00h = top row)
mov dl, 0x00							; Column number (00h = leftmost column)
int 0x10								; Issue BIOS video services interrupt with function 0x02

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
	mov ax, 0x0							; set ax to 0x0
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
	mov si, msg_kernel					; set si to msg_kernel
	call print_string					; print string
	jmp $								; infinite loop ( jump to current location )
;============================================================



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
; END OF CODE
;============================================================

times 510-($-$$) db 0x00
dw 0xAA55