locals @@	;������������ ?? �� @@ ��� ��������� �����
.186
.model tiny
.code

.getch		macro
		nop
		xor ah, ah
		int 16h
		nop
		endm

.myexit		macro ret
		nop
	ifnb <ret>
		mov ax, 4c00h or (ret and 0ffh)		;and 0ffh ����� ����� �������� ������������ ���� ������
	else
		mov ah, 4ch
	endif

		int 21h
		nop
		endm

org 100h

Start:          mov ax, (5eh shl 8) or '*' 	;ax �������� �������
		xor bx, bx
		mov cx, 80d
		call DrawLine
		.getch

		mov ah, 0b3h
		call DrawLine
		.getch
		.myexit
;-----------------------------------------------------
;Draw a horizontal line
;Entry: AH - color attr
;	AL - symb to draw
;	BX - addr to start a line
;	CX - number of symbols
;Destr: BX, CX, ES
;-----------------------------------------------------		
DrawLine	proc            ;���������, �� �������� ����������� �����
                push 0b800h
		pop es
;@@Next:
		rep stosw	;mov es:[di], ax
				;add di, 2
                ;loop @@Next 	;��������� �����, ����� ������ ���������. DrawLineNext
                                ;��������� ��������� ����� ??Next. � ������� locals ����� �������������� �������
                ret
                endp		;���������, �� �������� ����������� ��������


end	Start