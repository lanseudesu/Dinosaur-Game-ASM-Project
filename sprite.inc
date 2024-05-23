.code
drawDino PROC 
    cmp al, 1       ;check whether dino is dead or not
    je deadDino
    mov al, 0
    call calcXY
    lea si, dino    ; load sprite to SI
    mov bx, 0f0fh
    call drawImg
    ret
    deadDino:
    mov al, 0
    call calcXY
    lea si, dead
    mov bx, 0f0fh
    call drawImg
    ret
drawDino ENDP

drawBoulder PROC 
    mov al, 0
    call calcXY
    lea si, boulder ; load sprite to SI
    mov bx, 0f0fh
    call drawImg
    ret
drawBoulder ENDP

printLetter PROC
    mov al, 0
    call calcXY
    mov bx, 0f0fh
    call drawImg
    ret
printLetter ENDP

printSmallLetter PROC
    mov al, 2
    call calcXY
    mov bx, 0a0ah
    call drawImg
    ret
printSmallLetter ENDP

calcXY PROC   ; calculate x and y pos of image
    push ax
    mov ax, @code
    mov ds, ax
    pop ax      
    push dx
    cmp al, 1
    jle fifbyfif
    cmp al, 2
    je twobytwo
    cmp al, 3
    je onebyone

    fifbyfif:
    mov ax, 15      ; sprite size by pixel
    mul dh
    mov di, ax
    mov ax, 15*320 ; sprite size * screen size
    jmp returnSeq

    twobytwo:
    mov ax, 10      ; sprite size by pixel
    mul dh
    mov di, ax
    mov ax, 10*320 ; sprite size * screen size
    jmp returnSeq

    onebyone:
    mov ax, 1      ; sprite size by pixel
    mul dh
    mov di, ax
    mov ax, 1*320 ; sprite size * screen size
    jmp returnSeq

    returnSeq:
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
    mov cl, bl  ; height
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

checkInput proc     ; check input for name
	cmp al, 'a'
    je letA
    cmp al, 'b'
    je letB
    cmp al, 'c'
    je letC
    cmp al, 'd'
    je letD
    cmp al, 'e'
    je letE
    cmp al, 'f'
    je letF
    cmp al, 'g'
    je letG
    cmp al, 'h'
    je letH
    cmp al, 'i'
    je letI
    cmp al, 'j'
    je letJ
    cmp al, 'k'
    je letK
    cmp al, 'l'
    je letL
    cmp al, 'm'
    je letM
    cmp al, 'n'
    je letN
    cmp al, 'o'
    je letO
    cmp al, 'p'
    je letP
    cmp al, 'q'
    je letQ
    cmp al, 'r'
    je letR
    cmp al, 's'
    je letS
    cmp al, 't'
    je letT
    cmp al, 'u'
    je letU
    cmp al, 'v'
    je letV
    cmp al, 'w'
    je letW
    cmp al, 'x'
    je letX
    cmp al, 'y'
    je letY
    cmp al, 'z'
    je letZ
    ret

    letA:
    lea si,  smallA
    ret
    letB:
    lea si,  smallB
    ret
    letC:
    lea si,  smallC
    ret
    letD:
    lea si,  smallD
    ret
    letE:
    lea si,  smallE
    ret
    letF:
    lea si,  smallF
    ret
    letG:
    lea si,  smallG
    ret
    letH:
    lea si,  smallH
    ret
    letI:
    lea si,  smallI
    ret
    letJ:
    lea si,  smallJ
    ret
    letK:
    lea si,  smallK
    ret
    letL:
    lea si,  smallL
    ret
    letM:
    lea si,  smallM
    ret
    letN:
    lea si,  smallN
    ret
    letO:
    lea si,  smallO
    ret
    letP:
    lea si,  smallP
    ret
    letQ:
    lea si,  smallQ
    ret
    letR:
    lea si,  smallR
    ret
    letS:
    lea si,  smallS
    ret
    letT:
    lea si,  smallT
    ret
    letU:
    lea si,  smallU
    ret
    letV:
    lea si,  smallV
    ret
    letW:
    lea si,  smallW
    ret
    letX:
    lea si,  smallX
    ret
    letY:
    lea si,  smallY
    ret
    letZ:
    lea si,  smallZ
    ret
checkInput endp

gameOverScreen PROC ; prints game over screen
    mov dx, 4e3ah
    lea si, bigassg
    call calcXYbuffer
    mov bx, 1315h
    call drawImg
    add dh, 21
    lea si, bigassa
    call calcXYbuffer
    mov bx, 1215h
    call drawImg
    add dh, 20
    lea si, bigassm
    call calcXYbuffer
    mov bx, 1415h
    call drawImg
    add dh, 22
    lea si, bigasse
    call calcXYbuffer
    mov bx, 1314h
    call drawImg
    add dh, 25
    lea si, bigasso
    call calcXYbuffer
    mov bx, 1214h
    call drawImg
    add dh, 20
    lea si, bigassv
    call calcXYbuffer
    mov bx, 1214h
    call drawImg
    add dh, 20
    lea si, bigasse
    call calcXYbuffer
    mov bx, 1314h
    call drawImg
    add dh, 21
    lea si, bigassr
    call calcXYbuffer
    mov bx, 1214h
    call drawImg
    mov dx, 6b53h
    lea si, smallasse
    call calcXYbuffer
    mov bx, 0c0dh
    call drawImg
    add dh, 12
    lea si, smallassn
    call calcXYbuffer
    mov bx, 0a0dh
    call drawImg
    add dh, 10
    lea si, smallasst
    call calcXYbuffer
    mov bx, 0b0dh
    call drawImg
    add dh, 11
    lea si, smallasse
    call calcXYbuffer
    mov bx, 0c0dh
    call drawImg
    add dh, 12
    lea si, smallassr
    call calcXYbuffer
    mov bx, 0b0dh
    call drawImg
    add dh, 15
    lea si, smallassn
    call calcXYbuffer
    mov bx, 0a0dh
    call drawImg
    add dh, 10
    lea si, smallassa
    call calcXYbuffer
    mov bx, 0a0dh
    call drawImg
    add dh, 10
    lea si, smallassm
    call calcXYbuffer
    mov bx, 0e0dh
    call drawImg
    add dh, 14
    lea si, smallasse
    call calcXYbuffer
    mov bx, 0c0dh
    call drawImg
    mov bp, 0
    mov dx, 0e0bh
    blankLoop:
        lea si, blank
        call printSmallLetter
        inc dh
        inc bp
    cmp bp, 4
    jne blankLoop
    ret
gameOverScreen ENDP

calcXYbuffer proc
    mov al, 3
    call calcXY
    ret
calcXYbuffer endp

tryAgainScreen proc ; prints try again screen
    mov dx, 0604h
    lea si, bigt
    call printLetter
    mov dx, 0704h
    lea si, bigr
    call printLetter
    mov dx, 0804h
    lea si, bigy
    call printLetter
    mov dx, 0a04h
    lea si, biga
    call printLetter
    mov dx, 0b04h
    lea si, bigg
    call printLetter
    mov dx, 0c04h
    lea si, biga
    call printLetter
    mov dx, 0d04h
    lea si, bigi
    call printLetter
    mov dx, 0e04h
    lea si, bign
    call printLetter
    mov dx, 0f04h
    lea si, question
    call printLetter
    mov dx, 0f0ah
    lea si, smally
    call printSmallLetter
    mov dx, 100ah
    lea si, smalle
    call printSmallLetter
    mov dx, 110ah
    lea si, smalls
    call printSmallLetter
    mov dx, 0f0ch
    lea si, smalle
    call printSmallLetter
    mov dx, 100ch
    lea si, smallx
    call printSmallLetter
    mov dx, 110ch
    lea si, smalli
    call printSmallLetter
    mov dx, 120ch
    lea si, smallt
    call printSmallLetter
    ret
tryAgainScreen endp

drawhearts proc
    mov dx, 1800h
    lea si, heart
    call printSmallLetter
    mov dx, 1700h
    lea si, heart
    call printSmallLetter
    mov dx, 1600h
    lea si, heart
    call printSmallLetter
    ret
drawhearts endp

menu proc
    mov dx, 0503h
    lea si, bigp
    call printLetter
    mov dx, 0603h
    lea si, bigr
    call printLetter
    mov dx, 0703h
    lea si, bige
    call printLetter
    mov dx, 0803h
    lea si, bigh
    call printLetter
    mov dx, 0903h
    lea si, bigi
    call printLetter
    mov dx, 0a03h
    lea si, bigs
    call printLetter
    mov dx, 0b03h
    lea si, bigt
    call printLetter
    mov dx, 0c03h
    lea si, bigo
    call printLetter
    mov dx, 0d03h
    lea si, bigr
    call printLetter
    mov dx, 0e03h
    lea si, bigi
    call printLetter
    mov dx, 0f03h
    lea si, bigc
    call printLetter
    mov dx, 0d07h
    lea si, smallr
    call printSmallLetter
    mov dx, 0e07h
    lea si, smallu
    call printSmallLetter
    mov dx, 0f07h
    lea si, smallN
    call printSmallLetter
    mov dx, 1007h
    lea si, smalln
    call printSmallLetter
    mov dx, 1107h
    lea si, smallE
    call printSmallLetter
    mov dx, 1207h
    lea si, smallr
    call printSmallLetter
    mov dx, 0e09h
    lea si, smalls
    call printSmallLetter
    mov dx, 0f09h
    lea si, smallt
    call printSmallLetter
    mov dx, 1009h
    lea si, smalla
    call printSmallLetter
    mov dx, 1109h
    lea si, smallr
    call printSmallLetter
    mov dx, 1209h
    lea si, smallt
    call printSmallLetter
    mov dx, 0e0bh
    lea si, smallh
    call printSmallLetter
    mov dx, 0f0bh
    lea si, smalli
    call printSmallLetter
    mov dx, 100bh
    lea si, smalls
    call printSmallLetter
    mov dx, 110bh
    lea si, smallc
    call printSmallLetter
    mov dx, 120bh
    lea si, smallo
    call printSmallLetter
    mov dx, 130bh
    lea si, smallr
    call printSmallLetter
    mov dx, 140bh
    lea si, smalle
    call printSmallLetter
    mov dx, 150bh
    lea si, smalls
    call printSmallLetter
    mov dx, 0e0dh
    lea si, smalle
    call printSmallLetter
    mov dx, 0f0dh
    lea si, smallX
    call printSmallLetter
    mov dx, 100dh
    lea si, smalli
    call printSmallLetter
    mov dx, 110dh
    lea si, smallt
    call printSmallLetter
    ret
menu endp