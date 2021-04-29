; vi:set ts=8 sts=8 sw=8 ft=nasm:
scr_rows equ 20
scr_cols equ 20
pf_xoffs equ 20

tile_black	equ 0
tile_pf		equ 1
tile_pfsep	equ 2
tile_gameover	equ 3
tile_ipiece	equ 4
tile_opiece	equ 5
tile_jpiece	equ 6
tile_lpiece	equ 7
tile_spiece	equ 8
tile_tpiece	equ 9
tile_zpiece	equ 10
tile_frm_tl	equ 11
tile_frm_tr	equ 12
tile_frm_bl	equ 13
tile_frm_br	equ 14
tile_frm_ltee	equ 15
tile_frm_rtee	equ 16
tile_frm_hline	equ 17
tile_frm_lvline	equ 18
tile_frm_rvline equ 19

start_game:
	; fill the screen buffer, and draw
	mov ax, ds
	mov es, ax
	mov di, scrbuf
	mov si, bgdata
	mov cx, scr_rows * scr_cols / 2
	rep movsw

	call drawbg
	ret

drawbg:
	mov ax, 0b800h
	mov es, ax
	mov di, pf_xoffs * 2
	mov si, scrbuf
	mov dx, scr_rows
.yloop: mov cx, scr_cols
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
	add di, 160 - scr_cols * 4	; skip to the start of the next row
	dec dx
	jnz .yloop

	; draw UI strings
	mov cx, 0f0h

	mov si, str_score
	mov ax, 1
	mov bx, pf_xoffs + 14 * 2
	call drawstr

	mov si, str_level
	mov ax, 6
	mov bx, pf_xoffs + 14 * 2
	call drawstr

	mov si, str_lines
	mov ax, 9
	mov bx, pf_xoffs + 14 * 2
	call drawstr

	ret


	; expects string in si, row in ax, column in bx, color attr in cx
drawstr:
	mov dx, 160
	mul dx
	shl bx, 1
	add ax, bx
	mov di, ax
	mov ax, 0b800h
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
scrbuf	times (scr_rows * scr_cols) db 0

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
