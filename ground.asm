.model small
.386
.stack 1024
.data
DinoX db 0
DinoY db 0 
BoulderX db 0
BoulderY db 0   
.code

main PROC
    mov ax, @code       ; point DS to this segment
    mov ds, ax
    mov ah, 0           ; 0=Set Video mode (AL=Mode)
    mov al, 13h         ; mode 13 (VGA 320x200 256 color)
    int 10h             ; bios int
    
    ; Set background color to white
    mov ax, 0A000h      ; Segment of video memory
    mov es, ax
    xor di, di          ; Starting offset of video memory
    mov cx, 320*170     ; Total number of pixels (320 * 200)

    mov al, 0Bh         ; White color
    rep stosb           ; Set all pixels to white
    
    mov cx, 320*30     ; Total number of pixels (320 * 200)

    mov al, 02h         ; White color
    rep stosb   
    ; Draw the sprite at its initial position
    mov DinoX, 0
    mov DinoY, 23
    call ShowDino

    infloop:
    gravity:
        cmp DinoY, 23
        jg onGround
        call ShowDino
        inc DinoY
        call ShowDino
        call Delay
        jmp gravity

    onGround:
        call ReadChar

        cmp al, 'w'
        je moveUp
        
        jmp infloop     ; cont loop if w is not pressed

moveUp:
    mov ecx, 4
    jumpLoop:
        call ShowDino
        dec DinoY
        call ShowDino
        call Delay
    loop jumpLoop
    jmp infloop


main ENDP

Delay PROC
    push cx             ; save original value of cx
    mov ecx, 50000   
    delay_loop:
        nop             ; no operation
        loop delay_loop
    pop cx
    ret
Delay ENDP

ReadChar PROC
    mov ah, 09H         ; check for key press w/o waiting
    int 16h            
    jz @F               ; jmp to end if z = set (no key pressed)
    mov ah, 00h         
    int 16h 
@@:    
    ret
ReadChar ENDP

ShowDino PROC
    mov dh, DinoX      ; Fetch Dino's X position
    mov dl, DinoY      ; Fetch Dino's Y position
    call ShowSprite
    ret
ShowDino ENDP

showBoulder PROC
    mov dh, BoulderX      ; Fetch Dino's X position
    mov dl, BoulderY      ; Fetch Dino's Y position
    call ShowSprite
    ret
showBoulder ENDP

; XOR sprite at (X,Y) pos (DH,DL)
ShowSprite PROC
    mov ax, @code       ; point DS to this segment
    mov ds, ax
    push cx
    
    ;prepares the 8x8 space for sprite
    push dx             ; preserve dx
    mov ax, 15          ; 8 bytes per 8x8 block
    mul dh
    mov di, ax
    mov ax, 15*320      ; 320 bytes per line, 8 lines per block
    mov bx, 0
    add bl, dl
    mul bx
    add di, ax
    pop dx              ; pop back dx, ES:DI is VRAM destination
    
    ; draw XOR sprite  
    mov si, offset BitmapTest    ; si=Source bitmap
    mov cl, 15                  ; height

; iterates through each row
DrawBitmap_Yagain:              
    push di
    mov ch, 15                  ; width

; iterates through each column
DrawBitmap_Xagain:              
    mov al, [SI]
    xor al, byte ptr es:[di]   ; XOR with current screen data.
    mov byte ptr es:[di], al   ; store the result back into memory
    inc si
    inc di
    dec ch
    jnz DrawBitmap_Xagain       ; next column of pixels
    pop di
    add di, 320                 ; move down 1 line (320 pixels)
    inc bl
    dec cl
    jnz DrawBitmap_Yagain       ; next row of pixels
    pop cx
    ret 
ShowSprite ENDP

BitmapTest:             ; dinosaur, 1 byte per pixel
    DB 00h,00h,00h,0Bh,0Bh,0Bh,0Bh,0BH,0BH,0BH,0BH,0BH,0BH,00h,00h    ;  0
    DB 00h,0BH,0BH,09H,09H,09H,09H,09H,09H,09H,09H,01H,01H,0BH,00h    ;  1
    DB 0BH,01H,0BH,09H,09H,09H,09H,09H,09H,09H,09H,09H,01H,01H,0BH    ;  2
    DB 0BH,01H,0BH,09H,04h,0BH,09H,09H,09H,09H,09H,09H,09H,01H,0BH    ;  3
    DB 00h,0BH,0BH,09H,04h,0BH,09H,09H,09H,09H,09H,09H,09H,01H,0BH    ;  4
    DB 0BH,01H,0BH,09H,09H,09H,09H,09H,09H,09H,0BH,09H,09H,0BH,0BH    ;  5
    DB 0BH,01H,0BH,09H,09H,09H,09H,09H,09H,09H,09H,09H,09H,01H,0BH    ;  6
    DB 00h,0BH,0BH,09H,09H,09H,09H,09H,09H,09H,09H,09H,09H,01H,0BH    ;  7
    DB 00h,00h,00h,0BH,09H,09H,09H,09H,09H,09H,09H,0BH,0BH,0BH,00h    ;  8
    DB 00h,00h,00h,0BH,09H,09H,09H,09H,09H,09H,09H,0BH,00h,00h,00h    ;  9
    DB 00h,0BH,0BH,0BH,09H,09H,09H,09H,09H,09H,09H,0BH,00h,00h,00h    ;  10
    DB 00h,0BH,09H,09H,09H,09H,09H,09H,09H,09H,09H,0BH,00h,00h,00h    ;  11
    DB 00h,0BH,0BH,09H,09H,09H,0BH,0BH,0BH,09H,09H,0BH,00h,00h,00h    ;  12
    DB 00h,00h,0BH,0BH,0BH,09H,0BH,00h,0BH,09H,0BH,00h,00h,00h,00h    ;  13
    DB 00h,00h,00h,00h,0BH,0BH,0BH,00h,0BH,0BH,0BH,00h,00h,00h,00h    ;  14

END main
