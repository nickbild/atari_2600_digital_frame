; Nick Bild
; January 2025
; nick.bild@gmail.com
;
; This code makes use of the well-known 48-pixel image trick, and borrows from the
; implementation published at "Dr Boo's Woodgrain Wizadry":
; https://www.taswegian.com/WoodgrainWizard/tiki-index.php?page=48-pixel-Image-Routine

    processor 6502
    
    include "vcs.h"
    include "macro.h"

HEIGHT = 84 - 1


    SEG.U VARS
    ORG $80
Temp            ds 1
ImageHeightCnt     ds 1


   SEG CODE
   ORG $F000
Start:
   CLEAN_START
    
NextFrame
	VERTICAL_SYNC
    lda #44
    sta TIM64T

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

; VBLANK
WaitVBlank
    lda INTIM
    bne WaitVBlank
    sta WSYNC
    sta VBLANK

    ldy #HEIGHT
    sty ImageHeightCnt
BigGraphicLoop
    sta WSYNC           ; 3     (0)
    lda sprite0          ; 4     (4)
    sta GRP0            ; 3     (7)   
    lda sprite0          ; 4     (11)
    sta GRP1            ; 3     (14)   
    lda sprite0          ; 4     (18)
    sta GRP0            ; 3     (21)   
    lda sprite0          ; 4     (25*)   
    tax                 ; 2     (27)    
    lda sprite0          ; 4     (31)
    sta Temp            ; 3     (34)
    lda sprite0         ; 4     (38) 
    ldy Temp            ; 3     (41)

    stx GRP1            ; 3     (44)    
    sty GRP0            ; 3     (47)    
    sta GRP1            ; 3     (50)    
    sta GRP0            ; 3     (53)    
    dec ImageHeightCnt     ; 5     (58)
    ldy ImageHeightCnt     ; 3     (61)
    bpl BigGraphicLoop  ; 2/3   (64)


    lda #0
    sta GRP1
    sta GRP0
    sta GRP1    

    ldx #(192-HEIGHT)
VSLoop
    sta WSYNC
    dex
    bne VSLoop

SetupOS
    lda #36
    sta TIM64T

; Overscan            
WaitOverscan
    lda INTIM
    bne WaitOverscan


; Pass 2
	VERTICAL_SYNC
    lda #44
    sta TIM64T

    lda #103
    ldx #0
    jsr SetHorizPos
    lda #111
    ldx #1
    jsr SetHorizPos
    sta WSYNC
    sta HMOVE
    lda #1
    sta VDELP0
    sta VDELP1
    lda #0
    sta NUSIZ0
    sta NUSIZ1
    lda #$0F
    sta COLUP0
    sta COLUP1

; VBLANK
WaitVBlank2
    lda INTIM
    bne WaitVBlank2
    sta WSYNC
    sta VBLANK

    ldy #HEIGHT
    sty ImageHeightCnt
BigGraphicLoop2
    sta WSYNC           ; 3     (0)
    lda sprite0          ; 4     (4)
    sta GRP0            ; 3     (7)   
    lda sprite0          ; 4     (11)
    sta GRP1            ; 3     (14)
    sta GRP0
    
    dec ImageHeightCnt     ; 5  
    ldy ImageHeightCnt     ; 3 
    bpl BigGraphicLoop2  ; 2/3 


    lda #0
    sta GRP1
    sta GRP0
    sta GRP1  

    ldx #(192-HEIGHT)
VSLoop2
    sta WSYNC
    dex
    bne VSLoop2

SetupOS2
    lda #36
    sta TIM64T

; Overscan            
WaitOverscan2
    lda INTIM
    bne WaitOverscan2

    
    jmp NextFrame


SetHorizPos
    sta WSYNC
    bit 0
    sec
DivideLoop
    sbc #15
    bcs DivideLoop
    eor #7
    asl
    asl
    asl
    asl
    sta RESP0,x
    sta HMP0,x
    rts

    ORG $FF00   ; The PicoROM will change this byte after every time it's read.
sprite0
    .byte %11111111

    ORG $FFFA
    .word Start
    .word Start
    .word Start
