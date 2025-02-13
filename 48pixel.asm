    processor 6502
    include "vcs.h"
    include "macro.h"
    SEG.U VARS
    ORG $80

; $80
Temp            ds 1
ImageHeight     ds 1

   SEG CODE
   ORG $F800
Start:
   CLEAN_START
    lda #55
    ldx #0
    jsr SetHorizPos
    lda #63
    ldx #1
    jsr SetHorizPos
    sta WSYNC
    sta HMOVE
    lda #1
    sta VDELP0
    sta VDELP1
    lda #3
    sta NUSIZ0
    sta NUSIZ1
    lda #$0F
    sta COLUP0
    sta COLUP1

   
NextFrame
	VERTICAL_SYNC
    lda #44
    sta TIM64T

; My VBLANK code
	




WaitVBlank
    lda INTIM
    bne WaitVBlank ; loop until timer expires
    sta WSYNC
    sta VBLANK

    ldy #(hello_length-1)
    sty ImageHeight
BigGraphicLoop
    sta WSYNC           ; 3     (0)
    lda hello0,y        ; 4     (4)
    sta GRP0            ; 3     (7)     hello0->[GRP0]
    lda hello1,y        ; 4     (11)
    sta GRP1            ; 3     (14)    hello1->[GRP1], hello0->GRP0
    lda hello2,y        ; 4     (18)
    sta GRP0            ; 3     (21)    hello2->[GRP0], hello1->GRP1
    lda hello3,y        ; 4     (25*)   
    tax                 ; 2     (27)    hello3->X
    lda hello4,y        ; 4     (31)
    sta Temp            ; 3     (34)
    lda hello5,y        ; 4     (38)    hello5->A
    ldy Temp            ; 3     (41)

    stx GRP1            ; 3     (44)    hello3->[GRP1], hello2->GRP0
    sty GRP0            ; 3     (47)    hello4->[GRP0], hello3->GRP1
    sta GRP1            ; 3     (50)    hello5->[GRP1], hello4->GRP0
    sta GRP0            ; 3     (53)    hello5->GRP1    
    dec ImageHeight     ; 5     (58)
    ldy ImageHeight     ; 3     (61)
    bpl BigGraphicLoop  ; 2/3   (64)

    lda #0
    sta GRP1
    sta GRP0
    sta GRP1    

    ldx #(192-hello_length-1)
VSLoop
    sta WSYNC
    dex
    bne VSLoop

    
SetupOS
    lda #36
    sta TIM64T

; My Overscan code
            
WaitOverscan
    lda INTIM
    bne WaitOverscan
    
    jmp NextFrame



SetHorizPos
    sta WSYNC   ; start a new line
    bit 0       ; waste 3 cycles
    sec     ; set carry flag
DivideLoop
    sbc #15     ; subtract 15
    bcs DivideLoop  ; branch until negative
    eor #7      ; calculate fine offset
    asl
    asl
    asl
    asl
    sta RESP0,x ; fix coarse position
    sta HMP0,x  ; set fine offset
    rts     ; return to caller

    if >. != >[.+hello_length]
        align 256
    endif
hello0
    .byte %01000010
    .byte %11100111
    .byte %11100111
    .byte %11100111
    .byte %11100111
    .byte %11111111
    .byte %11111111
    .byte %11100111
    .byte %11100111
    .byte %11100111
    .byte %11100111
    .byte %01000010
hello_length = * - hello0

    if >. != >[.+hello_length]
        align 256
    endif
hello1
    .byte %00011111
    .byte %00111111
    .byte %00111111
    .byte %00110000
    .byte %00110000
    .byte %00111100
    .byte %00111100
    .byte %00110000
    .byte %00110000
    .byte %00111111
    .byte %00111111
    .byte %00011111

    if >. != >[.+hello_length]
        align 256
    endif
hello2
    .byte %00000000
    .byte %10001111
    .byte %00011111
    .byte %00011111
    .byte %00011100
    .byte %00011100
    .byte %00011100
    .byte %00011100
    .byte %00011100
    .byte %00011100
    .byte %10011100
    .byte %00001000
    
    if >. != >[.+hello_length]
        align 256
    endif
hello3
    .byte %00000000
    .byte %00001111
    .byte %10011111
    .byte %00011111
    .byte %00011100
    .byte %00011100
    .byte %00011100
    .byte %00011100
    .byte %00011100
    .byte %00011100
    .byte %00011100
    .byte %00001000
    
    if >. != >[.+hello_length]
        align 256
    endif
hello4
    .byte %00001111
    .byte %00011111
    .byte %10011111
    .byte %00011101
    .byte %00011000
    .byte %00011000
    .byte %00011000
    .byte %00011000
    .byte %00011101
    .byte %00011111
    .byte %00011111
    .byte %00001111
    
    if >. != >[.+hello_length]
        align 256
    endif
hello5
    .byte %10000110
    .byte %11000110
    .byte %11000000
    .byte %11000110
    .byte %11001111
    .byte %11001111
    .byte %11001111
    .byte %11001111
    .byte %11001111
    .byte %11001111
    .byte %11001111
    .byte %10000110


   ECHO ([$FFFC-.]d), "bytes free"

    org $fffc
    .word Start
    .word Start

