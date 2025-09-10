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
        ;       |||_______ m flag
        tetrisPlayground dw 200 dup(0)
        dw 10 dup(00FFh)

.CODE

extrn GraphicModeOn:near
extrn GraphicModeOff:near

main PROC                 
        call InitProgram

        mov dx, OFFSET msg
        mov ah, 9
        int 21h

;         mov cx, 8
;         sub bx, bx
; @b:
;         mov ax, 2
;         mul bx
;         mov si, ax
;         sub ax, ax
;         mov ah, 00010000b
;         mov al, 65
;         mov ds:[tetrisPlayground + si], ax

;         inc bx
;         loop @b
        mov ah, 00010000b
        mov al, 101
        mov ds:[tetrisPlayground + si + 8], ax
        mov ah, 00010000b
        mov al, 101
        mov ds:[tetrisPlayground + si + 10], ax
        mov ah, 00010000b
        mov al, 101
        mov ds:[tetrisPlayground + si + 12], ax
        mov ah, 00010000b
        mov al, 101
        mov ds:[tetrisPlayground + si + 12 + 20], ax

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

; render tetris playground
; no args
; no returns
; tag: 0002
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
        call FillRect

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
        call FillRect


        mov cx, 20
        sub bx, bx

        mov cx, 200
        sub si, si; column
        sub di, di; row
        sub bx, bx; unit count
@render_0002:
        push cx
        push si
        push di
        push bx

        jmp @RenderSingleUnit_0002
@finish_this_unit_0002:
        pop bx
        pop di
        pop si
        pop cx

        inc bx
        inc si

        cmp si, 10
        jl @column_add_0002

        inc di
        sub si, si
@column_add_0002:
        loop @render_0002

        jmp @finish_0002

@RenderSingleUnit_0002:
                ; because need word, di += count * 2
        mov ax, 2
        mul bx

        push di
        mov di, ax
        ; get unit
        mov cx, ds:[di + tetrisPlayground]
        pop di

        ; if is zero, ignore
        test cx, cx
        jz @finish_this_unit_0002

        ; get stack
        mov bp, sp

        ; tetrisPlaygroundStartX + bx * tetrisPlaygroundUnitSize
        ; start x
        mov ax, si
        mov bx, ds:[tetrisPlaygroundUnitSize]
        mul bx
        add ax, ds:[tetrisPlaygroundStartX]
        test ch, 00000100b; pos 2 is left
        jnz @left_no_need_change_0002
        inc ax
@left_no_need_change_0002:
        push ax

        ; start y
        mov ax, di
        mov bx, ds:[tetrisPlaygroundUnitSize]
        mul bx
        add ax, ds:[tetrisPlaygroundStartY]
        test ch, 00000001b; pos 0 is up
        jnz @up_no_need_change_0002
        inc ax
@up_no_need_change_0002:
        push ax

        ; end x
        mov ax, si
        mov bx, ds:[tetrisPlaygroundUnitSize]
        mul bx
        add ax, ds:[tetrisPlaygroundStartX]
        add ax, ds:[tetrisPlaygroundUnitSize]
        test ch, 00001000b; pos 3 is right
        jnz @right_no_need_change_0002
        dec ax
@right_no_need_change_0002:
        push ax
        
        ; end y
        mov ax, di
        mov bx, ds:[tetrisPlaygroundUnitSize]
        mul bx
        add ax, ds:[tetrisPlaygroundStartY]
        add ax, ds:[tetrisPlaygroundUnitSize]
        test ch, 00000010b; pos 1 is down
        jnz @down_no_need_change_0002
        dec ax
@down_no_need_change_0002:
        push ax

        push cx
        call FillRect

        jmp @finish_this_unit_0002

@finish_0002:
        popf
        popa

        ret

RenderTetrisPlayground ENDP

; update tetris playground
; no args
; no returns
; tag: 0003
UpdateTetrisPlayground PROC
        pusha
        pushf

        mov cx, 20
        sub bx, bx

        mov cx, 200
        sub si, si; column
        sub di, di; row
@update_0003:
        push cx
        push si
        push di

        sub cx, 2

        mov ax, 2
        mul cx
        mov bp, ax
        mov bx, ds:[tetrisPlayground + bp]; cx: current unit

        test bh, 00010000b; this is moving
        jnz @is_moving_0003
        jmp @finish_this_unit_0003

@is_moving_0003:
        mov dx, ds:[tetrisPlayground + bp + 20]; dx: row+1 unit

        cmp dx, 0; next is empty
        je @move_to_next_0003
        ; next it not empty

        and bh, 11101111b
        mov ds:[tetrisPlayground + bp], bx

        jmp @finish_this_unit_0003

@move_to_next_0003:
        
        mov ds:[tetrisPlayground + bp + 20], bx
        sub ax, ax
        mov ds:[tetrisPlayground + bp], ax

@finish_this_unit_0003:
        pop di
        pop si
        pop cx

        inc si

        cmp si, 10
        jl @column_add_0003

        inc di
        sub si, si
@column_add_0003:
        loop @update_0003

        jmp @finish_0003

@finish_0003:
        popf
        popa

        ret

UpdateTetrisPlayground ENDP

END main
