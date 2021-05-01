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

init_timer:
	cli
	; counter 0 square wave mode, set both low and high reload bytes
	mov al, PIT_CTL_SEL0 | PIT_CTL_BOTH | PIT_CTL_SQWAVE
	; reload = 1193182hz / 64hz = 18643 (48d3h)
	out PIT_CTL_PORT, al
	mov al, 0d3h
	out PIT_CNT0_PORT, al
	mov al, 48h
	out PIT_CNT0_PORT, al

	mov ax, cs
	mov ds, ax
	mov dx, timer_intr
	mov ax, IRQ0_TIMER
	call setvect
	sti

	ret

timer_intr:
	push ax
	inc word [nticks]
	send_eoi
	pop ax
	iret

buf times 16 db 0
nticks dw 0

; vi:ts=8 sts=8 sw=8 ft=nasm:
