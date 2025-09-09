; all args in stack
; all returns in stack

.286

.MODEL small

.STACK 100h

.DATA
        msg db 'Hello world!', 13, 10, '$'

.CODE

InitProgram PROC
        ; ds must init in exe
        mov ax, @data
        mov ds, ax

        ret
InitProgram ENDP

main PROC                 
        call InitProgram

        mov dx, OFFSET msg
        mov ah, 9
        int 21h

        call GraphicModeOn

        call GraphicModeOff

        mov ah, 4ch
        int 21h
main ENDP

; turn on graphic mode by interrupt
; no args
; no returns
GraphicModeOn PROC
        pusha
        pushf

        mov ah, 00h
        mov al, 13h
        int 10h

        popf
        popa

        ret
GraphicModeOn ENDP

; turn off graphic mode by interrupt
; no args
; no returns
GraphicModeOff PROC
        pusha
        pushf

        mov ah, 00h
        mov al, 03h
        int 10h

        popf
        popa
        
        ret
GraphicModeOff ENDP

END main
