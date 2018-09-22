tab = 0
scrx = 30
scry = 22
borderx = 2
bordery = 2
totalx = scrx+borderx*2	
totaly = scry+bordery*2
linelen = totalx*8
scr = $100
scrstart = scr+borderx*8+bordery*linelen
	;; 30*22*(56+4) = 39600 cycles
screensize = (totalx*totaly*8)

ORG	$100+screensize-$e0
GUARD	$8000
.start
{
.vectab
	equb $00,$00,$00,$fe,$00,$00,$00
	equb $00,$00,$00,$1E,$e0,$00,$00
	equb $00,$00,$0e,$30,$c0,$00,$00
	equb $00,$02,$0c,$10,$20,$c0,$00
	equb $02,$04,$08,$10,$20,$40,$80
	equb $04,$08,$08,$10,$20,$40,$40
	equb $08,$08,$08,$10,$10,$20,$20
	equb $10,$10,$10,$10,$20,$20,$20
	equb $10,$10,$10,$10,$10,$10,$10
	equb $20,$20,$20,$10,$10,$10,$10
	equb $20,$20,$20,$10,$10,$08,$08
	equb $80,$40,$40,$20,$10,$08,$08
	equb $80,$40,$20,$10,$08,$04,$02
	equb $00,$00,$c0,$20,$10,$0c,$02
	equb $00,$00,$c0,$30,$0e,$00,$00
	equb $00,$00,$00,$e0,$1e,$00,$00
.vecend
.crtctab
	equb 63, totalx, 29+totalx/2, 36
	equb 38, 1, totaly, 19+totaly/2
	equb 0, 7, 0, 0
	equb 0, 32
.pal0
	equb $80,$90,$a0,$b0,$c0,$d0,$e0,$f0
	equb $0f,$1f,$2f,$3f,$4f,$5f,$6f,$7f
.pal1
	equb $00,$10,$20,$30,$40,$50,$60,$70
	equb $8f,$9f,$af,$bf,$cf,$df,$ef,$ff
.*init
	sei
	sta $FEE3 ; ack
	lda #$08
	sta $FE20
	ldx #15
.palloop
	lda pal1,X
	sta $FE21
	dex
	bpl palloop
	ldx #13
	sta $FEE3
.crtcloop
	lda crtctab,X
	stx $FE00
	sta $FE01
	dex
	bpl crtcloop
.copy
	ldx #vecend-vectab-1
.copyloop
	lda vectab,X
	sta 0,X
	dex
	bpl copyloop
.zero
	lda #0
	ldx #0
.zeroloop
	sta $100*>(scr+screensize-$100),X
	dex
	bne zeroloop
	dec zeroloop+2
	bne zeroloop
	sta $100*>(scr+screensize)
IF screensize MOD 256	
	ldx #<screensize-1
.zeroloop2
	sta $100*>(scr+screensize),X
	dex
	bne zeroloop2
ENDIF
	; and we're go!
	; this returns control to the copro
	sta $FEE3
.vsync
	lda #2
.vsync1
	bit &FE4D
	beq vsync1 ; wait for vsync
.main
FOR y,0,scry-1,1
FOR x,0,scrx-1,1
	ldx $FEE1
FOR l,0,6,1
	lda tab+l,X
	sta scrstart+x*8+y*linelen+l
NEXT
NEXT
NEXT	
	jmp vsync
}
.end

SAVE "vectors", start, end
INCLUDE "vectube.asm"
PUTBASIC "rotate.bas","rotate"
