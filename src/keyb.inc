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
%ifndef KEYB_INC_
%define KEYB_INC_

KB_ESC		equ 27
KB_LALT		equ 128
KB_RALT		equ 129
KB_LCTRL	equ 130
KB_RCTRL	equ 131
KB_LSHIFT	equ 132
KB_RSHIFT	equ 133
KB_F1		equ 134
KB_F2		equ 135
KB_F3		equ 136
KB_F4		equ 137
KB_F5		equ 138
KB_F6		equ 139
KB_F7		equ 140
KB_F8		equ 141
KB_F9		equ 142
KB_F10		equ 143
KB_F11		equ 144
KB_F12		equ 145
KB_CAPSLK	equ 146
KB_NUMLK	equ 147
KB_SCRLK	equ 148
KB_SYSRQ	equ 149
KB_INS		equ 150
KB_DEL		equ 151
KB_HOME		equ 152
KB_END		equ 153
KB_PGUP		equ 154
KB_PGDN		equ 155
KB_LEFT		equ 156
KB_RIGHT	equ 157
KB_UP		equ 158
KB_DOWN		equ 159
KB_NUM_DOT	equ 160
KB_NUM_ENTER	equ 161
KB_NUM_PLUS	equ 162
KB_NUM_MINUS	equ 163
KB_NUM_MUL	equ 164
KB_NUM_DIV	equ 165
KB_NUM0		equ 166
KB_NUM1		equ 167
KB_NUM2		equ 168
KB_NUM3		equ 169
KB_NUM4		equ 170
KB_NUM5		equ 171
KB_NUM6		equ 172
KB_NUM7		equ 173
KB_NUM8		equ 174
KB_NUM9		equ 175

KB_MAXKEYS	equ 180

%endif	; KEYB_INC_
; vi:ts=8 sts=8 sw=8 ft=nasm:
