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

	; expects cursor location in ax
set_cursor_addr:
	mov dx, CGA_CRTC_PORT
	cmp word [mono], 0
	jz .notmono
	mov dx, MDA_CRTC_PORT
.notmono:
	mov bx, ax
	mov al, CRTC_CURH_REG
	out dx, ax
	mov ah, bl
	mov al, CRTC_CURL_REG
	out dx, ax
	ret

disable_blink:
	cmp word [vidtype], VIDTYPE_EGA_VGA
	jnz .notvga
	call disable_blink_ega
	jmp .done
.notvga:
	cmp word [vidtype], VIDTYPE_CGA
	jnz .notcga
	call disable_blink_cga
	jmp .done
.notcga:
	cmp word [vidtype], VIDTYPE_MDA
	jnz .unknown
	call disable_blink_mda
	jmp .done
.unknown:
	; unknown display adapter, hack the high order bits off the bg colors
	call game_drop_bgint
.done:	ret

disable_blink_ega:
	; EGA/VGA blink disable through the attribute controller
	mov dx, VGA_STAT1_PORT
	in al, dx
	mov dx, VGA_AC_PORT
	mov al, VGA_AC_MODE_REG | VGA_AC_EN
	out dx, al
	mov al, VGA_AC_MODE_LGE
	out dx, al
	ret

disable_blink_cga:
	; CGA blink disable through the mode register
	mov dx, CGA_MODE_PORT
	mov al, CGA_MODE_80COL | CGA_MODE_EN
	out dx, al
	ret

disable_blink_mda:
	; MDA blink disable through the mode register
	mov dx, MDA_MODE_PORT
	mov al, MDA_MODE_80COL | MDA_MODE_MONO
	out dx, al
	ret


detect_video:
	; try the VGA detect call first
	mov ax, 1a00h
	int 10h
	cmp al, 1ah
	jnz .skip_vgainfo
	cmp bl, 0ffh
	jz .skip_vgainfo
	cmp bl, 1
	jnz .nomda
	mov word [vidtype], VIDTYPE_MDA
	mov word [mono], 1
	jmp .done
.nomda:	cmp bl, 4
	jae .nocga
	mov word [vidtype], VIDTYPE_CGA
	mov word [mono], 0
	jmp .done
.nocga:	mov word [vidtype], VIDTYPE_EGA_VGA
	and bx, 1
	mov [mono], bx	; monochrome codes are odd
	jmp .done

.skip_vgainfo:
	; try get ega info
	mov ah, 12h
	mov bx, 0ff10h
	int 10h
	cmp bh, 0ffh
	jz .skip_egainfo
	mov word [vidtype], VIDTYPE_EGA_VGA
	test bh, bh
	jnz .ega_mono
	mov word [mono], 0
	jmp .done
.ega_mono:
	mov word [mono], 1
	jmp .done

.skip_egainfo:
	; try int 11h (get equipment list)
	int 11h
	and ax, 30h
	cmp ax, 30h
	jz .mda
	mov word [vidtype], VIDTYPE_CGA
	mov word [mono], 0
	jmp .done
.mda:	mov word [vidtype], VIDTYPE_MDA
	mov word [mono], 1

.done:	cmp word [mono], 0
	jz .skip_vmem_mono
	mov word [vmemseg], 0b000h	; change the vmem address for monochrome
.skip_vmem_mono:
	ret

vidtype dw 0
mono	dw 0
vmemseg	dw 0b800h
; vi:set ts=8 sts=8 sw=8 ft=nasm:
