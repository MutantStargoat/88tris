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
	xor ax, ax
	mov bx, 48d3h	; reload = 1193182hz / 64hz = 18643 (48d3h)
	call set_timer_reload

%ifdef DOS
	; save previous interrupt handler to be restored at exit (DOS version)
	push es
	mov ax, IRQ0_TIMER
	call getvect
	mov [saved_timer_intr], bx
	mov [saved_timer_intr + 2], es
	pop es
%endif

	mov ax, cs
	mov ds, ax
	mov dx, timer_intr
	mov ax, IRQ0_TIMER
	call setvect

	unmask_irq 0
	sti
	ret

%ifdef DOS
cleanup_timer:
	cli
	; restore previous interrupt handler
	push ds
	mov dx, [saved_timer_intr]
	mov ax, [saved_timer_intr + 2]
	mov ds, ax
	mov ax, IRQ0_TIMER
	call setvect
	pop ds
	; restore counter reload value
	xor ax, ax
	mov bx, 0ffffh
	call set_timer_reload
	sti
	ret
%endif	; DOS

	; expects counter number in ax, reload value in bx
set_timer_reload:
	; square wave mode, set both low and high reload bytes
	mov dx, ax
	add dx, PIT_CNT0_PORT
	ror al, 1
	ror al, 1
	or al, PIT_CTL_BOTH | PIT_CTL_SQWAVE
	out PIT_CTL_PORT, al
	mov al, bl
	out dx, al
	mov al, bh
	out dx, al
	ret

	; TODO chain dos interrupt in DOS build
timer_intr:
	inc word [nticks]
	send_eoi
	iret

	align 2
nticks dw 0
%ifdef DOS
saved_timer_intr times 2 dw 0
%endif

; vi:ts=8 sts=8 sw=8 ft=nasm:
