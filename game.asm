; todo: shorten sprite related procs
; - random interval for obstacles spawning
; - pause
; - design and animation

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
    newOnes db 0             ; flag if ones is repeating

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

    hearts db 0
    handle dw ?
    filename db 'scores.txt', 0
    nameBuffer db 5 dup(?)
    ;scores db 05h
            ;db 'LANS$', 000h, 010h
            ;db 'BNOS$', 000h, 00Fh
            ;db 'DURO$', 000h, 009h
            ;db 'FRED$', 000h, 004h
            ;db 'DIEL$', 000h, 001h
    ; LANS 0016 BNOS 0315 DURO 0009 FRED 0104 DIEL 0201  
    scores db 00h, 7*50 dup (0)
    score dw 0
    scorebuffer db 000h, 000h
    username db 'ELSA$'
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

    call cls
    
    mov ax, @data
    mov ds, ax 

    call menu
    promptLoop2:
    call readchar
    cmp al, 's'
    je maingame
    cmp al, 'h'
    je mmhiscore
    cmp al, 'x'
    je exitgame
    jmp promptLoop2

    mmhiscore:
    call leaderboard
    mov ah, 4ch
    int 21h
    
    exitgame:
    mov ah, 4CH
    int 21h

    maingame:
    call cls
    mov hearts, 3
    call drawhearts

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

leaderboard proc
    call cls
    ; fetch handle
    mov ax, 3d02h
    lea dx, filename
    int 21h
    mov handle, ax

    ; go to start of file
    mov ax, 4200h
    mov bx, handle
    mov cx, 0
    mov dx, 0
    int 21h

    ; read from file
    mov ah, 3fh
    mov bx, handle
    mov cx, 2eh           ; 7*5 + 1
    lea dx, scores
    int 21h

    lea si, scores
    mov ch, byte ptr [si] ; ch = number of records (05h)
    inc si                ; inc bcuz actual data starts from si+1
    iterScores:
        lea di, nameBuffer
        mov cl, 05h       ; 4 letter name + '$'
        nameloop:
            mov dl, byte ptr [si]
            mov byte ptr [di], dl
            inc di
            inc si
            dec cl
            jnz nameloop

        mov ah, 02h
        mov dl, 0ah
        int 21h  
        lea dx, nameBuffer
        mov ah, 09h
        int 21h

        mov ah, 02h
        mov dl, 20h
        int 21h
        
        mov ah, byte ptr [si]
        inc si
        mov al, byte ptr [si]
        push cx
        mov cx, 04h     ; 0000 format score
        hexToDec:       ; convert to decimal
            xor dx, dx
            mov bx, 0ah
            div bx
            push dx
        loop hexToDec
        mov cx, 04h
        printNum:       ; print score
            pop dx
            add dx, '0'
            mov ah, 02 
            int 21h
        loop printNum
        inc si
        pop cx
        dec ch
        mov ah, 02h
        mov dl, 10
        int 21h
    jnz iterScores
    ret
leaderboard endp

cls proc
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
    ret
cls endp

deadcls proc
    call cls
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
        je restartGame
        cmp al, 'x'
        je lead
        jmp promptLoop
    
    lead:
        call leaderboard

    exit:
        mov ah, 4CH
        int 21h
deadcls endp

restartGame proc                
    mov ones, 0
    mov tens, 0
    mov hundreds, 0
    mov thousands, 0
    mov hearts, 3

    mov ax, @code       
    mov ds, ax

    call cls
    
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

    call drawhearts

    jmp infloop
restartGame endp

checkCollision PROC       
    push bx
    mov bx, curDinoXY
    cmp bl, dl          ; compare dino y to boulder y
    jne noCollision
    cmp bh, dh          ; compare dino x to boulder x
    jne noCollision
    pop bx
    dec hearts
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
        mov al, hearts
        cmp al, 0
        jne reset

        call gameOverScreen
        mov dx, 1600h
        lea si, heart
        call printSmallLetter
        lea si, heart2
        call printSmallLetter
        mov cx, 4
        mov dx, 0e0ah
        lea bp, username
        readcharacter:
            call ReadChar
            mov byte ptr ds:[bp], al
            inc bp
            call checkInput
            push si
            lea si, blank
            call printSmallLetter
            pop si
            call printSmallLetter
            inc dh
        loop readcharacter
        mov byte ptr ds:[bp], '$'
        mov ax, score
        dec ax
        lea si, scorebuffer
        mov byte ptr [si+1], al
        call writeToRec
        call printScore
        call deadcls

        minus1:
            mov dx, 1800h
            lea si, heart
            call printSmallLetter
            lea si, heart2
            call printSmallLetter
            call rloop

        minus2:
            mov dx, 1700h
            lea si, heart
            call printSmallLetter
            lea si, heart2
            call printSmallLetter
            call rloop

        reset:
            mov al, hearts
            cmp al, 2
            je minus1
            cmp al, 1
            je minus2
        rloop:
            mov dx, 0f08h
            lea si, num3
            call printSmallLetter
            call longDelay
            call longDelay
            call longDelay
            call longDelay
            mov dx, 0f08h
            lea si, num3
            call printSmallLetter
            lea si, num2
            call printSmallLetter
            call longDelay
            call longDelay
            call longDelay
            call longDelay
            mov dx, 0f08h
            lea si, num2
            call printSmallLetter
            lea si, num1
            call printSmallLetter
            call longDelay
            call longDelay
            call longDelay
            call longDelay
            mov dx, 0f08h
            lea si, num1
            call printSmallLetter
            mov dx, 010bh
            mov al, 1
            call drawDino 
            mov al, 0
            call drawDino
            mov curDinoXY, dx
            jmp infloop
checkCollision ENDP

writeToRec proc  ; insert new score into hiscore list
    ; fetch handle
    mov ax, 3d02h
    lea dx, filename
    int 21h
    mov handle, ax ; return ax as handle
            
    ; go to start of file
    mov ax, 4200h
    mov bx, handle
    mov cx, 0
    mov dx, 0
    int 21h

    ; read from file
    mov ah, 3fh
    mov bx, handle
    mov cx, 2eh             ; 7*5 + 1
    lea dx, scores
    int 21h
            
    ; insert rec
    lea di, scores
    xor ax, ax              
    mov al, byte ptr [di]
    mov bl, 07h       ; go to the last score rec
    mul bl
    xor ah, ah
    add di, ax        ; move di to the the last byte of the last rec
    add di, 01h
    insrec:
        lea si, username
        mov cx, 05h
        inpname:      ; insert each letter of the username into last rec
            mov dl, byte ptr [si]
            mov byte ptr [di], dl
            inc si
            inc di
            loop inpname
            lea si, scorebuffer ; insert score
            mov dh, byte ptr [si]
            mov dl, byte ptr [si+1]
            mov byte ptr [di], dh
            mov byte ptr [di+1], dl
            
            ; increment score size 
            lea si, scores
            mov ch, byte ptr [si]
            inc ch
            mov byte ptr [si], ch
            
            ;sort using bubble sort
            mov dh, ch
            ; ch = outer loop counter
            ; dh = inner loop counter
            outsort:
                lea si, scores 
                lea di, scores
                add si, 07h  ; 07h is the low byte of the first rec score
                add di, 07h
                push cx
                mov ch, dh
                insort:
                    mov di, si
                    mov ah, byte ptr [si]
                    mov al, byte ptr [si-1]
                    mov bh, byte ptr [si+7]
                    mov bl, byte ptr [si+6]
                    cmp ax, bx
                    jge noswap
                    add di, 01h
                    sub si, 06h
                    mov dl, 07h
                    swapscore:
                        mov bh, byte ptr [di]
                        mov bl, byte ptr [si]
                        mov byte ptr [di], bl
                        mov byte ptr [si], bh
                        inc si
                        inc di
                        dec dl
                        jnz swapscore
                    noswap:
                    add si, 07h
                    dec ch 
                jnz insort
                pop cx
                dec dh
                dec ch
            jnz outsort

            ; cap hiscores to 5 recs
            lea si, scores
            mov al, byte ptr [si]
            cmp al, 05h
            jle undercap
            mov al, 05h
            undercap:
            mov byte ptr[si], al
                
            ; go to start of file
            mov ax, 4200h
            mov bx, handle
            mov cx, 0
            mov dx, 0
            int 21h
            ; write to file
            mov ah, 40h
            mov bx, handle
            lea dx, scores
            mov cx, 2eh;
            int 21h
            ; close file
            mov ah, 3eh
            mov bx, handle
            int 21h
            ret
writeToRec endp

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

longDelay proc
    push cx            
    mov ecx, 65500   ; delay speed
    d1:
        nop             
        loop d1
    mov ecx, 65500
    d2:
        nop
        loop d2
    mov ecx, 65500
    d3:
        nop
        loop d3
    pop dx
    ret
longDelay endp

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