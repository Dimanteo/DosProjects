locals @@
.model tiny
.code 

org 100h


Start:		video_memory 	equ 0b800h
		line_size 	equ 80
		frame_width 	equ 45
		frame_height 	equ 6
		X 		equ 20           	;frame coordinates
		y 		equ 5			;
		lu_corner 	equ 0c9h		;Left up corner
		ru_corner 	equ 0bbh		;Right up corner
		ld_corner	equ 0c8h		;left down corner
		rd_corner	equ 0bch		;right down corner
		h_side		equ 0cdh		;horizontal side
		v_side		equ 0bah		;vertical side
		space		equ 20h			;space 
		color		equ 5f00h		;Window color. Brt white on magenta
		shadow		equ 1300h		;Shadow color. Magenta on grey

;--------------------Main-----------------------
		mov ax, 1003h
		mov bl, 00h
		int 10

	      	mov bx, video_memory
		mov es, bx
		mov ax, color + h_side
		mov bx, (X shl 8) + Y
		mov cx, frame_width
		call drawHorizon

		mov ax, color + space
		mov cx, frame_height - 1
		mov dx, frame_width
		call fillFrame

		mov ax, color + h_side
		inc bl
		mov cx, frame_width
		call drawHorizon
		
		mov ax, color + v_side 
		mov bx, (X shl 8) + Y
		mov cx, frame_height
		call drawVertical 
		
		mov bx, ((X + frame_width) shl 8) + Y
		mov cx, frame_height
		call drawVertical
		
		call drawCorners

		mov ax, shadow + space
		call drawShadow

		xor ax, ax
		int 16h

		mov ax, 4c00h
		int 21h


;==================== fillFrame ==========================
;Draws window background
;---------------------------------------------------------
;Params		AH - color attribute
;		AL - symbol to fill with
;		CX - frame height
;		DX - frame width
;		ES - video memory address
;		BH - X coordinate of up left corner
;		BL - Y coordinate of up left corner
;--------------------------------------------------------
;Destr		BX, CX, DI 
;---------------------------------------------------------
fillFrame	proc       
@@Next:		push cx
		mov cx, dx
		inc bl
		push dx
		call drawHorizon
		pop dx
		pop cx
		loop @@Next
		ret
		endp		


;=================== drawCorners ========================
;Draw frame corners
;--------------------------------------------------------
;Params:	ES - video memory address
;--------------------------------------------------------
;Destr: 	BX
;--------------------------------------------------------

drawCorners	proc
		mov bx, (Y * line_size + X) shl 1
		mov word ptr es:[bx], color + lu_corner
		add bx, frame_width shl 1
		mov word ptr es:[bx], color + ru_corner
		mov bx, ((Y + frame_height) * line_size + X) shl 1
		mov word ptr es:[bx], color + ld_corner
		add bx, frame_width shl 1
		mov word ptr es:[bx], color + rd_corner
		ret
		endp		


;================ coord_to_addr ======================
;Translate coordinates in BX to address of element
;in video memory, stores it in DI.
;----------------------------------------------------
;Params:	BH - X coordinate
;		BL - Y coordinate
;----------------------------------------------------
;Returns:	DI - adress of symbol in video memory
;----------------------------------------------------
;Destr:		DX
;----------------------------------------------------
	
coord_to_addr	proc
		push ax
		mov al, line_size              
		mul bl
		xor di, di
		xor dx, dx
		mov dl, bh
		add dx, ax
		shl dx, 1
		mov di, dx
		pop ax
		ret   		
		endp
		


;=============== drawHorizon =====================
;Draws a horizontal line
;-------------------------------------------------
;Params:	AH - color attr
;	        AL - symb to draw
;	        BH - X coordinate of line beginning
;	        BL - Y coordinate of line beginning
;	        CX - line length
;		ES - video memory address
;-------------------------------------------------
;Destr:		CX, DX, DI	       
;-------------------------------------------------

drawHorizon	proc 
		call coord_to_addr 
		rep stosw
		ret
		endp


;================ drawVertical ====================
;Draws a vertical line
;--------------------------------------------------
;Params:	AH - color attr
;	        AL - symb to draw
;	        BH - X coordinate of line beginning
;	        BL - Y coordinate of line beginning
;	        CX - line length
;		ES - video memory address
;--------------------------------------------------
;Destr:		CX, DX, DI
;--------------------------------------------------

drawVertical	proc
		call coord_to_addr
@@Next:		mov es:[di], ax
		add di, line_size shl 1
		loop @@Next
		ret
		endp


;================ drawShadow ======================
;Draws shadow
;--------------------------------------------------
;Params:	ES - video memory address
;		AH - color attr
;--------------------------------------------------

drawShadow	proc
		mov bx, (X + frame_width + 1) shl 8 + Y + 1
		mov cx, frame_height + 1
		call drawVertical
		mov bx, (X + frame_width + 2) shl 8 + Y + 1
		mov cx, frame_height + 1
		call drawVertical
		
		mov bx, (X + 2) shl 8 + Y + frame_height + 1
		mov cx, frame_width
		call drawHorizon

		ret
		endp 		


end Start