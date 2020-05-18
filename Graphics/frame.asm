.model tiny             
.code
org 100h

Start:	
		mov bl, 00h
		mov ax, 1003h
		int 10h
		
		mov bx, 0b800h             
		mov es, bx
		L equ 9 	 	;LEFT
		R equ 72        	;RIGHT
		U equ 2         	;UP
		D equ 21        	;DOWN
		line_size equ 160	;sizeof(Line)
		mov bx, 0
		mov cx, L  		;column  20:64
		mov dx, U  		;row, (80 * dx + cx) * 2 = position


NextLine:	cmp dx, U
		je FilledLine
		cmp dx, D
		je FilledLine
		cmp dx, D + 1
		jae Finish  
		jmp BlankLine


FilledLine:	mov ax, 0edfh    		;- c4
		call PrintSymbol
		inc dx
		jmp NextLine
		

BlankLine:	mov ax, 0020h                   ;" "
		call PrintSymbol
		mov al, line_size
		mov ah, 00h
		push dx
		mul dx
		pop dx
		mov bx, ax
		add bx, L * 2
		mov word ptr es:[bx], 0eddh	;| b3
		add bx, (R - L) * 2
		mov word ptr es:[bx], 0edeh	;| b3
		inc dx
		jmp NextLine		


Finish:		mov bx, line_size * U + 2 * L
		mov word ptr es:[bx], 0edch  	;da
		mov bx, line_size * U + 2 * R
		mov word ptr es:[bx], 0edfh	;bf
		mov bx, line_size * D + 2 * L
		mov word ptr es:[bx], 0edch  	;c0
		mov bx, line_size * D + 2 * R
		mov word ptr es:[bx], 0edfh   	;d9

		mov bx, line_size * 4 + (R + 1) * 2 + 1
Shadow_V:	mov byte ptr es:[bx], 8eh
		add bx, 2
		mov byte ptr es:[bx], 8eh
		add bx, line_size - 2
		cmp bx, line_size * (D + 2)
		jb Shadow_V
		
		mov bx, line_size * (D  + 1) + 2 * (L + 2) + 1
Shadow_H:	mov byte ptr es:[bx], 8eh
		add bx, 2
		cmp bx, line_size * (D  + 1) + 2 * (R + 2) + 1
		jb Shadow_H
			

		mov ax, 4c00h
		int 21h


;==============Print Symbol=======================
;Fill line* with specified symbol
;ah - symbol ASCII
;al - symbol color
;dx - line
;================================================
PrintSymbol:	push ax
		mov al, line_size
		mov ah, 00h
		push dx
		mul dx 
		pop dx
		mov bx, ax
		mov al, 2
		mov ah, 00h
		push dx
		mul cx
		pop dx
		add bx, ax
		pop ax        
Next:		mov word ptr es:[bx], ax  
		inc cx
		cmp cx, R + 1
		je FuncEnd
		add bx, 2
		jmp Next
FuncEnd:	mov cx, L
		ret



end Start 
