; todo: shorten/simplify code
; - random interval for obstacles spawning

.model small
.386
.stack 1024
.data
    include sprite.inc       ; sprite related procs
    include fifteen.inc      ; include all sprites except alphabet
    include alphabet.inc     ; alphabet and numbers for score and name input
    include score.inc        ; score printing
    ;include anim.inc        ; walk cycle
    

    DinoXY dw 960 dup (?)    ; dh = x, dl = y
    curDinoXY dw 0           ; cur = current
    curBoulderXY dw 0

    randomNum db 0
    delayVarBig dd 20000        ;walking
    delayVarMed dd 10687        ;jumping
    delayVarSmol dd 15000
    spriteTimer db 10

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

    ans db 0
    dinoCycle db 2
    curArrowPos dw 0
    counter db 0
    firstjump db 0

    xloc dw 0
    yloc dw 0
    wid dw 0
    height dw 0
    color db 0

    hearts db 0
    handle dw ?
    filename db 'scores.txt', 0
    nameBuffer db 5 dup(?)
    scores db 00h, 7*50 dup (0)
    score dw 0
    scorebuffer db 000h, 000h
    username db 'ELSA$'
.code

main PROC
    mov ax, @data
    mov ds, ax

    call getRandomTimer
    call resetDelay

    mov ones, 0
    mov tens, 0
    mov hundreds, 0
    mov thousands, 0
    mov hearts, 3
    
    mov ax, @code       
    mov ds, ax
    ; screen initialization
    mov ax, 0013h
    int 10h

    call cls
    
    mov ax, @data
    mov ds, ax 

    ;call leaderboard
    call menu
    call drawclouds
    mov al, 2
    mov dx, 010bh
    call drawDino
    lea si, arrow
    mov dx, 6464h
    call arrowMove
    mov ans, 0
    promptLoop2:
        call ReadCharWithTimeout
        cmp ah, 48h
        je goUp
        cmp ah, 50h
        je goDown
        cmp al, 0dh
        je confirm2
        mov curArrowPos, dx
       ; call walkCycle
        mov dx, curArrowPos
        jmp promptLoop2
    
    goUp:
        cmp dx, 6975h
        je startchoice
        cmp dx, 7f85h
        je hiscorechoice
        jmp returnPrompt

        startchoice:
            lea si, arrow
            call arrowMove
            lea si, arrow
            mov dx, 6464h
            call arrowMove
            mov ans, 0
            jmp promptLoop2

    goDown:
        cmp dx, 6464h
        je hiscoreChoice
        cmp dx, 6975h
        je exitchoice
        jmp returnPrompt

        hiscoreChoice:
            lea si, arrow
            call arrowMove
            lea si, arrow
            mov dx, 6975h
            call arrowMove
            mov ans, 1
            jmp promptLoop2
        
        exitChoice:
            lea si, arrow
            call arrowMove
            lea si, arrow
            mov dx, 7f85h
            call arrowMove
            mov ans, 2
            jmp promptLoop2

        returnPrompt:
        jmp promptLoop2

    confirm2:
        mov al, ans
        cmp al, 1
        je gotohiscore
        cmp al, 2
        je exitgame
        jmp maingame

    gotohiscore:
    call leaderboard
    
    exitgame:
    mov ah, 4CH
    int 21h

    maingame:
    call cls
    call drawhearts
    call drawclouds
    call drawclouds2
    cmp firstjump, 2
    jne gotutorial
    jmp m1

    gotutorial:
        call tutorial

    m1:
    ; draw default dino pos
    mov dx, 010bh
    mov dinoCycle, 2
    mov al, 2
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
        mov dx, 150bh
        call drawBoulder
        mov counter, 0
        
        UpdateSprite:
            call drawBoulder
            dec dh
            call drawBoulder

        l1:
            cmp dh, 0Bh
            je incOnes
        l2:
            call ReadCharWithTimeout ; waits for user input 
            cmp al, 'w' 
            ;je checkCollision
            je moveUp
            cmp al, ' '
            je moveUp

            cmp dh, 00h
            jle slideStop       
            call checkCollision
            call Delay
            inc counter
            cmp counter, 3 
            jne UpdateSprite
            jmp animate

        incOnes:
            mov curBoulderXY, dx
            call drawOnes
            mov dx, curBoulderXY
            jmp l2

        animate:
            mov curBoulderXY, dx
            mov counter, 0
            mov dx, 010bh
            mov al, dinoCycle
            cmp al, 2
            je leftfoot2
            cmp al, 3
            je rightfoot2
            mov al, 0
            call drawDino
            mov al, 2
            call drawDino
            mov dinoCycle, 2
            mov dx, curBoulderXY
            jmp UpdateSprite
            
            leftfoot2:
                mov al, 2
                call drawDino
                mov al, 3
                call drawDino
                mov dinoCycle, 3
                mov dx, curBoulderXY
                jmp UpdateSprite

            rightfoot2:
                mov al, 3
                call drawDino
                mov al, 2
                call drawDino
                mov dinoCycle, 2
                mov dx, curBoulderXY
                jmp UpdateSprite

        slideStop:
            call drawOnes

            call spriteTimerDec
            call decDelay

            cmp spriteTimer, 0
            jg l1
            
            call spawnSprite
            jmp infloop

    gotutorial2:
        call tutorial
        jmp m2

    ; dino jump while still continuing obstacle slide
    moveUp: 
        mov curBoulderXY, dx ; preserve current boulder pos
        cmp firstjump, 2
        jne gotutorial2
        m2:
        mov dx, 010bh
        mov ecx, 4        ; height of jump
        mov isJumpFall, 1 ; set flag to 1 (jumping)
        jumpLoop:
            mov al, dinoCycle
            call drawDino
            dec dl
            mov al, 0
            call drawDino
            mov dinoCycle, 0
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
        l3skip:
            call delayy
            call checkCollision    
            mov curBoulderXY, dx
            mov dx, curDinoXY
        loop jumpLoop
        mov ecx, 4
        mov isJumpFall, 0  ; set flag to 0 (falling)
        fallLoop:
            mov al, 0
            call drawDino
            inc dl
            mov al, 0
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
        l4skip:
            call delayy
            call checkCollision
            mov curBoulderXY, dx
            mov dx, curDinoXY
        loop fallLoop
        mov dinoCycle, 4
        mov dx, curBoulderXY
        jmp l1

        slideStopp:
            call decDelay
            call drawOnes
            call spriteTimerDec

            cmp spriteTimer, 0
            jle stopSpawn
            
            mov al, isJumpFall ; check whether dino was jumping or falling when boulder reaches end
            cmp al, 1
            je l3skip  ; jumping
            jmp l4skip ; falling
            
            

            stopSpawn:
                call spawnSprite
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

spriteTimerDec PROC
    cmp spriteTimer, 0
    jle skipTimer
        
    call delay
    call delay
    dec spriteTimer

    skipTimer:
        ret
spriteTimerDec ENDP

spawnSprite PROC
    mov dx, 150bh
    call getRandomTimer
    call drawBoulder
    ret
spawnSprite ENDP

getRandomTimer proc
MOV AX, @DATA   
MOV DS, AX
push dx
push ax
push bx

        mov ah, 00h
        int 1ah

        mov ax, dx
        mov dx, 00h
        mov bx, 10h
        div bx

        mov spriteTimer, dl

    pop bx
    pop ax
    pop dx
    ret
getRandomTimer endp

writeToRec proc  ; insert new score into hiscore list
    ; fetch handle
    mov ax, 3d02h
    lea dx, filename
    int 21h
    jnc continueReading2

    mov ax, 3c00h
    mov cx, 0
    lea dx, filename
    int 21h
    
    continueReading2:
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


tutorial proc
    mov dx, 8761h
    lea si, wtojump
    call calcXYbuffer
    mov bx, 1907h
    call drawImg
    add dh, 19h
    lea si, wtojump2
    call calcXYbuffer
    mov bx, 1e07h
    call drawImg
    inc firstjump
    ret
tutorial endp


leaderboard proc
    call cls
    call leaderboardScreen
    ; fetch handle
    mov ax, 3d02h
    lea dx, filename
    int 21h
    jnc continueReading
    
    mov ax, 3c00h
    mov cx, 0
    lea dx, filename
    int 21h

    mov bx, handle
    lea dx, scores
    mov ax, 4000h
    mov cx, 1
    int 21h
    jmp promptLoop3

    continueReading:
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
    cmp ch, 0
    je promptLoop3
    inc si                ; inc bcuz actual data starts from si+1
    mov dx, 0710h
    push dx
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

        mov ah, 02h           ; BIOS set cursor position function
        mov bh, 00h           ; Page number (usually 0)
        pop dx
        int 10h               ; Call BIOS interrupt 10h to set cursor position
        add dh, 2
        push dx

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
    promptLoop3:
        call readchar
        cmp al, 'b'
        je goBackMain
        jmp promptLoop3
    goBackMain:
        call main
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
    mov dx, 010bh  
    mov al, 1       ; flag for dead dino sprite
    call drawDino   ; draw dead dino sprite
    call gameOverScreen
    call drawclouds
    call drawclouds2
    call tryAgainScreen
    lea si, arrow
    mov dx, 706dh
    call arrowMove
    mov ans, 0
    promptLoop:
        call ReadChar
        cmp al, 4bh
        je goLeft
        cmp al, 4dh
        je goRight
        cmp al, 0dh
        je confirm
        jmp promptLoop
    
    goLeft:
        lea si, arrow
        sub dh, 56
        call arrowMove
        lea si, arrow
        add dh, 56
        call arrowMove
        mov ans, 0
        jmp promptLoop

    goRight:
        lea si, arrow
        mov dx, 706dh
        call arrowMove
        lea si, arrow
        add dh, 56
        call arrowMove
        mov ans, 1
        jmp promptLoop

    confirm:
        mov al, ans
        cmp al, 0
        je yesAns
        call main
        yesAns:
        call restartGame

deadcls endp

arrowMove proc
    call calcXYbuffer
    mov bx, 070ch
    call drawImg
    ret
arrowMove endp

restartGame proc                
    mov ones, 0
    mov tens, 0
    mov hundreds, 0
    mov thousands, 0
    mov hearts, 3
    mov dinoCycle, 2
    call resetDelay
    call drawclouds
    call drawclouds2

    mov ax, @code       
    mov ds, ax

    call cls
    
    mov ax, @data
    mov ds, ax 

    mov dx, 010bh
    mov al, 2
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

decDelay PROC
    cmp delayVarBig, 20000
    jle skipDec

    sub delayVarBig, 3791
    sub delayVarMed, 2067
    ;sub delayVarSmol, 1000

    skipDec:
        ret
decDelay ENDP

resetDelay PROC
    mov delayVarBig, 65500
    mov delayVarMed, 35000
    mov delayVarSmol, 15000
    ret
resetDelay ENDP

checkCollision PROC       
    push bx
    mov bx, curDinoXY
    cmp bl, dl          ; compare dino y to boulder y
    jne noCollision
    cmp bh, dh          ; compare dino x to boulder x
    jne noCollision
    pop bx
    call EmptyKeyboardBuffer
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
        call enterName
        mov dx, 1600h
        lea si, heart
        call printSmallLetter
        lea si, heart2
        call printSmallLetter
        mov cx, 4
        mov dx, 0e0bh
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
            call EmptyKeyboardBuffer
            call resetDelay
            jmp infloop
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

randomDelay PROC    
    push ax
    push bx
    push cx
    push dx

        mov ah, 00h
        int 1ah

        mov ax, dx
        mov dx, 00h
        mov bx, 8h
        div bx
        add al, 1
        mov bx, 2
        mul bx

        mov cx, ax
        randDelayLoop:
            nop
        loop randDelayLoop

        ; mov ax, delayVarBig
        ; sub ax, 1000
        ; mov delayVarBig, ax
    
        ; Decrement delayVarMed by 1000
        ; mov ax, delayVarMed
        ; sub ax, 1000
        ; mov delayVarMed, ax
    
        ; Decrement delayVarSmol by 1000
        ; mov ax, delayVarSmol
        ; sub ax, 1000
        ; mov delayVarSmol, ax
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret
randomDelay ENDP

delayy PROC
MOV AX, @DATA
MOV DS, AX     
    push cx
    push ax

    mov ecx, delayVarMed  ; delay speed
    delay_loop:
        nop         ; no operation    
        loop delay_loop

    pop ax
    pop cx
    ret
Delayy ENDP

Delay PROC

MOV AX, @DATA
MOV DS, AX     

    push cx   
    push ax
  
    mov ecx, delayVarBig            
    delay1:
        nop
        loop delay1

    mov ecx, delayVarSmol            
    delay2:
        nop
        loop delay2

    pop ax
    pop cx
    ret
Delay ENDP

longDelay proc
MOV AX, @DATA
MOV DS, AX     
    push cx  
    push ax

    mov ax, 65500
    movzx ecx, ax   ; delay speed
    d1:
        nop             
        loop d1

    mov ax, 65500
    movzx ecx, ax
    d2:
        nop
        loop d2

     mov ax, 65500
    movzx ecx, ax
    d3:
        nop
        loop d3

    pop ax
    pop cx
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

END main
