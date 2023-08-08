.include "labels.s"
.include "header.s"
.segment "PRG"

.macro stp
	.byte $22
.endmacro

.macro lxa0
	; LXA is predictable/stable when operand is zero
	.byte $ab, 0
.endmacro

CHR:
	.incbin "chr/chr.chr"

Palette:
	.byte $0f, $16, $1a 
	; Last color in CreateApple code


CreateApple:
	.byte $a0 ; LDY # and palette color
	.byte 8 ; value to load Y with

	lda RNGData
	:
		asl
		rol RNGData+1
		bcc :+
		eor #$39
	:
		dey
		bne :--
		sta RNGData
	sta ApplePos
	lda RNGData+1
	and #$03
	ora #$04
	sta ApplePos+1
	lda (ApplePos),y
	bne CreateApple
	lda ApplePos+1
	cmp #$07
	bne :+
	lda ApplePos
	cmp #$c0
	bcs CreateApple
	:
	lda ApplePos+1
	ora #$20
	sta PpuAddr_2006
	lda ApplePos
	sta PpuAddr_2006
	lda #$01
	sta PpuData_2007
	sta (ApplePos),y
	rts

Reset:
	sei
	cld
	lxa0
	tay
	stx PpuControl_2000
	stx PpuAddr_2006
	stx PpuAddr_2006
	stx PpuMask_2001
	ClearRAMLoop:
		; Don't use zeropage addressing so page boundary will be crossed rather than accessing RNG data and so $100-$10f is cleared
		sta $810,x
		lda CHR,x
		sta $110,x
		lda #0
		; $200-$3ff unused
		sta $400,x
		sta $500,x
		sta $600,x
		sta $6c0,x ; Don't clear $7c0-$7ff so snake will run into edge of screen
		:
		sta PpuData_2007
		inx
		bne ClearRAMLoop
		iny
		bpl :-
	sta PpuAddr_2006
	sta PpuAddr_2006
	ldy #$10
	sty GamePaused
	:
		lda $100,x
		sta PpuData_2007
		inx
		bne :-
		dey
		bne :-
	lda #$3f
	sta PpuAddr_2006
	stx PpuAddr_2006
	:
		lda Palette,x
		sta PpuData_2007
		inx
		cpx #4
		bne :-
	stx BlacklistedInputs
	stx FrameCounter
	ror
	sta PpuControl_2000
	lda #%00001010
	sta PpuMask_2001
	
	:
		bit PpuStatus_2002
		bpl :-

	lda #$25
	sta PpuAddr_2006
	and #$1f
	sta SnakeHeadPos+1
	lda #$af
	sta PpuAddr_2006
	sta SnakeHeadPos
	lda #$15
	sta PpuData_2007
	sta $5af
	lda #$25
	sta PpuAddr_2006
	and #$1f
	sta SnakeTailPos+1
	lda #$cf
	sta PpuAddr_2006
	sta SnakeTailPos
	lda #$17
	sta PpuData_2007
	sta $5cf

	inc SnakeDirection

	jsr CreateApple

	jsr AfterPauseCode-1

Main:
	nop
	nop
	bvc Main

NMI:
	; Controller reading
	lda #1
	sta Ctrl1_4016
	sta ControllerInputs
	lsr
	sta Ctrl1_4016
	:
		lda Ctrl1_4016
		lsr
		rol ControllerInputs
		bcc :-

	bne :+
	sty AllowPauseViaStartButton
	:

	lda BlacklistedInputs
	eor #$ff
	and ControllerInputs
	sta ControllerInputs

	and #$ef
	beq :+
	sty GamePaused
	:

	; Update pause flag
	lda AllowPauseViaStartButton
	bne :+
	lda ControllerInputs
	and #$10
	beq :+
	inc AllowPauseViaStartButton
	eor GamePaused
	sta GamePaused
	:
	

	; Update snake direction
	lax ControllerInputs

	and DPad_Left
	beq :+
	lda DPad_Right
	sta BlacklistedInputs
	sty SnakeDirection
	:

	txa
	and DPad_Up
	beq :+
	lda DPad_Down
	sta BlacklistedInputs
	lda #1
	sta SnakeDirection
	:

	txa
	and DPad_Right
	beq :+
	lda DPad_Left
	sta BlacklistedInputs
	lda #2
	sta SnakeDirection
	:

	txa
	and DPad_Down
	beq :+
	lda DPad_Up
	sta BlacklistedInputs
	lda #3
	sta SnakeDirection
	:

	; Frame counter/pause flag
	@RTI1:
	lda GamePaused
	bne @RTI1+1
	dec FrameCounter
	bne @RTI1+1
	lda #12
	sta FrameCounter

	AfterPauseCode:


	; Move snake
	lda SnakeHeadPos
	sta LastSnakeHeadPos
	lda SnakeHeadPos+1
	sta LastSnakeHeadPos+1
	lda IncrementTailLength
	beq :+
	lda SnakeTailPos
	sta LastSnakeTailPos
	lda SnakeTailPos+1
	sta LastSnakeTailPos+1
	:
	; Move head
	ldx SnakeDirection
	cpx #2
	bcc :+
	lda SnakePosHeadMoveLoBytes,x
	clc
	adc SnakeHeadPos
	sta SnakeHeadPos
	bcc :++
	inc SnakeHeadPos+1
	bne :++
	:
	lda SnakeHeadPos
	sec
	sbc SnakePosHeadMoveLoBytes,x
	sta SnakeHeadPos
	bcs :+
	dec SnakeHeadPos+1
	:
	; Move tail
	lda IncrementTailLength
	beq :++
	lda (SnakeTailPos),y
	lsr
	lsr
	lsr
	lsr
	tax
	cpx #2
	bcc :+
	lda SnakePosTailMoveLoBytes,x
	clc
	adc SnakeTailPos
	sta SnakeTailPos
	bcc :++
	inc SnakeTailPos+1
	bne :++
	:
	lda SnakeTailPos
	sec
	sbc SnakePosTailMoveLoBytes,x
	sta SnakeTailPos
	bcs :+
	dec SnakeTailPos+1
	:

	; Prevent screen wrap
	; Left
	lda LastSnakeHeadPos
	and #$1f
	bne :+
	lda SnakeHeadPos
	and #$1f
	cmp #$1f
	beq GameOver
	:
	; Right
	lda LastSnakeHeadPos
	and #$1f
	cmp #$1f
	bne :+
	lda SnakeHeadPos
	and #$1f
	beq GameOver
	:
	; Don't need to check top or bottom screen wrap, since there will be garbage data there anyway


	lda #1
	sta IncrementTailLength

	; Draw snake positions
	lda (SnakeHeadPos),y
	cmp #$01
	bne :+
	jsr CreateApple
	dec IncrementTailLength
	:
	cmp #$02
	bcc :+
	; Game over
	GameOver:
		lda #$3f
		sta PpuAddr_2006
		lda #$03
		sta PpuAddr_2006
		lda #$16
		sta PpuData_2007
		lda #$20
		sta PpuAddr_2006
		sty PpuAddr_2006
		stp
	:
	; Draw snake head
	; Head
	lda SnakeDirection
	asl
	asl
	asl
	asl
	ora SnakeDirection
	clc
	adc #$4
	sta (SnakeHeadPos),y
	; Tile behind head
	lda (LastSnakeHeadPos),y
	and #$f0
	asl
	asl
	asl
	ora SnakeDirection
	rol
	rol
	tax
	lda NextSnakeTileData,x
	sta (LastSnakeHeadPos),y

	lda IncrementTailLength
	beq :+
	; Tile behind tail
	lda #0
	sta (LastSnakeTailPos),y
	; Tail
	lda (SnakeTailPos),y
	and #$f0
	sta Temp_SnakeTailDirection
	lsr
	lsr
	lsr
	lsr
	tax
	lda SnakeDirectionInvert,x
	clc
	adc #$04
	ora Temp_SnakeTailDirection
	sta (SnakeTailPos),y
	:

	; Draw tiles
	lda LastSnakeHeadPos+1
	ora #$20
	sta PpuAddr_2006
	lda LastSnakeHeadPos
	sta PpuAddr_2006
	lda (LastSnakeHeadPos),y
	sta PpuData_2007
	lda SnakeHeadPos+1
	ora #$20
	sta PpuAddr_2006
	lda SnakeHeadPos
	sta PpuAddr_2006
	lda (SnakeHeadPos),y
	sta PpuData_2007
	lda LastSnakeTailPos+1
	ora #$20
	sta PpuAddr_2006
	lda LastSnakeTailPos
	sta PpuAddr_2006
	lda (LastSnakeTailPos),y
	sta PpuData_2007
	lda SnakeTailPos+1
	ora #$20
	sta PpuAddr_2006
	lda SnakeTailPos
	sta PpuAddr_2006
	lda (SnakeTailPos),y
	sta PpuData_2007
	
	
	; Set scroll
	sty PpuScroll_2005
	sty PpuScroll_2005

IRQ:
	rti

SnakePosHeadMoveLoBytes:
SnakePosTailMoveLoBytes:
	.byte $01, $20, $01, $20

SnakeTailTiles:
	.byte $13, $02, $31, $20
SnakeDirectionInvert:
	.byte $02, $03, $00, $01


NextSnakeTileData:
	; New Direction: Left
	; Previous Directions:
		; Left
		.byte $02
		; Up
		.byte $09
		; Right
		.byte $02
		; Down
		.byte $08
	; New Direction: Up
	; Previous Directions:
		; Left
		.byte $1a
		; Up
		.byte $13
		; Right
		.byte $18
		; Down
		.byte $13
	; New Direction: Right
	; Previous Direction:
		; Left
		.byte $22
		; Up
		.byte $2b
		; Right
		.byte $22
		; Down
		.byte $2a
	; New Direction: Down
	; Previous Directions:
		; Left
		.byte $3b
		; Up
		.byte $33
		; Right
		.byte $39
		; Down
		.byte $33

.segment "VECTORS"
	.addr NMI
	.addr Reset
	.addr IRQ
