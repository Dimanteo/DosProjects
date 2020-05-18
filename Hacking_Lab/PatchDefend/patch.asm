; Для взлома с изменением исходника
; Вместо сравнения будем использовать вычитание
locals @@
.186
.model tiny
.code
org 100h

BS              equ     08h                     ; backspace
LF              equ     0dh
CR              equ     0ah
EXIT_0          equ     4c00h

;===============================================================================
;Description:   print string
;-------------------------------------------------------------------------------
;Params:        str - Label of string.
;===============================================================================

puts            macro str
                mov ah, 09h
                mov dx, offset str
                int 21h
                endm

;===============================================================================
;Description:   main() - Reads password from stdout. Checks it.
;               Print "Access granted :D" if password correct, otherwise
;               print "Wrong password, try again".
;===============================================================================

Start:
                puts Invite                     ; printf("%s", dx);
                xor cx, cx
                jmp NextSym

Invite:         db "Password:$"                 ; если я помещу это в data, то прибавив к адресу длину строки меня взломают
Password:       db "sass"
pass_len        equ $ - Password                ; password length

NextSym:        mov ah, 01h
                int 21h                         ; al = getc()

                cmp al, LF
                je Finish

                call checkSymbol
                inc cx
                jmp NextSym

Finish:         mov ah, 02h
                call checkPassword
                mov ax, EXIT_0
                int 21h


;===============================================================================
;Description:   Checks password.
;-------------------------------------------------------------------------------
;Params:        AL      - char
;               CX      - char position in password
;-------------------------------------------------------------------------------
;Destroy:       BX, DL
;===============================================================================

checkSymbol     proc
                cmp cx, pass_len
                jae @@Return
                mov bx, offset Password
                add bx, cx
                mov dl, byte ptr ds:[bx]
                sub dl, al
                mov byte ptr ds:[bx], dl
@@Return:       ret
                endp


;===============================================================================
;Description:   Final check of Password.
;-------------------------------------------------------------------------------
;Returns:       AH      - 09h
;               DX      - adress of output message
;-------------------------------------------------------------------------------
;Destroy:       AX, BX, CX, DX, DI
;===============================================================================

checkPassword   proc
                cmp cx, pass_len
                jne @@Denied

                mov bx, Error_msg - OK_msg
                mov di, offset Password
                xor ax, ax

@@Next:         mov al, byte ptr [di]
                add bx, ax
                inc di
                loop @@Next

                mov ax, offset Error_msg
                sub ax, bx
                cmp ax, offset OK_msg
                jne @@Denied

                mov dx, ax
                jmp @@Granted

@@Denied:       mov dx, offset Error_msg

@@Granted:      mov ah, 09h
                int 21h
                ret
                endp


.data

OK_msg: 	db "Access granted :D", LF, CR, "$"
Error_msg       db LF, CR, "Wrong password, try again.", LF, CR, "$"
FalsePassword:  db "godgodgod"

end 		Start
