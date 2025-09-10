.286

.MODEL small

.STACK 100h

.DATA
        msg db 'Hello world!', 13, 10, '$'
        gMemSeg dw 0A000h

.CODE

main PROC                 
        call InitProgram

        mov dx, OFFSET msg
        mov ah, 9
        int 21h

        call GraphicModeOn

        mov ax, 10  ; start x
        push ax
        mov ax, 10  ; start y
        push ax
        mov ax, 100  ; end x
        push ax
        mov ax, 100  ; end y
        push ax
        mov al, 101  ; color
        push ax
        call DrawRect

        call ReadChar

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

        ret
InitProgram ENDP

; turn on graphic mode by interrupt
; no args
; no returns
GraphicModeOn PROC
        push ax

        mov ah, 00h
        mov al, 13h
        int 10h

        pop ax

        ret
GraphicModeOn ENDP

; turn off graphic mode by interrupt
; no args
; no returns
GraphicModeOff PROC
        push ax

        mov ah, 00h
        mov al, 03h
        int 10h

        pop ax

        ret
GraphicModeOff ENDP

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

; draw a rect
; stack 14h
; args: 8:[start x] 6:[start y] 4:[end x] 2:[end y] 0:[color]
; no returns
DrawRect PROC
        pusha
        pushf

        ; init graph segment
        mov ax, ds:[gMemSeg]
        mov es, ax

        mov bp, sp


        ; calc height of rect
        mov cx, ss:[bp + 14h + 2]; end_y
        sub cx, ss:[bp + 14h + 6]; end_y - start_y
        sub bx, bx  ; count = 0
@y:     
        push cx
        push bx

        mov ax, 320; ax = 320
        add bx, ss:[bp + 14h + 6]; bx = count + start_y
        mul bx; result = ax * bx
        mov di, ax; offset = result

        ; calc width of rect
        mov cx, ss:[bp + 14h + 4]; end_x
        sub cx, ss:[bp + 14h + 8]; end_x - start_x
        sub bx, bx  ; count = 0
@x:
        push bx

        mov ax, ss:[bp + 14h]; color
        add bx, ss:[bp + 14h + 8]; bx = count + start_x

        mov es:[di + bx], al; write into gmem buffer

        pop bx
        inc bx; count += 1
        loop @x

        pop bx
        pop cx
        inc bx; count += 1
        loop @y

        popf
        popa

        ret 10
DrawRect ENDP

END main
