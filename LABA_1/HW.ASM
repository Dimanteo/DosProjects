.model tiny
.code
org 100h

Start:	mov dl, '!'
	nop
	nop
	nop
	mov ah, 09h
	int 21h

	mov ax, 4c00h
	int 21h

Msg:	db "Hello world", 13, 10, '$'

end 	Start