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

%include "src/hwregs.inc"
%include "src/intr.inc"
%include "src/keyb.inc"

init_keyb:
	cli
	; save previous interrupt handler
	push es
	mov ax, IRQ1_KEYB
	call getvect
	mov [saved_keyb_intr], bx
	mov [saved_keyb_intr + 2], es
	pop es

	mov ax, cs
	mov ds, ax
	mov dx, keyb_intr
	mov ax, IRQ1_KEYB
	call setvect

	unmask_irq 1
	sti
	ret

cleanup_keyb:
	cli
	; restore previous interrupt handler
	push ds
	mov dx, [saved_keyb_intr]
	mov ax, [saved_keyb_intr + 2]
	mov ds, ax
	mov ax, IRQ1_KEYB
	call setvect
	pop ds
	sti
	ret

	; sets the carry flag if there's pending input
keyb_pending:
	cli
	mov bl, [kb_inp_rd]
	cmp [kb_inp_wr], bl
	clc
	jz .done
	stc
.done:	sti
	ret

	; sets the carry flag if there was pending, removes it and puts it in al
keyb_getnext:
	cli
	mov bl, [kb_inp_rd]
	cmp [kb_inp_wr], bl
	clc
	jz .done
	xor bh, bh
	mov al, [bx + kb_inp]
	inc bx
	and bx, 0fh
	mov [kb_inp_rd], bl
	stc
.done:	sti
	ret

keyb_intr:
	push ax
	push bx
	in al, KB_DATA_PORT

	mov bx, ax
	in al, KB_CTRL_PORT
	mov ah, al
	or al, 80h
	out KB_CTRL_PORT, al
	mov al, ah
	out KB_CTRL_PORT, al
	mov ax, bx


	; if it's the extended scancode prefix, set the ext flag and return
	cmp al, 0e0h
	jnz .notext
	mov byte [kb_scan_ext], 1
	jmp .eoi
.notext:

	; translate scancode
	xor bh, bh
	mov bl, al
	and bx, 7fh
	cmp byte [kb_scan_ext], 0
	jnz .isext
	mov ah, [bx + scantbl]
	jmp .xlatdone
.isext:	mov ah, [bx + scantbl_ext]
	mov byte [kb_scan_ext], 0
.xlatdone:
	mov bl, ah

	; update keypress state
	test al, 80h
	jz .ispress
	mov byte [bx + kb_keystate], 0
	jmp .eoi	; we don't put release events in the queue, go to end
.ispress:
	mov byte [bx + kb_keystate], 1

	; append to input buffer
	mov al, [kb_inp_wr]
	mov bl, al	; bx <- write position
	inc al
	and al, 0fh
	cmp [kb_inp_rd], al
	jz .eoi		; buffer full, drop input
	mov [bx + kb_inp], ah
	mov [kb_inp_wr], al
	
.eoi:	send_eoi
	pop bx
	pop ax
	iret

kb_scan_ext db 0
kb_inp_rd db 0
kb_inp_wr db 0
kb_inp times 16 db 0

kb_keystate times KB_MAXKEYS db 0

scantbl:
	db 0,KB_ESC,'1','2','3','4','5','6','7','8','9','0','-','=',KB_BACKSP	; 0 - e
	db KB_TAB,'q','w','e','r','t','y','u','i','o','p','[',']',KB_ENTER	; f - 1c
	db KB_LCTRL,'a','s','d','f','g','h','j','k','l',';',"'",'`'		; 1d - 29
	db KB_LSHIFT,'\','z','x','c','v','b','n','m',',','.','/',KB_RSHIFT	; 2a - 36
	db KB_NUM_MUL,KB_LALT,' ',KB_CAPSLK,KB_F1,KB_F2,KB_F3,KB_F4,KB_F5,KB_F6,KB_F7,KB_F8,KB_F9,KB_F10	;37 - 44
	db KB_NUMLK,KB_SCRLK,KB_NUM7,KB_NUM8,KB_NUM9,KB_NUM_MINUS,KB_NUM4,KB_NUM5,KB_NUM6,KB_NUM_PLUS	; 45 - 4e
	db KB_NUM1,KB_NUM2,KB_NUM3,KB_NUM0,KB_NUM_DOT,KB_SYSRQ,0,0,KB_F11,KB_F12; 4d - 58
	db 0,0,0,0,0,0,0							; 59 - 5f
	db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0					; 60 - 6f
	db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0					; 70 - 7f

scantbl_ext:
	db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0				; 0 - f
	db 0,0,0,0,0,0,0,0,0,0,0,0,KB_NUM_ENTER,KB_RCTRL,0,0		; 10 - 1f
	db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0				; 20 - 2f
	db 0,0,0,0,0,KB_NUM_MINUS,0,KB_SYSRQ,KB_RALT,0,0,0,0,0,0,0	; 30 - 3f
	db 0,0,0,0,0,0,0,KB_HOME,KB_UP,KB_PGUP,0,KB_LEFT,0,KB_RIGHT,0,KB_END ; 40 - 4f
	db KB_DOWN,KB_PGDN,KB_INS,KB_DEL,0,0,0,0,0,0,0,0,0,0,0,0	; 50 - 5f
	db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0				; 60 - 6f
	db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0				; 70 - 7f



	align 2
saved_keyb_intr times 2 dw 0

; vi:ts=8 sts=8 sw=8 ft=nasm:
