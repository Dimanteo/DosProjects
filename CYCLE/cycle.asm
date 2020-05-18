.model tiny
.code
org 100h

Start:	mov bx, offset Msg
	mov ah, 0eh

Cycle:	mov al, [bx]
	int 10h
	inc bx
	cmp al, 0h
	jne Cycle
	mov ax, 4c00h
	int 21h

.data

Msg:	db "The Line", 0h	

end	Start
	