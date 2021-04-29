; vi:set ts=8 sts=8 sw=8 ft=nasm:

; ---- CGA registers ----
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
VGA_CRTC_ADDR_PORT	equ 3d4h
VGA_CRTC_DATA_PORT	equ 3d5h
VGA_STAT0_PORT		equ 3c2h
VGA_STAT1_PORT		equ 3dah	; same as CGA_STAT_PORT

; attribute controller registers
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
