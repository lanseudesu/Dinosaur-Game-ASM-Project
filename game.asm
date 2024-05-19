; todo: shorten sprite related procs
; - random interval for obstacles spawning
; - mainmenu, points, gameover screen, leaderboard, pause

.model small
.386
.stack 1024
.data
    include sprite.inc       ; sprite related procs
    include fifteen.inc      ; 15x15 sprites
    include alphabet.inc     ; 10x10 letters
    include score.inc        ; score printing

    DinoXY dw 960 dup (?)    ; dh = x, dl = y
    curDinoXY dw 0           ; cur = current
    curBoulderXY dw 0

    isJumpFall db 0          ; is dino jumping or falling flag
    curScore dw 960 dup (?)

    ones db 0                ; scores, ones
    newOnes db 0             ; flag if ones is repeatig

    tens db 0         
    newTens db 0

    hundreds db 0
    newHundreds db 0

    thousands db 0
    newThousands db 0

    xloc dw 0
    yloc dw 0
    wid dw 0
    height dw 0
    color db 0
.code

draw macro x, y, w, h, c         
	mov xloc, x
	mov yloc, y
	mov wid, w
	mov height, h
    mov color, c
	call addRec
endm

addRec proc
	mov cx, xloc              
	mov dx, yloc
	drawLoop:
		mov ah, 0Ch           ;draw pixel
		mov al, color         ;color
		mov bh, 00h           ;page number, always 0
		int 10h

		inc cx
		mov ax, cx
		sub ax, xloc
		cmp ax, wid
		jng drawLoop
		
		mov cx, xloc
		inc dx
		
		mov ax, dx
		sub ax, yloc
		cmp ax, height
		jng drawLoop
	ret
addRec endp

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
    mov cx, 320*180     

    mov al, 0Bh         
    rep stosb   

    mov cx, 320*20     
    mov al, 02h         ; grass
    rep stosb   
    
    mov ax, @data
    mov ds, ax 

    ; draw default dino pos
    mov dx, 010bh
    call drawDino 
    mov curDinoXY, dx
    call drawOnes
    mov dx, 1c00h
    lea si, num0
    call printSmallLetter
    mov dx, 1b00h
    lea si, num0
    call printSmallLetter
    mov dx, 1a00h
    lea si, num0
    call printSmallLetter
    infloop:
        mov dx, 160bh
        call drawBoulder
        l1:
            ;mov curBoulderXY, dx
            ;call drawOnes
            ;mov dx, curBoulderXY
            cmp dh, 00h
            jle slideStop
            cmp dh, 0Bh
            je incOnes
        l2:
            call ReadCharWithTimeout ; waits for user input 
            cmp al, 'w' 
            ;je checkCollision
            je moveUp
            call drawBoulder
            dec dh
            call drawBoulder
            call Delay
            call checkCollision
            jmp l1

        incOnes:
            mov curBoulderXY, dx
            call drawOnes
            mov dx, curBoulderXY
            jmp l2

        slideStop:
            call drawBoulder
            call drawOnes
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
            cmp dh, 0bh
            je incOnes2
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
            call drawOnes
            mov dx, 160bh
            call drawBoulder
            mov al, isJumpFall ; check whether dino was jumping or falling when boulder reaches end
            cmp al, 1
            je l3  ; jumping
            jmp l4 ; falling

        incOnes2:
            mov curBoulderXY, dx
            call drawOnes
            mov dx, curBoulderXY
            mov al, isJumpFall ; check whether dino was jumping or falling when boulder reaches end
            cmp al, 1
            je l3  ; jumping
            jmp l4 ; falling
main ENDP

deadcls proc
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

    ;draw bracket y
    draw 128, 98, 2, 1, 2ah
    draw 128, 99, 1, 10, 2ah
    draw 128, 110, 2, 1, 2ah
    draw 133, 99, 2, 4, 2ah
    draw 139, 99, 2, 4, 2ah
    draw 134, 103, 2, 1, 2ah
    draw 138, 103, 2, 1, 2ah
    draw 135, 104, 4, 1, 2ah
    draw 136, 105, 2, 4, 2ah
    draw 144, 98, 2, 1, 2ah
    draw 145, 99, 1, 10, 2ah
    draw 144, 110, 2, 1, 2ah
    ;draw bracket x
    draw 128, 118, 2, 1, 04h
    draw 128, 119, 1, 10, 04h
    draw 128, 130, 2, 1, 04h
    draw 133, 119, 2, 3, 04h
    draw 139, 119, 2, 3, 04h
    draw 134, 122, 2, 1, 04h
    draw 138, 122, 2, 1, 04h
    draw 136, 123, 2, 1, 04h
    draw 134, 125, 2, 1, 04h
    draw 138, 125, 2, 1, 04h
    draw 133, 126, 2, 4, 04h
    draw 139, 126, 2, 4, 04h
    draw 144, 118, 2, 1, 04h
    draw 145, 119, 1, 10, 04h
    draw 144, 130, 2, 1, 04h

    mov dx, 010bh  
    mov al, 1       ; flag for dead dino sprite
    call drawDino   ; draw dead dino sprite
    call tryAgainScreen
    call ReadChar

    promptLoop:
        cmp al, 'y'
        je cls
        cmp al, 'x'
        je exit
        jmp promptLoop
    
    exit:
        mov ah, 4CH
        int 21h
deadcls endp

cls proc                ; restart game
    mov ones, 0
    mov tens, 0
    mov hundreds, 0
    mov thousands, 0

    mov ax, @code       
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
    
    mov ax, @data
    mov ds, ax 

    mov dx, 010bh
    call drawDino 
    mov curDinoXY, dx
    call drawOnes
    mov dx, 1c00h
    lea si, num0
    call printSmallLetter
    mov dx, 1b00h
    lea si, num0
    call printSmallLetter
    mov dx, 1a00h
    lea si, num0
    call printSmallLetter

    jmp infloop
cls endp

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
        call gameOverScreen
        mov cl, 4
        mov dx, 0e0ah
        readcharacter:
            call ReadChar
            call checkInput
            push si
            lea si, blank
            call printSmallLetter
            pop si
            call printSmallLetter
            inc dh
        loop readcharacter
        call printScore
        call deadcls
        mov ah, 4CH
        int 21h
checkCollision ENDP

printScore proc
    dec ones
    mov ah, 02h
    mov dl, thousands
    add dl, '0'
    int 21h
    mov dl, hundreds
    add dl, '0'
    int 21h
    mov dl, tens
    add dl, '0'
    int 21h
    mov dl, ones
    add dl, '0'
    int 21h
    ret
printScore endp

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
    mov ah, 07h
    int 21h
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