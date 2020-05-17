locals @@
.186
.model tiny
.code
org 100h
print		macro symb
		mov ah, 0eh
		mov al, symb
		int 10h
		endm

print_dx	macro
		mov ah, 9h
		int 21h
		endm
				

Start:		
;-------------------------------------------------------------------------------
;memset test. Input: memset("error", 'K', 3). Expected Output: "KKKor"
		
		push 3 				;size_t n
		push 'K'                        ;char c
		push offset memsetSTR		;void* s
		push bp
		mov bp, sp		
		call memset
		pop bp
		
		print_dx
		print ' '

;------------------------------------------------------------------------------		
;memcpy test. Input: memcpy("error", "ok", 2). Expected Output: "okror"		
                   
		push 2                         	;size_t n  
		push offset memcpyCT            ;const void* ct
		push offset memcpyS             ;void* s
		push bp
		mov bp, sp
		call memcpy
		pop bp

		print_dx
		print ' '

;------------------------------------------------------------------------------		
;memchr test. Input: memchr("errorFokF-", 'F', 10). Expected Output: "FokF-"				

		push 10      			;size_t n
		push 'F'			;char c
		push offset memchrCS		;const void* cs
		push bp
		mov bp, sp
		call memchr
		pop bp
		mov dx, di

		print_dx
		print ' ' 
                       
;------------------------------------------------------------------------------		
;memcmp test 1. Input: memcmp("aabcd", "aabea", 4). Expected Output: "-"				
		
		push 4				;size_t n
		push offset memcmp2		;const void* ct
		push offset memcmp1		;const void* cs
		push bp
		mov bp, sp
		call memcmp
		pop dx				;dx = memcmp(...)
		pop bp

		
		print dl			
		print ' '

;------------------------------------------------------------------------------		
;memcmp test 2. Input: memcmp("aabea", "aabcd", 4). Expected Output: "+"			

		push 4				;size_t n
		push offset memcmp1		;const void* cs
		push offset memcmp2		;const void* ct
		push bp
		mov bp, sp
		call memcmp
		pop dx				;dx = memcmp(...)
		pop bp
		
		print dl
		print ' '

;------------------------------------------------------------------------------		
;memcmp test 3. Input: memcmp("aabcd", "aabea", 3). Expected Output: "0"			

		push 3				;size_t n
		push offset memcmp2		;const void* ct
		push offset memcmp1		;const void* cs
		push bp
		mov bp, sp
		call memcmp
		pop dx				;dx = memcmp(...)
		pop bp

		print dl

;-------------------------------------------------------------------------------
;Expected prgramm output: "KKKor okror FokF- - + 0"

                mov ax, 4c00h
                int 21h
                

;---------------- MEMSET -----------------------
;Params:	[SP + 2] 		- string address
;		[SP + 4] 	- char
;		[SP + 6] 	- number of symbols
;---------------------------------------------
;Returns:	DX 		- string address
;---------------------------------------------
;Destroy:	CX, ES, AX, BX, DI
;---------------------------------------------
memset		proc
		mov cx, [bp + 6]
		mov bx, [bp + 2]
		mov di, bx
		mov dx, ds
		mov es, dx
		mov ax, [bp + 4]
		rep stosb
		mov dx, bx
		ret
		endp
;-----------------------------------------------------

;------------------ MEMCPY -----------------------------
;Params:	[SP + 2] 	- source address
;		[SP + 4] 	- destination address
;		[SP + 6]	- count
;-----------------------------------------------------
;Returns:	DX 		- source address
;-----------------------------------------------------
;Destroy:	CX, SI, DI, ES
;-----------------------------------------------------	
memcpy		proc
		mov dx, [bp + 4]
		mov si, dx
		mov cx, [bp + 6]
		mov dx, ds
		mov es, dx
		mov dx, [bp + 2]
		mov di, dx
		rep movsb
		ret
		endp
;-----------------------------------------------------		

;------------------- MEMCHR --------------------------
;Params:	[SP + 2]	- string adress
;		[SP + 4] 	- symbol to search for
;		[SP + 6] 	- count
;-----------------------------------------------------
;Returns:	DI 		- adress of symbol
;-----------------------------------------------------
;Destroy:	AH, CX, ES
;-----------------------------------------------------
memchr		proc
		mov cx, ds
		mov es, cx
		mov cx, [bp + 2]
		mov di, cx
		mov cx, [bp + 6]
		mov al, byte ptr [bp + 4]
		repne scasb
		je @@Found			;ZF = 1 if char was found
		xor di, di
		ret
@@Found:	dec di               		;If found DI points to the next byte
		ret
		endp
;-----------------------------------------------------

;--------------------- MEMCMP ------------------------
;Params:	[SP + 2]	- first string adress
;		[SP + 4]	- second string address
;		[SP + 6]	- count
;-----------------------------------------------------
;Returns:	[SP]		- 1 if first > second
;				  0 if equal
;				 -1 if first < second
;-----------------------------------------------------
;Destroys:      CX, ES, DI, SI
;-----------------------------------------------------
memcmp     	proc
		mov cx, ds
		mov es, cx
		mov cx, [bp + 4]
		mov di, cx
		mov cx, [bp + 2]
		mov si, cx
		mov cx, [bp +  6]
                repe cmpsb
                pop cx
               ; cmp byte ptr ds:[si], byte ptr es:[di]
           	ja @@Bigger
           	jb @@Lesser
           	push '0'
                jmp @@Return
@@Bigger:	push '+'
		jmp @@Return
@@Lesser:	push '-'
		jmp @@Return		
@@Return:	push cx
		ret		
		endp
;-----------------------------------------------------	
.data

memsetSTR:		db 'error$'
memcpyCT:		db 'ok'
memcpyS:		db 'error$'
memchrCS:		db 'errorFokF-$'
memcmp1:		db 'aabcd$'
memcmp2:		db 'aabea$'
end Start
