; vi:set ts=8 sts=8 sw=8 ft=nasm:
	cpu 8086
	org 7c00h

prog_size equ prog_end - prog_start
driveno equ 7b00h

start:
	xor ax, ax
	mov ds, ax
	mov es, ax
	mov ss, ax
	jmp 00:.setcs
.setcs:
	mov sp, 7b00h
	mov [driveno], dx

	mov ax, str_loading
	call printstr

	mov ah, 2			; read sectors call
	mov al, (prog_size + 511) / 512	; num sectors
	mov cx, 2			; start from sector 2 cylinder 0
	mov dx, [driveno]
	xor dh, dh			; head 0
	mov bx, prog_start		; es:bx dest
	int 13h
	jnc prog_start

	mov ax, str_load_fail
	call printstr

	cli
	hlt

printstr:
	mov si, ax
.loop:	mov al, [si]
	inc si
	test al, al
	jz .done
	mov ah, 0eh
	xor bx, bx
	int 10h
	jmp .loop
.done:	ret

str_loading db "Loading program ...",13,10,0
str_load_fail db "Failed to load program!",0

	times 510-($-$$) db 0
	dw 0aa55h

prog_start:
	mov ax, str_foo
	call printstr

	mov ax, 0b800h
	mov es, ax
	xor di, di
	mov cx, 2000
	mov ax, 043fh
	rep stosw

	call start_game

	cli
	hlt

str_foo db "Foobar!",0

%include "game.asm"

prog_end:
