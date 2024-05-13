;todo: random interval for obstacles spawning
; - mainmenu, points, gameover screen, leaderboard, pause

.model small
.386
.stack 1024
.data
    DinoXY dw 960 dup (?)    
    curDinoXY dw 0
    curBoulderXY dw 0
    isJumpFall db 0
    strGameOver db 'haha loser$'
.code

main PROC
    mov ax, @code       
    mov ds, ax
    
    mov ax, 0013h
    int 10h

    mov ax, 0A000h      
    mov es, ax
    xor di, di         
    mov cx, 320*200     

    mov al, 0Bh         
    rep stosb   

    mov ax, @data
    mov ds, ax 

    mov curBoulderXY, 0
    mov curDinoXY, 0
    mov isJumpFall, 0

    lea si, DinoXY
    mov word ptr [si], 010bh    
    mov dx, word ptr [si]
    call drawDino 
    mov curDinoXY, dx

    infloop:
        mov dx, 160bh
        call drawBoulder
        l1:
            cmp dh, 00h
            jle slideStop
            call ReadCharWithTimeout
            cmp al, 'w' 
            je moveUp
            call drawBoulder
            dec dh
            call drawBoulder
            call Delay
            call checkCollision
            jmp l1
        slideStop:
            call drawBoulder
            jmp infloop
    
    moveUp:
        mov curBoulderXY, dx
        mov dx, 010bh
        mov ecx, 4
        mov isJumpFall, 1
        jumpLoop:
            call drawDino
            dec dl
            call drawDino
            call delayy
            mov curDinoXY, dx
            mov dx, curBoulderXY
            cmp dh, 00h 
            jle slideStopp
            l3:
            call drawBoulder
            dec dh
            call drawBoulder
            call delayy
            call checkCollision
            mov curBoulderXY, dx
            mov dx, curDinoXY
        loop jumpLoop
        mov ecx, 4
        mov isJumpFall, 0
        fallLoop:
            call drawDino
            inc dl
            call drawDino
            call Delayy
            mov curDinoXY, dx
            mov dx, curBoulderXY
            cmp dh, 00h 
            jle slideStopp
            l4:
            call drawBoulder
            dec dh
            call drawBoulder
            call delayy
            call checkCollision
            mov curBoulderXY, dx
            mov dx, curDinoXY
        loop fallLoop
        mov dx, curBoulderXY
        jmp l1

        slideStopp:
            call drawBoulder
            mov dx, 160bh
            call drawBoulder
            mov al, isJumpFall
            cmp al, 1
            je l3
            jmp l4
            
main ENDP

checkCollision PROC
    push bx
    mov bx, curDinoXY
    cmp bl, dl
    jne noCollision
    cmp bh, dh
    jne noCollision
    pop bx
    jmp gameOver

    noCollision:
        pop bx
        ret

    gameOver:
        mov ah, 4CH
        int 21h
checkCollision ENDP

delayy PROC
    push cx            
    mov ecx, 35000  
    delay_loop:
        nop             
        loop delay_loop
    pop cx
    ret
Delayy ENDP

Delay PROC
    push cx            
    mov ecx, 65500  
    delay1:
        nop             
        loop delay1
    mov ecx, 15000
    delay2:
        nop
        loop delay2
    pop cx
    ret
Delay ENDP

ReadChar PROC
    mov ah, 09H        
    int 16h            
    jz @F               
    mov ah, 00h         
    int 16h 
@@:    
    ret
ReadChar ENDP

drawDino PROC
    call calcXY
    lea si, dino
    call drawImg
    ret
drawDino ENDP

ReadCharWithTimeout PROC
    mov ah, 1   
    int 16h
    jz noKey        
    mov ah, 0       
    int 16h
    ret
    noKey:
    ret
ReadCharWithTimeout ENDP

drawBoulder PROC
    call calcXY
    lea si, boulder
    call drawImg
    ret
drawBoulder ENDP

calcXY PROC 
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
    ret
calcXY ENDP

drawImg PROC
    push cx 
    mov ax, 0A000h  
    mov es, ax     
    mov cl, 15
    y_axis:
        push di
        mov ch, 15
    x_axis:
        mov al, [SI]
        xor al, byte ptr es:[di]   
        mov byte ptr es:[di], al  
        inc si
        inc di
        dec ch
        jnz x_axis
    pop di
    add di, 320
    dec cl 
    jnz y_axis
    pop cx
    ret
drawImg ENDP

dino:             
    DB 00h,00h,00h,0Bh,0Bh,0Bh,0Bh,0BH,0BH,0BH,0BH,0BH,0BH,00h,00h   
    DB 00h,0BH,0BH,09H,09H,09H,09H,09H,09H,09H,09H,01H,01H,0BH,00h    
    DB 0BH,01H,0BH,09H,09H,09H,09H,09H,09H,09H,09H,09H,01H,01H,0BH    
    DB 0BH,01H,0BH,09H,04h,0BH,09H,09H,09H,09H,09H,09H,09H,01H,0BH   
    DB 00h,0BH,0BH,09H,04h,0BH,09H,09H,09H,09H,09H,09H,09H,01H,0BH    
    DB 0BH,01H,0BH,09H,09H,09H,09H,09H,09H,09H,0BH,09H,09H,0BH,0BH  
    DB 0BH,01H,0BH,09H,09H,09H,09H,09H,09H,09H,09H,09H,09H,01H,0BH   
    DB 00h,0BH,0BH,09H,09H,09H,09H,09H,09H,09H,09H,09H,09H,01H,0BH  
    DB 00h,00h,00h,0BH,09H,09H,09H,09H,09H,09H,09H,0BH,0BH,0BH,00h  
    DB 00h,00h,00h,0BH,09H,09H,09H,09H,09H,09H,09H,0BH,00h,00h,00h    
    DB 00h,0BH,0BH,0BH,09H,09H,09H,09H,09H,09H,09H,0BH,00h,00h,00h    
    DB 00h,0BH,09H,09H,09H,09H,09H,09H,09H,09H,09H,0BH,00h,00h,00h    
    DB 00h,0BH,0BH,09H,09H,09H,0BH,0BH,0BH,09H,09H,0BH,00h,00h,00h    
    DB 00h,00h,0BH,0BH,0BH,09H,0BH,00h,0BH,09H,0BH,00h,00h,00h,00h    
    DB 00h,00h,00h,00h,0BH,0BH,0BH,00h,0BH,0BH,0BH,00h,00h,00h,00h

boulder:
    DB 00h,00h,00h,0ch,0ch,0ch,0ch,00h,00h,00h,00h,00h,00h,00h,00h   
    DB 00h,00h,0ch,0ch,0ch,0ch,0ch,0ch,0ch,00h,00h,00h,00h,00h,00h    
    DB 00h,00h,0ch,0ch,00h,0ch,00h,0ch,0ch,0ch,00h,00h,00h,00h,00h    
    DB 00h,0ch,0ch,0ch,0ch,0ch,00h,00h,0ch,0ch,00h,00h,00h,00h,00h   
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
    
END main