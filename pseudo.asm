;check for collision

checkCollision:
        push bx
        mov bx, curDinoXY
        cmp bl, dl
        jne noCollision
        cmp bh, dh
        jne noCollision
        pop bx
        jmp gameOver

    noCollision:
        pop bx
        jmp l1


    gameOver:
        mov ah, 4CH
        int 21h

;while dino dl at 0Bh && boulder dh at 01h -> ggs

;random interval for obstacles spawning

; call delay function with a random input of number
; this random input will determine the seconds it takes to create 
; another obstacle

; nop 1x -> inc/dec 1x -> nop 1x -> and so on..

randomDelay PROC
    push cx
    mov al, isJumpFall
    cmp al, 1
    je l3
    jmp l4            
    mov ecx, 65500 
    randLoop1:
        nop
        loop randLoop1
    mov ecx, 65500
    randLoop2:
        nop
        loop randLoop2
     mov ecx, 65500
    randLoop3:
        nop
        loop randLoop3
    pop cx
    ret
randomDelay ENDP

;give a random ecx
;do wtv loop, then after print another obstacle

;jump
1 pixel ng jump -> 1 pixel ng slide 

;slide boulder

