.MODEL SMALL
.386
.STACK 1024
.DATA

DinoXY dw 960 dup (?)    ; dh = x, dl = y
newboulderpos dw 0           ; cur = current
firstboulderpos dw 0
isJumpFall db 0
prevBoulderXY dw 0
curDinoXY dw 0

delayVarBig dd 65500
delayVarSmol dd 15000

randomNum dw 0
spriteTimer db 5

newSpriteLocator db 0
newSpriteFlag db 0
didfirstend db 0


.CODE
MAIN PROC
    mov ax, @code       
    mov ds, ax
    ; screen initialization
    mov ax, 0013h
    int 10h

    mov ax, @data
    mov ds, ax 

    mov ax, 0A000h      
    mov es, ax
    ; cyan bg color
    xor di, di         
    mov cx, 320*180     

    mov al, 0Bh         
    rep stosb   

    mov cx, 320*20     
    mov al, 02h         ; grass
    rep stosb  

    mov dx, 010bh
    call drawDino
    mov curDinoXY, dx
    infloop:
        mov newboulderpos, 0
        mov firstboulderpos, 0
        mov newSpriteFlag, 0
        mov newSpriteLocator, 0
        mov didfirstend, 0

        call getRandomNumber
        mov dx, 150bh
        call drawBoulder
        mov firstboulderpos, dx
        l1:
            jmp checkEnd
        l3:
            cmp newSpriteFlag, 1
            je l2
            mov dx, firstboulderpos
            cmp dh, newSpriteLocator
            je printnewsprite
        l2:
            call ReadCharWithTimeout
            cmp al, 'w' 
            je moveup
            call decPos
                                    call checkCollision
            jmp l1

    checkEnd:
        cmp didfirstend, 1
        je l4
        mov dx, firstboulderpos
        cmp dh, 00h
        jle slidestop1
        mov firstboulderpos, dx
        jmp l4

    slidestop1:
        call drawBoulder
        mov didfirstend, 1
        mov firstboulderpos, dx

    l4:
        cmp newSpriteFlag, 1
        jne l3
        mov dx, newboulderpos
        cmp dh, 00h
        je slidestop2
        mov newboulderpos, dx
        jmp l3

        slidestop2:
        call drawBoulder
        jmp infloop
    
    printnewsprite:
        mov firstboulderpos, dx
        mov dx, 140bh
        call drawBoulder
        mov newboulderpos, d
        mov newSpriteFlag, 1
        jmp l2
    
    moveup:
    mov dx, 010bh
    mov ecx, 4
    mov isJumpFall, 1
    jumpLoop:
        call drawDino   
        dec dl
        call drawDino
        call delayy
        mov curDinoXY, dx
        call checkEnd2
        l5:
                                call checkCollision
        mov dx, curDinoXY
        loop jumpLoop
        mov ecx, 4
        mov isJumpFall, 0
        fallLoop:
            call drawDino   
            inc dl
            call drawDino
            call delayy
            mov curDinoXY, dx
            call checkEnd2
                                call checkCollision
        l6:
        mov dx, curDinoXY
    loop fallLoop
    jmp l1

checkend2:
    cmp didfirstend, 1
    je checkNewSprite
    mov dx, firstboulderpos
    cmp dh, 00h
    je stopfirst
    cmp newspriteflag, 1
    je decboth
    cmp dh, newSpriteLocator
    je printNewSprite2
    jmp decfirst
    
    checkNewSprite:
    mov dx, newboulderpos
    cmp dh, 00h
    je restart
    jmp decnew

    restart:
        call drawBoulder
        mov newboulderpos, 0
        mov firstboulderpos, 0
        mov newSpriteFlag, 0
        mov newSpriteLocator, 0
        mov didfirstend, 0
        call getRandomNumber

        mov dx, 150bh
        call drawBoulder
        mov firstboulderpos, dx
        jmp isjumping

    stopfirst:
        call drawBoulder
        mov firstboulderpos, dx
        mov didfirstend, 1
        jmp decnew

    decnew:
        mov dx, newboulderpos
        call drawBoulder
        dec dh
        call drawBoulder
        call delayy
        mov newboulderpos, dx
        jmp isjumping

    decboth:
        call drawBoulder
        dec dh
        call drawBoulder
        call delayy
        mov firstboulderpos, dx
        mov dx, newboulderpos
        call drawBoulder
        dec dh
        call drawBoulder
        mov newboulderpos, dx
        jmp isjumping

    decfirst:
        call drawBoulder
        dec dh
        call drawBoulder
        call delayy
        mov firstboulderpos, dx
        jmp isjumping

    printNewSprite2:
        mov firstboulderpos, dx
        mov dx, 150bh
        call drawBoulder
        mov newboulderpos, dx
        mov newSpriteFlag, 1
        mov dx, firstboulderpos
        call decfirst
    
    isjumping:
        mov al, isJumpFall
        cmp al, 1
        je l5
        jmp l6

MAIN ENDP

decPos proc
    cmp didfirstend, 1
    je addDelay
    mov dx, firstboulderpos
    call drawBoulder
    dec dh
    call drawBoulder
    call delay
    mov firstboulderpos, dx
    cmp newSpriteFlag, 1
    jne returnsequence
    mov dx, newboulderpos
    call drawBoulder
    dec dh
    call drawBoulder
    mov newboulderpos, dx
    returnsequence:
    ret

    addDelay:
    cmp newSpriteFlag, 1
    jne returnsequence
    mov dx, newboulderpos
    call drawBoulder
    dec dh
    call drawBoulder
    call delay
    mov newboulderpos, dx
    ret
decPos endp

checkCollision PROC       
    push bx
    push dx
    push ax
    mov dx, firstboulderpos
    mov bx, curDinoXY
;   mov al, dl
;   add al, 15
   cmp dx, bx
    jne checksecond
;    mov al, dh
;    add al, 15
    cmp dx, bx
    jne checksecond
  ;  mov al, bh
  ;  add al, 15
    cmp dx, bx
    jne checksecond
    
    pop bx
    pop dx
    pop ax
    mov ah, 4CH
    int 21h

    checksecond: 
        mov dx, newboulderpos
        mov bx, curDinoXY
  ;      mov al, dl
  ;      add al, 15
        cmp dx, bx
        jne noCollision
   ;     mov al, dh
   ;     add al, 15
        cmp dx, bx
        jne noCollision
    ;    mov al, bh
   ;     add al, 15
        cmp dx, bx
        jne noCollision
    
        pop bx
        pop dx
        pop ax
        mov ah, 4CH
        int 21h

    noCollision:
        pop dx
        pop bx
        pop ax
        ret
checkCollision endp

getRandomNumber PROC
    push cx
    MOV AH, 00h  ; interrupts to get system time        
    INT 1AH      ; CX:DX now hold number of clock ticks since midnight      

    mov  ax, dx
    xor  dx, dx
    mov  cx, 10
    div  cx       ; here dx contains the remainder of the division - from 0 to 9
    
    cmp dl, 0
    je zero
    cmp dl, 1
    je one
    cmp dl, 2
    je two
    cmp dl, 3
    je three
    cmp dl, 4
    je four
    cmp dl, 5
    je five
    cmp dl, 6
    je six
    cmp dl, 7
    je seven
    cmp dl, 8
    je eight
    mov newSpriteLocator, 0bh
    jmp goBack
    zero:
    mov newSpriteLocator, 14h
    jmp goBack
    one:
    mov newSpriteLocator, 12h
    jmp goBack
    two:
    mov newSpriteLocator, 10h
    jmp goBack
    three:
    mov newSpriteLocator, 0eh
    jmp goBack
    four:
    mov newSpriteLocator, 0ch
    jmp goBack
    five:
    mov newSpriteLocator, 0ah
    jmp goBack
    six:
    mov newSpriteLocator, 08h
    jmp goBack
    seven:
    mov newSpriteLocator, 15h
    jmp goBack
    eight:
    mov newSpriteLocator, 13h
    jmp goBack

    goBack:
    pop cx
    ret
getRandomNumber ENDP

Delay PROC
    push cx          
    mov ecx, 65500
    delay1: 
        nop             
        loop delay1
    mov ecx, 15500
    delay2: 
        nop
        loop delay2
    pop cx
    ret
Delay ENDP

drawBoulder PROC
call calcXY
lea si, boulder ; load sprite to SI
mov bx, 0f0fh
call drawImg
ret
drawBoulder ENDP

drawDino PROC
call calcXY
lea si, dino ; load sprite to SI
mov bx, 0f0fh
call drawImg
ret
drawDino ENDP

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
    mov cl, bl      ; height
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

dino:             
    DB 00h,00h,00h,0Bh,0Bh,0Bh,0Bh,0BH,0BH,0BH,0BH,0BH,0BH,00h,00h   
    DB 00h,0BH,0BH,09H,09H,09H,09H,09H,09H,09H,09H,01H,01H,0BH,00h    
    DB 0BH,01H,0BH,09H,09H,09H,09H,09H,09H,09H,09H,09H,01H,01H,0BH    
    DB 0BH,01H,0BH,09H,4fh,0BH,09H,09H,09H,09H,09H,09H,09H,01H,0BH   
    DB 00h,0BH,0BH,09H,4fh,0BH,09H,09H,09H,09H,09H,09H,09H,01H,0BH    
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

ReadCharWithTimeout PROC 
    mov ah, 1   
    int 16h
    jz noKey        
    mov ah, 0       
    int 16h
call EmptyKeyboardBuffer
    ret
    noKey:
    ret
ReadCharWithTimeout ENDP

EmptyKeyboardBuffer PROC    
    push ax
    .more:
        mov  ah, 01h        ; BIOS.ReadKeyboardStatus
        int  16h            ; -> AX ZF
        jz   .done          ; No key waiting aka buffer is empty
        mov  ah, 00h        ; BIOS.ReadKeyboardCharacter
        int  16h            ; -> AX
        jmp  .more          ; Go see if more keys are waiting
    .done:
        pop  ax
        ret
EmptyKeyboardBuffer ENDP


ReadChar PROC
    mov ah, 07h
    int 21h
    ret
ReadChar ENDP

END MAIN