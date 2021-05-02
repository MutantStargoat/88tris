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

	; expects interrupt number in al, vector address in ds:dx
setvect:
	push es
	xor bx, bx
	mov es, bx
	mov bl, al
	shl bx, 1
	shl bx, 1
	mov [es:bx], dx
	mov [es:bx + 2], ds
	pop es
	ret

	; expects interrupt number in al, returns in es:bx
getvect:
	push ds
	xor bx, bx
	mov ds, bx
	mov bl, al
	shl bx, 1
	shl bx, 1
	mov ax, [bx + 2]
	mov es, ax
	mov ax, [bx]
	mov bx, ax
	pop ds
	ret

; vi:ts=8 sts=8 sw=8 ft=nasm:
