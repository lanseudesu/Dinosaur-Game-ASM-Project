;todo: random interval for obstacles spawning
; - mainmenu, points, gameover screen, leaderboard, pause

.model small
.386
.stack 1024
.data
    DinoXY dw 960 dup (?)    ; dh = x, dl = y
    curDinoXY dw 0           ; cur = current
    curBoulderXY dw 0
    isJumpFall db 0          ; is dino jumping or falling flag
.code

main PROC
    mov ax, @code       
    mov ds, ax
    ; screen initialization
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
    ; draw default dino pos
    mov dx, 010bh
    call drawDino 
    mov curDinoXY, dx

    infloop:
        mov dx, 160bh
        call drawBoulder
        l1:
            cmp dh, 00h
            jle slideStop
            call ReadCharWithTimeout ; waits for user input 
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
    ; dino jump while still continuing obstacle slide
    moveUp: 
        mov curBoulderXY, dx ; preserve current boulder pos
        mov dx, 010bh
        mov ecx, 4        ; height of jump
        mov isJumpFall, 1 ; set flag to 1 (jumping)
        jumpLoop:
            call drawDino
            dec dl
            call drawDino
            call delayy           ; faster delay to reduce lag
            mov curDinoXY, dx     ; preserve current dino pos
            mov dx, curBoulderXY 
            cmp dh, 00h 
            jle slideStopp        ; if obstacle reaches end then go back to starting pos
            l3: ; slide
            call drawBoulder
            dec dh
            call drawBoulder
            call delayy
            call checkCollision    
            mov curBoulderXY, dx
            mov dx, curDinoXY
        loop jumpLoop
        mov ecx, 4
        mov isJumpFall, 0  ; set flag to 0 (falling)
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
            mov al, isJumpFall ; check whether dino was jumping or falling when boulder reaches end
            cmp al, 1
            je l3  ; jumping
            jmp l4 ; falling
main ENDP

checkCollision PROC       
    push bx
    mov bx, curDinoXY
    cmp bl, dl          ; compare dino y to boulder y
    jne noCollision
    cmp bh, dh          ; compare dino x to boulder x
    jne noCollision
    pop bx
    jmp gameOver

    noCollision: 
        pop bx
        ret

    gameOver:
        call drawBoulder
        mov dx, 010bh  
        call drawDino
        mov al, 1       ; flag for dead dino sprite
        call drawDino   ; draw dead dino sprite
        mov dx, 0604h
        lea si, bigg
        call printLetter ; prints game over screen
        mov dx, 0704h
        lea si, biga
        call printLetter
        mov dx, 0804h
        lea si, bigm
        call printLetter
        mov dx, 0904h
        lea si, bige
        call printLetter
        mov dx, 0b04h
        lea si, bigo
        call printLetter
        mov dx, 0c04h
        lea si, bigv
        call printLetter
        mov dx, 0d04h
        lea si, bige
        call printLetter
        mov dx, 0e04h
        lea si, bigr
        call printLetter
        mov ah, 4CH
        int 21h
checkCollision ENDP

printLetter PROC
    call calcXY
    call drawImg
    ret
printLetter ENDP

delayy PROC
    push cx            
    mov ecx, 35000  ; delay speed
    delay_loop:
        nop         ; no operation    
        loop delay_loop
    pop cx
    ret
Delayy ENDP

Delay PROC
    push cx            
    mov ecx, 65500   ; delay speed
    delay1:
        nop             
        loop delay1
    mov ecx, 15000   ; delay speed
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
    cmp al, 1       ;check whether dino is dead or not
    je deadDino
    call calcXY
    lea si, dino    ; load sprite to SI
    call drawImg
    ret
    deadDino:
    call calcXY
    lea si, dead
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
    lea si, boulder ; load sprite to SI
    call drawImg
    ret
drawBoulder ENDP

calcXY PROC  ; calculate x and y pos of image
    mov ax, @code
    mov ds, ax      
    push dx
    mov ax, 15      ; sprite size by pixel
    mul dh
    mov di, ax
    mov ax, 15*320 ; sprite size * screen size
    mov bx, 0
    add bl, dl
    mul bx 
    add di, ax     ; placed all the calculated pos into DI
    pop dx 
    ret
calcXY ENDP

drawImg PROC    
    push cx 
    mov ax, 0A000h  ; segment address of video memory 
    mov es, ax      ; moving to es allows pixel manipulation 
    mov cl, 15  ; height
    y_axis:
        push di
        mov ch, 15 ; width
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

; sprite bitmaps:
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

dead:             
    DB 00h,00h,00h,0Bh,0Bh,0Bh,0Bh,0BH,0BH,0BH,0BH,0BH,0BH,00h,00h   
    DB 00h,0BH,0BH,09H,09H,09H,09H,09H,09H,09H,09H,01H,01H,0BH,00h    
    DB 0BH,01H,0BH,09H,09H,09H,09H,09H,09H,09H,09H,09H,01H,01H,0BH    
    DB 0BH,01H,0BH,09H,0Bh,09H,0BH,09H,09H,09H,09H,09H,09H,01H,0BH   
    DB 00h,0BH,0BH,09H,09h,0BH,09H,09H,09H,09H,09H,09H,09H,01H,0BH    
    DB 0BH,01H,0BH,09H,0BH,09H,0BH,09H,09H,09H,0BH,09H,09H,0BH,0BH  
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

bigg:
    DB 00h,00h,00h,00h,00h,0bh,0bh,0bh,0bh,0bh,0bh,00h,00h,00h,00h   
    DB 00h,00h,00h,00h,0bh,0bh,0bh,0bh,00h,0bh,0bh,0bh,00h,00h,00h    
    DB 00h,00h,00h,0bh,0bh,0bh,0bh,00h,00h,0bh,0bh,0bh,0bh,00h,00h    
    DB 00h,00h,0bh,0bh,0bh,0bh,00h,00h,00h,00h,0bh,0bh,0bh,00h,00h   
    DB 00h,00h,0bh,0bh,0bh,0bh,00h,00h,00h,00h,00h,0bh,0bh,00h,00h    
    DB 00h,00h,0bh,0bh,0bh,0bh,00h,00h,00h,00h,00h,00h,00h,00h,00h  
    DB 00h,00h,0bh,0bh,0bh,0bh,00h,00h,00h,00h,00h,00h,00h,00h,00h   
    DB 00h,00h,0bh,0bh,0bh,0bh,00h,00h,00h,00h,00h,00h,00h,00h,00h  
    DB 00h,00h,0bh,0bh,0bh,0bh,00h,0bh,0bh,0bh,0bh,0bh,0bh,00h,00h  
    DB 00h,00h,0bh,0bh,0bh,0bh,00h,0bh,0bh,0bh,0bh,0bh,0bh,00h,00h    
    DB 00h,00h,0bh,0bh,0bh,0bh,00h,00h,00h,0bh,0bh,0bh,0bh,00h,00h   
    DB 00h,00h,0bh,0bh,0bh,0bh,00h,00h,00h,0bh,0bh,0bh,0bh,00h,00h    
    DB 00h,00h,00h,0bh,0bh,0bh,0bh,00h,00h,0bh,0bh,0bh,0bh,00h,00h    
    DB 00h,00h,00h,00h,0bh,0bh,0bh,0bh,00h,0bh,0bh,0bh,0bh,00h,00h
    DB 00h,00h,00h,00h,00h,0bh,0bh,0bh,0bh,0bh,00h,0bh,0bh,00h,00h
biga:
    DB 00h,00h,00h,00h,00h,00h,0bh,0bh,0bh,0bh,0bh,00h,00h,00h,00h   
    DB 00h,00h,00h,00h,00h,0bh,0bh,0bh,00h,0bh,0bh,0bh,00h,00h,00h    
    DB 00h,00h,00h,00h,0bh,0bh,0bh,00h,00h,0bh,0bh,0bh,0bh,00h,00h    
    DB 00h,00h,00h,0bh,0bh,0bh,00h,00h,00h,0bh,0bh,0bh,0bh,00h,00h   
    DB 00h,00h,0bh,0bh,0bh,0bh,00h,00h,00h,0bh,0bh,0bh,0bh,00h,00h    
    DB 00h,00h,0bh,0bh,0bh,0bh,00h,00h,00h,0bh,0bh,0bh,0bh,00h,00h  
    DB 00h,00h,0bh,0bh,0bh,0bh,00h,00h,0bh,0bh,0bh,0bh,0bh,00h,00h   
    DB 00h,00h,0bh,0bh,0bh,0bh,00h,0bh,0bh,0bh,0bh,0bh,0bh,00h,00h  
    DB 00h,00h,0bh,0bh,0bh,0bh,0bh,0bh,00h,0bh,0bh,0bh,0bh,00h,00h  
    DB 00h,00h,0bh,0bh,0bh,0bh,0bh,00h,00h,0bh,0bh,0bh,0bh,00h,00h    
    DB 00h,00h,0bh,0bh,0bh,0bh,00h,00h,00h,0bh,0bh,0bh,0bh,00h,00h   
    DB 00h,00h,0bh,0bh,0bh,0bh,00h,00h,00h,0bh,0bh,0bh,0bh,00h,00h    
    DB 00h,00h,0bh,0bh,0bh,0bh,00h,00h,00h,0bh,0bh,0bh,0bh,00h,00h    
    DB 00h,00h,0bh,0bh,0bh,0bh,00h,00h,00h,0bh,0bh,0bh,0bh,00h,00h
    DB 00h,00h,0bh,0bh,0bh,0bh,00h,00h,00h,0bh,0bh,0bh,0bh,00h,00h 
bigm:
    DB 00h,0bh,0bh,00h,00h,00h,00h,00h,00h,00h,00h,00h,0bh,0bh,00h   
    DB 00h,0bh,0bh,0bh,00h,00h,00h,00h,00h,00h,00h,0bh,0bh,0bh,00h    
    DB 00h,0bh,0bh,0bh,0bh,00h,00h,00h,00h,00h,0bh,0bh,0bh,0bh,00h    
    DB 00h,0bh,0bh,0bh,0bh,0bh,00h,00h,00h,0bh,0bh,0bh,0bh,0bh,00h   
    DB 00h,0bh,0bh,0bh,0bh,0bh,0bh,00h,0bh,0bh,0bh,0bh,0bh,0bh,00h    
    DB 00h,0bh,0bh,0bh,0bh,00h,0bh,0bh,0bh,00h,0bh,0bh,0bh,0bh,00h  
    DB 00h,0bh,0bh,0bh,0bh,00h,00h,0bh,00h,00h,0bh,0bh,0bh,0bh,00h   
    DB 00h,0bh,0bh,0bh,0bh,00h,00h,00h,00h,00h,0bh,0bh,0bh,0bh,00h  
    DB 00h,0bh,0bh,0bh,0bh,00h,00h,00h,00h,00h,0bh,0bh,0bh,0bh,00h  
    DB 00h,0bh,0bh,0bh,0bh,00h,00h,00h,00h,00h,0bh,0bh,0bh,0bh,00h    
    DB 00h,0bh,0bh,0bh,0bh,00h,00h,00h,00h,00h,0bh,0bh,0bh,0bh,00h   
    DB 00h,0bh,0bh,0bh,0bh,00h,00h,00h,00h,00h,0bh,0bh,0bh,0bh,00h    
    DB 00h,0bh,0bh,0bh,0bh,00h,00h,00h,00h,00h,0bh,0bh,0bh,0bh,00h    
    DB 00h,0bh,0bh,0bh,0bh,00h,00h,00h,00h,00h,0bh,0bh,0bh,0bh,00h
    DB 00h,0bh,0bh,0bh,0bh,00h,00h,00h,00h,00h,0bh,0bh,0bh,0bh,00h 
bige:
    DB 00h,00h,0bh,0bh,0bh,0bh,0bh,0bh,0bh,0bh,0bh,0bh,00h,00h,00h   
    DB 00h,00h,0bh,0bh,0bh,0bh,00h,0bh,0bh,0bh,0bh,0bh,00h,00h,00h    
    DB 00h,00h,0bh,0bh,0bh,0bh,00h,0bh,0bh,0bh,0bh,0bh,00h,00h,00h    
    DB 00h,00h,0bh,0bh,0bh,0bh,00h,00h,0bh,0bh,0bh,0bh,00h,00h,00h   
    DB 00h,00h,0bh,0bh,0bh,0bh,00h,00h,00h,00h,00h,00h,00h,00h,00h    
    DB 00h,00h,0bh,0bh,0bh,0bh,00h,00h,00h,00h,00h,00h,00h,00h,00h  
    DB 00h,00h,0bh,0bh,0bh,0bh,0bh,0bh,0bh,0bh,00h,00h,00h,00h,00h   
    DB 00h,00h,0bh,0bh,0bh,0bh,0bh,0bh,0bh,0bh,00h,00h,00h,00h,00h  
    DB 00h,00h,0bh,0bh,0bh,0bh,00h,00h,00h,00h,00h,00h,00h,00h,00h  
    DB 00h,00h,0bh,0bh,0bh,0bh,00h,00h,00h,00h,00h,00h,00h,00h,00h    
    DB 00h,00h,0bh,0bh,0bh,0bh,00h,00h,0bh,0bh,0bh,0bh,00h,00h,00h    
    DB 00h,00h,0bh,0bh,0bh,0bh,00h,0bh,0bh,0bh,0bh,0bh,00h,00h,00h    
    DB 00h,00h,0bh,0bh,0bh,0bh,00h,0bh,0bh,0bh,0bh,0bh,00h,00h,00h    
    DB 00h,00h,0bh,0bh,0bh,0bh,00h,0bh,0bh,0bh,0bh,0bh,00h,00h,00h    
    DB 00h,00h,0bh,0bh,0bh,0bh,0bh,0bh,0bh,0bh,0bh,0bh,00h,00h,00h
bigo:
    DB 00h,00h,00h,00h,0bh,0bh,0bh,0bh,0bh,0bh,00h,00h,00h,00h,00h   
    DB 00h,00h,00h,0bh,0bh,0bh,00h,0bh,0bh,0bh,0bh,00h,00h,00h,00h    
    DB 00h,00h,0bh,0bh,0bh,0bh,00h,00h,0bh,0bh,0bh,0bh,00h,00h,00h    
    DB 00h,0bh,0bh,0bh,0bh,0bh,00h,00h,0bh,0bh,0bh,0bh,0bh,00h,00h   
    DB 00h,0bh,0bh,0bh,0bh,0bh,00h,00h,0bh,0bh,0bh,0bh,0bh,00h,00h    
    DB 00h,0bh,0bh,0bh,0bh,0bh,00h,00h,0bh,0bh,0bh,0bh,0bh,00h,00h  
    DB 00h,0bh,0bh,0bh,0bh,0bh,00h,00h,0bh,0bh,0bh,0bh,0bh,00h,00h   
    DB 00h,0bh,0bh,0bh,0bh,0bh,00h,00h,0bh,0bh,0bh,0bh,0bh,00h,00h  
    DB 00h,0bh,0bh,0bh,0bh,0bh,00h,00h,0bh,0bh,0bh,0bh,0bh,00h,00h  
    DB 00h,0bh,0bh,0bh,0bh,0bh,00h,00h,0bh,0bh,0bh,0bh,0bh,00h,00h    
    DB 00h,0bh,0bh,0bh,0bh,0bh,00h,00h,0bh,0bh,0bh,0bh,0bh,00h,00h   
    DB 00h,0bh,0bh,0bh,0bh,0bh,00h,00h,0bh,0bh,0bh,0bh,0bh,00h,00h    
    DB 00h,00h,0bh,0bh,0bh,0bh,00h,00h,0bh,0bh,0bh,0bh,00h,00h,00h    
    DB 00h,00h,00h,0bh,0bh,0bh,00h,0bh,0bh,0bh,0bh,00h,00h,00h,00h
    DB 00h,00h,00h,00h,0bh,0bh,0bh,0bh,0bh,0bh,00h,00h,00h,00h,00h   
bigv:
    DB 00h,0bh,0bh,0bh,0bh,0bh,00h,00h,0bh,0bh,0bh,0bh,0bh,00h,00h   
    DB 00h,0bh,0bh,0bh,0bh,0bh,00h,00h,0bh,0bh,0bh,0bh,0bh,00h,00h    
    DB 00h,0bh,0bh,0bh,0bh,0bh,00h,00h,0bh,0bh,0bh,0bh,0bh,00h,00h    
    DB 00h,0bh,0bh,0bh,0bh,0bh,00h,00h,0bh,0bh,0bh,0bh,0bh,00h,00h   
    DB 00h,0bh,0bh,0bh,0bh,0bh,00h,00h,0bh,0bh,0bh,0bh,0bh,00h,00h    
    DB 00h,0bh,0bh,0bh,0bh,0bh,00h,00h,0bh,0bh,0bh,0bh,0bh,00h,00h  
    DB 00h,0bh,0bh,0bh,0bh,0bh,00h,00h,0bh,0bh,0bh,0bh,0bh,00h,00h   
    DB 00h,0bh,0bh,0bh,0bh,0bh,00h,00h,0bh,0bh,0bh,0bh,0bh,00h,00h  
    DB 00h,0bh,0bh,0bh,0bh,0bh,00h,00h,0bh,0bh,0bh,0bh,0bh,00h,00h  
    DB 00h,0bh,0bh,0bh,0bh,0bh,00h,00h,0bh,0bh,0bh,0bh,0bh,00h,00h    
    DB 00h,0bh,0bh,0bh,0bh,0bh,00h,00h,0bh,0bh,0bh,0bh,0bh,00h,00h   
    DB 00h,0bh,0bh,0bh,0bh,0bh,00h,00h,0bh,0bh,0bh,0bh,00h,00h,00h    
    DB 00h,0bh,0bh,0bh,0bh,0bh,00h,00h,0bh,0bh,0bh,00h,00h,00h,00h    
    DB 00h,0bh,0bh,0bh,0bh,0bh,00h,0bh,0bh,0bh,00h,00h,00h,00h,00h
    DB 00h,00h,0bh,0bh,0bh,0bh,0bh,0bh,0bh,00h,00h,00h,00h,00h,00h
bigr:
    DB 00h,00h,0bh,0bh,0bh,0bh,0bh,0bh,0bh,0bh,0bh,00h,00h,00h,00h   
    DB 00h,00h,0bh,0bh,0bh,0bh,00h,0bh,0bh,0bh,0bh,0bh,00h,00h,00h    
    DB 00h,00h,0bh,0bh,0bh,0bh,00h,00h,0bh,0bh,0bh,0bh,0bh,00h,00h    
    DB 00h,00h,0bh,0bh,0bh,0bh,00h,00h,0bh,0bh,0bh,0bh,0bh,00h,00h   
    DB 00h,00h,0bh,0bh,0bh,0bh,00h,00h,0bh,0bh,0bh,0bh,0bh,00h,00h    
    DB 00h,00h,0bh,0bh,0bh,0bh,00h,00h,0bh,0bh,0bh,0bh,00h,00h,00h  
    DB 00h,00h,0bh,0bh,0bh,0bh,00h,0bh,0bh,0bh,0bh,00h,00h,00h,00h   
    DB 00h,00h,0bh,0bh,0bh,0bh,0bh,0bh,0bh,0bh,00h,00h,00h,00h,00h  
    DB 00h,00h,0bh,0bh,0bh,0bh,00h,0bh,0bh,0bh,0bh,00h,00h,00h,00h  
    DB 00h,00h,0bh,0bh,0bh,0bh,00h,00h,0bh,0bh,0bh,0bh,00h,00h,00h    
    DB 00h,00h,0bh,0bh,0bh,0bh,00h,00h,0bh,0bh,0bh,0bh,0bh,00h,00h   
    DB 00h,00h,0bh,0bh,0bh,0bh,00h,00h,0bh,0bh,0bh,0bh,0bh,00h,00h    
    DB 00h,00h,0bh,0bh,0bh,0bh,00h,00h,0bh,0bh,0bh,0bh,0bh,00h,00h    
    DB 00h,00h,0bh,0bh,0bh,0bh,00h,00h,0bh,0bh,0bh,0bh,0bh,00h,00h
    DB 00h,00h,0bh,0bh,0bh,0bh,00h,00h,0bh,0bh,0bh,0bh,0bh,00h,00h   




END main