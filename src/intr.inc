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
%ifndef INTR_INC_
%define INTR_INC_

%include "src/hwregs.inc"

; default IRQ -> intr mapping is +8, no reason to change it
IRQ0_TIMER	equ 8
IRQ1_KEYB	equ 9

%macro send_eoi 0
	mov ax, PIC_OCW2_EOI
	out byte PIC_CMD_PORT, al
%endmacro

%macro mask_irq 1
	push ax
	in al, PIC_DATA_PORT
	or al, (1 << %1)
	out PIC_DATA_PORT, al
	pop ax
%endmacro

%macro unmask_irq 1
	push ax
	in al, PIC_DATA_PORT
	and al, ~(1 << %1)
	out PIC_DATA_PORT, al
	pop ax
%endmacro


%endif ; INTR_INC_
; vi:ts=8 sts=8 sw=8 ft=nasm:
