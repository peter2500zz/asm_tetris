.286

.MODEL small

.STACK 100h

.DATA
        msg db 'Hello world!', 13, 10, '$'

.CODE

extrn GraphicModeOn:near
extrn GraphicModeOff:near
extrn RenderTetrisPlayground:near
extrn UpdateTetrisPlayground:near
extrn PlayGroundInit:near

main PROC                 
        call InitProgram

        mov dx, OFFSET msg
        mov ah, 9
        int 21h

        call GraphicModeOn

        ; mov ax, 10  ; start x
        ; push ax
        ; mov ax, 10  ; start y
        ; push ax
        ; mov ax, 100  ; end x
        ; push ax
        ; mov ax, 100  ; end y
        ; push ax
        ; mov al, 101  ; color
        ; push ax
        ; call FillRect

        ; mov ax, 11  ; start x
        ; push ax
        ; mov ax, 11  ; start y
        ; push ax
        ; mov ax, 99  ; end x
        ; push ax
        ; mov ax, 99  ; end y
        ; push ax
        ; mov al, 65  ; color
        ; push ax
        ; call FillRect

@tick:
        call RenderTetrisPlayground

        call ReadChar
        call UpdateTetrisPlayground
        cmp al, 116
        je @tick

        call GraphicModeOff

        mov ah, 4ch
        int 21h
main ENDP

; init registers
; no args
; no returns
InitProgram PROC
        ; ds must init in exe
        mov ax, @data
        mov ds, ax

        call PlayGroundInit

        ret
InitProgram ENDP

; wait and read a char from input
; no args
; returns: al=[read char ascii] ah=[scan]
ReadChar PROC
@no_key:
        ; check if key is pressed
        mov ah,01h
        int 16h

        jz @no_key

        mov ah,00h
        int 16h

        ret
ReadChar ENDP

END main
