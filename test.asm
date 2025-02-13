                processor 6502
                include "vcs.h"
                include "macro.h"

                SEG.U vars
                ORG $80
;var1    ds 1

;------------------------------------------------------------------------------

                SEG code
                ORG $F000

Reset

    ; Clear RAM and all TIA registers.

                ldx #0 
                lda #0 
Clear           sta 0,x 
                inx 
                bne Clear

        ;------------------------------------------------
        ; Once-only initialisation...
                lda #%00000000
                sta HMP0
                lda #%00010000
                sta HMP1
        ;------------------------------------------------

StartOfFrame

    ; Start of new frame
    ; Start of vertical blank processing

                lda #0
                sta VBLANK

                lda #2
                sta VSYNC

                sta WSYNC
                sta WSYNC
                sta WSYNC                ; 3 scanlines of VSYNC signal

                lda #0
                sta VSYNC
                
        ;------------------------------------------------
        ; 37 scanlines of vertical blank...
            
                ldx #0
VerticalBlank   sta WSYNC
                inx
                cpx #36
                bne VerticalBlank

                lda #$56
                sta COLUP0
                lda #$67
                sta COLUP1
                
                ldx #0                  ; Scanline counter

                sta WSYNC

        ;------------------------------------------------
        ; 192 visible lines

                SLEEP 22
                sta RESP0               ; 3
                sta RESP1               ; 3
                sta WSYNC               ; 3
                sta HMOVE               ; 3

VisibleLines     

                ldy SpriteShape         ; 4
                sty GRP0                ; 3
                sty GRP1                ; 3


                sta WSYNC               ; 3
                
                inx                     ; 2
                cpx #191                ; 2
                bne VisibleLines        ; 3

                

        ;------------------------------------------------

 
                lda #%01000010
                sta VBLANK           ; end of screen - enter blanking

    ; 30 scanlines of overscan...

                lda #$0
                sta COLUP0
                lda #$0
                sta COLUP1
                sta WSYNC

                ldx #0
Overscan        sta WSYNC
                inx
                cpx #29
                bne Overscan

                jmp StartOfFrame

SpriteShape
            .byte #%11111111

;------------------------------------------------------------------------------

            ORG $FFFA

InterruptVectors

            .word Reset           ; NMI
            .word Reset           ; RESET
            .word Reset           ; IRQ

    		END
