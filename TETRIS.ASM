.286

.MODEL small

.STACK 100h

.DATA
        msg db 'Hello world!', 13, 10, '$'

.CODE

main PROC                 
        mov ax, @data
        mov ds, ax

read:
        mov ah, 01h
        int 16h

        ; input nothing
        jz read

        mov ah, 00h
        int 16h

        cmp al, 97
        ; input 'a'
        je bye

        mov dl, 0DBh
        mov ah, 02h
        int 21h

        loop read

bye:
        mov dx, OFFSET msg
        mov ah, 9
        int 21h

        mov al, 13h
        int 10h

        mov ah, 4ch
        int 21h
main ENDP
END
