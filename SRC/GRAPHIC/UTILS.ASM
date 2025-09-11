.286

.MODEL small

.DATA
        gMemSeg dw 0A000h

public FillRect
public DrawRect

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
        add bp, 14h


        ; calc height of rect
        mov cx, ss:[bp + 2]; end_y
        sub cx, ss:[bp + 6]; end_y - start_y
        sub bx, bx  ; count = 0
@y0:     
        push cx
        push bx

        mov ax, 320; ax = 320
        add bx, ss:[bp + 6]; bx = count + start_y
        mul bx; result = ax * bx
        mov di, ax; offset = result

        ; calc width of rect
        mov cx, ss:[bp + 4]; end_x
        sub cx, ss:[bp + 8]; end_x - start_x
        sub bx, bx  ; count = 0
@x0:
        push bx

        mov ax, ss:[bp]; color
        add bx, ss:[bp + 8]; bx = count + start_x

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

; draw a rect
; args: 10:[start x] 8:[start y] 6:[end x] 4:[end y] 2:[thickness] 0:[color]
; no returns
DrawRect PROC
        ; ret_addr + 2h
        pusha; + 10h
        pushf; + 2h

        mov bp, sp
        add bp, 14h

        mov cx, ss:[bp + 2]
        sub bx, bx; thickness offset
        mov si, ss:[bp]; color
@for_each_thickness:
        ; up
        mov dx, ss:[bp + 8]; start y == end y
        add dx, bx; add offset
        
        mov ax, ss:[bp + 10]
        add ax, bx; add offset
        push ax; start x

        push dx; start y

        mov ax, ss:[bp + 6]  ; end x
        sub ax, bx; add offset
        push ax

        inc dx
        push dx; end y

        push si; color
        call FillRect

        ; down
        mov dx, ss:[bp + 4]; start y == end y
        sub dx, bx; add offset
        
        mov ax, ss:[bp + 10]
        add ax, bx; add offset
        push ax; start x

        push dx; start y

        mov ax, ss:[bp + 6]  ; end x
        inc ax
        sub ax, bx; add offset
        push ax

        inc dx
        push dx; end y

        push si; color
        call FillRect

        ; left
        mov dx, ss:[bp + 10]; start x == end x
        add dx, bx; add offset

        push dx; start x

        mov ax, ss:[bp + 8]  ; start y
        add ax, bx; add offset
        push ax; start y

        inc dx
        push dx; end x

        mov ax, ss:[bp + 4]  ; end y
        sub ax, bx; add offset
        push ax; end y

        push si; color
        call FillRect

        ; right
        mov dx, ss:[bp + 6]; start x == end x
        sub dx, bx; add offset

        push dx; start x

        mov ax, ss:[bp + 8]  ; start y
        add ax, bx; add offset
        push ax; start y

        inc dx
        push dx; end x

        mov ax, ss:[bp + 4]  ; end y
        sub ax, bx; add offset
        push ax; end y

        push si; color
        call FillRect


        inc bx
        loop @for_each_thickness

        popf
        popa

        ret 12
DrawRect ENDP

END
