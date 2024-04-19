.model small
.386
.stack 1024
.code

main PROC
    mov ah, 0          	; 0=Set Video mode (AL=Mode)
    mov al, 13h        	; mode 13 (VGA 320x200 256 color)
    int 10h            	; bios int
	
    ; Set background color to white
    mov ax, 0A000h      ; Segment of video memory
    mov es, ax
    xor di, di          ; Starting offset of video memory
    mov cx, 320*200       ; Total number of pixels (320 * 200)

    mov al, 0Fh         ; White color
    rep stosb           ; Set all pixels to white

    mov dh,1            ; x
    mov dl,22          ; y

    call ShowSprite     ; Draw the sprite

    infloop:
    gravity:
        cmp dl, 22
        jg onGround
        call ShowSprite   
        inc dl
        call ShowSprite
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
        call ShowSprite
        dec dl
        call ShowSprite
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
    mov ah, 01h         ; check for key press w/o waiting
    int 16h            
    jz @F               ; jmp to end if z = set (no key pressed)
    mov ah, 00h         
    int 16h 
@@:    
    ret
ReadChar ENDP

; XOR sprite at (X,Y) pos (DH,DL)
ShowSprite PROC
    push cx
    ; calculate screen pos
    mov ax, @code       ; point DS to this segment
    mov ds, ax
    
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
    DB 00h,00h,00h,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,00h,00h    ;  0
    DB 00h,0Fh,0Fh,0Dh,0Dh,0Dh,0Dh,0Dh,0Dh,0Dh,0Dh,05h,05h,0Fh,00h    ;  1
    DB 0Fh,05h,0Fh,0Dh,0Dh,0Dh,0Dh,0Dh,0Dh,0Dh,0Dh,0Dh,05h,05h,0Fh    ;  2
    DB 0Fh,05h,0Fh,0Dh,00h,0Fh,0Dh,0Dh,0Dh,0Dh,0Dh,0Dh,0Dh,05h,0Fh    ;  3
    DB 00h,0Fh,0Fh,0Dh,00h,0Fh,0Dh,0Dh,0Dh,0Dh,0Dh,0Dh,0Dh,05h,0Fh    ;  4
    DB 0Fh,05h,0Fh,0Dh,0Dh,0Dh,0Dh,0Dh,0Dh,0Dh,0Fh,0Dh,0Dh,0Fh,0Fh    ;  5
    DB 0Fh,05h,0Fh,0Dh,0Dh,0Dh,0Dh,0Dh,0Dh,0Dh,0Dh,0Dh,0Dh,05h,0Fh    ;  6
    DB 00h,0Fh,0Fh,0Dh,0Dh,0Dh,0Dh,0Dh,0Dh,0Dh,0Dh,0Dh,0Dh,05h,0Fh    ;  7
    DB 00h,00h,00h,0Fh,0Dh,0Dh,0Dh,0Dh,0Dh,0Dh,0Dh,0Fh,0Fh,0Fh,00h    ;  8
    DB 00h,00h,00h,0Fh,0Dh,0Dh,0Dh,0Dh,0Dh,0Dh,0Dh,0Fh,00h,00h,00h    ;  9
    DB 00h,0Fh,0Fh,0Fh,0Dh,0Dh,0Dh,0Dh,0Dh,0Dh,0Dh,0Fh,00h,00h,00h    ;  10
    DB 00h,0Fh,0Dh,0Dh,0Dh,0Dh,0Dh,0Dh,0Dh,0Dh,0Dh,0Fh,00h,00h,00h    ;  11
    DB 00h,0Fh,0Fh,0Dh,0Dh,0Dh,0Fh,0Fh,0Fh,0Dh,0Dh,0Fh,00h,00h,00h    ;  12
    DB 00h,00h,0Fh,0Fh,0Fh,0Dh,0Fh,00h,0Fh,0Dh,0Fh,00h,00h,00h,00h    ;  13
    DB 00h,00h,00h,00h,0Fh,0Fh,0Fh,00h,0Fh,0Fh,0Fh,00h,00h,00h,00h    ;  14

END main