.code

walkCycle proc
    push ax
    mov dx, 010bh
    mov al, dinoCycle
    cmp al, 2
    je rightfoot
    cmp al, 3
    je leftfoot

    rightfoot:
    mov al, 2
    call drawDino
    mov al, 3
    call drawDino
    call longDelay
    call longDelay
    mov dinoCycle, 3
    pop ax
    ret

    leftfoot:
    mov al, 3
    call drawDino
    mov al, 2
    call drawDino
    call longDelay
    call longDelay
    mov dinoCycle, 2
    pop ax
    ret
walkCycle endp


