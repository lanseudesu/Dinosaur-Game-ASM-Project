.model small
.386
.stack 1024
.data
DinoX db 0
DinoY db 0    
.code

main PROC
    mov ax, @code       
    mov ds, ax
    mov ah, 0           
    mov al, 13h        
    int 10h             

   
    mov ax, 0A000h      
    mov es, ax
    xor di, di          
    mov cx, 320*170     

    mov al, 0Bh         
    rep stosb           
    
    mov cx, 320*30     

    mov al, 02h         
    rep stosb   
    
    mov DinoX, 0
    mov DinoY, 23
    call ShowDino

    infloop:
    gravity:
        cmp DinoY, 23
        jg onGround
        call ShowDino
        inc DinoY
        call ShowDino
        call Delay
        jmp gravity

    onGround:
        call ReadChar

        cmp al, 'w'
        je moveUp
        
        jmp infloop     ; cont loop if w is not pressed

moveUp:
    mov ecx, 4
    jumpLoop:
        call ShowDino
        dec DinoY
        call ShowDino
        call Delay
    loop jumpLoop
    jmp infloop


main ENDP

Delay PROC
    push cx             ; save original value of cx
    mov ecx, 65000   
    delay_loop:
        nop             ; no operation
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

ShowDino PROC
    mov dh, DinoX      
    mov dl, DinoY      
    call ShowSprite
    ret
ShowDino ENDP


ShowSprite PROC
    mov ax, @code      
    mov ds, ax
    push cx
    
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
    
    mov si, offset BitmapTest    
    mov cl, 15         ; height        

DrawBitmap_Yagain:              
    push di
    mov ch, 15                  ; width

DrawBitmap_Xagain:              
    mov al, [SI]
    xor al, byte ptr es:[di]   
    mov byte ptr es:[di], al   
    inc si
    inc di
    dec ch
    jnz DrawBitmap_Xagain       
    pop di
    add di, 320                
    inc bl
    dec cl
    jnz DrawBitmap_Yagain       
    pop cx
    ret 
ShowSprite ENDP

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
