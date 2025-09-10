.286

.MODEL small

.DATA
    gMemSeg dw 0A000h

public FillRect

.CODE
; draw a rect
; stack 14h
; args: 8:[start x] 6:[start y] 4:[end x] 2:[end y] 0:[color]
; no returns
FillRect PROC
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
FillRect ENDP

END
