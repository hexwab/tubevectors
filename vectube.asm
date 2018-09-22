CPU 1
ORG $900

x = $00
y = $01
frame = $02
effptr = $03

osfile = $FFDD
osbyte = $FFF4
wordv = $20C
	
.tubestart
{
	lda #$EA
	ldx #0
	ldy #$FF
	jsr osbyte
	cpx #0
	bne ok
	brk
	equb 0
	equs "No Tube :("
	equb 0
.ok
	ldx #<fileblk
	ldy #>fileblk
	lda #$FF
	jsr osfile
        lda #<init
        jsr osword_06
	inc param
        lda #>init
        jsr osword_06
        lda #&88
	jsr $FFF4
	sei
.main
	stz frame
	stz effptr
.neweff
	ldx effptr
	lda efftab,X
	sta effect+1
	lda efftab+1,X
	sta effect+2
.loop
	lda #scry-1
	sta y
.yloop
	lda #scrx-1
	sta x
.xloop
.effect
	jmp $FFFF
.resume
	lda multab16,X
.wrch
	bit $FEF8 ; Read Tube R1 status
	bvc wrch  ; loop until b6 set
	sta $FEF9

	dec x
	bpl xloop
	dec y
	bpl yloop
	inc frame
	bne loop
	lda effptr
	ina
	ina
	cmp #efftabend-efftab
	bne nocarry
	lda #0
.nocarry
	sta effptr
	bra neweff

.spin
	lda frame
	rol a
	tax
	jmp resume
.sweep
	clc
	lda x
	eor y
	asl a
	asl a
	asl a
	asl a
	clc
	adc x
	adc y
	sbc frame
	sbc frame
	tax
	jmp resume
.balls
	clc
	ldx y
	lda sqrtab+(scrx-scry)/2,X
	ldx x
	adc sqrtab,X
	adc frame
	adc frame
	tax
	jmp resume
.expand
	clc
	ldx y
	lda abstab+(scrx-scry)/2,X
	ldx x
	adc abstab,X
	lsr a
	sec
	sbc frame
	sbc frame
	tax
	jmp resume
	
.sqrtab
FOR n,0,31,1
	EQUB (n-16)*(n-16)-1
NEXT
.abstab	
FOR n,0,31,1
	EQUB ABS(n-16)
NEXT
	
.efftab
	EQUW spin
	EQUW sweep
	EQUW balls
	EQUW expand
.efftabend

.multab16
FOR n,0,255,1
	EQUB ((n DIV 2)MOD 16)*7
NEXT

;; Write a byte to host memory
.osword_06
        sta param+4
        lda #6
        ldx #<param
        ldy #>param
        jmp (wordv)

.param
        EQUB 0,2,0,0,0
.fileblk
	EQUW filename
	EQUW start
	EQUW -1
	EQUB 0
.filename
	EQUS "vectors"
	EQUB 13
}
.tubeend
SAVE "vectube", tubestart, tubeend
