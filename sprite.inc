.code
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

drawBoulder PROC 
    call calcXY
    lea si, boulder ; load sprite to SI
    call drawImg
    ret
drawBoulder ENDP

calcXY PROC   ; calculate x and y pos of image
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
