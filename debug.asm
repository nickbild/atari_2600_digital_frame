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
    lda sprite0,y          ; 4     (4)
    sta GRP0            ; 3     (7)   
    lda sprite1,y          ; 4     (11)
    sta GRP1            ; 3     (14)   
    lda sprite2,y          ; 4     (18)
    sta GRP0            ; 3     (21)   
    lda sprite3,y          ; 4     (25*)   
    tax                 ; 2     (27)    
    lda sprite4,y          ; 4     (31)
    sta Temp            ; 3     (34)
    lda sprite5,y         ; 4     (38) 
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
    lda sprite6,y          ; 4     (4)
    sta GRP0            ; 3     (7)   
    lda sprite7,y          ; 4     (11)
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

	align 256
sprite7
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 128
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
sprite6
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 192
	.byte 240
	.byte 252
	.byte 156
	.byte 230
	.byte 255
	.byte 249
	.byte 255
	.byte 255
	.byte 255
	.byte 254
	.byte 255
	.byte 243
	.byte 112
	.byte 0
	.byte 0
	.byte 0
	.byte 128
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 128
	.byte 192
	.byte 192
	.byte 224
	.byte 224
	.byte 0
	.byte 32
	.byte 160
	.byte 32
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 128
	.byte 0
	.byte 0
	.byte 128
	.byte 132
	.byte 4
	.byte 156
	.byte 120
	.byte 248
	.byte 248
	.byte 236
	.byte 228
	.byte 244
	.byte 246
	.byte 114
	.byte 119
	.byte 155
	.byte 199
	.byte 255
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
sprite5
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 1
	.byte 7
	.byte 15
	.byte 31
	.byte 31
	.byte 255
	.byte 255
	.byte 255
	.byte 255
	.byte 239
	.byte 255
	.byte 227
	.byte 71
	.byte 35
	.byte 2
	.byte 3
	.byte 7
	.byte 60
	.byte 56
	.byte 62
	.byte 127
	.byte 15
	.byte 3
	.byte 59
	.byte 125
	.byte 231
	.byte 199
	.byte 134
	.byte 224
	.byte 253
	.byte 255
	.byte 254
	.byte 223
	.byte 196
	.byte 254
	.byte 217
	.byte 225
	.byte 224
	.byte 210
	.byte 55
	.byte 249
	.byte 0
	.byte 0
	.byte 143
	.byte 143
	.byte 119
	.byte 179
	.byte 81
	.byte 13
	.byte 14
	.byte 7
	.byte 3
	.byte 1
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	align 256
sprite4
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 224
	.byte 240
	.byte 254
	.byte 255
	.byte 255
	.byte 255
	.byte 227
	.byte 139
	.byte 121
	.byte 12
	.byte 144
	.byte 252
	.byte 248
	.byte 248
	.byte 240
	.byte 248
	.byte 248
	.byte 240
	.byte 242
	.byte 210
	.byte 242
	.byte 246
	.byte 246
	.byte 243
	.byte 149
	.byte 62
	.byte 14
	.byte 140
	.byte 108
	.byte 108
	.byte 41
	.byte 41
	.byte 225
	.byte 167
	.byte 171
	.byte 36
	.byte 129
	.byte 4
	.byte 44
	.byte 32
	.byte 48
	.byte 9
	.byte 0
	.byte 5
	.byte 3
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
sprite3
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 32
	.byte 130
	.byte 143
	.byte 223
	.byte 31
	.byte 255
	.byte 255
	.byte 255
	.byte 255
	.byte 243
	.byte 102
	.byte 254
	.byte 253
	.byte 253
	.byte 251
	.byte 251
	.byte 255
	.byte 31
	.byte 199
	.byte 247
	.byte 55
	.byte 31
	.byte 31
	.byte 255
	.byte 253
	.byte 207
	.byte 223
	.byte 204
	.byte 205
	.byte 205
	.byte 203
	.byte 250
	.byte 247
	.byte 244
	.byte 228
	.byte 180
	.byte 68
	.byte 192
	.byte 196
	.byte 72
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
sprite2
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 32
	.byte 0
	.byte 64
	.byte 8
	.byte 0
	.byte 6
	.byte 75
	.byte 39
	.byte 7
	.byte 95
	.byte 254
	.byte 127
	.byte 127
	.byte 127
	.byte 127
	.byte 254
	.byte 249
	.byte 127
	.byte 255
	.byte 225
	.byte 207
	.byte 255
	.byte 255
	.byte 255
	.byte 252
	.byte 249
	.byte 251
	.byte 159
	.byte 255
	.byte 251
	.byte 255
	.byte 255
	.byte 190
	.byte 125
	.byte 125
	.byte 255
	.byte 255
	.byte 255
	.byte 255
	.byte 254
	.byte 255
	.byte 255
	.byte 254
	.byte 251
	.byte 246
	.byte 88
	.byte 227
	.byte 224
	.byte 128
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	align 256
sprite1
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 64
	.byte 0
	.byte 0
	.byte 0
	.byte 96
	.byte 16
	.byte 73
	.byte 6
	.byte 9
	.byte 4
	.byte 1
	.byte 0
	.byte 0
	.byte 1
	.byte 0
	.byte 0
	.byte 0
	.byte 1
	.byte 3
	.byte 3
	.byte 7
	.byte 15
	.byte 15
	.byte 12
	.byte 30
	.byte 63
	.byte 63
	.byte 127
	.byte 31
	.byte 31
	.byte 63
	.byte 63
	.byte 56
	.byte 31
	.byte 63
	.byte 127
	.byte 127
	.byte 127
	.byte 103
	.byte 231
	.byte 207
	.byte 143
	.byte 31
	.byte 126
	.byte 248
	.byte 227
	.byte 207
	.byte 30
	.byte 252
	.byte 240
	.byte 192
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	align 256
sprite0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 1
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 1
	.byte 3
	.byte 6
	.byte 6
	.byte 4
	.byte 13
	.byte 12
	.byte 31
	.byte 31
	.byte 15
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0

    ORG $FFFA
    .word Start
    .word Start
    .word Start
