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

PREVIEW_POS equ 13
ERASE_BIT equ 8000h

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

	; initialize the game state
	mov di, game_state
	mov cx, (game_state_end - game_state) / 2
	xor ax, ax
	rep stosw
	mov word [cur_piece], -1
	call rand_piece
	mov word [next_piece], ax

	mov ax, [level_speed]
	mov [tick_interval], ax

	call drawbg
	call print_numbers


.mainloop:
	hlt
	call keyb_getnext
	jnc .endkeys
	cmp al, KB_ESC
	jz .endgame
.endkeys:

	mov ax, [nticks]
	call update
	jmp .mainloop

.endgame:
	ret



	; game update, expects ticks in ax
update:
	cmp word [paused], 1
	jnz .notpaused
	mov [prev_tick], ax
	ret
.notpaused:
	sub ax, [prev_tick]
	mov [deltat], ax

	cmp word [gameover], 1
	jnz .notgameover
	; TODO gameover
	ret
.notgameover:
	
	cmp word [num_complines], 0
	jz .nocomplines
	; lines were completed, we're in blinking mode
	mov ax, [deltat]
	cmp ah, 6
	jbe .keepblinking
	; done blinking
	call erase_completed
	mov word [num_complines], 0
	ret
.keepblinking:
	mov cx, [num_complines]
.blinkloop:
	; TODO drawlines(complines[i], blink & i)
	dec cx
	jnz .blinkloop
	ret
.nocomplines:

	; fall
.fall:	mov ax, [deltat]
	cmp ax, [tick_interval]
	jbe .endfall
	; check if we have a current piece
	cmp word [cur_piece], 0
	jz .nocurpiece
	mov word [just_spawned], 0
	mov ax, [py]
	inc ax
	mov [next_py], ax
	call collision		; sets carry if collision was detected
	jnc .endcheck
	dec word [next_py]
	call stick
	ret
.nocurpiece:
	; no current piece, spawn one
	call spawn		; sets carry on failure
	jnc .endcheck
	mov word [gameover], 1
	ret
.endcheck:
	mov ax, [tick_interval]
	sub [deltat], ax
	mov ax, [nticks]
	mov [prev_tick], ax
	jmp .fall

.endfall:
	call update_cur_piece
	ret


update_cur_piece:
	mov ax, [cur_piece]
	cmp ax, 0
	jb .end
	mov bx, [px]
	mov cx, [py]
	mov dx, [prev_rot]
	cmp bx, [next_px]
	jnz .moved
	cmp cx, [next_py]
	jnz .moved
	cmp dx, [cur_rot]
	jnz .moved
	ret	; x/y/rot unchanged, nothing to do
.moved:	mov bh, cl	; bl: x, bh: y
	; erase previous
	or ax, ERASE_BIT
	call draw_piece
	; draw current
	mov ax, [cur_piece]
	mov bl, [next_px]
	mov bh, [next_py]
	mov dx, [cur_rot]
	mov [prev_rot], dx	; update rotation
	call draw_piece
	; update position
	mov si, next_px
	mov di, px
	movsw
	movsw
.end:	ret


spawn:
	; generate new random piece
	call rand_piece
	push ax

	; erase the previous preview piece
	mov ax, [next_piece]
	or ax, ERASE_BIT
	mov bl, PREVIEW_POS
	mov bh, bl
	xor dx, dx
	push bx
	call draw_piece
	; and draw the new random piece in its place
	pop bx
	mov bp, sp
	mov ax, [bp]	; don't pop it off the stack we'll need it
	xor dx, dx
	call draw_piece

	; update cur_piece to whatever next_piece was, and put the
	; new random piece in the next_piece variable
	mov ax, [next_piece]
	mov [cur_piece], ax
	pop ax
	mov [next_piece], ax

	; cancel any rotation
	xor ax, ax
	mov [prev_rot], ax
	mov [cur_rot], ax
	; reset the position to the default at the top
	mov ax, 40 - 2		; X pos: center screen -2
	mov [px], ax
	mov [next_px], ax
	mov bx, [cur_piece]
	mov ax, [bx + piece_spawn_py]
	mov [next_py], ax
	inc ax
	mov [py], ax

	call collision
	jc .end
	mov word [just_spawned], 1
.end:	ret

collision:
	clc
	ret

stick:
	ret

erase_completed:
	ret

	; expects piece in ax (bit 15 means erase), position (X/Y) in bl/bh,
	; rotation in dl
draw_piece:
	; TODO
	ret

drawbg:
	mov ax, [vmemseg]
	mov es, ax
	mov di, PF_XOFFS * 2
	mov si, scrbuf
	mov dx, SCR_ROWS
.yloop: mov cx, SCR_COLS
.xloop:	xor ax, ax
	lodsb		; read tile number from screen buffer
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

print_numbers:
	sub sp, 16

	mov ax, [score]
	mov di, sp
	mov cx, 10
	call format_num

	mov cx, [tiles + 41]
	mov ax, 3
	mov bx, PF_XOFFS + 14 * 2
	mov si, sp
	call drawstr

	mov ax, [level]
	mov di, sp
	mov cx, 2
	call format_num

	mov cx, [tiles + 41]
	mov ax, 7
	mov bx, PF_XOFFS + 17 * 2
	mov si, sp
	call drawstr

	mov ax, [lines]
	mov di, sp
	mov cx, 8
	call format_num

	mov cx, [tiles + 41]
	mov ax, 10
	mov bx, PF_XOFFS + 14 * 2
	mov si, sp
	call drawstr

	add sp, 16
	ret

	; expects number in ax, buffer in di, field width in cx
format_num:
	mov bp, di
	add di, cx
	mov byte [di], 0	; null terminator
	dec di
	cmp di, bp
	jz .end
	mov cx, 10
.convloop:
	xor dx, dx
	div cx
	add dl, '0'
	mov [di], dl
	dec di
	cmp di, bp
	jb .end
	test ax, ax
	jnz .convloop
	; fill leftover space with spaces
.fill:	cmp di, bp
	jb .end
	mov byte [di], ' '
	dec di
	jmp .fill
.end:	ret

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


rand_piece:
	; TODO gen random number
	mov ax, [rand_state]
	inc ax
	mov bl, 7
	div bl
	mov al, ah
	xor ah, ah
	ret

	align 2
rand_state dw 0
prev_tick dw 0
deltat dw 0

game_state:
px dw 0
py dw 0
next_px dw 0
next_py dw 0
prev_rot dw 0
cur_rot dw 0
paused dw 0
gameover dw 0
num_complines dw 0
score dw 0
level dw 0
lines dw 0
just_spawned dw 0
tick_interval dw 0
cur_piece dw -1
prev_piece dw 0
next_piece dw 0
game_state_end:

level_speed:
	dw 887, 820, 753, 686, 619, 552, 469, 368, 285, 184
	dw 167, 151, 134, 117, 107, 98, 88, 79, 69, 60, 50

piece_spawn_py dw -1, -1, -2, -1, -1, -1, -1

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
; vi:set ts=8 sts=8 sw=8 ft=nasm:
