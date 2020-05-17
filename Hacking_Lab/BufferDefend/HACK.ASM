; Взлом переполнением. В начале проги в стек кладется адрес функции сравнения.
; Команды для сравнения строки (спрятаны в сегменте данных) прямо перед буфером.
; Задача - переполнить буфер так, чтобы залезть в стек.
; Там поменять адрес возврата, так чтобы при проверке выполнялось начало буфера.
; В начало буфера поместить свой патч.

locals @@
.186
.model tiny
.code
org 100h

LF              equ     0dh
CR              equ     0ah
EXIT_0          equ     4c00h

PUTC            macro c
                mov ah, 02h
                mov dl, c
                int 21h
                endm


PUTS            macro str
                mov ah, 09h
                mov dx, offset str
                int 21h
                endm

ENDL            macro
                PUTC CR
                PUTC LF
                endm


;===============================================================================
;Description:   main() - Reads password from stdout. Checks it.
;               Print "Access granted :D" if password correct, otherwise
;               print "Wrong password, try again".
;===============================================================================

Start:
                PUTS Invite

                push offset Comparator          ; уязвисмость для взлома

                mov bx, offset Buffer
                xor dx, dx

NextSym:        mov ah, 01h
                int 21h                         ; al = getc()

                cmp al, LF
                je Break

                mov byte ptr [bx], al
                inc bx
                inc dx
                jmp NextSym

Break:          mov bx, offset Buffer
                call checkPass
                mov ax, EXIT_0
                int 21h


;===============================================================================
;Description:   Checks password.
;               Print "Access granted" if password correct, otherwise
;               print "Wrong password, try again".
;===============================================================================

checkPass       proc
                mov cx, pass_len
                mov si, offset Buffer
                mov di, offset Password

                pop ax                          ; это нужно чтобы
                pop bx                          ; взлом работал
                push ax
                jmp bx

Back:           je Correct
Wrong:          puts NOmsg
                jmp Return
Correct:        puts OKmsg
                jmp Return
Return:         ret
                endp


.data

Invite:         db "Password:$"
Password:       db "suss"
pass_len        equ $ - Password
OKmsg:          db "Access granted$"
NOmsg:          db "Wrong password$"

Comparator:     rep cmpsb
                jmp Back
Buffer:

end Start
