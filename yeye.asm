.model small		
.386                ; enables the use of 32 bit register
.stack 1024			; 1kb of memory for stack
.code				

main PROC
    mov ah, 0          	; 0=Set Video mode (AL=Mode)
    mov al, 13h        	; mode 13 (VGA 320x200 256 color)
    int 10h            	; bios int
	
    mov dh,1			; x
    mov dl,22			; y
	
    call ShowSprite		; initial position of sprite
    
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
    mov ax,0A000h 		; base address of VGA mode 13h 
    mov es,ax
    mov ax, @code		; point DS to this segment
    mov ds, ax
    
    ;prepares the 8x8 space for sprite
    push dx	            ;preserve dx
        mov ax,8		; 8 bytes per 8x8 block
        mul dh
        mov di,ax
			
        mov ax,8*320	; 320 bytes per line, 8 lines per block
        mov bx,0
        add bl,dl
        mul bx
        add di,ax
    pop dx				; pop back dx, ES:DI is VRAM destination
	
    ; draw XOR sprite	
    mov si,offset BitmapTest    ; si=Source bitmap
    mov cl,8			        ; height

; iterates through each row
DrawBitmap_Yagain:              
    push di
        mov ch,8		; width

; iterates through each column
DrawBitmap_Xagain:				
        mov al,[SI]
         xor al, byte ptr es:[di] ; XOR with current screen data.
        mov byte ptr es:[di], al ; store the result back into memory
        inc si
        inc di
        dec ch
        jnz DrawBitmap_Xagain ; next column of pixels
    pop di
    add di,320			; move down 1 line (320 pixels)
    inc bl
    dec cl
    jnz DrawBitmap_Yagain
    pop cx
    ret	
ShowSprite ENDP

BitmapTest:             ; smiley, 1 byte per pixel
    DB 00h,00h,0Eh,0Eh,0Eh,0Eh,00h,00h     ;  0
    DB 00h,0Eh,0Eh,0Eh,0Eh,0Eh,0Eh,00h     ;  1
    DB 0Eh,0Eh,03h,0Eh,0Eh,03h,0Eh,0Eh     ;  2
    DB 0Eh,0Eh,0Eh,0Eh,0Eh,0Eh,0Eh,0Eh     ;  3
    DB 0Eh,0Eh,0Eh,0Eh,0Eh,0Eh,0Eh,0Eh     ;  4
    DB 0Eh,0Eh,0Eh,0Eh,0Eh,0Eh,0Eh,0Eh     ;  5
    DB 0Eh,0Eh,02h,0Eh,0Eh,02h,0Eh,0Eh     ;  6
    DB 00h,0Eh,0Eh,02h,02h,0Eh,0Eh,00h     ;  7
	
END main
