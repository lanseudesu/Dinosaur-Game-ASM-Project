.code
drawDino PROC 
    cmp al, 1       ;check whether dino is dead or not
    je deadDino
    call calcXY
    lea si, dino    ; load sprite to SI
    call drawImg
    ret
    deadDino:
    call calcXY
    lea si, dead
    call drawImg
    ret
drawDino ENDP

drawBoulder PROC 
    call calcXY
    lea si, boulder ; load sprite to SI
    call drawImg
    ret
drawBoulder ENDP

printLetter PROC
    call calcXY
    call drawImg
    ret
printLetter ENDP

printSmallLetter PROC
    call calcXY2
    call drawImg2
    ret
printSmallLetter ENDP

calcXY PROC   ; calculate x and y pos of image
    mov ax, @code
    mov ds, ax      
    push dx
    mov ax, 15      ; sprite size by pixel
    mul dh
    mov di, ax
    mov ax, 15*320 ; sprite size * screen size
    mov bx, 0
    add bl, dl
    mul bx 
    add di, ax     ; placed all the calculated pos into DI
    pop dx 
    ret
calcXY ENDP

calcXY2 PROC   ; calculate x and y pos of image
    mov ax, @code
    mov ds, ax      
    push dx
    mov ax, 10     ; sprite size by pixel
    mul dh
    mov di, ax
    mov ax, 10*320 ; sprite size * screen size
    mov bx, 0
    add bl, dl
    mul bx 
    add di, ax     ; placed all the calculated pos into DI
    pop dx 
    ret
calcXY2 ENDP

drawImg PROC 
    push cx 
    mov ax, 0A000h  ; segment address of video memory 
    mov es, ax      ; moving to es allows pixel manipulation 
    mov cl, 15  ; height
    y_axis:
        push di
        mov ch, 15 ; width
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

drawImg2 PROC 
    push cx 
    mov ax, 0A000h  ; segment address of video memory 
    mov es, ax      ; moving to es allows pixel manipulation 
    mov cl, 10  ; height
    y_axis2:
        push di
        mov ch, 10 ; width
    x_axis2:
        mov al, [SI] ; ds:si (segment:offset), move 1 pixel db into al
        xor al, byte ptr es:[di]   ; xor al with first di pos
        mov byte ptr es:[di], al  ; updates the pixel on the screen with xor result
        inc si
        inc di
        dec ch
        jnz x_axis2  
    pop di
    add di, 320     ; move to new line of sprite
    dec cl 
    jnz y_axis2
    pop cx
    ret
drawImg2 ENDP

checkInput proc
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
    mov dx, 0604h
    lea si, bigg
    call printLetter 
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
    mov dx, 0f04h
    lea si, exclamation
    call printLetter
    mov dx, 0b08h
    lea si, smalle
    call printSmallLetter
    mov dx, 0c08h
    lea si, smalln
    call printSmallLetter
    mov dx, 0d08h
    lea si, smallt
    call printSmallLetter
    mov dx, 0e08h
    lea si, smalle
    call printSmallLetter
    mov dx, 0f08h
    lea si, smallr
    call printSmallLetter
    mov dx, 1108h
    lea si, smalln
    call printSmallLetter
    mov dx, 1208h
    lea si, smalla
    call printSmallLetter
    mov dx, 1308h
    lea si, smallm
    call printSmallLetter
    mov dx, 1408h
    lea si, smalle
    call printSmallLetter
    mov dx, 0e0ah
    lea si, blank
    call printSmallLetter
    mov dx, 0f0ah
    lea si, blank
    call printSmallLetter
    mov dx, 100ah
    lea si, blank
    call printSmallLetter
    mov dx, 110ah
    lea si, blank
    call printSmallLetter
    ret
gameOverScreen ENDP

drawOnes proc
    mov dx, 1d00h
    mov al, ones
    cmp al, 0
    je print0
    cmp al, 1
    je print1
    cmp al, 2
    je print2
    cmp al, 3
    je print3
    cmp al, 4
    je print4
    cmp al, 5
    je print5
    cmp al, 6
    je print6
    cmp al, 7
    je print7
    cmp al, 8
    je print8
    cmp al, 9
    je print9

    print0:
    mov ah, newOnes
    cmp ah, 1
    je new0
    lea si, blank2
    call printSmallLetter
    ;inc score
    jmp end0
    new0:
    lea si, num9
    call printSmallLetter
    mov ah, newtens
    cmp ah, 1
    je noIncTens
    inc tens
    call drawTens
    inc score
    jmp end0
    noIncTens:
    call drawTens
    mov newTens, 0
    inc score
    end0:
    mov dx, 1d00h
    lea si, num0
    call printSmallLetter
    inc ones
    ret
    print1:
    lea si, num0
    call printSmallLetter
    lea si, num1
    call printSmallLetter
    inc ones
    inc score
    ret
    print2:
    lea si, num1
    call printSmallLetter
    lea si, num2
    call printSmallLetter
    inc ones
    inc score
    ret
    print3:
    lea si, num2
    call printSmallLetter
    lea si, num3
    call printSmallLetter
    inc ones
    inc score
    ret
    print4:
    lea si, num3
    call printSmallLetter
    lea si, num4
    call printSmallLetter
    inc ones
    inc score
    ret
    print5:
    lea si, num4
    call printSmallLetter
    lea si, num5
    call printSmallLetter
    inc ones
    inc score
    ret
    print6:
    lea si, num5
    call printSmallLetter
    lea si, num6
    call printSmallLetter
    inc ones
    inc score
    ret
    print7:
    lea si, num6
    call printSmallLetter
    lea si, num7
    call printSmallLetter
    inc ones
    inc score
    ret
    print8:
    lea si, num7
    call printSmallLetter
    lea si, num8
    call printSmallLetter
    inc ones
    inc score
    ret
    print9:
    lea si, num8
    call printSmallLetter
    lea si, num9
    call printSmallLetter
    mov newOnes, 1
    mov ones, 0
    inc score
    ret
drawOnes endp

drawTens proc
    mov dx, 1c00h
    mov al, tens
    cmp al, 0
    je print00
    cmp al, 1
    je print10
    cmp al, 2
    je print20
    cmp al, 3
    je print30
    cmp al, 4
    je print40
    cmp al, 5
    je print50
    cmp al, 6
    je print60
    cmp al, 7
    je print70
    cmp al, 8
    je print80
    cmp al, 9
    je print90

    print00:
    mov ah, newTens
    cmp ah, 1
    je new00
    lea si, blank2
    call printSmallLetter
    jmp end00
    new00:
    lea si, num9
    call printSmallLetter
    mov ah, newHundreds
    cmp ah, 1
    je noIncHundreds
    inc hundreds
    call drawHundreds
    jmp end00
    noIncHundreds:
    call drawHundreds
    mov newHundreds, 0
    end00:
    mov dx, 1c00h
    lea si, num0
    call printSmallLetter
    ret
    print10:
    lea si, num0
    call printSmallLetter
    lea si, num1
    call printSmallLetter
    ret
    print20:
    lea si, num1
    call printSmallLetter
    lea si, num2
    call printSmallLetter
    ret
    print30:
    lea si, num2
    call printSmallLetter
    lea si, num3
    call printSmallLetter
    ret
    print40:
    lea si, num3
    call printSmallLetter
    lea si, num4
    call printSmallLetter
    ret
    print50:
    lea si, num4
    call printSmallLetter
    lea si, num5
    call printSmallLetter
    ret
    print60:
    lea si, num5
    call printSmallLetter
    lea si, num6
    call printSmallLetter
    ret
    print70:
    lea si, num6
    call printSmallLetter
    lea si, num7
    call printSmallLetter
    ret
    print80:
    lea si, num7
    call printSmallLetter
    lea si, num8
    call printSmallLetter
    ret
    print90:
    lea si, num8
    call printSmallLetter
    lea si, num9
    call printSmallLetter
    mov newTens, 1
    mov tens, 0
    ret
drawTens endp

drawHundreds proc
    mov dx, 1b00h
    mov al, hundreds
    cmp al, 0
    je print000
    cmp al, 1
    je print100
    cmp al, 2
    je print200
    cmp al, 3
    je print300
    cmp al, 4
    je print400
    cmp al, 5
    je print500
    cmp al, 6
    je print600
    cmp al, 7
    je print700
    cmp al, 8
    je print800
    cmp al, 9
    je print900

    print000:
    mov ah, newHundreds
    cmp ah, 1
    je new000
    lea si, blank2
    call printSmallLetter
    jmp end000
    new000:
    lea si, num9
    call printSmallLetter
    mov ah, newThousands
    cmp ah, 1
    je noIncThousands
    inc thousands
    call drawThousands
    jmp end000
    noIncThousands:
    call drawThousands
    mov newThousands, 0
    end000:
    mov dx, 1b00h
    lea si, num0
    call printSmallLetter
    ret
    print100:
    lea si, num0
    call printSmallLetter
    lea si, num1
    call printSmallLetter
    ret
    print200:
    lea si, num1
    call printSmallLetter
    lea si, num2
    call printSmallLetter
    ret
    print300:
    lea si, num2
    call printSmallLetter
    lea si, num3
    call printSmallLetter
    ret
    print400:
    lea si, num3
    call printSmallLetter
    lea si, num4
    call printSmallLetter
    ret
    print500:
    lea si, num4
    call printSmallLetter
    lea si, num5
    call printSmallLetter
    ret
    print600:
    lea si, num5
    call printSmallLetter
    lea si, num6
    call printSmallLetter
    ret
    print700:
    lea si, num6
    call printSmallLetter
    lea si, num7
    call printSmallLetter
    ret
    print800:
    lea si, num7
    call printSmallLetter
    lea si, num8
    call printSmallLetter
    ret
    print900:
    lea si, num8
    call printSmallLetter
    lea si, num9
    call printSmallLetter
    mov newHundreds, 1
    mov hundreds, 0
    ret
drawHundreds endp

drawThousands proc
    mov dx, 1a00h
    mov al, thousands
    cmp al, 0
    je print0000
    cmp al, 1
    je print1000
    cmp al, 2
    je print2000
    cmp al, 3
    je print3000
    cmp al, 4
    je print4000
    cmp al, 5
    je print5000
    cmp al, 6
    je print6000
    cmp al, 7
    je print7000
    cmp al, 8
    je print8000
    cmp al, 9
    je print9000

    print0000:
    lea si, num9
    call printSmallLetter
    lea si, num0
    call printSmallLetter
    ret
    print1000:
    lea si, num0
    call printSmallLetter
    lea si, num1
    call printSmallLetter
    ret
    print2000:
    lea si, num1
    call printSmallLetter
    lea si, num2
    call printSmallLetter
    ret
    print3000:
    lea si, num2
    call printSmallLetter
    lea si, num3
    call printSmallLetter
    ret
    print4000:
    lea si, num3
    call printSmallLetter
    lea si, num4
    call printSmallLetter
    ret
    print5000:
    lea si, num4
    call printSmallLetter
    lea si, num5
    call printSmallLetter
    ret
    print6000:
    lea si, num5
    call printSmallLetter
    lea si, num6
    call printSmallLetter
    ret
    print7000:
    lea si, num6
    call printSmallLetter
    lea si, num7
    call printSmallLetter
    ret
    print8000:
    lea si, num7
    call printSmallLetter
    lea si, num8
    call printSmallLetter
    ret
    print9000:
    lea si, num8
    call printSmallLetter
    lea si, num9
    call printSmallLetter
    mov newThousands, 1
    mov thousands, 0
    ret
drawThousands endp
