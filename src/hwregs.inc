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

%ifndef HWREGS_INC_
%define HWREGS_INC_

; ---- MDA registers ----
MDA_CRTC_PORT		equ 3b4h
MDA_CRTC_ADDR_PORT	equ 3b4h
MDA_CRTC_DATA_PORT	equ 3b5h
MDA_MODE_PORT		equ 3b8h
MDA_STAT_PORT		equ 3bah

MDA_MODE_80COL		equ 01h
MDA_MODE_MONO		equ 02h
MDA_MODE_EN		equ 08h
MDA_MODE_BLINK		equ 20h

; ---- CGA registers ----
CGA_CRTC_PORT		equ 3d4h
CGA_CRTC_ADDR_PORT	equ 3d4h
CGA_CRTC_DATA_PORT	equ 3d5h
CGA_MODE_PORT		equ 3d8h
CGA_COLOR_PORT		equ 3d9h
CGA_STAT_PORT		equ 3dah

CGA_MODE_80COL		equ 01h
CGA_MODE_GFX		equ 02h
CGA_MODE_MONO		equ 04h
CGA_MODE_EN		equ 08h
CGA_MODE_HIGFX		equ 10h
CGA_MODE_BLINK		equ 20h

CGA_COLOR_COLSEL_MASK	equ 0fh
CGA_COLOR_FG_BRIGHT	equ 10h
CGA_COLOR_PAL1		equ 20h

CGA_STAT_DISPEN		equ 01h
CGA_STAT_LPEN_TRIG	equ 02h
CGA_STAT_LPEN_SWSTAT	equ 04h
CGA_STAT_VBLANK		equ 08h

; ---- VGA registers ----
VGA_AC_PORT		equ 3c0h
VGA_AC_RD_PORT		equ 3c1h
VGA_SC_ADDR_PORT	equ 3c4h
VGA_SC_DATA_PORT	equ 3c5h
VGA_GC_ADDR_PORT	equ 3ceh
VGA_GC_DATA_PORT	equ 3cfh
VGA_CRTC_PORT		equ 3d4h
VGA_CRTC_ADDR_PORT	equ 3d4h
VGA_CRTC_DATA_PORT	equ 3d5h
VGA_STAT0_PORT		equ 3c2h
VGA_STAT1_PORT		equ 3dah	; same as CGA_STAT_PORT

; attribute controller registers
VGA_AC_EN		equ 20h
VGA_AC_MODE_REG		equ 10h

; sequence controller registers
VGA_SC_MAPMASK_REG	equ 02h

; graphics controller registers
VGA_GC_SR_REG		equ 00h
VGA_GC_SREN_REG		equ 01h
VGA_GC_ROT_REG		equ 03h
VGA_GC_MODE_REG		equ 05h
VGA_GC_MASK_REG		equ 08h

; attribute controller mode register (10h) bits
VGA_AC_MODE_GFX		equ 01h
VGA_AC_MODE_MONO	equ 02h
VGA_AC_MODE_LGE		equ 04h
VGA_AC_MODE_BLINK	equ 08h
VGA_AC_MODE_PIXPAN	equ 20h
VGA_AC_MODE_8BIT	equ 40h


; CRTC registers
CRTC_HTOTAL_REG		equ 00h
CRTC_HEND_REG		equ 01h
CRTC_HBLSTART_REG	equ 02h
CRTC_HBLEND_REG		equ 03h
CRTC_HRETSTART_REG	equ 04h
CRTC_HRETEND_REG	equ 05h
CRTC_VTOTAL_REG		equ 06h
CRTC_OVF_REG		equ 07h
CRTC_PRESET_REG		equ 08h
CRTC_MAXSCAN_REG	equ 09h
CRTC_CURSTART_REG	equ 0ah
CRTC_CUREND_REG		equ 0bh
CRTC_STARTH_REG		equ 0ch
CRTC_STARTL_REG		equ 0dh
CRTC_CURH_REG		equ 0eh
CRTC_CURL_REG		equ 0fh
CRTC_VRETSTART_REG	equ 10h
CRTC_VRETEND_REG	equ 11h
CRTC_VEND_REG		equ 12h
CRTC_OFFSET_REG		equ 13h
CRTC_UL_REG		equ 14h
CRTC_VBLSTART_REG	equ 15h
CRTC_VBLEND_REG		equ 16h
CRTC_MODE_REG		equ 17h
CRTC_LCMP_REG		equ 18h


; ---- 8254 PIT ----
OSC_FREQ		equ 1193182

PIT_CNT0_PORT		equ 40h
PIT_CNT1_PORT		equ 41h
PIT_CNT2_PORT		equ 42h
PIT_CTL_PORT		equ 43h

PIT_CTL_BCD		equ 01h
PIT_CTL_INTTERM		equ 00h
PIT_CTL_ONESHOT		equ 02h
PIT_CTL_RATE		equ 04h
PIT_CTL_SQWAVE		equ 06h
PIT_CTL_SWSTROBE	equ 08h
PIT_CTL_HWSTROBE	equ 0ah
PIT_CTL_LATCH		equ 00h
PIT_CTL_LSB		equ 10h
PIT_CTL_MSB		equ 20h
PIT_CTL_BOTH		equ 30h
PIT_CTL_SEL0		equ 00h
PIT_CTL_SEL1		equ 40h
PIT_CTL_SEL2		equ 80h
PIT_CTL_RD		equ 0c0h


; ---- 8259A PIC ----
PIC_CMD_PORT	equ 20h
PIC_DATA_PORT	equ 21h

; PIC initialization command word 1 bits
PIC_ICW1_ICW4_NEEDED	equ 01h
PIC_ICW1_SINGLE		equ 02h
PIC_ICW1_IVAL4		equ 04h
PIC_ICW1_LEVEL		equ 08h
PIC_ICW1_INIT		equ 10h
; PIC initialization command word 4 bits
PIC_ICW4_8086		equ 01h
PIC_ICW4_AUTO_EOI	equ 02h
PIC_ICW4_BUF_SLAVE	equ 08h
PIC_ICW4_BUF_MASTER	equ 0ch
PIC_ICW4_SPECIAL	equ 10h
; PIC operation command word 2 bits
PIC_OCW2_EOI		equ 20h


; ---- keyboard controller ----
KB_DATA_PORT		equ 60h
KB_CTRL_PORT		equ 61h

%endif ; HWREGS_INC_
; vi:set ts=8 sts=8 sw=8 ft=nasm:
