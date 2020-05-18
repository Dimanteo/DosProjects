locals @@
.186
.model tiny
.code

print 		macro symb
		mov ah, 0eh
		mov al, symb
		int 10h
		endm

print_dx	macro
		mov ah, 9h
		int 21h
		endm


org 100h

Start:          

;Expected programm output:ok\0 0 ok\0 0 6 bbbbbbaaaa\0 cdok\0 0		

;---------------------Main----------------------------------
;strchr test 1. Input: strchr("abcdok", 'o'). Expected output: ok\0
;-----------------------------------------------------------
                push 'o'                        ;const char c
                push offset strchrS		;const char* s
		push bp
		mov bp, sp
		call strchr
		pop bp
		mov dx, ax
		
		print_dx			;print(strchr(...))
		print ' '
;-------------------------------------------------------------
;strchr test 2. Input: strchr("abcdok", 'e') Expected output: 0
;--------------------------------------------------------------
		push 'e'
		push offset strchrS
		push bp
		mov bp, sp
		call strchr
		pop bp
		
		cmp ax, 0
		call print_null                
		print " "
;-------------------------------------------------------------
;strrchr test 1. Input: strrchr("oopsaopsbcdok", 'o') Expected output: ok\0
;-------------------------------------------------------------
		push 'o'  
		push offset strrchrS
		push bp
		mov bp, sp
		call strrchr
		pop bp

		print_dx
		print " "
		
;-------------------------------------------------------------
;strrchr test 2. Input: strrchr("oopsaopsbcdok", 'O') Expected output: 0
;-------------------------------------------------------------
		push 'O'  
		push offset strrchrS
		push bp
		mov bp, sp
		call strrchr
		pop bp

		cmp dx, 0
		call print_null
		print " "
;--------------------------------------------------------------
;strlen	test 1. Input: strlen("abcdok") Expected output: 6
;--------------------------------------------------------------
		push offset strchrS
		push bp
		mov bp, sp
		call strlen
		pop bp

		add al, 48
		print al
		print " "
;---------------------------------------------------------------		
;strcpy test 1. Input: strcpy("aaaaaaaaaa", "bbbbbb") Expected output: bbbbbbaaaa
;---------------------------------------------------------------
		push offset strcpyCT
		push offset strcpyS
		push bp
		mov bp, sp		
		call strcpy
		pop bp

		mov dx, ax
		print_dx
		print " "	


;----------------------------------------------------------------
;strstr test 1. Input: strstr("abcdok", "cd") Expected output: cdok
;----------------------------------------------------------------
                push offset strstrCT
                push offset strchrS
                push bp
                mov bp, sp
                call strstr
                pop bp

                cmp dx, 0
                jne PrintS1
                call print_null
                jmp Skip1
PrintS1:        print_dx
Skip1:          print " "
;-----------------------------------------------------------------
;strstr test 2. Input: strstr("aaaaaaaaaa", "cd") Expected output: 0
;-----------------------------------------------------------------
		push offset strstrCT
		push offset strcpyS
		push bp
		mov bp, sp
		call strstr
		pop bp

		cmp dx, 0
                jne PrintS2
                call print_null
                jmp Skip2
PrintS2:        print_dx
Skip2:
;-----------------------------------------------------------------
              	;EXIT
		mov ax, 4c00h
		int 21h	
;=================================================================



;--------------------- print_null -------------------------------
print_null	proc
		jne @@Error
		print '0'
		jmp @@Correct
@@Error:	print '!' 
@@Correct:	ret
		endp	
;------------------------------------------------------------


;--------------------- STRLEN -------------------------------
;Params:	[SP + 2]	- string address
;------------------------------------------------------------
;Returns:	[AX]		- string length
;------------------------------------------------------------
;Destroy:	[ES], [DI] 
;------------------------------------------------------------
strlen		proc
		mov ax, [bp + 2]
		mov di, ax
		mov ax, ds
		mov es, ax
		xor al, al		
@@Next:		scasb 
		jne @@Next
		mov ax, di
		dec ax
		sub ax, [bp + 2]
		ret
		endp
;------------------------------------------------------------


;--------------------- STRCHR -------------------------------
;Params:	[SP + 2]	- string address
;		[SP + 4] 	- char to search for
;------------------------------------------------------------
;Returns:	[AX]		- char address
;------------------------------------------------------------
;Destroy:	[DI], [ES] 
;------------------------------------------------------------
strchr		proc
		mov ax, [bp + 2]
		mov di, ax
		mov ax, ds
		mov es, ax
		mov al, byte ptr [bp + 4]
@@Next:		cmp byte ptr es:[di], 0
		je @@Break
		scasb
		je @@Found
		jmp @@Next
@@Found:	dec di
		mov ax, di
		ret
@@Break:	xor ax, ax		
		ret
		endp
;-------------------------------------------------------------


;--------------------- STRRCHR -------------------------------
;Params:	[SP + 2]	- string address
;		[SP + 4] 	- char to search for
;------------------------------------------------------------
;Returns:	[DX]		- last char address
;------------------------------------------------------------
;Destroy:	[AX], [DI], [ES] 
;------------------------------------------------------------
strrchr		proc
		mov ax, ds
		mov es, ax
		mov ax, [bp + 2]
		mov di, ax
		mov al, 0
		mov ah, [bp + 4]
		mov dx, 0
@@Next:		cmp ah, byte ptr es:[di]
		jne @@Skip
		mov dx, di
@@Skip:		scasb
		jne @@Next
		ret
		endp
;-------------------------------------------------------------


;--------------------- STRCPY --------------------------------
;Params:	[SP + 2]	- address of destination
;		[SP + 4]	- address of source
;--------------------------------------------------------------		
;Returns:	[AX]		- address of destination
;--------------------------------------------------------------
;Destroy:	[CX], [DI], [SI], [ES]
;-------------------------------------------------------------
strcpy		proc
		push [bp + 4]
		push bp
		mov bp, sp
		call strlen
		pop bp
		mov cx, ax
		pop ax			;clear stack from strlen args
		mov ax, ds
		mov es, ax		
		mov ax, [bp + 4]
		mov si, ax
		mov ax, [bp + 2]
		mov di, ax
		rep movsb
		ret
		endp
;-------------------------------------------------------------


;--------------------- STRSTR --------------------------------
;Params:	[SP + 2]	- address of source string, where to search
;		[SP + 4]	- address of sample string
;-------------------------------------------------------------
;Returns:	[DX]		- address of first sample in source	
;-------------------------------------------------------------
;Destroy:	[AX], [BX], [CX], [DX], [ES], [SI], [DI]
;-------------------------------------------------------------
strstr		proc
		mov cx, ds
		mov es, cx
		push [bp + 4]
		push bp
		mov bp, sp
		call strlen
		pop bp
		pop cx				;clear stack from strlen args		
		mov cx, ax
		mov dx, [bp + 2]
		mov si, [bp + 4]	
						;SI - address of sample
						;CX - length of sample string
						;DX - pointer to source string, show on substring started with the same symb as sample 

@@Next:		mov al, byte ptr es:[si]	;push first symbol from sample	
		xor ah, ah
		push ax
		push dx 			;push source address
		push bp
		mov bp, sp
		call strchr		
		mov dx, ax			;update source string pointer               
		pop bp
		pop ax				;clear stack from strchr args
		pop ax
		cmp dx, 0	
		je @@Ret_Null
		mov ax, cx			;save sample length value, destroyed by REPE
		mov di, dx 
		repe cmpsb
		je @@Ret_DX 			;if repe ended on equals (ZF = 1)
		inc dx		
		mov bx, dx 					
		cmp byte ptr es:[bx], 0
		je @@Ret_Null
		mov cx, ax
		jmp @@Next

@@Ret_Null:	mov dx, 0
		ret	

@@Ret_DX:	ret		
		endp
;-------------------------------------------------------------
.data
strchrS 	db "abcdok", 0 , '$'
strrchrS 	db "oopsaopsbcdok", 0 , '$'
strcpyS		db "aaaaaaaaaa", 0, '$'
strcpyCT	db "bbbbbb", 0
strstrCT	db "cd", 0

end Start