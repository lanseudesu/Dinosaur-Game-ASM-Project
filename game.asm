.model small
.386
.stack 1024
.data
    DinoXY dw 960 dup (?)    
    BoulderXY db 960 dup (?)
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
    lea si, DinoXY
    mov word ptr [si], 010Ah 
    mov dx, word ptr [si]
    call drawDino
    lea si, BoulderXY
    mov word ptr [si], 0f0ah
    mov dx, word ptr [si]
    call drawBoulder
    call slide

    infloop:
        gravity:
            cmp dl, 0Ah
            jg onGround
            call drawDino
            inc dl
            call drawDino
            jmp gravity
    
        onGround:
            call ReadChar
            cmp al, 'w'
            je moveUp
            jmp infloop

        moveUp:
            mov ecx, 4
            jumpLoop:
                call drawDino
                dec dl
                call drawDino
                call delay
            loop jumpLoop
            jmp infloop

main ENDP

Delay PROC
        push cx            
        mov ecx, 65500  
        delay_loop:
            nop             
            loop delay_loop
        pop cx
        ret
Delay ENDP

ReadChar PROC
    mov ah, 09H         ; check for key press w/o waiting
    int 16h            
    jz @F               ; jmp to end if z = set (no key pressed)
    mov ah, 00h         
    int 16h 
@@:    
    ret
ReadChar ENDP

drawDino PROC
    call calcXY
    call drawImg
    ret
drawDino ENDP

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
        lea si, BitmapTest  
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
        inc bl
        dec cl 
        jnz y_axis
        pop cx
        ret
drawImg ENDP

drawBoulder PROC
    call calcXY
    call drawImg
    ret
drawBoulder ENDP

Slide PROC
    slideloop:
        cmp dl, 00h
        jle slidestop
        call drawBoulder
        dec dl
        call drawBoulder
        call Delay
       jmp slideloop
    slidestop:
        ret
Slide ENDP

BitmapTest:             
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

END main