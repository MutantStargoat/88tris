; vi:set ts=8 sts=8 sw=8 ft=nasm:
	cpu 8086
%ifdef DOS
	org 100h
	jmp prog_start
%else
	org 7c00h
%endif

%include "src/hwregs.inc"

VIDTYPE_UNK	equ 0
VIDTYPE_MDA	equ 1
VIDTYPE_CGA	equ 2
VIDTYPE_EGA_VGA	equ 3

PROG_SIZE equ prog_end - prog_start
driveno equ 7b00h

start:
	xor ax, ax
	mov ds, ax
	mov es, ax
	mov ss, ax
	jmp 00:.setcs
.setcs:
	mov sp, 7b00h
	mov [driveno], dx

	mov ax, str_loading
	call printstr

	mov ah, 2			; read sectors call
	mov al, (PROG_SIZE + 511) / 512	; num sectors
	mov cx, 2			; start from sector 2 cylinder 0
	mov dx, [driveno]
	xor dh, dh			; head 0
	mov bx, prog_start		; es:bx dest
	int 13h
	jnc prog_start

	mov ax, str_load_fail
	call printstr

	cli
	hlt

printstr:
	mov si, ax
.loop:	mov al, [si]
	inc si
	test al, al
	jz .done
	mov ah, 0eh
	xor bx, bx
	int 10h
	jmp .loop
.done:	ret

str_loading db "Loading program ...",13,10,0
str_load_fail db "Failed to load program!",0

	times 510-($-$$) db 0
	dw 0aa55h

prog_start:
	call detect_video

	cmp word [mono], 0
	jz .notmono
	mov word [vmemseg], 0b000h
.notmono:

	; make sure we're in the correct mode and also reset scroll registers
	; and all the rest of the video state by setting up mode 3 through
	; the video BIOS, even though we're probably in mode 3 anyway
	mov ax, 3
	int 10h

	cld
	; clear the screen
	mov ax, [vmemseg]
	mov es, ax
	xor di, di
	mov cx, 2000
	xor ax, ax
	rep stosw

	cmp word [vidtype], VIDTYPE_EGA_VGA
	jnz .notvga
	; EGA/VGA blink disable through the attribute controller
	mov dx, VGA_STAT1_PORT
	in al, dx
	mov dx, VGA_AC_PORT
	mov al, VGA_AC_MODE_REG
	out dx, al
	mov al, VGA_AC_MODE_LGE
	out dx, al
	jmp .noblink_done
.notvga:
	cmp word [vidtype], VIDTYPE_CGA
	jnz .notcga
	; CGA blink disable through the mode register
	mov dx, CGA_MODE_PORT
	mov al, CGA_MODE_80COL | CGA_MODE_EN
	out dx, al
	jmp .noblink_done
.notcga:
	cmp word [vidtype], VIDTYPE_MDA
	jnz .unknown
	; MDA blink disable through the mode register
	mov dx, MDA_MODE_PORT
	mov al, MDA_MODE_80COL | MDA_MODE_MONO
	out dx, al
	jmp .noblink_done
.unknown:
	; unknown display adapter, hack the high order bits off the bg colors
	call game_drop_bgint
.noblink_done:

	call start_game

%ifdef DOS
	mov ax, str_waitesc
	call printstr
.waitesc:
	in al, 60h
	dec al
	jnz .waitesc

	mov ax, 3
	int 10h
	int 20h

str_waitesc db "press esc to quit...",13,10,0
%else
	cli
	hlt
%endif

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
	ret
.nomda:	cmp bl, 4
	jae .nocga
	mov word [vidtype], VIDTYPE_CGA
	mov word [mono], 0
	ret
.nocga:	mov word [vidtype], VIDTYPE_EGA_VGA
	and bx, 1
	mov [mono], bx	; monochrome codes are odd
	ret

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
	ret
.ega_mono:
	mov word [mono], 1
	ret

.skip_egainfo:
	; try int 11h (get equipment list)
	int 11h
	and ax, 30h
	cmp ax, 30h
	jz .mda
	mov word [vidtype], VIDTYPE_CGA
	mov word [mono], 0
	ret
.mda:	mov word [vidtype], VIDTYPE_MDA
	mov word [mono], 1
	ret

vidtype dw 0
mono	dw 0
vmemseg	dw 0b800h

%include "src/game.asm"

prog_end:
