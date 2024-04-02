.model small
.386
.stack 100h

.data
    ground db "-------------------------------------------------------$"
    xPos BYTE 10
    yPos BYTE 15

    inputChar BYTE ?

.code
main PROC
    mov ax, @data           
    mov ds, ax

    call ClearScreen

    mov dl, 0               ; x
    mov dh, 24              ; y
    call Gotoxy             ; using x and y (dl and dh) jump to gotoxy
    lea dx, ground          ; load ground into dx
    call WriteString        ; print ground

    call DrawPlayer

    gameLoop:
        gravity:            ; gravity logic xD
            cmp yPos, 22
            jg onGround     ; jump to onGround if alr on ground
            call UpdatePlayer   
            inc yPos
            call DrawPlayer
            mov eax, 50000  
            call Delay
            jmp gravity
            
        onGround:
            call ReadChar
            mov inputChar, al

            cmp inputChar, 'x' ; x for exit
            je exitGame

            cmp inputChar, 'w' ; w for jump yipee
            je moveUp

            jmp gameLoop

    moveUp:
        mov ecx, 4
        jumpLoop:
            call UpdatePlayer
            dec yPos
            call DrawPlayer
            mov eax, 50000 
            call Delay 
        loop jumpLoop
        jmp gameLoop
    
    exitGame:           ; exit program
        mov ah, 4Ch             
        int 21h     
main ENDP

Delay PROC
delay_loop:
    dec eax             ; uses eax as loop ctr
    jnz delay_loop  
    ret 
Delay ENDP


WriteString PROC        ; print string proc
    mov ah, 09h             
    int 21h                 
    ret
WriteString ENDP

ReadChar PROC
    mov ah, 01h         ; check for key press w/o waiting
    int 16h             
    jz @F               ; jmp to end if z = set (no key pressed)
    mov ah, 00h         
    int 16h             
@@:
    ret
ReadChar ENDP

DrawPlayer PROC         ; draw player proc
    mov dl, xPos
    mov dh, yPos
    call Gotoxy
    mov al, '@'
    call WriteChar
    ret
DrawPlayer ENDP

UpdatePlayer PROC       ; draw blank player proc
    mov dl, xPos
    mov dh, yPos
    call Gotoxy
    mov al, ' '
    call WriteChar
    ret
UpdatePlayer ENDP

WriteChar PROC
    mov ah, 0Eh     
    mov bh, 0        
    mov bl, 07h         
    int 10h          
    ret
WriteChar ENDP

Gotoxy PROC
    mov ah, 02h             
    int 10h                 
    ret
Gotoxy ENDP

ClearScreen PROC
    mov ah, 00h             
    mov al, 03h             
    int 10h                 
    ret
ClearScreen ENDP

.data
    userInput db 20,?,10,13, '$'  ; buffer to store user input
.code

END main
