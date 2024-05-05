.model small
.386
.stack 1024
.code

main PROC
    mov ah, 0          	
    mov al, 13h        	
    int 10h            	
	
    mov ax, 0A000h      
    mov es, ax
    xor di, di          
    mov cx, 320*200    

    mov al, 0Fh         
    rep stosb           

    mov dx, 400         
    mov dh, dl
    mov dl, 22          

    call ShowSprite    

    infloop:
    gravity:
        cmp dh, 50       
        jge onGround
        call ShowSprite   
        dec dh
        call ShowSprite
        call Delay
        jmp gravity

    onGround:
	
        call ReadChar

        cmp al, 'w'
        je moveUp
        
        jmp infloop     

moveUp:
    mov ecx, 4
    jumpLoop:
        call ShowSprite
        dec dl
        call ShowSprite
        call Delay
    loop jumpLoop
    jmp infloop

main ENDP


Delay PROC
    push cx             
    mov ecx, 50000   
    delay_loop:
        nop             
        loop delay_loop
    pop cx
    ret
Delay ENDP

ReadChar PROC
    mov ah, 01h         
    int 16h            
    jz @F               
    mov ah, 00h         
    int 16h 
@@:    
    ret
ReadChar ENDP


ShowSprite PROC
    push cx
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
    
    ; draw XOR sprite  
    mov si, offset BitmapTest    
    mov cl, 15                  ; height

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
    DB 00h,00h,00h,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,00h,00h    
    DB 00h,0Fh,0Fh,0Dh,0Dh,0Dh,0Dh,0Dh,0Dh,0Dh,0Dh,05h,05h,0Fh,00h   
    DB 0Fh,05h,0Fh,0Dh,0Dh,0Dh,0Dh,0Dh,0Dh,0Dh,0Dh,0Dh,05h,05h,0Fh    
    DB 0Fh,05h,0Fh,0Dh,00h,0Fh,0Dh,0Dh,0Dh,0Dh,0Dh,0Dh,0Dh,05h,0Fh    
    DB 00h,0Fh,0Fh,0Dh,00h,0Fh,0Dh,0Dh,0Dh,0Dh,0Dh,0Dh,0Dh,05h,0Fh   
    DB 0Fh,05h,0Fh,0Dh,0Dh,0Dh,0Dh,0Dh,0Dh,0Dh,0Fh,0Dh,0Dh,0Fh,0Fh    
    DB 0Fh,05h,0Fh,0Dh,0Dh,0Dh,0Dh,0Dh,0Dh,0Dh,0Dh,0Dh,0Dh,05h,0Fh    
    DB 00h,0Fh,0Fh,0Dh,0Dh,0Dh,0Dh,0Dh,0Dh,0Dh,0Dh,0Dh,0Dh,05h,0Fh    
    DB 00h,00h,00h,0Fh,0Dh,0Dh,0Dh,0Dh,0Dh,0Dh,0Dh,0Fh,0Fh,0Fh,00h    
    DB 00h,00h,00h,0Fh,0Dh,0Dh,0Dh,0Dh,0Dh,0Dh,0Dh,0Fh,00h,00h,00h    
    DB 00h,0Fh,0Fh,0Fh,0Dh,0Dh,0Dh,0Dh,0Dh,0Dh,0Dh,0Fh,00h,00h,00h    
    DB 00h,0Fh,0Dh,0Dh,0Dh,0Dh,0Dh,0Dh,0Dh,0Dh,0Dh,0Fh,00h,00h,00h    
    DB 00h,0Fh,0Fh,0Dh,0Dh,0Dh,0Fh,0Fh,0Fh,0Dh,0Dh,0Fh,00h,00h,00h   
    DB 00h,00h,0Fh,0Fh,0Fh,0Dh,0Fh,00h,0Fh,0Dh,0Fh,00h,00h,00h,00h    
    DB 00h,00h,00h,00h,0Fh,0Fh,0Fh,00h,0Fh,0Fh,0Fh,00h,00h,00h,00h    

END main