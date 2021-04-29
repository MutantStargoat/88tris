; vi:set ts=8 sts=8 sw=8 ft=nasm:
SCR_ROWS equ 20
SCR_COLS equ 20
PF_XOFFS equ 20

TILE_BLACK	equ 0
TILE_PF		equ 1
TILE_PFSEP	equ 2
TILE_GAMEOVER	equ 3
TILE_IPIECE	equ 4
TILE_OPIECE	equ 5
TILE_JPIECE	equ 6
TILE_LPIECE	equ 7
TILE_SPIECE	equ 8
TILE_TPIECE	equ 9
TILE_ZPIECE	equ 10
TILE_FRM_TL	equ 11
TILE_FRM_TR	equ 12
TILE_FRM_BL	equ 13
TILE_FRM_BR	equ 14
TILE_FRM_LTEE	equ 15
TILE_FRM_RTEE	equ 16
TILE_FRM_HLINE	equ 17
TILE_FRM_LVLINE	equ 18
TILE_FRM_RVLINE equ 19

	; called when we can't detect the display adapter, to drop all the high
	; bits off the background colors, since we can't disable blink
game_drop_bgint:
	mov bx, tiles
	mov cx, (end_tiles - tiles) / 2
.loop:	and word [bx], 07fffh
	add bx, 2
	dec cx
	jnz .loop
	ret

start_game:
	; fill the screen buffer, and draw
	mov ax, ds
	mov es, ax
	mov di, scrbuf
	mov si, bgdata
	mov cx, SCR_ROWS * SCR_COLS / 2
	rep movsw

	call drawbg
	ret


drawbg:
	mov ax, [vmemseg]
	mov es, ax
	mov di, PF_XOFFS * 2
	mov si, scrbuf
	mov dx, SCR_ROWS
.yloop: mov cx, SCR_COLS
.xloop:	xor ax, ax
	lodsb	; read tile number from screen buffer
	mov bx, tiles
	shl ax, 1
	shl ax, 1
	add bx, ax
	mov ax, [bx]
	stosw
	mov ax, [bx + 2]
	stosw
	dec cx
	jnz .xloop
	add di, 160 - SCR_COLS * 4	; skip to the start of the next row
	dec dx
	jnz .yloop

	; draw UI strings
	mov cl, [tiles + 41]

	mov si, str_score
	mov ax, 1
	mov bx, PF_XOFFS + 14 * 2
	call drawstr

	mov si, str_level
	mov ax, 6
	mov bx, PF_XOFFS + 14 * 2
	call drawstr

	mov si, str_lines
	mov ax, 9
	mov bx, PF_XOFFS + 14 * 2
	call drawstr

	ret

	; expects string in si, row in ax, column in bx, color attr in cx
drawstr:
	mov dx, 160
	mul dx
	shl bx, 1
	add ax, bx
	mov di, ax
	mov ax, [vmemseg]
	mov es, ax
.loop:	lodsb
	test al, al
	jz .done
	mov ah, cl
	stosw
	jmp .loop
.done:	ret


str_score db "S C O R E",0
str_level db "L E V E L",0
str_lines db "L I N E S",0

	; screen buffer with tile numbers for each screen position
scrbuf	times (SCR_ROWS * SCR_COLS) db 0

	; numbers correspond to tile_* equates at the top
bgdata	db 0,2,1,1,1,1,1,1,1,1,1,1,2,11,17,17,17,17,17,12,
	db 0,2,1,1,1,1,1,1,1,1,1,1,2,18,1,1,1,1,1,19,
	db 0,2,1,1,1,1,1,1,1,1,1,1,2,13,17,17,17,17,17,14,
	db 0,2,1,1,1,1,1,1,1,1,1,1,2,1,1,1,1,1,1,1,
	db 0,2,1,1,1,1,1,1,1,1,1,1,2,0,0,0,0,0,0,0,
	db 0,2,1,1,1,1,1,1,1,1,1,1,2,11,17,17,17,17,17,12,
	db 0,2,1,1,1,1,1,1,1,1,1,1,2,18,1,1,1,1,1,19,
	db 0,2,1,1,1,1,1,1,1,1,1,1,2,18,1,1,1,1,1,19,
	db 0,2,1,1,1,1,1,1,1,1,1,1,2,15,17,17,17,17,17,16,
	db 0,2,1,1,1,1,1,1,1,1,1,1,2,18,1,1,1,1,1,19,
	db 0,2,1,1,1,1,1,1,1,1,1,1,2,18,1,1,1,1,1,19,
	db 0,2,1,1,1,1,1,1,1,1,1,1,2,13,17,17,17,17,17,14,
	db 0,2,1,1,1,1,1,1,1,1,1,1,2,0,11,17,17,17,17,12,
	db 0,2,1,1,1,1,1,1,1,1,1,1,2,0,18,1,1,1,1,19,
	db 0,2,1,1,1,1,1,1,1,1,1,1,2,0,18,1,1,1,1,19,
	db 0,2,1,1,1,1,1,1,1,1,1,1,2,0,18,1,1,1,1,19,
	db 0,2,1,1,1,1,1,1,1,1,1,1,2,0,18,1,1,1,1,19,
	db 0,2,1,1,1,1,1,1,1,1,1,1,2,0,13,17,17,17,17,14,
	db 0,2,2,2,2,2,2,2,2,2,2,2,2,0,0,0,0,0,0,0,
	db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,

	; mapping between tile number and CGA character pairs
	align 2
tiles	dw 00020h, 00020h		; black tile
	dw 0ff20h, 0ff20h		; playfield background
	dw 070b1h, 070b1h		; well separator
	dw 040c5h, 040c5h		; gameover fill
	dw 0f65bh, 0f65dh		; L
	dw 0f25bh, 0f25dh		; J
	dw 0f35bh, 0f35dh		; I
	dw 0f15bh, 0f15dh		; O
	dw 0f45bh, 0f45dh		; Z
	dw 0f55bh, 0f55dh		; S
	dw 0f05bh, 0f05dh		; T
	dw 00fdah, 00fc4h		; top-left corner
	dw 00fc4h, 00fbfh		; top-right corner
	dw 00fc0h, 00fc4h		; bottom-left corner
	dw 00fc4h, 00fd9h		; bottom-right corner
	dw 00fc3h, 00fc4h		; left-T
	dw 00fc4h, 00fb4h		; right-T
	dw 00fc4h, 00fc4h		; horizontal line
	dw 00fb3h, 00f20h		; left vertical line
	dw 00f20h, 00fb3h		; right vertical line
end_tiles:
