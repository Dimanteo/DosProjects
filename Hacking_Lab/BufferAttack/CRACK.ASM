.model tiny
.code
org 100h

Start:
	mov dx, offset OutStr
	mov ah, 09h
	int 21h

	mov ax, 4c00h
	int 21h
.data
OutStr: 	db 0, 0, 0, 2, 2, 2, 3, 1, 0, 0, 0, 0, 0, '$'		
end Start