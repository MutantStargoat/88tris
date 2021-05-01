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
	xor bx, bx
	mov bl, al
	shl bx, 1
	shl bx, 1
	mov [bx], dx
	mov [bx + 2], ds
	ret

; vi:ts=8 sts=8 sw=8 ft=nasm:
