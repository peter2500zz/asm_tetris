.286

.MODEL small

.STACK 100h

.DATA
        msg db 'Hello world!', 13, 10, '$'
        gMemSeg dw 0A000h

        tetrisPlaygroundStartX dw 120
        tetrisPlaygroundStartY dw 20
        tetrisPlaygroundUnitSize dw 7
        ; tetrisPlayground unit
        ; size: word
        ; total: 10 x 20
        ; low: color
        ; high: 00000000b
        ;       ||||||||__ connect to up
        ;       |||||||___ connect to down
        ;       ||||||____ connect to left
        ;       |||||_____ connect to right
        ;       ||||______ is moving
        ;       ||________ m flag
        tetrisPlayground dw 200 dup(0)

.CODE

main PROC                 
        call InitProgram

        mov dx, OFFSET msg
        mov ah, 9
        int 21h

        mov cx, 200
        sub bx, bx
@b:
        mov ax, 2
        mul bx
        mov si, ax
        sub ax, ax
        mov ah, 00001111b
        mov al, 65
        mov ds:[tetrisPlayground + si], ax

        inc bx
        loop @b

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
        ; call DrawRect

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
        ; call DrawRect

        call RenderTetrisPlayground

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
@y0:     
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
@x0:
        push bx

        mov ax, ss:[bp + 14h]; color
        add bx, ss:[bp + 14h + 8]; bx = count + start_x

        mov es:[di + bx], al; write into gmem buffer

        pop bx
        inc bx; count += 1
        loop @x0

        pop bx
        pop cx
        inc bx; count += 1
        loop @y0

        popf
        popa

        ret 10
DrawRect ENDP

; render tetris playground
; no args
; no returns
RenderTetrisPlayground PROC
        pusha
        pushf

        mov cx, 3; thickness

        ; outer board
        mov ax, ds:[tetrisPlaygroundStartX]  ; start x
        sub ax, cx
        push ax
        mov ax, ds:[tetrisPlaygroundStartY]  ; start y
        sub ax, cx
        push ax

        mov bx, ds:[tetrisPlaygroundUnitSize]  ; end x
        mov ax, 10
        mul bx
        add ax, ds:[tetrisPlaygroundStartX]
        add ax, cx
        push ax

        mov bx, ds:[tetrisPlaygroundUnitSize]  ; end y
        mov ax, 20
        mul bx
        add ax, ds:[tetrisPlaygroundStartY]
        add ax, cx
        push ax

        mov ax, 0Fh  ; color
        push ax
        call DrawRect

        dec cx

        ; inner board
        mov ax, ds:[tetrisPlaygroundStartX]  ; start x
        sub ax, cx
        push ax
        mov ax, ds:[tetrisPlaygroundStartY]  ; start y
        sub ax, cx
        push ax

        mov bx, ds:[tetrisPlaygroundUnitSize]  ; end x
        mov ax, 10
        mul bx
        add ax, ds:[tetrisPlaygroundStartX]
        add ax, cx
        push ax

        mov bx, ds:[tetrisPlaygroundUnitSize]  ; end y
        mov ax, 20
        mul bx
        add ax, ds:[tetrisPlaygroundStartY]
        add ax, cx
        push ax

        mov ax, 0  ; color
        push ax
        call DrawRect


        mov cx, 20
        sub bx, bx
@y1:
        push cx
        push bx

        ; di: offset in playground
        mov ax, 10; ax = 10
        mul bx; result = ax * bx
        mov di, ax; offset = result

        mov cx, 10
        sub bx, bx; count = 0
@x1:
        push cx
        push bx

        call RenderTetrisPlaygroundUnit

        pop bx
        pop cx
        inc bx
        loop @x1

        pop bx
        pop cx
        inc bx
        loop @y1


        popf
        popa

        ret

RenderTetrisPlayground ENDP

; dont call this
RenderTetrisPlaygroundUnit PROC
        ; because need word, di += count * 2
        mov ax, 2
        mul bx
        add di, ax

        ; get unit
        mov cx, ds:[di + tetrisPlayground]
        ; if is zero, ignore
        test cx, cx
        jz @finish1

        ; get stack
        mov bp, sp

        ; tetrisPlaygroundStartX + bx * tetrisPlaygroundUnitSize
        ; start x
        mov ax, ss:[bp + 2]
        mov bx, ds:[tetrisPlaygroundUnitSize]
        mul bx
        add ax, ds:[tetrisPlaygroundStartX]
        test ch, 00000100b; pos 2 is left
        jne @left_no_need_change
        inc ax
@left_no_need_change:
        push ax

        ; start y
        mov ax, ss:[bp + 4 + 2]
        mov bx, ds:[tetrisPlaygroundUnitSize]
        mul bx
        add ax, ds:[tetrisPlaygroundStartY]
        test ch, 00000001b; pos 0 is up
        jne @up_no_need_change
        inc ax
@up_no_need_change:
        push ax

        ; end x
        mov ax, ss:[bp + 2]
        mov bx, ds:[tetrisPlaygroundUnitSize]
        mul bx
        add ax, ds:[tetrisPlaygroundStartX]
        add ax, ds:[tetrisPlaygroundUnitSize]
        test ch, 00001000b; pos 3 is right
        jne @right_no_need_change
        dec ax
@right_no_need_change:
        push ax
        
        ; end y
        mov ax, ss:[bp + 4 + 2]
        mov bx, ds:[tetrisPlaygroundUnitSize]
        mul bx
        add ax, ds:[tetrisPlaygroundStartY]
        add ax, ds:[tetrisPlaygroundUnitSize]
        test ch, 00000010b; pos 1 is down
        jne @down_no_need_change
        dec ax
@down_no_need_change:
        push ax

        push cx
        call DrawRect

@finish1:
        ret
RenderTetrisPlaygroundUnit ENDP

END main
