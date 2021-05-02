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

init_keyb:
	cli
%ifdef DOS
	; save previous interrupt handler
	push es
	mov ax, IRQ1_KEYB
	call getvect
	mov [saved_keyb_intr], bx
	mov [saved_keyb_intr + 2], es
	pop es
%endif

	mov ax, cs
	mov ds, ax
	mov dx, keyb_intr
	mov ax, IRQ1_KEYB
	call setvect

	unmask_irq 1
	sti
	ret

%ifdef DOS
cleanup_keyb:
	cli
	; restore previous interrupt handler
	push ds
	mov dx, [saved_keyb_intr]
	mov ax, [saved_keyb_intr + 2]
	mov ds, ax
	call setvect
	pop ds
	sti
	ret
%endif

keyb_intr:
	push ax
	in al, KB_DATA_PORT

	cmp al, 0e0h
	jnz .notext
	mov word [kb_scan_ext], 1
	jmp .eoi
.notext:
	xor ah, ah
	test al, 80h
	jz .notrelease
	inc ah
.notrelease:
	; TODO cont...
	
.eoi:	send_eoi
	pop ax
	iret

	align 2
kb_scan_ext dw 0
kb_inp times 16 db 0
kb_inp_rd dw 0
kb_inp_wr dw 0

%ifdef DOS
saved_keyb_intr times 2 dw 0
%endif
	

; vi:ts=8 sts=8 sw=8 ft=nasm:
