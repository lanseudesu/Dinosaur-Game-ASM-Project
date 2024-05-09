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
    
    lea si, BoulderXY
    mov word ptr [si], 0f0bh 
    mov dx, word ptr [si]
    call drawBoulder

    lea si, DinoXY
    mov word ptr [si], 010bh    
    mov dx, word ptr [si]
    call drawDino 

    infloop:
        mov dx, 0f0bh
        call drawBoulder
        l1:
            cmp dh, 00h
            jle slideStop
            call ReadCharWithTimeout
            cmp al, 'w' 
            push dx
            je moveUp
            call drawBoulder
            dec dh
            call drawBoulder
            call Delay
            jmp l1
        slideStop:
            call drawBoulder
            jmp infloop
main ENDP

moveUp PROC
    mov dx, 010bh
    mov ecx, 4
    jumpLoop:
        call drawDino
        dec dl
        call drawDino
        call delay
    loop jumpLoop
    mov ecx, 4
    fallLoop:
        call drawDino
        inc dl
        call drawDino
        call Delay
    loop fallLoop
    pop dx
    jmp l1
moveUp ENDP

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
    call drawImg
    ret
drawDino ENDP

ReadCharWithTimeout PROC
    mov ah, 1   
    int 16h
    jz NoKey        
    mov ah, 0       
    int 16h
    ret
    NoKey:
    ret
ReadCharWithTimeout ENDP

drawBoulder PROC
    call calcXY
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

;Drawing of the rock (temporary) 
BitmapTest:             
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