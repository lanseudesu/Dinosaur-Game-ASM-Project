;todo: random interval for obstacles spawning
; - mainmenu, points, gameover screen, leaderboard, pause

.model small
.386
.stack 1024
.data
    include sprite.inc
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

END main