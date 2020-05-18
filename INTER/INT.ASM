locals @@
.186
.model tiny
.code

org 100h

Start:          jmp Main

		include frame.asm

Main:		xor ax, ax
		mov es, ax
		mov bx, INT_SIZE * INT_NUM		;���������� ����� ���������� � �������

		cli
		mov ax, es:[bx]
		mov Old09, ax
		mov ax, es:[bx+2]
		mov Old09 + 2, ax

		mov ax, cs
		mov word ptr es:[bx], offset New09
		mov word ptr es:[bx + 2], ax
		sti

		mov ah, 31h
		mov dx, offset TheEnd
		shr dx, 4
		inc dx
		int 21h
;---------------------------------------------------------------

New09		proc
		push ax bx cx dx es di si

		call DrawFrame
		in al, 60h				;read scan-code from keyboard controller
		call ToHex

		pop si di es dx cx bx ax   		

		db 0eah					;jmpfar
Old09		dw 0					;reserve place for address of handler
		dw 0

		iret
		endp

;--------------------------- ToHex -----------------------------------
;Params:	AL - hexadecimal number to write
;---------------------------------------------------------------------
;Destroy:	[AX], [DI], [ES]
;---------------------------------------------------------------------

HexStr 		db '0123456789ABCDEF'

ToHex		proc
		mov ah, al
		shr al, 4				;take first numeral
		shl ah, 4
		shr ah, 4               		;take second numeral

		mov bx, offset HexStr
		xlat					; mov al, [al+bx]

		cmp al, 9h                              ;translate hex numbers into ASCII code of that number
		ja @@AL_10
		add al, '0'
		jmp @@Next_Num
@@AL_10:	add al, 'A'-'0'+10

@@Next_Num:	cmp ah, 9h
		ja @@AH_10
		add ah, 30h
		jmp @@Continue
@@AH_10:	add ah, 37h

@@Continue:	mov di, video_memory			;write character on screen
		mov es, di
		mov di, ((y + frame_height / 2) * line_size + x + frame_width / 2) * 2
		stosb
		inc di
		mov al, ah
		stosb
		ret
		endp

TheEnd:

end 		Start
