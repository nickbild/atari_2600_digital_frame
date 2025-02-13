;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Nick Bild
; nick.bild@gmail.com
; 2024-11-14
; 2600 Camera
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	processor 6502
	include "/home/nick/software/dasm-2.20.14.1/machines/atari2600/vcs.h"
	include "/home/nick/software/dasm-2.20.14.1/machines/atari2600/macro.h"

; RAM
	SEG.U vars
	ORG $80

; Initialize player 0 coordinates and score.
P0yStart	ds 1
P0yEnd 		ds 1
P0Score 	ds 1
P0line 		ds 1 ; Current line of P0 sprite to be drawn.
temp		ds 1
PFpattern	ds 1 ; PF pattern to use.
PFinterval	ds 1 ; Refresh pattern every this many frames.
PFnum		ds 1 ; Write pattern to which PF address (PF0...PF2 == $0D...$0F).
ButtonTimer	ds 1 ; Used to deactivate button press for a time.
Missile0y	ds 1
MissileTimer	ds 1
RANDOM		ds 1

; ROM
	SEG code
	ORG $F000

; Clear RAM and all TIA registers.
Reset
	ldx #0 
	lda #0 
Clear
	sta 0,x 
	inx 

	bne Clear

	ldx #$FF	; Stack start.
	txs		; Transfer to stack.

; Initialization
	lda #$0C
	sta COLUP0	; Set player 0 color.

	lda #$02	; Set playfield color.
	sta COLUPF
	
	lda #0
	sta P0yStart	; Player 0 Y coordinates.
	
	lda #10
	sta P0yEnd
	sta PFpattern

	lda #0
	sta P0line
	sta PFinterval
	sta ButtonTimer
	sta MissileTimer

	lda #2
	sta PFnum

	;;;
	; Set initial sprite X positions.
	;;;

	; Initialize P0.
	ldx #40
	ldy #0
	jsr PosObject

	; Initialize  missile.
        ldx #150
        ldy #1
        jsr PosObject

	lda #$20
	sta NUSIZ0


; Frame loop
StartOfFrame
; VSYNC / VBLANK
	lda #0
	sta VBLANK

	lda #2
	sta VSYNC

; 3 scanlines of VSYNC signal (game logic embedded within)
	sta WSYNC

; Adjust P0 X position
; SWCHA contains bits representing state of joystick 0.
	ldy #0	; 2
	sty GRP0 ; 4 prevent P0 bleeding over

	lda #%10000000 ; 2 - value for "right" from joystick.
	bit SWCHA	; 4 is the joystick currently in the "right" state?
	bne NORIGHT ; 2,3
	ldy #%11110000	; 2
	jmp MOVEP	; 3
NORIGHT
	lda #%01000000 ; 2 left
	bit SWCHA	; 4
	bne MOVEP	; 2,3
	ldy %00010000	; 2
MOVEP
	sty HMP0	; 4

	lda #%00100000 ; 2 up
	bit SWCHA	; 4
	bne NOUP	; 2,3
	inc P0yStart	; 6
	inc P0yEnd	; 6
NOUP
	lda #%00010000 ; 2 down
	bit SWCHA	; 4
	bne NODOWN	; 2,3
	dec P0yStart	; 6
	dec P0yEnd	; 6
NODOWN
; END Adjust P0 X position

	sta WSYNC
	
; Keep P0 within Y upper and lower bounds
	ldx P0yStart
	cpx #255
	bne NOCORRECTUP
	ldx #0
	stx P0yStart
	ldx #10
	stx P0yEnd     
NOCORRECTUP
	ldx P0yEnd
	cpx #182
	bne NOCORRECTDOWN
	ldx #171
	stx P0yStart
	ldx #181
	stx P0yEnd
NOCORRECTDOWN   	
	
	sta WSYNC

	lda #0
	sta VSYNC

; 37 scanlines of VBLANK (game logic embedded within)
	sta WSYNC

	lda #0
	sta AUDV0
	sta AUDV1

	lda #$02        ; Set playfield color.
        sta COLUPF

	sta WSYNC
	
	bit CXP0FB
	bpl SkipCollision ; bpl effectively checks bit 7 (P0/PF collision)
	
	lda INPT4 ; joystick button
	bmi ButtonNotPressed

	; At this point, there was a P0/PF collision, and the button was pressed.	

	lda #$34        ; Set playfield color on PF0/PF collision and button press.
        sta COLUPF

	; Play some sound.
	lda #7
        sta AUDC0 ; 16 values
        lda #31
        sta AUDF0 ; 32 values
        lda #4
        sta AUDV0 ; 16 values

        lda #15
        sta AUDC1 ; 16 values
        lda #1
        sta AUDF1 ; 32 values
        lda #4
        sta AUDV1 ; 16 values

	ldx ButtonTimer		; This is used to slow down the rate at which the button may work.
	cpx #0
	beq BUTTONOK 		; If ButtonTimer == 0, allow it to process.
	inx			; else, increment timer. If >= x (30/second)
	cpx #15			; reset it to 0.
	bcs RESETBUTTONTIMER
	stx ButtonTimer
	jmp SkipCollision
RESETBUTTONTIMER
	ldx #0
	stx ButtonTimer
	jmp SkipCollision

BUTTONOK
	inc ButtonTimer

	inc P0Score

	ldx P0Score	; 4
	cpx #99
	bcc NOSCORERESET	; if score < 100, don't reset it.
	ldx #99
	stx P0Score     ; 4
NOSCORERESET
ButtonNotPressed
SkipCollision

	sta WSYNC

	lda #$0C
        sta COLUP0      ; Set player 0 standard color.

	; Check for missile 0 collision.
        bit CXM0P
        bvc SkipM0Collision     ; bvc effectively checks bit 6 (P0/M0 collision)

	lda #$36
        sta COLUP0      ; Set player 0 missile hit color.

	; Play some collision sound.
	lda #9
        sta AUDC0 ; 16 values
        lda #41
        sta AUDF0 ; 32 values
        lda #8
        sta AUDV0 ; 16 values

        lda #5
        sta AUDC1 ; 16 values
        lda #11
        sta AUDF1 ; 32 values
        lda #23
        sta AUDV1 ; 16 values

	; Update score.
        ldx P0Score
        cpx #1
        bcc SkipM0Collision     ; if score <1, skip decrement.
        dec P0Score             ; Decrement score if collision.
SkipM0Collision

	sta WSYNC

	sta CXCLR ; clear collision registers

	sta WSYNC

	; Move missile X position (relative).
	ldy %00100000
	sty HMM0
	
	;;;
	; Move missile Y position (absolute, 0-182 are on screen values).
	;;;


	ldx MissileTimer         ; This is used to slow down the rate at which the missile may change Y coordinates.
        cpx #0
        beq MISSILEOK            ; If MillileTimer == 0, allow it to process.
        inx                     ; else, increment timer. If >= x (30/second)
        cpx #30                 ; reset it to 0.
        bcs RESETMISSILETIMER
        stx MissileTimer
        jmp SkipMoveMissile

RESETMISSILETIMER
        ldx #0
        stx MissileTimer
        jmp SkipMoveMissile

MISSILEOK
	inc MissileTimer

	; Generate pseudo-random number for positioning.
	lda RANDOM
   	beq XSEED
	lsr
	bcc SRAND
XSEED
	eor #$A9
SRAND
	sta RANDOM
	tay

	cpy #182
	bcc RANDOMOK
	ldy #90		; If random number out of range, just place missile in middle of screen this time.
RANDOMOK 

	; Store the Y position
	sty Missile0y

SkipMoveMissile

	sta WSYNC

	; Start drawing P0 from 1st line for new frame.
	lda #0
        sta P0line

	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC	
	
	sta HMOVE	; Update horizontal position of all sprites.  This triggers relative position updates
			; made to all sprites (e.g. HMP0).
	
	lda #$D4
	sta COLUBK	; Set background color.
	
	;;;
	; Change playfield segement to use.
	;;;

	ldx PFinterval  	; 4
        cpx #10         	; 2 Update every this many frames (must be < PF pattern change frequency).
        beq UPDATEPFNUM 	; 3/4
        jmp NOUPDATEPFNUM	; 3

UPDATEPFNUM

	ldx PFnum
	dex
	cpx #3
	bcs STEPPFNUM0
	stx PFnum	; else
	jmp STEPPFEND
STEPPFNUM0		; if PFnum >= 3 (i.e., it rolled from 0 to 255).
	ldx #2
	stx PFnum
STEPPFEND

NOUPDATEPFNUM

	lda #0

	sta WSYNC

	;;;
	; Update play field.
	;;;

	; Load current PF pattern.
	ldy PFpattern	; 4

	; Clear all playfield addresses.
	ldx #0		; 2
	stx PF0		; 4
	stx PF1		; 4
	stx PF2		; 4

	; Use PF0, PF1, or PF2?
	ldx PFnum	; 2
	cpx #0		; 2
	beq USEPF0	; 3/4
	cpx #1
        beq USEPF1	; 3/4

	sty PF2		; 4
	jmp ENDPF       ; 3
USEPF0
	sty PF0		; 4
	jmp ENDPF	; 3
USEPF1
        sty PF1         ; 4
ENDPF

	; Increment PF update interval (happens once per frame).
	ldx PFinterval	; 4
	inx		; 2
	stx PFinterval	; 4

	; Decide if it's time to update pattern yet.
	cpx #15		; 2 Update every this many frames.
	beq UPDATEPF	; 3/4
	jmp NOUPDATEPF	; 3

UPDATEPF
	; Update pattern.
	iny		; 2
	sty PFpattern	; 4

	; Reset interval counter.
	ldx #0		; 2
	stx PFinterval	; 4
NOUPDATEPF

	sta WSYNC

	ldx #0  ; 2 Scan line counter
        lda #0  ; 2

	sta WSYNC	; Vertical blank 37.

; Visible screen loop
VisibleLoop
	sta GRP0		; 4 Set P0 shape for this line.
				; This is actually the shape set on the previous
				; scanline to allow for more cycles.

	; P0 Y positioning
	lda #0		; 2 Make sprite invisible, unless in bounds (as determined below).

	; Is P0 Y location within bounds of current scanline?
	cpx P0yStart	; 4
	bcc SkipSprite	; 3/4 Skip past if scanline < P0 start.
	cpx P0yEnd	; 4
	bcs SkipSprite	; 3/4 Skip past if scanline >= P0 end

	; Drawing P0 sprite 1 scanline at a time from data table.
	ldy P0line              ; 4 Get current line of P0 sprite to be drawn.
	lda SpriteP0,y          ; 4/5 Get current sprite line from lookup table.
	inc P0line		; 6

SkipSprite
	; 40 worst case.

	ldy #0			; 2
	cpx Missile0y           ; 4
	bne SkipMissile0	; 2/3
	ldy #2                  ; 2
SkipMissile0
	sty ENAM0               ; 4

	inx			; 2
	cpx #182		; 2
	
	sta WSYNC		; 4
	bne VisibleLoop	; 2,3

ScoreSection
	; Change BG color, make P0, playfield invisible.
        lda #50         ; 2
        sta COLUBK      ; 4
        lda #0          ; 2
        sta GRP0        ; 4
        sta PF0         ; 4
        sta PF1         ; 4
        sta PF2         ; 4

	sta WSYNC
	sta WSYNC
	sta WSYNC

	; Left side.
	lda #%01010000  ; 2
        sta PF0         ; 4
        lda #%11101001  ; 2
        sta PF1         ; 4
        lda #%11101110  ; 2
        sta PF2         ; 4
	; 18

	; Delay before writing right side.
	SLEEP 10
	ldy #0		; 2
	sty PF0		; 4 Clear PF 0
	
	; Write right side PF1
	ldy P0Score             ; 2
        lda NumbersLine0,y      ; 4/5 Load approriate scanline of score number.
        sta PF1                 ; 4

	SLEEP 8
	ldy #0		; 2
	sty PF2		; 4 Clear PF2
	
	sta WSYNC

	; Left side.
        lda #%01010000  ; 2
        sta PF0         ; 4
        lda #%10001101  ; 2
        sta PF1         ; 4
        lda #%00101010  ; 2
        sta PF2         ; 4

        ; Delay before writing right side.
        SLEEP 10
        ldy #0          ; 2
        sty PF0         ; 4

	ldy P0Score		; 2
        lda NumbersLine1,y      ; 4/5 Load approriate scanline of score number.
	sta PF1         	; 4

	SLEEP 8
        ldy #0          ; 2
        sty PF2         ; 4 Clear PF

	sta WSYNC

	; Left side.
        lda #%00100000  ; 2
        sta PF0         ; 4
        lda #%11101011  ; 2
        sta PF1         ; 4
        lda #%11101010  ; 2
        sta PF2         ; 4

        ; Delay before writing right side.
        SLEEP 10
        ldy #0          ; 2
        sty PF0         ; 4

	ldy P0Score             ; 2
        lda NumbersLine2,y      ; 4/5 Load approriate scanline of score number.
	sta PF1         ; 4

	SLEEP 8
        ldy #0          ; 2
        sty PF2         ; 4 Clear PF

	sta WSYNC

	; Left side.
        lda #%01010000  ; 2
        sta PF0         ; 4
        lda #%10001001  ; 2
        sta PF1         ; 4
        lda #%10001010  ; 2
        sta PF2         ; 4

        ; Delay before writing right side.
        SLEEP 10
        ldy #0          ; 2
        sty PF0         ; 4

	ldy P0Score             ; 2
        lda NumbersLine3,y      ; 4/5 Load approriate scanline of score number.
	sta PF1         ; 4

	SLEEP 8
        ldy #0          ; 2
        sty PF2         ; 4 Clear PF

	sta WSYNC

	; Left side.
        lda #%01010000  ; 2
        sta PF0         ; 4
        lda #%11101001  ; 2
        sta PF1         ; 4
        lda #%11101110  ; 2
        sta PF2         ; 4

        ; Delay before writing right side.
        SLEEP 10
        ldy #0          ; 2
        sty PF0         ; 4

	ldy P0Score             ; 2
        lda NumbersLine4,y      ; 4/5 Load approriate scanline of score number.
	sta PF1         ; 4

	SLEEP 8
        ldy #0          ; 2
        sty PF2         ; 4 Clear PF

	sta WSYNC

	lda #0		; 2
	sta PF0
	sta PF1         ; 4
	sta PF2

	sta WSYNC		; 4
	sta WSYNC

ScoreSectionEND


	lda #%01000010
	sta VBLANK ; end of screen - enter blanking

; Overscan
	ldx #0
Overscan
	sta WSYNC
	inx
	cpx #29
	bne Overscan
	
	lda #$D4
	sta COLUBK

	lda #0
	sta PF0
	sta PF1
	sta PF2
	sta GRP0
	
	sta WSYNC ; Overscan #30

	jmp StartOfFrame

;;;;
; Subroutines
;;;;

; Horizonal object positioning.
; Input: X - X position of P0.
; Y - object to position. 0 = Player 0 1 = Player 1 2 = Missile 0 3 = Missile 1 4 = Ball
; The subroutine wastes the appropriate amount of cycles (the loop == 5 cycles, which == 15 TIA color clocks),
; then hits the RESP0 strobe at the appropriate cycle to set X position of P0.
PosObject
	sta WSYNC		; 00 Sync to next scanline.
	lda DivideBy15,x  	; x / 15 - This is the number of cycles that need to be wasted.
	tax
WaitLoop	dex		; Kill some time.
	bne WaitLoop
	sta RESP0,y 		; Draw sprite for P0 at proper cyvle..
	rts

;;;;
; Data tables
;;;;

; This lookup table will give the result of a division by
; 15 of the index value supplied to it.
DivideBy15
.POS	SET 0
	REPEAT 160			; There are 160 visible color clocks, so that's the most we'll ever need to lookup.
	.byte (.POS / 15) + 1
.POS	SET .POS + 1
	REPEND

; This defines which pixels are on for each scanline of the P0 sprite.
SpriteP0
	.byte %01000000
	.byte %01100000
	.byte %01110000
	.byte %11111000
	.byte %11111111
	.byte %11111111
	.byte %11111000
	.byte %01110000
	.byte %01100000
	.byte %01000000

; All 2 digit numbers 00-99.
; 5 bytes height each.
; Using ROM space to save cycles.
NumbersLine0
	.byte %01000010
	.byte %01000110
	.byte %01000111
	.byte %01000111
	.byte %01000101
	.byte %01000111
	.byte %01000111
	.byte %01000111
	.byte %01000111
	.byte %01000111
	.byte %11000010
	.byte %11000110
	.byte %11000111
	.byte %11000111
	.byte %11000101
	.byte %11000111
	.byte %11000111
	.byte %11000111
	.byte %11000111
	.byte %11000111
	.byte %11100010
	.byte %11100110
	.byte %11100111
	.byte %11100111
	.byte %11100101
	.byte %11100111
	.byte %11100111
	.byte %11100111
	.byte %11100111
	.byte %11100111
	.byte %11100010
	.byte %11100110
	.byte %11100111
	.byte %11100111
	.byte %11100101
	.byte %11100111
	.byte %11100111
	.byte %11100111
	.byte %11100111
	.byte %11100111
	.byte %10100010
	.byte %10100110
	.byte %10100111
	.byte %10100111
	.byte %10100101
	.byte %10100111
	.byte %10100111
	.byte %10100111
	.byte %10100111
	.byte %10100111
	.byte %11100010
	.byte %11100110
	.byte %11100111
	.byte %11100111
	.byte %11100101
	.byte %11100111
	.byte %11100111
	.byte %11100111
	.byte %11100111
	.byte %11100111
	.byte %11100010
	.byte %11100110
	.byte %11100111
	.byte %11100111
	.byte %11100101
	.byte %11100111
	.byte %11100111
	.byte %11100111
	.byte %11100111
	.byte %11100111
	.byte %11100010
	.byte %11100110
	.byte %11100111
	.byte %11100111
	.byte %11100101
	.byte %11100111
	.byte %11100111
	.byte %11100111
	.byte %11100111
	.byte %11100111
	.byte %11100010
	.byte %11100110
	.byte %11100111
	.byte %11100111
	.byte %11100101
	.byte %11100111
	.byte %11100111
	.byte %11100111
	.byte %11100111
	.byte %11100111
	.byte %11100010
	.byte %11100110
	.byte %11100111
	.byte %11100111
	.byte %11100101
	.byte %11100111
	.byte %11100111
	.byte %11100111
	.byte %11100111
	.byte %11100111
NumbersLine1
	.byte %10100101
	.byte %10100010
	.byte %10100001
	.byte %10100001
	.byte %10100101
	.byte %10100100
	.byte %10100100
	.byte %10100001
	.byte %10100101
	.byte %10100101
	.byte %01000101
	.byte %01000010
	.byte %01000001
	.byte %01000001
	.byte %01000101
	.byte %01000100
	.byte %01000100
	.byte %01000001
	.byte %01000101
	.byte %01000101
	.byte %00100101
	.byte %00100010
	.byte %00100001
	.byte %00100001
	.byte %00100101
	.byte %00100100
	.byte %00100100
	.byte %00100001
	.byte %00100101
	.byte %00100101
	.byte %00100101
	.byte %00100010
	.byte %00100001
	.byte %00100001
	.byte %00100101
	.byte %00100100
	.byte %00100100
	.byte %00100001
	.byte %00100101
	.byte %00100101
	.byte %10100101
	.byte %10100010
	.byte %10100001
	.byte %10100001
	.byte %10100101
	.byte %10100100
	.byte %10100100
	.byte %10100001
	.byte %10100101
	.byte %10100101
	.byte %10000101
	.byte %10000010
	.byte %10000001
	.byte %10000001
	.byte %10000101
	.byte %10000100
	.byte %10000100
	.byte %10000001
	.byte %10000101
	.byte %10000101
	.byte %10000101
	.byte %10000010
	.byte %10000001
	.byte %10000001
	.byte %10000101
	.byte %10000100
	.byte %10000100
	.byte %10000001
	.byte %10000101
	.byte %10000101
	.byte %00100101
	.byte %00100010
	.byte %00100001
	.byte %00100001
	.byte %00100101
	.byte %00100100
	.byte %00100100
	.byte %00100001
	.byte %00100101
	.byte %00100101
	.byte %10100101
	.byte %10100010
	.byte %10100001
	.byte %10100001
	.byte %10100101
	.byte %10100100
	.byte %10100100
	.byte %10100001
	.byte %10100101
	.byte %10100101
	.byte %10100101
	.byte %10100010
	.byte %10100001
	.byte %10100001
	.byte %10100101
	.byte %10100100
	.byte %10100100
	.byte %10100001
	.byte %10100101
	.byte %10100101
NumbersLine2
	.byte %10100101
	.byte %10100010
	.byte %10100111
	.byte %10100111
	.byte %10100111
	.byte %10100111
	.byte %10100111
	.byte %10100010
	.byte %10100111
	.byte %10100111
	.byte %01000101
	.byte %01000010
	.byte %01000111
	.byte %01000111
	.byte %01000111
	.byte %01000111
	.byte %01000111
	.byte %01000010
	.byte %01000111
	.byte %01000111
	.byte %11100101
	.byte %11100010
	.byte %11100111
	.byte %11100111
	.byte %11100111
	.byte %11100111
	.byte %11100111
	.byte %11100010
	.byte %11100111
	.byte %11100111
	.byte %11100101
	.byte %11100010
	.byte %11100111
	.byte %11100111
	.byte %11100111
	.byte %11100111
	.byte %11100111
	.byte %11100010
	.byte %11100111
	.byte %11100111
	.byte %11100101
	.byte %11100010
	.byte %11100111
	.byte %11100111
	.byte %11100111
	.byte %11100111
	.byte %11100111
	.byte %11100010
	.byte %11100111
	.byte %11100111
	.byte %11100101
	.byte %11100010
	.byte %11100111
	.byte %11100111
	.byte %11100111
	.byte %11100111
	.byte %11100111
	.byte %11100010
	.byte %11100111
	.byte %11100111
	.byte %11100101
	.byte %11100010
	.byte %11100111
	.byte %11100111
	.byte %11100111
	.byte %11100111
	.byte %11100111
	.byte %11100010
	.byte %11100111
	.byte %11100111
	.byte %01000101
	.byte %01000010
	.byte %01000111
	.byte %01000111
	.byte %01000111
	.byte %01000111
	.byte %01000111
	.byte %01000010
	.byte %01000111
	.byte %01000111
	.byte %11100101
	.byte %11100010
	.byte %11100111
	.byte %11100111
	.byte %11100111
	.byte %11100111
	.byte %11100111
	.byte %11100010
	.byte %11100111
	.byte %11100111
	.byte %11100101
	.byte %11100010
	.byte %11100111
	.byte %11100111
	.byte %11100111
	.byte %11100111
	.byte %11100111
	.byte %11100010
	.byte %11100111
	.byte %11100111
NumbersLine3
	.byte %10100101
	.byte %10100010
	.byte %10100100
	.byte %10100001
	.byte %10100001
	.byte %10100001
	.byte %10100101
	.byte %10100010
	.byte %10100101
	.byte %10100001
	.byte %01000101
	.byte %01000010
	.byte %01000100
	.byte %01000001
	.byte %01000001
	.byte %01000001
	.byte %01000101
	.byte %01000010
	.byte %01000101
	.byte %01000001
	.byte %10000101
	.byte %10000010
	.byte %10000100
	.byte %10000001
	.byte %10000001
	.byte %10000001
	.byte %10000101
	.byte %10000010
	.byte %10000101
	.byte %10000001
	.byte %00100101
	.byte %00100010
	.byte %00100100
	.byte %00100001
	.byte %00100001
	.byte %00100001
	.byte %00100101
	.byte %00100010
	.byte %00100101
	.byte %00100001
	.byte %00100101
	.byte %00100010
	.byte %00100100
	.byte %00100001
	.byte %00100001
	.byte %00100001
	.byte %00100101
	.byte %00100010
	.byte %00100101
	.byte %00100001
	.byte %00100101
	.byte %00100010
	.byte %00100100
	.byte %00100001
	.byte %00100001
	.byte %00100001
	.byte %00100101
	.byte %00100010
	.byte %00100101
	.byte %00100001
	.byte %10100101
	.byte %10100010
	.byte %10100100
	.byte %10100001
	.byte %10100001
	.byte %10100001
	.byte %10100101
	.byte %10100010
	.byte %10100101
	.byte %10100001
	.byte %01000101
	.byte %01000010
	.byte %01000100
	.byte %01000001
	.byte %01000001
	.byte %01000001
	.byte %01000101
	.byte %01000010
	.byte %01000101
	.byte %01000001
	.byte %10100101
	.byte %10100010
	.byte %10100100
	.byte %10100001
	.byte %10100001
	.byte %10100001
	.byte %10100101
	.byte %10100010
	.byte %10100101
	.byte %10100001
	.byte %00100101
	.byte %00100010
	.byte %00100100
	.byte %00100001
	.byte %00100001
	.byte %00100001
	.byte %00100101
	.byte %00100010
	.byte %00100101
	.byte %00100001
NumbersLine4
	.byte %01000010
	.byte %01000111
	.byte %01000111
	.byte %01000111
	.byte %01000001
	.byte %01000111
	.byte %01000111
	.byte %01000010
	.byte %01000111
	.byte %01000111
	.byte %11100010
	.byte %11100111
	.byte %11100111
	.byte %11100111
	.byte %11100001
	.byte %11100111
	.byte %11100111
	.byte %11100010
	.byte %11100111
	.byte %11100111
	.byte %11100010
	.byte %11100111
	.byte %11100111
	.byte %11100111
	.byte %11100001
	.byte %11100111
	.byte %11100111
	.byte %11100010
	.byte %11100111
	.byte %11100111
	.byte %11100010
	.byte %11100111
	.byte %11100111
	.byte %11100111
	.byte %11100001
	.byte %11100111
	.byte %11100111
	.byte %11100010
	.byte %11100111
	.byte %11100111
	.byte %00100010
	.byte %00100111
	.byte %00100111
	.byte %00100111
	.byte %00100001
	.byte %00100111
	.byte %00100111
	.byte %00100010
	.byte %00100111
	.byte %00100111
	.byte %11100010
	.byte %11100111
	.byte %11100111
	.byte %11100111
	.byte %11100001
	.byte %11100111
	.byte %11100111
	.byte %11100010
	.byte %11100111
	.byte %11100111
	.byte %11100010
	.byte %11100111
	.byte %11100111
	.byte %11100111
	.byte %11100001
	.byte %11100111
	.byte %11100111
	.byte %11100010
	.byte %11100111
	.byte %11100111
	.byte %01000010
	.byte %01000111
	.byte %01000111
	.byte %01000111
	.byte %01000001
	.byte %01000111
	.byte %01000111
	.byte %01000010
	.byte %01000111
	.byte %01000111
	.byte %11100010
	.byte %11100111
	.byte %11100111
	.byte %11100111
	.byte %11100001
	.byte %11100111
	.byte %11100111
	.byte %11100010
	.byte %11100111
	.byte %11100111
	.byte %11100010
	.byte %11100111
	.byte %11100111
	.byte %11100111
	.byte %11100001
	.byte %11100111
	.byte %11100111
	.byte %11100010
	.byte %11100111
	.byte %11100111

; Make ROM loadable by the 2600.
	ORG $FFFA

InterruptVectors
	.word Reset           ; NMI
	.word Reset           ; RESET
	.word Reset           ; IRQ

	END
