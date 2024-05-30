.MODEL SMALL
.386
.STACK 1024
.DATA

DinoXY dw 960 dup (?)    ; dh = x, dl = y
curDinoXY dw 0           ; cur = current
curBoulderXY dw 0
isJumpFall db 0
prevBoulderXY dw 0

delayVarBig dd 65500
delayVarSmol dd 15000

randomNum dw 0
spriteTimer db 5
   

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX               ; Initialize data segment
    
    mov ax, 0013h
    int 10h

    mov ax, 0A000h      
    mov es, ax
    ; cyan bg color
    xor di, di         
    mov cx, 320*200     

    mov al, 0Bh         
    rep stosb   
    
    mov ax, @data
    mov ds, ax 
    ; var init
    mov curBoulderXY, 0
    mov curDinoXY, 0
    mov isJumpFall, 0



    mov dx, 160bh
    call drawBoulder

    call getRandomTimer

infloop:
    l1:
        Update:
            call drawBoulder
            dec dh
            call drawBoulder
        skipUpdate:
            cmp dh, 00h
            jle slideStop
            
            call Delay
            
            jmp l1

    slideStop:
        call drawBoulder
        
    skipDraw:
        call Delay
        call spriteTimerDec

        cmp spriteTimer, 0
        jg skipUpdate

        call spawnSprite
        jmp l1 

MAIN ENDP

spriteTimerDec PROC
    cmp spriteTimer, 0
    jle skipTimer
        
    call delay
    call delay
    dec spriteTimer

    skipTimer:
        ret

spriteTimerDec ENDP

spawnSprite PROC
    mov dx, 160bh
    call getRandomTimer
    call drawBoulder
    ret
spawnSprite ENDP

getRandomTimer proc
MOV AX, @DATA   
MOV DS, AX

    push dx
    push ax
    push bx

        mov ah, 00h
        int 1ah

        mov ax, dx
        mov dx, 00h
        mov bx, 05h
        div bx

        mov spriteTimer, dl

    pop bx
    pop ax
    pop dx
    ret
getRandomTimer endp


Delay PROC

MOV AX, @DATA
MOV DS, AX     
    push cx          

    mov ecx, delayVarBig  
    delay1:
        nop             
        loop delay1
    
    mov ecx, delayVarSmol
    delay2:
        nop
        loop delay2
    
    pop cx
    ret
Delay ENDP

drawBoulder PROC
mov al, 0
call calcXY
lea si, boulder ; load sprite to SI
mov bx, 0f0fh
call drawImg
ret
    RET
drawBoulder ENDP

delayy PROC
    push cx            
    mov ecx, 35000  
    delay_loop:
        nop             
        loop delay_loop
    pop cx
    ret
Delayy ENDP

drawImg PROC 
    push cx 
    mov ax, 0A000h  ; segment address of video memory 
    mov es, ax      ; moving to es allows pixel manipulation 
    mov cl, bl  ; height
    y_axis:
        push di
        mov ch, bh ; width
    x_axis:
        mov al, [SI] ; ds:si (segment:offset), move 1 pixel db into al
        xor al, byte ptr es:[di]   ; xor al with first di pos
        mov byte ptr es:[di], al  ; updates the pixel on the screen with xor result
        inc si
        inc di
        dec ch
        jnz x_axis  
    pop di
    add di, 320     ; move to new line of sprite
    dec cl 
    jnz y_axis
    pop cx
    ret
drawImg ENDP

boulder:
    DB 00h,00h,00h,0ch,0ch,0ch,0ch,00h,00h,00h,00h,00h,00h,00h,00h   
    DB 00h,00h,0ch,0ch,0ch,0ch,0ch,0ch,0ch,00h,00h,00h,00h,00h,00h    
    DB 00h,00h,0ch,0ch,0ch,0ch,0ch,0ch,0ch,0ch,00h,00h,00h,00h,00h    
    DB 00h,0ch,0ch,0ch,0ch,0ch,0ch,0ch,0ch,0ch,00h,00h,00h,00h,00h   
    DB 00h,0ch,0ch,0ch,0ch,0ch,0ch,0ch,0ch,0ch,0ch,00h,00h,00h,00h    
    DB 00h,0ch,0ch,0ch,0ch,0ch,0ch,0ch,0ch,0ch,0ch,00h,00h,00h,00h  
    DB 0ch,0ch,0ch,0ch,0ch,0ch,1eh,0ch,0ch,0ch,0ch,0ch,00h,00h,00h   
    DB 0ch,0ch,1fh,1eh,0ch,0ch,1fh,1eh,0ch,0ch,0ch,0ch,0ch,00h,00h  
    DB 0ch,1fh,1fh,1eh,1eh,0ch,1fh,1fh,1eh,0ch,0ch,0ch,1eh,0ch,0dh  
    DB 1dh,1fh,1fh,1fh,1eh,1eh,1fh,1fh,1eh,1eh,0ch,1eh,1eh,1eh,1dh    
    DB 1dh,1fh,1fh,1fh,1eh,1eh,1fh,1fh,1eh,1eh,1eh,1eh,1eh,1fh,1dh    
    DB 1dh,1fh,1fh,1fh,1fh,1fh,1fh,1fh,1fh,1eh,1eh,1eh,1fh,1fh,1dh    
    DB 1dh,1fh,1fh,1fh,1fh,1fh,1fh,1fh,1fh,1fh,1fh,1fh,1fh,1fh,1dh    
    DB 00h,1dh,1fh,1fh,1fh,1fh,1fh,1fh,1fh,1dh,1fh,1fh,1fh,1dh,00h    
    DB 00h,00h,1dh,1dh,1dh,1dh,1dh,1dh,1dh,1dh,1dh,1dh,1dh,00h,00h

    calcXY PROC   ; calculate x and y pos of image
    push ax
    mov ax, @code
    mov ds, ax
    push dx
    mov ax, 15
    mul dh
    mov di, ax
    mov ax, 15*320
    mov bx, 0
    add bl, dl
    mul bx 
    add di, ax
    pop dx 
    pop ax
    ret
calcXY ENDP



END MAIN