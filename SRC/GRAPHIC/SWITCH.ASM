
.MODEL small

public GraphicModeOn
public GraphicModeOff

.CODE

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

END