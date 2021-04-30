; 88tris - bootable tetris for the IBM PC
; Copyright (C) 2021  John Tsiombikas <nuclear@member.fsf.org>
; 
; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.
; 
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
; 
; You should have received a copy of the GNU General Public License
; along with this program.  If not, see <https://www.gnu.org/licenses/>.

	cpu 8086
%ifdef DOS
	org 100h
	jmp prog_start
%else
	org 7c00h
%endif

%include "src/hwregs.inc"

VIDTYPE_UNK	equ 0
VIDTYPE_MDA	equ 1
VIDTYPE_CGA	equ 2
VIDTYPE_EGA_VGA	equ 3

PROG_SIZE equ prog_end - prog_start
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
	mov al, (PROG_SIZE + 511) / 512	; num sectors
	mov cx, 2			; start from sector 2 cylinder 0
	mov dx, [driveno]
	xor dh, dh			; head 0
	mov bx, prog_start		; es:bx dest
	int 13h
	jnc prog_start

	call floppy_off
	mov ax, str_load_fail
	call printstr

	cli
	hlt

floppy_off:
	test word [driveno], 80h
	jnz .done	; skip if high bit is set (i.e. it's not a floppy)
	mov dx, 3f2h
	in al, dx
	and al, 0fh
	out dx, al
.done:	ret


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
	call floppy_off
	call detect_video

	; make sure we're in the correct mode and also reset scroll registers
	; and all the rest of the video state by setting up mode 3 through
	; the video BIOS, even though we're probably in mode 3 anyway
	mov ax, 3
	int 10h

	cld

	; hide cursor by placing it outside the screen
	mov ax, 2000
	call set_cursor_addr
	; disable blink to allow 16 colors for the background attr
	call disable_blink

	call start_game

%ifdef DOS
	mov ax, str_waitesc
	call printstr
.waitesc:
	mov ah, 8
	int 21h
	cmp al, 27
	jnz .waitesc

	mov ax, 3
	int 10h
	int 20h

str_waitesc db "ESC to quit...",13,10,0
%else
.hang:	hlt
	jmp .hang
%endif

%include "src/disp.asm"
%include "src/game.asm"

prog_end:
; vi:set ts=8 sts=8 sw=8 ft=nasm:
