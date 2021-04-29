; vi:set ts=8 sts=8 sw=8 ft=nasm:
scr_rows equ 20
scr_cols equ 20
pf_xoffs equ 20

start_game:
	; fill the screen buffer, and draw
	xor ax, ax
	mov es, ax	; reset es as it's used for video memory elsewhere
	mov di, scrbuf
	mov si, bgdata
	mov cx, scr_rows * scr_cols
	rep movsw

	call drawbg
	ret

drawbg:
	mov ax, 0b800h
	mov es, ax
	mov di, pf_xoffs * 2
	xor si, si
	mov dx, scr_rows
.yloop:	mov cx, scr_cols
	rep movsw
	add di, (80 - scr_cols) * 2	; skip to the start of the next row
	dec dx
	jnz .yloop

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
	
scrbuf	resw scr_rows * scr_cols

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

tiles	dw 0020h, 0020h		; black tile
	dw 7720h, 7720h		; playfield background
	dw 70b1h, 70b1h		; well separator
	dw 40c5h, 40c5h		; gameover fill
	dw 765bh, 765dh		; L
	dw 725bh, 725dh		; J
	dw 735bh, 735dh		; I
	dw 715bh, 715dh		; O
	dw 745bh, 745dh		; Z
	dw 755bh, 755dh		; S
	dw 705bh, 705dh		; T
	dw 70dah, 70c4h		; top-left corner
	dw 70c4h, 70bfh		; top-right corner
	dw 70c0h, 70c4h		; bottom-left corner
	dw 70c4h, 70d9h		; bottom-right corner
	dw 70c3h, 70c4h		; left-T
	dw 70c4h, 70b4h		; right-T
	dw 70c4h, 70c4h		; horizontal line
	dw 70b3h, 7020h		; left vertical line
	dw 7020h, 70b3h		; right vertical line
