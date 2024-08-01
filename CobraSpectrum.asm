; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
; Cobra - 48K Spectrum.
;
; Design, Code, Art and Plip Plop programming by Jonathan Smith.
; Musical Scores by Martin Galway.
;
; Reverse Engineered by Paul "Paulie" Hughes July, 2024.
;
; SpectrumAnalyser https://colourclash.co.uk/spectrum-analyser/
;
;
;

	device zxspectrum48

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
; Sprite data structure
;

TYP:					equ		0				; sprite type index  (0 = inactive)
XNO:					equ		1				; x coord
YNO:					equ		2				; y coord
GNO:					equ		3				; graphic index
XSPD:					equ		4				; x velocity
CNT1:					equ		5				; general purpose counter 1
CNT2:					equ		6				; general purpose counter 2

SPVARLEN:				equ		CNT2+1			; length of sprite data

;
; sprite type indexes - TYP
;

T_PirateGuyMove:		equ $00 
T_KnifeGuyMove: 		equ $01 
T_PirateGuyJiggle:		equ $02 
T_Pram:					equ $03 	
T_BazookaLadyMove:		equ $04 
T_BazookaLadyFire:		equ $05 
T_KnifeGuyWait:			equ $06 
T_NightSlasher:			equ $07 
T_MissileUp:			equ $08 
T_MIssileDown:			equ $09 
T_MoveObject:			equ $0a 
T_Explosion:			equ $0b 
T_DoNothing:			equ $0c 
T_DoDrop:				equ $0d 
T_GirlfriendOn:			equ $0e 
T_GirlfriendFollow:		equ $0f 
T_GirlfriendOff:		equ $10 
T_MoveOffScreenQuick:	equ $11 

;
; Sprite Graphic Numbers "GNO" (indexes into SpriteGFXTable)
;
; Baddy Sprites and projectiles are in pairs facing left (even GNO) and then right (odd GNO) 
; Player Sprites are also in pairs, but, facing right (even GNO) and then facing left (odd GNO)
;


G_PlayerWalk:  			equ $00 
G_PlayerJump:  			equ $02 
G_PlayerDuck:  			equ $04 
G_Knife:        		equ $06 
G_Pistol:       		equ $08 
G_MachineGun:  			equ $0a 
G_Headbutt:     		equ $0c 
G_Girlfriend:   		equ $0e 
G_PirateGuy:   			equ $10 
G_KnifeGuy:    			equ $12 
G_Pram:         		equ $14 
G_BazookaLady: 			equ $16 
G_NightSlasher:			equ $18 
G_Explosion:    		equ $1a 
G_Burger:       		equ $1b 
G_Missile:      		equ $1c 

;
; Variable Offsets to Variables+NN and IY+NN)
;

V_SCRNX:							EQU $00	; <
V_SCRNY:							EQU $01	; <
V_DIRECT:							EQU $02	; <
V_SYSFLAG							EQU $03	; < Used by Sprint
V_TABXPOS:							EQU $04	; <
V_ATTR:								EQU $05	; <
V_CHARS:							EQU $06	; <
V_HIGH:								EQU $08	; <
V_FUDLR:							EQU $09	
V_LASTPLAYERDIR:					EQU $0a	
V_HEADBUTTCOUNTER:					EQU $0b	
V_PLAYERINAIR:						EQU $0c	
V_PLAYERJUMPFALLINDEX:				EQU $0d	
V_PLAYERJUMPFALLYSTART:				EQU $0e	
V_PLAYERWEAPON:						EQU $0f	
V_PLAYERWEAPONINFLIGHT:				EQU $10	
V_KNIFEYINDEX:						EQU $11	
V_KNIFEYSTART:						EQU $12	
V_BULLETFIREDELAY:					EQU $13	
V_PLAYERFIREJIGGLE:					EQU $14	
V_STARINDEX:						EQU $16	
V_STARUPDATEDELAY:					EQU $17	
V_DUCKON:							EQU $18	
V_FRAMECOUNTER:						EQU $19	
V_FIREDEBOUNCE:						EQU $1a	
V_INVULNERABLECOUNT:				EQU $1b	
V_GIRLFRIENDONSCREEN:				EQU $1e	
V_GIRLFRIENDISLEAVING:				EQU $1f	
V_PROJECTILEFIREDELAYCOUNTER:		EQU $20	
V_STUNNEDCOUNTER:					EQU $21	
V_GIRLFRIENDSTATUS:					EQU $22	
V_PLAYERLOSTLIFE:					EQU $23	
V_GIRLFRIENDFOUNDPLAYER:			EQU $24	
V_ALLBADDIESKILLED:					EQU $25	
V_LEVELENDCOUNTDOWN:				EQU $26	
V_NIGHTSLASHERFLAG:					EQU $27	
V_NUMLIVES:							EQU $28	
V_COLOURMONOFLAG:					EQU $29	
V_SOUNDSMUTEFLAG:					EQU $2a	
V_PROJECTILESPEED:					EQU $2b	
V_BURGERWEAPONADJUST:				EQU $2c	
V_ROUNDNUMBER:						EQU $2d	
V_PROJECTILEFIREDELAY:				EQU $2e	
V_CONTROLMETHOD:					EQU $2f	
V_RND1:								EQU $30	
V_RND2:								EQU $31	
V_RND3:								EQU $32	
V_GIRLFRIENDENTERX:					EQU $33	
V_BURGERCOUNT:						EQU $34	
V_INITIALGIRLFRIENDCOUNTDOWN:		EQU $35	
V_GIRLFRIENDCOUNTDOWN:				EQU $37	
V_RANDOMNUMMASK:					EQU $39	

;
; Player weapon types
;

WEAPON_HEADBUTT:					equ 0
WEAPON_KNIFE:						equ 1
WEAPON_PISTOL:						equ 2
WEAPON_MACHINEGUN:					equ 3


;
; "Sprint" commands
;

AT:		EQU $00
DIR:	EQU $01
MOD:	EQU $02
TAB:	EQU $03
REP:	EQU $04
PEN:	EQU $05
CHR:	EQU $06
RSET:	EQU $07
JSR:	EQU $08
JSRS:	EQU $09
CLS:	EQU $0a
CLA:	EQU $0b
EXPD:	EQU $0c
RTN:	EQU $0d
CUR:	EQU $0e
FOR:	EQU $0f
NEXT:	EQU $10
TABX:	EQU $11
XTO:	EQU $12
YTO:	EQU $13
EXOFF:	EQU $14

UP:			EQU 0
UP_RI:		EQU 1
RI:			EQU 2
DW_RI:		EQU 3
DW:			EQU 4
DW_LE:		EQU 5
LE:			EQU 6
UP_LE:		EQU 7

S:			EQU 128
B:			EQU 64

EXPN:		EQU 1
NINK:		EQU 255

NORM:		equ 	0
OVER:		equ 	1
ORON:		equ 	2
INVR:		equ 	3

FIN:		equ 	$ff

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

INTJUMP		EQU 	$FFF5

SYSBorder 	equ 	0x5C48			; Used by ROM beeper!
ROM_BEEPER	equ		0x03b5

SCRNADDR:	equ		0x4000				; screen
ATTRADDR:	equ		0x5800				; attributes

BRIGHT:		equ		0x40				; colour attributes
FLASH:		equ		0x80
PAPER:		equ		0x8					; multply with inks to get paper colour
WHITE:		equ		0x7					; ink colours
YELLOW:		equ		0x6
CYAN:		equ		0x5
GREEN:		equ		0x4
MAGENTA:	equ		0x3
RED:		equ		0x2
BLUE:		equ		0x1
BLACK:		equ		0x0


; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

	org  $5B00

	disp MapBuffer	;assemble as if located in MapBuffer memory ($8000)

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
; Music player stored up in contended memory but assembled as if at $8000 (the MapBuffer)
; as the code is swapped in, in order to play the two channel music.
;

YES 			EQU $3C		; Code for "play music that can be interrupted by a keypress"
NO				EQU $AF		; Code for play music until it ends.
	
NL             	EQU  40		; Number of notes
PP_JSR          EQU  00*2+NL
PP_JMP          EQU  01*2+NL
PP_JSRS         EQU  02*2+NL
PP_FOR          EQU  03*2+NL
PP_NEXT         EQU  04*2+NL
PP_SDRUM        EQU  05*2+NL
PP_PBEND        EQU  06*2+NL
PP_CALL        	EQU  07*2+NL	
	
PP_GOSUB        EQU  00*2+128
PP_GOTO         EQU  01*2+128
PP_FORD         EQU  02*2+128
PP_NEXD         EQU  03*2+128
PP_RTSD         EQU  04*2+128
PP_END          EQU  05*2+128

PP_RTS          EQU  255
	
	
PlipPlopPlayerStart:
					; Notes table (40 notes $28)
	dw $0000
	dw $0279
	dw $0255
	dw $0234
	dw $0214
	dw $01F6
	dw $01DA
	dw $01BF
	dw $01A6
	dw $018F
	dw $0178
	dw $0163
	dw $014F
	dw $013C
	dw $012B
	dw $011A
	dw $010A
	dw $00FB
	dw $00ED
	dw $00E0
	dw $00D3
	dw $00C7
	dw $00BC 
	dw $00B2 
	dw $00A8 
	dw $009E 
	dw $0095 
	dw $008D 
	dw $0085 
	dw $007E 
	dw $0076 
	dw $0070 
	dw $006A 
	dw $0064 
	dw $005E 
	dw $0059 
	dw $0054 
	dw $004F 
	dw $004B 
	dw $0046 
	dw $0043 
	dw $003F 

MusicRoutines:
	dw JSR_
	dw JMP_
	dw JSRS_
	dw FOR_
	dw NEXT_
	dw SDRUM_
	dw PBEND_
	dw CALLFUNC_

DrumRoutines:
	dw GOSUB_
	dw GOTO_
	dw FORDUM_
	dw NEXTDRUM_
	dw GetDrumStack
	dw END_

DrumTypeRoutines:
	dw TOM2_
	dw SNARE_
	dw BASS_
	dw TOM1_

; first byte of each tuple is either $3c (inc a) or $af (dec a) which sets whether
; a keypress interrupts the tune or not.

TuneTable:			
	db YES 
	dw Tune_Titles		;0
	
	db YES 
	dw Tune_Pause		;1
	
	db NO 
	dw Tune_RoundStart	;2
	
	db NO 
	dw Tune_LoseLife	;3
	
	db NO 
	dw Tune_GameUnder	;4

StackPos:
	dw $8099
LoopPos:
	dw $80B8
DrumStack:
	dw $80C7
DrumLoop:
	dw $80E7

MusicVars:
	dw StackSpace 
	dw LoopSpace 
	dw DrumStackSpace 
	dw DrumLoopSpace 
	
StackSpace:
	defs 32,0
	
LoopSpace: 
	defs 16,0
	
DrumStackSpace:
	defs 32,0
	
DrumLoopSpace:
	defs 16,0

Drums:
	db $00 

DrumCount:
	db $03 

DrumPos:
	dw $8563

OldNote:
	dw $0054

EndNote:
	dw $00A8

OldNote2:
	dw $0053

OldNote3:
	dw $0055

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

PlipPlopPlayer:
	DI  
	LD   HL,(INTJUMP)			; Store current TimerInt 
	PUSH HL
	LD   (ExitMusic+1),SP			; self mod
	
	CALL PlayPlipPlopMusic

ExitMusic:
	LD   SP,$63D5			; self mod
	DI  
	POP  HL
	LD   (INTJUMP),HL			; retrieve previous TimerInt
	EI  
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

PlayPlipPlopMusic:
	LD   L,A
	ADD  A,A
	ADD  A,L
	ADD  A,(TuneTable & $ff )		;$78
	LD   L,A
	LD   H,(TuneTable / $100)		;$80			; $8078 - TuneTable

	LD   A,(HL)			; first byte of table is INC A or DEC A instruction
	INC  L
	LD   (KeyMod1),A
	LD   (KeyMod2),A
	LD   A,(HL)
	INC  L
	LD   H,(HL)
	LD   L,A
	PUSH HL
	LD   HL,OurDrumInt
	LD   (INTJUMP),HL			; $FFF5 INTJMP vector
	LD   HL,MusicVars
	LD   DE,StackPos
	LD   BC,$0008
	LDIR
	POP  HL
	XOR  A
	LD   (Drums),A
	INC  A
	LD   (DrumCount),A
	LD   A,$10			; $10 to the Add A, xx instruction
	LD   (BuzzAddMod+1),A
	CALL InterpMusic
	LD   HL,ExitINT
	LD   (INTJUMP),HL
	RET 

InterpMusic:
	LD   A,(HL)
	INC  HL
	CP   PP_RTS			; $ff RTS instruction
	RET  Z
	CP   PP_JSR			; $28 JSR instruction
	EXX 
	LD   H,((MusicRoutines-$28) / $100) 	;$80	; Notes Table base at $8000
	JR   C,IsNote
	ADD  A,((MusicRoutines-$28) & $ff ) 	;$2C	; $802c MusicRoutines - $28 ($28 = JSR = the first music code)
	LD   L,A
	LD   A,(HL)
	INC  L
	LD   H,(HL)
	LD   L,A
	CALL JPHL
	JR   InterpMusic

IsNote:
	OR   A
	JR   Z,IsRest
	ADD  A,A
	LD   L,A
	LD   C,(HL)
	INC  L
	LD   B,(HL)
	LD   (OldNote),BC
	DEC  BC
	LD   (OldNote2),BC
	INC  BC
	INC  BC
	LD   (OldNote3),BC
	DEC  BC
	EXX 
	LD   A,(HL)
	INC  HL
	EXX 
	LD   L,A
	EI  
	CALL Buzz

MusicAnyKeyCheck2:
	DI  
	EXX 
	XOR  A
	IN   A,($FE)
	OR   $E0
KeyMod1:
	INC  A
	JP   NZ,ExitMusic
	JP   InterpMusic

IsRest:
	EXX 
	LD   A,(HL)
	INC  HL
	EXX 
	LD   L,A
	CALL RestLp
	JR   MusicAnyKeyCheck2
RestLp:
	EI  
MusicAnyKeyCheck:
	XOR  A
	IN   A,($FE)
	OR   $E0
KeyMod2:
	INC  A
	JP   NZ,ExitMusic
	JR   MusicAnyKeyCheck

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

Buzz:
	EI  
	XOR  A
	EX   AF,AF'
	LD   D,B
	LD   E,C
	DEC  DE
	LD   (Buzz1Mod+1),BC
	LD   (Buzz3Mod+1),DE
	SRL  D
	RR   E

Buzz0:
	DEC  BC
	LD   A,B
	OR   C
	JP   NZ,Buzz2

Buzz1Mod:
	LD   BC,$0054
	EX   AF,AF'

BuzzAddMod:
	ADD  A,$10
	OUT  ($FE),A
	EX   AF,AF'
	JP   Buzz2

Buzz2:
	DEC  DE
	LD   A,D
	OR   E
	JP   NZ,Buzz0

Buzz3Mod:
	LD   DE,$0053
	EX   AF,AF'
	ADD  A,$10
	OUT  ($FE),A
	EX   AF,AF'
	JP   Buzz0

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

OurDrumInt:
	PUSH AF
	LD   A,(Drums)
	OR   A
	JR   Z,NoDrums
	LD   A,(DrumCount)
	DEC  A
	LD   (DrumCount),A
	JR   NZ,NoDrums
	POP  AF
	LD   IX,DrumCode			; $820c DrumCode
	PUSH IX
	EI  
	RETI

NoDrums:
	DEC  L
	JR   NZ,NoEscape
	POP  AF

NoEscape:
	POP  AF
	EI  
	RETI

DrumCode:
	PUSH AF
	PUSH BC
	PUSH DE
	DEC  L
	JR   NZ,Drums0
	INC  L

Drums0:
	PUSH HL
	LD   HL,DRUM_INT
	LD   (INTJUMP),HL
	EI  
	LD   HL,(DrumPos)

InterpDrum:
	LD   A,(HL)
	INC  HL
	OR   A
	JP   P,IsDrum
	AND  $7F
	EX   DE,HL
	ADD  A, (DrumRoutines & $ff)		;$64	; $8064 DrumRoutines
	CALL TabJump
	JR   InterpDrum

IsDrum:
	LD   C,A
	AND  $1F
	DEC  A
	LD   (DrumCount),A
	LD   A,C
	RLCA
	RLCA
	RLCA
	AND  $03
	ADD  A,A
	LD   (DrumPos),HL
	ADD  A,(DrumTypeRoutines &$ff)		;$70
TabJump:
	LD   L,A
	LD   H,(DrumTypeRoutines / $100)	;$80			;$8070
	LD   A,(HL)
	INC  L
	LD   H,(HL)
	LD   L,A
JPHL:
	JP   (HL)


DRUM_INT:
	LD   HL,OurDrumInt
	LD   (INTJUMP),HL
	POP  IX
	POP  HL
	POP  DE
	POP  BC
	JP   NoDrums

TOM2_:
	LD   C,$00
TOM2_0:
	LD   B,C
a1:	DJNZ a1
	LD   A,$10
	OUT  ($FE),A
	INC  C
	INC  C
	LD   B,C
a2:	DJNZ a2
	XOR  A
	OUT  ($FE),A
	JR   TOM2_0

BASS_:
	LD   C,$3F
BASS_0:
	LD   B,C
a3:	DJNZ a3
	LD   A,$10
	OUT  ($FE),A
	LD   A,C
	RRCA
	LD   C,A
	LD   B,A
a4:	DJNZ a4
	XOR  A
	OUT  ($FE),A
	JR   BASS_0

SNARE_:
	LD   HL,$0F18
SNARE_0:
	LD   B,(HL)
a5:	DJNZ a5
	LD   A,$10
	OUT  ($FE),A
	INC  HL
	LD   B,(HL)
a6:	DJNZ a6
	XOR  A
	OUT  ($FE),A
	INC  HL
	JR   SNARE_0

TOM1_:
	LD   C,$00
TOM1_0:
	LD   B,C
a7:	DJNZ a7
	LD   A,$10
	OUT  ($FE),A
	LD   A,C
	ADD  A,$04
	LD   C,A
	LD   B,A
a8:	DJNZ a8
	XOR  A
	OUT  ($FE),A
	JR   TOM1_0

GOSUB_:
	EX   DE,HL
	LD   E,(HL)
	INC  HL
	LD   D,(HL)
	INC  HL
	EX   DE,HL

PutDrumStack:
	PUSH HL
	LD   HL,(DrumStack)
	LD   (HL),E
	INC  L
	LD   (HL),D
	INC  L
	LD   (DrumStack),HL
	POP  HL
	RET 

GOTO_:
	EX   DE,HL
	LD   A,(HL)
	INC  HL
	LD   H,(HL)
	LD   L,A
	RET 

FORDUM_:
	LD   A,(DE)
	INC  DE
	LD   HL,(DrumLoop)
	LD   (HL),A
	INC  L
	LD   (DrumLoop),HL
	LD   L,E
	LD   H,D
	JR   PutDrumStack

NEXTDRUM_:
	LD   HL,(DrumLoop)
	DEC  L
	DEC  (HL)
	JR   Z,NEXTDRUM_0
	EX   DE,HL
	CALL GetDrumStack
	LD   E,L
	LD   D,H
	JR   PutDrumStack

NEXTDRUM_0:
	LD   (DrumLoop),HL
	PUSH DE
	CALL GetDrumStack
	POP  HL
	RET 

GetDrumStack:
	LD   HL,(DrumStack)
	DEC  L
	LD   D,(HL)
	DEC  L
	LD   E,(HL)
	LD   (DrumStack),HL
	EX   DE,HL
	RET 

END_:
	XOR  A
	LD   (Drums),A
	EX   DE,HL
	RET 

JSR_:
	EXX 
	LD   A,(HL)
	INC  HL
	PUSH HL
	LD   H,(HL)
	LD   L,A
	CALL InterpMusic
	POP  HL
	INC  HL
	RET 

JMP_:
	EXX 
	LD   A,(HL)
	INC  HL
	LD   H,(HL)
	LD   L,A
	RET 

JSRS_:
	EXX 

JSRS_0:
	LD   A,(HL)
	INC  HL
	CP   $FF			; RTS
	RET  Z
	LD   E,A
	LD   D,(HL)
	INC  HL
	PUSH HL
	EX   DE,HL
	CALL InterpMusic
	POP  HL
	JR   JSRS_0

FOR_:
	EXX 
	LD   A,(HL)
	INC  HL
	EXX 
	LD   HL,(LoopPos)
	LD   (HL),A
	INC  L
	LD   (LoopPos),HL
	EXX 
	LD   E,L
	LD   D,H

PutStack:
	PUSH HL
	LD   HL,(StackPos)
	LD   (HL),E
	INC  L
	LD   (HL),D
	INC  L
	LD   (StackPos),HL
	POP  HL
	RET 

GetStack:
	LD   HL,(StackPos)
	DEC  L
	LD   D,(HL)
	DEC  L
	LD   E,(HL)
	LD   (StackPos),HL
	EX   DE,HL
	RET 

NEXT_:
	LD   HL,(LoopPos)
	DEC  L
	DEC  (HL)
	JR   Z,MoveOn
	EXX 
	CALL GetStack
	LD   E,L
	LD   D,H
	JR   PutStack

MoveOn:
	LD   (LoopPos),HL
	CALL GetStack
	EXX 
	RET 

SDRUM_:
	EXX 
	LD   A,(HL)
	INC  HL
	LD   (DrumCount),A
	LD   E,(HL)
	INC  HL
	LD   D,(HL)
	INC  HL
	LD   (DrumPos),DE
	LD   A,$FF
	LD   (Drums),A
	RET 

PBEND_:
	EXX 
	LD   A,(HL)
	INC  HL
	LD   C,(HL)
	INC  HL
	LD   B,(HL)
	INC  HL
	PUSH BC
	EXX 
	POP  BC
	ADD  A,A
	LD   L,A
	LD   H,$80
	LD   E,(HL)
	INC  L
	LD   D,(HL)
	LD   (EndNote),DE

PBendLp:
	PUSH BC
	LD   HL,(OldNote)
	LD   A,C
	OR   A
	JP   P,PosCheck
	ADD  A,L
	LD   L,A
	LD   A,H
	CCF
	SBC  A,$00
	LD   H,A
	XOR  A
	LD   (Carry),A

Do16CP:
	LD   C,L
	LD   B,H
	LD   HL,(EndNote)
	SBC  HL,BC
Carry:			; self mod NOP/CCF
	NOP 
	JR   C,NotEndNote
	LD   BC,(EndNote)

NotEndNote:
	LD   (OldNote),BC
	LD   L,$01
	CALL Buzz
	XOR  A
	OUT  ($FE),A
	DI  
	POP  BC
	DJNZ PBendLp
	EXX 
	RET 

PosCheck:
	ADD  A,L
	LD   L,A
	LD   A,H
	ADC  A,$00
	LD   H,A
	LD   A,$3F
	LD   (Carry),A
	JR   Do16CP

CALLFUNC_:
	EXX 
	LD   A,(HL)
	INC  HL
	LD   DE,(INTJUMP)
	PUSH DE					; DE holds the original TimerInt for later
	PUSH HL

	LD   H,(HL)
	LD   L,A
	LD   DE,ExitINT
	LD   (INTJUMP),DE			; set TIMERINT to ExitINT
	EI  
	CALL JPHL
	DI  
	POP  HL
	POP  DE
	LD   (INTJUMP),DE			; Reset The TimerINT to what it was
	INC  HL
	RET 
	
ExitINT:
	EI  
	RETI

NoisePlayer:
	DI  
	LD   E,$01
	LD   BC,$07D0

NoiseLoop:
	PUSH BC
NextNoise:
	CALL GetRandomNoise
	AND  E
	CALL Z,PlayNoise

	DEC  BC
	LD   A,B
	OR   C
	JR   NZ,NextNoise

	POP  BC
	LD   HL,$03E8
	ADD  HL,BC
	LD   C,L
	LD   B,H
	SCF
	RL   E
	JR   NC,NoiseLoop
	
	EI  
	RET 

PlayNoise:
	PUSH BC
	LD   A,E
	NEG  
	SRL  A
	LD   C,A
	XOR  A
	OUT  ($FE),A
	LD   A,(WHITE_RND3)
	AND  C
	LD   B,A

Wait1:	DJNZ Wait1
	LD   A,$10
	OUT  ($FE),A
	LD   A,(WHITE_RND2)
	AND  C
	LD   B,A

Wait2:	DJNZ Wait2
	POP  BC
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

GetRandomNoise:
	LD   HL,WHITE_RND1
	LD   D,(HL)
	INC  HL
	LD   A,(HL)
	SRL  D
	SRL  D
	SRL  D
	XOR  D
	INC  HL
	RRA
	RL   (HL)
	DEC  HL
	RL   (HL)
	DEC  HL
	RL   (HL)
	RET 

WHITE_RND1:
	db $37 
WHITE_RND2:
	db $69 
WHITE_RND3:
	db $67 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

Tune_RoundStart:
	db $32 
	db $14 
	dw Tune_RoundStartDrums			; addr of drum pattern
	db $18 
	db $05 
	db $1B 
	db $0F 
	db $1D 
	db $37 
	db $00 
	db $05 
	db $1D 
	db $05 
	db $1F 
	db $0F 
	db $18 
	db $05 
	db $00 
	db $05 
	db $18 
	db $05 
	db $00 
	db $05 
	db $24 
	db $05 
	db $18 
	db $05 
	db $00 
	db $05 
	db $18 
	db $0A 
	db $FF 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

Tune_RoundStartDrums:
	db $2A 
	db $0A 
	db $4A 
	db $0A 
	db $2A 
	db $0A 
	db $45 
	db $2A 
	db $25 
	db $2A 
	db $0A 
	db $4A 
	db $25 
	db $25 
	db $8A 
	db $25 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

Tune_LoseLife:
	db $32 
	db $01 
	dw Tune_RoundStartDrums
	db $24 
	db $05 
	db $1F 
	db $05 
	db $1B 
	db $05 
	db $18 
	db $05 
	db $1F 
	db $05 
	db $1B 
	db $05 
	db $18 
	db $05 
	db $13 
	db $05 
	db $1B 
	db $05 
	db $18 
	db $05 
	db $13 
	db $05 
	db $0F 
	db $05 
	db $0C 
	db $05 
	db $FF 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

Tune_GameUnder:
	db $36 			; CALL command
	dw NoisePlayer
	db $32 			; actual tune 3 music/drum data starts here
	db $01 
	dw Tune_GameUnderDrums
	db $18 
	db $05 
	db $00 
	db $0A 
	db $24 
	db $05 
	db $00 
	db $0A 
	db $22 
	db $05 
	db $00 
	db $05 
	db $22 
	db $05 
	db $24 
	db $05 
	db $00 
	db $0A 
	db $1F 
	db $05 
	db $00 
	db $0A 
	db $24 
	db $05 
	db $00 
	db $0A 
	db $1B 
	db $05 
	db $00 
	db $05 
	db $1B 
	db $05 
	db $1F 
	db $05 
	db $1B 
	db $05 
	db $1A 
	db $05 
	db $18 
	db $05 
	db $FF 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

Tune_GameUnderDrums:
	db $3E 
	db $5E 
	db $39 
	db $25 
	db $4A 
	db $25 
	db $45 
	db $25 
	db $25 
	db $8A 
	db $25 
	db $84 
	db $08 
	db $44 
	db $86 
	db $84 
	db $08 
	db $64 
	db $86 
	db $02 
	db $0E 
	db $02 
	db $0E 
	db $02 
	db $06 
	db $02 
	db $06 
	db $02 
	db $0E 
	db $88 
	db $22 
	db $26 
	db $02 
	db $06 
	db $22 
	db $26 
	db $02 
	db $06 
	db $42 
	db $42 
	db $44 
	db $02 
	db $06 
	db $02 
	db $06 
	db $22 
	db $26 
	db $02 
	db $06 
	db $22 
	db $26 
	db $22 
	db $26 
	db $02 
	db $06 
	db $42 
	db $42 
	db $44 
	db $88 
	db $80 
	db $DE 
	db $84 
	db $02 
	db $06 
	db $22 
	db $26 
	db $02 
	db $06 
	db $80 
	db $DE 
	db $84 
	db $22 
	db $26 
	db $02 
	db $06 
	db $22 
	db $26 
	db $80 
	db $DE 
	db $84 
	db $02 
	db $06 
	db $22 
	db $26 
	db $02 
	db $06 
	db $82 
	db $DE 
	db $84 
	db $80 
	db $FB 
	db $84 
	db $62 
	db $66 
	db $80 
	db $26 
	db $85 
	db $80 
	db $FB 
	db $84 
	db $22 
	db $26 
	db $62 
	db $66 
	db $62 
	db $66 
	db $88 
	db $80 
	db $44 
	db $85 
	db $08 
	db $28 
	db $08 
	db $80 
	db $44 
	db $85 
	db $28 
	db $08 
	db $28 
	db $80 
	db $44 
	db $85 
	db $08 
	db $28 
	db $08 
	db $80 
	db $44 
	db $85 
	db $28 
	db $48 
	db $48 
	db $88 
	db $28 
	db $08 
	db $28 
	db $08 
	db $48 
	db $08 
	db $08 
	db $28 
	db $08 
	db $28 
	db $28 
	db $08 
	db $48 
	db $88 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

Tune_TitlesDrums:
	db $80 
	db $CB 
	db $84 
	db $80 
	db $19 
	db $85 
	db $80 
	db $CB 
	db $84 
	db $84 
	db $04 
	db $80 
	db $2B 
	db $85 
	db $86 
	db $8A 
	db $24 
	db $80 
	db $2B 
	db $85 
	db $8A 
	db $24 
	db $80 
	db $CB 
	db $84 
	db $8A 
	db $24 
	db $84 
	db $04 
	db $22 
	db $22 
	db $24 
	db $02 
	db $06 
	db $86 
	db $42 
	db $42 
	db $44 
	db $22 
	db $26 
	db $84 
	db $02 
	db $42 
	db $42 
	db $44 
	db $42 
	db $42 
	db $44 
	db $22 
	db $26 
	db $86 
	db $82 
	db $55 
	db $85 
	db $84 
	db $04 
	db $22 
	db $22 
	db $24 
	db $86 
	db $84 
	db $03 
	db $42 
	db $42 
	db $44 
	db $86 
	db $22 
	db $22 
	db $24 
	db $84 
	db $04 
	db $28 
	db $86 
	db $84 
	db $04 
	db $62 
	db $66 
	db $86 
	db $02 
	db $8A 
	db $04 
	db $84 
	db $04 
	db $22 
	db $26 
	db $86 
	db $42 
	db $46 
	db $02 
	db $06 
	db $84 
	db $02 
	db $22 
	db $26 
	db $22 
	db $26 
	db $02 
	db $06 
	db $86 
	db $62 
	db $66 
	db $22 
	db $26 
	db $42 
	db $46 
	db $42 
	db $46 
	db $02 
	db $8A 
	db $04 
	db $24 
	db $01 
	db $21 
	db $01 
	db $1B 
	db $01 
	db $18 
	db $01 
	db $00 
	db $04 
	db $FF 
	db $24 
	db $01 
	db $1F 
	db $01 
	db $1B 
	db $01 
	db $18 
	db $01 
	db $00 
	db $04 
	db $FF 
	db $22 
	db $01 
	db $21 
	db $01 
	db $1B 
	db $01 
	db $16 
	db $01 
	db $00 
	db $04 
	db $FF 
	db $22 
	db $01 
	db $1F 
	db $01 
	db $1B 
	db $01 
	db $16 
	db $01 
	db $00 
	db $04 
	db $FF 
	db $2E 
	db $03 
	db $28 
	db $C0 
	db $85 
	db $18 
	db $04 
	db $00 
	db $04 
	db $30 
	db $2E 
	db $02 
	db $24 
	db $04 
	db $00 
	db $04 
	db $28 
	db $C0 
	db $85 
	db $30 
	db $18 
	db $04 
	db $00 
	db $04 
	db $24 
	db $04 
	db $00 
	db $04 
	db $28 
	db $C0 
	db $85 
	db $2E 
	db $03 
	db $18 
	db $04 
	db $00 
	db $04 
	db $30 
	db $FF 
	db $28 
	db $CB 
	db $85 
	db $18 
	db $04 
	db $00 
	db $04 
	db $2E 
	db $04 
	db $28 
	db $CB 
	db $85 
	db $30 
	db $2E 
	db $02 
	db $24 
	db $04 
	db $00 
	db $04 
	db $28 
	db $CB 
	db $85 
	db $30 
	db $2E 
	db $02 
	db $28 
	db $CB 
	db $85 
	db $24 
	db $04 
	db $00 
	db $04 
	db $30 
	db $2E 
	db $02 
	db $18 
	db $04 
	db $00 
	db $04 
	db $30 
	db $FF 
	db $2E 
	db $03 
	db $28 
	db $D6 
	db $85 
	db $1B 
	db $04 
	db $00 
	db $04 
	db $30 
	db $2E 
	db $02 
	db $27 
	db $04 
	db $00 
	db $04 
	db $28 
	db $D6 
	db $85 
	db $30 
	db $1B 
	db $04 
	db $00 
	db $04 
	db $27 
	db $04 
	db $00 
	db $04 
	db $28 
	db $D6 
	db $85 
	db $2E 
	db $03 
	db $1B 
	db $04 
	db $00 
	db $04 
	db $30 
	db $FF 
	db $28 
	db $E1 
	db $85 
	db $1B 
	db $04 
	db $00 
	db $04 
	db $2E 
	db $04 
	db $28 
	db $E1 
	db $85 
	db $30 
	db $2E 
	db $02 
	db $27 
	db $04 
	db $00 
	db $04 
	db $28 
	db $E1 
	db $85 
	db $30 
	db $2E 
	db $02 
	db $28 
	db $E1 
	db $85 
	db $27 
	db $04 
	db $00 
	db $04 
	db $30 
	db $2E 
	db $02 
	db $1B 
	db $04 
	db $00 
	db $04 
	db $30 
	db $FF 
	db $28 
	db $C0 
	db $85 
	db $00 
	db $08 
	db $2E 
	db $04 
	db $24 
	db $01 
	db $21 
	db $01 
	db $1B 
	db $01 
	db $18 
	db $01 
	db $30 
	db $2E 
	db $03 
	db $28 
	db $C0 
	db $85 
	db $30 
	db $00 
	db $08 
	db $2E 
	db $02 
	db $28 
	db $C0 
	db $85 
	db $30 
	db $00 
	db $08 
	db $28 
	db $C0 
	db $85 
	db $00 
	db $20 
	db $FF 
	db $2E 
	db $02 
	db $28 
	db $C0 
	db $85 
	db $28 
	db $C0 
	db $85 
	db $00 
	db $10 
	db $30 
	db $28 
	db $C0 
	db $85 
	db $28 
	db $C0 
	db $85 
	db $00 
	db $08 
	db $28 
	db $C0 
	db $85 
	db $00 
	db $20 
	db $FF 
	db $2C 
	db $EC 
	db $85 
	db $13 
	db $86 
	db $3C 
	db $86 
	db $63 
	db $86 
	db $FF 
	db $FF 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

Tune_Titles:
	db $32 
	db $01 
	dw Tune_TitlesDrums
	db $2E 
	db $09 
	db $00 
	db $80 
	db $30 
	db $01 
	db $01 
	db $34 
	db $18 
	db $FC 
	db $66 
	db $2E 
	db $02 
	db $2E 
	db $10 
	db $28 
	db $C0 
	db $85 
	db $30 
	db $2E 
	db $10 
	db $28 
	db $CB 
	db $85 
	db $30 
	db $2E 
	db $10 
	db $28 
	db $D6 
	db $85 
	db $30 
	db $2E 
	db $10 
	db $28 
	db $E1 
	db $85 
	db $30 
	db $30 
	db $2E 
	db $03 
	db $28 
	db $CB 
	db $86 
	db $30 
	db $32 
	db $01 
	db $63 
	db $85 
	db $28 
	db $CB 
	db $86 
	db $28 
	db $8C 
	db $86 
	db $32 
	db $01 
	db $68 
	db $85 
	db $00 
	db $80 
	db $28 
	db $B2 
	db $86 
	db $32 
	db $01 
	db $88 
	db $85 
	db $00 
	db $80 
	db $28 
	db $8C 
	db $86 
	db $32 
	db $01 
	db $A3 
	db $85 
	db $00 
	db $80 
	db $28 
	db $B2 
	db $86 
	db $32 
	db $01 
	db $6D 
	db $85 
	db $2A 
	db $DA 
	db $86 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;
Tune_Pause:
	db $32 
	db $01 
	dw Tune_PauseDrums
	db $00 
	db $01 
	db $2A 
	db $36 
	db $87 
	db $32 
	db $6C 
	db $66 
	db $52 
	db $6C 
	db $66 
	db $88 
	db $2C 
	db $66 
	db $06 
	db $66 
	db $06 
	db $4C 
	db $66 
	db $06 
	db $66 
	db $06 
	db $88 
	db $84 
	db $04 
	db $80 
	db $3B 
	db $87 
	db $86 
	db $84 
	db $03 
	db $80 
	db $42 
	db $87 
	db $86 
	db $88 
	db $22 
	db $30 
	db $62 
	db $6A 
	db $62 
	db $64 
	db $42 
	db $50 
	db $62 
	db $6A 
	db $62 
	db $64 
	db $88 
	db $22 
	db $2A 
	db $62 
	db $64 
	db $62 
	db $04 
	db $62 
	db $64 
	db $62 
	db $04 
	db $42 
	db $42 
	db $48 
	db $62 
	db $64 
	db $62 
	db $04 
	db $62 
	db $64 
	db $62 
	db $04 
	db $88 
	db $84 
	db $04 
	db $80 
	db $5A 
	db $87 
	db $86 
	db $84 
	db $03 
	db $80 
	db $67 
	db $87 
	db $86 
	db $88 
	db $2C 
	db $66 
	db $66 
	db $26 
	db $26 
	db $06 
	db $26 
	db $06 
	db $26 
	db $06 
	db $06 
	db $88 
	db $06 
	db $26 
	db $06 
	db $26 
	db $06 
	db $06 
	db $66 
	db $66 
	db $66 
	db $6C 
	db $66 
	db $88 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;
Tune_PauseDrums:
	db $84 
	db $08 
	db $80 
	db $4D 
	db $87 
	db $80 
	db $8A 
	db $87 
	db $80 
	db $4D 
	db $87 
	db $80 
	db $96 
	db $87 
	db $86 
	db $84 
	db $08 
	db $80 
	db $7D 
	db $87 
	db $80 
	db $8A 
	db $87 
	db $80 
	db $7D 
	db $87 
	db $80 
	db $96 
	db $87 
	db $86 
	db $82 
	db $A2 
	db $87 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $1F 
	db $1B 
	db $1F 
	db $1B 
	db $00 
	db $1B 
	db $1E 
	db $1B 
	db $1D 
	db $36 
	db $1F 
	db $1B 
	db $00 
	db $1B 
	db $1F 
	db $1B 
	db $1F 
	db $1B 
	db $00 
	db $1B 
	db $00 
	db $1B 
	db $19 
	db $9F 
	db $1A 
	db $9F 
	db $1B 
	db $9F 
	db $00 
	db $3F 
	db $00 
	db $3F 
	db $00 
	db $3F 
	db $00 
	db $3F 
	db $00 
	db $3F 
	db $00 
	db $3F 
	db $00 
	db $3F 
	db $00 
	db $3F 
	db $07 
	db $B6 
	db $07 
	db $9B 
	
;
; End of music
;

	ent		;stop displacing the origin location

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;
	org 	$63DE

Map_Round3:

   db 01Fh, 036h, 01Dh, 03Fh, 01Eh, 03Fh, 01Fh, 036h, 01Fh, 036h
   db 01Dh, 01Bh, 01Eh, 01Bh, 01Fh, 036h, 01Fh, 036h, 01Dh, 03Fh
   db 01Eh, 03Fh, 01Fh, 036h, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 019h, 036h, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 019h, 036h, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 01Bh, 036h, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 01Bh, 036h, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 01Bh, 02Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 00Dh, 02Dh, 00Eh, 02Dh, 00Eh, 02Dh, 00Fh, 02Dh
   db 000h, 03Fh, 00Dh, 02Dh, 00Fh, 02Dh, 000h, 03Fh, 00Dh, 02Dh
   db 00Eh, 02Dh, 00Fh, 02Dh, 000h, 03Fh, 00Dh, 02Dh, 00Eh, 02Dh
   db 00Eh, 02Dh, 00Eh, 02Dh, 00Eh, 02Dh, 00Eh, 02Dh, 00Fh, 02Dh
   db 00Dh, 02Dh, 00Eh, 02Dh, 00Eh, 02Dh, 00Eh, 02Dh, 00Eh, 02Dh
   db 00Fh, 02Dh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 017h, 02Dh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 01Fh, 01Bh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 01Fh, 01Bh, 000h, 03Fh, 01Fh, 01Bh
   db 000h, 03Fh, 01Fh, 01Bh, 000h, 03Fh, 01Fh, 036h, 01Dh, 01Bh
   db 01Eh, 01Bh, 01Fh, 036h, 01Fh, 036h, 01Dh, 03Fh, 01Eh, 03Fh
   db 01Fh, 036h, 01Fh, 036h, 01Dh, 01Bh, 01Eh, 01Bh, 01Fh, 036h
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 019h, 036h, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 019h, 036h, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 01Bh, 036h
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 01Bh, 036h, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 01Bh, 02Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 00Dh, 02Dh
   db 00Eh, 02Dh, 00Eh, 02Dh, 00Fh, 02Dh, 000h, 03Fh, 00Dh, 02Dh
   db 00Fh, 02Dh, 000h, 03Fh, 00Dh, 02Dh, 00Eh, 02Dh, 00Fh, 02Dh
   db 000h, 03Fh, 00Dh, 02Dh, 00Eh, 02Dh, 00Eh, 02Dh, 00Eh, 02Dh
   db 00Eh, 02Dh, 00Eh, 02Dh, 00Fh, 02Dh, 00Dh, 02Dh, 00Eh, 02Dh
   db 00Eh, 02Dh, 00Eh, 02Dh, 00Eh, 02Dh, 00Fh, 02Dh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 015h, 01Bh, 016h, 01Bh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 01Fh, 01Bh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 01Fh, 01Bh, 000h, 03Fh, 01Fh, 01Bh, 000h, 03Fh, 01Fh, 01Bh
   db 000h, 03Fh, 01Fh, 036h, 01Dh, 0BFh, 01Eh, 0BFh, 01Dh, 0ADh
   db 01Eh, 0ADh, 01Dh, 09Bh, 01Eh, 09Bh, 01Dh, 0ADh, 01Eh, 0ADh
   db 01Dh, 0BFh, 01Eh, 0BFh, 01Fh, 036h, 005h, 08Dh, 006h, 08Dh
   db 006h, 08Dh, 006h, 08Dh, 007h, 08Dh, 005h, 08Dh, 006h, 08Dh
   db 006h, 08Dh, 006h, 08Dh, 006h, 08Dh, 006h, 08Dh, 006h, 08Dh
   db 006h, 08Dh, 007h, 08Dh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 005h, 08Dh, 006h, 08Dh, 006h, 08Dh, 007h, 08Dh
   db 000h, 03Fh, 000h, 03Fh, 01Bh, 036h, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 01Bh, 036h
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 01Ah, 0BDh, 01Ah, 0BDh, 000h, 03Fh, 01Bh, 02Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 009h, 0BEh, 00Ah, 0BEh, 00Ah, 0BEh
   db 00Bh, 0BEh, 000h, 03Fh, 009h, 0BEh, 00Bh, 0BEh, 000h, 03Fh
   db 009h, 0BEh, 00Ah, 0BEh, 00Bh, 0BEh, 000h, 03Fh, 009h, 0BEh
   db 00Ah, 0BEh, 00Ah, 0BEh, 00Ah, 0BEh, 00Ah, 0BEh, 00Ah, 0BEh
   db 00Bh, 0BEh, 00Dh, 02Dh, 00Eh, 02Dh, 00Eh, 02Dh, 00Eh, 02Dh
   db 00Eh, 02Dh, 00Fh, 02Dh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 011h, 096h, 012h, 096h, 013h, 096h, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 01Fh, 01Bh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 01Fh, 01Bh, 000h, 03Fh
   db 01Fh, 01Bh, 000h, 03Fh, 01Fh, 01Bh, 000h, 03Fh, 01Fh, 036h
   db 01Dh, 09Bh, 01Eh, 09Bh, 01Fh, 036h, 01Fh, 036h, 01Dh, 0BFh
   db 01Eh, 0BFh, 01Fh, 036h, 01Fh, 036h, 01Dh, 09Bh, 01Eh, 09Bh
   db 01Fh, 036h, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 005h, 084h
   db 006h, 084h, 006h, 084h, 006h, 084h, 006h, 084h, 007h, 084h
   db 000h, 03Fh, 000h, 03Fh, 001h, 09Fh, 002h, 09Fh, 002h, 09Fh
   db 002h, 09Fh, 002h, 09Fh, 002h, 09Fh, 002h, 09Fh, 002h, 09Fh
   db 002h, 09Fh, 002h, 09Fh, 002h, 09Fh, 002h, 09Fh, 002h, 09Fh
   db 003h, 09Fh, 000h, 03Fh, 000h, 03Fh, 001h, 0ABh, 002h, 0ABh
   db 002h, 0ABh, 002h, 0ABh, 002h, 0ABh, 002h, 0ABh, 002h, 0ABh
   db 002h, 0ABh, 003h, 0ABh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 009h, 0BEh
   db 00Ah, 0BEh, 00Ah, 0BEh, 00Ah, 0BEh, 00Ah, 0BEh, 00Bh, 0BEh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 011h, 0B2h, 012h, 0B2h, 013h, 0B2h
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 011h, 0B2h
   db 012h, 0B2h, 013h, 0B2h, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 01Dh, 089h, 01Eh, 089h, 01Dh, 0BFh, 01Eh, 0BFh
   db 01Dh, 089h, 01Eh, 089h, 000h, 03Fh, 01Fh, 01Bh, 000h, 03Fh
   db 01Fh, 01Bh, 000h, 03Fh, 01Fh, 036h, 01Dh, 0BFh, 01Eh, 0BFh
   db 01Fh, 036h, 01Fh, 036h, 01Dh, 09Bh, 01Eh, 09Bh, 01Fh, 036h
   db 01Fh, 036h, 01Dh, 0BFh, 01Eh, 0BFh, 01Fh, 036h, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 019h, 032h, 000h, 03Fh, 01Ah, 09Bh
   db 01Ah, 09Bh, 000h, 03Fh, 019h, 032h, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 01Bh, 02Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 009h, 0BEh, 00Ah, 0BEh, 00Ah, 0BEh
   db 00Ah, 0BEh, 00Bh, 0BEh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 011h, 096h, 012h, 096h
   db 013h, 096h, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 011h, 096h
   db 012h, 096h, 013h, 096h, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 01Dh, 0BFh, 01Eh, 0BFh, 000h, 03Fh, 01Fh, 01Bh, 000h, 03Fh
   db 01Fh, 036h, 01Dh, 09Bh, 01Eh, 09Bh, 01Dh, 0ADh, 01Eh, 0ADh
   db 01Dh, 0BFh, 01Eh, 0BFh, 01Dh, 0ADh, 01Eh, 0ADh, 01Dh, 09Bh
   db 01Eh, 09Bh, 01Fh, 036h, 005h, 08Dh, 006h, 08Dh, 007h, 08Dh
   db 005h, 08Dh, 006h, 08Dh, 006h, 08Dh, 006h, 08Dh, 006h, 08Dh
   db 007h, 08Dh, 005h, 08Dh, 007h, 08Dh, 005h, 08Dh, 006h, 08Dh
   db 006h, 08Dh, 006h, 08Dh, 006h, 08Dh, 006h, 08Dh, 006h, 08Dh
   db 006h, 08Dh, 006h, 08Dh, 006h, 08Dh, 006h, 08Dh, 006h, 08Dh
   db 007h, 08Dh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 01Bh, 02Fh, 01Ah, 0B7h
   db 01Ah, 0B7h, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 009h, 0BEh, 00Ah, 0BEh, 00Ah, 0BEh, 00Bh, 0BEh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 011h, 0B2h
   db 012h, 0B2h, 013h, 0B2h, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 01Dh, 089h, 01Eh, 089h, 000h, 03Fh, 01Fh, 036h, 01Dh, 0BFh
   db 01Eh, 0BFh, 01Fh, 036h, 01Fh, 036h, 01Dh, 09Bh, 01Eh, 09Bh
   db 01Fh, 036h, 01Fh, 036h, 01Dh, 0BFh, 01Eh, 0BFh, 01Fh, 036h
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 019h, 032h, 000h, 03Fh
   db 01Ah, 09Bh, 01Ah, 09Bh, 000h, 03Fh, 019h, 032h, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 001h, 09Fh
   db 002h, 09Fh, 002h, 09Fh, 002h, 09Fh, 002h, 09Fh, 002h, 09Fh
   db 002h, 09Fh, 003h, 09Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 001h, 0ABh, 002h, 0ABh, 002h, 0ABh
   db 002h, 0ABh, 002h, 0ABh, 002h, 0ABh, 002h, 0ABh, 002h, 0ABh
   db 003h, 0ABh, 000h, 03Fh, 000h, 03Fh, 001h, 0ABh, 003h, 0ABh
   db 000h, 03Fh, 000h, 03Fh, 001h, 0ABh, 003h, 0ABh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 009h, 0BEh, 00Ah, 0BEh, 00Bh, 0BEh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 011h, 096h
   db 012h, 096h, 013h, 096h, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 011h, 096h, 012h, 096h, 013h, 096h, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 005h, 0ADh, 007h, 0ADh, 005h, 084h, 007h, 084h, 005h, 08Dh
   db 006h, 08Dh, 006h, 08Dh, 006h, 08Dh, 006h, 08Dh, 007h, 08Dh
   db 005h, 084h, 006h, 084h, 006h, 084h, 007h, 084h, 005h, 08Dh
   db 007h, 08Dh, 01Fh, 036h, 01Dh, 09Bh, 01Eh, 09Bh, 01Fh, 036h
   db 01Fh, 036h, 01Dh, 0BFh, 01Eh, 0BFh, 01Fh, 036h, 01Fh, 036h
   db 01Dh, 09Bh, 01Eh, 09Bh, 01Fh, 036h, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 019h, 036h, 01Ah, 09Bh, 01Ah, 09Bh, 01Ah, 09Bh
   db 01Ah, 09Bh, 019h, 036h, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 01Ah, 09Bh, 01Ah, 0ADh
   db 01Ah, 0BFh, 01Ah, 0BFh, 01Ah, 0ADh, 01Ah, 09Bh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 015h, 012h, 016h, 012h, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 015h, 012h, 016h, 012h, 000h, 03Fh, 000h, 03Fh
   db 015h, 036h, 016h, 036h, 015h, 036h, 016h, 036h, 015h, 03Fh
   db 016h, 03Fh, 015h, 03Fh, 016h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 009h, 0BEh, 00Bh, 0BEh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 011h, 0B2h
   db 012h, 0B2h, 013h, 0B2h, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 011h, 096h, 012h, 096h, 013h, 096h, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 011h, 0B2h, 012h, 0B2h, 013h, 0B2h, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh

Map_Round2:

   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 009h, 02Ch, 00Ah, 008h, 00Ah, 008h
   db 00Bh, 02Ch, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 01Fh, 036h, 000h, 03Fh, 000h, 03Fh, 01Fh, 036h, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 01Fh, 036h, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 00Dh, 02Dh, 00Eh, 009h, 00Eh, 009h, 00Fh, 02Dh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 01Fh, 036h, 000h, 03Fh
   db 000h, 03Fh, 01Fh, 036h, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 01Fh, 036h, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 00Dh, 02Dh, 00Eh, 009h
   db 00Eh, 009h, 00Fh, 02Dh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 011h, 0A7h, 013h, 0A7h, 011h, 0A7h, 012h, 0A7h
   db 013h, 0A7h, 000h, 03Fh, 000h, 03Fh, 011h, 0A7h, 012h, 0A7h
   db 013h, 0A7h, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 001h, 0B7h
   db 002h, 0B7h, 003h, 0B7h, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 009h, 0B4h, 00Ah, 090h, 00Ah, 090h
   db 00Ah, 090h, 00Ah, 090h, 00Ah, 090h, 00Ah, 090h, 00Ah, 090h
   db 00Bh, 0B4h, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 011h, 0A7h, 012h, 0A7h, 013h, 0A7h, 000h, 03Fh, 000h, 03Fh
   db 001h, 0B7h, 002h, 0B7h, 003h, 0B7h, 000h, 03Fh, 001h, 0B7h
   db 002h, 0B7h, 002h, 0B7h, 003h, 0B7h, 000h, 03Fh, 001h, 0B7h
   db 002h, 0B7h, 003h, 0B7h, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 001h, 0B7h, 002h, 0B7h, 003h, 0B7h, 000h, 03Fh, 001h, 0B7h
   db 002h, 0B7h, 002h, 0B7h, 003h, 0B7h, 000h, 03Fh, 001h, 0B7h
   db 002h, 0B7h, 003h, 0B7h, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 01Dh, 036h, 01Eh, 036h, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 015h, 036h, 016h, 012h, 016h, 012h, 016h, 012h, 016h, 012h
   db 016h, 012h, 016h, 012h, 016h, 012h, 017h, 036h, 009h, 0B4h
   db 00Bh, 0B4h, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 019h, 03Eh, 01Ah, 03Eh, 01Ah, 03Eh, 01Ah, 03Eh, 01Ah, 03Eh
   db 01Ah, 03Eh, 01Ah, 03Eh, 01Bh, 03Eh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 011h, 0A7h, 012h, 0A7h, 012h, 0A7h, 012h, 0A7h, 012h, 0A7h
   db 012h, 0A7h, 013h, 0A7h, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 001h, 0B7h, 002h, 0B7h, 003h, 0B7h, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 009h, 0AEh, 00Bh, 0AEh, 000h, 03Fh, 000h, 03Fh, 009h, 0AEh
   db 00Bh, 0AEh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 009h, 0BDh, 00Ah, 09Dh, 00Ah, 09Dh, 00Ah, 09Dh, 00Ah, 09Dh
   db 00Ah, 09Dh, 00Ah, 09Dh, 00Bh, 0BDh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 015h, 036h, 016h, 012h
   db 016h, 012h, 016h, 012h, 016h, 012h, 016h, 012h, 016h, 012h
   db 016h, 012h, 017h, 036h, 015h, 036h, 017h, 036h, 009h, 0B4h
   db 00Bh, 0B4h, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 005h, 036h, 006h, 036h
   db 006h, 036h, 006h, 036h, 006h, 036h, 006h, 036h, 006h, 036h
   db 007h, 036h, 000h, 03Fh, 000h, 03Fh, 011h, 0A7h, 012h, 0A7h
   db 012h, 0A7h, 013h, 0A7h, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 011h, 0A7h, 012h, 0A7h, 013h, 0A7h, 000h, 03Fh
   db 000h, 03Fh, 001h, 0B7h, 002h, 0B7h, 002h, 0B7h, 003h, 0B7h
   db 000h, 03Fh, 000h, 03Fh, 001h, 0B7h, 003h, 0B7h, 000h, 03Fh
   db 001h, 0B7h, 002h, 0B7h, 003h, 0B7h, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 001h, 0B7h, 002h, 0B7h, 003h, 0B7h, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 00Dh, 02Dh, 00Fh, 02Dh
   db 000h, 03Fh, 000h, 03Fh, 00Dh, 02Dh, 00Fh, 02Dh, 000h, 03Fh
   db 009h, 0AEh, 00Bh, 0AEh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 005h, 03Fh, 007h, 01Bh
   db 000h, 01Bh, 005h, 01Bh, 007h, 01Bh, 000h, 01Bh, 005h, 01Bh
   db 007h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 01Dh, 0ADh, 01Eh, 0ADh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 01Dh, 0ADh, 01Eh, 0ADh, 000h, 03Fh
   db 009h, 0BCh, 00Ah, 098h, 00Ah, 098h, 00Ah, 098h, 00Ah, 098h
   db 00Ah, 098h, 00Ah, 098h, 00Ah, 098h, 00Ah, 098h, 00Ah, 098h
   db 00Ah, 098h, 00Ah, 098h, 00Ah, 098h, 00Ah, 098h, 00Ah, 098h
   db 00Bh, 0BCh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 015h, 0ADh, 016h, 0ADh, 016h, 0ADh, 016h, 0ADh, 016h, 0ADh
   db 016h, 0ADh, 016h, 0ADh, 016h, 0ADh, 016h, 0ADh, 017h, 0ADh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 001h, 0B7h, 002h, 0B7h, 003h, 0B7h, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 009h, 0AEh, 00Ah, 0AEh, 00Bh, 0AEh, 000h, 03Fh, 000h, 03Fh
   db 009h, 0AEh, 00Ah, 0AEh, 00Bh, 0AEh, 00Dh, 02Dh, 00Fh, 02Dh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 005h, 03Fh, 007h, 01Bh, 000h, 01Bh, 005h, 01Bh
   db 007h, 01Bh, 000h, 01Bh, 005h, 01Bh, 007h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 009h, 0B4h
   db 00Ah, 0B4h, 00Ah, 0B4h, 00Bh, 0B4h, 000h, 034h, 009h, 0B4h
   db 00Ah, 0B4h, 00Ah, 0B4h, 00Bh, 0B4h, 009h, 0BCh, 00Ah, 098h
   db 00Ah, 098h, 00Ah, 098h, 00Ah, 098h, 00Ah, 098h, 00Ah, 098h
   db 00Ah, 098h, 00Ah, 098h, 00Ah, 098h, 00Ah, 098h, 00Ah, 098h
   db 00Ah, 098h, 00Ah, 098h, 00Ah, 098h, 00Bh, 0BCh, 009h, 0B4h
   db 00Ah, 0B4h, 00Ah, 0B4h, 00Bh, 0B4h, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 015h, 0BFh, 016h, 0BFh, 016h, 0BFh
   db 016h, 0BFh, 016h, 0BFh, 016h, 0BFh, 016h, 0BFh, 016h, 0BFh
   db 016h, 0BFh, 016h, 0BFh, 016h, 0BFh, 017h, 0BFh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 01Dh, 0ADh, 01Eh, 0ADh
   db 01Dh, 0A4h, 01Eh, 0A4h, 000h, 03Fh, 01Dh, 0B6h, 01Eh, 0B6h
   db 01Dh, 0ADh, 01Eh, 0ADh, 000h, 03Fh, 01Dh, 0BDh, 01Eh, 0BDh
   db 000h, 03Fh, 001h, 0B7h, 002h, 0B7h, 003h, 0B7h, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 001h, 0B7h, 002h, 0B7h, 003h, 0B7h
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 009h, 0AEh, 00Bh, 0AEh, 000h, 03Fh, 00Dh, 02Dh, 00Eh, 02Dh
   db 00Fh, 02Dh, 000h, 03Fh, 000h, 03Fh, 00Dh, 02Dh, 00Eh, 02Dh
   db 00Fh, 02Dh, 00Dh, 02Dh, 00Fh, 02Dh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 005h, 03Fh
   db 006h, 01Bh, 006h, 01Bh, 006h, 01Bh, 006h, 01Bh, 006h, 01Bh
   db 006h, 01Bh, 007h, 03Fh, 000h, 03Fh, 000h, 03Fh


; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
; Unshifted Map Tile Data
;
	org $73e0

MapTiles_Round1:
	
   db 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 055h, 055h, 055h, 055h
   db 055h, 055h, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 001h, 000h
   db 001h, 000h, 001h, 000h, 001h, 000h, 003h, 000h, 001h, 008h
   db 001h, 004h, 041h, 041h, 005h, 040h, 00Bh, 050h, 093h, 014h
   db 06Bh, 0A5h, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0EDh, 06Fh
   db 0BFh, 0B5h, 084h, 0DFh, 0BDh, 0A5h, 0F5h, 0D7h, 051h, 036h
   db 0EBh, 0D6h, 0AEh, 082h, 084h, 02Fh, 0D5h, 062h, 074h, 014h
   db 002h, 04Dh, 042h, 088h, 020h, 080h, 020h, 006h, 090h, 000h
   db 044h, 002h, 004h, 005h, 000h, 082h, 001h, 000h, 000h, 020h
   db 008h, 010h, 000h, 020h, 001h, 000h, 0FFh, 0FFh, 0FFh, 0FFh
   db 0FFh, 0FFh, 000h, 000h, 000h, 000h, 000h, 03Fh, 010h, 010h
   db 010h, 010h, 010h, 03Fh, 000h, 000h, 000h, 000h, 000h, 03Fh
   db 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0F8h, 017h, 0F8h, 017h
   db 0F8h, 0BFh, 0F1h, 08Bh, 0F1h, 08Bh, 0F1h, 07Fh, 0E2h, 0C5h
   db 0E2h, 0C5h, 0E2h, 0FFh, 0C5h, 0E2h, 0C5h, 0E2h, 0C5h, 0FFh
   db 08Bh, 0F1h, 08Bh, 0F1h, 08Bh, 0FFh, 017h, 0F8h, 017h, 0F8h
   db 017h, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 000h, 000h
   db 000h, 000h, 000h, 03Fh, 010h, 010h, 010h, 010h, 010h, 03Fh
   db 000h, 000h, 000h, 000h, 000h, 03Fh, 0FFh, 0FFh, 0FFh, 0FFh
   db 0FFh, 0FFh, 0FFh, 0FFh, 0ECh, 0FFh, 0FFh, 0FFh, 0D8h, 07Fh
   db 0ECh, 0FFh, 060h, 03Fh, 0FFh, 0FFh, 0ECh, 0FFh, 060h, 03Fh
   db 0ECh, 0FFh, 0ECh, 0FFh, 0FFh, 0FFh, 0ECh, 0FFh, 0ECh, 0FFh
   db 0B0h, 07Fh, 0FFh, 0FFh, 0ECh, 0FFh, 0B0h, 07Fh, 0D8h, 07Fh
   db 0ECh, 0FFh, 0B0h, 07Fh, 0FFh, 0FFh, 0ECh, 0FFh, 0B0h, 07Fh
   db 0ECh, 0FFh, 0ECh, 0FFh, 0B0h, 07Fh, 0ECh, 0FFh, 0ECh, 0FFh
   db 0B0h, 07Fh, 0ECh, 0FFh, 0ECh, 0FFh, 0B0h, 07Fh, 0ECh, 0FFh
   db 0ECh, 0FFh, 0B0h, 07Fh, 0ECh, 0FFh, 0ECh, 0FFh, 0B0h, 07Fh
   db 0ECh, 0FFh, 0ECh, 0FFh, 0FFh, 0FFh, 0ECh, 0FFh, 0ECh, 0FFh
   db 060h, 03Fh, 0ECh, 0FFh, 0ECh, 0FFh, 060h, 03Fh, 0FFh, 0FFh
   db 0FFh, 0FFh, 0FFh, 0FFh, 001h, 001h, 001h, 001h, 001h, 0FFh
   db 001h, 001h, 001h, 001h, 001h, 0FFh, 001h, 001h, 001h, 001h
   db 001h, 0FFh, 001h, 001h, 001h, 001h, 001h, 0FFh, 001h, 001h
   db 001h, 001h, 001h, 0FFh, 001h, 001h, 001h, 001h, 001h, 0FFh
   db 001h, 001h, 001h, 001h, 001h, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
   db 0FFh, 0FFh, 008h, 021h, 008h, 021h, 009h, 0FFh, 008h, 021h
   db 008h, 021h, 009h, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
   db 0C4h, 044h, 044h, 044h, 047h, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
   db 0FFh, 0FFh, 0F5h, 055h, 055h, 055h, 05Fh, 0FFh, 0FFh, 0FFh
   db 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
   db 001h, 001h, 001h, 001h, 001h, 0FFh, 001h, 001h, 001h, 001h
   db 001h, 0FFh, 001h, 001h, 001h, 001h, 001h, 0FFh, 0FFh, 0FFh
   db 0FFh, 0FFh, 0FFh, 0FFh, 010h, 010h, 010h, 010h, 011h, 0FFh
   db 010h, 010h, 010h, 010h, 011h, 0FFh, 010h, 010h, 010h, 010h
   db 011h, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 001h, 001h
   db 001h, 001h, 001h, 0FFh, 001h, 001h, 001h, 001h, 001h, 0FFh
   db 001h, 001h, 001h, 001h, 001h, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
   db 0FFh, 0FFh, 010h, 010h, 010h, 010h, 011h, 0FFh, 010h, 010h
   db 010h, 010h, 011h, 0FFh, 010h, 010h, 010h, 010h, 011h, 0FFh
   db 0F3h, 0F3h, 0F3h, 0F3h, 0F3h, 0FFh, 015h, 015h, 015h, 015h
   db 015h, 0FFh, 019h, 019h, 019h, 019h, 019h, 0FFh, 015h, 015h
   db 015h, 015h, 015h, 0FFh, 013h, 013h, 013h, 013h, 013h, 0FFh
   db 015h, 015h, 015h, 015h, 015h, 0FFh, 019h, 019h, 019h, 019h
   db 019h, 0FFh, 015h, 015h, 015h, 015h, 015h, 0FFh, 01Fh, 01Fh
   db 01Fh, 01Fh, 01Fh, 0FFh, 015h, 015h, 015h, 015h, 015h, 0FFh
   db 019h, 019h, 019h, 019h, 019h, 0FFh, 015h, 015h, 015h, 015h
   db 015h, 0FFh, 013h, 013h, 013h, 013h, 013h, 0FFh, 015h, 015h
   db 015h, 015h, 015h, 0FFh, 019h, 019h, 019h, 019h, 019h, 0FFh
   db 015h, 015h, 015h, 015h, 015h, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
   db 0FFh, 0FFh, 0E0h, 0C3h, 0F0h, 07Fh, 0E0h, 07Fh, 0DAh, 028h
   db 0CCh, 07Fh, 09Ah, 03Fh, 0DDh, 040h, 0CEh, 03Fh, 03Ch, 0BFh
   db 0BAh, 000h, 04Ch, 03Fh, 070h, 03Fh, 0BCh, 000h, 050h, 03Fh
   db 020h, 03Fh, 0B0h, 000h, 040h, 03Fh, 090h, 0BFh, 070h, 002h
   db 068h, 03Fh, 080h, 0BFh, 020h, 000h, 07Ch, 03Fh, 050h, 0BFh
   db 050h, 000h, 0E6h, 07Fh, 040h, 07Fh, 020h, 082h, 0C3h, 0FFh
   db 000h, 03Fh, 040h, 000h, 0C8h, 0FFh, 020h, 03Fh, 021h, 006h
   db 040h, 03Fh, 040h, 03Fh, 041h, 02Bh, 050h, 03Fh, 071h, 03Fh
   db 022h, 016h, 068h, 03Fh, 028h, 07Fh, 083h, 0E0h, 0E0h, 07Fh
   db 080h, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FEh, 043h
   db 0C0h, 003h, 0C2h, 07Fh, 0FFh, 0FEh, 07Fh, 0FEh, 07Fh, 0FFh
   db 0FCh, 043h, 0C0h, 003h, 0C2h, 03Fh, 0FFh, 0C2h, 040h, 002h
   db 043h, 0FFh, 0FEh, 043h, 0C0h, 003h, 0C2h, 07Fh, 0FEh, 07Fh
   db 0FFh, 0FFh, 0FEh, 07Fh, 0FEh, 07Fh, 0FFh, 0FFh, 0FEh, 07Fh
   db 0FEh, 07Fh, 0FFh, 0FFh, 0FEh, 07Fh, 0FEh, 07Fh, 0FFh, 0FFh
   db 0FEh, 07Fh, 0FEh, 07Fh, 0FFh, 0FFh, 0FEh, 07Fh, 0FEh, 07Fh
   db 0FFh, 0FFh, 0FEh, 07Fh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
   db 0FDh, 03Fh, 0FFh, 0FFh, 0FDh, 03Fh, 0FDh, 03Fh, 0FFh, 0FFh
   db 0FDh, 03Fh, 0FDh, 03Fh, 0FFh, 0FFh, 0FDh, 03Fh, 0E9h, 0FFh
   db 0FFh, 0FFh, 0FFh, 0FFh, 0B8h, 07Fh, 0FEh, 07Fh, 0FEh, 07Fh
   db 070h, 03Fh, 0FEh, 07Fh, 0FEh, 07Fh, 0FFh, 0FFh, 0FEh, 07Fh
   db 0FEh, 07Fh, 0BAh, 07Fh, 0FEh, 07Fh, 0FEh, 07Fh, 0BAh, 07Fh
   db 0E6h, 07Fh, 0FEh, 07Fh, 0BAh, 07Fh, 0EFh, 0FFh, 0FEh, 07Fh
   db 03Ah, 03Fh, 0E5h, 03Fh, 0FEh, 07Fh, 03Ah, 03Fh, 0ADh, 03Fh
   db 0FEh, 07Fh, 0BAh, 07Fh, 0ADh, 03Fh, 0FEh, 07Fh, 0BAh, 07Fh
   db 0E5h, 03Fh, 0FEh, 07Fh, 0BAh, 07Fh, 0EFh, 0FFh, 0FEh, 07Fh
   db 0BAh, 07Fh, 0E6h, 07Fh, 0FFh, 0FFh, 0BAh, 07Fh, 0FEh, 07Fh
   db 0FDh, 03Fh, 0FFh, 0FFh, 0FEh, 07Fh, 0FDh, 03Fh, 070h, 03Fh
   db 0FEh, 07Fh, 0FDh, 03Fh

MapTiles_Round2:
   db 073h, 00Eh, 010h, 085h, 0CCh, 060h, 07Dh, 09Fh, 0BDh, 0FBh
   db 0F0h, 0F7h, 0EFh, 0F7h, 0FBh, 0FFh, 0DEh, 0FBh, 0FFh, 0BFh
   db 0FFh, 0BDh, 0FFh, 0DFh, 0BBh, 0FEh, 0DFh, 0FFh, 0F7h, 07Fh
   db 0FFh, 0EFh, 0FFh, 0FFh, 0FFh, 0FBh, 0EEh, 0FBh, 0FEh, 0FFh
   db 0FDh, 0EFh, 07Bh, 0FFh, 0B7h, 0EEh, 0EFh, 069h, 0DFh, 0EDh
   db 06Fh, 0BFh, 0B5h, 084h, 036h, 0BDh, 0A5h, 0F5h, 0D7h, 051h
   db 02Fh, 0EBh, 0D6h, 0AEh, 082h, 084h, 04Dh, 0D5h, 062h, 074h
   db 014h, 002h, 006h, 042h, 088h, 020h, 080h, 020h, 005h, 090h
   db 000h, 044h, 002h, 004h, 020h, 000h, 082h, 001h, 000h, 000h
   db 000h, 008h, 010h, 000h, 020h, 001h, 0FFh, 0FFh, 0FFh, 0FFh
   db 0FFh, 0FFh, 000h, 000h, 000h, 000h, 001h, 0FFh, 000h, 010h
   db 000h, 010h, 001h, 0FFh, 010h, 000h, 010h, 000h, 011h, 0FFh
   db 000h, 010h, 000h, 010h, 001h, 0FFh, 000h, 000h, 000h, 000h
   db 001h, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 055h, 055h
   db 055h, 055h, 055h, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
   db 095h, 029h, 009h, 029h, 049h, 0FFh, 053h, 009h, 043h, 009h
   db 005h, 0FFh, 025h, 085h, 005h, 085h, 015h, 0FFh, 005h, 009h
   db 025h, 009h, 029h, 0FFh, 0A3h, 0C3h, 0A3h, 0C3h, 09Bh, 0FFh
   db 0C7h, 0D7h, 0C7h, 0D7h, 0D7h, 0FFh, 0EFh, 0EFh, 0EFh, 0EFh
   db 0EFh, 0FFh, 089h, 045h, 089h, 045h, 089h, 0FFh, 041h, 007h
   db 041h, 007h, 041h, 0FFh, 041h, 001h, 041h, 001h, 041h, 0FFh
   db 003h, 005h, 003h, 005h, 003h, 0FFh, 093h, 00Bh, 093h, 00Bh
   db 093h, 0FFh, 009h, 0A9h, 009h, 0A9h, 009h, 0FFh, 017h, 065h
   db 017h, 065h, 017h, 0FFh, 015h, 023h, 015h, 023h, 015h, 0FFh
   db 015h, 007h, 015h, 007h, 015h, 0FFh, 055h, 065h, 055h, 065h
   db 055h, 0FFh, 089h, 021h, 089h, 021h, 089h, 0FFh, 085h, 001h
   db 085h, 001h, 085h, 0FFh, 08Bh, 089h, 08Bh, 089h, 08Bh, 0FFh
   db 007h, 055h, 007h, 055h, 007h, 0FFh, 02Bh, 015h, 02Bh, 015h
   db 02Bh, 0FFh, 009h, 009h, 009h, 009h, 009h, 0FFh, 0DCh, 06Bh
   db 00Dh, 06Bh, 077h, 0FFh, 0E4h, 084h, 010h, 084h, 061h, 0FFh
   db 052h, 080h, 000h, 080h, 000h, 0FFh, 080h, 040h, 000h, 040h
   db 000h, 0FFh, 080h, 004h, 000h, 004h, 000h, 07Fh, 008h, 004h
   db 000h, 004h, 000h, 07Fh, 004h, 028h, 020h, 028h, 000h, 07Fh
   db 08Eh, 034h, 072h, 034h, 08Ch, 0FFh, 0FBh, 0FFh, 0DFh, 0FFh
   db 0FFh, 0FFh, 091h, 085h, 015h, 085h, 03Bh, 0FFh, 0FAh, 0DAh
   db 09Ah, 0DAh, 054h, 0FFh, 075h, 0A2h, 055h, 0A2h, 04Bh, 0FFh
   db 02Bh, 025h, 05Ah, 025h, 057h, 0FFh, 0A5h, 041h, 04Dh, 041h
   db 028h, 0FFh, 09Ah, 042h, 08Bh, 042h, 010h, 0FFh, 0BFh, 0D4h
   db 08Eh, 0D4h, 010h, 0FFh, 0A1h, 053h, 09Ch, 053h, 009h, 0FFh
   db 015h, 021h, 014h, 021h, 087h, 0FFh, 088h, 041h, 024h, 041h
   db 001h, 0FFh, 058h, 0C1h, 068h, 0C1h, 030h, 0FFh, 04Ah, 0A2h
   db 0C8h, 0A2h, 059h, 0FFh, 08Dh, 044h, 0E8h, 044h, 06Bh, 0FFh
   db 085h, 0B4h, 048h, 0B4h, 05Bh, 0FFh, 0B6h, 08Ch, 010h, 08Ch
   db 073h, 0FFh, 088h, 082h, 020h, 082h, 055h, 0FFh, 049h, 081h
   db 060h, 081h, 02Dh, 0FFh, 052h, 081h, 0D1h, 081h, 058h, 0FFh
   db 053h, 041h, 0B3h, 041h, 038h, 0FFh, 08Ah, 0C1h, 05Ah, 0C1h
   db 0E8h, 0FFh, 095h, 060h, 0ADh, 060h, 0D8h, 0FFh, 096h, 0A1h
   db 05Ah, 0A1h, 0A8h, 0FFh, 005h, 061h, 0ADh, 061h, 055h, 0FFh
   db 0A1h, 022h, 0AAh, 022h, 084h, 03Fh, 0D1h, 0D2h, 089h, 0D2h
   db 0EAh, 03Fh, 0A3h, 054h, 0D2h, 054h, 091h, 03Fh, 094h, 0ADh
   db 0ACh, 0ADh, 082h, 0FFh, 08Bh, 05Ah, 084h, 05Ah, 08Dh, 07Fh
   db 091h, 0E8h, 084h, 0E8h, 092h, 0BFh, 0A2h, 024h, 088h, 024h
   db 0A5h, 07Fh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0E6h, 069h
   db 0C4h, 069h, 0BEh, 07Fh, 0D4h, 08Eh, 089h, 08Eh, 0A2h, 03Fh
   db 0CDh, 012h, 04Bh, 012h, 0D9h, 0FFh, 0F9h, 011h, 049h, 011h
   db 0B8h, 0FFh, 0AAh, 079h, 0A6h, 079h, 0B0h, 0FFh, 048h, 0DCh
   db 0A3h, 0DCh, 080h, 0FFh, 047h, 08Fh, 043h, 08Fh, 0C1h, 0FFh
   db 0B3h, 0DFh, 0C7h, 0DFh, 0E3h, 0FFh, 087h, 0F0h, 06Bh, 0F0h
   db 0F0h, 0FFh, 05Ch, 06Fh, 022h, 06Fh, 06Eh, 07Fh, 033h, 0B6h
   db 034h, 0B6h, 06Dh, 03Fh, 0EFh, 059h, 01Dh, 0D9h, 05Ah, 03Fh
   db 0DFh, 00Ah, 01Dh, 0CAh, 05Ch, 03Fh, 0DEh, 00Ch, 0FDh, 00Ch
   db 024h, 03Fh, 0D4h, 00Fh, 085h, 08Fh, 033h, 03Fh, 0EAh, 009h
   db 085h, 009h, 09Fh, 07Fh, 0B4h, 01Eh, 0CEh, 09Eh, 099h, 0FFh
   db 052h, 016h, 07Ah, 016h, 058h, 0FFh, 014h, 07Ah, 067h, 07Ah
   db 076h, 07Fh, 058h, 0C8h, 05Bh, 0C8h, 06Eh, 07Fh, 09Fh, 0A4h
   db 05Ah, 024h, 068h, 0FFh, 0F3h, 064h, 0D2h, 064h, 034h, 0FFh
   db 0CDh, 08Ch, 0A3h, 00Ch, 029h, 0FFh, 0B0h, 0FFh, 0A3h, 0FFh
   db 031h, 0FFh, 0EFh, 0EFh, 0EFh, 0EFh, 0EFh, 0FFh, 0C7h, 0D7h
   db 0C7h, 0D7h, 0D7h, 0FFh, 08Bh, 087h, 08Bh, 087h, 0B3h, 0FFh
   db 041h, 021h, 049h, 021h, 029h, 0FFh, 049h, 043h, 041h, 043h
   db 051h, 0FFh, 095h, 021h, 085h, 021h, 041h, 0FFh, 053h, 029h
   db 021h, 029h, 025h, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
   db 000h, 000h, 000h, 000h, 001h, 0FFh, 000h, 010h, 000h, 010h
   db 001h, 0FFh, 010h, 000h, 010h, 000h, 011h, 0FFh, 000h, 010h
   db 000h, 010h, 001h, 0FFh, 000h, 000h, 000h, 000h, 001h, 0FFh
   db 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 055h, 055h, 055h, 055h
   db 055h, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0F8h, 08Fh
   db 0FFh, 0FFh, 0A4h, 0FFh, 0E4h, 003h, 093h, 0FFh, 084h, 0FFh
   db 0D0h, 009h, 000h, 0FFh, 09Ah, 0FFh, 084h, 061h, 084h, 07Fh
   db 08Ah, 0FFh, 081h, 0F8h, 080h, 07Fh, 0A6h, 0FFh, 027h, 054h
   db 0F0h, 0BFh, 0D6h, 0FFh, 00Dh, 0EDh, 0ACh, 03Fh, 0A4h, 0FFh
   db 013h, 039h, 0AAh, 03Fh, 0B4h, 0FFh, 01Ah, 013h, 0F6h, 03Fh
   db 0AAh, 0FFh, 026h, 00Fh, 019h, 03Fh, 08Ah, 0FFh, 0B6h, 00Eh
   db 00Bh, 07Fh, 08Eh, 0FFh, 09Eh, 00Eh, 00Eh, 07Fh, 08Ah, 0FFh
   db 0E2h, 004h, 011h, 0FFh, 0CEh, 0FFh, 0FFh, 004h, 01Fh, 0FFh
   db 0EAh, 0FFh, 0FFh, 004h, 01Fh, 0FFh, 096h, 0FFh, 0FFh, 08Eh
   db 03Fh, 0FFh, 092h, 0FFh
		
MapTiles_Round3:
   db 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0B8h, 01Dh, 099h, 099h
   db 0B8h, 01Dh, 060h, 006h, 044h, 044h, 060h, 006h, 043h, 0C2h
   db 055h, 055h, 043h, 0C2h, 0CCh, 033h, 0AAh, 0AAh, 0CCh, 033h
   db 08Ah, 051h, 0FFh, 0FFh, 08Ah, 051h, 096h, 079h, 0FFh, 0FFh
   db 096h, 079h, 091h, 089h, 0FFh, 0FFh, 091h, 089h, 091h, 089h
   db 0FFh, 0FFh, 091h, 089h, 096h, 079h, 0FFh, 0FFh, 096h, 079h
   db 08Ah, 071h, 0FFh, 0FFh, 08Ah, 071h, 0CEh, 072h, 0AAh, 0AAh
   db 0CEh, 073h, 043h, 0C2h, 055h, 055h, 043h, 0C2h, 060h, 006h
   db 044h, 044h, 060h, 006h, 0B8h, 01Dh, 099h, 099h, 0B8h, 01Dh
   db 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
   db 0FFh, 0FFh, 0F0h, 007h, 0F0h, 007h, 0F0h, 03Fh, 0CAh, 049h
   db 0CAh, 049h, 0CAh, 03Fh, 0B0h, 000h, 0B0h, 000h, 0B0h, 03Fh
   db 0A7h, 0F0h, 0A7h, 0F0h, 0A7h, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
   db 0FFh, 0FFh, 001h, 0C0h, 001h, 0C0h, 001h, 0FFh, 088h, 0BCh
   db 088h, 0BCh, 088h, 0BFh, 000h, 0A8h, 000h, 0A8h, 000h, 0BFh
   db 001h, 0C0h, 001h, 0C0h, 001h, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
   db 0FFh, 0FFh, 0A7h, 0F0h, 0A7h, 0F0h, 0A7h, 0FFh, 090h, 000h
   db 090h, 000h, 090h, 03Fh, 0C0h, 001h, 0C0h, 001h, 0C0h, 03Fh
   db 0F0h, 007h, 0F0h, 007h, 0F0h, 03Fh, 0FFh, 0FFh, 0FFh, 0FFh
   db 0FFh, 0FFh, 01Fh, 0FFh, 0FFh, 0FFh, 0FEh, 03Fh, 0E8h, 000h
   db 000h, 000h, 005h, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
   db 01Fh, 0FFh, 0FFh, 0FFh, 0FEh, 03Fh, 008h, 000h, 000h, 000h
   db 004h, 03Fh, 008h, 000h, 000h, 000h, 004h, 03Fh, 008h, 000h
   db 000h, 000h, 004h, 03Fh, 008h, 000h, 000h, 000h, 004h, 03Fh
   db 008h, 000h, 000h, 000h, 004h, 03Fh, 008h, 000h, 000h, 000h
   db 004h, 03Fh, 008h, 000h, 000h, 000h, 004h, 03Fh, 008h, 000h
   db 000h, 000h, 004h, 03Fh, 008h, 000h, 000h, 000h, 004h, 03Fh
   db 008h, 000h, 000h, 000h, 004h, 03Fh, 01Fh, 0FFh, 0FFh, 0FFh
   db 0FEh, 03Fh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
   db 0FFh, 0FFh, 0FFh, 0FFh, 000h, 000h, 000h, 000h, 000h, 07Fh
   db 000h, 000h, 000h, 000h, 000h, 07Fh, 0FFh, 0FFh, 0FFh, 0FFh
   db 0FFh, 0FFh, 041h, 008h, 041h, 008h, 041h, 07Fh, 063h, 008h
   db 063h, 008h, 063h, 07Fh, 036h, 01Ch, 036h, 01Ch, 036h, 07Fh
   db 01Ch, 036h, 01Ch, 036h, 01Ch, 07Fh, 008h, 063h, 008h, 063h
   db 008h, 07Fh, 080h, 0C1h, 080h, 0C1h, 080h, 0FFh, 0C1h, 0FFh
   db 0C1h, 0FFh, 0C1h, 0FFh, 0E3h, 0FFh, 0E3h, 0FFh, 0E3h, 0FFh
   db 03Eh, 000h, 03Eh, 000h, 03Eh, 07Fh, 014h, 000h, 014h, 000h
   db 014h, 07Fh, 014h, 000h, 014h, 000h, 014h, 07Fh, 0F7h, 0FFh
   db 0F7h, 0FFh, 0F7h, 0FFh, 0FDh, 0FDh, 0FDh, 0FDh, 0FDh, 0FFh
   db 07Bh, 07Bh, 07Bh, 07Bh, 07Bh, 07Fh, 0B7h, 0B7h, 0B7h, 0B7h
   db 0B7h, 0BFh, 0DFh, 0DFh, 0DFh, 0DFh, 0DFh, 0FFh, 0EFh, 0EFh
   db 0EFh, 0EFh, 0EFh, 0FFh, 0B7h, 0B7h, 0B7h, 0B7h, 0B7h, 0BFh
   db 07Bh, 07Bh, 07Bh, 07Bh, 07Bh, 07Fh, 0FEh, 0FEh, 0FEh, 0FEh
   db 0FEh, 0FFh, 0FDh, 0FDh, 0FDh, 0FDh, 0FDh, 0FFh, 07Bh, 07Bh
   db 07Bh, 07Bh, 07Bh, 07Fh, 0B7h, 0B7h, 0B7h, 0B7h, 0B7h, 0BFh
   db 0DFh, 0DFh, 0DFh, 0DFh, 0DFh, 0FFh, 0EFh, 0EFh, 0EFh, 0EFh
   db 0EFh, 0FFh, 0B7h, 0B7h, 0B7h, 0B7h, 0B7h, 0BFh, 07Bh, 07Bh
   db 07Bh, 07Bh, 07Bh, 07Fh, 0FEh, 0FEh, 0FEh, 0FEh, 0FEh, 0FFh
   db 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FCh, 044h, 044h, 044h
   db 047h, 0FFh, 0E4h, 044h, 044h, 044h, 044h, 0FFh, 0C7h, 0FFh
   db 0FFh, 0FFh, 0FCh, 07Fh, 0CCh, 07Bh, 0BBh, 0BBh, 0C6h, 07Fh
   db 0F8h, 031h, 011h, 011h, 083h, 0FFh, 091h, 01Bh, 0BBh, 0BBh
   db 011h, 03Fh, 093h, 09Fh, 0FFh, 0FFh, 039h, 03Fh, 091h, 01Ah
   db 0AAh, 0ABh, 011h, 03Fh, 0F8h, 035h, 055h, 055h, 083h, 0FFh
   db 0CCh, 06Ah, 0AAh, 0AAh, 0C6h, 07Fh, 0C7h, 0FFh, 0FFh, 0FFh
   db 0FCh, 07Fh, 0E4h, 044h, 044h, 044h, 044h, 0FFh, 0FCh, 044h
   db 044h, 044h, 047h, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
   db 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
   db 001h, 03Fh, 088h, 088h, 088h, 0FFh, 001h, 03Fh, 0FFh, 0FFh
   db 0FFh, 0FFh, 001h, 03Fh, 000h, 000h, 000h, 07Fh, 0DFh, 07Fh
   db 020h, 002h, 002h, 07Fh, 0D1h, 07Fh, 000h, 000h, 000h, 07Fh
   db 0D1h, 03Fh, 0FFh, 0FFh, 0FFh, 0FFh, 0D1h, 03Fh, 088h, 088h
   db 088h, 0FFh, 0D5h, 03Fh, 088h, 088h, 088h, 0FFh, 0D5h, 03Fh
   db 088h, 088h, 088h, 0FFh, 0D5h, 07Fh, 0FFh, 0FFh, 0FFh, 0FFh
   db 0D5h, 07Fh, 000h, 000h, 000h, 07Fh, 0D5h, 07Fh, 020h, 020h
   db 002h, 07Fh, 0D5h, 07Fh, 000h, 000h, 000h, 07Fh, 011h, 07Fh
   db 0FFh, 0FFh, 0FFh, 0FFh, 011h, 07Fh, 088h, 088h, 088h, 0FFh
   db 011h, 07Fh, 060h, 03Fh, 0FFh, 0FFh, 0F3h, 0FFh, 060h, 03Fh
   db 070h, 03Fh, 0D2h, 0FFh, 060h, 03Fh, 0FFh, 0FFh, 092h, 07Fh
   db 0FFh, 0FFh, 070h, 03Fh, 092h, 07Fh, 0B0h, 07Fh, 070h, 07Fh
   db 012h, 03Fh, 0B0h, 07Fh, 052h, 0BFh, 033h, 03Fh, 0B0h, 07Fh
   db 09Ah, 0BFh, 033h, 03Fh, 0B0h, 07Fh, 0DAh, 0FFh, 03Fh, 03Fh
   db 0B0h, 07Fh, 05Ah, 0BFh, 03Fh, 03Fh, 0B0h, 07Fh, 05Ah, 0BFh
   db 033h, 03Fh, 0B0h, 07Fh, 0B4h, 0BFh, 033h, 03Fh, 0B0h, 07Fh
   db 0B0h, 0BFh, 012h, 03Fh, 0B0h, 07Fh, 088h, 03Fh, 092h, 07Fh
   db 0B0h, 07Fh, 0B0h, 03Fh, 092h, 07Fh, 0B0h, 07Fh, 070h, 03Fh
   db 0D2h, 0FFh, 0FFh, 0FFh, 0B8h, 07Fh, 0F3h, 0FFh, 0FFh, 0FFh
   db 0FFh, 0FFh, 080h, 0BFh, 080h, 000h, 000h, 07Fh, 0C0h, 07Fh
   db 077h, 0D7h, 076h, 0BFh, 0A0h, 03Fh, 07Ah, 0AAh, 040h, 0BFh
   db 0F0h, 03Fh, 055h, 000h, 000h, 03Fh, 088h, 03Fh, 068h, 000h
   db 000h, 03Fh, 004h, 07Fh, 030h, 000h, 000h, 0BFh, 003h, 0FFh
   db 068h, 000h, 000h, 03Fh, 001h, 07Fh, 050h, 000h, 000h, 0BFh
   db 080h, 0FFh, 040h, 000h, 000h, 0BFh, 0C0h, 07Fh, 020h, 000h
   db 001h, 03Fh, 0A0h, 03Fh, 040h, 000h, 005h, 0BFh, 0F0h, 03Fh
   db 040h, 000h, 002h, 0BFh, 088h, 03Fh, 000h, 000h, 017h, 0BFh
   db 004h, 07Fh, 040h, 082h, 02Dh, 0BFh, 003h, 0FFh, 080h, 000h
   db 000h, 07Fh, 001h, 07Fh

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

	org $7d00
	
Charset:
   db 000h, 07Fh, 0D1h, 03Fh, 0FFh, 0FFh, 0FFh, 0FFh, 0D1h, 03Fh
   db 088h, 088h, 088h, 0FFh, 0D5h, 03Fh, 088h, 088h, 088h, 0FFh
   db 0D5h, 03Fh, 088h, 088h, 088h, 0FFh, 0D5h, 07Fh, 0FFh, 0FFh
   db 0FFh, 0FFh, 0D5h, 07Fh, 000h, 000h, 000h, 07Fh, 0D5h, 07Fh
   db 020h, 020h, 002h, 07Fh, 0D5h, 07Fh, 000h, 000h, 000h, 07Fh
   db 011h, 07Fh, 0FFh, 0FFh, 0FFh, 0FFh, 011h, 07Fh, 088h, 088h
   db 088h, 0FFh, 011h, 07Fh, 060h, 03Fh, 0FFh, 0FFh, 0F3h, 0FFh
   db 060h, 03Fh, 070h, 03Fh, 0D2h, 0FFh, 060h, 03Fh, 0FFh, 0FFh
   db 092h, 07Fh, 0FFh, 0FFh, 070h, 03Fh, 092h, 07Fh, 0B0h, 07Fh
   db 070h, 07Fh, 012h, 03Fh, 0B0h, 07Fh, 052h, 0BFh, 033h, 03Fh
   db 0B0h, 07Fh, 09Ah, 0BFh, 033h, 03Fh, 0B0h, 07Fh, 0DAh, 0FFh
   db 03Fh, 03Fh, 0B0h, 07Fh, 05Ah, 0BFh, 03Fh, 03Fh, 0B0h, 07Fh
   db 05Ah, 0BFh, 033h, 03Fh, 0B0h, 07Fh, 0B4h, 0BFh, 033h, 03Fh
   db 0B0h, 07Fh, 0B0h, 0BFh, 012h, 03Fh, 0B0h, 07Fh, 088h, 03Fh
   db 092h, 07Fh, 0B0h, 07Fh, 0B0h, 03Fh, 092h, 07Fh, 0B0h, 07Fh
   db 070h, 03Fh, 0D2h, 0FFh, 0FFh, 0FFh, 0B8h, 07Fh, 0F3h, 0FFh
   db 0FFh, 0FFh, 0FFh, 0FFh, 080h, 0BFh, 080h, 000h, 000h, 07Fh
   db 0C0h, 07Fh, 077h, 0D7h, 076h, 0BFh, 0A0h, 03Fh, 07Ah, 0AAh
   db 040h, 0BFh, 0F0h, 03Fh, 055h, 000h, 000h, 03Fh, 088h, 03Fh
   db 068h, 000h, 000h, 03Fh, 004h, 07Fh, 030h, 000h, 000h, 0BFh
   db 003h, 0FFh, 068h, 000h, 000h, 03Fh, 001h, 07Fh, 050h, 000h
   db 000h, 0BFh, 080h, 0FFh, 040h, 000h, 000h, 0BFh, 0C0h, 07Fh
   db 020h, 000h, 001h, 03Fh, 0A0h, 03Fh, 040h, 000h, 005h, 0BFh
   db 0F0h, 03Fh, 040h, 000h, 002h, 0BFh, 088h, 03Fh, 000h, 000h
   db 017h, 0BFh, 004h, 07Fh, 040h, 082h, 02Dh, 0BFh, 003h, 0FFh
   db 080h, 000h, 000h, 07Fh, 001h, 07Fh, 000h, 000h, 000h, 000h
   db 000h, 000h, 000h, 000h, 010h, 07Ah, 0F1h, 059h, 00Dh, 036h
   db 06Fh, 0C3h, 000h, 024h, 024h, 000h, 000h, 000h, 000h, 000h
   db 000h, 024h, 07Eh, 024h, 024h, 07Eh, 024h, 000h, 000h, 008h
   db 03Eh, 028h, 03Eh, 00Ah, 03Eh, 008h, 000h, 062h, 064h, 008h
   db 010h, 026h, 046h, 000h, 000h, 010h, 028h, 010h, 02Ah, 044h
   db 03Ah, 000h, 000h, 008h, 010h, 000h, 000h, 000h, 000h, 000h
   db 000h, 004h, 008h, 008h, 008h, 008h, 004h, 000h, 000h, 020h
   db 010h, 010h, 010h, 010h, 020h, 000h, 010h, 010h, 038h, 0FEh
   db 038h, 044h, 082h, 000h, 000h, 000h, 008h, 008h, 03Eh, 008h
   db 008h, 000h, 000h, 000h, 000h, 000h, 000h, 008h, 008h, 010h
   db 000h, 000h, 000h, 030h, 05Ah, 00Ch, 000h, 000h, 000h, 000h
   db 000h, 000h, 000h, 018h, 018h, 000h, 000h, 000h, 002h, 004h
   db 008h, 010h, 020h, 000h, 03Ch, 062h, 062h, 062h, 062h, 062h
   db 03Ch, 000h, 018h, 038h, 018h, 018h, 018h, 018h, 018h, 000h
   db 03Ch, 062h, 002h, 03Ch, 060h, 060h, 07Eh, 000h, 03Ch, 062h
   db 002h, 01Ch, 002h, 062h, 03Ch, 000h, 03Ch, 04Ch, 04Ch, 03Eh
   db 00Ch, 00Ch, 00Ch, 000h, 03Eh, 060h, 060h, 07Ch, 002h, 002h
   db 07Ch, 000h, 03Ch, 062h, 060h, 07Ch, 062h, 062h, 03Ch, 000h
   db 07Eh, 006h, 006h, 006h, 006h, 006h, 006h, 000h, 03Ch, 062h
   db 062h, 03Ch, 062h, 062h, 03Ch, 000h, 03Ch, 062h, 062h, 03Eh
   db 002h, 062h, 03Ch, 000h, 07Ch, 040h, 040h, 040h, 046h, 046h
   db 07Ch, 000h, 03Ch, 046h, 006h, 03Ch, 040h, 046h, 03Ch, 000h
   db 07Ch, 006h, 006h, 03Eh, 006h, 006h, 006h, 000h, 000h, 000h
   db 000h, 03Eh, 000h, 03Eh, 000h, 000h, 000h, 000h, 010h, 008h
   db 004h, 008h, 010h, 000h, 03Ch, 062h, 002h, 01Ch, 018h, 000h
   db 018h, 000h, 000h, 03Ch, 04Ah, 056h, 05Eh, 040h, 03Ch, 000h
   db 03Ch, 062h, 062h, 07Eh, 062h, 062h, 062h, 000h, 03Ch, 062h
   db 062h, 07Ch, 062h, 062h, 07Ch, 000h, 03Ch, 062h, 060h, 060h
   db 060h, 062h, 07Ch, 000h, 03Ch, 062h, 062h, 062h, 062h, 062h
   db 07Ch, 000h, 03Eh, 060h, 060h, 07Ch, 060h, 060h, 07Eh, 000h
   db 03Eh, 060h, 060h, 07Ch, 060h, 060h, 060h, 000h, 03Ch, 062h
   db 060h, 060h, 066h, 062h, 07Ch, 000h, 062h, 062h, 062h, 07Eh
   db 062h, 062h, 062h, 000h, 07Eh, 018h, 018h, 018h, 018h, 018h
   db 07Eh, 000h, 03Eh, 002h, 002h, 002h, 062h, 062h, 03Eh, 000h
   db 062h, 062h, 064h, 078h, 064h, 062h, 062h, 000h, 060h, 060h
   db 060h, 060h, 060h, 060h, 07Eh, 000h, 03Ch, 06Ah, 06Ah, 06Ah
   db 06Ah, 06Ah, 06Ah, 000h, 03Ch, 062h, 062h, 062h, 062h, 062h
   db 062h, 000h, 03Ch, 062h, 062h, 062h, 062h, 062h, 03Ch, 000h
   db 03Ch, 062h, 062h, 07Ch, 060h, 060h, 060h, 000h, 03Ch, 062h
   db 062h, 062h, 06Ch, 06Eh, 036h, 000h, 03Ch, 062h, 062h, 07Ch
   db 062h, 062h, 062h, 000h, 03Ch, 062h, 060h, 03Ch, 002h, 062h
   db 03Ch, 000h, 07Eh, 018h, 018h, 018h, 018h, 018h, 018h, 000h
   db 062h, 062h, 062h, 062h, 062h, 062h, 03Ch, 000h, 062h, 062h
   db 062h, 062h, 062h, 034h, 018h, 000h, 06Ah, 06Ah, 06Ah, 06Ah
   db 06Ah, 06Ah, 03Ch, 000h, 042h, 024h, 018h, 018h, 018h, 024h
   db 042h, 000h, 062h, 062h, 034h, 018h, 018h, 018h, 018h, 000h
   db 03Eh, 044h, 008h, 010h, 020h, 042h, 07Ch, 000h, 0EEh, 0EEh
   db 088h, 08Eh, 082h, 0EEh, 0EEh, 000h, 0EEh, 0EEh, 088h, 0EEh
   db 022h, 0EEh, 0EEh, 000h, 0EEh, 0EEh, 08Ah, 0EEh, 028h, 0E8h
   db 0E8h, 000h, 0EEh, 0EEh, 08Ah, 0EAh, 08Ah, 0EAh, 0EAh, 000h
   db 000h, 000h, 000h, 000h, 000h, 000h, 000h
	

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
; PAGE $00 
;
	org $8000	

data_8000:

;
; MapBuffer also doubles up as a fast memory buffer for the PlipPlopPlayer to run in.
;
	
MapBuffer:	
Map_Round1:

   db 002h, 01Fh, 002h, 01Fh, 002h, 01Fh, 002h, 01Fh, 002h, 01Fh
   db 002h, 01Fh, 002h, 01Fh, 002h, 01Fh, 002h, 01Fh, 002h, 01Fh
   db 002h, 01Fh, 002h, 01Fh, 002h, 01Fh, 002h, 01Fh, 002h, 01Fh
   db 002h, 01Fh, 003h, 01Fh, 000h, 03Fh, 006h, 02Dh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 006h, 02Dh, 000h, 03Fh, 000h, 03Fh
   db 006h, 02Dh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 006h, 02Dh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 011h, 036h, 012h, 036h, 012h, 036h, 012h, 036h
   db 012h, 036h, 012h, 036h, 012h, 036h, 012h, 036h, 012h, 036h
   db 012h, 036h, 013h, 036h, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 00Dh, 02Dh, 00Fh, 02Dh, 000h, 02Dh, 00Dh, 02Dh
   db 00Eh, 02Dh, 00Fh, 02Dh, 000h, 02Dh, 00Dh, 02Dh, 00Fh, 02Dh
   db 000h, 02Dh, 00Dh, 02Dh, 00Fh, 02Dh, 000h, 02Dh, 00Dh, 02Dh
   db 00Eh, 02Dh, 00Fh, 02Dh, 000h, 02Dh, 00Dh, 02Dh, 00Fh, 02Dh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 019h, 09Fh
   db 01Ah, 09Fh, 01Bh, 09Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 001h, 01Fh
   db 002h, 01Fh, 002h, 01Fh, 002h, 01Fh, 005h, 02Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 006h, 02Dh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 005h, 02Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 006h, 02Dh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 005h, 02Fh
   db 000h, 03Fh, 006h, 02Dh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 006h, 02Dh, 000h, 03Fh, 000h, 03Fh, 006h, 02Dh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 006h, 02Dh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 011h, 036h
   db 012h, 036h, 012h, 036h, 012h, 036h, 012h, 036h, 012h, 036h
   db 012h, 036h, 012h, 036h, 012h, 036h, 012h, 036h, 013h, 036h
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 00Dh, 02Dh
   db 00Fh, 02Dh, 000h, 02Dh, 00Dh, 02Dh, 00Eh, 02Dh, 00Fh, 02Dh
   db 000h, 02Dh, 00Dh, 02Dh, 00Fh, 02Dh, 000h, 02Dh, 00Dh, 02Dh
   db 00Fh, 02Dh, 000h, 02Dh, 00Dh, 02Dh, 00Eh, 02Dh, 00Fh, 02Dh
   db 000h, 02Dh, 00Dh, 02Dh, 00Fh, 02Dh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 01Dh, 02Dh
   db 000h, 03Fh, 000h, 03Fh, 01Fh, 01Bh, 000h, 01Bh, 01Fh, 01Bh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 006h, 029h, 000h, 03Fh, 000h, 03Fh
   db 006h, 029h, 001h, 09Fh, 002h, 09Fh, 002h, 09Fh, 002h, 09Fh
   db 002h, 09Fh, 002h, 09Fh, 002h, 09Fh, 002h, 09Fh, 002h, 09Fh
   db 002h, 09Fh, 002h, 09Fh, 002h, 09Fh, 002h, 09Fh, 002h, 09Fh
   db 002h, 09Fh, 002h, 09Fh, 003h, 09Fh, 000h, 03Fh, 001h, 0B2h
   db 002h, 0B2h, 002h, 0B2h, 002h, 0B2h, 002h, 0B2h, 002h, 0B2h
   db 002h, 0B2h, 002h, 0B2h, 002h, 0B2h, 002h, 0B2h, 002h, 0B2h
   db 003h, 0B2h, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 011h, 036h, 012h, 036h, 012h, 036h
   db 012h, 036h, 012h, 036h, 012h, 036h, 012h, 036h, 012h, 036h
   db 012h, 036h, 012h, 036h, 013h, 036h, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 00Dh, 02Dh, 00Eh, 02Dh, 00Eh, 02Dh
   db 00Eh, 02Dh, 00Eh, 02Dh, 00Eh, 02Dh, 00Eh, 02Dh, 00Eh, 02Dh
   db 00Fh, 02Dh, 000h, 02Dh, 00Dh, 02Dh, 00Eh, 02Dh, 00Eh, 02Dh
   db 00Eh, 02Dh, 00Eh, 02Dh, 00Eh, 02Dh, 00Eh, 02Dh, 00Eh, 02Dh
   db 00Fh, 02Dh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 019h, 09Fh, 01Ah, 09Fh, 01Bh, 09Fh, 000h, 03Fh
   db 019h, 09Fh, 01Ah, 09Fh, 01Bh, 09Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 001h, 096h, 002h, 096h, 002h, 096h, 003h, 096h, 006h, 02Dh
   db 000h, 03Fh, 000h, 03Fh, 007h, 0B6h, 005h, 0AFh, 007h, 0B6h
   db 000h, 03Fh, 000h, 03Fh, 006h, 02Dh, 000h, 03Fh, 000h, 03Fh
   db 007h, 0B6h, 005h, 0AFh, 007h, 0B6h, 000h, 03Fh, 000h, 03Fh
   db 006h, 02Dh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 001h, 08Dh, 002h, 08Dh
   db 002h, 08Dh, 002h, 08Dh, 002h, 08Dh, 002h, 08Dh, 002h, 08Dh
   db 002h, 08Dh, 002h, 08Dh, 002h, 08Dh, 002h, 08Dh, 002h, 08Dh
   db 002h, 08Dh, 002h, 08Dh, 003h, 08Dh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 009h, 09Fh, 00Ah, 09Fh, 00Ah, 09Fh, 00Ah, 09Fh, 00Ah, 09Fh
   db 00Ah, 09Fh, 00Ah, 09Fh, 00Ah, 09Fh, 00Bh, 09Fh, 000h, 03Fh
   db 009h, 09Fh, 00Ah, 09Fh, 00Ah, 09Fh, 00Ah, 09Fh, 00Ah, 09Fh
   db 00Ah, 09Fh, 00Ah, 09Fh, 00Ah, 09Fh, 00Bh, 09Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 019h, 09Fh, 01Ah, 09Fh, 01Bh, 09Fh, 01Eh, 01Bh
   db 000h, 01Bh, 01Fh, 01Bh, 000h, 03Fh, 01Eh, 01Bh, 000h, 01Bh
   db 01Fh, 01Bh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 001h, 09Fh, 002h, 09Fh, 002h, 09Fh
   db 002h, 09Fh, 002h, 09Fh, 002h, 09Fh, 002h, 09Fh, 002h, 09Fh
   db 002h, 09Fh, 002h, 09Fh, 002h, 09Fh, 002h, 09Fh, 002h, 09Fh
   db 002h, 09Fh, 002h, 09Fh, 002h, 09Fh, 003h, 09Fh, 000h, 03Fh
   db 001h, 096h, 002h, 096h, 002h, 096h, 002h, 096h, 003h, 096h
   db 000h, 03Fh, 000h, 03Fh, 001h, 096h, 002h, 096h, 002h, 096h
   db 002h, 096h, 003h, 096h, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 007h, 0ADh, 007h, 0ADh
   db 006h, 020h, 000h, 020h, 005h, 023h, 000h, 020h, 005h, 023h
   db 000h, 020h, 006h, 020h, 007h, 0ADh, 007h, 0ADh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 00Dh, 09Bh, 00Fh, 09Bh, 000h, 03Fh, 000h, 03Fh, 00Dh, 029h
   db 00Fh, 029h, 000h, 02Dh, 00Dh, 029h, 00Eh, 029h, 00Eh, 029h
   db 00Fh, 029h, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 00Dh, 029h
   db 00Eh, 029h, 00Eh, 029h, 00Fh, 029h, 000h, 02Dh, 00Dh, 029h
   db 00Fh, 029h, 000h, 03Fh, 000h, 03Fh, 00Dh, 09Bh, 00Fh, 09Bh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 019h, 09Fh, 01Ah, 09Fh, 01Ah, 09Fh
   db 01Ah, 09Fh, 01Ah, 09Fh, 01Ah, 09Fh, 01Ah, 09Fh, 01Bh, 09Fh
   db 000h, 03Fh, 019h, 09Fh, 01Ah, 09Fh, 01Bh, 09Fh, 019h, 01Fh
   db 01Bh, 09Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 005h, 0AFh, 007h, 0B6h, 000h, 03Fh, 000h, 03Fh, 006h, 02Dh
   db 000h, 03Fh, 000h, 03Fh, 007h, 0B6h, 005h, 0AFh, 007h, 0B6h
   db 000h, 03Fh, 000h, 03Fh, 006h, 02Dh, 000h, 03Fh, 000h, 03Fh
   db 007h, 0B6h, 005h, 0AFh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 005h, 02Eh, 000h, 03Fh, 000h, 03Fh, 007h, 099h, 007h, 099h
   db 000h, 03Fh, 000h, 03Fh, 005h, 02Eh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 017h, 09Bh, 015h, 0BFh, 016h, 0BFh, 015h, 09Bh
   db 016h, 09Bh, 015h, 0BFh, 016h, 0BFh, 017h, 09Bh, 015h, 0BFh
   db 016h, 0BFh, 017h, 09Bh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 00Dh, 09Bh, 00Fh, 09Bh, 00Dh, 02Dh, 00Fh, 02Dh, 000h, 02Dh
   db 00Dh, 02Dh, 00Eh, 02Dh, 00Eh, 02Dh, 00Fh, 02Dh, 00Dh, 096h
   db 00Eh, 096h, 00Fh, 096h, 00Dh, 02Dh, 00Eh, 02Dh, 00Eh, 02Dh
   db 00Fh, 02Dh, 000h, 02Dh, 00Dh, 02Dh, 00Fh, 02Dh, 00Dh, 09Bh
   db 00Fh, 09Bh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 019h, 09Fh, 01Ah, 09Fh
   db 01Ah, 09Fh, 01Ah, 09Fh, 01Bh, 09Fh, 000h, 01Bh, 000h, 01Bh
   db 000h, 01Bh, 000h, 01Bh, 019h, 09Fh, 01Ah, 09Fh, 01Bh, 09Fh
   db 000h, 03Fh, 019h, 09Fh, 01Ah, 09Fh, 01Bh, 09Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 001h, 09Fh, 002h, 09Fh
   db 002h, 09Fh, 002h, 09Fh, 002h, 09Fh, 002h, 09Fh, 002h, 09Fh
   db 002h, 09Fh, 002h, 09Fh, 002h, 09Fh, 002h, 09Fh, 002h, 09Fh
   db 002h, 09Fh, 002h, 09Fh, 002h, 09Fh, 002h, 09Fh, 003h, 09Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 006h, 02Dh, 000h, 03Fh
   db 007h, 099h, 007h, 099h, 007h, 099h, 007h, 099h, 000h, 03Fh
   db 006h, 02Dh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 017h, 0BFh, 017h, 09Bh, 015h, 0BFh
   db 016h, 0BFh, 017h, 09Bh, 017h, 0BFh, 015h, 09Bh, 016h, 09Bh
   db 017h, 0BFh, 015h, 09Bh, 016h, 09Bh, 017h, 0BFh, 015h, 09Bh
   db 016h, 09Bh, 017h, 0BFh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 00Dh, 09Bh, 00Fh, 09Bh, 000h, 03Fh, 000h, 03Fh
   db 00Dh, 02Dh, 00Eh, 02Dh, 00Eh, 02Dh, 00Eh, 02Dh, 00Eh, 02Dh
   db 00Eh, 02Dh, 00Fh, 02Dh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 00Dh, 02Dh, 00Eh, 02Dh, 00Eh, 02Dh, 00Eh, 02Dh, 00Eh, 02Dh
   db 00Eh, 02Dh, 00Fh, 02Dh, 000h, 03Fh, 000h, 03Fh, 00Dh, 09Bh
   db 00Fh, 09Bh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 019h, 09Fh, 01Ah, 09Fh, 01Bh, 09Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 019h, 09Fh, 01Ah, 09Fh, 01Ah, 09Fh, 01Ah, 09Fh
   db 01Ah, 09Fh, 01Ah, 09Fh, 01Bh, 09Fh, 019h, 01Fh, 01Ah, 09Fh
   db 01Bh, 09Fh, 000h, 03Fh, 019h, 09Fh, 01Ah, 09Fh, 01Bh, 09Fh
   db 019h, 01Fh, 01Ah, 09Fh, 01Ah, 09Fh, 01Bh, 09Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 006h, 02Dh, 000h, 03Fh, 000h, 03Fh, 007h, 0B6h
   db 005h, 0AFh, 007h, 0B6h, 000h, 03Fh, 000h, 03Fh, 006h, 02Dh
   db 000h, 03Fh, 000h, 03Fh, 007h, 0B6h, 005h, 0AFh, 007h, 0B6h
   db 000h, 03Fh, 000h, 03Fh, 006h, 02Dh, 007h, 09Bh, 007h, 0B6h
   db 000h, 03Fh, 006h, 02Dh, 007h, 099h, 007h, 099h, 007h, 099h
   db 007h, 099h, 007h, 099h, 007h, 099h, 006h, 02Dh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 015h, 0BFh, 016h, 0BFh
   db 015h, 09Bh, 016h, 09Bh, 017h, 0BFh, 015h, 09Bh, 016h, 09Bh
   db 015h, 0BFh, 016h, 0BFh, 017h, 09Bh, 015h, 0BFh, 016h, 0BFh
   db 017h, 09Bh, 015h, 0BFh, 016h, 0BFh, 015h, 09Bh, 016h, 09Bh
   db 017h, 0BFh, 017h, 09Bh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 009h, 09Fh, 00Ah, 09Fh, 00Ah, 09Fh
   db 00Ah, 09Fh, 00Ah, 09Fh, 00Ah, 09Fh, 00Ah, 09Fh, 00Ah, 09Fh
   db 00Bh, 09Fh, 000h, 03Fh, 009h, 09Fh, 00Ah, 09Fh, 00Ah, 09Fh
   db 00Ah, 09Fh, 00Ah, 09Fh, 00Ah, 09Fh, 00Ah, 09Fh, 00Ah, 09Fh
   db 00Bh, 09Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 019h, 09Fh
   db 01Ah, 09Fh, 01Bh, 09Fh, 019h, 01Fh, 01Ah, 09Fh, 01Ah, 09Fh
   db 01Ah, 09Fh, 01Ah, 09Fh, 01Ah, 09Fh, 01Ah, 09Fh, 01Ah, 09Fh
   db 01Bh, 09Fh, 000h, 01Bh, 000h, 01Bh, 000h, 01Bh, 000h, 01Bh
   db 01Fh, 01Bh, 01Fh, 01Bh, 000h, 01Bh, 01Eh, 01Bh, 01Dh, 036h
   db 01Fh, 01Bh, 000h, 01Bh, 01Fh, 01Bh, 01Fh, 01Bh, 000h, 01Bh
   db 000h, 01Bh, 019h, 09Fh, 01Ah, 09Fh, 01Bh, 09Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh, 000h, 03Fh
   db 000h, 03Fh, 000h, 03Fh, 007h, 0B6h, 007h, 09Bh

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

	org $8800
	
data_8800:				; PAGE $08

	JP   PlayGame
	
; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
; offsets to the four pre-shifts of this sized sprite
;
;
	
Spr4x8:			
	dw $0000			; 0 x 192
	dw $00C0			; 1 x 192
	dw $0180			; 2 x 192
	dw $0240			; 3 x 192

Spr3x8:
	dw $0000			; 0 x 144
	dw $0090			; 1 x 144
	dw $0120			; 2 x 144
	dw $01B0			; 3 x 144

Spr2x8:
	dw $0000			; 0 x 96
	dw $0060			; 1 x 96
	dw $00C0			; 2 x 96
	dw $0120			; 3 x 96

Spr1x8:
	dw $0000			; 0 x 48
	dw $0030			; 1 x 48
	dw $0060			; 2 x 48
	dw $0090			; 3 x 48

SpriteSizes:
	db $04 				; (1 x 8) / 2
	db (Spr1x8 & $ff) 	; $1B			; 881b - SPR1x8 (lowbyte)
	
	db $08 				; (2 x 8) / 2
	db (Spr2x8 & $ff)	; $13 			; 8813 - SPR2x8 (lowbyte)
	
	db $0C 				; (3 x 8) / 2
	db (Spr3x8 & $ff)	; $0B 			; 880b - SPR3x8 (lowbyte)
	
	db $10 				; (4 x 8) / 2
	db (Spr4x8 & $ff)	; $03 			; 8803 - SPR4x8 (lowbyte)

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
; word address of interleaved and zig-zagged sprite data
; byte index into SpriteSizes table
;
	
SpriteGFXTable:
	dw gfx_CobraWalkRight			; Cobra Walk Right
	db $06 
	dw gfx_CobraWalkLeft			; Cobra Walk Left
	db $06 
	dw gfx_CobraJumpRight			; Cobra Jump Right
	db $06 
	dw gfx_CobraJumpLeft			; Cobra Jump Left
	db $06 
	dw gfx_CobraDuckRight			; Cobra Duck Right
	db $04 
	dw gfx_CobraDuckLeft			; Cobra Duck Left
	db $04 
	dw gfx_KnifeRight				; Knife Right
	db $00 
	dw gfx_KnifeLeft				; Knife Left
	db $00 
	dw gfx_PistolRight				; Pistol Right
	db $00 
	dw gfx_PistolLeft				; Pistol Left
	db $00 
	dw gfx_MachineGunRight			; Machine Gun Right
	db $02 
	dw gfx_MachineGunLeft			; Machine Gun Left
	db $02 
	dw gfx_CobraHeadbuttRight		; Headbutt Right
	db $06 
	dw gfx_CobraHeadbuttLeft		; Headbutt left
	db $06 
	dw gfx_GirlfriendLeft			; Girlfriend Left
	db $06 
	dw gfx_GirlfriendRight			; Girlfriend Right
	db $06 
	dw gfx_PirateGuyLeft			; Pirate Guy Left
	db $06 
	dw gfx_PirateGuyRight			; Pirate Guy Right
	db $06 
	dw gfx_KnifeGuyLeft				; Knife Guy Left
	db $06 
	dw gfx_KnifeGuyRight			; Knife Guy Right
	db $06 
	dw gfx_PramLeft					; Pram Left
	db $04 
	dw gfx_PramLeft					; Pram Left (doesn't face right!)
	db $04 
	dw gfx_BazookaLadyLeft			; Bazooka Lady Left
	db $06 
	dw gfx_BazookaLadyRight			; Bazooka Lady Right
	db $06 
	dw gfx_NightSlasherLeft			; Night Slasher Left
	db $04 
	dw gfx_NightSlasherRight		; Night Slasher Right
	db $04 
	dw gfx_Explosion				; Explosion
	db $04 
	
BurgerSpriteAddr:
	dw gfx_Burger				; Burger graphic (modifed by game loop)
	db $02 
	dw gfx_MissileLeft			; Missile Left
	db $00 
	dw gfx_MissileRight			; Missile Right
	db $00 
	
GroundShiftOffsets:
	dw $0000
	dw $0060
	dw $00C0
	dw $0120
	
PushInstructions:
	db $E5 			; PUSH HL
	db $C5 			; PUSH BC
	db $D5 			; PUSH DE
	db $F5 			; PUSH AF
	
ScrollUpdateTable:			; Indexed by ScrollDirection
	db $00 			; what to add to ScrollX
	db $00 			; When to flip scroll tables
	db $FF 			; -1 to ScrollX
	db $07 			; 7 flip at
	db $01 			; 1 to ScrollX
	db $00 			; 0 flip at
	db $00 
	
DirectionTable:
	db $00 			; 0 - no movement
	db $FE 			; 1 - move left (-2)
	db $02 			; 2 - move right (+2)
	db $00 
	
BitTable:
	db $01 
	db $02 
	db $04 
	db $08 
	db $10 
	db $20 
	db $40 
	db $80 
	
SelfModInstructionTable:
	db $00 			; NOP
	db $07 			; rlca
	db $0F 			; rrca
	db $00 			; nop
	db $00 			; nop
	db $0D 			; dec c
	db $0C 			; inc c
	db $00 			; nop
	db $00 			; nop
	
PlayerX:
	db $70 	
PlayerY:
	db $60 
PlayerDir:			; bit 1 left / right, bit 2, in air, bit 3, duck down
	db $00 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
; Sprite data strutures - SpriteData structure 7 bytes each
;
	
SpriteData:			

	db $0B 			; TYP
	db $7A 			; XNO
	db $64 			; YNO
	db $1A 			; GNO
	db $00 			; XSPD
	db $00 			; XCNT
	db $EC 			; YCNT
	
SpriteDataGeneral:
	db $0B 
	db $7A 
	db $50 
	db $1A 
	db $04 
	db $BE 
	db $EC 

	db $0B 
	db $6A 
	db $68 
	db $1A 
	db $04 
	db $08 
	db $EC 

	db $0B 
	db $8A 
	db $68 
	db $1A 
	db $03 
	db $00 
	db $EC 

	db $0B 
	db $6A 
	db $58 
	db $1A 
	db $04 
	db $70 
	db $EC 

	db $0B 
	db $8A 
	db $58 
	db $1A 
	db $01 
	db $01 
	db $EC 

	db $0B 
	db $7A 
	db $74 
	db $1A 
	db $03 
	db $03 
	db $EC 
	
	db $00 
SpriteDataLastXNO:
	db $78 
SpriteDataLastYNO:
	db $C8 
SpriteDataLastGNO:
	db $06 
	db $00 
	db $00 

Score:
	db $30 
	db $30 
	db $30 
	db $37 
	db $30 
	db $30 
	
ExtraLifeScore:
	db $30 
	db $31 
	db $30 
	db $30 
	db $30 
	db $30 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
; Player weapon function table.
;

PlayerWeaponRoutines:
	dw DoHeadbutt
	dw DoKnifeThrow
	dw DoFireGun
	dw DoFireMachineGun

NumBaddiesToKill:
	dw $0028

InitialNumBaddiesToKill:
	dw $0014
	db $00 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
; PushMapEven - (generated) code to draw the pre-shifted map tiles.
;
	org $8900		; PAGE $09

PushMapEven:
	PUSH HL
	PUSH HL
	PUSH HL
	PUSH HL
	PUSH HL
	PUSH AF
	PUSH BC
	PUSH HL
	PUSH AF
	PUSH DE
	PUSH BC
	PUSH HL
	PUSH AF
	PUSH BC
	JP   NextScanLine
	
	PUSH AF
	PUSH AF 
	PUSH AF
	PUSH AF
	PUSH AF
	PUSH AF
	PUSH AF
	PUSH AF 
	PUSH AF 
	PUSH AF
	PUSH AF
	PUSH AF 
	PUSH AF
	PUSH HL
	PUSH HL
	PUSH HL
	PUSH HL
	PUSH HL
	PUSH AF
	PUSH BC
	PUSH HL
	PUSH AF
	PUSH DE
	PUSH BC
	PUSH HL
	PUSH AF
	PUSH BC
	JP   NextScanLine
	
	PUSH AF
	PUSH AF 
	PUSH AF
	PUSH AF
	PUSH AF
	PUSH AF
	PUSH AF 
	PUSH AF 
	PUSH AF
	PUSH AF
	PUSH AF
	PUSH AF
	PUSH AF 
label_893C:
	PUSH HL
	PUSH HL
	PUSH HL
	PUSH HL
	PUSH HL
	PUSH AF
	PUSH DE
	PUSH DE
	PUSH DE
	PUSH DE
	PUSH DE
	PUSH DE
	PUSH DE
	PUSH BC
	JP   NextScanLine
	
	PUSH AF
	PUSH AF
	PUSH AF
	PUSH AF
	PUSH AF
	PUSH AF
	PUSH AF
	PUSH AF
	PUSH AF
	PUSH AF
	PUSH AF
	PUSH AF 
	PUSH AF
	PUSH HL
	PUSH HL
	PUSH HL
	PUSH HL
	PUSH HL
	PUSH AF
	PUSH DE
	PUSH DE
	PUSH DE
	PUSH DE
	PUSH DE
	PUSH DE
	PUSH DE
	PUSH BC
	JP   NextScanLine
	
	LD   SP,IX
	POP  BC
	POP  DE
	POP  AF
	LD   SP,(SP_StoreMap)
	PUSH AF
	JP   NextScanLine
	
label_8978:
	PUSH HL
	PUSH HL
	PUSH AF
	PUSH BC
	PUSH HL
	PUSH HL
	PUSH AF
	PUSH BC
	PUSH HL
	PUSH AF
	PUSH DE
	PUSH DE
	PUSH BC
	PUSH HL
	JP   NextScanLine
	
	LD   SP,IX
	POP  BC
	POP  DE
	POP  AF
	LD   SP,(SP_StoreMap)
	PUSH AF
	JP   NextScanLine
	
	PUSH HL
	PUSH HL
	PUSH HL
	PUSH HL
	PUSH AF
	PUSH BC
	PUSH AF
	PUSH BC
	PUSH HL
	PUSH AF
	PUSH DE
	PUSH DE
	PUSH BC
	PUSH AF
	JP   NextScanLine
	
	PUSH AF
	PUSH AF
	PUSH AF
	PUSH AF
	PUSH AF
	PUSH AF
	PUSH AF
	PUSH AF
	PUSH AF
	PUSH AF
	PUSH AF
	PUSH AF 
	PUSH AF 
label_89B4:
	PUSH HL
	PUSH HL
	PUSH AF
	PUSH BC
	PUSH HL
	PUSH HL
	PUSH AF
	PUSH DE
	PUSH DE
	PUSH DE
	PUSH DE
	PUSH DE
	PUSH BC
	PUSH HL
	JP   NextScanLine
	
	POP  BC
	db $D1 
	db $F1 
	db $ED 
	LD   A,E
	RET  P
	ADC  A,E
	PUSH AF
	PUSH DE
	PUSH BC
	JP   NextScanLine
	
label_89D2:
	PUSH DE
	PUSH BC
	PUSH HL
	PUSH HL
	PUSH HL
	LD   (SP_StoreMap),SP
	LD   SP,IX
	POP  BC
	POP  DE
	POP  AF
	LD   SP,(SP_StoreMap)
	PUSH AF
	PUSH DE
	PUSH DE
	PUSH DE
	PUSH DE
	PUSH DE
	PUSH DE
	PUSH DE
	PUSH BC
	JP   NextScanLine
	
Tileset2Code:
	LD   (SP_StoreMap),SP
	LD   SP,IX
	POP  BC
	POP  DE
	POP  AF
	LD   SP,(SP_StoreMap)
	
MapXpos:
	db $B2 

SmoothX:			; 0..7 with 4 being the middle stopped value
	db $04 

UsingTileset:
	db $04 
	
; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;
	org $8a00			; PAGE $0A
	
PlayerMoveTable:
	dw DUF
	dw PlayerLeftRight
	dw PlayerLeftRight
	dw DUF
	dw PlayerDown
	dw PlayerDown
	dw PlayerDown
	dw PlayerDown
	dw PlayerJump
	dw PlayerJump
	dw PlayerJump
	dw PlayerJump
	dw DUF
	dw PlayerLeftRight
	dw PlayerLeftRight
	dw DUF
	
	db $03 
	db $58 
	db $23 
	db $58 
	db $43 
	db $58 
	db $63 
	db $58 
	db $83 
	db $58 
	db $A3 
	db $58 
	db $C3 
	db $58 
	db $E3 
	db $58 
	db $03 
	db $59 
	db $23 
	db $59 
	db $43 
	db $59 
	db $63 
	db $59 
	db $83 
	db $59 
	db $A3 
	db $59 
	db $C3 
	db $59 
	db $E3 
	db $59 
	db $1D 
	db $58 
	db $3D 
	db $58 
	db $5D 
	db $58 
	db $7D 
	db $58 
	db $9D 
	db $58 
	db $BD 
	db $58 
	db $DD 
	db $58 
	db $FD 
	db $58 
	db $1D 
	db $59 
	db $3D 
	db $59 
	db $5D 
	db $59 
	db $7D 
	db $59 
	db $9D 
	db $59 
	db $BD 
	db $59 
	db $DD 
	db $59 
	db $FD 
	db $59 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;	
; Code Address for each row remains constant (though the actual generated code differs)
; Two Tileset Addresses are set during code row generation.
;
; dw CodeToGenerateThisRow, Tileset1, Tilset2
;
; Each row has code space reserved for 30 bytes (this is the max size when we need to do a tileset
; switch on the row. 
;
; This means we generate a maximum of 240 bytes of code at a time (there are two groups of 240 bytes
; being alternately generated in a double buffer stylee) - as one is being executed the other is being
; created 
;
	
DrawMapTableEven:

	dw PushMapEven+(0*$1e), $F480, $0000
	dw PushMapEven+(1*$1e), $F480, $0000
	dw PushMapEven+(2*$1e), $F480, $0000
	dw PushMapEven+(3*$1e), $F300, $F000
	dw PushMapEven+(4*$1e), $F480, $F180
	dw PushMapEven+(5*$1e), $F480, $0000
	dw PushMapEven+(6*$1e), $F480, $F780
	dw PushMapEven+(7*$1e), $F900, $F300
	dw $0000

DrawMapTableOdd:

	dw PushMapOdd+(0*$1e), $F480, $0000
	dw PushMapOdd+(1*$1e), $F480, $0000
	dw PushMapOdd+(2*$1e), $F480, $0000
	dw PushMapOdd+(3*$1e), $F300, $F000
	dw PushMapOdd+(4*$1e), $F480, $F180
	dw PushMapOdd+(5*$1e), $F480, $0000
	dw PushMapOdd+(6*$1e), $F480, $F480
	dw PushMapOdd+(7*$1e), $F900, $F300
	dw $0000

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

WeaponJumpTable:
	dw DUF
	dw KnifeFunc
	dw GunFunc
	dw MachineGunFunc

SFXAddresses:
	dw FX0
	dw FX1
	dw FX6
	dw FX7
	dw FX2
	dw FX3
	dw FX4
	dw FX5
	dw FX8
	dw FX9

JingleAddresses:
	dw Jingle6
	dw Jingle1
	dw Jingle2
	dw Jingle4
	dw Jingle3
	dw Jingle5

TileSetAddresses:
	dw PreShiftedTiles + ( 1 * $180 )	;$F000	
	dw PreShiftedTiles + ( 2 * $180 )	;$F180	
	dw PreShiftedTiles + ( 3 * $180 )	;$F300	
	dw PreShiftedTiles + ( 4 * $180 )	;$F480	
	dw PreShiftedTiles + ( 5 * $180 )	;$F600	
	dw PreShiftedTiles + ( 6 * $180 )	;$F780	
	dw PreShiftedTiles + ( 7 * $180 )	;$F900	
	dw PreShiftedTiles + ( 8 * $180 )	;$FA80	

LRToDir:
	db $FF 
	db $00 
	db $01 
	db $FF 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
; PushMapOdd - (generated) code to draw the pre-shifted map tiles.
;

	org $8b00
	
PushMapOdd:
	PUSH HL
	PUSH HL
	PUSH HL
	PUSH HL
	PUSH HL
	PUSH AF
	PUSH BC
	PUSH HL
	PUSH AF
	PUSH DE
	PUSH BC
	PUSH HL
	PUSH AF
	PUSH BC
	JP   NextScanLine
	
	PUSH AF
	db $F5 
	PUSH AF
	PUSH AF
	PUSH AF
	PUSH AF
	db $F5 
	db $F5 
	db $F5 
	PUSH AF
	PUSH AF
	db $F5 
	db $F5 
	PUSH HL
	PUSH HL
	PUSH HL
	PUSH HL
	PUSH HL
	PUSH AF
	PUSH BC
	PUSH HL
	PUSH AF
	PUSH DE
	PUSH BC
	PUSH HL
	PUSH AF
	PUSH BC
	JP   NextScanLine
	
	PUSH AF
	db $F5 
	PUSH AF
	PUSH AF
	PUSH AF
	PUSH AF
	db $F5 
	db $F5 
	db $F5 
	PUSH AF
	PUSH AF
	db $F5 
	db $F5 
label_8B3C:
	PUSH HL
	PUSH HL
	PUSH HL
	PUSH HL
	PUSH HL
	PUSH AF
	PUSH DE
	PUSH DE
	PUSH DE
	PUSH DE
	PUSH DE
	PUSH DE
	PUSH DE
	PUSH BC
	JP   NextScanLine
	
	PUSH AF
	db $F5 
	PUSH AF
	PUSH AF
	PUSH AF
	PUSH AF
	db $F5 
	db $F5 
	db $F5 
	PUSH AF
	PUSH AF
	db $F5 
	db $F5 
	PUSH HL
	PUSH HL
	PUSH HL
	PUSH HL
	PUSH HL
	PUSH AF
	PUSH DE
	PUSH DE
	PUSH DE
	PUSH DE
	PUSH DE
	PUSH DE
	PUSH DE
	PUSH BC
	JP   NextScanLine
	
	LD   SP,IX
	POP  BC
	POP  DE
	POP  AF
	db $ED 
	db $7B 
	db $F0 
	ADC  A,E
	PUSH AF
	JP   NextScanLine
	
label_8B78:
	PUSH HL
	PUSH HL
	PUSH AF
	PUSH BC
	PUSH HL
	PUSH HL
	PUSH AF
	PUSH BC
	PUSH HL
	PUSH AF
	PUSH DE
	PUSH DE
	PUSH BC
	PUSH HL
	JP   NextScanLine
	
	LD   SP,HL
	POP  BC
	POP  DE
	POP  AF
	LD   SP,(SP_StoreMap)
	PUSH AF
	PUSH AF
	JP   NextScanLine
	
label_8B96:
	PUSH HL
	PUSH HL
	PUSH HL
	PUSH HL
	PUSH AF
	PUSH BC
	PUSH AF
	PUSH BC
	PUSH HL
	PUSH AF
	PUSH DE
	PUSH DE
	PUSH BC
	PUSH AF
	JP   NextScanLine
	
	PUSH AF
	PUSH AF
	PUSH AF
	PUSH AF
	PUSH AF
	PUSH AF
	PUSH AF
	PUSH AF
	PUSH AF
	PUSH AF
	PUSH AF
	db $F5 
	db $F5 
label_8BB4:
	PUSH HL
	PUSH HL
	PUSH AF
	PUSH BC
	PUSH HL
	PUSH HL
	PUSH AF
	PUSH DE
	PUSH DE
	PUSH DE
	PUSH DE
	PUSH DE
	PUSH BC
	PUSH HL
	JP   NextScanLine
	
	ADC  A,E
	PUSH AF
	PUSH BC
	PUSH HL
	PUSH HL
	PUSH AF
	PUSH DE
	PUSH DE
	PUSH DE
	PUSH DE
	JP   NextScanLine
	
label_8BD2:
	PUSH DE
	PUSH BC
	PUSH HL
	PUSH HL
	PUSH HL
	LD   (SP_StoreMap),SP
	LD   SP,IX
	POP  BC
	POP  DE
	POP  AF
	LD   SP,(SP_StoreMap)
	PUSH AF
	PUSH DE
	PUSH DE
	PUSH DE
	PUSH DE
	PUSH DE
	PUSH DE
	PUSH DE
	PUSH BC
	JP   NextScanLine

SP_StoreMap:
	dw	$4FF5 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

WorkingScrollTable:
	dw $8A60 

OtherScrollTable:
	dw $8A92 

ScrollTableToBuild:
	dw $8A92

MapLineHi:
	db $7F 

ScrollDirection:		; 0 - no movement, 1 scroll right to left, 2 scrolling left to right
	db $00 

PlayerInputDelay:		; must hit 0 before new input is read - char must move a whole character
	db $00 

GroundScrollX:
	db $00 

LaserSightByte:
	db $00 

MapXPosAttr:			; Used by attribute scroller
	db $B2 

BlankBlockPattern:		; bit pattern that is in the blank block (used in round 3 for the parallax background)
	db $FF 
	
ScoreDigitToDraw:
	db $00 
	
; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;	
; $8c00			PAGE $0C
;

	org $8c00
data_8c00	
	
WeaponOffsets:
	db $20 
	db $28 
	db $30 
	db $38 
	db $60 
	db $68 
	db $70 
	db $78 
	db $0C 
	db $10 
	db $0C 
	db $F8 
	db $08 
	db $10 
	db $08 
	db $F8 
	db $08 
	db $08 
	db $08 
	db $F8 
	db $06 
	db $08 
	db $06 
	db $F8 

; two bullet types, two directions.	
BulletTypes:		
	db $00 			; GFX Lo
	db $08 			; XSpd
	
	db $00 			; GFX Lo
	db $F8 			; XSpd
	
	db $01 			; GFX Lo
	db $08          ; XSpd
	
	db $01          ; GFX Lo
	db $F8          ; XSpd
	
; two bullet types, two bytes each (y doubled when drawn)
gfx_Bullets:		
	db $81 
	db $7E 
	db $FF 
	db $81 
	
; bullet structures (max 3) 	
BulletSprites:			
	db $FF 
	db $78 
	db $3E 
	
	db $FF 
	db $78 
	db $36 
	
	db $FF 
	db $78 
	db $2E 
	
NoteFreqTbl:
	db $00 
	db $FB 
	db $ED 
	db $E0 
	db $D3 
	db $C7 
	db $BC 
	db $B2 
	db $A8 
	db $9E 
	db $95 
	db $8D 
	db $85 
	db $7E 
	db $76 
	db $70 
	db $6A 
	db $64 
	db $5E 
	db $59 
	db $54 
	db $4F 
	db $4B 
	db $46 
	db $43 
	db $3F 
	
StarPositions:
	db $94 
	db $48 
	db $69 
	db $4A 
	db $F3 
	db $46 
	db $BB 
	db $48 
	db $57 
	db $46 
	db $04 
	db $4A 
	db $C5 
	db $40 
	db $BD 
	db $46 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
; Baddy Routine lookup tables.
;
	
BaddyRoutines:
	dw PirateGuyMove		; 0
	dw KnifeGuyMove			; 1
	dw PirateGuyJiggle		; 2
	dw Pram					; 3
	dw BazookaLadyMove		; 4
	dw BazookaLadyFire		; 5
	dw KnifeGuyWait			; 6
	dw NightSlasher			; 7
	dw MissileUp			; 8
	dw MissileDown			; 9
	dw MoveObject			; 0a
	dw Explosion			; 0b
	dw DoNothing			; 0c
	dw DoDrop				; 0d
	dw GirlfriendOn			; 0e
	dw GirlfriendFollow		; 0f
	dw GirlfriendOff		; 10
	dw MoveOffScreenQuick	; 11


BaddyTypesTable:			; typ, gno, height

	db T_PirateGuyMove 		; 1 pirate guy
	db G_PirateGuy 
	db $20 
	
	db T_KnifeGuyMove 		; 2 knife guy
	db G_KnifeGuy 
	db $20 
	
	db T_Pram 				; 3 pram
	db G_Pram 
	db $18 
	
	db T_BazookaLadyMove 	; 4 bazooka lady
	db G_BazookaLady
	db $20 
	
RandomSpeeds:
	db $01 
	db $03 
	db $04 
	db $03 
	
WeaponImages:
	dw gfx_UseYourHead
	dw gfx_UserYourHeadAttrs
	
	dw gfx_StartToStab
	dw gfx_StartToStabAttrs
	
	dw gfx_ImTheCure
	dw gfx_ImTheCureAttrs
	
	dw gfx_DontPushMe
	dw gfx_DontPushMeAttrs

ExplodePos:
	db $00 
	db $02 
	db $04 
	db $06 
	db $06 
	db $04 
	db $02 
	db $00 

PickupJumpTable:
	dw DrawDefaultWeaponImage
	dw PickupKnifeInit
	dw PickupGunsInit
	dw PickupGunsInit

PlayerFireUpdateRoutines:
	dw HeadButtUpdate			; head butt
	dw FireKnifeUpdate			; knife
	dw FireBulletUpdate			; pistol
	dw FireBulletUpdate			; machine gun

PointsTable:
	dw $0502
	dw $0002
	dw $0503
	dw $0501
	dw $0003
	dw $0004
	dw $0001
	dw $0500
	dw $0500
	dw $0500
	dw $0500
	dw $0500
	dw $0500
	dw $0500

ExplosionOffsets:
	dw $0400
	dw $F000
	dw $08F0
	dw $0810
	dw $F8F0
	dw $F810
	dw $1400

GirlfriendSpriteAddress:
	dw $0000
	
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
; PAGE $0D
;
	org $8d00
	
data_8D00:
	db $10 
	db $30 
	db $20 
	db $40 

BaddyTriggerRowHeights:
	db $60 
	db $80 
	db $50 
	db $70 

RoundSetupTable:
	db $30 				; Colour 1
	db $41 				; Colour 2
	db $FF 				; Blank/Parallax block bit pattern
	db $AA 				; MapXPos Start
	
	dw MapTiles_Round1	; address of map block graphics (starting with ground block)

	db $4C 
	db $44 
	db $FF 
	db $2A 
	dw MapTiles_Round2	; address of map blocks

	db $78 
	db $38 
	db $7F 
	db $18 
	dw MapTiles_Round3	; address of map blocks


RoundWeaponOffsets:
	db $20 
	db $28 
	db $30 
	db $38 
	db $60 
	db $68 
	db $70 
	db $78 
	db $60 
	db $68 
	db $70 
	db $78 
	db $61 
	db $69 
	db $71 
	db $79 
	db $20 
	db $28 
	db $30 
	db $38 
	db $60 
	db $68 
	db $70 
	db $78 

BurgerTables:
	dw Round1Burgers
	dw Round2Burgers
	dw Round3Burgers

Round1Burgers:
	db $1A 			; x
	db $10 			; y
	db $03 			; pickup type
	db $4A 
	db $40 
	db $01 
	db $6D 
	db $10 
	db $02 
	db $2D 
	db $20 
	db $00 

Round2Burgers:
	db $0D 
	db $20 
	db $01 
	db $33 
	db $10 
	db $00 
	db $62 
	db $30 
	db $02 
	db $4F 
	db $10 
	db $03 

Round3Burgers:
	db $2C 
	db $20 
	db $02 
	db $12 
	db $10 
	db $03 
	db $69 
	db $20 
	db $00 
	db $3D 
	db $10 
	db $01 

GameMapAddresses:
	dw Map_Round1			;$8000
	dw Map_Round2			;$6BDE
	dw Map_Round3			;$63DE

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
; SFX data
;

FX0:
	db $0B 
	db $15 
	db $1F 
	db $1F 
	db $0B 
	db $FF 
FX6:
	db $29 
	db $2B 
	db $25 
	db $15 
	db $1B 
	db $17 
	db $0B 
	db $11 
	db $0D 
	db $FF 
FX1:
	db $07 
	db $01 
	db $FF 
FX7:
	db $77 
	db $73 
	db $6F 
	db $13 
	db $0F 
	db $01 
	db $FF 
FX2:
	db $15 
	db $00 
	db $0B 
	db $00 
	db $1F 
	db $00 
	db $FF 
FX3:
	db $C9 
	db $83 
	db $51 
	db $15 
	db $01 
	db $FF 
FX4:
	db $C9 
	db $97 
	db $65 
	db $33 
	db $0B 
	db $0B 
	db $33 
	db $65 
	db $97 
	db $C9 
	db $FF 
FX5:
	db $96 
	db $8C 
	db $82 
	db $78 
	db $6E 
	db $64 
	db $5A 
	db $50 
	db $46 
	db $3C 
	db $38 
	db $32 
	db $2E 
	db $28 
	db $24 
	db $24 
	db $22 
	db $20 
	db $20 
	db $20 
	db $20 
	db $20 
	db $02 
	db $02 
	db $32 
	db $32 
	db $30 
	db $30 
	db $2E 
	db $30 
	db $32 
	db $3C 
	db $46 
	db $50 
	db $5A 
	db $64 
	db $6E 
	db $78 
	db $82 
	db $8C 
	db $96 
	db $FF 
FX8:
	db $2E 
	db $14 
	db $30 
	db $14 
	db $28 
	db $20 
	db $16 
	db $14 
	db $FF 
FX9:
	db $5A 
	db $5C 
	db $56 
	db $46 
	db $4C 
	db $48 
	db $3C 
	db $42 
	db $3E 
	db $0C 
	db $10 
	db $0A 
	db $16 
	db $1A 
	db $14 
	db $24 
	db $2A 
	db $28 
	db $FF 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
; PlayGame - Let's start a round of Cobra...
;
	
PlayGame:

	CALL ResetVars

PlayGameNoReset:
	LD   HL,Round1Burgers
	LD   B,$0C

ResetBurgerLp:
	RES  7,(HL)
	INC  L
	INC  L
	INC  L
	DJNZ ResetBurgerLp
	
	LD   (IY+V_BURGERCOUNT),$04						; $fce4 - BurgerCount
	LD   HL,(InitialNumBaddiesToKill)
	LD   (NumBaddiesToKill),HL
	LD   HL,(InitialGirlfriendCountdown)
	LD   (GirlfriendCountdown),HL
	CALL SetupRound
	CALL Sprint
	db CLA, CLS 
	db RSET 
	db EXPD,$02 
	db AT, $0C,$0B 
	db PEN, BRIGHT+YELLOW
	db "ROUND  "
	db PEN, BRIGHT+WHITE 
RoundNumText:
	db "01"
	db RSET 
	db FIN 

	LD   A,$02		; Rocky Ditty
	CALL PlayTune
	
	LD   B,$32
	CALL HaltB
	CALL Sprint
	db CLA
	db CLS 
	db FIN 

RestartRound:
	CALL SwapInGameMap
	CALL ResetGame

MainLoop:
	CALL UpdateBeeper
	DI  
	CALL DrawGround
	CALL Keys
	CALL ScrollMap
	CALL ScrollAttributes
	CALL UpdatePlayer
	CALL PlayerFall
	CALL WaitforRaster
	CALL DrawMap
	CALL DrawStars
	CALL DrawSprites
	CALL DrawGround
	CALL GenerateScrollCode
	CALL Baddies
	CALL DrawScoreDigits
	CALL DissolveDuck
	CALL TwinkleStars
	CALL ExtraLife
	CALL Rand
	CALL IntroduceGirlfriend
	CALL DoBurgers
	CALL Pause
	CALL AnimateBurgers
	
	INC  (IY+V_FRAMECOUNTER)			; Variables in IY + 19 = FrameCounter
	EI  
	LD   A,(LevelEndCountdown)
	OR   A
	JR   Z,LevelInProgress
	
	DEC  (IY+V_LEVELENDCOUNTDOWN)			; fcd6 LevelEndCountdown
	JR   NZ,NoBaddyIntroductions
	
	JP   LevelComplete

LevelInProgress:
	CALL IntroduceBaddies

NoBaddyIntroductions:

	LD   A,(PlayerLostLife)
	OR   A
	JR   Z,MainLoop
	CALL SwapInGameMap
	HALT
	CALL DrawScore
	LD   A,$03			; 03 - Lose Life Jingle
	CALL PlayTune

	XOR  A
	LD   (BeepFXNum),A
	LD   (BeepNum),A
	LD   A,(NumLives)
	DEC  A
	LD   (NumLives),A
	PUSH AF
	CP   $04
	JR   NC,SkipGlove
	
	LD   C,A			; black out a glove
	ADD  A,A
	ADD  A,C
	ADD  A,$03
	LD   L,A
	ADD  A,$02
	LD   C,A
	LD   H,$13
	LD   B,$15
	XOR  A
	CALL FillAttrBlock

SkipGlove:
	LD   IX,SpriteData
	LD   HL,ExplosionOffsets
	LD   B,$07			; setup 8 explosions

NextBang:
	LD   A,(HL)
	ADD  A,$78
	LD   (IX+XNO),A			; XNO
	INC  L
	LD   A,(PlayerY)
	ADD  A,(HL)
	LD   (IX+YNO),A			; YNO
	INC  L
	LD   (IX+GNO),$1A			; ix + GNO = explosion
	LD   (IX+TYP),$0B			; ix+TYP = explosion
	LD   (IX+CNT2),$00
	LD   DE,$0007
	ADD  IX,DE
	DJNZ NextBang

	CALL ResetBullets
	LD   A,$07
	CALL PlayBeepFX
	LD   (IY+V_FRAMECOUNTER),$14			; IY+19 = FrameCounter

ExplodeLoop:
	CALL UpdateBeeper
	CALL DrawSprites
	CALL Baddies
	DEC  (IY+V_FRAMECOUNTER)			; dec FrameCounter
	JR   NZ,ExplodeLoop

	EI  
	LD   B,$32				; wait 50 frames
	CALL HaltB
	POP  AF
	JR   Z,GameOver

	LD   A,(NightSlasherFlag)
	OR   A
	JP   NZ,PlayGameNoReset
	JP   RestartRound

GameOver:
	CALL Sprint
	db EXPD, 2
	db AT, $04, $13
	db PEN, BRIGHT+WHITE
	db "GAME UNDER" 
	db FIN

	LD   A,$04
	JP   PlayTune

LevelComplete:
	CALL SwapInGameMap
	INC  (IY+V_BURGERWEAPONADJUST)			; $2c - BurgerWeaponAdjust
	LD   B,$32
	CALL HaltB								; wait 1 second
	LD   B,$50
	LD   A,(RoundNumber)
	INC  A
	CP   $03
	JR   NZ,NextRound
	CALL GameCompleteSound
	LD   B,$A0
	XOR  A

NextRound:
	LD   (RoundNumber),A

BoostScore:
	PUSH BC
	LD   A,B
	ADD  A,A
	LD   C,A
	XOR  A
	LD   R,A
	CALL White
	LD   DE,$0504
	CALL ScoreAdd
	CALL DrawScore
	CALL ExtraLife
	POP  BC
	DJNZ BoostScore
	LD   B,$64
	CALL HaltB
	LD   HL,(RoundNumText)
	LD   A,H
	INC  A
	CP   $3A
	JR   NZ,SetRoundText
	INC  L
	LD   A,$30

SetRoundText:
	LD   H,A
	LD   (RoundNumText),HL
	LD   HL,(InitialNumBaddiesToKill)
	LD   DE,$000A
	ADD  HL,DE
	LD   (InitialNumBaddiesToKill),HL
	LD   HL,(InitialGirlfriendCountdown)
	ADD  HL,DE
	LD   (InitialGirlfriendCountdown),HL
	LD   A,(ProjectileSpeed)
	INC  A			; bump projectile speed to a max of 8 pixels per frame
	CP   $08
	JR   Z,FullSpeed

	LD   (ProjectileSpeed),A

FullSpeed:
	LD   A,(ProjectileFireDelay)
	SUB  $05
	JR   C,FullDelay
	JR   Z,FullDelay
	LD   (ProjectileFireDelay),A

FullDelay:
	LD   A,(RandomNumMask)
	SRL  A
	JR   Z,AllShifted
	LD   (RandomNumMask),A

AllShifted:
	JP   PlayGameNoReset

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

Beep:			; set the buzzer on for E cycles
	XOR  A
	OUT  ($FE),A
	LD   B,E

BeepWait:
	DJNZ BeepWait
	LD   A,$10
	OUT  ($FE),A
	RET 

PlayRandomNoise:
	PUSH BC
	CALL Rand
	LD   E,$32
	AND  D
	CALL Z,Beep
	LD   A,(RND1)
	LD   E,A
	LD   A,(RND2)
	AND  $0F
	CALL Z,Beep
	POP  BC
	RET 

GameCompleteSound:
	LD   C,$00
	LD   D,$FF
lp1:
	LD   B,$05
lp2:
	CALL PlayRandomNoise
	DJNZ lp2
	DEC  C
	JR   NZ,lp1
	SRL  D
	JR   NZ,lp1
	LD   BC,$07D0
	LD   D,$01
lp3:
	CALL PlayRandomNoise
	DEC  BC
	LD   A,B
	OR   C
	JR   NZ,lp3
	LD   D,$01
	LD   C,$00
lp4:
	LD   B,$50
lp5:
	CALL PlayRandomNoise
	DJNZ lp5

	DEC  C
	JR   NZ,lp4
	LD   C,$64
	LD   A,D
	SCF
	RL   A
	LD   D,A
	INC  A
	JR   NZ,lp4
	RET 
	
; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
; Baddies - Process all the baddy logic including the collision detection with the player.
;
	
Baddies:
	LD   B,$07
	LD   IX,SpriteData

BadLp:
	PUSH BC
	LD   A,(IX+TYP)			; TYP
	OR   A
	CALL P,DoBad
	LD   DE,$0007
	ADD  IX,DE
	POP  BC
	DJNZ BadLp
	RET 

DoBad:
	CALL PlayerHitBaddy
	CALL CollideWithPlayer
	
	LD   A,(IX+TYP)					; IX+TYP
	ADD  A,A
	JP   M,IsInTheAir
	ADD  A,(BaddyRoutines & $ff )	;$57
	LD   L,A
	LD   H,(BaddyRoutines / $100 )	;$8C ; baddy logic jump table 8c57 (BaddyRoutines)
	LD   A,(HL)
	INC  L
	LD   H,(HL)
	LD   L,A
	JP   (HL)

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
; PlayerHitBaddy - when the player shoots / head butts what does this object do
;
; IX is the baddy we've hit
;

PlayerHitBaddy:			 
	LD   A,(IX+GNO)			; IX + GNO
	CP   G_Explosion
	RET  NC					; return if its an explosion, burger, missile
	
	AND  $FE
	CP   G_Knife
	RET  Z					; return if its a knife
	
	LD   A,(IX+TYP)			; IX + TYP
	AND  $3F
	CP   T_GirlfriendFollow			; 0f == GirlfriendFollow
	RET  Z
	
	LD   A,(PlayerWeapon)
	ADD  A,A
	ADD  A,(PlayerFireUpdateRoutines & $ff ) ;$AB
	LD   L,A
	LD   H,(PlayerFireUpdateRoutines / $100) ;$8C	; Jump Table at 8cab PlayerFireUpdateRoutines
	LD   A,(HL)
	INC  L
	LD   H,(HL)
	LD   L,A
	JP   (HL)			; Update the player's weapon
	
; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;
	
MissileUp:
	DEC  (IX+CNT2)			; YCNT
	JR   NZ,NoYup

	LD   A,(IX+CNT1)		; reset y count
	LD   (IX+CNT2),A
	DEC  (IX+YNO)			; y-2
	DEC  (IX+YNO)

NoYup:
	JP   MoveObject
	
; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

MissileDown:
	DEC  (IX+CNT2)			; ycount
	JR   NZ,NoYDown

	LD   A,(IX+CNT1)		; reset y count
	LD   (IX+CNT2),A
	INC  (IX+YNO)			; and move y +2 down
	INC  (IX+YNO)

NoYDown:
	JP   MoveObject

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

NightSlasher:
	CALL MoveObject
	LD   C,(IX+GNO)			; GNO
	LD   A,(IX+XNO)			; YNO
	CP   $D0
	JR   C,InRange1
	
	LD   C,G_NightSlasher	; GNO = $18 if $28 < y < $d0

InRange1:
	CP   $28
	JR   NC,InRange2
	
	LD   C,G_NightSlasher+1	; otherwise GNO = $19 (face right)

InRange2:
	LD   (IX+GNO),C			; IX+GNO
	DEC  (IX+CNT2)			; countdown to fire
	RET  NZ
	
	INC  (IX+CNT2)
	CALL FindFreeSpriteAll
	RET  P
	
	LD   (IX+CNT2),$0A		; next fire countdown to $0a
	LD   (HL),T_MissileUp	; TYP = MissileUp (for movement)
	INC  L
	LD   A,(IX+XNO)			; copy x into knife pos
	LD   (HL),A
	INC  L
	LD   (HL),$6C			; set knife pos Y
	INC  L
	LD   (HL),G_Knife		; GNO = Knife facing Left
	LD   A,(RND2)
	AND  $01
	JR   Z,KnifeLeft
	
	INC  (HL)				; Knife facing right

KnifeLeft:
	INC  L
	LD   (HL),$05			; knife XSPD
	INC  L
	LD   A,(RND1)
	AND  $07
	LD   (HL),A				; XCNT & YCNT rand 0..7
	INC  L
	LD   (HL),A
	
	LD   A,$04
	JP   PlayBeepFX

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

GirlfriendOn:
	LD   HL,$1870			; Player X and Width
	LD   E,(IX+XNO)			; IX + XNO
	LD   D,H				; Girlfriend's Width
	CALL HitA
	JR   C,ReachedTarget
	
	LD   A,(PlayerY)
	LD   L,A
	LD   H,$18				; Player Height
	LD   E,(IX+YNO)			; IX + YNO
	LD   D,H				; Girlfriend's Height
	CALL HitA
	JR   C,ReachedTarget
	
	INC  (IX+TYP)			; switch to GirlfriendFollow
	LD   A,(GirlfriendFoundPlayer)
	INC  A
	LD   (GirlfriendStatus),A
	DEC  A
	RET  NZ

	LD   A,$05				; Wolf whistle jingle
	LD   (GirlfriendFoundPlayer),A
	JP   PlayBeepJingle

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

GirlfriendFollow:
	LD   C,$28
	LD   L,$70			; L=Fixed PlayerX of 70h
	LD   H,C			; H=Player XWidth of 28h
	LD   E,(IX+XNO)		; E=GirlfriendX
	LD   D,C			; D=Girlfriend's XWidth (28h)
	CALL HitA
	JR   C,GFHitPlayer
	
	LD   A,(PlayerY)
	ADD  A,C
	LD   L,A			; L=PlayerY+40
	LD   H,C			; H=Player YHeight
	LD   A,(IX+YNO)		; Girlfriend's Y
	ADD  A,C
	LD   E,A			; E=GirlfriendsY+40
	LD   D,C			; D=Girlfriends YHeight
	CALL HitA
	JR   NC,ReachedTarget

GFHitPlayer:
	DEC  (IX+TYP)		; Change TYP to GirlfriendOn
	XOR  A
	LD   (GirlfriendStatus),A
	RET 

ReachedTarget:
	XOR  A
	LD   (IX+XSPD),A
	LD   C,A
	LD   A,(PlayerDir)		; XDirection
	AND  $01
	LD   A,(IX+XNO)			; IX + XNO
	JR   Z,HeadLeft
	
	CP   $88
	JR   Z,TurnAround		; reached X of 88h
	JR   NC,HeadforTargetX	; further than Player X of 88h
	
	INC  C
	JR   HeadforTargetX

HeadLeft:
	CP   $60				; reached X of 60h
	JR   Z,TurnAround
	JR   NC,HeadforTargetX
	
	INC  C

HeadforTargetX:
	LD   A,C
	ADD  A,G_Girlfriend
	LD   (IX+XSPD),$02		; reset movement speed

HeadForTargetX_2:
	LD   (IX+GNO),A			; IX+GNO (0eh or 0fh)

NotYet:
	CALL TryFall			; Try to match the Player's Y position
	CALL TryJump
	JP   MoveObject

TurnAround:
	LD   A,(FrameCounter)
	AND  $1F
	JR   NZ,NotYet
	
	LD   A,(IX+GNO)			; IX + GNO
	XOR  $01				; Flip Direction of graphic
	LD   C,A
	JR   HeadForTargetX_2

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

PirateGuyMove:
	PUSH BC
	CALL FindFreeSpriteGeneral			; find a sprite slot for a knife
	POP  BC
	JP   P,PirateTryMove
	
	LD   A,(RND1)
	AND  (IY+V_RANDOMNUMMASK)			; FCE9 - RandomNumMask
	JR   NZ,PirateTryMove
	
	LD   C,T_PirateGuyJiggle			; Switch to PirateGuyJiggle

SetSpriteProjectile:		; stores a free sprite index for when this baddy wants to fire
	LD   (HL),T_DoNothing	; Bullet TYP = $0c (DoNothing)
	LD   (IX+CNT1),L		; store lowbyte of the bullet sprite addr with this sprite for when it needs to shoot
	INC  L
	INC  L
	LD   (HL),$E0			; YNO of bullet
	LD   (IX+XSPD),$00
	LD   (IX+TYP),C			; IX+TYP = C
	LD   (IX+CNT2),$10
	LD   A,(IX+XNO)			; IX+XNO
	CPL
	RLCA
	AND  $01
	LD   C,A
	LD   A,(IX+GNO)
	AND  $FE
	ADD  A,C
	LD   (IX+GNO),A			; IX+GNO
	JP   MoveObject

PirateTryMove:
	CALL TryFall
	CALL MoveObject
	JP   TryJump

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

PirateGuyJiggle:
	CALL MoveObject
	DEC  (IX+CNT2)			; jiggle counter
	JR   Z,FinishedJiggle

	LD   A,(IX+CNT2)
	AND  $01
	LD   C,$02
	JR   Z,JiggleDown

	LD   C,$FE

JiggleDown:
	LD   A,(IX+YNO)			; IX + YNO
	ADD  A,C				; jiggle
	LD   (IX+YNO),A
	RET 

FinishedJiggle:
	LD   L,(IX+CNT1)		; get bullet lo byte to fire
	LD   H,(data_8800 / $100);$88
	LD   (HL),T_MoveObject	; TYP = $0a - Moving object

	INC  L
	LD   A,(IX+XNO)			; Pirate's XNO
	LD   (HL),A
	INC  L
	LD   A,(IX+YNO)			; Pirate's YNO
	ADD  A,$02
	AND  $F0
	LD   (IX+YNO),A			; Update Pirate's YNO
	ADD  A,$0C
	LD   (HL),A				; Knife's YNO
	INC  L
	LD   C,$01
	LD   A,(IX+GNO)			; IX+GNO
	AND  C					; extract whether we're facing left or right
	ADD  A,G_Knife
	LD   (HL),A				; Knife's GNO 06/07
	AND  C
	XOR  C
	ADD  A,G_PirateGuy
	LD   (IX+GNO),A					; IX+GNO
	LD   (IX+TYP),T_PirateGuyMove	; IX+TYP=0 PirateGuyMove

SetProjectileSpeed:
	INC  L
	LD   A,(ProjectileSpeed)
	LD   (HL),A					; XSPD
	LD   (IX+XSPD),$04			; IX+XSPD
	
	LD   A,$05
	JP   PlayBeepFX

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

KnifeGuyMove:
	LD   A,(RND3)
	AND  $1F
	JR   NZ,MoveSprite
	
	LD   A,(IX+XSPD)				; store xspd
	LD   (IX+CNT1),A
	LD   (IX+XSPD),$00				; clear xspd
	
	LD   (IX+CNT2),$0E				; counter
	LD   (IX+TYP),T_KnifeGuyWait	; Switch to KnifeGuyWait (stands around for a while)
	JP   MoveObject

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

MoveSprite:
	CALL DoFall
	CALL MoveObject
	JP   TryJump

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

KnifeGuyWait:
	CALL MoveObject
	DEC  (IX+CNT2)					; countdown
	RET  NZ
	
	LD   (IX+TYP),T_KnifeGuyMove	; IX+TYP - Switch to KnifeGuyMove
	LD   A,(IX+CNT1)
	CP   $04
	JR   Z,SetKnifeGuySpeed

BumpXSpd:
	INC  A
	CP   $02
	JR   Z,BumpXSpd

SetKnifeGuySpeed:
	LD   (IX+XSPD),A				; reset xspd
	JP   TryDirectionFlip

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

Pram:
	CALL DoFall
	JP   MoveObject

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

BazookaLadyMove:
	PUSH BC
	CALL FindFreeSpriteGeneral
	POP  BC
	JP   P,MoveSprite
	
	LD   A,(RND1)
	AND  (IY+V_RANDOMNUMMASK)			; $FCE9 - RandomNumMask
	JR   NZ,MoveSprite
	
	LD   C,T_BazookaLadyFire			; Switch to BazookaLadyFire
	JP   SetSpriteProjectile

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

BazookaLadyFire:
	CALL MoveObject
	DEC  (IX+CNT2)
	RET  NZ

	LD   L,(IX+CNT1)
	LD   H,(data_8800 / $100)	;$88
	LD   (HL),T_MoveObject		; TYP $0a - Moving Object
	INC  L
	LD   A,(IX+XNO)				; IX+XNO
	LD   (HL),A
	INC  L
	LD   A,(IX+YNO)				; IX+YNO
	ADD  A,$06
	LD   (HL),A
	INC  L
	LD   C,$01
	LD   A,(IX+GNO)				; IX+GNO
	AND  C
	ADD  A,G_Missile
	LD   (HL),A					; Missile GNO $1c/$1d
	AND  C
	XOR  C
	ADD  A,G_BazookaLady
	LD   (IX+GNO),A
	LD   (IX+TYP),T_BazookaLadyMove
	JP   SetProjectileSpeed

DoDrop:
	CALL GetMapPos
	LD   A,(HL)
	OR   A
	JP   P,Drop
	
	LD   A,(IX+CNT1)			; landed, switch back to the TYP it was previously
	LD   (IX+TYP),A
	
	LD   H,(data_8c00 / $100)	;$8C
	JP   LandedSetSpeed

Drop:
	LD   A,(IX+YNO)				; IX+YNUM
	ADD  A,$10
	LD   (IX+YNO),A

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

DoNothing:
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

IsInTheAir:
	LD   A,$02				; move an xvel of 2 pixels
	CALL MoveObjectXvel
	LD   A,(IX+CNT2)			; cnt2 is index into jump/fall table
	ADD  A,$05
	LD   (IX+CNT2),A
	LD   L,A
	LD   H,(SineTable / $100)	;$FC	; SineTable = fc00+(IX+6)
	LD   A,(HL)
	ADD  A,A
	LD   C,A
	LD   A,(IX+CNT1)			; IX+CNT1 = y destination
	ADD  A,$6A
	SUB  C
	AND  $FE
	LD   (IX+YNO),A			; IX+YNO
	AND  $F0				; round to 16 pixels
	LD   H,A
	LD   A,L
	CP   $73
	RET  C					; return if y > $73 (the floor)
	
	CALL GetMapPos			; anything below us?
	LD   A,(HL)
	OR   A
	RET  P					; nothing under us
	
	LD   A,H
	OR   A
	JR   NZ,NotGrounded
	
	LD   A,$80				; 128 - y offset from table
	SUB  C
	JR   Landed

NotGrounded:
	ADD  A,A				; mapy x 16
	ADD  A,A
	ADD  A,A
	ADD  A,A
	SUB  C					; - Y offset from table

Landed:
	LD   (IX+YNO),A			; ix+YNO
	RES  6,(IX+TYP)			; flag we're not in the air
	LD   A,(IX+TYP)
	CP   T_Pram				; pram?
	JR   Z,PlayLandSound	; yes, it can't change direction on landing
	
	LD   A,(RND2)
	AND  $01
	JR   NZ,PlayLandSound

TryDirectionFlip:
	LD   C,$00
	LD   A,(IX+XNO)			; IX+XNO
	CP   $70
	JR   NC,NoDirectionFlip
	INC  C					;  x < 70, flip direction (C)

NoDirectionFlip:
	LD   A,(PlayerWeapon)
	CP   WEAPON_MACHINEGUN	; does player have the MachineGun?
	JR   NZ,SetLandDirection
	
	LD   A,C				; flip direction if player has machine gun
	XOR  $01
	LD   C,A

SetLandDirection:
	LD   A,(IX+GNO)			; IX+GNO
	AND  $FE				; mask out direction
	ADD  A,C				; add in required direction
	LD   (IX+GNO),A			; Set IX+GNO

PlayLandSound:
	LD   A,$02
	JP   PlayBeepFX

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

TryJump:
	LD   A,B
	CP   $04
	RET  C			; first three baddy slots don't jump.
	
	LD   A,(PlayerY)
	ADD  A,$04
	JP   P,IsPositive
	
	XOR  A

IsPositive:
	CP   (IX+YNO)			; IX+YNO
	RET  NC
	
	LD   A,(IX+YNO)			; move upwards
	PUSH AF
	SUB  $08
	LD   (IX+YNO),A
	CALL GetMapPos
	POP  AF
	LD   (IX+YNO),A
	LD   A,(HL)
	OR   A
	RET  P					; return if there's nothing below us
	
	JR   StartJump			; so jump up

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

TryFall:
	LD   A,B
	CP   $03
	JR   C,DoFall			; sprite num < 3
	
	CALL GetMapPos
	LD   A,(HL)
	OR   A
	RET  M					; -ve = something under us

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

StartJump:
	LD   A,(IX+YNO)			; IX+YNO
	LD   (IX+CNT1),A		; IX+CNT1 = Y
	LD   (IX+CNT2),$32		; sinetable + $32
	SET  6,(IX+TYP)			; in the air
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

DoFall:
	CALL GetMapPos
	LD   A,(HL)
	OR   A
	RET  M					; -ve = something under us
	
	LD   A,(IX+YNO)			; IX+YNO
	ADD  A,$18
	LD   (IX+CNT1),A		; IX+CNT1 = Y+24
	LD   (IX+CNT2),$5A		; FC5a start of the fall sinetable + $5a
	SET  6,(IX+TYP)			; IX+TYP set bit 6 (in the air)
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

MoveOffScreenQuick:
	LD   A,$08				; +8 xvel
	BIT  0,(IX+GNO)			; IX+GNO
	JR   Z,MoveOffRight
	
	NEG  					; -8 xvel

MoveOffRight:
	ADD  A,(IX+XNO)
	JR   OffScreenCheck

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

GirlfriendOff:
	CALL DoFall

MoveObject:
	LD   A,(IX+XSPD)		; XSPD
	
MoveObjectXvel:
	BIT  0,(IX+GNO)			; IX + GNO; bit 0 == dir
	JR   NZ,AddVel
	
	NEG  					; flip x velocity

AddVel:
	ADD  A,(IX+XNO)			; ix+XNO
	EX   AF,AF'
	LD   A,(ScrollDirection)
	ADD  A,(DirectionTable & $ff)	;$98
	LD   L,A
	LD   H,(DirectionTable / $100)	;$88	; DirectionTable 8898
	EX   AF,AF'
	ADD  A,(HL)
OffScreenCheck:
	LD   (IX+XNO),A
	CP   $F8			; off screen?
	RET  C

IsOffScreen:
	LD   A,(IX+TYP)
	AND  $3F
	SET  7,(IX+TYP)				; TYP bit 7 = off screen
	CP   T_PirateGuyJiggle
	JR   Z,FreeUpProjectile		; TYP == PirateGuyJiggle
	
	CP   T_BazookaLadyFire
	JR   Z,FreeUpProjectile		; TYP = BazookaLadyFire
	
	LD   A,(IX+GNO)
	AND  $FE					; mask out direction bit from GNO
	CP   G_Girlfriend
	RET  NZ						; return if not Girlfriend
	
	LD   HL,$007D
	LD   (GirlfriendCountdown),HL
	XOR  A
	LD   (GirlfriendOnScreen),A
	LD   A,(IX+GNO)
	AND  $01
	LD   A,$06					; on left
	JR   Z,OnScreenLeft
	
	LD   A,$F0					; on right

OnScreenLeft:
	LD   (GirlfriendEnterX),A
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
; FreeUpProjectile - free up the sprite index that was to be used by this sprite when it fired
;

FreeUpProjectile:				
	LD   L,(IX+CNT1)			; low byte index into sprite with reserved projectile for this baddy
	LD   H,(data_8800 / $100)	; $88 sprite structure data is on PAGE8 ($8800)
	LD   (HL),$FF				; free up sprite
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

Explosion:
	LD   A,(FrameCounter)
	AND  $07
	ADD  A,(ExplodePos & $ff)				; $9B
	LD   L,A
	LD   H,(ExplodePos / $100)				; $8c $8c9b - ExplodePos
	LD   A,(IX+XNO)
	AND  $F8
	ADD  A,(HL)
	LD   (IX+XNO),A
	DEC  (IX+CNT2)
	RET  NZ
	
	JR   IsOffScreen

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

GetMapPos:
	CALL GetSpriteHeight
	ADD  A,A
	LD   C,A
	LD   L,(IX+XNO)						; IX+XNO
	INC  L
	INC  L
	INC  L
	INC  L								; +4
	LD   H,(IX+YNO)						; IX+YNO
	JP   GetMapPosXY

GetSpriteHeight:
	LD   A,(IX+GNO)						; IX+GNO
	LD   C,A
	ADD  A,A
	ADD  A,C							; x 3
	ADD  A,((SpriteGFXTable+2) & $ff)	;$2D
	LD   L,A
	LD   H,((SpriteGFXTable+2) / $100)	;$88	; 882d SpriteDataTable+2
	LD   A,(HL)
	ADD  A,(SpriteSizes & $ff)			;$23	; 8823 SpriteSizes
	LD   L,A
	LD   A,(HL)
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

CollideWithPlayer:
	LD   A,(IX+TYP)
	AND  $3F
	CP   T_Explosion
	RET  NC				; if > Explosion TYP return
	
	LD   A,(IX+XNO)
	CP   $6A
	RET  C
	
	CP   $7E
	RET  NC
	
	CALL GetSpriteHeight
	ADD  A,A
	CP   $08
	JR   NZ,Not8
	
	ADD  A,A

Not8:
	ADD  A,$20
	ADD  A,(IX+YNO)			; IX+YNO
	LD   C,A
	LD   A,(PlayerY)
	ADD  A,$40
	CP   C
	RET  C
	
	SUB  $10
	CP   C
	RET  NC
	
	LD   A,(IX+GNO)					; ix+GNO
	CP   G_Burger
	RET  Z							; bail out of this is a Burger
	
	LD   A,(InvulnerableCount)
	OR   A
	JR   NZ,DoSpriteExplode			; invulnerable - blow up whatever hit you
	
	LD   A,(IX+TYP)
	AND  $3F
	CP   T_Pram					; TYP = Pram
	JR   Z,SetStunned			; stun the player
	
	CP   T_NightSlasher			; TYP = Night Slasher
	JR   Z,PlayerLosesALife
	
	LD   A,(PlayerWeapon)		; Got a weapon?
	OR   A
	JR   Z,NoWeapon
	
	XOR  A						; yes, lose the weapon, not a life
	CALL SetWeapon
	
	LD   A,$04					; weapon gone jingle
	CALL PlayBeepJingle
	JR   SetStunned				; and stun you for good measure

NoWeapon:
	LD   A,(GirlfriendStatus)
	OR   A
	JR   NZ,WithGirlfriend

PlayerLosesALife:
	DEC  A
	LD   (PlayerLostLife),A
	JR   DoSpriteExplode

WithGirlfriend:					; if player is with his girlfriend when hit, he loses her, not a life
	PUSH IX
	LD   IX,(GirlfriendSpriteAddress)
	CALL LoseGirfriend
	POP  IX

SetStunned:
	LD   (IY+V_STUNNEDCOUNTER),$14			; IY+StunnedCounter

DoSpriteExplode:
	LD   A,(IX+TYP)
	AND  $3F
	JP   ExplodeSprite

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

HeadButtUpdate:
	LD   A,(HeadButtCounter)
	OR   A
	RET  Z
	
	LD   A,(IX+TYP)			; IX is the object potentially headbutted
	AND  $3F
	CP   T_MoveObject
	RET  NC					; ret if > $0a (MoveObject)
	
	CP   T_Pram
	RET  Z					; ret if Pram
	
	LD   DE,$7860
	LD   A,(PlayerDir)
	AND  $01
	JR   NZ,ButtSide
	
	LD   DE,$8878

ButtSide:
	LD   A,(IX+XNO)			; XNO
	CP   E
	RET  C
	
	CP   D
	RET  NC
	
	CALL GetSpriteHeight
	ADD  A,A
	ADD  A,$20
	ADD  A,(IX+YNO)			; YNO
	LD   C,A
	LD   A,(PlayerY)
	ADD  A,$48
	CP   C
	RET  C
	
	SUB  $28
	CP   C
	RET  NC
	
	CALL FreeAnyProjectiles
	CP   $07
	JR   NZ,HasHeadButted
	
	LD   (IY+V_LEVELENDCOUNTDOWN),$32					; fcd6 - LevelEndCountdown

HasHeadButted:
	LD   (IX+TYP),T_MoveOffScreenQuick	; IX+TYP = MoveOffScreenQuick
	CALL BumpScore
	LD   A,$09
	JP   PlayBeepFX

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

FireKnifeUpdate:
	LD   A,(PlayerWeaponInFlight)
	OR   A
	RET  Z
	
	LD   A,(SpriteDataLastXNO)
	SRL  A
	LD   L,A
	LD   H,$08
	LD   A,(IX+XNO)
	SRL  A
	ADD  A,$02
	LD   E,A
	LD   D,$08
	CALL HitA
	RET  C
	
	LD   A,(SpriteDataLastYNO)
	ADD  A,$20
	LD   L,A
	LD   H,$08
	LD   A,(IX+YNO)
	ADD  A,$24
	LD   E,A
	LD   D,$18
	CALL HitA
	RET  C
	
	XOR  A
	LD   (PlayerWeaponInFlight),A
	JR   HasHitObject

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

FireBulletUpdate:
	LD   B,$03
	LD   HL,BulletSprites

NextBullet:
	LD   A,(HL)			; run through all in flight bullets
	INC  L
	OR   A
	
	PUSH HL
	CALL P,MoveBullet
	POP  HL
	
	INC  L
	INC  L
	DJNZ NextBullet
	
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

MoveBullet:
	INC  L
	LD   A,(HL)
	EX   AF,AF'
	DEC  L
	LD   L,(HL)
	LD   A,(IX+XNO)
	ADD  A,$04
	LD   E,A
	LD   A,$08
	ADD  A,L
	CP   E
	RET  C
	
	LD   A,$10
	ADD  A,E
	CP   L
	RET  C
	
	EX   AF,AF'
	ADD  A,$20
	LD   L,A
	LD   A,(IX+YNO)
	ADD  A,$24
	LD   E,A
	LD   A,$04
	ADD  A,L
	CP   E
	RET  C
	
	LD   A,$18
	ADD  A,E
	CP   L
	RET  C
	
	POP  HL
	POP  HL
	DEC  L
	SET  7,(HL)			; mark bullet as done

HasHitObject:
	POP  AF
	LD   A,(IX+GNO)			; IX+GNO
	AND  $FE
	CP   G_Girlfriend		; hit Girlfriend?
	JR   Z,HasHitGirlfriend
	
	CP   G_NightSlasher		; hit the Night Slasher?
	JR   NZ,ExplodeSprite
	
	LD   (IY+V_LEVELENDCOUNTDOWN),$32		; LevelEndCountdown

ExplodeSprite:
	CALL FreeAnyProjectiles
	PUSH AF
	LD   A,(IX+YNO)
	ADD  A,$04
	LD   (IX+YNO),A
	LD   (IX+GNO),G_Explosion	; IX+GNO = Explosion
	LD   (IX+TYP),T_Explosion	; IX+TYP = Explosion
	LD   (IX+CNT2),$08			; IX+CNT2 = 8 (frames to run)
	POP  AF

BumpScore:			; enters with A == TYP
	ADD  A,A
	ADD  A,(PointsTable & $ff)	;$B3
	LD   L,A
	LD   H,(PointsTable / $100)	;$8C	; 8cb3 - PointsTable
	LD   D,(HL)
	LD   E,$03
	INC  L
	PUSH HL
	CALL ScoreAdd
	POP  HL
	LD   D,(HL)
	LD   E,$04
	CALL ScoreAdd
	LD   A,(PlayerWeapon)
	CP   WEAPON_MACHINEGUN
	JR   Z,AllDone

	LD   A,(AllBaddiesKilled)
	OR   A
	JR   NZ,AllDone
	
	LD   HL,(NumBaddiesToKill)
	DEC  HL
	LD   (NumBaddiesToKill),HL
	LD   A,H
	OR   L
	JR   NZ,AllDone
	
	DEC  A
	LD   (AllBaddiesKilled),A

AllDone:
	LD   A,$07
	JP   PlayBeepFX

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

FreeAnyProjectiles:					; if the TYP carries a projectile, free up the sprite slot that this sprite has reserved.
	LD   A,(IX+TYP)
	AND  $3F
	CP   T_PirateGuyJiggle			; TYP = PirateGuyJiggle?
	JR   Z,.FreeUpProjectile
	
	CP   T_BazookaLadyFire			; BazookaLady Fire?
	RET  NZ

.FreeUpProjectile:
	LD   L,(IX+CNT1)					; Projectile Sprite slot
	LD   H,(data_8800 / $100)		; $88 PAGE 8
	LD   (HL),$FF
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

HasHitGirlfriend:
	LD   A,(GirlfriendIsLeaving)
	OR   A
	RET  NZ					; if already leaving don't retrigger girfriend leaving

LoseGirfriend:
	LD   C,$00
	LD   A,(IX+XNO)			; IX+XNO
	CP   $70
	JR   C,GFExitLeft		; < $70 exit left
	INC  C			;		Exit right

GFExitLeft:
	LD   A,(IX+GNO)			; IX+GNO
	AND  $FE
	ADD  A,C
	LD   (IX+GNO),A			; Face the requisite direction
	LD   A,(IX+TYP)
	AND  $40
	ADD  A,T_GirlfriendOff
	LD   (IX+TYP),A			; TYP = GirfriendOff
	XOR  A
	LD   (GirlfriendStatus),A			; no more girfriend

	LD   A,$03				; play girlfriend leaving jingle
	LD   (IX+XSPD),A
	LD   (GirlfriendIsLeaving),A
	
	JP   PlayBeepJingle

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

WaitforRaster:			; wait on the floating bus
	LD   BC,$3F28
Raster1:
	LD   A,C
	IN   A,($FF)
	CP   B
	JR   NC,Raster1
	
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

UpdatePlayer:
	LD   A,(StunnedCounter)
	OR   A
	JR   Z,TryWeapon

	LD   (IY+V_FUDLR),$00		; IY+FUDLR
	DEC  (IY+V_STUNNEDCOUNTER)			; IY+StunnedCounter
	AND  $01
	JR   Z,TryWeapon
	
	LD   (IY+V_PLAYERFIREJIGGLE),$FE		; $FCC4 - PlayerFireJiggle

TryWeapon:
	LD   A,(PlayerWeapon)
	CP   WEAPON_MACHINEGUN	; machine gun?
	CALL Z,DrawLaserSight
	
	CALL TryFireWeapon
	LD   A,(LastPlayerDir)
	OR   A
	JR   Z,InHeadButt
	
	LD   A,(PlayerY)
	SUB  $08
	LD   (PlayerY),A
	XOR  A
	LD   (LastPlayerDir),A
	LD   A,(HeadButtCounter)
	OR   A
	JR   NZ,InHeadButt
	
	LD   A,(PlayerDir)
	AND  $01
	LD   (PlayerDir),A

InHeadButt:
	LD   C,(IY+V_FUDLR)			; IY+FUDLR
	LD   A,(PlayerInAir)
	OR   A
	JP   NZ,IsInAir
	
	LD   A,(PlayerDir)
	LD   B,A
	LD   DE,(PlayerX)
	LD   A,(PlayerInputDelay)
	OR   A
	JR   Z,ReadInput
	
	DEC  A
	AND  $07
	LD   (PlayerInputDelay),A
	BIT  3,C					; c = FUDLR
	JP   NZ,PressingUp

ContinueHeadButt:
	LD   A,(HeadButtCounter)
	OR   A
	RET  NZ
	
	LD   A,(PlayerAnimFrame)
	INC  A
	LD   (PlayerAnimFrame),A
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

ReadInput:
	XOR  A
	LD   (ScrollDirection),A
	LD   A,(HeadButtCounter)
	OR   A
	RET  NZ
	
	LD   A,C			; FUDLR
	AND  $0F
	ADD  A,A
	LD   L,A
	LD   H,(PlayerMoveTable / $100)		;$8A ; $8a00 - Page $0a - PlayerMoveTable
	LD   A,(HL)
	INC  L
	LD   H,(HL)
	LD   L,A
	LD   A,C
	JP   (HL)			; Jump to player movement function passing FUDLR in c and XY in DE

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

PlayerLeftRight:
	AND  $03
	RET  Z
	
	DEC  A
	LD   C,A
	LD   A,(PlayerDir)
	CP   C
	LD   A,C
	LD   (PlayerDir),A
	RET  NZ
	
	INC  A
	LD   (ScrollDirection),A
	CALL UpdateMapPos			; move the map along left or right after a full smooth cycle
	LD   A,(PlayerAnimFrame)
	INC  A
	LD   (PlayerAnimFrame),A
	LD   A,$07
	LD   (PlayerInputDelay),A
	
	LD   A,$01
	JP   PlayBeepFX

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

PlayerDown:
	LD   A,(PlayerY)
	ADD  A,$08
	LD   (PlayerY),A
	LD   A,C			; c=FUDLR
	AND  $03
	JP   PE,GetPlayDir
	
	ADD  A,$03
	JR   DoSet
	
GetPlayDir:
	LD   A,B			; b = PlayerDir
	AND  $01
	ADD  A,$04
DoSet:
	LD   (LastPlayerDir),A
	
	JP   SetPlayerDir

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

PressingUp:
	EX   AF,AF'
	LD   A,C
	AND  $03
	LD   C,A
	LD   A,(ScrollDirection)
	CP   C
	JP   NZ,ContinueHeadButt
	
	EX   AF,AF'
	CP   $07
	JR   NZ,IntoJump

PlayerJump:
	LD   A,$07
	LD   (PlayerInputDelay),A
	LD   A,C
	AND  $03
	LD   C,A			; leave only L/R in fudlr
	CALL PO,UpdateMapPos

IntoJump:
	LD   A,D
	LD   (PlayerJumpFallYStart),A
	LD   A,$35
	LD   (PlayerJumpFallIndex),A			; index into sine table for jump
	LD   (PlayerInAir),A
	LD   A,C								; c = l/r
	ADD  A,(LRToDir & $ff)					;$FC
	LD   L,A
	LD   H,(LRToDir / $100)					;$8A; $8afc - LRToDir - maps LR bits to player dir
	LD   A,(HL)
	OR   A
	JP   P,SetInAir

SetPlayerFalling:
	LD   A,(PlayerDir)
	AND  $01

SetInAir:
	ADD  A,$02								; in air
	LD   (PlayerDir),A
	XOR  A
	LD   (PlayerAnimFrame),A
	
	LD   A,$03
	JP   PlayBeepFX

IsInAir:
	LD   A,(PlayerInputDelay)
	OR   A
	JR   NZ,StillInputDelay
	
	EX   AF,AF'
	LD   A,(ScrollDirection)
	AND  $03
	JR   Z,NoDirect
	
	CALL UpdateMapPos
	EX   AF,AF'
StillInputDelay:
	DEC  A
	AND  $07
	LD   (PlayerInputDelay),A

NoDirect:
	LD   A,(PlayerJumpFallIndex)
	ADD  A,$04
	LD   (PlayerJumpFallIndex),A
	LD   L,A
	LD   H,(SineTable / $100)		;$FC	; fc00 SineTable
	LD   A,(HL)
	ADD  A,A
	LD   C,A
	LD   A,(PlayerJumpFallYStart)
	ADD  A,$6A
	SUB  C
	AND  $FE
	LD   (PlayerY),A
	AND  $F0
	LD   H,A
	LD   A,L
	CP   $6D
	RET  C						; not end of fall index
	
	LD   A,(PlayerX)
	ADD  A,$08
	LD   L,A
	LD   A,$20
	CALL GetMapPosXY
	LD   A,(HL)
	OR   A
	RET  P					; return if nothing under us

	LD   A,(PlayerY)		; lock Player landing to a 16 pixel boundary
	AND  $F0
	LD   (PlayerY),A
	
	XOR  A
	LD   (PlayerInAir),A
	LD   A,(PlayerDir)
	AND  $01
	LD   (PlayerDir),A
	
	LD   A,$02
	JP   PlayBeepFX

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

UpdateMapPos:

	LD   (ScrollDirection),A
	ADD  A,(DirectionTable & $ff)	;$98
	LD   L,A
	LD   H,(DirectionTable / $100)	;$88 ; 8898 DirectionTable
	LD   A,(MapXpos)
	SUB  (HL)
	LD   (MapXpos),A
	LD   A,$04
	LD   (BuildScrollCounter),A
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

AddInScrollDirection:
	PUSH HL
	LD   C,A
	LD   A,(ScrollDirection)
	ADD  A,(DirectionTable & $ff)		;$98
	LD   L,A
	LD   H,(DirectionTable / $100)		;$88	; 8898 DirectionTable
	LD   A,(HL)
	ADD  A,C
	POP  HL
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

TryFireWeapon:
	BIT  4,(IY+V_FUDLR)				; IY+FUDLR
	JR   NZ,FirePlayerWeapon
	
	XOR  A
	LD   (FireDebounce),A
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

FirePlayerWeapon:
	LD   A,(PlayerWeapon)
	ADD  A,A
	ADD  A,(PlayerWeaponRoutines & $ff)			;$F3
	LD   L,A
	LD   H,(PlayerWeaponRoutines /$100 );$88	; 88f3 PlayerWeaponRoutines
	LD   A,(HL)
	INC  L
	LD   H,(HL)
	LD   L,A
	JP   (HL)			; Fire the player's weapon (start it firing)

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

DoHeadbutt:
	LD   A,(HeadButtCounter)
	OR   (IY+V_FIREDEBOUNCE)				; $fcca - FireDebounce
	RET  NZ
	
	LD   A,$06
	CALL PlayBeepFX
	
	LD   (IY+V_HEADBUTTCOUNTER),$06			; $fc0b - HeadButtCounter
	LD   A,(PlayerDir)
	AND  $01
	ADD  A,$0C
	
SetPlayerDir:
	LD   (PlayerDir),A
	XOR  A
	LD   (PlayerAnimFrame),A
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

DoKnifeThrow:
	LD   A,(PlayerWeaponInFlight)
	OR   A
	RET  NZ
	LD   A,(PlayerY)
	ADD  A,$0C
	LD   H,A
	LD   L,$74						; x = $74
	LD   (KnifeYStart),A
	LD   (SpriteDataLastXNO),HL
	LD   A,(PlayerDir)
	AND  $01
	XOR  $01
	ADD  A,G_Knife
	LD   (SpriteDataLastGNO),A
	LD   A,$35
	LD   (KnifeYIndex),A
	LD   (PlayerWeaponInFlight),A
	LD   A,(KnifeIndexAdditive)		; additive cycles with every throw
	INC  A
	AND  $03
	LD   (KnifeIndexAdditive),A
	ADD  A,$02						; A = 5..8
	LD   (AdditiveMod+1),A			; self mod KnifeYIndex additive value
	LD   A,$04
	JP   PlayBeepFX

KnifeIndexAdditive:
	db $00 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

DoFireGun:
	LD 	 A, (BulletFireDelay)
	OR   A
	RET  NZ

	CALL FindFreeBullet
	RET  P
	
	LD   A,$08
	LD   (BulletFireDelay),A
	LD   A,(SpriteDataLastGNO)
	AND  $01
	ADD  A,$02
	LD   (HL),A
	INC  L
	LD   A,(SpriteDataLastXNO)
	ADD  A,$08
	AND  $F8
	LD   (HL),A
	INC  L
	LD   A,(SpriteDataLastYNO)
	JR   GoFire

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

DoFireMachineGun:
	LD   A,(BulletFireDelay)
	OR   A
	RET  NZ
	
	CALL FindFreeBullet
	RET  P
	
	LD   A,$04
	LD   (BulletFireDelay),A
	LD   A,(SpriteDataLastGNO)
	AND  $01
	LD   (HL),A
	INC  L
	LD   A,(SpriteDataLastXNO)
	ADD  A,$08
	AND  $F8
	LD   (HL),A
	INC  L
	LD   A,(SpriteDataLastYNO)
	ADD  A,$04

GoFire:
	LD   (HL),A
	LD   A,$FE
	LD   (PlayerFireJiggle),A
	
	LD   A,$05
	JP   PlayBeepFX

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

DrawLaserSight:
	LD   A,(SpriteDataLastYNO)
	ADD  A,$02
	RET  M
	
	LD   D,A
	LD   E,$08
	LD   A,(SpriteDataLastGNO)
	AND  $01
	JR   NZ,CalcSightPos
	LD   E,$90

CalcSightPos:
	CALL PixAddr
	LD   B,$0C
	LD   A,(LaserSightByte)
	CPL							; toggle graphic
	LD   (LaserSightByte),A
LSLoop:
	LD   (HL),A
	INC  L
	DJNZ LSLoop
	
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

PlayerFall:
	LD   A,(PlayerInAir)
	OR   A
	RET  NZ
	
	LD   HL,(PlayerX)
	LD   A,L
	ADD  A,$08
	LD   L,A
	LD   A,$20
	CALL GetMapPosXY
	LD   A,(HL)
	OR   A
	RET  M
	
	LD   A,(PlayerY)
	ADD  A,$18
	LD   (PlayerJumpFallYStart),A
	LD   A,$5A							; index into sine table for fall
	LD   (PlayerJumpFallIndex),A
	LD   (PlayerInAir),A
	CALL SetPlayerFalling
	
	LD   A,$03
	JP   PlayBeepFX

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

CalcEdgeBlocks:					; exits D E with 8 bit bitmask for left and right columns of 8 rows 
	LD   A,(MasterMapXpos)
	ADD  A,$03
	LD   L,A
	LD   H,(MapBuffer / $100)	;$80
	LD   E,$00
	LD   D,E
	LD   B,$08					; 8 rows
RowLP:
	LD   A,(HL)
	ADD  A,A
	RR   E
	INC  H
	DJNZ RowLP
	
	LD   A,L
	SUB  $1E
	LD   L,A
	LD   H,$80
	LD   B,$08					; 8 rows
RowLP2:
	LD   A,(HL)
	ADD  A,A
	RR   D
	INC  H
	DJNZ RowLP2
	
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

DoBurgers:
	LD   A,(PlayerInputDelay)
	OR   A
	RET  NZ
	LD   A,(BurgerCount)
	OR   A
	RET  Z
	
	LD   IX,SpriteData			; First sprite in list is a burger
	LD   A,(RoundNumber)			; round number?
	ADD  A,A
	ADD  A,(BurgerTables & $ff)		;$32
	LD   L,A
	LD   H,(BurgerTables / $100)	;$8D	; 8d32 BurgerTables for each round
	LD   A,(HL)
	INC  L
	LD   H,(HL)
	LD   L,A			; HL this round's burger positions
	
	LD   B,$04			; 4 burgers per level

FindBurger:
	LD   A,(HL)
	INC  L
	ADD  A,A
	JR   C,NextBurger
	
	LD   C,A
	LD   E,$F2
	LD   A,(MapXPosAttr)
	CP   C
	JR   Z,OnScreen
	
	LD   E,$02
	SUB  $1E
	CP   C
	JR   Z,OnScreen
	ADD  A,$0E
	CP   C
	JR   Z,TryPickUpBurger

NextBurger:
	INC  L
	INC  L
	DJNZ FindBurger
	
	RET 

OnScreen:
	LD   (IX+TYP),T_MoveObject	; IX+TYP = MoveableObject (BURGER)
	LD   A,(HL)
	LD   (IX+YNO),A				; IX+YNO
	LD   (IX+XNO),E				; IX+XNO
	LD   (IX+GNO),G_Burger		; IX+GNO
	LD   (IX+XSPD),$00
	RET 

TryPickUpBurger:
	LD   A,(PlayerY)		; same Y as burger
	ADD  A,$10
	CP   (HL)
	JR   NZ,NextBurger
	
	LD   (IX+TYP),$FF		; kill burger sprite
	INC  L
	LD   A,(HL)				; Weapon pickup in this burger
	DEC  L
	DEC  L
	SET  7,(HL)				; Mark Burger as picked up
	PUSH AF
	LD   DE,$0102
	CALL ScoreAdd
	DEC  (IY+V_BURGERCOUNT)			; IY+$34 = BurgerCount
	JR   NZ,BurgersRemain
	
	LD   A,$04				; free up this sprite when there are no burgers left
	LD   HL,SpriteData
	LD   (operand_A8CB+1),A
	LD   (operand_A8CD+1),HL

BurgersRemain:
	POP  AF						; weapon pickup
	ADD  A,(IY+V_BURGERWEAPONADJUST)				; +$2c = BurgerWeaponAdjust
	AND  $03
	JP   NZ,SetWeapon
	
	DEC  A						; set invulnerability
	LD   (InvulnerableCount),A
	
	LD   A,$02					; invulnerability jingle
	JP   PlayBeepJingle

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
; In game, single beep jingles
;

Jingle1:
	db $18 
	db $04 
	db $10 
	db $03 
	db $18 
	db $02 
	db $10 
	db $02 
	db $18 
	db $02 
	db $10 
	db $02 
	db $1C 
	db $04 
	db $18 
	db $04 
	db $1C 
	db $04 
	db $1F 
	db $04 
	db $24 
	db $0C 
Jingle6:
	db $12 
	db $01 
	db $13 
	db $01 
	db $14 
	db $01 
	db $15 
	db $01 
	db $16 
	db $01 
	db $17 
	db $01 
	db $18 
	db $01 
	db $19 
	db $01 
	db $16 
	db $01 
	db $17 
	db $01 
	db $18 
	db $01 
	db $19 
	db $01 
	db $1A 
	db $01 
	db $1B 
	db $01 
	db $1C 
	db $01 
	db $1D 
	db $01 
	db $1F 
	db $04 
	db $1D 
	db $04 
	db $1C 
	db $04 
	db $1A 
	db $04 
	db $18 
	db $0C 
	db $FF 
Jingle2:
	db $1C 
	db $04 
	db $1D 
	db $04 
	db $1C 
	db $04 
	db $1A 
	db $04 
	db $10 
	db $04 
	db $1F 
	db $04 
	db $18 
	db $0D 
	db $FF 
Jingle3:
	db $24 
	db $04 
	db $18 
	db $04 
	db $1B 
	db $04 
	db $1F 
	db $04 
	db $20 
	db $04 
	db $1F 
	db $04 
	db $1B 
	db $04 
	db $1A 
	db $04 
	db $18 
	db $06 
	db $FF 
Jingle4:
	db $1A 
	db $01 
	db $1B 
	db $03 
	db $10 
	db $08 
	db $17 
	db $01 
	db $18 
	db $03 
	db $10 
	db $04 
	db $1C 
	db $01 
	db $1D 
	db $03 
	db $1A 
	db $01 
	db $1B 
	db $03 
	db $10 
	db $08 
	db $17 
	db $01 
	db $18 
	db $03 
	db $10 
	db $08 
	db $1A 
	db $01 
	db $1B 
	db $03 
	db $10 
	db $04 
	db $1A 
	db $01 
	db $1B 
	db $03 
	db $17 
	db $01 
	db $18 
	db $03 
	db $10 
	db $04 
	db $1C 
	db $01 
	db $1D 
	db $03 
	db $1A 
	db $01 
	db $1B 
	db $03 
	db $10 
	db $08 
	db $17 
	db $01 
	db $18 
	db $03 
	db $FF 
Jingle5:
	db $19 
	db $03 
	db $10 
	db $01 
	db $19 
	db $03 
	db $10 
	db $05 
	db $19 
	db $03 
	db $10 
	db $01 
	db $1B 
	db $03 
	db $10 
	db $05 
	db $1D 
	db $03 
	db $10 
	db $05 
	db $1E 
	db $03 
	db $10 
	db $0D 
	db $11 
	db $10 
	db $FF

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;
	
SetupRound:
	LD   A,(RoundNumber)
	ADD  A,A
	LD   B,A
	ADD  A,A
	LD   C,A
	ADD  A,B						; x6
	ADD  A,(RoundSetupTable & $ff)			;$08
	LD   L,A
	LD   H,(RoundSetupTable / $100);$8D		; $8d08 - RoundSetupTable
	LD   A,(HL)
	LD   (GroundColour1),A				; mod sprint data colour 1
	INC  L
	LD   A,(HL)
	LD   (GroundColour2),A				; mod sprint data colour 2
	INC  L
	LD   A,(HL)
	LD   (ModBlankBlock+1),A			; blank block bit pattern (self mod)
	INC  L
	LD   A,(HL)			; start xpos
	LD   (MapXpos),A
	LD   (MapXPosAttr),A
	LD   (MasterMapXpos),A
	INC  L
	PUSH HL
	LD   A,C							; round x 4
	ADD  A,A							; round x 8 - 8 bytes per round (4 weapons x 2 offsets per round)
	ADD  A,(RoundWeaponOffsets & $ff )	; $1A
	LD   L,A							; HL = 8d1a - RoundWeaponOffsets
	LD   DE,WeaponOffsets
	LD   BC,$0008
	LDIR				; Copy to WeaponOffsets
	POP  HL
	LD   A,(HL)			; address of map blocks (starting with ground graphics)
	INC  L
	LD   H,(HL)
	LD   L,A
	LD   B,$09					; 9 block triples to process
	LD   DE,PreShiftedTiles		; ee80 start of preshift memory for these map blocks (starting with ground graphics)

NextBlock:
	PUSH BC
	PUSH HL
	PUSH DE
	LD   BC,$0060
	LDIR
	POP  HL
	LD   B,$03			; 3 shifts of the base block

NextPreShift:
	PUSH BC
	PUSH DE
	LD   BC,$0060		; copy base block down
	LDIR
	
	POP  HL
	PUSH HL
	CALL PreShiftBlock
	EX   DE,HL
	POP  HL
	POP  BC
	DJNZ NextPreShift
	
	POP  HL
	LD   BC,$0060
	ADD  HL,BC
	POP  BC
	DJNZ NextBlock
	
	RET 

PreShiftBlock:
	LD   B,$10			; 16 pixel high blocks
NextShiftLine:
	PUSH BC
	LD   C,$02			; two pixel shifts

NextShift:
	PUSH HL
	LD   A,(HL)
	RRA
	INC  HL
	LD   B,$05

NextByte:
	RR   (HL)
	INC  HL
	DJNZ NextByte
	POP  HL
	RR   (HL)
	DEC  C
	JR   NZ,NextShift

	LD   BC,$0006			; 6 bytes per block line
	ADD  HL,BC
	POP  BC
	DJNZ NextShiftLine
	RET 
	

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

ScrollMap:
	LD   A,(ScrollDirection)
	ADD  A,(DirectionTable & $ff)		;$98
	LD   L,A
	LD   H,(DirectionTable / $100)		;$88	; DirectionTable at 8898
	LD   A,(SmoothX)
	OR   A
	JR   NZ,NoMapXUpdate
	
	LD   A,(MasterMapXpos)
	SUB  (HL)
	LD   (MasterMapXpos),A
	
	RET 

NoMapXUpdate:
	CP   $02
	RET  NZ
	
	LD   A,(MapXPosAttr)
	SUB  (HL)
	LD   (MapXPosAttr),A
	RET 

MasterMapXpos:			
	db $B2 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;


GetMapPosXY:
	ADD  A,H
	JP   M,MapOffScreen
	SRL  A
	SRL  A
	SRL  A
	SRL  A
	ADD  A,(MapBuffer / $100 )		;$80	; $80 high byte of MapBuffer ($8000)
	LD   H,A
	SRL  L
	SRL  L
	SRL  L
	LD   A,(MasterMapXpos)
	SUB  $1C
	ADD  A,L
	OR   $01
	LD   L,A
	RET 

MapOffScreen:
	LD   HL,$0000
	CP   $AA
	RET  C
	DEC  HL
	RET 

PlayerAnimFrame:
	db $41 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

DrawSprites:
	LD   A,(InvulnerableCount)
	OR   A
	JR   Z,DrawPlayer
	
	DEC  A
	LD   (InvulnerableCount),A
	CP   $14
	JR   NZ,StillInvulnerable
	
	LD   A,$0A			; warn that invulnerability is almost finished
	CALL PlayBeepFX
	
	XOR  A
	LD   (BeepNum),A

StillInvulnerable:
	AND  $01
	JR   Z,DrawPlayer

	LD   BC,$00C8				; burn some time as we're not drawing the player this frame
DelayLp:
	DEC  BC
	LD   A,B
	OR   C
	JR   NZ,DelayLp
	
	JR   SkipDrawPlayer

DrawPlayer:
	LD   HL,PlayerX
	LD   E,(HL)
	LD   A,(PlayerFireJiggle)
	INC  L
	ADD  A,(HL)
	LD   D,A
	XOR  A							; jiggle Y +-2 pixels whilst firing a gun
	LD   (PlayerFireJiggle),A
	INC  L
	LD   C,(HL)
	INC  L
	LD   A,(PlayerAnimFrame)		; rather than being the pre shift position A is used for the player anim frame as he stays on the same X position
	AND  $06
	CALL DrawSprite

SkipDrawPlayer:
	CALL DoPlayerWeapons
	CALL DrawBullets
	LD   HL,SpriteData
	LD   B,$07
	
SprLoop:
	LD   A,(HL)
	INC  L
	OR   A
	JP   M,NextSpr
	PUSH BC
	PUSH HL
	CALL DrawSpriteFromHL
	POP  HL
	POP  BC
	
NextSpr:
	LD   A,L
	ADD  A,$06
	LD   L,A
	DJNZ SprLoop
	
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

ClipSpriteY:
	SRL  E
	SRL  E
	SRL  E
	LD   L,E
	LD   H,$40
	LD   A,C							; c = GNO
	ADD  A,A
	ADD  A,C							; x3 for index into SpriteDataTable
	ADD  A,(SpriteGFXTable & $ff)		; $2B
	EXX 
	LD   L,A
	LD   H,(SpriteGFXTable / $100 )		;$88; 882B SpriteDataTable
	LD   E,(HL)
	INC  L
	LD   D,(HL)						; DE = sprite bitmap address
	INC  L
	LD   A,(HL)						; Sprite Size Index
	ADD  A,(SpriteSizes & $ff)		; $23
	LD   L,A						; 8823 SpriteSizes
	LD   A,(HL)						; A = SpriteHeight
	EXX 
	ADD  A,A
	ADD  A,D
	RET  M				;  off screen
	
	SRL  A
	LD   B,A
	RET  Z				; off screen
	EXX 
	LD   C,A
	LD   A,(HL)			; sprite height
	SUB  C
	EX   AF,AF'			; XNO
	AND  $06			; x pre-shift offset
	INC  L
	ADD  A,(HL)			; offsettab - offset to which pre-shift we're using
	LD   L,A
	LD   A,(HL)
	INC  L
	LD   H,(HL)
	LD   L,A
	ADD  HL,DE
	EX   AF,AF'
	LD   E,A			; a = num lines clipped off top
	ADD  A,A
	ADD  A,E
	ADD  A,A
	ADD  A,A			; x12
	LD   E,A
	LD   D,$00
	ADD  HL,DE			; HL clipped sprite data address
	LD   (SPStr),SP
	LD   SP,HL
	EXX 
	JR   LineLoop

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

DrawSpriteFromHL:
	LD   E,(HL)			; XNO
	INC  L
	LD   D,(HL)			; YNO
	INC  L
	LD   C,(HL)			; GNO
	INC  L
	LD   A,E

DrawSprite:
	EX   AF,AF'			; 'AF a holds the pre-shift offset
	LD   A,D
	OR   A
	JP   M,ClipSpriteY
	
	CALL PixAddr
	LD   A,C			; GNO
	ADD  A,A
	ADD  A,C			; x 3 for index into SpriteDataTable
	ADD  A,(SpriteGFXTable & $ff )	;$2B
	EXX 
	LD   L,A
	LD   H,(SpriteGFXTable / $100)	;$88			; 882B SpriteDataTable
	LD   E,(HL)
	INC  L
	LD   D,(HL)
	INC  L
	LD   A,(HL)
	ADD  A,(SpriteSizes & $ff)		;$23			; 8823 SpriteSizes
	LD   L,A
	LD   A,(HL)			; A = sprite's height
	INC  L
	EX   AF,AF'
	AND  $06			; x shift offset
	ADD  A,(HL)			; offsettab - which pre-shift offset to use
	LD   L,A
	LD   A,(HL)
	INC  L
	LD   H,(HL)
	LD   L,A
	ADD  HL,DE			; HL Sprite address
	LD   (SPStr),SP
	LD   SP,HL			; Stack points to sprite data
	EXX 
	EX   AF,AF'
	LD   B,A
	
LineLoop:
	POP  DE			; zig zag plot loop
	LD   A,(HL)
	AND  E
	OR   D
	LD   (HL),A
	INC  L
	POP  DE
	LD   A,(HL)
	AND  E
	OR   D
	LD   (HL),A
	INC  L
	POP  DE
	LD   A,(HL)
	AND  E
	OR   D
	LD   (HL),A
	INC  H
	POP  DE
	LD   A,(HL)
	AND  E
	OR   D
	LD   (HL),A
	DEC  L
	POP  DE
	LD   A,(HL)
	AND  E
	OR   D
	LD   (HL),A
	DEC  L
	POP  DE
	LD   A,(HL)
	AND  E
	OR   D
	LD   (HL),A
	INC  H
	LD   A,H
	AND  $06
	JR   NZ,NextSpriteLine
	
	LD   A,L
	ADD  A,$20
	LD   L,A
	JR   C,NextSpriteLine
	
	LD   A,H
	SUB  $08
	LD   H,A
	
NextSpriteLine:
	
	DJNZ LineLoop
	LD   SP,(SPStr)
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

DoPlayerWeapons:
	LD   A,(PlayerWeapon)
	ADD  A,A
	ADD  A,(WeaponJumpTable & $ff)		;$C4
	LD   L,A
	LD   H,(WeaponJumpTable / $100)		;$8A	; Weapon Jump table at 8ac4
	LD   A,(HL)
	INC  L
	LD   H,(HL)
	LD   L,A
	JP   (HL)

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

GunFunc:
	LD   DE,SpriteDataLastGNO
	LD   A,(PlayerDir)
	LD   B,A
	AND  $01			; mask out just left / right
	LD   C,A
	ADD  A,$08
	LD   (DE),A			; GNO = $08/$09
	DEC  E
	LD   A,B
	LD   B,$08
	AND  $FE
	CP   $04			; Player ducked down?
	JR   NZ,NotDucked
	
	LD   B,$0C

NotDucked:
	LD   A,C			; c = Direction and 1 
	ADD  A,A			; x2
	ADD  A,B			; + $08 or $0c if player ducked down
	LD   L,A
	LD   H,(WeaponOffsets / $100)	;$8C	; $8c00 - WeaponOffsets
	LD   A,(PlayerY)
	ADD  A,(HL)			; + weapon Y offset
	LD   (DE),A			; YNO
	DEC  E
	INC  L
	LD   A,(PlayerX)
	ADD  A,(HL)			; + weapon X offset
	LD   (DE),A			; XNO
	EX   DE,HL
	JP   DrawSpriteFromHL			; draw player's weapon

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

MachineGunFunc:
	LD   DE,SpriteDataLastGNO
	LD   A,(PlayerDir)
	LD   B,A
	AND  $01
	LD   C,A
	ADD  A,$0A
	LD   (DE),A
	DEC  E
	LD   A,B
	LD   B,$10			; +$10 if stood up
	AND  $FE
	CP   $04
	JR   NZ,NotDucked
	
	LD   B,$14			; +$14 if ducked
	JR   NotDucked

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

KnifeFunc:
	LD   A,(PlayerWeaponInFlight)
	OR   A
	RET  Z
	LD   A,(KnifeYIndex)

AdditiveMod:
	ADD  A,$04						; self mod index additive
	LD   (KnifeYIndex),A
	LD   L,A
	LD   H,(SineTable / $100)		;$FC ; HL = $fc00 (SineTable) + KnifeYIndex
	LD   A,(HL)
	ADD  A,A
	LD   L,A
	LD   A,(KnifeYStart)
	ADD  A,$6A
	SUB  L
	AND  $FE
	LD   (SpriteDataLastYNO),A
	LD   HL,SpriteDataLastXNO
	LD   A,(SpriteDataLastGNO)
	AND  $01
	LD   A,(HL)
	JR   Z,.KnifeLeft
	
	ADD  A,$08
	JR   SetKnifeX
	
.KnifeLeft:
	SUB  $08
SetKnifeX:
	CALL AddInScrollDirection
	CP   $F0
	JR   NC,KnifeOff
	LD   (HL),A						; XNO
	JP   DrawSpriteFromHL			; Draw Knife
	
KnifeOff:
	XOR  A
	LD   (PlayerWeaponInFlight),A
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

DrawMap:
	LD   A,(BlankBlockPattern)
	
ModParallaxBlock:
	NOP 						; nop, rlca, rrca - to shift the bits of the parallax/blank block according to scroll direction
	LD   (BlankBlockPattern),A
	LD   L,A
	LD   H,A
	EXX 
	LD   (SPStr),SP
	LD   A,(SmoothX)
	AND  $03
	ADD  A,A
	ADD  A,(GroundShiftOffsets & $ff)		;$85
	LD   L,A
	LD   H,(GroundShiftOffsets / $100)		;$88	; $8885 - GroundShiftOffsets
	LD   A,(HL)
	INC  L
	LD   H,(HL)
	LD   L,A
	LD   (ModCounter+1),HL			; self mod counter
	LD   HL,$401E					; Start Screen Line
	LD   DE,(WorkingScrollTable)
	LD   A,(SmoothX)
	CP   $04
	JR   C,NextMapRow
	
	INC  L
NextMapRow:
	LD   A,(DE)
	LD   (ModJumpL+1),A				; self mod jump
	INC  E
	LD   A,(DE)
	OR   A
	JR   Z,Finished
	
	LD   (ModJumpL+2),A				; self mod jump
	INC  E

ModCounter:
	LD   BC,$0000

	LD   A,(DE)
	LD   IYL,A
	INC  E
	LD   A,(DE)
	LD   IYH,A
	INC  E
	ADD  IY,BC
	LD   A,(DE)
	LD   IXL,A
	INC  E
	LD   A,(DE)
	LD   IXH,A
	INC  E
	ADD  IX,BC
	LD   C,$02			; num of rows per tile

NextRow:
	LD   B,$08			; num lines per row

NextLine:
	EXX 
	LD   SP,IY
	POP  BC
	POP  DE
	POP  AF
	EXX 
	LD   SP,HL
	EXX 

ModJumpL:
	JP   PushMapEven		; this jump is self modified

NextScanLine:
	LD   DE,$0006
	ADD  IY,DE
	ADD  IX,DE
	EXX 
	INC  H
	DJNZ NextLine

	LD   A,L
	ADD  A,$20
	LD   L,A
	JR   C,LinesDown
	LD   A,H
	SUB  $08
	LD   H,A
LinesDown:
	DEC  C
	JR   NZ,NextRow
	JR   NextMapRow

Finished:
	LD   SP,(SPStr)
	LD   IY,Variables	;$FCB0
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

DrawGround:
	CALL PushGroundGraphics
	LD   A,(ScrollDirection)
	ADD  A,A
	ADD  A,(ScrollUpdateTable & $ff)		;$91
	LD   L,A
	LD   H,(ScrollUpdateTable / $100)		;$88	; $8891 ScrollUpdateTable
	LD   A,(HL)
	OR   A
	RET  Z

	INC  L					; time to scroll and wrap the push instructions
	LD   C,A
	LD   A,(GroundScrollX)
	ADD  A,C
	AND  $07
	LD   (GroundScrollX),A
	CP   (HL)				; time to scroll the push instructions?
	RET  NZ

	DEC  C
	JR   NZ,ScrRight

	LD   HL,operand_9D85		; scroll the push instructions
	LD   DE,operand_9D84
	LD   BC,$000D
	LDIR
	LD   A,(operand_9D88)		; wrap the push instructions
	LD   (operand_9D91),A
	RET 

ScrRight:
	LD   HL,operand_9D90		; scroll the push instructions
	LD   DE,operand_9D91
	LD   BC,$000D
	LDDR
	LD   A,(operand_9D87)		; wrap the push instructions
	LD   (operand_9D84),A
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

PushGroundGraphics:
	LD   A,(GroundScrollX)
	AND  $03
	ADD  A,A
	ADD  A,(GroundShiftOffsets & $ff)		;$85
	LD   L,A
	LD   H,(GroundShiftOffsets / $100)		;$88	; $8885 GroundShiftOffsets
	LD   E,(HL)
	INC  L
	LD   D,(HL)
	LD   IY,PreShiftedTiles		;$EE80	; base ground graphic
	ADD  IY,DE					; plus offset for which pre shift we're on
	LD   (SPStr),SP
	LD   C,$02
	LD   HL,$501E				; start screen line for ground
	LD   A,(GroundScrollX)
	CP   $04
	JR   C,NextGroundLines
	INC  L

NextGroundLines:
	LD   B,$08

NextGroundLine:
	EXX 
	LD   SP,IY
	POP  BC
	POP  DE
	POP  HL
	EXX 
	LD   SP,HL
	EX   AF,AF'
	EXX 

operand_9D84:	PUSH BC
operand_9D85:	PUSH HL
				PUSH DE
operand_9D87:	PUSH BC
operand_9D88:	PUSH HL
				PUSH DE
				PUSH BC
				PUSH HL
				PUSH DE
				PUSH BC
				PUSH HL
				PUSH DE
operand_9D90:	PUSH BC
operand_9D91:	PUSH HL

	LD   DE,$0006
	ADD  IY,DE
	EXX 
	INC  H
	DJNZ NextGroundLine

	LD   A,L
	ADD  A,$20
	LD   L,A
	JR   C,NoHigh
	LD   A,H
	SUB  $08
	LD   H,A
NoHigh:
	DEC  C
	JR   NZ,NextGroundLines
	JP   Finished

BuildScrollCounter:			; 4..0
	db $00 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

GenerateMapTables:

	CALL GenerateMapTable
	
GenerateMapTable:						; calls itself to generate odd/even tables
	LD   A, (MapBuffer / $100)-1		;$7F	; Page $80-1 (hi)MapBuffer-1
	LD   (MapLineHi),A
	LD   B,$08							;  8 ROWS
NxtMapRow:
	PUSH BC
	CALL BuildScrollCode
	POP  BC
	DJNZ NxtMapRow
	
	LD   HL,(WorkingScrollTable)
	LD   DE,(OtherScrollTable)
	LD   (WorkingScrollTable),DE
	LD   (OtherScrollTable),HL
	LD   (ScrollTableToBuild),HL
	
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

GenerateScrollCode:

	CALL TryBuildScrollCode						; build scroll code if it is time to do so
	
	LD   A,(ScrollDirection)
	LD   C,A
	ADD  A,(SelfModInstructionTable & $ff )			;$A4
	LD   L,A
	LD   H,(SelfModInstructionTable / $100)			;$88	; 88a4 SelfModInstructionTable
	LD   A,(HL)
	LD   (ModParallaxBlock),A	; self mod in DrawMap
	LD   (ModStars1),A			; self mod in DrawStars
	INC  L
	INC  L
	INC  L
	INC  L
	LD   A,(HL)
	LD   (ModStars2),A			; self mod in DrawStars
	LD   A,C					; a = scrolldirection
	ADD  A,A
	ADD  A,(ScrollUpdateTable & $ff)			;$91
	LD   L,A
	LD   H,(ScrollUpdateTable / $100)			;$88		; 8891 ScrollUpdateTable
	LD   A,(HL)				; how much to scroll by
	OR   A
	RET  Z					; bail if 0 movement
	
	LD   C,A
	INC  L
	LD   B,(HL)				; b = when to flip WorkingScrollTable
	LD   A,(SmoothX)
	ADD  A,C
	AND  $07
	LD   (SmoothX),A
	CP   B					; time to flip?
	RET  NZ

	LD   HL,(WorkingScrollTable)			; swap tables storing addresses to generate code to
	LD   DE,(OtherScrollTable)
	LD   (WorkingScrollTable),DE
	LD   (OtherScrollTable),HL
	LD   (ScrollTableToBuild),HL
	
	LD   A,(MapBuffer / $100)-1				;$7F	; Page $80 - 1
	LD   (MapLineHi),A

TryBuildScrollCode:							; time to generate new code?
	LD   A,(BuildScrollCounter)
	OR   A
	RET  Z
	
	DEC  A									; yes!
	LD   (BuildScrollCounter),A
	
	CALL BuildScrollCode					; Build both versions of the code

BuildScrollCode:
	LD   HL,(ScrollTableToBuild)
	LD   E,(HL)
	INC  L
	LD   D,(HL)						; DE addr of code block to build a row (we generate the code to here)
	INC  L
	PUSH HL
	PUSH DE
	EXX 
	POP  DE
	LD   A,(MapLineHi)
	INC  A
	LD   (MapLineHi),A
	LD   H,A
	LD   A,(MapXpos)
	LD   L,A
	LD   A,$FF
	LD   (UsingTileset),A

	LD   B,$0E			; 14 blocks across
ScanMap:
	LD   A,(HL)
	OR   A
	JR   NZ,NotBlank

	LD   A,$E5			; PUSH HL instruction (blank block)
	LD   (DE),A			; write out code
	INC  DE
	DEC  L
	DEC  L
	DJNZ ScanMap
	
	JR   WriteEndLineCode

NotBlank:
	AND  $7C
	SRL  A
	LD   (UsingTileset),A
	CALL WriteTilesetAddress
	LD   A,(HL)
	PUSH HL
	JR   ConvertBlockNumToCode

NextMapBlock:
	LD   A,(HL)
	PUSH HL
	OR   A
	JR   Z,BlankBlock

	PUSH AF					
	AND  $7C
	SRL  A
	LD   C,A
	LD   A,(UsingTileset)				; second tileset on this row?
	CP   C
	JR   Z,NoTilesetChange
	
	LD   A,C							; switch to second tileset
	LD   (UsingTileset),A
	CALL WriteTilesetAddress
	CALL WriteTileset2Code

NoTilesetChange:
	POP  AF
ConvertBlockNumToCode:
	AND  $03
BlankBlock:
	ADD  A,(PushInstructions & $ff )		;$8D
	LD   L,A
	LD   H,(PushInstructions / $100)		;$88; 888d PushInstructions
	LD   A,(HL)
	LD   (DE),A								; write our requisite push
	INC  DE
	POP  HL
	DEC  L
	DEC  L
	DJNZ NextMapBlock

WriteEndLineCode:
	LD   HL,EndLineCode						; write code to finish drawing this row
	LDI
	LDI
	LDI
	POP  HL
	LD   A,L
	ADD  A,$04
	LD   L,A
	LD   (ScrollTableToBuild),HL
	RET 

EndLineCode:
	JP   NextScanLine


; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

WriteTilesetAddress:
	ADD  A,(TileSetAddresses & $ff )	;$EC
	EXX 
	EX   DE,HL
	LD   L,A
	LD   H,(TileSetAddresses / $100)	;$8A	; 8aec - TileSetAddresses
	LD   C,(HL)
	INC  L
	LD   B,(HL)
	EX   DE,HL
	LD   (HL),C
	INC  L
	LD   (HL),B
	INC  L
	EXX 
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

WriteTileset2Code:
	PUSH BC
	PUSH HL
	LD   HL,Tileset2Code
	LDI
	LDI
	LDI
	LDI
	LDI
	LDI
	LDI
	LDI
	LDI
	LDI
	LDI
	LDI
	LDI
	POP  HL
	POP  BC
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

DrawBullets:
	LD   A,(BulletFireDelay)
	OR   A
	JR   Z,DoBullets
	
	DEC  A
	LD   (BulletFireDelay),A
DoBullets:
	LD   HL,BulletSprites
	LD   B,$03			; 3 lines high, double to 6 lines on screen

DoNxtBullet:
	PUSH BC
	LD   A,(HL)			; bullet 0/1
	INC  L
	PUSH HL
	OR   A
	JP   M,TryNxtBul
	ADD  A,A
	ADD  A,(BulletTypes & $ff)			;$18
	LD   E,A
	LD   D,(BulletTypes / $100)			;$8C	; $8C18 - BulletTypes
	LD   A,(DE)							; Bullet GFX Lo
	INC  E
	ADD  A,A							; 2 bytes per bullet sprite graphic
	ADD  A,(gfx_Bullets & $ff)   		;$20
	LD   C,A
	LD   B,D			; BC = BulletGFX (B=$8c)
	LD   A,(DE)			; bul xspeed
	ADD  A,(HL)			; add to BulX
	LD   (HL),A
	JR   Z,BulOffScreen
	
	LD   E,A			; e=BulX
	INC  L
	LD   A,(HL)
	OR   A
	JP   M,TryNxtBul
	LD   D,A			; d=BulY
	CALL PixAddr
	LD   A,(BC)			; fetch graphic
	LD   E,A
	INC  C
	LD   A,(BC)			; fetch graphic
	LD   D,A
	LD   (HL),E			; write to screen
	INC  H
	LD   (HL),D			; write to screen
	INC  H
	LD   A,H
	AND  $06
	JR   NZ,NxtBulLine
	
	LD   A,L
	ADD  A,$20
	LD   L,A
	JR   C,NxtBulLine
	
	LD   A,H
	SUB  $08
	LD   H,A
NxtBulLine:
	LD   (HL),D			; write to next line (double size in Y)
	INC  H
	LD   (HL),E
TryNxtBul:
	POP  HL
	POP  BC
	INC  L
	INC  L
	DJNZ DoNxtBullet
	RET 
	
BulOffScreen:
	DEC  L
	DEC  A
	LD   (HL),A			; GNO = $FF
	JR   TryNxtBul

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

ResetBullets:
	LD   HL,BulletSprites
	LD   B,$03
	
ResBullLp:
	LD   (HL),$FF
	INC  L
	INC  L
	INC  L
	DJNZ ResBullLp
	XOR  A
	LD   (PlayerWeapon),A
	LD   A,$C8
	LD   (SpriteDataLastYNO),A
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

ResetSprites:
	LD   HL,SpriteData
	LD   B,$07
	
ResSprLp:
	LD   (HL),$FF
	LD   A,$07
	ADD  A,L
	LD   L,A
	DJNZ ResSprLp
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

FindFreeBullet:
	LD   HL,BulletSprites
	LD   B,$03

NextBul:
	LD   A,(HL)
	OR   A
	RET  M
	INC  L
	INC  L
	INC  L
	DJNZ NextBul
	XOR  A
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

BeepPos:
	dw $99C7
BeepNum:
	db $00 
BeepLength:
	db $04 
BeepNote:
	db $10 

PlayBeepJingle:
	LD   (BeepNum),A
	ADD  A,A
	ADD  A,((JingleAddresses-2) & $ff )			;$DE
	LD   L,A
	LD   H,((JingleAddresses-2) / $100)			;$8A	Table at $8ADE (JingleAddresses-2)
	LD   A,(HL)
	INC  L
	LD   H,(HL)
	LD   L,A
	LD   (BeepPos),HL			;  BeepPos address of a <note,length> list for this effect
	LD   A,$01
	LD   (BeepLength),A
	RET 

GetNextBeep:
	LD   HL,(BeepPos)
	LD   A,(HL)
	CP   $FF
	JR   Z,.EndBeep
	INC  HL
	LD   (BeepNote),A
	LD   A,(HL)			; beep length in A
	INC  HL
	LD   (BeepPos),HL
	RET 

.EndBeep:
	XOR  A			; clear jingle and FX beeps
	LD   (BeepNum),A
	LD   (BeepFXNum),A
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

UpdateBeeper:
	XOR  A
	LD   R,A
	EI  
	LD   A,(SoundsMuteFlag)
	OR   A
	JP   NZ,NoBeep
	LD   A,(BeepNum)
	OR   A
	JR   Z,UpdateBeepFX			; No jingle beep playing, so update the FX beep
	
	LD   A,(BeepLength)
	DEC  A
	CALL Z,GetNextBeep
	
	LD   (BeepLength),A
	LD   A,(BeepNote)
	ADD  A,((NoteFreqTbl-$10) & $ff)		;$1D  (-$10 as the first NOTE value is $10)
	LD   L,A
	LD   H,((NoteFreqTbl-$10) / $100)		;$8C	; 8C1D - NoteFreqTbl-$10
	LD   A,(HL)
	OR   A
	JP   Z,NoBeep
	SRL  A
	LD   C,A
	LD   A,(BeepToggle)
	XOR  $FF
	LD   (BeepToggle),A
	JR   Z,DoNote
	SRL  C

DoNote:
	LD   A,$00
	OUT  ($FE),A
	LD   B,C

DB0:
	LD   A,R
	RET  M
	DJNZ DB0
	LD   A,$10
	OUT  ($FE),A
	LD   B,C

DB1:
	LD   A,R
	RET  M
	DJNZ DB1
	JR   DoNote

BeepToggle:
	db $FF 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

WaitForSounds:
	LD   A,(BeepFXNum)
	LD   C,A
	LD   A,(BeepNum)
	OR   C
	RET  Z
	
	CALL UpdateBeeper
	JR   WaitForSounds

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

PlayBeepFX:
	LD   C,A				; Play SFX in A
	LD   A,(BeepFXNum)
	OR   A
	JR   Z,CanBeep			; nothing playing on FX channel
	
	CP   C
	JR   Z,CanBeep			; same fx playing
	
	RET  NC

CanBeep:
	LD   A,C
	LD   (BeepFXNum),A
	ADD  A,A
	ADD  A,((SFXAddresses-2) & $ff)		;$CA
	LD   L,A
	LD   H,((SFXAddresses-2) / $100 )	;$8A			; 8aca - SFXAddresses-2
	LD   A,(HL)
	INC  L
	LD   H,(HL)
	LD   L,A
	LD   (BeepPosFX),HL
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

UpdateBeepFX:
	LD   A,(BeepFXNum)
	OR   A
	JR   Z,NoBeep
	LD   HL,(BeepPosFX)
	LD   C,(HL)
	INC  HL
	LD   A,C
	CP   $FF			; ff = FIN
	JR   Z,EndBeep
	
	LD   (BeepPosFX),HL
	SRL  A
	JR   NC,DoNote
	
White:
	LD   A,C
	LD   (Beat+1),A
	
DoDrum:
	XOR  A
	OUT  ($FE),A
	LD   B,(IY+V_RND1)			; fce0 - RND1
	
DR0:
	LD   A,R
	RET  M
	DJNZ DR0
	
	LD   A,$10
	OUT  ($FE),A
Beat:
	LD   B,$C9				; self mod beat
DR1:
	LD   A,R
	RET  M
	DJNZ DR1
	
	CALL Rand
	JR   DoDrum
	
EndBeep:
	INC  A
	LD   (BeepFXNum),A		; zero out the beep effect
NoBeep:
	LD   A,R
	RET  M
	JR   NoBeep

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

StarBitPosition:
	db $04 

DrawStars:
	LD   A,(RoundNumber)
	OR   A
	RET  NZ
	LD   C,$00
	LD   A,(StarBitPosition)

ModStars1:			; self mod
	NOP 
	LD   (StarBitPosition),A
	JR   NC,DoStarLoop

ModStars2:
	NOP 			;  self mod

DoStarLoop:
	LD   B,$08			; 8 stars
	LD   HL,StarPositions
	CPL
	EX   AF,AF'

NxtStar:
	LD   A,(HL)
	ADD  A,C
	AND  $1F
	LD   E,A
	LD   A,(HL)
	AND  $E0
	ADD  A,E
	LD   (HL),A
	LD   E,A
	INC  L
	LD   D,(HL)
	INC  L
	LD   A,(DE)
	INC  A
	JR   NZ,NoDraw
	INC  D
	LD   A,(DE)
	INC  A
	JR   NZ,NoDraw
	EX   AF,AF'
	LD   (DE),A			; draw star
	EX   AF,AF'

NoDraw:
	DJNZ NxtStar
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

SetupStars:
	LD   B,$08
StarLp:
	PUSH BC
	CALL TwinkleAStar
	POP  BC
	DJNZ StarLp
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

TwinkleStars:
	LD   A,(RoundNumber)
	OR   A
	RET  NZ
	DEC  (IY+V_STARUPDATEDELAY)							; fcc7 - StarUpdateDelay
	RET  NZ
	LD   (IY+V_STARUPDATEDELAY),$03

TwinkleAStar:
	CALL Rand
	LD   A,(RND1)
	LD   E,A
	LD   A,(RND2)
	AND  $7E
	LD   D,A
	CALL PixAddr
	LD   A,(StarIndex)
	INC  A
	AND  $07
	LD   (StarIndex),A
	ADD  A,A
	ADD  A,(StarPositions & $ff )			;$47
	LD   E,A
	LD   D,(StarPositions / $100)			;$8C	; 8c47 StarPositions table
	EX   DE,HL
	LD   (HL),E
	INC  L
	LD   (HL),D
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

SetWeapon:
	EX   AF,AF'
	LD   A,$01			; collect weapon jingle
	CALL PlayBeepJingle
	CALL ResetBullets
	EX   AF,AF'
	LD   (PlayerWeapon),A
	ADD  A,A
	ADD  A,(PickupJumpTable & $ff )		;$A3 ; PickupJumpTable 8ca3
	LD   L,A
	LD   H,(PickupJumpTable / $100)		;$8C
	LD   A,(HL)
	INC  L
	LD   H,(HL)
	LD   L,A
	JP   (HL)			; call the weapon pickup setup code

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

DrawDefaultWeaponImage:
	XOR  A					; disable the duck!
	LD   (DuckOn),A
	CALL DrawWeaponImage	; Draw "use your head" image
	JP   DrawCobraImage

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

PickupKnifeInit:
	XOR  A
	LD   (PlayerWeaponInFlight),A

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

PickupGunsInit:
	LD   A,$FF
	LD   (DuckOn),A
	JP   InitNewWeapon

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

DuckYPos:
	db $98 
DuckXPos:
	db $0F 

DissolveDuck:
	LD   A,(DuckOn)
	OR   A
	RET  Z
	
	LD   A,(DuckXPos)
	DEC  A
	JR   NZ,RemovePixels
	
	LD   A,(DuckYPos)
	CP   $B8				; last Ypos of the last 8 pixels of the duck
	JR   NZ,BumpYPos

	LD   HL,$50F1			; bottom left screen addr of duck
	XOR  A					; see if any pixels are left on the bottom character row of the duck
	LD   C,$08				; 8 rows per column

NextDuckRow:
	LD   B,$05				; 5 columns
	LD   E,L

NextCol:
	OR   (HL)
	INC  L
	DJNZ NextCol
	INC  H
	LD   L,E
	DEC  C
	JR   NZ,NextDuckRow
	OR   A
	JR   NZ,ResetXAndRemovePixels
	LD   (PlayerWeapon),A			; back to Use Your Head (weapon 0)

	LD   A,$04						; weapon gone jingle
	CALL PlayBeepJingle
	JR   DrawDefaultWeaponImage

BumpYPos:
	INC  A
	LD   (DuckYPos),A
	DEC  A
	LD   D,A			; d Ypos
	LD   E,$88			; e Xpos
	CALL PixAddr
	LD   B,$05			; Duck is 5 chars wide
	XOR  A
	
WipeLine:
	LD   (HL),A
	INC  L
	DJNZ WipeLine

ResetXAndRemovePixels:
	LD   A,$0F
RemovePixels:
	LD   (DuckXPos),A
	LD   B,$08			; remove 8 pixels
NextDissolve:
	CALL Rand
	AND  $3F
	CP   $28
	JR   C,InRange
	
	SUB  $28			; rand 0..$28 (5 * 8) pixels
InRange:
	ADD  A,$88			; top left X of duck
	LD   E,A			;  e = Xpos
	LD   A,(RND2)
	AND  $07
	LD   C,A
	LD   A,(DuckYPos)
	ADD  A,C
	LD   D,A			; d = Ypos
	CALL PixAddr
	EXX 
	LD   A,(RND3)
	AND  $07
	ADD  A,(BitTable & $ff )	;$9C
	LD   L,A
	LD   H,(BitTable / $100)	;$88	; 889c - BitTable
	LD   A,(HL)
	EXX 
	CPL
	AND  (HL)			; remove a random bit
	LD   (HL),A
	DJNZ NextDissolve
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

DrawGloves:
	LD   B,$04
	LD   DE,$9818

NextGlove:
	PUSH BC
	PUSH DE
	LD   BC,$0318
	LD   HL,gfx_Glove
	CALL DrawBitmap
	POP  DE
	POP  BC
	LD   A,E
	ADD  A,$18
	LD   E,A
	DJNZ NextGlove
	
	JR   ColourGloves

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

ExtraLife:
	LD   DE,Score
	LD   HL,ExtraLifeScore			;$88ED
	LD   B,$06
	CALL StrCmp
	RET  C
	
	LD   HL,ExtraLifeScore
	LD   DE,$0201
	CALL InAd
	INC  (IY+V_NUMLIVES)
	LD   A,$06
	CALL PlayBeepJingle

ColourGloves:
	LD   A,(NumLives)
	CP   $05
	JR   C,NotMax
	LD   A,$04			; max 4 lives drawn
NotMax:
	LD   B,A
	LD   HL,$1303

ColourNext:
	PUSH BC
	PUSH HL
	LD   A,L
	ADD  A,$02
	LD   C,A
	LD   A,H
	ADD  A,$02
	LD   B,A
	LD   A,$42
	CALL FillAttrBlock
	POP  HL
	POP  BC
	LD   A,L
	ADD  A,$03
	LD   L,A
	DJNZ ColourNext
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

InitNewWeapon:
	CALL DrawWeaponImage
	LD   HL,gfx_QuackometerAttrs
	EXX 
	LD   HL,gfx_Quackometer
	CALL DrawPic
	
	LD   A,$98
	LD   (DuckYPos),A
	LD   A,$3C
	LD   (DuckXPos),A
	LD   A,(SYSBorder)
	PUSH AF
	XOR  A
	LD   (SYSBorder),A			; system variable - used by ROM Beeper routine

	LD   B,$C8
DoQuack:
	PUSH BC
	CALL Rand
	XOR  A
	LD   D,A
	LD   H,A
	LD   A,(RND1)
	LD   L,A
	LD   E,$03
	CALL ROM_BEEPER						; ??? ROM Beeper
	POP  BC
	DJNZ DoQuack
	
	POP  AF
	LD   (SYSBorder),A
	HALT
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

DrawWeaponImage:
	EI  
	LD   A,(PlayerWeapon)
	ADD  A,A
	ADD  A,A
	ADD  A,(WeaponImages & $ff )	;$8B
	LD   L,A
	LD   H,(WeaponImages / $100)	;$8C	; $8c8b - WeaponImages
	LD   A,(HL)
	INC  L
	PUSH HL
	LD   H,(HL)
	LD   L,A
	LD   BC,$0618
	LD   DE,$98C0
	HALT
	CALL DrawBitmap
	INC  H
	INC  H
	INC  H
	LD   BC,$0608
	CALL DrawBitmapToHL
	POP  HL
	INC  L
	LD   A,(HL)
	INC  L
	LD   H,(HL)
	LD   L,A
	LD   BC,$0603
	LD   DE,$1318
	JR   DrawAttributes

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

DrawCobraImage:
	LD   HL,gfx_CobraSnakeAttrs				;$A295
	EXX 
	LD   HL,gfx_CobraSnakeImage

DrawPic:
	LD   BC,$0528
	LD   DE,$9888
	CALL DrawBitmap
	EXX 
	LD   BC,$0505
	LD   DE,$1311
	JR   DrawAttributes

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
; DrawBitmap - 
;
; HL - point to Bitmap Data
; BC - X character width/Y pixel height
; DE - X/Y pixel position
;

DrawBitmap:
	PUSH HL
	CALL PixAddr	; HL = Screen address
	POP  DE			; DE = bitmap data

DrawBitmapToHL:
	LD   A,B
	EX   AF,AF'

.NextByte:
	LD   A,(DE)
	LD   (HL),A
	INC  L
	INC  DE
	DJNZ .NextByte
	
	EX   AF,AF'
	LD   B,A
	EX   AF,AF'
	LD   A,L
	SUB  B
	LD   L,A
	CALL DownLine
	DEC  C
	JR   NZ,.NextByte
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
; DrawAttributes - 
;
; HL - source Attribute data
; DE - X/Y character position
; BC - Width/Height in characters
;

DrawAttributes:
	EX   DE,HL
	CALL AttrAddr
	LD   A,B
	EX   AF,AF'

NextAttrByte:
	LD   A,(DE)
	LD   (HL),A
	INC  L
	INC  DE
	DJNZ NextAttrByte
	
	EX   AF,AF'
	LD   B,A
	EX   AF,AF'
	LD   A,$20
	SUB  B
	ADD  A,L
	LD   L,A
	LD   A,H
	ADC  A,$00
	LD   H,A
	DEC  C
	JR   NZ,NextAttrByte
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

gfx_QuackometerAttrs:
	db $46 
	db $46 
	db $46 
	db $46 
	db $46 
	db $46 
	db $46 
	db $46 
	db $46 
	db $46 
	db $46 
	db $46 
	db $46 
	db $46 
	db $46 
	db $46 
	db $46 
	db $46 
	db $46 
	db $46 
	db $46 
	db $46 
	db $46 
	db $46 
	db $46 
	
gfx_CobraSnakeAttrs:
	db $07 
	db $06 
	db $06 
	db $06 
	db $07 
	db $07 
	db $06 
	db $56 
	db $06 
	db $07 
	db $07 
	db $07 
	db $46 
	db $07 
	db $07 
	db $07 
	db $07 
	db $46 
	db $07 
	db $07 
	db $07 
	db $07 
	db $46 
	db $46 
	db $07 

gfx_UserYourHeadAttrs:
	db $07 
	db $07 
	db $42 
	db $42 
	db $07 
	db $07 
	db $47 
	db $07 
	db $42 
	db $42 
	db $07 
	db $47 
	db $47 
	db $47 
	db $42 
	db $42 
	db $47 
	db $47 

gfx_StartToStabAttrs:
	db $00 
	db $00 
	db $46 
	db $47 
	db $47 
	db $00 
	db $46 
	db $72 
	db $46 
	db $47 
	db $47 
	db $45 
	db $00 
	db $42 
	db $46 
	db $47 
	db $47 
	db $00 

gfx_ImTheCureAttrs:
	db $00 
	db $45 
	db $07 
	db $07 
	db $07 
	db $00 
	db $47 
	db $47 
	db $47 
	db $45 
	db $45 
	db $00 
	db $47 
	db $4E 
	db $47 
	db $00 
	db $00 
	db $00 

gfx_DontPushMeAttrs:
	db $42 
	db $42 
	db $05 
	db $05 
	db $47 
	db $47 
	db $42 
	db $72 
	db $45 
	db $45 
	db $45 
	db $07 
	db $42 
	db $42 
	db $07 
	db $07 
	db $07 
	db $47 

BeepFXNum:
	db $00 

BeepPosFX:
	dw $8D93

SPStr:
	dw $63D1

STACKPOS:
	dw $A2FF

LOOPSTACK:
	dw $A30F

STACK:
	dw $0000
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 

LSTACK:
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 

KeyTab:
	db $BF 
	db $FE 
	db $7F 
	db $FE 
	db $FB 
	db $FE 
	db $FD 
	db $FE 
	db $DF 
	db $FD 
	db $DF 
	db $FE 

MODE_TAB:
	db $00	;NOP 
	db $AE 	;XOR (HL)
	db $B6 	;OR (HL)
	db $2F 	;CPL

DIR_TAB:
	db $00 
	db $FF 
	db $01 
	db $FF 
	db $01 
	db $00 
	db $01 
	db $01 
	db $00 
	db $01 
	db $FF 
	db $01 
	db $FF 
	db $00 
	db $FF 
	db $FF 

CONT_TAB:
	dw Coords
	dw DirectN
	dw PR_MODE
	dw TABULATE
	dw REPEAT
	dw PEN_INK
	dw CHAR_BASE
	dw RESET_PR
	dw JSR_RUTS
	dw JSR_STRG
	dw CLEARSCR
	dw CLEARATR
	dw SET_EXPD
	dw CARRIAGEETURN
	dw BACKSPC
	dw HIT_FOR
	dw HIT_END
	dw TAB_TO_X
	dw X_TO_NUM
	dw Y_TO_NUM
	dw RESX

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

Sprint:
	EX   (SP),HL
	CALL Print
	EX   (SP),HL
	RET 

Print:
	LD   A,(HL)
	INC  HL
	CP   $FF
	RET  Z
	EXX 
	LD   HL,Print
	PUSH HL
	CP   $20
	JR   NC,PRChars
	ADD  A,A
	LD   HL,CONT_TAB			; control code function table
	CALL AddHLA
	JP   JPIndex

PRChars:
	EXX 
PRChar:
	PUSH HL
	EX   AF,AF'
	LD   DE,(Variables)			; v+SCRNX
	CALL LowAd
	EX   AF,AF'
	CALL ChrAddr
	BIT  1,(IY+V_SYSFLAG)			; IY + SYSFLAG
	JR   NZ,Expand
	
	LD   B,$08
PR_LOOP:
	LD   A,(DE)
MODE0:
	NOP 
	LD   (HL),A
	INC  H
	INC  DE
	DJNZ PR_LOOP
	DEC  H
	CALL Colour
PR_OUT:
	POP  HL
	LD   A,(Variables_Direct)			; v + Direct
	JP   MOVE_CUR

Expand:
	LD   C,$08
Expand2:
	LD   B,(IY+V_HIGH)			; IY + High
Expand0:
	CALL Colour
	LD   A,(DE)
MODE1:
	NOP 
	LD   (HL),A
	CALL DownLine
	DJNZ Expand0
	INC  DE
	DEC  C
	JR   NZ,Expand2
	JR   PR_OUT

Colour:
	LD   A,(Variables_Attr)
	INC  A
	RET  Z
	PUSH HL
	DEC  A
	EX   AF,AF'
	CALL PixToAtr
	EX   AF,AF'
	LD   (HL),A
	POP  HL
	RET 

Coords:
	EXX 
	CALL DEFromHL
	LD   (Variables),DE
	RET 

DirectN:
	EXX 
	LD   A,(HL)
	INC  HL
	LD   (Variables_Direct),A
	RET 

PR_MODE:
	EXX 
	LD   A,(HL)
	INC  HL
	EXX 
	LD   HL,MODE_TAB
	CALL AddHLA
	LD   A,(HL)
	LD   (MODE0),A			; self mod
	LD   (MODE1),A			; self mod
	EXX 
	RET 

SET_EXPD:
	EXX 
	LD   A,(HL)
	INC  HL
	LD   (Variables_High),A
	SET  1,(IY+V_SYSFLAG)			; IY + SYSFLAG
	RET 

RESET_PR:
	EXX 
	PUSH HL
	LD   HL,STACK
	LD   (STACKPOS),HL
	LD   HL,LSTACK
	LD   (LOOPSTACK),HL
	CALL Sprint
	db MOD, NORM 
	db DIR, RI 
	db PEN, NINK 
	db TAB,0
	db AT,0,0 
	db CHR
	dw Charset
	db FIN 
	POP  HL
RESX:
	RES  1,(IY+V_SYSFLAG)			; IY + SYSFLAG
	RET 

TABULATE:
	EXX 
	LD   A,(HL)
	LD   (Variables_TabXPos),A
	INC  HL
	RET 

REPEAT:
	EXX 
	LD   A,(HL)
	INC  HL
	LD   B,(HL)
	INC  HL

REPEATL:
	PUSH AF
	PUSH BC
	PUSH HL
	CALL PRChar
	POP  HL
	POP  BC
	POP  AF
	DJNZ REPEATL
	RET 

PEN_INK:
	EXX 
	LD   A,(HL)
	INC  HL
	LD   (Variables_Attr),A
	RET 

CHAR_BASE:
	EXX 
	CALL DEFromHL
	LD   (Variables_Chars),DE			; V + CHARS
	RET 

JSR_RUTS:
	EXX 
	PUSH IX
	LD   A,(HL)
	INC  HL
	PUSH HL
	LD   H,(HL)
	LD   L,A
	POP  IX
	INC  IX
	CALL JumpHL
	PUSH IX
	POP  HL
	POP  IX
	RET 

JSR_STRG:
	EXX 
	LD   A,(HL)
	INC  HL
	PUSH HL
	LD   H,(HL)
	LD   L,A
	CALL Print
	POP  HL
	INC  HL
	RET 

CLEARSCR:
	LD   BC,$17FF
	LD   HL,$4000

CLEARMEM:
	LD   E,$01
	LD   D,H
	LD   (HL),L
	LDIR
	EXX 
	RET 

CLEARATR:
	LD   HL,$5800
	LD   BC,$02FF
	JR   CLEARMEM

CARRIAGEETURN:
	EXX 
	LD   A,(Variables_TabXPos)
	LD   (Variables),A
	INC  (IY+V_SCRNY)			; IY+SCRNY
	RET 

BACKSPC:
	EXX 
	LD   A,(HL)
	INC  HL

MOVE_CUR:
	EXX 
	ADD  A,A
	LD   HL,DIR_TAB
	CALL AddHLA
	LD   DE,(Variables)
	LD   A,E
	ADD  A,(HL)
	AND  $1F
	LD   E,A
	INC  HL
	LD   A,D
	ADD  A,(HL)
	LD   D,A
	LD   (Variables),DE			; SCRNX/SCRNY
	EXX 
	RET 

HIT_FOR:
	EXX 
	LD   A,(HL)			; counter
	INC  HL
	EXX 
	LD   HL,(LOOPSTACK)
	LD   (HL),A
	INC  HL
	LD   (LOOPSTACK),HL
	EXX 
	LD   E,L
	LD   D,H
	JR   PUTSTACK

HIT_END:
	LD   HL,(LOOPSTACK)
	DEC  HL
	DEC  (HL)
	JR   Z,HASENDLOP
	EXX 
	CALL GETSTACK
	LD   E,L
	LD   D,H
	JR   PUTSTACK

HASENDLOP:
	LD   (LOOPSTACK),HL
	CALL GETSTACK
	EXX 
	RET 

GETSTACK:
	LD   HL,(STACKPOS)
	DEC  HL
	LD   D,(HL)
	DEC  HL
	LD   E,(HL)
	LD   (STACKPOS),HL
label_A4E0_1:
	EX   DE,HL
	RET 

PUTSTACK:
	PUSH HL
	LD   HL,(STACKPOS)
	LD   (HL),E
	INC  HL
	LD   (HL),D
	INC  HL
	LD   (STACKPOS),HL
	POP  HL
	RET 

TAB_TO_X:
	EXX 
	LD   A,(Variables)
	LD   (Variables_TabXPos),A
	RET 

X_TO_NUM:
	EXX 
	LD   A,(HL)
	INC  HL
	LD   (Variables),A			; V + SCRNX
	RET 

Y_TO_NUM:
	EXX 
	LD   A,(HL)
	INC  HL
	LD   (Variables_ScrnY),A			; variables + scrny
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

Rand:
	LD   HL,RND1
	LD   C,(HL)
	INC  HL
	LD   A,(HL)
	SRL  C
	SRL  C
	SRL  C
	XOR  C
	INC  HL
	RRA
	RL   (HL)
	DEC  HL
	RL   (HL)
	DEC  HL
	RL   (HL)
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

ChrAddr:
	LD   DE,(Variables_Chars)			;  v+CHARS
	PUSH HL
	LD   L,A
	LD   H,$00
	ADD  HL,HL
	ADD  HL,HL
	ADD  HL,HL
	ADD  HL,DE
	EX   DE,HL
	POP  HL
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
; PixAddr - DE =X,Y pixel positions (256x192).  Returns HL as screen address
;

PixAddr:			
	LD   A,D
	AND  $C0
	SRL  A
	SRL  A
	SRL  A
	OR   $40
	LD   H,A
	LD   A,D
	AND  $38
	ADD  A,A
	ADD  A,A
	LD   L,A
	LD   A,D
	AND  $07
	OR   H
	LD   H,A
	LD   A,E
	AND  $F8
	SRL  A
	SRL  A
	SRL  A
	OR   L
	LD   L,A
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

LowAd:			; DE  = X,Y char positions.  Returns HL as screen address
	LD   A,D
	RRCA
	RRCA
	RRCA
	AND  $E0
	OR   E
	LD   L,A
	LD   A,D
	AND  $18
	OR   $40
	LD   H,A
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
; AttrAddr - HL x,y in char positions, returns HL with attribute address of given position
;

AttrAddr:			
	EX   AF,AF'
	LD   A,H
	RRCA
	RRCA
	RRCA
	LD   H,A
	AND  $E0
	OR   L
	LD   L,A
	LD   A,H
	AND  $1F
	OR   $58
	LD   H,A
	EX   AF,AF'
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

PixToAtr:			; screen address in HL returns the attribute address for that screen addr back in HL
	LD   A,H
	RRCA
	RRCA
	RRCA
	AND  $03
	OR   $58
	LD   H,A
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

DownLine:			; HL screen addr, returns HL as new screen addr
	INC  H
	LD   A,H
	AND  $07
	RET  NZ
	LD   A,L
	ADD  A,$20
	LD   L,A
	RET  C
	LD   A,H
	SUB  $08
	LD   H,A
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

HitA:
	LD   A,H			; H=XLEN
	ADD  A,L			; L=X
	CP   E			; E=X1
	RET  C
	LD   A,D			; D=X1LEN
	ADD  A,E
	CP   L
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

FillAttrBlocks:
	CALL HLBCFromIX
	INC  IX
	LD   A,L
	CP   $FF
	RET  Z
	LD   A,(IX+$03)
	PUSH IX
	CALL FillAttrBlock
	POP  IX
	LD   DE,$0004
	ADD  IX,DE
	JR   FillAttrBlocks

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

FillAttrBlock:			; hl = x,y, bc = width, height, a = colour
	LD   E,L
	LD   D,H
	CALL AttrAddr
	EX   AF,AF'
	LD   A,C
	SUB  E
	LD   C,A
	LD   A,B
	SUB  D
	LD   D,A
	EX   AF,AF'
	INC  C
	INC  D
BlkD:
	PUSH HL
	LD   B,C
Blk1:
	LD   (HL),A
	INC  HL
	DJNZ Blk1
	LD   B,D
	LD   DE,$0020
	POP  HL
	ADD  HL,DE
	LD   D,B
	DEC  D
	JR   NZ,BlkD
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

Keys:
	LD   A,(ControlMethod)
	DEC  A
	JR   Z,KeyR
	DEC  A
	JR   Z,Kemp
	LD   BC,$0500
	CALL JoyR
JoyA:
	LD   A,$7F
	IN   A,($FE)
	OR   $E0
	INC  A
	LD   A,C
	JR   Z,Jout
	ADD  A,$20
	JR   Jout
Kemp:
	XOR  A
	IN   A,($1F)
	AND  $1F
	LD   C,A
	JR   JoyA
KeyR:
	LD   BC,$0600
JoyR:
	LD   HL,KeyTab
KeyIn:
	LD   A,(HL)
	INC  HL
	IN   A,($FE)
	OR   (HL)
	INC  HL
	ADD  A,$01
	CCF
	RL   C
	DJNZ KeyIn
	LD   A,C
Jout:
	LD   (FUDLR),A
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

ScoreAdd:
	LD   HL,Score
InAd:
	LD   A,D
	LD   D,$00
	ADD  HL,DE
	ADD  A,(HL)
ScA0:
	LD   B,A
	SUB  $3A
	JR   NC,ScA1
	LD   (HL),B
	RET 
ScA1:
	ADD  A,$30
	LD   (HL),A
	DEC  HL
	LD   A,(HL)
	OR   A
	RET  Z
	INC  A
	JR   ScA0

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

PrScore:
	LD   HL,$0008
	LD   (Variables),HL
	LD   HL,Score

PrNums:
	LD   BC,$0600

PrSc0:
	LD   A,C
	OR   A
	LD   A,(HL)
	JR   NZ,NonZero
	LD   A,(HL)
	CP   $30
	JR   NZ,NonZero
	DEC  C
	LD   A,$20
NonZero:
	INC  C
	PUSH BC
	CALL PRChar
	POP  BC
	INC  HL
	DJNZ PrSc0
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

StrCmp:
	LD   A,(DE)
	CP   (HL)
	RET  NZ
	INC  HL
	INC  DE
	DJNZ StrCmp
	AND  A
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

InitIM2:
	DI  
	IM   2
	LD   A,$FD
	LD   I,A
	LD   HL,IM2Handler
	LD   DE,$FFF4
	LD   BC,$000C
	LDIR
	LD   HL,$FD00
	LD   DE,$FD01
	LD   BC,$0100
	LD   (HL),$FF
	LDIR
	EI  
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

IM2Handler:
	JP   InterruptHandler
	db $80 
	db $40 
	db $20 
	db $10 
	db $08 
	db $04 
	db $02 
	db $01 
	db $18 

InterruptHandler:
	EI  
	PUSH AF
	LD   A,$FF
	LD   R,A
	POP  AF
	RETI

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

HaltB:
	HALT
	DJNZ HaltB
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

AddHLA:
	ADD  A,L
	LD   L,A
	RET  NC
	INC  H
DUF:
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

HLFromHL:
	LD   A,(HL)
	INC  HL
	LD   H,(HL)
	LD   L,A
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

DEFromHL:
	LD   E,(HL)
	INC  HL
	LD   D,(HL)
	INC  HL
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

JPIndex:
	LD   A,(HL)
	INC  HL
	LD   H,(HL)
	LD   L,A

JumpHL:
	JP   (HL)

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

HLBCFromIX:
	LD   L,(IX+$00)
	LD   H,(IX+$01)
	LD   C,(IX+$02)
	LD   B,(IX+$03)
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

HLDEFromIX:
	LD   L,(IX+$00)
	LD   H,(IX+$01)
	LD   E,(IX+$02)
	LD   D,(IX+$03)
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

SkoreText:
	db $53 
	db $4B 
	db $4F 
	db $52 
	db $45 

DrawScore:
	LD   HL,$54C3
	LD   IX,SkoreText
	LD   B,$05
PrLoop:
	PUSH BC
	PUSH HL
	EXX 
	LD   L,(IX+$00)
	CALL PrChr
	POP  HL
	POP  BC
	INC  L
	INC  IX
	DJNZ PrLoop
	LD   B,$05
DigitLoop:
	PUSH BC
	CALL DrawScoreDigits
	POP  BC
	DJNZ DigitLoop
	
DrawScoreDigits:
	LD   HL,$54C9			; Screen address of score
	LD   B,$E7
	LD   A,(ScoreDigitToDraw)
	INC  A
	CP   $06			; six digits to draw
	JR   NZ,NoReset
	XOR  A
NoReset:
	LD   (ScoreDigitToDraw),A
	LD   C,A
	ADD  A,L
	LD   L,A
	LD   A,C
	ADD  A,B
	EXX 
	LD   L,A
	LD   H,$88			; 88e7 Score text digits
	LD   L,(HL)

PrChr:
	LD   H,$00
	ADD  HL,HL
	ADD  HL,HL
	ADD  HL,HL
	LD   DE,Charset
	ADD  HL,DE
	LD   (SPStr),SP
	LD   SP,HL
	EXX 
	LD   B,$02
PRN0:
	POP  DE
	LD   (HL),E
	INC  H
	LD   (HL),D
	INC  H
	POP  DE
	LD   (HL),E
	INC  H
	LD   (HL),D
	INC  H
	LD   A,L
	ADD  A,$20
	LD   L,A
	JR   C,PRN1
	LD   A,H
	SUB  $08
	LD   H,A
PRN1:
	DJNZ PRN0
	LD   SP,(SPStr)
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

ScrollAttributes:
	LD   A,(ColourMonoFlag)
	OR   A
	RET  NZ
	LD   A,(ScrollDirection)
	DEC  A
	JR   Z,NoRightFeed
	DEC  A
	RET  NZ
	LD   A,(SmoothX)
	CP   $04
	JR   NZ,NoLeftFeed
	CALL FeedLeftEdge
	JP   ScrollAttrRightToLeft
NoLeftFeed:
	OR   A
	RET  NZ
	CALL FeedRightEdge
	JP   ScrollAttrRightToLeft
NoRightFeed:
	LD   A,(SmoothX)
	CP   $03
	JR   Z,ScrollAttrLeftToRight
	CP   $07
	RET  NZ
	CALL FeedLeftEdge
	JR   ScrollAttrLeftToRight
FeedRightEdge:			; feed right edge
	LD   A,(MapXPosAttr)
	SUB  $1B
	LD   DE,$A831
	JR   FillEdgeAttributes
FeedLeftEdge:			; feed left edge
	LD   A,(MapXPosAttr)
	INC  A
	LD   DE,$A841
FillEdgeAttributes:
	LD   L,A
	LD   H,$80
	LD   B,$8C
	LD   A,$08
NextAttr:
	EX   AF,AF'
	LD   A,(HL)
	AND  $07
	LD   C,A
	LD   A,(BC)
	LD   (DE),A
	INC  DE
	LD   A,(HL)
	AND  $38
	SRL  A
	SRL  A
	SRL  A
	LD   C,A
	LD   A,(BC)
	LD   (DE),A
	INC  DE
	INC  H
	EX   AF,AF'
	DEC  A
	JR   NZ,NextAttr
	RET 
ScrollAttrLeftToRight:
	LD   HL,$A841
	EXX 
	LD   HL,$8A20
	LD   BC,$01A0
	LD   (SPStr),SP
	LD   SP,HL
LRLoop:
	POP  DE
	LD   L,E
	LD   H,D
	INC  HL
	LDI
	LDI
	LDI
	LDI
	LDI
	LDI
	LDI
	LDI
	LDI
	LDI
	LDI
	LDI
	LDI
	LDI
	LDI
	LDI
	LDI
	LDI
	LDI
	LDI
	LDI
	LDI
	LDI
	LDI
	LDI
	LDI
	EXX 
	LD   A,(HL)
	INC  HL
	EXX 
	LD   (DE),A
	JP   PE,LRLoop
	LD   SP,(SPStr)
	RET 

ScrollAttrRightToLeft:
	LD   HL,$A831
	EXX 
	LD   HL,$8A40
	LD   BC,$01A0
	LD   (SPStr),SP
	LD   SP,HL
RLLoop:
	POP  DE
	LD   L,E
	LD   H,D
	DEC  HL
	LDD
	LDD
	LDD
	LDD
	LDD
	LDD
	LDD
	LDD
	LDD
	LDD
	LDD
	LDD
	LDD
	LDD
	LDD
	LDD
	LDD
	LDD
	LDD
	LDD
	LDD
	LDD
	LDD
	LDD
	LDD
	LDD
	EXX 
	LD   A,(HL)
	INC  HL
	EXX 
	LD   (DE),A
	JP   PE,RLLoop
	LD   SP,(SPStr)
	RET
	
	db $68 
	db $68 
	db $68 
	db $68 
	db $68 
	db $68 
	db $78 
	db $78 
	db $78 
	db $78 
	db $70 
	db $30 
	db $78 
	db $78 
	db $78 
	db $78 
	db $78 
	db $78 
	db $78 
	db $78 
	db $78 
	db $78 
	db $78 
	db $78 
	db $78 
	db $78 
	db $78 
	db $78 
	db $78 
	db $78 
	db $78 
	db $38

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;
	
FillMono:
	LD   A,(RND2)
	AND  $58
	ADD  A,$20
	LD   HL,$0003
	LD   BC,$0F1D
	JP   FillAttrBlock

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;
	
DumpMapColours:
	LD   A,(ColourMonoFlag)
	OR   A
	JR   NZ,FillMono
	LD   A,(MapXpos)
	INC  A
	LD   E,A
	LD   D,$80			; de - $8000 + MapXPos
	LD   B,$8C			; bc - $8c00 - Map Block Colours
	LD   HL,$581E			; top right attribute of map
	EXX 
	LD   B,$08			; 8 3x3 map rows
NextAttrMapRow:
	EXX 
	PUSH DE
	PUSH HL
	LD   A,$0E
NextBlk:
	EX   AF,AF'
	LD   A,(DE)
	AND  $07
	LD   C,A
	LD   A,(BC)
	LD   (HL),A
	DEC  L
	LD   (HL),A
	LD   A,$20
	ADD  A,L
	LD   L,A
	LD   A,H
	ADC  A,$00
	LD   H,A
	LD   A,(DE)
	AND  $38
	SRL  A
	SRL  A
	SRL  A
	LD   C,A
	LD   A,(BC)
	LD   (HL),A
	INC  L
	LD   (HL),A
	LD   A,L
	SUB  $20
	LD   L,A
	LD   A,H
	SBC  A,$00
	LD   H,A
	DEC  L
	DEC  L
	DEC  E
	DEC  E
	EX   AF,AF'
	DEC  A
	JR   NZ,NextBlk
	POP  HL
	LD   DE,$0020
	LD   (HL),$00
	ADD  HL,DE
	LD   (HL),$00
	ADD  HL,DE
	POP  DE
	INC  D
	EXX 
	DJNZ NextAttrMapRow
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

FindFreeSpriteAll:
	LD   HL,SpriteData
	LD   B,$07

FindSprite:
	LD   A,(HL)
	OR   A
	RET  M
	LD   A,L
	ADD  A,$07
	LD   L,A
	DJNZ FindSprite
	XOR  A
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

FindFreeSpriteGeneral:
operand_A8CB:
	LD   B,$03
operand_A8CD:
	LD   HL,SpriteDataGeneral
	JR   FindSprite

FindFreeSpriteReserve:
	LD   B,$03
	LD   HL,$88CC
	JR   FindSprite

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

IntroduceGirlfriend:
	LD   HL,(GirlfriendCountdown)
	LD   A,L
	OR   H
	JR   Z,TriggerGirlfriend
	DEC  HL
	LD   (GirlfriendCountdown),HL
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

TriggerGirlfriend:
	LD   A,(GirlfriendOnScreen)
	OR   A
	RET  NZ
	CALL FindFreeSpriteGeneral
	RET  P
	LD   (GirlfriendSpriteAddress),HL
	LD   (HL),T_DoDrop					; TYP 
	INC  L
	LD   A,(GirlfriendEnterX)
	LD   (HL),A							; XNO
	INC  L
	EX   AF,AF'
	LD   A,(PlayerY)
	AND  $F0
	LD   (HL),A							; YNO
	EX   AF,AF'
	INC  L
	LD   (HL),G_Girlfriend				; GNO
	OR   A
	JP   P,.NoFlip
	INC  (HL)

.NoFlip:
	INC  L
	INC  L
	LD   (HL),T_GirlfriendOn			; CNT1 - what TYP to switch to when DoDrop completes
	
	XOR  A								; Girlfriend hasn't touched player yet
	LD   (GirlfriendIsLeaving),A
	LD   (GirlfriendFoundPlayer),A
	LD   A,$08							; wolf whistle
	LD   (GirlfriendOnScreen),A
	JP   PlayBeepFX

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

SwapInGameMap:							; Swaps in the round map into $8000
	LD   A,(RoundNumber)
	ADD  A,A
	ADD  A,(GameMapAddresses & $ff)		;$5C
	LD   L,A
	LD   H,(GameMapAddresses / $100)	;$8D 8d5c GameMapAddresses
	LD   E,(HL)
	INC  L
	LD   D,(HL)
	LD   HL,data_8000					;$8000
	LD   BC,$0800
	JR   SwapMemory

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

Pause:
	BIT  5,(IY+V_FUDLR)			; IY+FUDLR
	RET  Z
	
	LD   A,$01					; Music played during Pause

PlayTune:
	PUSH AF
	CALL SwapPlipPlopPlayerInOut
	POP  AF
	CALL PlipPlopPlayer				; call the player

SwapPlipPlopPlayerInOut:
	LD   HL,data_8000				; $8000 Move player to $8000 when in use (map buffer)
	LD   DE,$5b00					; PlipPlopPlayerStart		; from $5b00
	LD   BC,$07D0
	
SwapMemory:
	LD   A,(HL)
	EX   AF,AF'
	LD   A,(DE)
	LD   (HL),A
	EX   AF,AF'
	LD   (DE),A
	INC  HL
	INC  DE
	DEC  BC
	LD   A,B
	OR   C
	JR   NZ,SwapMemory
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

ResetGame:
	LD   HL,Variables			; clear game variables
	LD   DE,Variables+1
	LD   BC,$0027
	LD   (HL),$00
	LDIR
	LD   A,$03
	LD   HL,SpriteDataGeneral
	LD   (operand_A8CB+1),A
	LD   (operand_A8CD+1),HL
	LD   A,$60
	LD   (PlayerY),A
	LD   A,$98
	LD   (DuckYPos),A
	LD   A,$0F
	LD   (DuckXPos),A
	LD   A,$04
	LD   (GroundScrollX),A
	LD   (SmoothX),A
	LD   A,(ProjectileFireDelay)
	LD   (ProjectileFireDelayCounter),A
	LD   HL,(GirlfriendCountdown)
	LD   DE,$00FA
	ADD  HL,DE
	LD   (GirlfriendCountdown),HL
	LD   HL,(NumBaddiesToKill)
	LD   DE,$0008			; 8 more baddies to kill
	ADD  HL,DE
	LD   (NumBaddiesToKill),HL
	XOR  A
	LD   (ModParallaxBlock),A		; self mod in DrawMap (NOP)
	LD   (ModStars1),A				; self mod in DrawStars
	LD   (BuildScrollCounter),A
	LD   (GroundScrollX),A
	LD   (ScrollDirection),A
	LD   (PlayerInputDelay),A
	LD   (BeepFXNum),A
	LD   (BeepNum),A
	LD   (PlayerDir),A
	INC  A
	LD   (BulletFireDelay),A
	LD   (StarUpdateDelay),A

ModBlankBlock:
	LD   A,$FF
	LD   (BlankBlockPattern),A
	LD   A,(MapXpos)
	AND  $FE
	LD   (MapXpos),A
	LD   (MapXPosAttr),A
	LD   (MasterMapXpos),A
	LD   HL,DrawMapTableEven
	LD   (WorkingScrollTable),HL
	LD   HL,DrawMapTableOdd
	LD   (OtherScrollTable),HL
	LD   (ScrollTableToBuild),HL
	DI  
	CALL GenerateMapTables
	LD   A,(MapBuffer / $100)-1			;$7F
	LD   (MapLineHi),A
	CALL DrawMap
	CALL DrawGround
	CALL FeedRightEdge
	CALL FeedLeftEdge
	CALL SetupStars
	CALL ResetSprites
	CALL ResetBullets
	CALL SetupBurgers
	CALL DrawSprites
	CALL DrawScore
	CALL DrawDefaultWeaponImage
	CALL DrawGloves
	CALL Sprint
	db RSET 			; RSET
	db JSR 				; JSR
	dw FillAttrBlocks
	db 3,22 			; x,y
	db 14,22 			; w,h
	db BRIGHT+CYAN		; $45 ; attr
	db 3,23 
	db 14,23 
	db BRIGHT+WHITE 
	db 24, 22 
	db 29, 22 
	db WHITE 
	db 24,23 
	db 29,23
	db BRIGHT+WHITE 
	db 3,16 
	db 29,16
GroundColour1:
	db PAPER*YELLOW 	; Ground Attr Modified
	db 3, 17 
	db 29, 17 
GroundColour2:
	db BRIGHT+BLUE 		; Ground Attr Modified
	db FIN 				; FIN (blocks)
	db FIN 				; FIN (sprint)
	JP   DumpMapColours

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

ResetVars:
	CALL InitIM2
	LD   IY,Variables
	LD   HL,Score
	LD   DE,Score+1
	LD   BC,$000B
	LD   (HL),$30				; "0"
	LDIR
	LD   A,$31					; "1"	;extra life score at 10,000
	LD   (ExtraLifeScore+1),A
	LD   HL,$3130				; "01"
	LD   (RoundNumText),HL
	
	LD   HL,$0271
	LD   (InitialGirlfriendCountdown),HL
	LD   (IY+V_RANDOMNUMMASK),$1F			; $FCE9 - RandomNumMask
	LD   HL,$0014
	LD   (InitialNumBaddiesToKill),HL
	LD   (IY+V_PROJECTILEFIREDELAY),$19			; $fcde - ProjectileFireDelay
	LD   (IY+V_PROJECTILESPEED),$04			; $fcdb - ProjectileSpeed
	
	XOR  A
	LD   (RoundNumber),A
	LD   (BurgerWeaponAdjust),A
	DEC  A
	LD   (RND1),A
	
	LD   (IY+V_NUMLIVES),$03		; NumLives
	LD   (IY+V_GIRLFRIENDENTERX),$06
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

SetupBurgers:
	LD   IX,SpriteData
	LD   A,(RoundNumber)
	ADD  A,A
	ADD  A,(BurgerTables & $ff )		;$32
	LD   L,A
	LD   H,(BurgerTables / $100)		;$8D			; 8d32 BurgerTables
	LD   A,(HL)
	INC  L
	LD   H,(HL)
	LD   L,A
	LD   B,$04
	LD   D,$1E
BrgrLoop:
	LD   A,(HL)
	INC  L
	ADD  A,A
	JR   C,NextBrgr
	LD   C,A
	LD   A,(MapXPosAttr)
	CP   C
	JR   C,NextBrgr
	SUB  D
	CP   C
	JR   NC,NextBrgr
	LD   E,A
	LD   A,C
	SUB  E
	ADD  A,A
	ADD  A,A
	ADD  A,A
	ADD  A,$02
	LD   E,A
	CALL OnScreen
NextBrgr:
	INC  L
	INC  L
	DJNZ BrgrLoop
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

TriggerNightSlasher:
	LD   (NightSlasherFlag),A
	CALL FindFreeSpriteGeneral
	PUSH HL
	POP  IX
	LD   A,(RND1)
	AND  $01
	LD   A,$E8						; right edge
	JR   Z,IntroduceSlasherRight
	LD   A,$10						; left edge

IntroduceSlasherRight:
	LD   (IX+XNO),A
	OR   A
	LD   A,G_NightSlasher			; GNO Night Slasher facing left
	JP   P,GNORight
	INC  A							; make facing right

GNORight:
	LD   (IX+GNO),A					; GNO
	LD   (IX+TYP),T_NightSlasher	; TYP = Night Slasher
	LD   (IX+YNO),$68				; IX+YNO
	LD   (IX+XSPD),$03				; xspd
	LD   (IX+CNT2),$01				; countdown to fire
	XOR  A
	JP   SetWeapon

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

IntroduceBaddies:
	LD   A,(NightSlasherFlag)
	OR   A
	RET  NZ
	LD   A,(AllBaddiesKilled)
	OR   A
	JR   Z,NoMoreTriggers
	LD   HL,SpriteData
	LD   B,$07

FindNext:
	LD   A,(HL)						; TYP
	AND  $3F
	CP   T_GirlfriendFollow			; ignore girlfriend TYP 0e/0f
	JR   Z,SkipGirlfriend
	
	CP   T_GirlfriendOn
	JR   Z,SkipGirlfriend
	
	LD   A,(HL)
	OR   A
	RET  P

SkipGirlfriend:
	LD   A,L
	ADD  A,$07
	LD   L,A
	DJNZ FindNext
	
	LD   A,(BurgerCount)
	OR   A
	JR   Z,UsedAllBurgers

	LD   A,(BeepFXNum)
	CP   $09
	RET  Z
	
	LD   A,$09
	JP   PlayBeepFX

UsedAllBurgers:
	LD   A,(GirlfriendStatus)
	OR   A
	RET  Z
	
	LD   A,(RoundNumber)
	CP   $02
	JR   Z,TriggerNightSlasher
	
	LD   (IY+V_LEVELENDCOUNTDOWN),$32			; fcd6 LevelEndCountdown
	RET 

NoMoreTriggers:
	LD   A,(PlayerWeapon)
	CP   WEAPON_MACHINEGUN						; MachineGun
	JR   Z,IsMachineGun
	
	DEC  (IY+V_PROJECTILEFIREDELAYCOUNTER)		; fcd0 - ProjectileFireDelay
	RET  NZ
	
	INC  (IY+V_PROJECTILEFIREDELAYCOUNTER)		; fcd0 - ProjectileFireDelay
IsMachineGun:									; machine gun has no fire delay
	CALL FindFreeSpriteGeneral
	JP   M,FoundSpareSprite
	CALL FindFreeSpriteReserve
	RET  P

	CALL TriggerBaddy
	LD   A,(RND3)
	AND  $03
	ADD  A,$04

TriggerOnAnyRow:
	LD   E,A
	LD   D,(BaddyTriggerRowHeights / $100)		; 8d04 BaddyTriggerRowHeights
	LD   A,(DE)
	SUB  (HL)
	LD   (IX+YNO),A			; IX+YNO
	LD   A,(FrameCounter)
	AND  $01
	LD   A,$F0			; introduce on the right
	JR   Z,IntroRight
	
	LD   A,$02			; introduce on the left
	INC  (IX+GNO)		; make IX+GNO face right

IntroRight:
	LD   (IX+XNO),A				; IX+XNO
	LD   A,(IX+TYP)
	LD   (IX+CNT1),A			; Store my TYP for when I land
	LD   (IX+TYP),T_DoDrop		; IX+TYP = DoDrop
	LD   (IX+XSPD),$00

SpriteDone:
	LD   A,(ProjectileFireDelay)			; reset fire delay counter
	LD   (ProjectileFireDelayCounter),A
	RET 

FoundSpareSprite:
	CALL TriggerBaddy
	LD   A,C
	AND  $1F				; 0001 1111
	JR   Z,ContinueTrigger
	
	LD   A,(RND1)
	AND  $03
	JR   NZ,ContinueTrigger
	
	LD   A,(RND1)			; swap triggered baddy for a missile
	LD   C,A
	AND  $07
	ADD  A,A
	LD   (IX+CNT1),A		; cnt1
	LD   (IX+CNT2),A		; cnt2
	LD   A,C
	AND  $08
	LD   A,$1C				; GNO Missile
	LD   C,$EE				; c = xpos on right
	JR   Z,SetMissileGNO
	
	INC  A					; flip missile sprite
	LD   C,$08				; c = xpos on left

SetMissileGNO:
	LD   (IX+GNO),A
	LD   A,(FrameCounter)
	AND  $01
	ADD  A,T_MissileUp			; TYP = 08/09 Missile Up / Missile Down
	LD   (IX+TYP),A
	LD   A,(RND2)
	AND  $3E
	ADD  A,$20				; a = ypos
	JR   SetSprite

ContinueTrigger:			; attempt to trigger on the same row as player
	LD   A,(FrameCounter)
	AND  $01
	JR   Z,SwapTriggerSides
	
	LD   A,E				; e bitmask of valid right side rows to trigger on
	AND  C					; c bitmask of row the player is on
	JR   NZ,TriggerOnRight
	
	LD   A,D				; d bitmask of valid left side rows to trigger on
	AND  C					; c bitmask of row the player is on
	JR   NZ,TriggerOnLeft

PickRandomRow:
	LD   A,(RND3)
	AND  $07
	ADD  A,$00
	JP   TriggerOnAnyRow	; trigger on a random row

SwapTriggerSides:
	LD   A,D
	AND  C
	JR   NZ,TriggerOnLeft
	
	LD   A,E
	AND  C
	JR   Z,PickRandomRow

TriggerOnRight:
	LD   A,(PlayerY)
	ADD  A,$20
	AND  $F0
	SUB  (HL)			; Random BaddyType height
	LD   C,$F0			; XPOS on right
	JR   SetSprite

TriggerOnLeft:
	LD   A,(PlayerY)
	ADD  A,$20
	AND  $F0
	SUB  (HL)			; Random BaddyType height
	LD   C,$02			; XPOS on left
	INC  (IX+GNO)

SetSprite:
	LD   (IX+YNO),A		; YNO
	LD   (IX+XNO),C		; XNO

LandedSetSpeed:
	LD   A,(RND2)
	AND  $03
	ADD  A,(RandomSpeeds & $ff)	;$87			; 8c87 - RandomSpeeds
	LD   L,A
	LD   A,(HL)
	LD   (IX+XSPD),A
	JP   SpriteDone

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

TriggerBaddy:			; c = what row (as a bit mask) the player is on and D E = left and right side 8 bit bitmasks for column contents
	PUSH HL
	POP  IX
	CALL CalcEdgeBlocks
	LD   A,(PlayerY)
	ADD  A,$20
	AND  $70			; 0111 0000
	SRL  A
	SRL  A
	SRL  A
	SRL  A
	ADD  A,(BitTable & $ff)
	LD   L,A
	LD   H,(BitTable / $100)			; 889c - BitTable
	LD   A,(RND1)
	AND  $03
	LD   C,A
	ADD  A,A
	ADD  A,C			;  x 3
	ADD  A,(BaddyTypesTable & $ff)
	LD   C,(HL)			; C = map row player is on
	LD   L,A
	LD   H,(BaddyTypesTable / $100)			; 8c7b BaddyTypesTable
	LD   A,(HL)
	LD   (IX+TYP),A			; IX+TYP
	INC  L
	LD   A,(HL)
	LD   (IX+GNO),A			; IX+GNO
	INC  L
	LD   A,(PlayerY)
	CP   $78
	RET  NC				; PlayerY > $78
	
	CP   $58
	RET  C				; PlayerY < $58
	
	LD   C,$FF			; Player Y in range of $58..$78
	LD   E,C
	LD   D,C
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

AnimateBurgers:
	LD   A,(FrameCounter)
	LD   HL,gfx_Burger2
	AND  $02
	JR   Z,SetBurgerFrame
	
	LD   HL,gfx_Burger

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

SetBurgerFrame:
	LD   (BurgerSpriteAddr),HL
	LD   A,(HeadButtCounter)
	OR   A
	RET  Z
	DEC  A
	LD   (HeadButtCounter),A
	RET  NZ
	LD   C,A
	DEC  A
	LD   (FireDebounce),A		; a=$ff when headbutt count first hits 0, stays set until fire is released.
	LD   A,(PlayerInAir)
	OR   A
	JR   Z,OnGround
	LD   C,$02					; bit 2 - jump

OnGround:
	LD   A,(PlayerDir)
	AND  $01					; mask off leaving just left/right
	ADD  A,C
	JP   SetPlayerDir


	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
; Start - Game start.
;

Start:
	DI  
	LD   SP,$63DD
	
;	LD   HL,$F280		; copy plip plop player into contended memory for later swapping.
;	LD   DE,$5B00		; PlipPlop player
;	LD   BC,$07D0
;	LDIR
;	
;	LD   HL,PreShiftedTiles			; $EE80	Copy Round3 map from temp loc tiles buffer
;	LD   DE,Map_Round3				; $63DE - final destination for round 3 map.
;	LD   BC,$0400					; 1K of map 
;	LDIR
	
	CALL InitIM2
	XOR  A
	LD   IY,Variables
	LD   (ColourMonoFlag),A
	LD   (SoundsMuteFlag),A
	OUT  ($FE),A
	DEC  A
	LD   (RND1),A
	
	CALL Sprint
	db CLA 			
	db CLS 			
	db RSET 			
	db AT, 7, 5
	db PEN, CYAN
	db "MUSICAL SCORES BY"
	db AT, 15, 6 
	db "BY"
	db AT, 9,7 
	db "MARTIN GALWAY"
	db AT, 10, 13 
	db "GAME CODING"
	db AT, 9, 14 
	db "GRAPHIC DESIGN"
	db AT, 5, 15 
	db "PLIP PLOP PROGRAMMING"
	db AT, 15, 16 
	db "BY"
	db AT, 8, 17 
	db "<<<IM;  NATHANO:"
	db $FF 			; end
	
	LD   B,$08
FadeLp:
	PUSH BC			; fade up credits
	LD   A, $48
	SUB  B
	LD   HL,$0505
	LD   BC,$111A
	CALL FillAttrBlock
	
	LD   B,$04
	CALL HaltB
	
	POP  BC
	DJNZ FadeLp
	
	CALL WaitForKeyDown
	CALL WaitForKeyUp
	
	LD   B,$08
FadeLp2:
	PUSH BC			; fade credits out
	LD   A,$3F
	ADD  A,B
	LD   HL,$0505
	LD   BC,$111A
	CALL FillAttrBlock
	LD   B,$04
	CALL HaltB
	
	POP  BC
	DJNZ FadeLp2
	
	LD   B,$64
	CALL HaltB

GameLoop:

	CALL Sprint
	db CLA 			; clear attr
	db CLS 			; clear scrn
	db RSET 		; reset print
	db FIN 
	
	LD   BC,$0C1A
	LD   DE,$0B50
	LD   HL,gfx_CobraLogo
	CALL DrawBitmap			; Cobra Logo
	
	LD   BC,$0C20
	LD   DE,$A050
	LD   HL,gfx_OceanLogo
	CALL DrawBitmap			; Ocean Logo
	
	LD   DE,$3050
	LD   BC,$0C08
	LD   HL,gfx_WarnerLogo
	CALL DrawBitmap			; Warner Bros

	XOR  A
	LD   ($432A),A
	LD   HL,$470A
	CALL Fill13
	LD   HL,$40AA
	CALL Fill13				; draw lines around Cobra logo
	
	CALL TitleScreen

	CALL PlayGame

	CALL DoHighScoreTable
	
	JR   GameLoop

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

Fill13:
	LD   B,$0C
FillLp:
	LD   (HL),$FF
	INC  L
	DJNZ FillLp
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

TitleScreen:
	EI  
	HALT
	CALL Sprint
	db AT, 13, 8 
	db EXPD, 2 
	db "SELECT"
	db RSET 
	db AT,9,11 
	db TABX 
	db "1  KEYBOARD ", RTN 
	db "2  KEMPSTON ", RTN
	db "3  SINCLAIR ", RTN
	db "4  CURSOR TYPE", RTN
	db "5  COLOUR/MONO", RTN
	db "6  SOUNDS/MUTE", RTN
	db "7  DEFINE KEYS", RTN
	db JSR 
	dw FillAttrBlocks			
	db $0A,$14,$15,$17,$41
	db $0B,$15,$14,$15,$4F 
	db $0B,$16,$14,$16,$0F 
	db $0A,$00,$15,$00,$47 
	db $0A,$05,$15,$05,$47 
	db $0A,$06,$15,$06,$41 
	db $0A,$01,$15,$04,$42 
	db $0D,$08,$12,$09,$07 
	db $09,$0B,$09,$11,$47 
	db $0C,$0B,$16,$0E,$47 
	db $0C,$0F,$16,$10,$46 
	db $0C,$11,$16,$11,$45 
	db FIN 					;END of ATTRBlocks
	db FIN 					;END of text

	CALL ColourInMenuOptions
	XOR  A						; Title Tune
	CALL PlayTune

MenuLoop:
	CALL GetMenuKeys
	OR   A
	JR   Z,MenuLoop
	CP   $08
	JR   NC,MenuLoop
	
	LD   (ControlMethod),A
	ADD  A,A
	LD   HL,MenuRoutines-2
	CALL AddHLA
	CALL JPIndex
	JP   TitleScreen

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

MenuRoutines:
	dw MenuKeyboard
	dw MenuKempston
	dw MenuSinclair
	dw MenuCursor
	dw MenuColour
	dw MenuSound
	dw DefineKeys

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

MenuKeyboard:
	POP  HL
	LD   HL,RedefinedKeys
	LD   DE,KeyTab+4
	LD   BC,$0008
	LDIR
	LD   DE,KeyTab+2
	LDI
	LDI
	LD   DE,KeyTab
	LDI
	LDI
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

MenuKempston:
	POP  HL
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

MenuSinclair:
	POP  HL
	LD   HL,$B4F7
	JR   SetJoy

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

MenuCursor:
	POP  HL
	LD   HL,$B4ED

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

SetJoy:
	LD   DE,$A31F
	LD   BC,$000A
	LDIR
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

ColourInMenuOptions:
	LD   A,(ColourMonoFlag)
	OR   A
	CALL ColourInColourMonoMenu
	LD   A,(SoundsMuteFlag)
	OR   A
	JR   ColourInSoundsMuteMenu

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

MenuSound:
	CALL MenuToggleSound
	LD   C,$09

PlaySoundUntilDone:
	LD   A,(SoundsMuteFlag)
	PUSH AF
	XOR  A
	LD   (SoundsMuteFlag),A
	LD   A,C
	CALL PlayBeepFX
	CALL WaitForSounds
	POP  AF
	LD   (SoundsMuteFlag),A
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

MenuToggleSound:
	LD   A,(SoundsMuteFlag)
	XOR  $01
	LD   (SoundsMuteFlag),A

ColourInSoundsMuteMenu:
	LD   HL,$5A0C
	LD   B,$06
	JR   NZ,FillAttributes
	LD   HL,$5A13
	LD   B,$04
	JR   FillAttributes

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

MenuColour:
	CALL MenuToggleColour
	LD   C,$05
	JR   PlaySoundUntilDone

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

MenuToggleColour:
	LD   A,(ColourMonoFlag)
	XOR  $01
	LD   (ColourMonoFlag),A

ColourInColourMonoMenu:
	LD   HL,$59EC
	LD   B,$06
	JR   NZ,FillAttributes
	LD   HL,$59F3
	LD   B,$04

FillAttributes:
	LD   (HL),$02
	INC  L
	DJNZ FillAttributes
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

DefineKeys:
	EI  
	CALL BlackScreenOut
	LD   HL,UserKeys
	LD   DE,UserKeys+1
	LD   BC,$0005
	LD   (HL),$3F			; Fill with Question Marks
	LDIR
	CALL Sprint
	db AT,11,8 
	db EXPD,2 
	db PEN,BRIGHT+CYAN
	db "PUSH ME..."
	db RSET
	db AT,11,12 
	db TABX
	db PEN,$44 
	db "UP", RTN
	db "DOWN", RTN 
	db "LEFT", RTN 
	db "RIGHT", RTN 
	db "MURDER", RTN 
	db "HOLD" 
PrintKeys:
	db DIR, DW 
	db AT, 20, 12 
	db PEN, BRIGHT + YELLOW 
UserKeys:
	db "QAOP[^"
	db DIR, RI 
	db PEN, $FF 
	db FIN 

	LD   B,$06				; six keys to redefine
	LD   HL,RedefinedKeys
	LD   IX,UserKeys

RedefineNxtKey:
	PUSH BC
	PUSH HL
	CALL WaitForKeyDown
	CALL SelectUniqueKey
	LD   (IX+$00),A
	PUSH BC
	
	LD   HL,PrintKeys
	CALL Sprint
	db JSRS 		
	dw PrintKeys 
	db FIN
	
	LD   C,$06					; Sound effect 6
	CALL PlaySoundUntilDone
	CALL WaitForKeyDown
	POP  BC
	POP  HL
	LD   A,C
	LD   (HL),A
	INC  HL
	LD   A,(KeyPressed)
	OR   $E0
	LD   (HL),A
	INC  HL
	POP  BC
	INC  IX
	DJNZ RedefineNxtKey
	
	LD   B,$64
	CALL HaltB

BlackScreenOut:
	LD   HL,$0809
	LD   BC,$1116
	XOR  A
	JP   FillAttrBlock

KeyPressed:
	db $BE 

SelectUniqueKey:
	HALT
	CALL ScanKeyboard
	JR   NZ,SelectUniqueKey
	LD   A,B
	DEC  A
	LD   B,E
	LD   C,D
	LD   HL,RDPortAscii-5		; $B41C	; HL = (RDPortAscii - 5)
	LD   DE,$0005
UnqLp:
	ADD  HL,DE					; HL = RDPOrtAscii
	DJNZ UnqLp					; loop through to the right row in the table
	
	CALL AddHLA
	LD   A,(HL)					; ASCII for key pressed
	LD   B,$06					; check key is uniquely defined
	LD   HL,UserKeys
NxtKey:
	CP   (HL)
	JR   Z,SelectUniqueKey
	INC  HL
	DJNZ NxtKey
	
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

ScanKeyboard:
	LD   DE,$FE08		; D bitmask ($fe), E = 8 rows to read
ReadQuad:
	LD   B,$05			; 5 possible presses per row

ReadRow:
	LD   A,B
	DEC  A
	ADD  A,A
	ADD  A,A
	ADD  A,A
	ADD  A,$47
	LD   (ModBit+1),A
	LD   A,D
	IN   A,($FE)
	LD   (KeyPressed),A
	
ModBit:
	BIT  0,A
	RET  Z
	DJNZ ReadRow
	
	SLA  D
	INC  D
	DEC  E
	JR   NZ,ReadQuad
	
	INC  E
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

DoHighScoreTable:
	EI  
	CALL Sprint
	db JSR 
	dw FillAttrBlocks 
	db 22,  2, 22, 15, $7F 
	db 11, 16, 22, 16 ,$7F 
	db 10,  1, 21, 15, $3F 
	db FIN 
	db FIN 
	CALL TryInsertScore
	CALL Sprint
	db PEN, $3A 
	db AT, 11, 2 
	db EXPD, 2 
	db "THE MORGUE"
	db RSET 
	db PEN, $38 
	db FIN 
	CALL PrintHighScores
	EI  
	
	LD   B,$00
WaitHSKey:
	HALT
	XOR  A
	IN   A,($FE)
	OR   $E0
	INC  A
	RET  NZ
	DJNZ WaitHSKey

	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

TryInsertScore:
	LD   B,$0A					; 10 entries
	LD   HL,HighScoreTable+4	; $B44D	top score in table

SearchTable:
	PUSH BC
	PUSH HL
	LD   DE,Score
	LD   B,$06
	EX   DE,HL
	CALL StrCmp
	POP  HL
	POP  BC
	JR   C,InsertScore
	LD   A,$0B
	CALL AddHLA
	DJNZ SearchTable
	RET 

InsertScore:
	PUSH BC
	LD   C,B
	PUSH HL
	LD   HL,HighScoreTableEnd
	LD   DE,HighScoreTableEnd+11
	LD   A,$01

ShiftScoreLoop:
	PUSH BC
	LD   BC,$000B		; 11 characters per highscore entry
	LDDR
	POP  BC
	CP   C
	JR   Z,InsertionPoint
	
	INC  A
	CP   $0B
	JR   NZ,ShiftScoreLoop

InsertionPoint:
	POP  HL
	PUSH HL
	EX   DE,HL
	LD   HL,Score
	LD   BC,$0006
	LDIR							; insert score into table
	POP  HL
	DEC  HL
	DEC  HL
	LD   A,$20						; clear name at this position
	LD   (HL),A
	DEC  HL
	LD   (HL),A
	DEC  HL
	LD   (HL),A
	LD   (NamePosition),HL
	LD   A,FIN						; FIN token for sprint
	LD   (HighScoreTableEnd+1),A
	CALL Sprint
	db EXPD, 2 
	db PEN, $39 
	db AT, 11, 2 
	db "ENTER NAME"
	db RSET
	db PEN, $38 
	db FIN 
	
	CALL PrintHighScores
	POP  BC
	LD   A,$0F
	SUB  B
	LD   L,$0B						; X = 11
	LD   H,A						; y = 15 - Position in table
	LD   C,$14						; 20 wide
	LD   B,H		 
	LD   A,(PAPER * WHITE) + RED
	LD   (Variables),HL				; set scrnx, scrny
	LD   (Variables_Attr),A			; set attr
	CALL FillAttrBlock
	LD   E,$1B
	LD   HL,$01F4
	LD   (NameEntryTime),HL
	JR   PrintHSChar

HSWaitForKey:
	HALT
	LD   HL,(NameEntryTime)
	DEC  HL
	LD   (NameEntryTime),HL
	LD   A,H
	OR   L
	JP   Z,EntryDone
	
	PUSH DE
	CALL Keys
	POP  DE
	OR   A
	JR   Z,HSWaitForKey
	
	BIT  4,A
	CALL NZ,InsertLetter
	
	SRL  A
	JR   NC,label_B3A1
	
	LD   HL,$01F4
	LD   (NameEntryTime),HL
	INC  E
	LD   A,E
	CP   $1F
	JR   NZ,PrintHSChar
	
	LD   E,$00						; print " "
	JR   PrintHSChar
	
label_B3A1:
	SRL  A
	JR   NC,PrintHSChar
	
	LD   HL,$01F4
	LD   (NameEntryTime),HL
	DEC  E
	LD   A,E
	INC  A
	JR   NZ,PrintHSChar
	LD   E,$1E						; print "*" 
	
PrintHSChar:
	LD   A,E
	LD   HL,ASCIITable
	CALL AddHLA
	LD   A,(HL)
	PUSH DE
	CALL PRChar
	DEC  (IY+V_SCRNX)
	XOR  A
	LD   (BeepFXNum),A
	
	LD   B,$08						; BLOOP!
KeyBeep:
	PUSH BC
	XOR  A
	LD   R,A
	CALL UpdateBeepFX
	POP  BC
	DJNZ KeyBeep
	
	POP  DE
	JR   HSWaitForKey

InsertLetter:
	LD   A,E
	LD   HL,ASCIITable
	CALL AddHLA
	LD   A,(HL)
	LD   HL,(NamePosition)
	LD   (HL),A
	INC  HL
	LD   (NamePosition),HL
	PUSH DE
	LD   C,$06
	CALL PlaySoundUntilDone

WaitKey:
	CALL Keys
	OR   A
	JR   NZ,WaitKey
	POP  DE
	LD   A,(Variables_ScrnX)			
	INC  A
	LD   (Variables_ScrnX),A			; SCRNX++
	CP   $0E
	JR   Z,FinishedEntry
	
	XOR  A
	RET 

FinishedEntry:
	POP  HL
EntryDone:
	JP   WaitForKeyDown

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

PrintHighScores:
	CALL Sprint
	db AT, 11, 5 
	db TABX
	db JSRS
	dw HighScoreTable
	db FIN
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

WaitForKeyUp:
	HALT
	XOR  A
	IN   A,($FE)
	OR   $E0
	INC  A
	JR   Z,WaitForKeyUp
	
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

WaitForKeyDown:
	XOR  A
	IN   A,($FE)
	OR   $E0
	INC  A
	JR   NZ,WaitForKeyDown
	RET 

RDPortAscii:			; 8 rows x 5 bytes of ASCII per row
	db $5D 
	db $5C 
	db $4D 
	db $4E 
	db $42 
	db $5E 
	db $4C 
	db $4B 
	db $4A 
	db $48 
	db $50 
	db $4F 
	db $49 
	db $55 
	db $59 
	db $30 
	db $39 
	db $38 
	db $37 
	db $36 
	db $31 
	db $32 
	db $33 
	db $34 
	db $35 
	db $51 
	db $57 
	db $45 
	db $52 
	db $54 
	db $41 
	db $53 
	db $44 
	db $46 
	db $47 
	db $5B 
	db $5A 
	db $58 
	db $43 
	db $56 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

HighScoreTable:
	db "DEB 150000", RTN 
	db "CLR 090000", RTN
	db "SIM 075000", RTN
	db "LYN 050000", RTN
	db "JNE 025000", RTN
	db "LOU 015000", RTN
	db "RAY 012000", RTN
	db "HEV 010000", RTN
	db "KAY 008000", RTN
	db "STL 004500" 
HighScoreTableEnd:
	db FIN 
	
	db "LEAVE HERE!"
	
ASCIITable:	
	db " ABCDEFGHIJKLMNOPQRSTUVWXYZ?!*."
	
RedefinedKeys:
	db $FB 
	db $FE 
	db $FD 
	db $FE 
	db $DF 
	db $FD 
	db $DF 
	db $FE 

	db $7F 
	db $FE 
	db $BF 
	db $FE 
	db $EF 
	db $FE 
	db $EF 
	db $F7 
	db $EF 
	db $EF 
	db $F7 
	db $EF 
	db $EF 
	db $FB 
	db $EF 
	db $FE 
	db $EF 
	db $FD 
	db $EF 
	db $FB 
	db $EF 
	db $EF 
	db $EF 
	db $F7 

NameEntryTime:
	dw $0000

NamePosition:
	dw $0000

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

GetMenuKeys:
	LD   BC,$0A00
	LD   HL,MenuKeyTable

ScanKeys:
	LD   A,(HL)
	INC  HL
	IN   A,($FE)
	OR   (HL)
	INC  A
	JR   NZ,.KeyPressed
	
	INC  HL
	INC  C
	DJNZ ScanKeys
	
	OR   A
	RET 

.KeyPressed:
	LD   A,C
	SCF
	RET 

; 10 pairs of values
MenuKeyTable:
	db $EF 
	db $FE 
	db $F7 
	db $FE 
	db $F7 
	db $FD 
	db $F7 
	db $FB 
	db $F7 
	db $F7 
	db $F7 
	db $EF 
	db $EF 
	db $EF 
	db $EF 
	db $F7 
	db $EF 
	db $FB 
	db $EF 
	db $FD 

	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	
; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;
	org $b5d0

gfx_Burger:
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $03 
	db $FC 
	db $F0 
	db $0F 
	db $80 
	db $78 
	db $00 
	db $07 
	db $7F 
	db $80 
	db $3F 
	db $C0 
	db $00 
	db $00 
	db $00 
	db $C0 
	db $00 
	db $80 
	db $00 
	db $00 
	db $3F 
	db $40 
	db $3F 
	db $40 
	db $00 
	db $00 
	db $00 
	db $80 
	db $80 
	db $7F 
	db $00 
	db $FF 
	db $7F 
	db $80 
	db $3F 
	db $C0 
	db $00 
	db $12 
	db $00 
	db $DA 
	db $00 
	db $BC 
	db $00 
	db $80 
	db $3F 
	db $40 
	db $3F 
	db $C0 
	db $00 
	db $10 
	db $00 
	db $D4 
	db $80 
	db $7F 
	db $00 
	db $FF 
	db $7F 
	db $80 
	db $3F 
	db $C0 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $80 
	db $00 
	db $00 
	db $3F 
	db $40 
	db $3F 
	db $40 
	db $00 
	db $00 
	db $00 
	db $80 
	db $00 
	db $C0 
	db $00 
	db $00 
	db $3F 
	db $C0 
	db $7F 
	db $80 
	db $00 
	db $FF 
	db $80 
	db $7F 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $FF 
	db $FC 
	db $03 
	db $E0 
	db $1E 
	db $00 
	db $01 
	db $1F 
	db $E0 
	db $0F 
	db $30 
	db $00 
	db $00 
	db $C0 
	db $30 
	db $C0 
	db $20 
	db $00 
	db $00 
	db $0F 
	db $10 
	db $0F 
	db $10 
	db $00 
	db $00 
	db $C0 
	db $20 
	db $E0 
	db $1F 
	db $00 
	db $FF 
	db $1F 
	db $E0 
	db $0F 
	db $B0 
	db $00 
	db $84 
	db $C0 
	db $36 
	db $C0 
	db $2F 
	db $00 
	db $20 
	db $0F 
	db $10 
	db $0F 
	db $30 
	db $00 
	db $04 
	db $C0 
	db $35 
	db $E0 
	db $1F 
	db $00 
	db $FF 
	db $1F 
	db $E0 
	db $0F 
	db $F0 
	db $00 
	db $FF 
	db $C0 
	db $3F 
	db $C0 
	db $20 
	db $00 
	db $00 
	db $0F 
	db $10 
	db $0F 
	db $10 
	db $00 
	db $00 
	db $C0 
	db $20 
	db $C0 
	db $30 
	db $00 
	db $00 
	db $0F 
	db $30 
	db $1F 
	db $E0 
	db $00 
	db $FF 
	db $E0 
	db $1F 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $3F 
	db $C0 
	db $00 
	db $FF 
	db $FF 
	db $00 
	db $F8 
	db $07 
	db $00 
	db $80 
	db $07 
	db $78 
	db $03 
	db $0C 
	db $00 
	db $00 
	db $F0 
	db $0C 
	db $F0 
	db $08 
	db $00 
	db $00 
	db $03 
	db $04 
	db $03 
	db $04 
	db $00 
	db $00 
	db $F0 
	db $08 
	db $F8 
	db $07 
	db $00 
	db $FF 
	db $07 
	db $F8 
	db $03 
	db $2C 
	db $00 
	db $A1 
	db $F0 
	db $0D 
	db $F0 
	db $0B 
	db $00 
	db $C8 
	db $03 
	db $04 
	db $03 
	db $0C 
	db $00 
	db $41 
	db $F0 
	db $0D 
	db $F8 
	db $07 
	db $00 
	db $FF 
	db $07 
	db $F8 
	db $03 
	db $FC 
	db $00 
	db $FF 
	db $F0 
	db $0F 
	db $F0 
	db $08 
	db $00 
	db $00 
	db $03 
	db $04 
	db $03 
	db $04 
	db $00 
	db $00 
	db $F0 
	db $08 
	db $F0 
	db $0C 
	db $00 
	db $00 
	db $03 
	db $0C 
	db $07 
	db $F8 
	db $00 
	db $FF 
	db $F8 
	db $07 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $0F 
	db $F0 
	db $C0 
	db $3F 
	db $FF 
	db $00 
	db $FE 
	db $01 
	db $00 
	db $E0 
	db $01 
	db $1E 
	db $00 
	db $03 
	db $00 
	db $00 
	db $FC 
	db $03 
	db $FC 
	db $02 
	db $00 
	db $00 
	db $00 
	db $01 
	db $00 
	db $01 
	db $00 
	db $00 
	db $FC 
	db $02 
	db $FE 
	db $01 
	db $00 
	db $FF 
	db $01 
	db $FE 
	db $00 
	db $4B 
	db $00 
	db $68 
	db $FC 
	db $03 
	db $FC 
	db $02 
	db $00 
	db $F2 
	db $00 
	db $01 
	db $00 
	db $43 
	db $00 
	db $50 
	db $FC 
	db $03 
	db $FE 
	db $01 
	db $00 
	db $FF 
	db $01 
	db $FE 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $FC 
	db $03 
	db $FC 
	db $02 
	db $00 
	db $00 
	db $00 
	db $01 
	db $00 
	db $01 
	db $00 
	db $00 
	db $FC 
	db $02 
	db $FC 
	db $03 
	db $00 
	db $00 
	db $00 
	db $03 
	db $01 
	db $FE 
	db $00 
	db $FF 
	db $FE 
	db $01 
	
	
gfx_OceanLogo:
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $01 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $80 
	db $07 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $E0 
	db $06 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $60 
	db $0C 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $30 
	db $0D 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $B0 
	db $0D 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $B0 
	db $0D 
	db $01 
	db $F8 
	db $01 
	db $F8 
	db $01 
	db $F8 
	db $01 
	db $FB 
	db $CF 
	db $80 
	db $B0 
	db $0D 
	db $07 
	db $FE 
	db $07 
	db $FE 
	db $07 
	db $FE 
	db $07 
	db $FF 
	db $DF 
	db $E0 
	db $B0 
	db $0D 
	db $0F 
	db $FF 
	db $0F 
	db $FF 
	db $0F 
	db $FF 
	db $0F 
	db $FF 
	db $FF 
	db $F0 
	db $B0 
	db $0D 
	db $1F 
	db $FF 
	db $9F 
	db $FF 
	db $9F 
	db $9F 
	db $9F 
	db $FF 
	db $FF 
	db $F8 
	db $B0 
	db $0D 
	db $1F 
	db $9F 
	db $9F 
	db $9F 
	db $9E 
	db $07 
	db $9F 
	db $9F 
	db $F9 
	db $F8 
	db $B0 
	db $0D 
	db $3E 
	db $07 
	db $FE 
	db $07 
	db $FE 
	db $07 
	db $FE 
	db $07 
	db $E0 
	db $7C 
	db $B0 
	db $0D 
	db $3E 
	db $07 
	db $FE 
	db $00 
	db $3F 
	db $FF 
	db $FE 
	db $07 
	db $E0 
	db $7C 
	db $B0 
	db $0D 
	db $3C 
	db $03 
	db $FC 
	db $00 
	db $3F 
	db $FF 
	db $FC 
	db $03 
	db $C0 
	db $3C 
	db $B0 
	db $0D 
	db $3C 
	db $03 
	db $FC 
	db $00 
	db $3F 
	db $FF 
	db $FC 
	db $03 
	db $C0 
	db $3C 
	db $B0 
	db $0D 
	db $3E 
	db $07 
	db $FE 
	db $00 
	db $3E 
	db $00 
	db $3E 
	db $07 
	db $C0 
	db $3C 
	db $B0 
	db $0D 
	db $3E 
	db $07 
	db $FE 
	db $07 
	db $FE 
	db $07 
	db $FE 
	db $07 
	db $C0 
	db $3C 
	db $B0 
	db $0D 
	db $1F 
	db $9F 
	db $9F 
	db $9F 
	db $9F 
	db $9F 
	db $9F 
	db $9F 
	db $C0 
	db $3C 
	db $B0 
	db $0D 
	db $1F 
	db $FF 
	db $9F 
	db $FF 
	db $9F 
	db $FF 
	db $9F 
	db $FF 
	db $C0 
	db $3C 
	db $B0 
	db $0D 
	db $0F 
	db $FF 
	db $0F 
	db $FF 
	db $0F 
	db $FF 
	db $0F 
	db $FF 
	db $C0 
	db $3C 
	db $B0 
	db $0D 
	db $07 
	db $FE 
	db $07 
	db $FE 
	db $07 
	db $FE 
	db $07 
	db $FF 
	db $C0 
	db $3C 
	db $B0 
	db $0D 
	db $01 
	db $F8 
	db $01 
	db $F8 
	db $01 
	db $F8 
	db $01 
	db $FB 
	db $C0 
	db $3C 
	db $B0 
	db $0D 
	db $FE 
	db $07 
	db $FE 
	db $07 
	db $FE 
	db $07 
	db $FE 
	db $04 
	db $3F 
	db $C3 
	db $B0 
	db $0D 
	db $F8 
	db $01 
	db $F8 
	db $01 
	db $F8 
	db $01 
	db $F0 
	db $00 
	db $3F 
	db $C3 
	db $B0 
	db $0C 
	db $F0 
	db $00 
	db $F0 
	db $00 
	db $F0 
	db $00 
	db $E0 
	db $00 
	db $3F 
	db $C3 
	db $30 
	db $06 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $60 
	db $07 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $E0 
	db $01 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $80 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
; Sprites are stored with the mask and data interleaved and alternately zig-zag each line of data,
; writing out the first line left to right and the second line right to left.
;
; Mask and data are POPed off together in one 16 bit register pair
;
;

gfx_NightSlasherLeft:			; Sprites start here
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $9F 
	db $00 
	db $E8 
	db $00 
	db $C0 
	db $17 
	db $07 
	db $60 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $03 
	db $E8 
	db $80 
	db $39 
	db $00 
	db $70 
	db $07 
	db $F0 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $01 
	db $F8 
	db $80 
	db $3A 
	db $C0 
	db $1A 
	db $00 
	db $5E 
	db $FF 
	db $00 
	db $7F 
	db $00 
	db $00 
	db $B3 
	db $C0 
	db $10 
	db $80 
	db $39 
	db $00 
	db $A1 
	db $7F 
	db $00 
	db $3F 
	db $80 
	db $00 
	db $21 
	db $00 
	db $6F 
	db $00 
	db $40 
	db $00 
	db $20 
	db $3F 
	db $80 
	db $3F 
	db $80 
	db $00 
	db $30 
	db $00 
	db $40 
	db $00 
	db $40 
	db $00 
	db $10 
	db $3F 
	db $80 
	db $3F 
	db $80 
	db $00 
	db $38 
	db $80 
	db $24 
	db $80 
	db $3B 
	db $00 
	db $DC 
	db $3F 
	db $80 
	db $3F 
	db $80 
	db $00 
	db $3C 
	db $80 
	db $34 
	db $00 
	db $7B 
	db $00 
	db $68 
	db $3F 
	db $80 
	db $3F 
	db $80 
	db $00 
	db $C1 
	db $00 
	db $5F 
	db $00 
	db $4C 
	db $00 
	db $41 
	db $7F 
	db $00 
	db $7F 
	db $00 
	db $00 
	db $E3 
	db $00 
	db $67 
	db $80 
	db $3C 
	db $00 
	db $9E 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $C6 
	db $C0 
	db $11 
	db $C0 
	db $1B 
	db $01 
	db $6C 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $83 
	db $38 
	db $E0 
	db $0E 
	db $FA 
	db $00 
	db $27 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $01 
	db $D8 
	db $F0 
	db $05 
	db $E0 
	db $0E 
	db $00 
	db $7A 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $01 
	db $3C 
	db $C0 
	db $1C 
	db $E0 
	db $0E 
	db $01 
	db $BC 
	db $FF 
	db $00 
	db $7F 
	db $00 
	db $00 
	db $9E 
	db $F0 
	db $06 
	db $F0 
	db $04 
	db $00 
	db $27 
	db $3F 
	db $80 
	db $1F 
	db $C0 
	db $00 
	db $6C 
	db $F0 
	db $06 
	db $E0 
	db $0F 
	db $00 
	db $C8 
	db $1F 
	db $40 
	db $0F 
	db $60 
	db $00 
	db $08 
	db $C0 
	db $18 
	db $C0 
	db $10 
	db $00 
	db $08 
	db $0F 
	db $20 
	db $0F 
	db $20 
	db $00 
	db $0C 
	db $C0 
	db $10 
	db $C0 
	db $10 
	db $00 
	db $04 
	db $0F 
	db $20 
	db $0F 
	db $20 
	db $00 
	db $0E 
	db $E0 
	db $09 
	db $E0 
	db $0E 
	db $00 
	db $F7 
	db $0F 
	db $20 
	db $0F 
	db $20 
	db $00 
	db $0F 
	db $E0 
	db $0D 
	db $C0 
	db $1E 
	db $00 
	db $DA 
	db $0F 
	db $20 
	db $0F 
	db $60 
	db $00 
	db $F0 
	db $C0 
	db $17 
	db $C0 
	db $13 
	db $00 
	db $10 
	db $1F 
	db $40 
	db $1F 
	db $C0 
	db $00 
	db $F8 
	db $C0 
	db $19 
	db $E0 
	db $0F 
	db $00 
	db $27 
	db $3F 
	db $80 
	db $3F 
	db $80 
	db $00 
	db $71 
	db $F0 
	db $04 
	db $F0 
	db $06 
	db $00 
	db $DB 
	db $7F 
	db $00 
	db $FF 
	db $00 
	db $20 
	db $8E 
	db $F8 
	db $03 
	db $FE 
	db $00 
	db $89 
	db $00 
	db $FF 
	db $00 
	db $7F 
	db $00 
	db $00 
	db $76 
	db $FC 
	db $01 
	db $F8 
	db $03 
	db $00 
	db $9E 
	db $3F 
	db $80 
	db $7F 
	db $00 
	db $00 
	db $0F 
	db $F0 
	db $07 
	db $F8 
	db $03 
	db $00 
	db $AF 
	db $1F 
	db $80 
	db $0F 
	db $E0 
	db $00 
	db $A5 
	db $FC 
	db $01 
	db $FC 
	db $01 
	db $00 
	db $0B 
	db $07 
	db $30 
	db $07 
	db $10 
	db $00 
	db $9A 
	db $F8 
	db $03 
	db $F0 
	db $06 
	db $00 
	db $F2 
	db $03 
	db $18 
	db $03 
	db $08 
	db $00 
	db $02 
	db $F0 
	db $04 
	db $F0 
	db $04 
	db $00 
	db $03 
	db $03 
	db $08 
	db $03 
	db $08 
	db $00 
	db $01 
	db $F0 
	db $04 
	db $F8 
	db $02 
	db $00 
	db $43 
	db $03 
	db $88 
	db $03 
	db $C8 
	db $00 
	db $BD 
	db $F8 
	db $03 
	db $F8 
	db $03 
	db $00 
	db $43 
	db $03 
	db $C8 
	db $03 
	db $88 
	db $00 
	db $B6 
	db $F0 
	db $07 
	db $F0 
	db $05 
	db $00 
	db $FC 
	db $03 
	db $18 
	db $07 
	db $10 
	db $00 
	db $C4 
	db $F0 
	db $04 
	db $F0 
	db $06 
	db $00 
	db $7E 
	db $07 
	db $30 
	db $0F 
	db $E0 
	db $00 
	db $C9 
	db $F8 
	db $01 
	db $FE 
	db $00 
	db $00 
	db $48 
	db $1F 
	db $80 
	db $3F 
	db $80 
	db $00 
	db $48 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $48 
	db $3F 
	db $80 
	db $3F 
	db $80 
	db $00 
	db $7F 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $A2 
	db $00 
	db $7F 
	db $00 
	db $1F 
	db $80 
	db $00 
	db $5D 
	db $FF 
	db $00 
	db $FE 
	db $00 
	db $00 
	db $E7 
	db $0F 
	db $A0 
	db $1F 
	db $C0 
	db $00 
	db $C3 
	db $FC 
	db $01 
	db $FE 
	db $00 
	db $00 
	db $EB 
	db $07 
	db $E0 
	db $03 
	db $78 
	db $00 
	db $69 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $42 
	db $01 
	db $CC 
	db $01 
	db $84 
	db $00 
	db $E6 
	db $FE 
	db $00 
	db $FC 
	db $01 
	db $00 
	db $BC 
	db $00 
	db $86 
	db $00 
	db $82 
	db $00 
	db $00 
	db $FC 
	db $01 
	db $FC 
	db $01 
	db $00 
	db $00 
	db $00 
	db $C2 
	db $00 
	db $42 
	db $00 
	db $00 
	db $FC 
	db $01 
	db $FE 
	db $00 
	db $00 
	db $90 
	db $00 
	db $E2 
	db $00 
	db $72 
	db $00 
	db $EF 
	db $FE 
	db $00 
	db $FE 
	db $00 
	db $00 
	db $D0 
	db $00 
	db $F2 
	db $00 
	db $A2 
	db $00 
	db $ED 
	db $FC 
	db $01 
	db $FC 
	db $01 
	db $00 
	db $7F 
	db $00 
	db $06 
	db $01 
	db $04 
	db $00 
	db $31 
	db $FC 
	db $01 
	db $FC 
	db $01 
	db $00 
	db $9F 
	db $01 
	db $8C 
	db $03 
	db $78 
	db $00 
	db $72 
	db $FE 
	db $00 
	db $FF 
	db $00 
	db $80 
	db $12 
	db $07 
	db $20 
	db $0F 
	db $20 
	db $C0 
	db $12 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $C0 
	db $12 
	db $0F 
	db $20 
	db $0F 
	db $E0 
	db $C0 
	db $1F 
	db $FF 
	db $00 
gfx_NightSlasherRight:
	db $FE 
	db $00 
	db $45 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $BA 
	db $F8 
	db $01 
	db $F0 
	db $05 
	db $00 
	db $E7 
	db $7F 
	db $00 
	db $3F 
	db $80 
	db $00 
	db $C3 
	db $F8 
	db $03 
	db $E0 
	db $07 
	db $00 
	db $D7 
	db $7F 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $96 
	db $C0 
	db $1E 
	db $80 
	db $33 
	db $00 
	db $42 
	db $FF 
	db $00 
	db $7F 
	db $00 
	db $00 
	db $67 
	db $80 
	db $21 
	db $00 
	db $61 
	db $00 
	db $3D 
	db $3F 
	db $80 
	db $3F 
	db $80 
	db $00 
	db $00 
	db $00 
	db $41 
	db $00 
	db $43 
	db $00 
	db $00 
	db $3F 
	db $80 
	db $3F 
	db $80 
	db $00 
	db $00 
	db $00 
	db $42 
	db $00 
	db $47 
	db $00 
	db $09 
	db $7F 
	db $00 
	db $7F 
	db $00 
	db $00 
	db $F7 
	db $00 
	db $4E 
	db $00 
	db $4F 
	db $00 
	db $0B 
	db $7F 
	db $00 
	db $3F 
	db $80 
	db $00 
	db $B7 
	db $00 
	db $45 
	db $00 
	db $60 
	db $00 
	db $FE 
	db $3F 
	db $80 
	db $3F 
	db $80 
	db $00 
	db $8C 
	db $80 
	db $20 
	db $80 
	db $31 
	db $00 
	db $F9 
	db $3F 
	db $80 
	db $7F 
	db $00 
	db $00 
	db $4E 
	db $C0 
	db $1E 
	db $E0 
	db $04 
	db $01 
	db $48 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $03 
	db $48 
	db $F0 
	db $04 
	db $F0 
	db $04 
	db $03 
	db $48 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $03 
	db $F8 
	db $F0 
	db $07 
	db $FF 
	db $00 
	db $91 
	db $00 
	db $7F 
	db $00 
	db $3F 
	db $80 
	db $00 
	db $6E 
	db $FE 
	db $00 
	db $FC 
	db $01 
	db $00 
	db $79 
	db $1F 
	db $C0 
	db $0F 
	db $E0 
	db $00 
	db $F0 
	db $FE 
	db $00 
	db $F8 
	db $01 
	db $00 
	db $F5 
	db $1F 
	db $C0 
	db $3F 
	db $80 
	db $00 
	db $A5 
	db $F0 
	db $07 
	db $E0 
	db $0C 
	db $00 
	db $D0 
	db $3F 
	db $80 
	db $1F 
	db $C0 
	db $00 
	db $59 
	db $E0 
	db $08 
	db $C0 
	db $18 
	db $00 
	db $4F 
	db $0F 
	db $60 
	db $0F 
	db $20 
	db $00 
	db $40 
	db $C0 
	db $10 
	db $C0 
	db $10 
	db $00 
	db $C0 
	db $0F 
	db $20 
	db $0F 
	db $20 
	db $00 
	db $80 
	db $C0 
	db $10 
	db $C0 
	db $11 
	db $00 
	db $C2 
	db $1F 
	db $40 
	db $1F 
	db $C0 
	db $00 
	db $BD 
	db $C0 
	db $13 
	db $C0 
	db $13 
	db $00 
	db $C2 
	db $1F 
	db $C0 
	db $0F 
	db $E0 
	db $00 
	db $6D 
	db $C0 
	db $11 
	db $C0 
	db $18 
	db $00 
	db $3F 
	db $0F 
	db $A0 
	db $0F 
	db $20 
	db $00 
	db $23 
	db $E0 
	db $08 
	db $E0 
	db $0C 
	db $00 
	db $7E 
	db $0F 
	db $60 
	db $1F 
	db $80 
	db $00 
	db $93 
	db $F0 
	db $07 
	db $F8 
	db $01 
	db $00 
	db $12 
	db $7F 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $12 
	db $FC 
	db $01 
	db $FC 
	db $01 
	db $00 
	db $12 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $FE 
	db $FC 
	db $01 
	db $FF 
	db $00 
	db $E4 
	db $00 
	db $5F 
	db $00 
	db $0F 
	db $A0 
	db $80 
	db $1B 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $5E 
	db $07 
	db $70 
	db $03 
	db $38 
	db $80 
	db $3C 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $80 
	db $3D 
	db $07 
	db $70 
	db $0F 
	db $60 
	db $00 
	db $79 
	db $FE 
	db $00 
	db $FC 
	db $01 
	db $00 
	db $E4 
	db $0F 
	db $20 
	db $0F 
	db $60 
	db $00 
	db $36 
	db $F8 
	db $03 
	db $F8 
	db $02 
	db $00 
	db $13 
	db $07 
	db $F0 
	db $03 
	db $18 
	db $00 
	db $10 
	db $F0 
	db $06 
	db $F0 
	db $04 
	db $00 
	db $10 
	db $03 
	db $08 
	db $03 
	db $08 
	db $00 
	db $30 
	db $F0 
	db $04 
	db $F0 
	db $04 
	db $00 
	db $20 
	db $03 
	db $08 
	db $07 
	db $90 
	db $00 
	db $70 
	db $F0 
	db $04 
	db $F0 
	db $04 
	db $00 
	db $EF 
	db $07 
	db $70 
	db $07 
	db $B0 
	db $00 
	db $F0 
	db $F0 
	db $04 
	db $F0 
	db $04 
	db $00 
	db $5B 
	db $03 
	db $78 
	db $03 
	db $E8 
	db $00 
	db $0F 
	db $F0 
	db $06 
	db $F8 
	db $02 
	db $00 
	db $08 
	db $03 
	db $C8 
	db $03 
	db $98 
	db $00 
	db $1F 
	db $F8 
	db $03 
	db $FC 
	db $01 
	db $00 
	db $E4 
	db $07 
	db $F0 
	db $0F 
	db $20 
	db $00 
	db $8E 
	db $FC 
	db $01 
	db $FE 
	db $00 
	db $00 
	db $DB 
	db $0F 
	db $60 
	db $1F 
	db $C0 
	db $04 
	db $71 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $17 
	db $00 
	db $F9 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $E0 
	db $06 
	db $03 
	db $E8 
	db $01 
	db $9C 
	db $C0 
	db $17 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $E0 
	db $0F 
	db $00 
	db $0E 
	db $01 
	db $5C 
	db $80 
	db $1F 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $7A 
	db $03 
	db $58 
	db $03 
	db $08 
	db $00 
	db $CD 
	db $FE 
	db $00 
	db $FE 
	db $00 
	db $00 
	db $85 
	db $01 
	db $9C 
	db $00 
	db $F6 
	db $00 
	db $84 
	db $FC 
	db $01 
	db $FC 
	db $01 
	db $00 
	db $04 
	db $00 
	db $02 
	db $00 
	db $02 
	db $00 
	db $0C 
	db $FC 
	db $01 
	db $FC 
	db $01 
	db $00 
	db $08 
	db $00 
	db $02 
	db $01 
	db $24 
	db $00 
	db $1C 
	db $FC 
	db $01 
	db $FC 
	db $01 
	db $00 
	db $3B 
	db $01 
	db $DC 
	db $01 
	db $2C 
	db $00 
	db $3C 
	db $FC 
	db $01 
	db $FC 
	db $01 
	db $00 
	db $16 
	db $00 
	db $DE 
	db $00 
	db $FA 
	db $00 
	db $83 
	db $FC 
	db $01 
	db $FE 
	db $00 
	db $00 
	db $82 
	db $00 
	db $32 
	db $00 
	db $E6 
	db $00 
	db $C7 
	db $FE 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $79 
	db $01 
	db $3C 
	db $03 
	db $88 
	db $00 
	db $63 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $80 
	db $36 
	db $03 
	db $D8 
	db $07 
	db $70 
	db $C1 
	db $1C 
	db $FF 
	db $00 
gfx_BazookaLadyLeft:
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $C5 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $3A 
	db $FF 
	db $00 
	db $7F 
	db $00 
	db $00 
	db $FF 
	db $FE 
	db $00 
	db $FC 
	db $01 
	db $00 
	db $FE 
	db $FF 
	db $00 
	db $7F 
	db $00 
	db $00 
	db $FF 
	db $FE 
	db $00 
	db $BC 
	db $01 
	db $00 
	db $3E 
	db $7F 
	db $00 
	db $3F 
	db $80 
	db $00 
	db $7A 
	db $00 
	db $40 
	db $00 
	db $7F 
	db $00 
	db $FB 
	db $3F 
	db $80 
	db $3F 
	db $80 
	db $00 
	db $72 
	db $00 
	db $40 
	db $00 
	db $7F 
	db $00 
	db $83 
	db $3F 
	db $80 
	db $3F 
	db $80 
	db $00 
	db $D3 
	db $00 
	db $7F 
	db $00 
	db $79 
	db $00 
	db $E7 
	db $3F 
	db $80 
	db $3F 
	db $80 
	db $00 
	db $FE 
	db $00 
	db $51 
	db $80 
	db $11 
	db $00 
	db $E6 
	db $7F 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $A2 
	db $E0 
	db $08 
	db $C0 
	db $1C 
	db $00 
	db $32 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $1E 
	db $80 
	db $24 
	db $80 
	db $26 
	db $01 
	db $3C 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $01 
	db $E4 
	db $C0 
	db $1D 
	db $E0 
	db $0D 
	db $01 
	db $FC 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $3E 
	db $F0 
	db $03 
	db $F0 
	db $06 
	db $00 
	db $6F 
	db $7F 
	db $00 
	db $7F 
	db $00 
	db $00 
	db $BB 
	db $F0 
	db $04 
	db $E0 
	db $0C 
	db $00 
	db $6F 
	db $3F 
	db $80 
	db $3F 
	db $80 
	db $00 
	db $BD 
	db $E0 
	db $08 
	db $E0 
	db $09 
	db $00 
	db $6F 
	db $3F 
	db $80 
	db $3F 
	db $80 
	db $00 
	db $BD 
	db $E0 
	db $08 
	db $C0 
	db $1F 
	db $00 
	db $FF 
	db $1F 
	db $C0 
	db $1F 
	db $40 
	db $00 
	db $25 
	db $C0 
	db $15 
	db $C0 
	db $15 
	db $00 
	db $25 
	db $1F 
	db $40 
	db $1F 
	db $C0 
	db $00 
	db $FF 
	db $C0 
	db $1F 
	db $FF 
	db $00 
	db $F1 
	db $00 
	db $7F 
	db $00 
	db $3F 
	db $80 
	db $C0 
	db $0E 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $80 
	db $3F 
	db $1F 
	db $C0 
	db $3F 
	db $80 
	db $00 
	db $7F 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $80 
	db $3F 
	db $1F 
	db $C0 
	db $1F 
	db $80 
	db $00 
	db $4F 
	db $EF 
	db $00 
	db $C0 
	db $10 
	db $00 
	db $12 
	db $0F 
	db $A0 
	db $0F 
	db $E0 
	db $00 
	db $FA 
	db $C0 
	db $1F 
	db $C0 
	db $10 
	db $00 
	db $1C 
	db $0F 
	db $A0 
	db $0F 
	db $E0 
	db $00 
	db $E0 
	db $C0 
	db $1F 
	db $C0 
	db $1F 
	db $00 
	db $F4 
	db $0F 
	db $E0 
	db $0F 
	db $E0 
	db $00 
	db $79 
	db $C0 
	db $1E 
	db $C0 
	db $14 
	db $00 
	db $7F 
	db $0F 
	db $A0 
	db $1F 
	db $80 
	db $00 
	db $79 
	db $E0 
	db $04 
	db $F8 
	db $02 
	db $00 
	db $28 
	db $3F 
	db $80 
	db $3F 
	db $80 
	db $00 
	db $0C 
	db $F0 
	db $07 
	db $E0 
	db $09 
	db $00 
	db $07 
	db $3F 
	db $80 
	db $7F 
	db $00 
	db $00 
	db $8F 
	db $E0 
	db $09 
	db $F0 
	db $07 
	db $00 
	db $7F 
	db $7F 
	db $00 
	db $7F 
	db $00 
	db $00 
	db $51 
	db $F8 
	db $03 
	db $FC 
	db $00 
	db $00 
	db $7F 
	db $7F 
	db $00 
	db $3F 
	db $80 
	db $00 
	db $CF 
	db $FE 
	db $00 
	db $FC 
	db $01 
	db $00 
	db $9B 
	db $1F 
	db $C0 
	db $1F 
	db $C0 
	db $00 
	db $2E 
	db $FC 
	db $01 
	db $F8 
	db $03 
	db $00 
	db $1B 
	db $0F 
	db $E0 
	db $0F 
	db $60 
	db $00 
	db $2F 
	db $F8 
	db $02 
	db $F8 
	db $02 
	db $00 
	db $5B 
	db $0F 
	db $E0 
	db $0F 
	db $60 
	db $00 
	db $2F 
	db $F8 
	db $02 
	db $F0 
	db $07 
	db $00 
	db $FF 
	db $07 
	db $F0 
	db $07 
	db $50 
	db $00 
	db $49 
	db $F0 
	db $05 
	db $F0 
	db $05 
	db $00 
	db $49 
	db $07 
	db $50 
	db $07 
	db $F0 
	db $00 
	db $FF 
	db $F0 
	db $07 
	db $FF 
	db $00 
	db $FC 
	db $00 
	db $5F 
	db $00 
	db $0F 
	db $A0 
	db $F0 
	db $03 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $E0 
	db $0F 
	db $07 
	db $F0 
	db $0F 
	db $E0 
	db $C0 
	db $1F 
	db $FF 
	db $00 
	db $FB 
	db $00 
	db $E0 
	db $0F 
	db $07 
	db $F0 
	db $03 
	db $E8 
	db $00 
	db $13 
	db $F0 
	db $04 
	db $F0 
	db $07 
	db $00 
	db $FC 
	db $03 
	db $B8 
	db $03 
	db $A8 
	db $00 
	db $06 
	db $F0 
	db $04 
	db $F0 
label_BF01:
	db $07 
	db $00 
	db $FF 
	db $03 
	db $38 
	db $03 
	db $38 
	db $00 
	db $F8 
	db $F0 
	db $07 
	db $F0 
	db $07 
	db $00 
	db $9D 
	db $03 
	db $38 
	db $03 
	db $E8 
	db $00 
	db $1F 
	db $F0 
	db $05 
	db $F8 
	db $01 
	db $00 
	db $1E 
	db $07 
	db $60 
	db $0F 
	db $20 
	db $00 
	db $8A 
	db $FE 
	db $00 
	db $FC 
	db $01 
	db $00 
	db $C3 
	db $0F 
	db $20 
	db $0F 
	db $E0 
	db $00 
	db $41 
	db $F8 
	db $02 
	db $F8 
	db $02 
	db $00 
	db $63 
	db $1F 
	db $C0 
	db $1F 
	db $C0 
	db $00 
	db $DF 
	db $FC 
	db $01 
	db $FE 
	db $00 
	db $00 
	db $DF 
	db $1F 
	db $C0 
	db $1F 
	db $40 
	db $00 
	db $14 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $C0 
	db $1F 
	db $1F 
	db $C0 
	db $0F 
	db $E0 
	db $80 
	db $33 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $66 
	db $07 
	db $F0 
	db $07 
	db $B0 
	db $00 
	db $4B 
	db $FF 
	db $00 
	db $FE 
	db $00 
	db $00 
	db $C6 
	db $03 
	db $F8 
	db $03 
	db $D8 
	db $00 
	db $8B 
	db $FE 
	db $00 
	db $FE 
	db $00 
	db $00 
	db $96 
	db $03 
	db $F8 
	db $03 
	db $D8 
	db $00 
	db $8B 
	db $FE 
	db $00 
	db $FC 
	db $01 
	db $00 
	db $FF 
	db $01 
	db $FC 
	db $01 
	db $54 
	db $00 
	db $52 
	db $FC 
	db $01 
	db $FC 
	db $01 
	db $00 
	db $52 
	db $01 
	db $54 
	db $01 
	db $FC 
	db $00 
	db $FF 
	db $FC 
	db $01 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $17 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FC 
	db $00 
	db $03 
	db $E8 
	db $01 
	db $FC 
	db $F8 
	db $03 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $F0 
	db $07 
	db $03 
	db $F8 
	db $01 
	db $FC 
	db $F8 
	db $03 
	db $FF 
	db $00 
	db $FE 
	db $00 
	db $F0 
	db $04 
	db $01 
	db $F8 
	db $00 
	db $2A 
	db $00 
	db $01 
	db $FC 
	db $01 
	db $FC 
	db $01 
	db $00 
	db $FF 
	db $00 
	db $2E 
	db $00 
	db $CA 
	db $00 
	db $01 
	db $FC 
	db $01 
	db $FC 
	db $01 
	db $00 
	db $FE 
	db $00 
	db $0E 
	db $00 
	db $4E 
	db $00 
	db $FF 
	db $FC 
	db $01 
	db $FC 
	db $01 
	db $00 
	db $E7 
	db $00 
	db $9E 
	db $00 
	db $FA 
	db $00 
	db $47 
	db $FC 
	db $01 
	db $FE 
	db $00 
	db $00 
	db $47 
	db $01 
	db $98 
	db $03 
	db $88 
	db $80 
	db $22 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $70 
	db $03 
	db $C8 
	db $03 
	db $78 
	db $00 
	db $90 
	db $FE 
	db $00 
	db $FE 
	db $00 
	db $00 
	db $98 
	db $07 
	db $F0 
	db $07 
	db $90 
	db $00 
	db $77 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $80 
	db $37 
	db $07 
	db $F0 
	db $03 
	db $F8 
	db $C0 
	db $0C 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $C0 
	db $19 
	db $01 
	db $BC 
	db $01 
	db $EC 
	db $C0 
	db $12 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $80 
	db $31 
	db $00 
	db $BE 
	db $00 
	db $F6 
	db $80 
	db $22 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $80 
	db $25 
	db $00 
	db $BE 
	db $00 
	db $F6 
	db $80 
	db $22 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $7F 
	db $00 
	db $FF 
	db $00 
	db $95 
	db $00 
	db $54 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $54 
	db $00 
	db $95 
	db $00 
	db $FF 
	db $00 
	db $7F 
	db $FF 
	db $00 
gfx_BazookaLadyRight:
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $E8 
	db $00 
	db $C0 
	db $17 
	db $3F 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $1F 
	db $C0 
	db $80 
	db $3F 
	db $C0 
	db $1F 
	db $0F 
	db $E0 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $1F 
	db $C0 
	db $80 
	db $3F 
	db $80 
	db $1F 
	db $0F 
	db $20 
	db $7F 
	db $00 
	db $3F 
	db $80 
	db $00 
	db $80 
	db $00 
	db $54 
	db $00 
	db $74 
	db $00 
	db $FF 
	db $3F 
	db $80 
	db $3F 
	db $80 
	db $00 
	db $80 
	db $00 
	db $53 
	db $00 
	db $70 
	db $00 
	db $7F 
	db $3F 
	db $80 
	db $3F 
	db $80 
	db $00 
	db $FF 
	db $00 
	db $72 
	db $00 
	db $79 
	db $00 
	db $E7 
	db $3F 
	db $80 
	db $3F 
	db $80 
	db $00 
	db $E2 
	db $00 
	db $5F 
	db $80 
	db $19 
	db $00 
	db $E2 
	db $7F 
	db $00 
	db $FF 
	db $00 
	db $01 
	db $44 
	db $C0 
	db $11 
	db $C0 
	db $13 
	db $00 
	db $0E 
	db $FF 
	db $00 
	db $7F 
function_C0B7:
	db $00 
	db $00 
	db $09 
	db $C0 
	db $1E 
	db $E0 
	db $0F 
	db $00 
	db $19 
	db $7F 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $EE 
	db $E0 
	db $09 
	db $E0 
	db $0F 
	db $01 
	db $EC 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $03 
	db $30 
	db $C0 
	db $1F 
	db $80 
	db $3D 
	db $03 
	db $98 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $03 
	db $48 
	db $80 
	db $37 
	db $00 
	db $7D 
	db $01 
	db $8C 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $01 
	db $44 
	db $00 
	db $6F 
	db $00 
	db $7D 
	db $01 
	db $A4 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $01 
	db $44 
	db $00 
	db $6F 
	db $00 
	db $FF 
	db $00 
	db $FE 
	db $FF 
	db $00 
	db $FF 
label_C0FF:
	db $00 
	db $00 
	db $2A 
	db $00 
	db $A9 
	db $00 
	db $A9 
	db $00 
	db $2A 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $FE 
	db $00 
	db $FF 
	db $FA 
	db $00 
	db $3F 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $0F 
	db $C0 
	db $F0 
	db $05 
	db $E0 
	db $0F 
	db $07 
	db $F0 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $03 
	db $F8 
	db $F0 
	db $07 
	db $E0 
	db $0F 
	db $07 
	db $F0 
	db $DF 
	db $00 
	db $0F 
	db $20 
	db $00 
	db $C8 
	db $C0 
	db $17 
	db $C0 
	db $1D 
	db $00 
	db $3F 
	db $0F 
	db $E0 
	db $0F 
	db $20 
	db $00 
	db $60 
	db $C0 
	db $15 
	db $C0 
	db $1C 
	db $00 
	db $FF 
	db $0F 
	db $E0 
	db $0F 
	db $E0 
	db $00 
	db $1F 
	db $C0 
	db $1C 
	db $C0 
	db $1C 
	db $00 
	db $B9 
	db $0F 
	db $E0 
	db $0F 
	db $A0 
	db $00 
	db $F8 
	db $C0 
	db $17 
	db $E0 
	db $06 
	db $00 
	db $78 
	db $1F 
	db $80 
	db $7F 
	db $00 
	db $00 
	db $51 
	db $F0 
	db $04 
	db $F0 
	db $04 
	db $00 
	db $C3 
	db $3F 
	db $80 
	db $1F 
	db $40 
	db $00 
	db $82 
	db $F0 
	db $07 
	db $F8 
	db $03 
	db $00 
	db $C6 
	db $1F 
	db $40 
	db $3F 
	db $80 
	db $00 
	db $FB 
	db $F8 
	db $03 
	db $F8 
	db $03 
	db $00 
	db $FB 
	db $7F 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $28 
	db $F8 
	db $02 
	db $F8 
	db $03 
	db $03 
	db $F8 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $01 
	db $CC 
	db $F0 
	db $07 
	db $E0 
	db $0F 
	db $00 
	db $66 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $D2 
	db $E0 
	db $0D 
	db $C0 
	db $1F 
	db $00 
	db $63 
	db $7F 
	db $00 
	db $7F 
	db $00 
label_C1A8:
	db $00 
	db $D1 
	db $C0 
	db $1B 
	db $C0 
	db $1F 
	db $00 
	db $69 
	db $7F 
	db $00 
	db $7F 
	db $00 
	db $00 
	db $D1 
	db $C0 
	db $1B 
	db $80 
	db $3F 
	db $00 
	db $FF 
	db $3F 
	db $80 
	db $3F 
	db $80 
	db $00 
	db $4A 
	db $80 
	db $2A 
	db $80 
	db $2A 
	db $00 
	db $4A 
	db $3F 
	db $80 
	db $3F 
	db $80 
	db $00 
	db $FF 
	db $80 
	db $3F 
	db $FE 
	db $00 
	db $8F 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $03 
	db $70 
	db $FC 
	db $01 
	db $F8 
	db $03 
	db $01 
	db $FC 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $FE 
	db $FC 
	db $01 
	db $F8 
	db $03 
	db $01 
	db $FC 
	db $FF 
	db $00 
	db $F7 
	db $00 
	db $00 
	db $F2 
	db $F8 
	db $01 
	db $F0 
	db $05 
	db $00 
	db $48 
	db $03 
	db $08 
	db $03 
	db $F8 
	db $00 
	db $5F 
	db $F0 
	db $07 
label_C200:
	db $F0 
	db $05 
	db $00 
	db $38 
	db $03 
	db $08 
	db $03 
	db $F8 
	db $00 
	db $07 
	db $F0 
	db $07 
	db $F0 
	db $07 
	db $00 
	db $2F 
	db $03 
	db $F8 
	db $03 
	db $78 
	db $00 
	db $9E 
	db $F0 
	db $07 
	db $F0 
	db $05 
	db $00 
	db $FE 
	db $03 
	db $28 
	db $07 
	db $20 
	db $00 
	db $9E 
	db $F8 
	db $01 
	db $FC 
	db $01 
	db $00 
	db $14 
	db $1F 
	db $40 
	db $0F 
	db $E0 
	db $00 
	db $30 
	db $FC 
	db $01 
	db $FC 
	db $01 
	db $00 
	db $E0 
	db $07 
	db $90 
	db $07 
	db $90 
	db $00 
	db $F1 
	db $FE 
	db $00 
	db $FE 
	db $00 
	db $00 
	db $FE 
	db $0F 
	db $E0 
	db $1F 
	db $C0 
	db $00 
	db $8A 
	db $FE 
	db $00 
	db $FE 
	db $00 
	db $00 
	db $FE 
	db $3F 
	db $00 
	db $7F 
	db $00 
	db $00 
	db $F3 
	db $FC 
	db $01 
	db $F8 
	db $03 
	db $00 
	db $D9 
	db $3F 
	db $80 
	db $3F 
	db $80 
	db $00 
	db $74 
	db $F8 
	db $03 
	db $F0 
	db $07 
	db $00 
	db $D8 
	db $1F 
	db $C0 
	db $1F 
	db $40 
	db $00 
	db $F4 
	db $F0 
	db $06 
	db $F0 
	db $07 
	db $00 
	db $DA 
	db $1F 
	db $40 
	db $1F 
	db $40 
	db $00 
	db $F4 
	db $F0 
	db $06 
	db $E0 
	db $0F 
	db $00 
	db $FF 
	db $0F 
	db $E0 
	db $0F 
	db $A0 
	db $00 
	db $92 
	db $E0 
	db $0A 
	db $E0 
	db $0A 
	db $00 
	db $92 
	db $0F 
	db $A0 
	db $0F 
	db $E0 
	db $00 
	db $FF 
	db $E0 
	db $0F 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $A3 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $5C 
	db $FF 
	db $00 
	db $7F 
	db $00 
	db $00 
	db $FF 
	db $FE 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $7F 
	db $3F 
	db $80 
	db $7F 
	db $00 
	db $00 
	db $FF 
	db $FE 
	db $00 
	db $FE 
	db $00 
	db $00 
	db $7C 
	db $3D 
	db $80 
	db $00 
	db $02 
	db $00 
	db $5E 
	db $FC 
	db $01 
	db $FC 
	db $01 
	db $00 
	db $DF 
	db $00 
	db $FE 
	db $00 
	db $02 
	db $00 
	db $4E 
	db $FC 
	db $01 
	db $FC 
	db $01 
	db $00 
	db $C1 
	db $00 
	db $FE 
	db $00 
	db $FE 
	db $00 
	db $CB 
	db $FC 
	db $01 
	db $FC 
	db $01 
	db $00 
	db $E7 
	db $00 
	db $9E 
	db $00 
	db $8A 
	db $00 
	db $7F 
	db $FC 
	db $01 
	db $FE 
	db $00 
	db $00 
	db $67 
	db $01 
	db $88 
	db $07 
	db $10 
	db $00 
	db $45 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $4C 
	db $03 
	db $38 
	db $01 
	db $24 
	db $00 
	db $78 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $80 
	db $3C 
	db $01 
	db $64 
	db $03 
	db $B8 
	db $80 
	db $27 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $80 
	db $3F 
	db $07 
	db $B0 
	db $0F 
	db $C0 
	db $00 
	db $7C 
	db $FF 
	db $00 
	db $FE 
	db $00 
	db $00 
	db $F6 
	db $0F 
	db $60 
	db $0F 
	db $20 
	db $00 
	db $DD 
	db $FE 
	db $00 
	db $FC 
	db $01 
	db $00 
	db $F6 
	db $07 
	db $30 
	db $07 
	db $10 
	db $00 
	db $BD 
	db $FC 
	db $01 
	db $FC 
	db $01 
	db $00 
	db $F6 
	db $07 
	db $90 
	db $07 
	db $10 
	db $00 
	db $BD 
	db $FC 
	db $01 
	db $F8 
	db $03 
	db $00 
	db $FF 
	db $03 
	db $F8 
	db $03 
	db $A8 
	db $00 
	db $A4 
	db $F8 
	db $02 
	db $F8 
	db $02 
	db $00 
	db $A4 
	db $03 
	db $A8 
	db $03 
	db $F8 
	db $00 
	db $FF 
	db $F8 
	db $03 
gfx_CobraWalkLeft:
	db $FF 
	db $00 
	db $0B 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $01 
	db $F4 
	db $FE 
	db $00 
	db $FC 
	db $01 
	db $00 
	db $FE 
	db $FF 
	db $00 
	db $7F 
	db $00 
	db $00 
	db $BF 
	db $F8 
	db $03 
	db $FC 
	db $01 
	db $00 
	db $0F 
	db $7F 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $FE 
	db $FC 
	db $01 
	db $FC 
	db $01 
	db $00 
	db $B7 
	db $7F 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $06 
	db $FC 
	db $01 
	db $FC 
	db $01 
	db $00 
	db $04 
	db $1F 
	db $00 
	db $07 
	db $E0 
	db $00 
	db $EF 
	db $FE 
	db $00 
	db $FE 
	db $00 
	db $00 
	db $CA 
	db $03 
	db $18 
	db $01 
	db $04 
	db $00 
	db $F4 
	db $FC 
	db $01 
	db $FC 
	db $01 
	db $00 
	db $AC 
	db $00 
	db $02 
	db $00 
	db $02 
	db $00 
	db $54 
	db $FC 
	db $01 
	db $F0 
	db $01 
	db $00 
	db $AA 
	db $00 
	db $22 
	db $00 
	db $E2 
	db $00 
	db $D7 
	db $E0 
	db $0E 
	db $C0 
	db $11 
	db $00 
	db $AF 
	db $00 
	db $62 
	db $00 
	db $42 
	db $00 
	db $D7 
	db $C0 
	db $11 
	db $C0 
	db $11 
	db $00 
	db $FE 
	db $00 
	db $42 
	db $01 
	db $44 
	db $00 
	db $FE 
	db $E0 
	db $0F 
	db $F0 
	db $03 
	db $00 
	db $FF 
	db $03 
	db $38 
	db $47 
	db $00 
	db $00 
	db $FF 
	db $F0 
	db $07 
	db $E0 
	db $0F 
	db $00 
	db $FF 
	db $7F 
	db $00 
	db $7F 
	db $00 
	db $00 
	db $DF 
	db $E0 
	db $0F 
	db $E0 
	db $0F 
	db $00 
	db $9F 
	db $7F 
	db $00 
	db $7F 
	db $00 
	db $00 
	db $DF 
	db $F0 
	db $07 
	db $F8 
	db $03 
	db $00 
	db $EF 
	db $3F 
	db $80 
	db $3F 
	db $80 
	db $00 
	db $EF 
	db $FC 
	db $00 
	db $FC 
	db $01 
	db $00 
	db $E7 
	db $3F 
	db $80 
	db $3F 
	db $80 
	db $10 
	db $C3 
	db $F8 
	db $03 
	db $F8 
	db $03 
	db $20 
	db $0F 
	db $1F 
	db $C0 
	db $1F 
	db $C0 
	db $C0 
	db $1F 
	db $FC 
	db $00 
	db $FF 
	db $00 
	db $85 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $7A 
	db $FF 
	db $00 
	db $FE 
	db $00 
	db $00 
	db $FF 
	db $7F 
	db $00 
	db $3F 
	db $80 
	db $00 
	db $DF 
	db $FC 
	db $01 
	db $FE 
	db $00 
	db $00 
	db $87 
	db $3F 
	db $80 
	db $7F 
	db $00 
	db $00 
	db $FF 
	db $FE 
	db $00 
	db $FE 
	db $00 
	db $00 
	db $DB 
	db $3F 
	db $80 
	db $7F 
	db $00 
	db $00 
	db $83 
	db $FE 
	db $00 
	db $FE 
	db $00 
	db $00 
	db $82 
	db $3F 
	db $00 
	db $0F 
	db $C0 
	db $00 
	db $77 
	db $FF 
	db $00 
	db $FE 
	db $00 
	db $00 
	db $EA 
	db $07 
	db $30 
	db $03 
	db $08 
	db $00 
	db $F4 
	db $FC 
	db $01 
	db $FC 
	db $01 
	db $00 
	db $AC 
	db $03 
	db $08 
	db $01 
	db $04 
	db $00 
	db $54 
	db $FC 
	db $01 
	db $FC 
	db $01 
	db $00 
	db $AA 
	db $01 
	db $04 
	db $01 
	db $04 
	db $00 
	db $D7 
	db $FE 
	db $00 
	db $FC 
	db $01 
	db $00 
	db $AF 
	db $01 
	db $C4 
	db $01 
	db $44 
	db $00 
	db $D7 
	db $F8 
	db $02 
	db $F0 
	db $04 
	db $00 
	db $7E 
	db $03 
	db $08 
	db $03 
	db $08 
	db $00 
	db $7E 
	db $F0 
	db $04 
	db $F8 
	db $02 
	db $00 
	db $FF 
	db $07 
	db $10 
	db $0F 
	db $E0 
	db $00 
	db $FF 
	db $FC 
	db $01 
	db $FC 
	db $01 
	db $00 
	db $FF 
	db $1F 
	db $80 
	db $3F 
	db $80 
	db $00 
	db $FF 
	db $F8 
	db $03 
	db $F8 
	db $03 
	db $00 
	db $FF 
	db $1F 
	db $C0 
	db $0F 
	db $E0 
	db $00 
	db $E7 
	db $F8 
	db $03 
	db $F0 
	db $07 
	db $10 
	db $C7 
	db $07 
	db $F0 
	db $01 
	db $F8 
	db $18 
	db $C3 
	db $F0 
	db $07 
	db $C0 
	db $07 
	db $3C 
	db $81 
	db $00 
	db $FE 
	db $00 
	db $7E 
	db $3E 
	db $80 
	db $80 
	db $3F 
	db $80 
	db $3F 
	db $7F 
	db $00 
	db $80 
	db $1E 
	db $81 
	db $3C 
	db $7F 
	db $00 
	db $C0 
	db $1F 
	db $FF 
	db $00 
	db $0B 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $01 
	db $F4 
	db $FE 
	db $00 
	db $FC 
	db $01 
	db $00 
	db $FE 
	db $FF 
	db $00 
	db $7F 
	db $00 
	db $00 
	db $BF 
	db $F8 
	db $03 
	db $FC 
	db $01 
	db $00 
	db $0F 
	db $7F 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $FE 
	db $FC 
	db $01 
	db $FC 
	db $01 
	db $00 
	db $B7 
	db $7F 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $06 
	db $FC 
	db $01 
	db $FC 
	db $01 
	db $00 
	db $04 
	db $3F 
	db $00 
	db $1F 
	db $C0 
	db $00 
	db $EF 
	db $FE 
	db $00 
	db $FE 
	db $00 
	db $00 
	db $CA 
	db $0F 
	db $20 
	db $07 
	db $10 
	db $00 
	db $F4 
	db $FC 
	db $01 
	db $FC 
	db $01 
	db $00 
	db $AC 
	db $07 
	db $10 
	db $07 
	db $10 
	db $00 
	db $54 
	db $FC 
	db $01 
	db $FC 
	db $01 
	db $00 
	db $AA 
	db $03 
	db $08 
	db $03 
	db $08 
	db $00 
	db $D7 
	db $FE 
	db $00 
	db $FE 
	db $00 
	db $00 
	db $AF 
	db $03 
	db $08 
	db $03 
	db $08 
	db $00 
	db $D9 
	db $FE 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $70 
	db $07 
	db $10 
	db $0F 
	db $60 
	db $00 
	db $70 
	db $FF 
	db $00 
	db $FE 
	db $00 
	db $00 
	db $F8 
	db $1F 
	db $80 
	db $3F 
	db $80 
	db $00 
	db $FF 
	db $FC 
	db $01 
	db $FC 
	db $01 
	db $00 
	db $FF 
	db $0F 
	db $00 
	db $07 
	db $70 
	db $00 
	db $FF 
	db $F8 
	db $03 
	db $F8 
	db $03 
	db $00 
	db $FF 
	db $07 
	db $F0 
	db $03 
	db $F8 
	db $00 
	db $EF 
	db $F8 
	db $03 
	db $F8 
	db $03 
	db $00 
	db $EF 
	db $03 
	db $F8 
	db $03 
	db $98 
	db $00 
	db $E7 
	db $FC 
	db $01 
	db $FC 
	db $01 
	db $08 
	db $E0 
	db $63 
	db $08 
	db $F7 
	db $00 
	db $07 
	db $F0 
	db $FE 
	db $00 
	db $FC 
	db $01 
	db $07 
	db $F0 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $07 
	db $F0 
	db $F8 
	db $03 
	db $FE 
	db $00 
	db $17 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $03 
	db $E8 
	db $FC 
	db $01 
	db $F8 
	db $03 
	db $01 
	db $FC 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $7E 
	db $F0 
	db $07 
	db $F8 
	db $02 
	db $00 
	db $1E 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $01 
	db $FC 
	db $F8 
	db $03 
	db $F8 
	db $03 
	db $00 
	db $6E 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $01 
	db $0C 
	db $F8 
	db $02 
	db $F8 
	db $02 
	db $00 
	db $08 
	db $3F 
	db $00 
	db $0F 
	db $C0 
	db $00 
	db $DF 
	db $FC 
	db $01 
	db $FE 
	db $00 
	db $00 
	db $DA 
	db $07 
	db $30 
	db $03 
	db $08 
	db $00 
	db $F4 
	db $FC 
	db $01 
	db $FC 
	db $01 
	db $00 
	db $AC 
	db $03 
	db $08 
	db $01 
	db $04 
	db $00 
	db $54 
	db $FC 
	db $01 
	db $FC 
	db $01 
	db $00 
	db $AA 
	db $01 
	db $04 
	db $01 
	db $04 
	db $00 
	db $D7 
	db $FE 
	db $00 
	db $FC 
	db $01 
	db $00 
	db $AF 
	db $01 
	db $C4 
	db $01 
	db $44 
	db $00 
	db $D7 
	db $F8 
	db $02 
	db $F0 
	db $04 
	db $00 
	db $7E 
	db $03 
	db $08 
	db $03 
	db $08 
	db $00 
	db $3E 
	db $F0 
	db $04 
	db $F8 
	db $02 
	db $00 
	db $7F 
	db $07 
	db $10 
	db $0F 
	db $E0 
	db $00 
	db $FF 
	db $FC 
	db $01 
	db $FE 
	db $00 
	db $00 
	db $FF 
	db $1F 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $FE 
	db $FE 
	db $00 
	db $FC 
	db $01 
	db $00 
	db $FC 
	db $FF 
	db $00 
	db $1F 
	db $00 
	db $00 
	db $FF 
	db $FC 
	db $01 
	db $FC 
	db $01 
	db $00 
	db $FF 
	db $0F 
	db $E0 
	db $0F 
	db $E0 
	db $00 
	db $FF 
	db $FE 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $3F 
	db $0F 
	db $E0 
	db $0F 
	db $E0 
	db $80 
	db $3C 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $7C 
	db $1F 
	db $C0 
	db $3F 
	db $80 
	db $00 
	db $FC 
	db $FE 
	db $00 
gfx_CobraWalkRight:
	db $FF 
	db $00 
	db $D0 
	db $00 
	db $FF 
	db $00 
	db $7F 
	db $00 
	db $80 
	db $2F 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $7F 
	db $3F 
	db $80 
	db $1F 
	db $C0 
	db $00 
	db $FD 
	db $FE 
	db $00 
	db $FE 
	db $00 
	db $00 
	db $F0 
	db $3F 
	db $80 
	db $3F 
	db $80 
	db $00 
	db $7F 
	db $FF 
	db $00 
	db $FE 
	db $00 
	db $00 
	db $ED 
	db $3F 
	db $80 
	db $3F 
	db $80 
	db $00 
	db $60 
	db $FF 
	db $00 
	db $F8 
	db $00 
	db $00 
	db $20 
	db $3F 
	db $80 
	db $7F 
	db $00 
	db $00 
	db $F7 
	db $E0 
	db $07 
	db $C0 
	db $18 
	db $00 
	db $53 
	db $7F 
	db $00 
	db $3F 
	db $80 
	db $00 
	db $2F 
	db $80 
	db $20 
	db $00 
	db $40 
	db $00 
	db $35 
	db $3F 
	db $80 
	db $3F 
	db $80 
	db $00 
	db $2A 
	db $00 
	db $40 
	db $00 
	db $44 
	db $00 
	db $55 
	db $0F 
	db $80 
	db $07 
	db $70 
	db $00 
	db $EB 
	db $00 
	db $47 
	db $00 
	db $46 
	db $00 
	db $F5 
	db $03 
	db $88 
	db $03 
	db $88 
	db $00 
	db $EB 
	db $00 
	db $42 
	db $00 
	db $42 
	db $00 
	db $7F 
	db $03 
	db $88 
	db $07 
	db $F0 
	db $00 
	db $7F 
	db $80 
	db $22 
	db $C0 
	db $1C 
	db $00 
	db $FF 
	db $0F 
	db $C0 
	db $0F 
	db $E0 
	db $00 
	db $FF 
	db $E2 
	db $00 
	db $FE 
	db $00 
	db $00 
	db $FF 
	db $07 
	db $F0 
	db $07 
	db $F0 
	db $00 
	db $FB 
	db $FE 
	db $00 
	db $FE 
	db $00 
	db $00 
	db $F9 
	db $07 
	db $F0 
	db $0F 
	db $E0 
	db $00 
	db $FB 
	db $FE 
	db $00 
	db $FC 
	db $01 
	db $00 
	db $F7 
	db $1F 
	db $C0 
	db $3F 
	db $00 
	db $00 
	db $F7 
	db $FC 
	db $01 
	db $FC 
	db $01 
	db $00 
	db $E7 
	db $3F 
	db $80 
	db $1F 
	db $C0 
	db $08 
	db $C3 
	db $FC 
	db $01 
	db $F8 
	db $03 
	db $04 
	db $F0 
	db $1F 
	db $C0 
	db $3F 
	db $00 
	db $03 
	db $F8 
	db $F8 
	db $03 
	db $FF 
	db $00 
	db $A1 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $5E 
	db $FF 
	db $00 
	db $FE 
	db $00 
	db $00 
	db $FF 
	db $7F 
	db $00 
	db $3F 
	db $80 
	db $00 
	db $FB 
	db $FC 
	db $01 
	db $FC 
	db $01 
	db $00 
	db $E1 
	db $7F 
	db $00 
	db $7F 
	db $00 
	db $00 
	db $FF 
	db $FE 
	db $00 
	db $FC 
	db $01 
	db $00 
	db $DB 
	db $7F 
	db $00 
	db $7F 
	db $00 
	db $00 
	db $C1 
	db $FE 
	db $00 
	db $FC 
	db $00 
	db $00 
	db $41 
	db $7F 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $EE 
	db $F0 
	db $03 
	db $E0 
	db $0C 
	db $00 
	db $57 
	db $7F 
	db $00 
	db $3F 
	db $80 
	db $00 
	db $2F 
	db $C0 
	db $10 
	db $C0 
	db $10 
	db $00 
	db $35 
	db $3F 
	db $80 
	db $3F 
	db $80 
	db $00 
	db $2A 
	db $80 
	db $20 
	db $80 
	db $20 
	db $00 
	db $55 
	db $3F 
	db $80 
	db $7F 
	db $00 
	db $00 
	db $EB 
	db $80 
	db $20 
	db $80 
	db $23 
	db $00 
	db $F5 
	db $3F 
	db $80 
	db $1F 
	db $40 
	db $00 
	db $EB 
	db $80 
	db $22 
	db $C0 
	db $10 
	db $00 
	db $7E 
	db $0F 
	db $20 
	db $0F 
	db $20 
	db $00 
	db $7E 
	db $C0 
	db $10 
	db $E0 
	db $08 
	db $00 
	db $FF 
	db $1F 
	db $40 
	db $3F 
	db $80 
	db $00 
	db $FF 
	db $F0 
	db $07 
	db $F8 
	db $01 
	db $00 
	db $FF 
	db $3F 
	db $80 
	db $1F 
	db $C0 
	db $00 
	db $FF 
	db $FC 
	db $01 
	db $F8 
	db $03 
	db $00 
	db $FF 
	db $1F 
	db $C0 
	db $1F 
	db $C0 
	db $00 
	db $E7 
	db $F0 
	db $07 
	db $E0 
	db $0F 
	db $08 
	db $E3 
	db $0F 
	db $E0 
	db $0F 
	db $E0 
	db $18 
	db $C3 
	db $80 
	db $1F 
	db $00 
	db $7F 
	db $3C 
	db $81 
	db $03 
	db $E0 
	db $01 
	db $FC 
	db $7C 
	db $01 
	db $00 
	db $7E 
	db $01 
	db $78 
	db $FE 
	db $00 
	db $01 
	db $FC 
	db $03 
	db $F8 
	db $FE 
	db $00 
	db $81 
	db $3C 
	db $FF 
	db $00 
	db $D0 
	db $00 
	db $FF 
	db $00 
	db $7F 
	db $00 
	db $80 
	db $2F 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $7F 
	db $3F 
	db $80 
	db $1F 
	db $C0 
	db $00 
	db $FD 
	db $FE 
	db $00 
	db $FE 
	db $00 
	db $00 
	db $F0 
	db $3F 
	db $80 
	db $3F 
	db $80 
	db $00 
	db $7F 
	db $FF 
	db $00 
	db $FE 
	db $00 
	db $00 
	db $ED 
	db $3F 
	db $80 
	db $3F 
	db $80 
	db $00 
	db $60 
	db $FF 
	db $00 
	db $FC 
	db $00 
	db $00 
data_C803:
	db $20 
	db $3F 
	db $80 
	db $7F 
	db $00 
	db $00 
	db $F7 
	db $F8 
	db $03 
	db $F0 
	db $04 
	db $00 
	db $53 
	db $7F 
	db $00 
	db $3F 
	db $80 
	db $00 
	db $2F 
	db $E0 
	db $08 
	db $E0 
	db $08 
	db $00 
	db $35 
	db $3F 
	db $80 
	db $3F 
	db $80 
	db $00 
	db $2A 
	db $E0 
	db $08 
	db $C0 
	db $10 
	db $00 
	db $55 
	db $3F 
	db $80 
	db $7F 
	db $00 
	db $00 
	db $EB 
	db $C0 
	db $10 
	db $C0 
	db $10 
	db $00 
	db $F5 
	db $7F 
	db $00 
	db $7F 
	db $00 
	db $00 
	db $9B 
data_C83A:
	db $C0 
	db $10 
	db $E0 
	db $08 
	db $00 
	db $0E 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $0E 
	db $F0 
	db $06 
	db $F8 
	db $01 
	db $00 
	db $1F 
	db $7F 
	db $00 
	db $3F 
	db $80 
	db $00 
	db $FF 
	db $FC 
	db $01 
	db $F0 
	db $00 
	db $00 
	db $FF 
	db $3F 
	db $80 
	db $1F 
	db $C0 
	db $00 
	db $FF 
	db $E0 
	db $0E 
	db $E0 
	db $0F 
	db $00 
	db $FF 
	db $1F 
label_C865:
	db $C0 
	db $1F 
	db $C0 
	db $00 
	db $F7 
	db $C0 
	db $1F 
	db $C0 
	db $1F 
	db $00 
	db $F7 
	db $1F 
label_C871:
	db $C0 
	db $3F 
	db $80 
	db $00 
	db $E7 
	db $C0 
	db $19 
	db $C6 
	db $10 
	db $10 
	db $07 
	db $3F 
	db $80 
	db $7F 
	db $00 
	db $E0 
	db $0F 
	db $EF 
label_C883:
	db $00 
	db $FF 
	db $00 
	db $E0 
	db $0F 
	db $3F 
	db $80 
	db $1F 
	db $C0 
	db $E0 
	db $0F 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $E8 
	db $00 
	db $7F 
	db $00 
	db $3F 
	db $80 
	db $C0 
label_C899:
	db $17 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $80 
	db $3F 
	db $1F 
	db $C0 
	db $0F 
	db $E0 
	db $00 
	db $7E 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $78 
	db $1F 
	db $40 
	db $1F 
	db $C0 
	db $80 
	db $3F 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
function_C8B7:
	db $76 
	db $1F 
	db $C0 
	db $1F 
	db $40 
	db $80 
	db $30 
	db $FF 
	db $00 
	db $FC 
	db $00 
	db $00 
	db $10 
	db $1F 
	db $40 
	db $3F 
	db $80 
	db $00 
	db $FB 
	db $F0 
	db $03 
	db $E0 
	db $0C 
	db $00 
	db $5B 
	db $7F 
	db $00 
	db $3F 
	db $80 
	db $00 
	db $2F 
	db $C0 
	db $10 
	db $C0 
	db $10 
	db $00 
label_C8DB:
	db $35 
	db $3F 
	db $80 
	db $3F 
	db $80 
	db $00 
	db $2A 
	db $80 
	db $20 
label_C8E4:
	db $80 
	db $20 
	db $00 
label_C8E7:
	db $55 
	db $3F 
label_C8E9:
	db $80 
	db $7F 
	db $00 
	db $00 
	db $EB 
	db $80 
	db $20 
	db $80 
	db $23 
	db $00 
	db $F5 
	db $3F 
	db $80 
	db $1F 
	db $40 
	db $00 
	db $EB 
	db $80 
	db $22 
	db $C0 
	db $10 
	db $00 
label_C8FF:
	db $7E 
	db $0F 
	db $20 
	db $0F 
	db $20 
	db $00 
label_C905:
	db $7C 
	db $C0 
	db $10 
	db $E0 
	db $08 
	db $00 
	db $FE 
	db $1F 
	db $40 
	db $3F 
	db $80 
	db $00 
	db $FF 
label_C912:
	db $F0 
	db $07 
	db $F8 
	db $00 
	db $00 
	db $FF 
	db $7F 
	db $00 
	db $7F 
Unnamed_1:
	db $00 
	db $00 
	db $7F 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $3F 
	db $3F 
	db $80 
	db $3F 
	db $80 
	db $00 
	db $FF 
	db $F8 
	db $00 
	db $F0 
	db $07 
	db $00 
	db $FF 
	db $3F 
	db $80 
	db $7F 
	db $00 
	db $00 
	db $FF 
	db $F0 
	db $07 
	db $F0 
	db $07 
	db $00 
label_C93B:
	db $FC 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $01 
	db $3C 
	db $F0 
	db $07 
	db $F8 
	db $03 
	db $00 
	db $3E 
	db $FF 
	db $00 
	db $7F 
	db $00 
	db $00 
	db $3F 
	db $FC 
	db $01 
gfx_CobraHeadbuttLeft:
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $7F 
	db $00 
	db $FA 
	db $00 
	db $F0 
	db $05 
	db $3F 
	db $80 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $1F 
	db $C0 
	db $E0 
	db $0F 
	db $C0 
	db $1F 
	db $0F 
	db $C0 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $07 
	db $F0 
	db $C0 
	db $1D 
	db $80 
	db $33 
	db $0F 
	db $20 
	db $FF 
	db $00 
	db $3F 
	db $00 
	db $00 
	db $10 
	db $80 
	db $37 
	db $C0 
	db $1C 
	db $00 
	db $0F 
	db $1F 
	db $C0 
	db $0F 
	db $20 
	db $00 
label_C989:
	db $5A 
	db $E0 
	db $04 
	db $F8 
	db $02 
	db $00 
	db $F4 
	db $07 
	db $10 
	db $07 
	db $10 
	db $00 
label_C995:
	db $AC 
	db $F0 
	db $07 
	db $F0 
	db $05 
	db $00 
	db $54 
	db $07 
	db $10 
	db $03 
	db $08 
	db $00 
	db $AA 
label_C9A2:
	db $F0 
	db $05 
	db $F0 
	db $02 
	db $00 
	db $D7 
	db $03 
	db $08 
	db $03 
	db $08 
	db $00 
	db $AF 
	db $E0 
	db $0E 
	db $C0 
	db $12 
	db $00 
	db $59 
	db $03 
	db $08 
	db $07 
	db $10 
	db $00 
label_C9B9:
	db $30 
	db $80 
	db $20 
	db $80 
	db $20 
	db $00 
label_C9BF:
	db $50 
	db $0F 
	db $60 
	db $1F 
	db $80 
	db $00 
	db $F8 
	db $C0 
	db $11 
	db $E0 
	db $0E 
	db $00 
	db $FF 
	db $3F 
	db $80 
	db $3F 
	db $80 
	db $00 
	db $FF 
	db $F0 
	db $01 
	db $FC 
	db $01 
	db $00 
	db $FF 
	db $0F 
	db $00 
	db $07 
Unnamed_2:
	db $70 
	db $00 
	db $FF 
	db $F8 
	db $03 
	db $F8 
	db $03 
	db $00 
	db $FF 
	db $07 
	db $F0 
	db $03 
	db $F8 
	db $00 
	db $EF 
	db $F8 
	db $03 
	db $F8 
	db $03 
	db $00 
	db $EF 
	db $03 
	db $F8 
	db $03 
	db $98 
	db $00 
	db $E7 
	db $FC 
	db $01 
	db $FC 
	db $01 
	db $08 
	db $E0 
	db $63 
	db $08 
	db $F7 
	db $00 
	db $07 
	db $F0 
	db $FE 
	db $00 
	db $FC 
	db $01 
	db $07 
	db $F0 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $07 
	db $F0 
	db $F8 
	db $03 

gfx_CobraHeadbuttRight:
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $5F 
	db $00 
	db $FE 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FC 
	db $01 
	db $0F 
	db $A0 
	db $07 
	db $F0 
	db $F8 
	db $03 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $F0 
	db $03 
	db $03 
	db $F8 
	db $03 
	db $B8 
	db $E0 
	db $0F 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $F0 
	db $04 
	db $01 
	db $CC 
	db $01 
	db $EC 
	db $00 
	db $08 
	db $FC 
	db $00 
	db $F8 
	db $03 
	db $00 
	db $F0 
	db $03 
	db $38 
	db $07 
	db $20 
	db $00 
	db $5A 
	db $F0 
	db $04 
	db $E0 
	db $08 
	db $00 
	db $2F 
	db $1F 
	db $40 
	db $0F 
	db $E0 
	db $00 
	db $35 
	db $E0 
	db $08 
	db $E0 
	db $08 
	db $00 
	db $2A 
	db $0F 
	db $A0 
	db $0F 
	db $A0 
	db $00 
	db $55 
	db $C0 
	db $10 
	db $C0 
	db $10 
	db $00 
	db $EB 
	db $0F 
	db $40 
	db $07 
	db $70 
	db $00 
	db $F5 
	db $C0 
	db $10 
	db $C0 
	db $10 
	db $00 
	db $9A 
	db $03 
	db $48 
	db $01 
	db $04 
	db $00 
	db $0C 
	db $E0 
	db $08 
	db $F0 
	db $06 
	db $00 
	db $0E 
	db $01 
	db $04 
	db $03 
	db $88 
	db $00 
	db $1F 
	db $F8 
	db $01 
	db $FC 
	db $01 
	db $00 
	db $FF 
	db $07 
	db $70 
	db $0F 
	db $80 
	db $00 
	db $FF 
	db $FC 
	db $01 
	db $F0 
	db $00 
	db $00 
	db $FF 
	db $3F 
	db $80 
	db $1F 
	db $C0 
	db $00 
	db $FF 
	db $E0 
	db $0E 
	db $E0 
	db $0F 
	db $00 
	db $FF 
	db $1F 
	db $C0 
	db $1F 
	db $C0 
	db $00 
	db $F7 
	db $C0 
	db $1F 
	db $C0 
	db $1F 
	db $00 
	db $F7 
	db $1F 
	db $C0 
	db $3F 
	db $80 
	db $00 
	db $E7 
	db $C0 
	db $19 
	db $C6 
	db $10 
	db $10 
	db $07 
	db $3F 
	db $80 
	db $7F 
	db $00 
	db $E0 
	db $0F 
	db $EF 
	db $00 
	db $FF 
	db $00 
	db $E0 
	db $0F 
	db $3F 
	db $80 
	db $1F 
	db $C0 
	db $E0 
	db $0F 
	db $FF 
	db $00 
	
gfx_CobraJumpLeft:
	db $FF 
	db $00 
	db $0B 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $01 
	db $F4 
	db $FE 
	db $00 
	db $FC 
	db $01 
	db $00 
	db $FE 
	db $FF 
	db $00 
	db $7F 
	db $00 
	db $00 
	db $BF 
	db $F8 
	db $03 
	db $FC 
	db $01 
	db $00 
	db $0F 
	db $7F 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $FE 
	db $FC 
	db $01 
	db $FC 
	db $01 
	db $00 
	db $B7 
	db $7F 
	db $00 
	db $1F 
	db $00 
	db $00 
	db $06 
	db $FC 
	db $01 
	db $FC 
	db $01 
	db $00 
	db $07 
	db $07 
	db $E0 
	db $03 
	db $18 
	db $00 
	db $EA 
	db $FC 
	db $01 
	db $F0 
	db $03 
	db $00 
	db $D4 
	db $01 
	db $04 
	db $00 
	db $02 
	db $00 
	db $AC 
	db $E0 
	db $0F 
	db $C0 
	db $13 
	db $00 
	db $54 
	db $00 
	db $02 
	db $00 
	db $22 
	db $00 
	db $AA 
	db $80 
	db $21 
	db $80 
	db $23 
	db $00 
	db $D7 
	db $00 
	db $E2 
	db $00 
	db $62 
	db $00 
	db $AE 
	db $C0 
	db $10 
	db $E0 
	db $0C 
	db $00 
	db $D6 
	db $00 
	db $42 
	db $00 
	db $42 
	db $01 
	db $FC 
	db $F0 
	db $03 
	db $FC 
	db $01 
	db $01 
	db $FC 
	db $01 
	db $44 
	db $83 
	db $38 
	db $00 
	db $FE 
	db $F8 
	db $03 
	db $F0 
	db $07 
	db $00 
	db $FE 
	db $C7 
	db $00 
	db $0F 
	db $20 
	db $00 
	db $FE 
	db $F0 
	db $07 
	db $E0 
	db $0F 
	db $00 
	db $9E 
	db $07 
	db $F0 
	db $07 
	db $F0 
	db $00 
	db $9F 
	db $F0 
	db $07 
	db $F0 
	db $07 
	db $20 
	db $8F 
	db $03 
	db $F8 
	db $03 
	db $D8 
	db $00 
	db $CF 
	db $F8 
	db $03 
	db $F8 
	db $01 
	db $10 
	db $C7 
	db $23 
	db $08 
	db $F7 
	db $00 
	db $08 
	db $E0 
	db $F0 
	db $07 
	db $E0 
	db $0F 
	db $0F 
	db $E0 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $0F 
	db $E0 
	db $F0 
	db $00 
	db $FF 
	db $00 
	db $1F 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 

gfx_CobraJumpRight:
	db $FF 
	db $00 
	db $D0 
	db $00 
	db $FF 
	db $00 
	db $7F 
	db $00 
	db $80 
	db $2F 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $7F 
	db $3F 
	db $80 
	db $1F 
	db $C0 
	db $00 
	db $FD 
	db $FE 
	db $00 
	db $FE 
	db $00 
	db $00 
	db $F0 
	db $3F 
	db $80 
	db $3F 
	db $80 
	db $00 
	db $7F 
	db $FF 
	db $00 
	db $FE 
	db $00 
	db $00 
	db $ED 
	db $3F 
	db $80 
	db $3F 
	db $80 
	db $00 
	db $60 
	db $F8 
	db $00 
	db $E0 
	db $07 
	db $00 
	db $E0 
	db $3F 
	db $80 
	db $3F 
	db $80 
	db $00 
	db $57 
	db $C0 
	db $18 
	db $80 
	db $20 
	db $00 
	db $2B 
	db $0F 
	db $C0 
	db $07 
	db $F0 
	db $00 
	db $35 
	db $00 
	db $40 
	db $00 
	db $40 
	db $00 
	db $2A 
	db $03 
	db $C8 
	db $01 
	db $84 
	db $00 
	db $55 
	db $00 
	db $44 
	db $00 
	db $47 
	db $00 
	db $EB 
	db $01 
	db $C4 
	db $03 
	db $08 
	db $00 
	db $75 
	db $00 
	db $46 
	db $00 
	db $42 
	db $00 
	db $6B 
	db $07 
	db $30 
	db $0F 
	db $C0 
	db $80 
	db $3F 
	db $00 
	db $42 
	db $80 
	db $22 
	db $80 
	db $3F 
	db $3F 
	db $80 
	db $1F 
	db $C0 
	db $00 
	db $7F 
	db $C1 
	db $1C 
	db $E3 
	db $00 
	db $00 
	db $7F 
	db $0F 
	db $E0 
	db $0F 
	db $E0 
	db $00 
	db $7F 
	db $F0 
	db $04 
	db $E0 
	db $0F 
	db $00 
	db $79 
	db $07 
	db $F0 
	db $0F 
	db $E0 
	db $00 
	db $F9 
	db $E0 
	db $0F 
	db $C0 
	db $1F 
	db $04 
	db $F1 
	db $0F 
	db $E0 
	db $1F 
	db $C0 
	db $00 
	db $F3 
	db $C0 
	db $1B 
	db $C4 
	db $10 
	db $08 
	db $E3 
	db $1F 
	db $80 
	db $0F 
	db $E0 
	db $10 
	db $07 
	db $EF 
	db $00 
	db $FF 
	db $00 
	db $F0 
	db $07 
	db $07 
	db $F0 
	db $0F 
	db $00 
	db $F0 
	db $07 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $F8 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 

gfx_CobraDuckLeft:
	db $FE 
	db $00 
	db $17 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $03 
	db $E8 
	db $FC 
	db $01 
	db $F8 
	db $03 
	db $01 
	db $FC 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $7E 
	db $F0 
	db $07 
	db $F8 
	db $02 
	db $00 
	db $1E 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $01 
	db $FC 
	db $F8 
	db $03 
	db $F8 
	db $03 
	db $00 
	db $6E 
	db $3F 
	db $00 
	db $0F 
	db $C0 
	db $00 
	db $0F 
	db $F8 
	db $02 
	db $F8 
	db $02 
	db $00 
	db $0A 
	db $07 
	db $30 
	db $03 
	db $08 
	db $00 
	db $DC 
	db $FC 
	db $01 
	db $FC 
	db $01 
	db $00 
	db $AC 
	db $03 
	db $08 
	db $01 
	db $04 
	db $00 
	db $54 
	db $E0 
	db $01 
	db $C0 
	db $1D 
	db $00 
	db $AA 
	db $01 
	db $04 
	db $01 
	db $04 
	db $00 
	db $D7 
	db $80 
	db $23 
	db $80 
	db $20 
	db $00 
	db $AF 
	db $01 
	db $C4 
	db $01 
	db $44 
	db $00 
	db $FF 
	db $80 
	db $20 
	db $C0 
	db $13 
	db $00 
	db $FE 
	db $03 
	db $08 
	db $03 
	db $08 
	db $00 
	db $BE 
	db $E0 
	db $0F 
	db $F0 
	db $03 
	db $00 
	db $7F 
	db $07 
	db $10 
	db $0F 
	db $E0 
	db $00 
	db $7D 
	db $F8 
	db $03 
	db $F0 
	db $06 
	db $00 
	db $FB 
	db $1F 
	db $C0 
	db $0F 
	db $E0 
	db $00 
	db $FF 
	db $F0 
	db $06 
	db $F0 
	db $06 
	db $00 
	db $FF 
	db $0F 
	db $E0 
	db $07 
	db $70 
	db $00 
	db $7E 
	db $F8 
	db $03 

gfx_CobraDuckRight:
	db $FF 
	db $00 
	db $E8 
	db $00 
	db $7F 
	db $00 
	db $3F 
	db $80 
	db $C0 
	db $17 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $80 
	db $3F 
	db $1F 
	db $C0 
	db $0F 
	db $E0 
	db $00 
	db $7E 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $78 
	db $1F 
	db $40 
	db $1F 
	db $C0 
	db $80 
	db $3F 
	db $FF 
	db $00 
	db $FC 
	db $00 
	db $00 
	db $76 
	db $1F 
	db $C0 
	db $1F 
	db $40 
	db $00 
	db $F0 
	db $F0 
	db $03 
	db $E0 
	db $0C 
	db $00 
	db $50 
	db $1F 
	db $40 
	db $3F 
	db $80 
	db $00 
	db $3B 
	db $C0 
	db $10 
	db $C0 
	db $10 
	db $00 
	db $35 
	db $3F 
	db $80 
	db $07 
	db $80 
	db $00 
	db $2A 
	db $80 
	db $20 
	db $80 
	db $20 
	db $00 
	db $55 
	db $03 
	db $B8 
	db $01 
	db $C4 
	db $00 
	db $EB 
	db $80 
	db $20 
	db $80 
	db $23 
	db $00 
	db $F5 
	db $01 
	db $04 
	db $01 
	db $04 
	db $00 
	db $FF 
	db $80 
	db $22 
	db $C0 
	db $10 
	db $00 
	db $7F 
	db $03 
	db $C8 
	db $07 
	db $F0 
	db $00 
	db $7D 
	db $C0 
	db $10 
	db $E0 
	db $08 
	db $00 
	db $FE 
	db $0F 
	db $C0 
	db $1F 
	db $C0 
	db $00 
	db $BE 
	db $F0 
	db $07 
	db $F8 
	db $03 
	db $00 
	db $DF 
	db $0F 
	db $60 
	db $0F 
	db $60 
	db $00 
	db $FF 
	db $F0 
	db $07 
	db $F0 
	db $07 
	db $00 
	db $FF 
	db $0F 
	db $60 
	db $1F 
	db $C0 
	db $00 
	db $7E 
	db $E0 
	db $0E 

gfx_GirlfriendLeft:
	db $F8 
	db $00 
	db $3F 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $0F 
	db $C0 
	db $E0 
	db $07 
	db $C0 
	db $1F 
	db $07 
	db $F0 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $07 
	db $F0 
	db $C0 
	db $1D 
	db $80 
	db $3A 
	db $03 
	db $F8 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $03 
	db $78 
	db $80 
	db $3B 
	db $C0 
	db $1B 
	db $07 
	db $30 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $07 
	db $70 
	db $C0 
	db $10 
	db $C0 
	db $16 
	db $03 
	db $38 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $03 
	db $70 
	db $E0 
	db $08 
	db $C0 
	db $1F 
	db $01 
	db $3C 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $66 
	db $E0 
	db $0E 
	db $C0 
	db $1B 
	db $00 
	db $83 
	db $7F 
	db $00 
	db $7F 
	db $00 
	db $00 
	db $11 
	db $C0 
	db $10 
	db $C0 
	db $10 
	db $00 
	db $19 
	db $3F 
	db $80 
	db $3F 
	db $80 
	db $00 
	db $3C 
	db $C0 
	db $19 
	db $80 
	db $3F 
	db $00 
	db $F4 
	db $3F 
	db $80 
	db $3F 
	db $80 
	db $00 
	db $36 
	db $00 
	db $7E 
	db $00 
	db $5B 
	db $00 
	db $FD 
	db $3F 
	db $80 
	db $3F 
	db $80 
	db $00 
	db $F8 
	db $00 
	db $57 
	db $80 
	db $2F 
	db $00 
	db $FD 
	db $3F 
	db $80 
	db $7F 
	db $00 
	db $00 
	db $FF 
	db $C0 
	db $0F 
	db $C0 
	db $1F 
	db $00 
	db $FE 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $FE 
	db $C0 
	db $1F 
	db $80 
	db $3F 
	db $00 
	db $FF 
	db $7F 
	db $00 
	db $7F 
	db $00 
	db $00 
	db $FF 
	db $80 
	db $3F 
	db $80 
	db $3F 
	db $00 
	db $FF 
	db $7F 
	db $00 
	db $3F 
	db $80 
	db $00 
	db $FF 
	db $00 
	db $7F 
	db $00 
	db $7F 
	db $00 
	db $FF 
	db $3F 
	db $80 
	db $3F 
	db $80 
	db $00 
	db $FF 
	db $00 
	db $7F 
	db $00 
	db $7F 
	db $00 
	db $FF 
	db $3F 
	db $80 
	db $7F 
	db $00 
	db $00 
	db $00 
	db $80 
	db $00 
	db $FE 
	db $00 
	db $0F 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $03 
	db $F0 
	db $F8 
	db $01 
	db $F0 
	db $07 
	db $01 
	db $FC 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $01 
	db $7C 
	db $F0 
	db $07 
	db $E0 
	db $0E 
	db $00 
	db $BE 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $DE 
	db $E0 
	db $0E 
	db $F0 
	db $06 
	db $01 
	db $CC 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $01 
	db $1C 
	db $F0 
	db $04 
	db $F0 
	db $05 
	db $00 
	db $8E 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $1C 
	db $F8 
	db $02 
	db $F0 
	db $07 
	db $00 
	db $CF 
	db $7F 
	db $00 
	db $3F 
	db $80 
	db $00 
	db $99 
	db $F8 
	db $03 
	db $F0 
	db $06 
	db $00 
	db $E0 
	db $1F 
	db $C0 
	db $1F 
	db $40 
	db $00 
	db $04 
	db $F0 
	db $04 
	db $F0 
	db $04 
	db $00 
	db $06 
	db $0F 
	db $60 
	db $0F 
	db $20 
	db $00 
	db $4F 
	db $F0 
	db $06 
	db $E0 
	db $0F 
	db $00 
	db $FD 
	db $0F 
	db $20 
	db $0F 
	db $A0 
	db $00 
	db $8D 
	db $C0 
	db $1F 
	db $C0 
	db $16 
	db $00 
	db $FF 
	db $0F 
	db $60 
	db $0F 
	db $20 
	db $00 
	db $FE 
	db $C0 
	db $15 
	db $E0 
	db $0B 
	db $00 
	db $FF 
	db $0F 
	db $60 
	db $1F 
	db $C0 
	db $00 
	db $FF 
	db $F0 
	db $03 
	db $F0 
	db $07 
	db $00 
	db $FF 
	db $3F 
	db $80 
	db $3F 
	db $80 
	db $00 
	db $FF 
	db $F0 
	db $07 
	db $E0 
	db $0F 
	db $00 
	db $FF 
	db $1F 
	db $C0 
	db $1F 
	db $C0 
	db $00 
	db $FF 
	db $E0 
	db $0F 
	db $E0 
	db $0F 
	db $00 
	db $FF 
	db $1F 
	db $C0 
	db $0F 
	db $E0 
	db $00 
	db $FF 
	db $C0 
	db $1F 
	db $C0 
	db $1F 
	db $00 
	db $FF 
	db $0F 
	db $E0 
	db $0F 
	db $E0 
	db $00 
	db $FF 
	db $C0 
	db $1F 
	db $C0 
	db $1F 
	db $00 
	db $FF 
	db $0F 
	db $E0 
	db $1F 
	db $00 
	db $00 
	db $00 
	db $E0 
	db $00 
	db $FF 
	db $00 
	db $83 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $7C 
	db $FE 
	db $00 
	db $FC 
	db $01 
	db $00 
	db $FF 
	db $7F 
	db $00 
	db $7F 
	db $00 
	db $00 
	db $DF 
	db $FC 
	db $01 
	db $F8 
	db $03 
	db $00 
	db $AF 
	db $3F 
	db $80 
	db $3F 
	db $80 
	db $00 
	db $B7 
	db $F8 
	db $03 
	db $FC 
	db $01 
	db $00 
	db $B3 
	db $7F 
	db $00 
	db $7F 
	db $00 
	db $00 
	db $07 
	db $FC 
	db $01 
	db $FC 
	db $01 
	db $00 
	db $63 
	db $3F 
	db $80 
	db $3F 
	db $00 
	db $00 
	db $87 
	db $FE 
	db $00 
	db $FC 
	db $01 
	db $00 
	db $F3 
	db $1F 
	db $C0 
	db $0F 
	db $60 
	db $00 
	db $E6 
	db $FE 
	db $00 
	db $FC 
	db $01 
	db $00 
	db $B8 
	db $07 
	db $30 
	db $07 
	db $10 
	db $00 
	db $01 
	db $FC 
	db $01 
	db $FC 
	db $01 
	db $00 
	db $01 
	db $03 
	db $98 
	db $03 
	db $C8 
	db $00 
	db $93 
	db $FC 
	db $01 
	db $F8 
	db $03 
	db $00 
	db $FF 
	db $03 
	db $48 
	db $03 
	db $68 
	db $00 
	db $E3 
	db $F0 
	db $07 
	db $F0 
	db $05 
	db $00 
	db $BF 
	db $03 
	db $D8 
	db $03 
	db $88 
	db $00 
	db $7F 
	db $F0 
	db $05 
	db $F8 
	db $02 
	db $00 
	db $FF 
	db $03 
	db $D8 
	db $07 
	db $F0 
	db $00 
	db $FF 
	db $FC 
	db $00 
	db $FC 
	db $01 
	db $00 
	db $FF 
	db $0F 
	db $E0 
	db $0F 
	db $E0 
	db $00 
	db $FF 
	db $FC 
	db $01 
	db $F8 
	db $03 
	db $00 
	db $FF 
	db $07 
	db $F0 
	db $07 
	db $F0 
	db $00 
	db $FF 
	db $F8 
	db $03 
	db $F8 
	db $03 
	db $00 
	db $FF 
	db $07 
	db $F0 
	db $03 
	db $F8 
	db $00 
	db $FF 
	db $F0 
	db $07 
	db $F0 
	db $07 
	db $00 
	db $FF 
	db $03 
	db $F8 
	db $03 
	db $F8 
	db $00 
	db $FF 
	db $F0 
	db $07 
	db $F0 
	db $07 
	db $00 
	db $FF 
	db $03 
	db $F8 
	db $07 
	db $00 
	db $00 
	db $00 
	db $F8 
	db $00 
	db $FF 
	db $00 
	db $E0 
	db $00 
	db $FF 
	db $00 
	db $3F 
	db $00 
	db $80 
	db $1F 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $7F 
	db $1F 
	db $C0 
	db $1F 
	db $C0 
	db $00 
	db $77 
	db $FF 
	db $00 
	db $FE 
	db $00 
	db $00 
	db $EB 
	db $0F 
	db $E0 
	db $0F 
	db $E0 
	db $00 
	db $ED 
	db $FE 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $6C 
	db $1F 
	db $C0 
	db $1F 
	db $C0 
	db $00 
	db $41 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $58 
	db $0F 
	db $E0 
	db $0F 
	db $C0 
	db $80 
	db $21 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $7C 
	db $07 
	db $F0 
	db $03 
	db $98 
	db $80 
	db $39 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $6E 
	db $01 
	db $0C 
	db $01 
	db $44 
	db $00 
	db $40 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $40 
	db $00 
	db $66 
	db $00 
	db $F2 
	db $00 
	db $64 
	db $FF 
	db $00 
	db $FE 
	db $00 
	db $00 
	db $FF 
	db $00 
	db $D2 
	db $00 
	db $DA 
	db $00 
	db $F8 
	db $FC 
	db $01 
	db $FC 
	db $01 
	db $00 
	db $6F 
	db $00 
	db $F6 
	db $00 
	db $E2 
	db $00 
	db $5F 
	db $FC 
	db $01 
	db $FE 
	db $00 
	db $00 
	db $BF 
	db $00 
	db $F6 
	db $01 
	db $FC 
	db $00 
	db $3F 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $7F 
	db $03 
	db $F8 
	db $03 
	db $F8 
	db $00 
	db $7F 
	db $FF 
	db $00 
	db $FE 
	db $00 
	db $00 
	db $FF 
	db $01 
	db $FC 
	db $01 
	db $FC 
	db $00 
	db $FF 
	db $FE 
	db $00 
	db $FE 
	db $00 
	db $00 
	db $FF 
	db $01 
	db $FC 
	db $00 
	db $FE 
	db $00 
	db $FF 
	db $FC 
	db $01 
	db $FC 
	db $01 
	db $00 
	db $FF 
	db $00 
	db $FE 
	db $00 
	db $FE 
	db $00 
	db $FF 
	db $FC 
	db $01 
	db $FC 
	db $01 
	db $00 
	db $FF 
	db $00 
	db $FE 
	db $01 
	db $00 
	db $00 
	db $00 
	db $FE 
	db $00 
gfx_GirlfriendRight:
	db $FF 
	db $00 
	db $07 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $01 
	db $F8 
	db $FC 
	db $00 
	db $F8 
	db $03 
	db $00 
	db $FE 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $EE 
	db $F8 
	db $03 
	db $F0 
	db $07 
	db $00 
	db $D7 
	db $7F 
	db $00 
	db $7F 
	db $00 
	db $00 
	db $B7 
	db $F0 
	db $07 
	db $F8 
	db $03 
	db $00 
	db $36 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $82 
	db $F8 
	db $03 
	db $F0 
	db $07 
	db $00 
	db $1A 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $01 
	db $84 
	db $F0 
	db $03 
	db $E0 
	db $0F 
	db $00 
	db $3E 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $01 
	db $9C 
	db $C0 
	db $19 
	db $80 
	db $30 
	db $00 
	db $76 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $02 
	db $80 
	db $22 
	db $00 
	db $66 
	db $00 
	db $02 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $26 
	db $00 
	db $4F 
	db $00 
	db $4B 
	db $00 
	db $FF 
	db $7F 
	db $00 
	db $3F 
	db $80 
	db $00 
	db $1F 
	db $00 
	db $5B 
	db $00 
	db $6F 
	db $00 
	db $F6 
	db $3F 
	db $80 
	db $3F 
	db $80 
	db $00 
	db $FA 
	db $00 
	db $47 
	db $00 
	db $6F 
	db $00 
	db $FD 
	db $7F 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $FC 
	db $80 
	db $3F 
	db $C0 
	db $1F 
	db $00 
	db $FE 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $FE 
	db $C0 
	db $1F 
	db $80 
	db $3F 
	db $00 
	db $FF 
	db $7F 
	db $00 
	db $7F 
	db $00 
	db $00 
	db $FF 
	db $80 
	db $3F 
	db $80 
	db $3F 
	db $00 
	db $FF 
	db $7F 
	db $00 
	db $3F 
	db $80 
	db $00 
	db $FF 
	db $00 
	db $7F 
	db $00 
	db $7F 
	db $00 
	db $FF 
	db $3F 
	db $80 
	db $3F 
	db $80 
	db $00 
	db $FF 
	db $00 
	db $7F 
	db $00 
	db $7F 
	db $00 
	db $FF 
	db $3F 
	db $80 
	db $7F 
	db $00 
	db $00 
	db $00 
	db $80 
	db $00 
	db $FF 
	db $00 
	db $C1 
	db $00 
	db $FF 
	db $00 
	db $7F 
	db $00 
	db $00 
	db $3E 
	db $FF 
	db $00 
	db $FE 
	db $00 
	db $00 
	db $FF 
	db $3F 
	db $80 
	db $3F 
	db $80 
	db $00 
	db $FB 
	db $FE 
	db $00 
	db $FC 
	db $01 
	db $00 
	db $F5 
	db $1F 
	db $C0 
	db $1F 
	db $C0 
	db $00 
	db $ED 
	db $FC 
	db $01 
	db $FE 
	db $00 
	db $00 
	db $CD 
	db $3F 
	db $80 
	db $3F 
	db $80 
	db $00 
	db $E0 
	db $FE 
	db $00 
	db $FC 
	db $01 
	db $00 
	db $C6 
	db $3F 
	db $80 
	db $7F 
	db $00 
	db $00 
	db $E1 
	db $FC 
	db $00 
	db $F8 
	db $03 
	db $00 
	db $CF 
	db $3F 
	db $80 
	db $7F 
	db $00 
	db $00 
	db $67 
	db $F0 
	db $06 
	db $E0 
	db $0C 
	db $00 
	db $1D 
	db $3F 
	db $80 
	db $3F 
	db $80 
	db $00 
	db $80 
	db $E0 
	db $08 
	db $C0 
	db $19 
	db $00 
	db $80 
	db $3F 
	db $80 
	db $3F 
	db $80 
	db $00 
	db $C9 
	db $C0 
	db $13 
	db $C0 
	db $12 
	db $00 
	db $FF 
	db $1F 
	db $C0 
	db $0F 
	db $E0 
	db $00 
	db $C7 
	db $C0 
	db $16 
	db $C0 
	db $1B 
	db $00 
	db $FD 
	db $0F 
	db $A0 
	db $0F 
	db $A0 
	db $00 
	db $FE 
	db $C0 
	db $11 
	db $C0 
	db $1B 
	db $00 
	db $FF 
	db $1F 
	db $40 
	db $3F 
	db $00 
	db $00 
	db $FF 
	db $E0 
	db $0F 
	db $F0 
	db $07 
	db $00 
	db $FF 
	db $3F 
	db $80 
	db $3F 
	db $80 
	db $00 
	db $FF 
	db $F0 
	db $07 
	db $E0 
	db $0F 
	db $00 
	db $FF 
	db $1F 
	db $C0 
	db $1F 
	db $C0 
	db $00 
	db $FF 
	db $E0 
	db $0F 
	db $E0 
	db $0F 
	db $00 
	db $FF 
	db $1F 
	db $C0 
	db $0F 
	db $E0 
	db $00 
	db $FF 
	db $C0 
	db $1F 
	db $C0 
	db $1F 
	db $00 
	db $FF 
	db $0F 
	db $E0 
	db $0F 
	db $E0 
	db $00 
	db $FF 
	db $C0 
	db $1F 
	db $C0 
	db $1F 
	db $00 
	db $FF 
	db $0F 
	db $E0 
	db $1F 
	db $00 
	db $00 
	db $00 
	db $E0 
	db $00 
	db $FF 
	db $00 
	db $F0 
	db $00 
	db $7F 
	db $00 
	db $1F 
	db $80 
	db $C0 
	db $0F 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $80 
	db $3F 
	db $0F 
	db $E0 
	db $0F 
	db $E0 
	db $80 
	db $3E 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $7D 
	db $07 
	db $70 
	db $07 
	db $70 
	db $00 
	db $7B 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $80 
	db $33 
	db $0F 
	db $60 
	db $0F 
	db $20 
	db $80 
	db $38 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $71 
	db $0F 
	db $A0 
	db $1F 
	db $40 
	db $00 
	db $38 
	db $FF 
	db $00 
	db $FE 
	db $00 
	db $00 
	db $F3 
	db $0F 
	db $E0 
	db $1F 
	db $C0 
	db $00 
	db $99 
	db $FC 
	db $01 
	db $F8 
	db $03 
	db $00 
	db $07 
	db $0F 
	db $60 
	db $0F 
	db $20 
	db $00 
	db $20 
	db $F8 
	db $02 
	db $F0 
	db $06 
	db $00 
	db $60 
	db $0F 
	db $20 
	db $0F 
	db $60 
	db $00 
	db $F2 
	db $F0 
	db $04 
	db $F0 
	db $04 
	db $00 
	db $BF 
	db $07 
	db $F0 
	db $03 
	db $F8 
	db $00 
	db $B1 
	db $F0 
	db $05 
	db $F0 
	db $06 
	db $00 
	db $FF 
	db $03 
	db $68 
	db $03 
	db $A8 
	db $00 
	db $7F 
	db $F0 
	db $04 
	db $F0 
	db $06 
	db $00 
	db $FF 
	db $07 
	db $D0 
	db $0F 
	db $C0 
	db $00 
	db $FF 
	db $F8 
	db $03 
	db $FC 
	db $01 
	db $00 
	db $FF 
	db $0F 
	db $E0 
	db $0F 
	db $E0 
	db $00 
	db $FF 
	db $FC 
	db $01 
	db $F8 
	db $03 
	db $00 
	db $FF 
	db $07 
	db $F0 
	db $07 
	db $F0 
	db $00 
	db $FF 
	db $F8 
	db $03 
	db $F8 
	db $03 
	db $00 
	db $FF 
	db $07 
	db $F0 
	db $03 
	db $F8 
	db $00 
	db $FF 
	db $F0 
	db $07 
	db $F0 
	db $07 
	db $00 
	db $FF 
	db $03 
	db $F8 
	db $03 
	db $F8 
	db $00 
	db $FF 
	db $F0 
	db $07 
	db $F0 
	db $07 
	db $00 
	db $FF 
	db $03 
	db $F8 
	db $07 
	db $00 
	db $00 
	db $00 
	db $F8 
	db $00 
	db $FF 
	db $00 
	db $FC 
	db $00 
	db $1F 
	db $00 
	db $07 
	db $E0 
	db $F0 
	db $03 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $E0 
	db $0F 
	db $03 
	db $F8 
	db $03 
	db $B8 
	db $E0 
	db $0F 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $C0 
	db $1F 
	db $01 
	db $5C 
	db $01 
	db $DC 
	db $C0 
	db $1E 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $E0 
	db $0C 
	db $03 
	db $D8 
	db $03 
	db $08 
	db $E0 
	db $0E 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $C0 
	db $1C 
	db $03 
	db $68 
	db $07 
	db $10 
	db $C0 
	db $0E 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $80 
	db $3C 
	db $03 
	db $F8 
	db $07 
	db $70 
	db $00 
	db $66 
	db $FF 
	db $00 
	db $FE 
	db $00 
	db $00 
	db $C1 
	db $03 
	db $D8 
	db $03 
	db $08 
	db $00 
	db $88 
	db $FE 
	db $00 
	db $FC 
	db $01 
	db $00 
	db $98 
	db $03 
	db $08 
	db $03 
	db $98 
	db $00 
	db $3C 
	db $FC 
	db $01 
	db $FC 
	db $01 
	db $00 
	db $2F 
	db $01 
	db $FC 
	db $00 
	db $7E 
	db $00 
	db $6C 
	db $FC 
	db $01 
	db $FC 
	db $01 
	db $00 
	db $BF 
	db $00 
	db $DA 
	db $00 
	db $EA 
	db $00 
	db $1F 
	db $FC 
	db $01 
	db $FC 
	db $01 
	db $00 
	db $BF 
	db $01 
	db $F4 
	db $03 
	db $F0 
	db $00 
	db $FF 
	db $FE 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $7F 
	db $03 
	db $F8 
	db $03 
	db $F8 
	db $00 
	db $7F 
	db $FF 
	db $00 
	db $FE 
	db $00 
	db $00 
	db $FF 
	db $01 
	db $FC 
function_D346:
	db $01 
	db $FC 
	db $00 
	db $FF 
	db $FE 
	db $00 
	db $FE 
	db $00 
	db $00 
	db $FF 
	db $01 
	db $FC 
	db $00 
	db $FE 
	db $00 
	db $FF 
	db $FC 
	db $01 
	db $FC 
	db $01 
	db $00 
	db $FF 
	db $00 
	db $FE 
	db $00 
	db $FE 
	db $00 
	db $FF 
	db $FC 
	db $01 
	db $FC 
	db $01 
	db $00 
	db $FF 
	db $00 
	db $FE 
	db $01 
	db $00 
	db $00 
	db $00 
	db $FE 
	db $00 
gfx_KnifeRight:
	db $FF 
	db $00 
	db $DF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $20 
	db $80 
	db $00 
	db $00 
	db $7F 
	db $00 
	db $DF 
	db $7F 
	db $00 
	db $3F 
	db $80 
	db $00 
	db $52 
	db $00 
	db $40 
	db $80 
	db $30 
	db $00 
	db $5F 
	db $3F 
	db $80 
	db $7F 
	db $00 
	db $00 
	db $DF 
	db $C0 
	db $0F 
	db $F0 
	db $00 
	db $00 
	db $20 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $DF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $F7 
	db $00 
	db $FF 
	db $00 
	db $3F 
	db $00 
	db $00 
	db $08 
	db $E0 
	db $00 
	db $C0 
	db $1F 
	db $00 
	db $F7 
	db $1F 
	db $C0 
	db $0F 
	db $A0 
	db $00 
	db $14 
	db $C0 
	db $10 
	db $E0 
	db $0C 
	db $00 
	db $17 
	db $0F 
	db $E0 
	db $1F 
	db $C0 
	db $00 
	db $F7 
	db $F0 
	db $03 
	db $FC 
	db $00 
	db $00 
	db $08 
	db $3F 
	db $00 
	db $FF 
	db $00 
	db $F7 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FD 
	db $00 
	db $FF 
	db $00 
	db $0F 
	db $00 
	db $00 
	db $02 
	db $F8 
	db $00 
	db $F0 
	db $07 
	db $00 
	db $FD 
	db $07 
	db $F0 
	db $03 
	db $28 
	db $00 
	db $05 
	db $F0 
	db $04 
	db $F8 
	db $03 
	db $00 
	db $05 
	db $03 
	db $F8 
	db $07 
	db $F0 
	db $00 
	db $FD 
	db $FC 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $02 
	db $0F 
	db $00 
	db $FF 
	db $00 
	db $FD 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $7F 
	db $00 
	db $03 
	db $80 
	db $00 
	db $00 
	db $FE 
	db $00 
	db $FC 
	db $01 
	db $00 
	db $FF 
	db $01 
	db $7C 
	db $00 
	db $4A 
	db $00 
	db $01 
	db $FC 
	db $01 
	db $FE 
	db $00 
	db $00 
	db $C1 
	db $00 
	db $7E 
	db $01 
	db $7C 
	db $00 
	db $3F 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $C0 
	db $00 
	db $03 
	db $80 
	db $7F 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
gfx_KnifeLeft:
	db $FE 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $7F 
	db $00 
	db $00 
	db $00 
	db $C0 
	db $01 
	db $80 
	db $3E 
	db $00 
	db $FF 
	db $3F 
	db $80 
	db $3F 
	db $80 
	db $00 
	db $80 
	db $00 
	db $52 
	db $00 
	db $7E 
	db $00 
	db $83 
	db $7F 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $FC 
	db $80 
	db $3E 
	db $C0 
	db $01 
	db $03 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FE 
	db $00 
	db $FF 
	db $00 
	db $BF 
	db $00 
	db $FF 
	db $00 
	db $1F 
	db $00 
	db $00 
	db $40 
	db $F0 
	db $00 
	db $E0 
	db $0F 
	db $00 
	db $BF 
	db $0F 
	db $E0 
	db $0F 
	db $20 
	db $00 
	db $A0 
	db $C0 
	db $14 
	db $C0 
	db $1F 
	db $00 
	db $A0 
	db $1F 
	db $C0 
	db $3F 
	db $00 
	db $00 
	db $BF 
	db $E0 
	db $0F 
	db $F0 
	db $00 
	db $00 
	db $40 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $BF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $EF 
	db $00 
	db $FF 
	db $00 
	db $07 
	db $00 
	db $00 
	db $10 
	db $FC 
	db $00 
	db $F8 
	db $03 
	db $00 
	db $EF 
	db $03 
	db $F8 
	db $03 
	db $08 
	db $00 
	db $28 
	db $F0 
	db $05 
	db $F0 
	db $07 
	db $00 
	db $E8 
	db $07 
	db $30 
	db $0F 
	db $C0 
	db $00 
	db $EF 
	db $F8 
	db $03 
	db $FC 
	db $00 
	db $00 
	db $10 
	db $3F 
	db $00 
	db $FF 
	db $00 
	db $EF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FB 
	db $00 
	db $FF 
	db $00 
	db $01 
	db $00 
	db $00 
	db $04 
	db $FF 
	db $00 
	db $FE 
	db $00 
	db $00 
	db $FB 
	db $00 
	db $FE 
	db $00 
	db $02 
	db $00 
	db $4A 
	db $FC 
	db $01 
	db $FC 
	db $01 
	db $00 
	db $FA 
	db $01 
	db $0C 
	db $03 
	db $F0 
	db $00 
	db $FB 
	db $FE 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $04 
	db $0F 
	db $00 
	db $FF 
	db $00 
	db $FB 
	db $00 
	db $FF 
	db $00 
gfx_PistolLeft:
	db $E0 
	db $00 
	db $07 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $03 
	db $78 
	db $C0 
	db $1E 
	db $C0 
	db $1F 
	db $03 
	db $F8 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $03 
	db $C8 
	db $E0 
	db $0F 
	db $F0 
	db $00 
	db $01 
	db $44 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $81 
	db $24 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $81 
	db $3C 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $C3 
	db $00 
	db $FF 
	db $00 
gfx_PistolRight:
	db $C0 
	db $00 
	db $0F 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $07 
	db $F0 
	db $80 
	db $3C 
	db $80 
	db $3F 
	db $07 
	db $F0 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $0F 
	db $E0 
	db $80 
	db $27 
	db $00 
	db $44 
	db $1F 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $03 
	db $48 
	db $03 
	db $78 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $87 
	db $00 
gfx_MachineGunLeft:
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $07 
	db $00 
	db $C0 
	db $00 
	db $80 
	db $3F 
	db $03 
	db $F8 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $01 
	db $D4 
	db $80 
	db $3F 
	db $C0 
	db $18 
	db $01 
	db $7C 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $03 
	db $F8 
	db $80 
	db $17 
	db $00 
	db $71 
	db $00 
	db $3C 
	db $FF 
	db $00 
	db $7F 
	db $00 
	db $00 
	db $33 
	db $80 
	db $1F 
	db $C0 
	db $10 
	db $00 
	db $D9 
	db $3F 
	db $80 
	db $3F 
	db $80 
	db $00 
	db $CC 
	db $C6 
	db $10 
	db $C6 
	db $10 
	db $10 
	db $C6 
	db $3F 
	db $80 
	db $3F 
	db $80 
	db $18 
	db $C3 
	db $EE 
	db $00 
	db $FE 
	db $00 
	db $1C 
	db $C0 
	db $7F 
	db $00 
	db $FF 
	db $00 
	db $1F 
	db $C0 
	db $FE 
	db $00 
	db $FF 
	db $00 
	db $3F 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
gfx_MachineGunRight:
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $03 
	db $00 
	db $E0 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $C0 
	db $1F 
	db $01 
	db $FC 
	db $01 
	db $FC 
	db $80 
	db $2B 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $80 
	db $3E 
	db $03 
	db $18 
	db $01 
	db $E8 
	db $C0 
	db $1F 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $3C 
	db $00 
	db $8E 
	db $01 
	db $F8 
	db $00 
	db $CC 
	db $FE 
	db $00 
	db $FC 
	db $01 
	db $00 
	db $9B 
	db $03 
	db $08 
	db $63 
	db $08 
	db $00 
	db $33 
	db $FC 
	db $01 
	db $FC 
	db $01 
	db $08 
	db $63 
	db $63 
	db $08 
	db $77 
	db $00 
	db $18 
	db $C3 
	db $FC 
	db $01 
	db $FE 
	db $00 
	db $38 
	db $03 
	db $7F 
	db $00 
	db $7F 
	db $00 
	db $F8 
	db $03 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FC 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
gfx_Quackometer:
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $03 
	db $F8 
	db $00 
	db $00 
	db $00 
	db $0F 
	db $FE 
	db $00 
	db $00 
	db $00 
	db $1F 
	db $82 
	db $00 
	db $00 
	db $00 
	db $3F 
	db $19 
	db $00 
	db $00 
	db $00 
	db $3F 
	db $3D 
	db $00 
	db $00 
	db $00 
	db $3F 
	db $39 
	db $00 
	db $00 
	db $00 
	db $7F 
	db $99 
	db $00 
	db $00 
	db $00 
	db $7F 
	db $CD 
	db $00 
	db $00 
	db $00 
	db $7F 
	db $F2 
	db $00 
	db $00 
	db $00 
	db $3F 
	db $FF 
	db $00 
	db $00 
	db $00 
	db $3F 
	db $DF 
	db $FC 
	db $00 
	db $00 
	db $1F 
	db $EF 
	db $F8 
	db $00 
	db $00 
	db $1F 
	db $F3 
	db $E0 
	db $01 
	db $00 
	db $0F 
	db $F8 
	db $00 
	db $00 
	db $00 
	db $07 
	db $FC 
	db $00 
	db $01 
	db $00 
	db $07 
	db $FE 
	db $00 
	db $01 
	db $10 
	db $03 
	db $FF 
	db $00 
	db $03 
	db $10 
	db $01 
	db $FF 
	db $C0 
	db $09 
	db $20 
	db $FC 
	db $FF 
	db $E0 
	db $0D 
	db $A7 
	db $FF 
	db $7F 
	db $F0 
	db $03 
	db $1F 
	db $FF 
	db $FF 
	db $F8 
	db $03 
	db $3F 
	db $FF 
	db $FF 
	db $F8 
	db $00 
	db $7F 
	db $FF 
	db $FF 
	db $FC 
	db $0C 
	db $FF 
	db $FF 
	db $FF 
	db $FC 
	db $00 
	db $FF 
	db $FF 
	db $FF 
	db $FE 
	db $01 
	db $FF 
	db $FF 
	db $FF 
	db $FE 
	db $01 
	db $FF 
	db $FF 
	db $FF 
	db $FE 
	db $03 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $03 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $03 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $03 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $03 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $01 
	db $FF 
	db $FF 
	db $FF 
	db $FE 
	db $01 
	db $FF 
	db $FF 
	db $FF 
	db $FE 
	db $00 
	db $FF 
	db $FF 
	db $FF 
	db $FC 
	db $00 
	db $3F 
	db $FF 
	db $FF 
	db $F0 
gfx_Explosion:
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $C7 
	db $38 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $80 
	db $6F 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $D1 
	db $FF 
	db $00 
	db $FE 
	db $01 
	db $00 
	db $83 
	db $FF 
	db $00 
	db $7F 
	db $80 
	db $00 
	db $09 
	db $FE 
	db $01 
	db $FC 
	db $03 
	db $00 
	db $78 
	db $7F 
	db $80 
	db $3F 
	db $C0 
	db $30 
	db $4C 
	db $FC 
	db $02 
	db $FC 
	db $02 
	db $38 
	db $46 
	db $3F 
	db $40 
	db $3F 
	db $40 
	db $10 
	db $6C 
	db $FC 
	db $02 
	db $FC 
	db $03 
	db $00 
	db $38 
	db $3F 
	db $40 
	db $7F 
	db $80 
	db $00 
	db $01 
	db $FE 
	db $01 
	db $FE 
	db $01 
	db $00 
	db $83 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $01 
	db $D6 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $83 
	db $7C 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
Unnamed_0_2:
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $7F 
	db $80 
	db $1C 
	db $E3 
	db $FE 
	db $01 
	db $FE 
	db $01 
	db $00 
	db $3E 
	db $7F 
	db $80 
	db $7F 
	db $80 
	db $00 
	db $8D 
	db $FE 
	db $01 
	db $F0 
	db $0F 
	db $00 
	db $01 
	db $FF 
	db $00 
	db $7F 
	db $80 
	db $00 
	db $01 
	db $F0 
	db $08 
	db $F0 
	db $0C 
	db $00 
	db $80 
	db $1F 
label_D79D:
	db $E0 
	db $1F 
	db $20 
	db $00 
label_D7A1:
	db $E4 
	db $F0 
	db $08 
	db $E0 
label_D7A5:
	db $19 
	db $40 
	db $BC 
	db $1F 
	db $60 
	db $07 
	db $38 
	db $F8 
	db $06 
	db $E0 
	db $13 
	db $E0 
	db $11 
	db $7C 
	db $83 
	db $07 
	db $08 
	db $07 
	db $18 
	db $78 
	db $86 
	db $E0 
	db $10 
	db $E0 
	db $18 
	db $60 
	db $9C 
	db $0F 
	db $10 
	db $0F 
	db $30 
	db $00 
label_D7C5:
	db $F4 
	db $F0 
	db $08 
	db $F0 
	db $08 
	db $00 
	db $60 
	db $1F 
	db $E0 
	db $7F 
	db $80 
	db $00 
	db $21 
	db $F0 
	db $0C 
	db $F8 
	db $05 
	db $00 
	db $01 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $8B 
	db $F8 
	db $07 
	db $FF 
	db $00 
	db $01 
	db $BE 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $1F 
label_D7E9:
	db $E0 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
label_D7FD:
	db $00 
	db $7F 
	db $80 
	db $32 
	db $CD 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $BA 
	db $3F 
	db $C0 
	db $3F 
	db $40 
	db $00 
label_D80D:
	db $88 
	db $F8 
	db $07 
	db $E0 
	db $1D 
	db $00 
	db $00 
	db $7F 
	db $80 
	db $1F 
	db $E0 
	db $00 
	db $00 
	db $E0 
	db $10 
	db $E0 
	db $18 
	db $00 
label_D81F:
	db $80 
	db $07 
	db $38 
	db $07 
	db $08 
	db $00 
	db $80 
	db $C0 
	db $30 
	db $C0 
	db $20 
	db $00 
label_D82B:
	db $E5 
	db $07 
label_D82D:
	db $18 
	db $0F 
	db $10 
	db $40 
label_D831:
	db $BE 
	db $C0 
	db $31 
	db $80 
	db $67 
	db $FC 
	db $03 
	db $03 
label_D839:
	db $1C 
	db $03 
	db $84 
	db $FE 
	db $01 
label_D83E:
	db $80 
	db $41 
	db $80 
	db $61 
	db $7E 
	db $81 
	db $01 
	db $86 
	db $01 
	db $02 
	db $7E 
	db $81 
	db $C0 
	db $20 
	db $C0 
	db $20 
	db $70 
	db $8F 
	db $01 
	db $06 
	db $03 
	db $84 
	db $60 
	db $9A 
	db $C0 
	db $30 
	db $E0 
	db $1C 
	db $00 
	db $F0 
	db $03 
	db $2C 
	db $07 
	db $38 
	db $00 
label_D861:
	db $60 
	db $E0 
	db $10 
	db $E0 
	db $18 
	db $00 
label_D867:
	db $20 
	db $1F 
	db $60 
	db $3F 
	db $C0 
	db $00 
	db $80 
	db $F0 
	db $0A 
	db $F0 
	db $0F 
	db $00 
	db $1D 
	db $7F 
	db $80 
	db $FF 
	db $00 
	db $09 
	db $B6 
	db $FE 
Unnamed_1_2:
	db $01 
	db $FF 
	db $00 
	db $1F 
	db $E0 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FE 
	db $01 
	db $32 
	db $CD 
	db $3F 
	db $C0 
	db $1F 
	db $20 
	db $00 
label_D891:
	db $7A 
	db $FC 
	db $03 
	db $F0 
	db $0F 
	db $00 
	db $08 
	db $1F 
	db $20 
	db $3F 
	db $40 
	db $00 
	db $00 
	db $C0 
	db $3A 
	db $C0 
	db $20 
	db $00 
	db $00 
	db $1F 
label_D8A5:
	db $60 
	db $07 
	db $38 
	db $00 
label_D8A9:
	db $80 
	db $E0 
	db $10 
	db $80 
	db $70 
	db $00 
	db $80 
	db $03 
	db $0C 
	db $03 
	db $04 
	db $00 
	db $C5 
	db $80 
	db $41 
	db $80 
	db $43 
	db $80 
	db $6E 
	db $03 
	db $0C 
	db $07 
label_D8BF:
	db $08 
	db $C4 
	db $3A 
	db $81 
	db $62 
	db $01 
	db $C2 
	db $FC 
	db $02 
	db $03 
	db $0C 
	db $01 
	db $06 
	db $FC 
	db $03 
	db $01 
	db $8E 
	db $80 
	db $43 
	db $FE 
	db $01 
	db $01 
	db $C2 
	db $00 
	db $83 
	db $FE 
	db $01 
label_D8DA:
	db $00 
	db $C1 
	db $00 
	db $81 
	db $7E 
	db $81 
	db $00 
label_D8E1:
	db $01 
	db $00 
	db $03 
	db $70 
	db $8F 
	db $00 
	db $C0 
	db $80 
	db $60 
	db $60 
	db $9A 
	db $01 
	db $82 
	db $01 
	db $96 
	db $00 
	db $F1 
	db $C0 
	db $39 
	db $C0 
	db $20 
	db $00 
label_D8F7:
	db $60 
	db $03 
	db $1C 
	db $0F 
	db $30 
	db $00 
label_D8FD:
	db $20 
	db $C0 
	db $30 
	db $E0 
	db $15 
	db $00 
	db $00 
	db $1F 
	db $A0 
	db $1F 
	db $E0 
	db $00 
	db $1D 
	db $E0 
	db $1F 
	db $F6 
	db $09 
	db $08 
	db $B7 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $1F 
	db $E0 
	db $FF 
	db $00 
gfx_PirateGuyLeft:
	db $E0 
	db $0F 
	db $1F 
	db $80 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $0F 
	db $60 
	db $C0 
	db $10 
	db $80 
	db $3F 
	db $07 
	db $F0 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $0F 
	db $60 
	db $80 
	db $36 
	db $00 
	db $5E 
	db $07 
	db $D0 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $03 
	db $18 
	db $00 
	db $4C 
	db $00 
	db $40 
	db $01 
	db $7C 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $C6 
	db $00 
	db $68 
	db $80 
	db $3D 
	db $00 
	db $82 
	db $FF 
	db $00 
	db $7F 
	db $00 
	db $00 
	db $81 
	db $80 
	db $25 
	db $80 
	db $23 
	db $00 
	db $01 
	db $7F 
	db $00 
	db $3F 
	db $80 
	db $00 
	db $80 
	db $00 
	db $77 
	db $00 
	db $7F 
	db $00 
	db $80 
	db $3F 
	db $80 
	db $3F 
	db $80 
	db $00 
	db $C0 
	db $00 
	db $7F 
	db $00 
	db $7F 
	db $00 
	db $E0 
	db $3F 
	db $80 
	db $3F 
	db $80 
	db $00 
	db $F8 
	db $80 
	db $3F 
	db $80 
	db $3F 
	db $00 
	db $F0 
	db $3F 
	db $80 
	db $3F 
	db $80 
	db $00 
	db $F0 
	db $C0 
	db $1F 
	db $E0 
	db $07 
	db $00 
	db $B0 
	db $3F 
	db $80 
	db $3F 
	db $80 
	db $00 
	db $40 
	db $E0 
	db $0C 
	db $C0 
	db $13 
	db $00 
	db $81 
	db $7F 
	db $00 
	db $7F 
	db $00 
	db $00 
	db $81 
	db $C0 
Unnamed_2_2:
	db $13 
	db $C0 
	db $11 
	db $00 
	db $81 
	db $7F 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $C2 
	db $E0 
	db $09 
	db $90 
	db $07 
	db $00 
	db $FC 
	db $3F 
	db $00 
	db $1F 
	db $C0 
	db $00 
	db $BF 
	db $08 
	db $63 
	db $00 
	db $53 
	db $40 
	db $0F 
	db $1F 
	db $40 
	db $1F 
	db $40 
	db $70 
	db $01 
	db $00 
	db $53 
	db $00 
	db $53 
	db $40 
	db $0E 
	db $1F 
	db $40 
	db $1F 
	db $C0 
	db $00 
	db $30 
	db $00 
label_D9CB:
	db $4F 
	db $00 
	db $61 
	db $00 
	db $21 
	db $3F 
	db $80 
	db $7F 
	db $00 
	db $C0 
	db $1F 
	db $80 
	db $3E 
	db $F8 
	db $03 
	db $07 
	db $E0 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $03 
	db $18 
	db $F0 
	db $04 
	db $E0 
	db $0F 
	db $01 
	db $FC 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $03 
	db $98 
	db $E0 
	db $08 
	db $C0 
	db $14 
	db $01 
	db $B4 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $06 
	db $C0 
	db $13 
	db $C0 
	db $10 
	db $00 
label_D9FF:
	db $1F 
	db $7F 
	db $00 
	db $3F 
	db $80 
	db $00 
	db $31 
	db $C0 
	db $1A 
	db $E0 
	db $0F 
	db $00 
	db $60 
	db $3F 
	db $80 
	db $1F 
	db $40 
	db $00 
	db $60 
	db $E0 
	db $09 
	db $E0 
	db $08 
	db $00 
	db $C0 
	db $1F 
	db $40 
	db $0F 
	db $20 
	db $00 
label_DA1D:
	db $E0 
	db $C0 
	db $1D 
	db $C0 
	db $1F 
	db $00 
	db $E0 
	db $0F 
	db $20 
	db $0F 
	db $20 
	db $00 
label_DA29:
	db $F0 
	db $C0 
	db $1F 
	db $C0 
	db $1F 
	db $00 
	db $F8 
	db $0F 
	db $20 
	db $0F 
	db $20 
	db $00 
label_DA35:
	db $FE 
	db $E0 
	db $0F 
	db $E0 
	db $0F 
	db $00 
	db $FC 
	db $0F 
	db $20 
	db $0F 
	db $20 
	db $00 
label_DA41:
	db $FC 
	db $F0 
	db $07 
	db $F8 
	db $01 
	db $00 
	db $EC 
	db $0F 
	db $20 
	db $0F 
	db $20 
	db $00 
label_DA4D:
	db $10 
	db $F8 
	db $03 
	db $F0 
	db $04 
	db $00 
	db $E0 
	db $1F 
	db $40 
	db $1F 
	db $40 
	db $00 
	db $E0 
label_DA5A:
	db $F0 
	db $04 
	db $F0 
	db $04 
	db $00 
	db $60 
	db $1F 
	db $40 
	db $3F 
	db $80 
	db $00 
	db $70 
	db $F8 
	db $02 
	db $E4 
	db $01 
	db $00 
	db $FF 
	db $0F 
	db $00 
	db $07 
	db $F0 
	db $00 
	db $EF 
	db $C2 
	db $18 
	db $C0 
	db $14 
	db $10 
	db $C3 
	db $07 
	db $D0 
	db $07 
	db $50 
	db $1C 
	db $C0 
	db $C0 
	db $14 
	db $C0 
	db $14 
	db $10 
	db $C3 
	db $07 
	db $90 
	db $07 
	db $30 
	db $00 
label_DA89:
	db $CC 
	db $C0 
	db $13 
	db $C0 
	db $18 
	db $00 
label_DA8F:
	db $48 
	db $0F 
	db $60 
	db $1F 
	db $C0 
	db $30 
	db $87 
	db $E0 
	db $0F 
	db $FE 
	db $00 
	db $01 
	db $F8 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $06 
	db $FC 
	db $01 
	db $F8 
	db $03 
	db $00 
	db $FF 
	db $7F 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $66 
	db $F8 
	db $03 
	db $F0 
	db $05 
	db $00 
	db $ED 
	db $7F 
	db $00 
	db $3F 
	db $80 
	db $00 
	db $C1 
	db $F0 
Unnamed_3_2:
	db $04 
	db $F0 
	db $04 
	db $00 
	db $07 
	db $1F 
	db $C0 
	db $0F 
	db $60 
	db $00 
	db $8C 
	db $F0 
	db $06 
	db $F8 
	db $03 
	db $00 
	db $D8 
	db $0F 
	db $20 
	db $07 
	db $10 
	db $00 
label_DAD1:
	db $58 
	db $F8 
	db $02 
	db $F8 
	db $02 
label_DAD6:
	db $00 
	db $30 
	db $07 
	db $10 
	db $03 
	db $08 
	db $00 
	db $78 
label_DADE:
	db $F0 
	db $07 
label_DAE0:
	db $F0 
	db $07 
	db $00 
	db $F8 
	db $03 
	db $08 
	db $03 
	db $08 
	db $00 
	db $FC 
	db $F0 
	db $07 
	db $F0 
	db $07 
	db $00 
	db $FE 
	db $03 
	db $08 
	db $03 
	db $88 
	db $00 
	db $FF 
	db $F8 
	db $03 
	db $F8 
	db $03 
	db $00 
	db $FF 
	db $03 
	db $08 
	db $03 
	db $08 
	db $00 
	db $FF 
	db $FC 
	db $01 
	db $FE 
	db $00 
	db $00 
	db $7B 
	db $03 
	db $08 
	db $03 
	db $08 
	db $00 
	db $C4 
	db $FE 
	db $00 
	db $FC 
	db $01 
	db $00 
	db $38 
	db $07 
	db $10 
	db $07 
label_DB17:
	db $10 
	db $00 
label_DB19:
	db $38 
	db $FC 
	db $01 
	db $FC 
	db $01 
label_DB1E:
	db $00 
	db $18 
	db $07 
	db $10 
	db $0F 
	db $20 
	db $00 
label_DB25:
	db $9C 
	db $FE 
	db $00 
label_DB28:
	db $FF 
	db $00 
	db $00 
	db $6F 
	db $1F 
	db $C0 
	db $3F 
	db $00 
	db $80 
	db $0E 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $F0 
	db $06 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $C0 
	db $06 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $3F 
	db $7F 
	db $00 
	db $3F 
	db $80 
	db $00 
	db $C3 
	db $FE 
	db $00 
	db $FE 
	db $00 
	db $00 
	db $80 
	db $1F 
	db $40 
	db $1F 
	db $C0 
	db $00 
	db $7F 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $80 
	db $3E 
	db $7F 
	db $00 
	db $3F 
	db $80 
	db $00 
	db $41 
	db $FF 
	db $00 
	db $FE 
	db $00 
	db $00 
	db $FF 
	db $1F 
	db $C0 
	db $3F 
	db $80 
	db $00 
	db $F9 
	db $FE 
	db $00 
	db $FC 
	db $01 
	db $00 
	db $7B 
	db $1F 
	db $40 
	db $0F 
label_DB77:
	db $60 
	db $00 
	db $30 
	db $FC 
	db $01 
	db $FC 
	db $01 
	db $00 
	db $01 
	db $07 
	db $F0 
	db $03 
	db $18 
	db $00 
label_DB85:
	db $A3 
	db $FC 
	db $01 
	db $FE 
	db $00 
	db $00 
	db $F6 
	db $03 
	db $08 
	db $01 
	db $04 
	db $00 
	db $96 
	db $FE 
	db $00 
	db $FE 
	db $00 
	db $00 
	db $8C 
	db $01 
	db $04 
	db $00 
	db $02 
	db $00 
	db $DE 
	db $FC 
	db $01 
	db $FC 
	db $01 
	db $00 
	db $FE 
	db $00 
	db $02 
	db $00 
	db $02 
	db $00 
	db $FF 
	db $FC 
	db $01 
	db $FC 
	db $01 
	db $00 
	db $FF 
	db $00 
	db $82 
	db $00 
	db $E2 
	db $00 
	db $FF 
	db $FE 
	db $00 
	db $FE 
	db $00 
	db $00 
	db $FF 
	db $00 
	db $C2 
	db $00 
	db $C2 
	db $00 
	db $7F 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $80 
	db $1E 
	db $00 
	db $C2 
	db $00 
	db $02 
	db $80 
	db $31 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $4E 
	db $01 
	db $04 
	db $01 
	db $04 
	db $00 
	db $4E 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $46 
	db $01 
	db $04 
	db $03 
	db $08 
	db $80 
	db $27 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $C0 
	db $1B 
	db $07 
	db $F0 
	db $0F 
	db $80 
	db $E0 
	db $03 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FC 
	db $01 
	db $3F 
	db $80 
	db $3F 
	db $80 
	db $F0 
	db $01 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $C0 
	db $0F 
	db $1F 
	db $C0 
	db $0F 
	db $E0 
	db $80 
	db $30 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $80 
	db $20 
	db $07 
	db $10 
	db $07 
	db $F0 
	db $C0 
	db $1F 
	db $FF 
	db $00 
gfx_PirateGuyRight:
	db $FE 
	db $00 
	db $01 
	db $7C 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $82 
	db $FC 
	db $01 
	db $F8 
	db $03 
	db $00 
	db $FF 
	db $7F 
	db $00 
	db $7F 
	db $00 
	db $00 
	db $9F 
	db $FC 
	db $01 
	db $F8 
	db $02 
	db $00 
	db $DE 
	db $3F 
	db $80 
	db $3F 
	db $80 
	db $00 
	db $0C 
	db $F0 
	db $06 
	db $E0 
	db $0F 
	db $00 
	db $80 
	db $3F 
	db $80 
	db $3F 
	db $80 
	db $00 
	db $C5 
	db $C0 
	db $18 
	db $C0 
	db $10 
	db $00 
	db $6F 
	db $7F 
	db $00 
	db $7F 
	db $00 
	db $00 
	db $69 
	db $80 
	db $20 
	db $80 
	db $20 
	db $00 
	db $31 
	db $7F 
	db $00 
	db $3F 
	db $80 
	db $00 
	db $7B 
	db $00 
	db $40 
	db $00 
	db $40 
	db $00 
	db $7F 
	db $3F 
	db $80 
	db $3F 
	db $80 
	db $00 
	db $FF 
	db $00 
	db $40 
	db $00 
	db $41 
	db $00 
	db $FF 
	db $3F 
	db $80 
	db $7F 
	db $00 
	db $00 
	db $FF 
	db $00 
	db $47 
	db $00 
	db $43 
	db $00 
	db $FF 
	db $7F 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $FE 
	db $00 
	db $43 
	db $00 
	db $43 
	db $01 
	db $78 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $01 
	db $8C 
	db $00 
	db $40 
	db $80 
	db $20 
	db $00 
	db $72 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $72 
	db $80 
	db $20 
	db $80 
	db $20 
	db $00 
	db $62 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $01 
	db $E4 
	db $C0 
	db $10 
	db $E0 
	db $0F 
	db $03 
	db $D8 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $07 
	db $C0 
	db $F0 
	db $01 
	db $FC 
	db $01 
	db $3F 
	db $80 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $0F 
	db $80 
	db $FC 
	db $01 
	db $F8 
	db $03 
	db $03 
	db $F0 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $01 
	db $0C 
	db $F0 
	db $07 
	db $E0 
	db $08 
	db $01 
	db $04 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $03 
	db $F8 
	db $E0 
	db $0F 
	db $FF 
	db $00 
	db $80 
	db $1F 
	db $7F 
	db $00 
	db $3F 
	db $80 
	db $00 
	db $60 
	db $FF 
	db $00 
	db $FE 
	db $00 
	db $00 
	db $FF 
	db $1F 
	db $C0 
	db $1F 
	db $C0 
	db $00 
	db $66 
	db $FF 
	db $00 
	db $FE 
	db $00 
	db $00 
	db $B7 
	db $0F 
	db $A0 
	db $0F 
	db $20 
	db $00 
	db $83 
	db $FC 
	db $01 
	db $F8 
	db $03 
	db $00 
	db $E0 
	db $0F 
	db $20 
	db $0F 
	db $60 
	db $00 
	db $31 
	db $F0 
	db $06 
	db $F0 
	db $04 
	db $00 
	db $1B 
	db $1F 
	db $C0 
	db $1F 
	db $40 
	db $00 
	db $1A 
	db $E0 
	db $08 
	db $E0 
	db $08 
	db $00 
	db $0C 
	db $1F 
	db $40 
	db $0F 
	db $E0 
	db $00 
	db $1E 
	db $C0 
	db $10 
	db $C0 
	db $10 
	db $00 
	db $1F 
	db $0F 
	db $E0 
	db $0F 
	db $E0 
	db $00 
	db $3F 
	db $C0 
	db $10 
	db $C0 
	db $10 
	db $00 
	db $7F 
	db $0F 
	db $E0 
	db $1F 
	db $C0 
	db $00 
	db $FF 
	db $C0 
	db $11 
	db $C0 
	db $10 
	db $00 
	db $FF 
	db $1F 
	db $C0 
	db $3F 
	db $80 
	db $00 
	db $FF 
	db $C0 
	db $10 
	db $C0 
	db $10 
	db $00 
	db $DE 
	db $7F 
	db $00 
	db $7F 
	db $00 
	db $00 
	db $23 
	db $C0 
	db $10 
	db $E0 
	db $08 
	db $00 
	db $1C 
	db $3F 
	db $80 
	db $3F 
	db $80 
	db $00 
	db $1C 
	db $E0 
	db $08 
	db $E0 
	db $08 
	db $00 
	db $18 
	db $3F 
	db $80 
	db $7F 
	db $00 
	db $00 
	db $39 
	db $F0 
	db $04 
	db $F8 
	db $03 
	db $00 
	db $F6 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $01 
	db $70 
	db $FC 
	db $00 
	db $FF 
	db $00 
	db $0F 
	db $60 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $03 
	db $60 
	db $FF 
	db $00 
	db $FE 
	db $00 
	db $00 
	db $FC 
	db $FF 
	db $00 
	db $7F 
	db $00 
	db $00 
	db $C3 
	db $FC 
	db $01 
	db $F8 
	db $02 
	db $00 
	db $01 
	db $7F 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $FE 
	db $F8 
	db $03 
	db $FF 
	db $00 
	db $E0 
	db $07 
	db $1F 
	db $C0 
	db $0F 
	db $20 
	db $C0 
	db $18 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $80 
	db $3F 
	db $07 
	db $F0 
	db $07 
	db $10 
	db $C0 
	db $19 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $80 
	db $2D 
	db $03 
	db $28 
	db $03 
	db $C8 
	db $00 
	db $60 
	db $FF 
	db $00 
	db $FE 
	db $00 
	db $00 
	db $F8 
	db $03 
	db $08 
	db $03 
	db $58 
	db $00 
	db $8C 
	db $FC 
	db $01 
	db $FC 
	db $01 
	db $00 
	db $06 
	db $07 
	db $F0 
	db $07 
	db $90 
	db $00 
	db $06 
	db $F8 
	db $02 
	db $F8 
	db $02 
	db $00 
	db $03 
	db $07 
	db $10 
	db $03 
	db $B8 
	db $00 
	db $07 
	db $F0 
	db $04 
	db $F0 
	db $04 
	db $00 
	db $07 
	db $03 
	db $F8 
	db $03 
	db $F8 
	db $00 
	db $0F 
	db $F0 
	db $04 
	db $F0 
	db $04 
	db $00 
	db $1F 
	db $03 
	db $F8 
	db $07 
	db $F0 
	db $00 
	db $7F 
	db $F0 
	db $04 
	db $F0 
	db $04 
	db $00 
	db $3F 
	db $07 
	db $F0 
	db $0F 
	db $E0 
	db $00 
	db $3F 
	db $F0 
	db $04 
	db $F0 
	db $04 
	db $00 
	db $37 
	db $1F 
	db $80 
	db $1F 
	db $C0 
	db $00 
	db $08 
	db $F0 
	db $04 
	db $F8 
	db $02 
	db $00 
	db $07 
	db $0F 
	db $20 
	db $0F 
	db $20 
	db $00 
	db $07 
	db $F8 
	db $02 
	db $F8 
	db $02 
	db $00 
	db $06 
	db $0F 
	db $20 
	db $1F 
	db $40 
	db $00 
	db $0E 
	db $FC 
	db $01 
	db $F0 
	db $00 
	db $00 
	db $FF 
	db $27 
	db $80 
	db $43 
	db $18 
	db $00 
	db $F7 
	db $E0 
	db $0F 
	db $E0 
	db $0B 
	db $08 
	db $C3 
	db $03 
	db $28 
	db $03 
	db $28 
	db $38 
	db $03 
	db $E0 
	db $0A 
	db $E0 
	db $09 
	db $08 
	db $C3 
	db $03 
	db $28 
	db $03 
	db $C8 
	db $00 
	db $33 
	db $E0 
	db $0C 
	db $F0 
	db $06 
	db $00 
	db $12 
	db $03 
	db $18 
	db $07 
	db $F0 
	db $0C 
	db $E1 
	db $F8 
	db $03 
	db $FF 
	db $00 
	db $F8 
	db $01 
	db $07 
	db $F0 
	db $03 
	db $08 
	db $F0 
	db $06 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $E0 
	db $0F 
	db $01 
	db $FC 
	db $01 
	db $6C 
	db $F0 
	db $06 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $E0 
	db $0B 
	db $00 
	db $7A 
	db $00 
	db $32 
	db $C0 
	db $18 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $80 
	db $3E 
	db $00 
	db $02 
	db $00 
	db $16 
	db $00 
	db $63 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $41 
	db $01 
	db $BC 
	db $01 
	db $A4 
	db $00 
	db $81 
	db $FE 
	db $00 
	db $FE 
	db $00 
	db $00 
	db $80 
	db $01 
	db $C4 
	db $00 
	db $EE 
	db $00 
	db $01 
	db $FC 
	db $01 
	db $FC 
	db $01 
	db $00 
	db $01 
	db $00 
	db $FE 
	db $00 
	db $FE 
	db $00 
	db $03 
	db $FC 
	db $01 
	db $FC 
	db $01 
	db $00 
	db $07 
	db $00 
	db $FE 
	db $01 
	db $FC 
	db $00 
	db $1F 
	db $FC 
	db $01 
	db $FC 
	db $01 
	db $00 
	db $0F 
	db $01 
	db $FC 
	db $03 
	db $F8 
	db $00 
	db $0F 
	db $FC 
	db $01 
	db $FC 
	db $01 
	db $00 
	db $0D 
	db $07 
	db $E0 
	db $07 
	db $30 
	db $00 
	db $02 
	db $FC 
	db $01 
	db $FE 
	db $00 
	db $00 
	db $81 
	db $03 
	db $C8 
	db $03 
	db $C8 
	db $00 
	db $81 
	db $FE 
	db $00 
	db $FE 
	db $00 
	db $00 
	db $81 
	db $03 
	db $88 
	db $07 
	db $90 
	db $00 
	db $43 
	db $FF 
	db $00 
	db $FC 
	db $00 
	db $00 
	db $3F 
	db $09 
	db $E0 
	db $10 
	db $C6 
	db $00 
	db $FD 
	db $F8 
	db $03 
	db $F8 
	db $02 
	db $02 
	db $F0 
	db $00 
	db $CA 
	db $00 
	db $CA 
	db $0E 
	db $80 
	db $F8 
	db $02 
	db $F8 
	db $02 
	db $02 
	db $70 
	db $00 
	db $CA 
	db $00 
	db $F2 
	db $00 
	db $0C 
	db $F8 
	db $03 
	db $FC 
	db $01 
	db $00 
	db $84 
	db $00 
	db $86 
	db $01 
	db $7C 
	db $03 
	db $F8 
	db $FE 
	db $00 
gfx_KnifeGuyLeft:
	db $FE 
	db $00 
	db $0F 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $03 
	db $F0 
	db $C0 
	db $01 
	db $80 
	db $3F 
	db $01 
	db $1C 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $0A 
	db $00 
	db $42 
	db $80 
	db $22 
	db $00 
	db $0A 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $01 
	db $1C 
	db $C0 
	db $1E 
	db $E0 
	db $04 
	db $03 
	db $30 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $03 
	db $38 
	db $C0 
	db $14 
	db $A0 
	db $0C 
	db $01 
	db $7C 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $03 
	db $38 
	db $00 
	db $5C 
	db $80 
	db $3C 
	db $01 
	db $3C 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $1E 
	db $80 
	db $3E 
	db $00 
	db $7E 
	db $00 
	db $0E 
	db $FF 
	db $00 
	db $7F 
	db $00 
	db $00 
	db $0F 
	db $80 
	db $3F 
	db $00 
	db $4F 
	db $00 
	db $9F 
	db $7F 
	db $00 
	db $7F 
	db $00 
	db $00 
	db $FF 
	db $00 
	db $6A 
	db $00 
	db $70 
	db $00 
	db $FF 
	db $7F 
	db $00 
	db $7F 
	db $00 
	db $00 
	db $FF 
	db $00 
	db $41 
	db $00 
	db $43 
	db $00 
	db $7E 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $80 
	db $3E 
	db $00 
	db $76 
	db $81 
	db $1C 
	db $00 
	db $7E 
	db $FF 
	db $00 
	db $7F 
	db $00 
	db $00 
	db $FF 
	db $E2 
	db $00 
	db $FC 
	db $01 
	db $00 
	db $FF 
	db $7F 
	db $00 
	db $7F 
	db $00 
	db $00 
	db $FF 
	db $F8 
	db $03 
	db $F8 
	db $03 
	db $00 
	db $FE 
	db $FF 
	db $00 
	db $3F 
	db $00 
	db $00 
	db $FF 
	db $F0 
	db $07 
	db $80 
	db $07 
	db $00 
	db $9F 
	db $1F 
	db $C0 
	db $1F 
	db $C0 
	db $20 
	db $8F 
	db $00 
	db $77 
	db $00 
	db $5F 
	db $20 
	db $8E 
	db $1F 
	db $40 
	db $1F 
	db $40 
	db $30 
	db $86 
	db $00 
	db $73 
	db $80 
	db $31 
	db $60 
	db $0D 
	db $1F 
	db $40 
	db $1F 
	db $C0 
	db $60 
	db $0F 
	db $C0 
	db $1F 
	db $FF 
	db $00 
	db $83 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $7C 
	db $F0 
	db $00 
	db $E0 
	db $0F 
	db $00 
	db $C7 
	db $7F 
	db $00 
	db $3F 
	db $80 
	db $00 
	db $82 
	db $C0 
	db $10 
	db $E0 
	db $08 
	db $00 
	db $82 
	db $3F 
	db $80 
	db $7F 
	db $00 
	db $00 
	db $87 
	db $F0 
	db $07 
	db $F8 
	db $01 
	db $00 
	db $0C 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $01 
	db $08 
	db $F8 
	db $01 
	db $F0 
	db $05 
	db $00 
	db $1E 
	db $FF 
	db $00 
	db $7F 
	db $00 
	db $00 
	db $0F 
	db $E8 
	db $03 
	db $C0 
	db $17 
	db $00 
	db $0F 
	db $7F 
	db $00 
	db $3F 
	db $80 
	db $00 
	db $87 
	db $E0 
	db $0F 
	db $E0 
	db $0F 
	db $00 
	db $83 
	db $3F 
	db $80 
	db $1F 
	db $C0 
	db $00 
	db $C3 
	db $C0 
	db $1F 
	db $E0 
	db $0F 
	db $00 
	db $E7 
	db $1F 
	db $C0 
	db $1F 
	db $C0 
	db $00 
	db $FF 
	db $C0 
	db $13 
	db $C0 
	db $1A 
	db $00 
	db $BF 
	db $1F 
	db $C0 
	db $1F 
	db $C0 
	db $00 
	db $3F 
	db $C0 
	db $1C 
	db $C0 
	db $10 
	db $00 
	db $7F 
	db $3F 
	db $80 
	db $3F 
	db $80 
	db $00 
	db $CF 
	db $C0 
	db $10 
	db $C0 
	db $1D 
	db $00 
	db $9F 
	db $3F 
	db $80 
	db $1F 
	db $C0 
	db $00 
	db $3F 
	db $E0 
	db $07 
	db $F8 
	db $00 
	db $00 
	db $7F 
	db $1F 
	db $C0 
	db $1F 
	db $C0 
	db $00 
	db $FF 
	db $FE 
	db $00 
	db $FE 
	db $00 
	db $00 
	db $FF 
	db $3F 
	db $80 
	db $0F 
	db $C0 
	db $00 
	db $FF 
	db $FC 
	db $01 
	db $E0 
	db $01 
	db $00 
	db $E7 
	db $07 
	db $F0 
	db $07 
	db $F0 
	db $08 
	db $E3 
	db $C0 
	db $1D 
	db $C0 
	db $17 
	db $08 
	db $E3 
	db $07 
	db $90 
	db $07 
	db $90 
	db $0C 
	db $E1 
	db $C0 
	db $1C 
	db $E0 
	db $0C 
	db $18 
	db $43 
	db $07 
	db $50 
	db $07 
	db $F0 
	db $18 
	db $C3 
	db $F0 
	db $07 
	db $FF 
	db $00 
	db $E0 
	db $00 
	db $FF 
	db $00 
	db $3F 
	db $00 
	db $00 
	db $1F 
	db $FC 
	db $00 
	db $F8 
	db $03 
	db $00 
	db $F1 
	db $1F 
	db $C0 
	db $0F 
	db $A0 
	db $00 
	db $20 
	db $F0 
	db $04 
	db $F8 
	db $02 
	db $00 
	db $20 
	db $0F 
	db $A0 
	db $1F 
	db $C0 
	db $00 
	db $E1 
	db $FC 
	db $01 
	db $FE 
	db $00 
	db $00 
	db $43 
	db $3F 
	db $00 
	db $3F 
	db $80 
	db $00 
	db $43 
	db $FC 
	db $01 
	db $FA 
	db $00 
	db $00 
	db $C7 
	db $1F 
	db $C0 
	db $3F 
	db $80 
	db $00 
	db $C3 
	db $F0 
	db $05 
	db $F8 
	db $03 
	db $00 
	db $C3 
	db $1F 
	db $C0 
	db $0F 
	db $E0 
	db $00 
	db $E1 
	db $F8 
	db $03 
	db $F0 
	db $07 
	db $00 
	db $E0 
	db $0F 
	db $E0 
	db $07 
	db $F0 
	db $00 
	db $F0 
	db $F8 
	db $03 
	db $F0 
	db $04 
	db $00 
	db $F9 
	db $07 
	db $F0 
	db $07 
	db $F0 
	db $00 
	db $AF 
	db $F0 
	db $06 
	db $F0 
	db $07 
	db $00 
	db $0F 
	db $07 
	db $F0 
	db $07 
	db $F0 
	db $00 
	db $1F 
	db $F0 
	db $04 
	db $F0 
	db $04 
	db $00 
	db $37 
	db $0F 
	db $E0 
	db $0F 
	db $E0 
	db $08 
	db $63 
	db $F0 
	db $07 
	db $F8 
	db $01 
	db $18 
	db $C3 
	db $0F 
	db $E0 
	db $07 
	db $F0 
	db $30 
	db $07 
	db $FE 
	db $00 
	db $FF 
	db $00 
	db $F0 
	db $07 
	db $07 
	db $F0 
	db $07 
	db $F0 
	db $E0 
	db $0F 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $E0 
	db $0F 
	db $0F 
	db $E0 
	db $1F 
	db $C0 
	db $E0 
	db $0F 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $F0 
	db $07 
	db $0F 
	db $E0 
	db $0F 
	db $E0 
	db $F0 
	db $07 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $F0 
	db $03 
	db $0F 
	db $E0 
	db $07 
	db $30 
	db $E0 
	db $0E 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $C0 
	db $1B 
	db $07 
	db $30 
	db $07 
	db $F0 
	db $C0 
	db $1F 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $F8 
	db $00 
	db $3F 
	db $00 
	db $0F 
	db $C0 
	db $00 
	db $07 
	db $FF 
	db $00 
	db $FE 
	db $00 
	db $00 
	db $FC 
	db $07 
	db $70 
	db $03 
	db $28 
	db $00 
	db $08 
	db $FC 
	db $01 
	db $FE 
	db $00 
	db $00 
	db $88 
	db $03 
	db $28 
	db $07 
	db $70 
	db $00 
	db $78 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $80 
	db $10 
	db $0F 
	db $C0 
	db $0F 
	db $E0 
	db $00 
	db $50 
	db $FF 
	db $00 
	db $FE 
	db $00 
	db $80 
	db $31 
	db $07 
	db $F0 
	db $0F 
	db $E0 
	db $00 
	db $70 
	db $FC 
	db $01 
	db $FE 
	db $00 
	db $00 
	db $F0 
	db $07 
	db $F0 
	db $03 
	db $78 
	db $00 
	db $F8 
	db $FE 
	db $00 
	db $FC 
	db $01 
	db $00 
	db $F8 
	db $03 
	db $38 
	db $01 
	db $3C 
	db $00 
	db $FC 
	db $FE 
	db $00 
	db $FC 
	db $01 
	db $00 
	db $3E 
	db $01 
	db $7C 
	db $01 
	db $FC 
	db $00 
	db $AB 
	db $FC 
	db $01 
	db $FC 
	db $01 
	db $00 
	db $C3 
	db $01 
	db $FC 
	db $01 
	db $FC 
	db $00 
	db $07 
	db $FC 
	db $01 
	db $FC 
	db $01 
	db $00 
	db $0D 
	db $03 
	db $F8 
	db $03 
	db $F8 
	db $02 
	db $D8 
	db $FC 
	db $01 
	db $FE 
	db $00 
	db $06 
	db $70 
	db $03 
	db $F8 
	db $01 
	db $FC 
	db $8C 
	db $01 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FC 
	db $01 
	db $01 
	db $FC 
	db $01 
	db $FC 
	db $F8 
	db $03 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $F8 
	db $03 
	db $03 
	db $F8 
	db $07 
	db $F0 
	db $F8 
	db $03 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FC 
	db $01 
	db $03 
	db $F8 
	db $03 
	db $F8 
	db $FC 
	db $01 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FC 
	db $00 
	db $03 
	db $F8 
	db $01 
	db $8C 
	db $F8 
	db $03 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $F0 
	db $06 
	db $01 
	db $CC 
	db $01 
	db $FC 
	db $F0 
	db $07 
	db $FF 
	db $00 
gfx_KnifeGuyRight:
	db $F8 
	db $00 
	db $3F 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $01 
	db $C0 
	db $E0 
	db $07 
	db $C0 
	db $1C 
	db $00 
	db $7E 
	db $FF 
	db $00 
	db $7F 
	db $00 
	db $00 
	db $21 
	db $80 
	db $28 
	db $80 
	db $28 
	db $00 
	db $22 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $01 
	db $3C 
	db $C0 
	db $1C 
	db $E0 
	db $06 
	db $03 
	db $10 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $01 
	db $14 
	db $E0 
	db $0E 
	db $C0 
	db $1F 
	db $02 
	db $18 
	db $FF 
	db $00 
	db $7F 
	db $00 
	db $00 
	db $1D 
	db $E0 
	db $0E 
	db $C0 
	db $1E 
	db $00 
	db $1E 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $3E 
	db $80 
	db $3C 
	db $80 
	db $38 
	db $00 
	db $3F 
	db $7F 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $7E 
	db $00 
	db $78 
	db $00 
	db $7C 
	db $00 
	db $F9 
	db $7F 
	db $00 
	db $7F 
	db $00 
	db $00 
	db $AB 
	db $00 
	db $7F 
	db $00 
	db $7F 
	db $00 
	db $87 
	db $7F 
	db $00 
	db $7F 
	db $00 
	db $00 
	db $C1 
	db $00 
	db $7F 
	db $80 
	db $3F 
	db $00 
	db $61 
	db $7F 
	db $00 
	db $7F 
	db $00 
	db $80 
	db $37 
	db $80 
	db $3E 
	db $80 
	db $3E 
	db $C0 
	db $1C 
	db $FF 
	db $00 
label_E296:
	db $FF 
	db $00 
	db $63 
	db $00 
	db $00 
	db $7F 
	db $00 
	db $7F 
	db $7F 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $3F 
	db $80 
	db $00 
	db $7F 
	db $80 
	db $3F 
	db $3F 
	db $80 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $3F 
	db $80 
	db $C0 
	db $1F 
	db $80 
	db $3F 
	db $7F 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $7F 
	db $00 
	db $80 
	db $3F 
	db $80 
	db $3E 
	db $7F 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $3F 
	db $80 
	db $00 
	db $63 
	db $00 
	db $66 
	db $1F 
	db $C0 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $1F 
	db $C0 
	db $00 
	db $7F 
	db $FE 
	db $00 
	db $0F 
	db $00 
	db $FF 
	db $00 
	db $7F 
	db $00 
	db $00 
	db $F0 
	db $F8 
	db $01 
	db $F0 
	db $07 
	db $00 
	db $1F 
	db $3F 
	db $80 
	db $1F 
	db $40 
	db $00 
	db $08 
	db $E0 
	db $0A 
	db $E0 
	db $0A 
	db $00 
	db $08 
	db $3F 
	db $80 
	db $7F 
	db $00 
	db $00 
	db $0F 
	db $F0 
	db $07 
	db $F8 
	db $01 
	db $00 
	db $84 
	db $FF 
	db $00 
	db $7F 
	db $00 
	db $00 
	db $85 
	db $F8 
	db $03 
	db $F0 
	db $07 
	db $00 
	db $C6 
	db $BF 
	db $00 
	db $1F 
	db $40 
	db $00 
	db $87 
	db $F8 
	db $03 
	db $F0 
	db $07 
	db $00 
	db $87 
	db $3F 
	db $80 
label_E31A:
	db $3F 
	db $80 
	db $00 
	db $0F 
	db $E0 
	db $0F 
	db $E0 
	db $0E 
	db $00 
	db $0F 
	db $1F 
	db $C0 
	db $3F 
	db $80 
	db $00 
	db $1F 
	db $C0 
	db $1E 
	db $C0 
	db $1F 
	db $00 
	db $3E 
	db $1F 
	db $40 
	db $1F 
	db $C0 
	db $00 
	db $EA 
	db $C0 
	db $1F 
	db $C0 
	db $1F 
	db $00 
	db $E1 
	db $1F 
	db $C0 
	db $1F 
	db $40 
	db $00 
	db $F0 
	db $C0 
	db $1F 
	db $E0 
	db $0F 
	db $00 
	db $D8 
	db $1F 
	db $40 
	db $1F 
	db $C0 
	db $20 
	db $8D 
	db $E0 
	db $0F 
	db $E0 
	db $0F 
	db $30 
	db $87 
	db $3F 
	db $00 
	db $FF 
	db $00 
label_E358:
	db $18 
	db $C0 
	db $C0 
	db $1F 
	db $C0 
	db $1F 
	db $1F 
	db $C0 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $0F 
	db $E0 
	db $C0 
	db $1F 
	db $E0 
	db $0F 
	db $0F 
	db $E0 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $0F 
	db $E0 
	db $F0 
	db $07 
	db $E0 
	db $0F 
	db $1F 
	db $C0 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $1F 
	db $C0 
	db $E0 
	db $0F 
	db $E0 
	db $0F 
	db $1F 
	db $80 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $0F 
	db $E0 
	db $C0 
	db $18 
	db $C0 
	db $19 
	db $07 
	db $B0 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $07 
	db $F0 
	db $C0 
	db $1F 
	db $FF 
	db $00 
	db $83 
	db $00 
	db $FF 
	db $00 
	db $1F 
	db $00 
	db $00 
	db $7C 
	db $FE 
	db $00 
	db $FC 
	db $01 
	db $00 
	db $C7 
	db $0F 
	db $E0 
	db $07 
	db $10 
	db $00 
	db $82 
	db $F8 
	db $02 
	db $F8 
	db $02 
	db $00 
	db $82 
	db $0F 
	db $20 
	db $1F 
	db $C0 
	db $00 
	db $C3 
	db $FC 
	db $01 
	db $FE 
	db $00 
	db $00 
	db $61 
	db $3F 
	db $00 
	db $3F 
	db $00 
	db $00 
	db $21 
	db $FF 
	db $00 
	db $FE 
	db $00 
	db $00 
	db $F1 
	db $1F 
	db $40 
	db $2F 
	db $80 
	db $00 
	db $E1 
	db $FC 
	db $01 
	db $FC 
	db $01 
	db $00 
	db $E1 
	db $07 
	db $D0 
	db $0F 
	db $E0 
	db $00 
	db $C3 
	db $F8 
	db $03 
	db $F8 
	db $03 
	db $00 
	db $83 
	db $0F 
	db $E0 
	db $07 
	db $F0 
	db $00 
	db $87 
	db $F0 
	db $07 
	db $F0 
	db $07 
	db $00 
	db $CF 
	db $0F 
	db $E0 
	db $07 
	db $90 
	db $00 
	db $FF 
	db $F0 
	db $07 
	db $F0 
	db $07 
	db $00 
	db $FA 
	db $07 
	db $B0 
	db $07 
	db $70 
	db $00 
	db $F8 
	db $F0 
	db $07 
	db $F8 
	db $03 
	db $00 
	db $FC 
	db $07 
	db $10 
	db $07 
	db $10 
	db $00 
	db $E6 
	db $F8 
	db $03 
	db $F8 
	db $03 
	db $00 
	db $F3 
	db $07 
	db $70 
	db $0F 
	db $C0 
	db $00 
	db $F9 
	db $F0 
	db $07 
	db $F0 
	db $07 
	db $00 
	db $FC 
	db $3F 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $FE 
	db $F0 
	db $07 
	db $F8 
	db $03 
	db $00 
	db $FE 
	db $FF 
	db $00 
	db $7F 
	db $00 
	db $00 
	db $FF 
	db $E0 
	db $07 
	db $C0 
	db $1F 
	db $00 
	db $CF 
	db $0F 
	db $00 
	db $07 
	db $70 
	db $20 
	db $8F 
	db $C0 
	db $1F 
	db $C0 
	db $13 
	db $20 
	db $8F 
	db $07 
	db $D0 
	db $07 
	db $70 
	db $60 
	db $0E 
	db $C0 
	db $13 
	db $C0 
	db $15 
	db $30 
	db $84 
	db $0F 
	db $60 
	db $1F 
	db $C0 
	db $30 
	db $87 
	db $C0 
	db $1F 
	db $FF 
	db $00 
	db $E0 
	db $00 
	db $FF 
	db $00 
	db $07 
	db $00 
	db $80 
	db $1F 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $71 
	db $03 
	db $F8 
	db $01 
	db $84 
	db $00 
	db $A0 
	db $FE 
	db $00 
	db $FE 
	db $00 
	db $00 
	db $A0 
	db $03 
	db $88 
	db $07 
	db $F0 
	db $00 
	db $70 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $80 
	db $18 
	db $0F 
	db $40 
	db $07 
	db $50 
	db $80 
	db $38 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $7C 
	db $0B 
	db $60 
	db $01 
	db $74 
	db $80 
	db $38 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $78 
	db $03 
	db $78 
	db $03 
	db $F8 
	db $00 
	db $F0 
	db $FE 
	db $00 
	db $FE 
	db $00 
	db $00 
	db $E0 
	db $01 
	db $FC 
	db $03 
	db $F8 
	db $00 
	db $E1 
	db $FC 
	db $01 
	db $FC 
	db $01 
	db $00 
	db $F3 
	db $01 
	db $E4 
	db $01 
	db $AC 
	db $00 
	db $FE 
	db $FC 
	db $01 
	db $FC 
	db $01 
	db $00 
	db $FE 
	db $01 
	db $1C 
	db $01 
	db $04 
	db $00 
	db $FF 
	db $FC 
	db $01 
	db $FE 
	db $00 
	db $00 
	db $FD 
	db $01 
	db $84 
	db $01 
	db $DC 
	db $02 
	db $F8 
	db $FE 
	db $00 
	db $FE 
	db $00 
	db $01 
	db $FC 
	db $03 
	db $70 
	db $8F 
	db $00 
	db $00 
	db $FE 
	db $FC 
	db $01 
	db $FC 
	db $01 
	db $00 
	db $FF 
	db $7F 
	db $00 
	db $3F 
	db $80 
	db $00 
	db $FF 
	db $FC 
	db $01 
	db $FE 
	db $00 
	db $00 
	db $FF 
	db $3F 
	db $80 
	db $1F 
	db $C0 
	db $00 
	db $FF 
	db $F8 
	db $01 
	db $F0 
	db $07 
	db $00 
	db $F3 
	db $03 
	db $C0 
	db $01 
	db $DC 
	db $08 
	db $E3 
	db $F0 
	db $07 
	db $F0 
	db $04 
	db $08 
	db $E3 
	db $01 
	db $F4 
	db $01 
	db $9C 
	db $18 
	db $C3 
	db $F0 
	db $04 
	db $F0 
	db $05 
	db $0C 
	db $61 
	db $03 
	db $18 
	db $07 
	db $F0 
	db $0C 
	db $E1 
	db $F0 
	db $07 
gfx_Glove:
	db $00 
	db $1F 
	db $00 
	db $00 
	db $FF 
	db $C0 
	db $03 
	db $FF 
	db $F0 
	db $07 
	db $FF 
	db $F0 
	db $07 
	db $FF 
	db $F8 
	db $0F 
	db $FF 
	db $F8 
	db $0F 
	db $FE 
	db $38 
	db $0F 
	db $F9 
	db $C8 
	db $0F 
	db $F7 
	db $F0 
	db $07 
	db $EF 
	db $F0 
	db $07 
	db $CF 
	db $F8 
	db $03 
	db $8F 
	db $F8 
	db $00 
	db $47 
	db $78 
	db $02 
	db $A0 
	db $7C 
	db $07 
	db $D4 
	db $F8 
	db $07 
	db $EB 
	db $F8 
	db $07 
	db $D7 
	db $F8 
	db $03 
	db $FF 
	db $F0 
	db $03 
	db $FF 
	db $F0 
	db $01 
	db $FF 
	db $C0 
	db $02 
	db $FF 
	db $A0 
	db $03 
	db $AE 
	db $E0 
	db $01 
	db $FF 
	db $C0 
	db $00 
	db $7F 
	db $00 
gfx_UseYourHead:
	db $00 
	db $00 
	db $1E 
	db $B0 
	db $00 
	db $00 
	db $01 
	db $80 
	db $7B 
	db $7C 
	db $01 
	db $80 
	db $33 
	db $C0 
	db $5C 
	db $EE 
	db $03 
	db $CC 
	db $7B 
	db $CC 
	db $D7 
	db $D5 
	db $33 
	db $DE 
	db $7B 
	db $DE 
	db $FB 
	db $87 
	db $7B 
	db $DE 
	db $7B 
	db $DE 
	db $90 
	db $1B 
	db $7B 
	db $DE 
	db $79 
	db $9E 
	db $20 
	db $05 
	db $79 
	db $9E 
	db $33 
	db $DE 
	db $00 
	db $76 
	db $7B 
	db $CC 
	db $7B 
	db $CC 
	db $00 
	db $0A 
	db $33 
	db $DE 
	db $7B 
	db $DE 
	db $03 
	db $BC 
	db $7B 
	db $DE 
	db $61 
	db $9E 
	db $00 
	db $68 
	db $79 
	db $86 
	db $40 
	db $DE 
	db $05 
	db $D0 
	db $7B 
	db $02 
	db $22 
	db $CC 
	db $13 
	db $E0 
	db $33 
	db $44 
	db $7E 
	db $5E 
	db $0E 
	db $80 
	db $7A 
	db $7E 
	db $7C 
	db $AE 
	db $1D 
	db $00 
	db $75 
	db $3E 
	db $F1 
	db $74 
	db $3E 
	db $00 
	db $2E 
	db $8F 
	db $F8 
	db $AE 
	db $74 
	db $00 
	db $75 
	db $1F 
	db $F5 
	db $56 
	db $78 
	db $00 
	db $6A 
	db $AF 
	db $FA 
	db $BE 
	db $F8 
	db $00 
	db $7D 
	db $5F 
	db $FF 
	db $5E 
	db $F4 
	db $00 
	db $7A 
	db $FF 
	db $7F 
	db $FC 
	db $FB 
	db $70 
	db $3F 
	db $FE 
	db $7F 
	db $7C 
	db $7F 
	db $EE 
	db $3E 
	db $FE 
	db $3F 
	db $F8 
	db $7F 
	db $FF 
	db $1F 
	db $FC 
	db $0E 
	db $D0 
	db $1F 
	db $FE 
	db $0B 
	db $70 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $A4 
	db $E2 
	db $92 
	db $B0 
	db $AE 
	db $4C 
	db $AA 
	db $82 
	db $AA 
	db $A8 
	db $A8 
	db $AA 
	db $A8 
	db $82 
	db $AA 
	db $A8 
	db $A8 
	db $AA 
	db $A4 
	db $C1 
	db $2A 
	db $B0 
	db $EC 
	db $EA 
	db $A2 
	db $81 
	db $2A 
	db $A8 
	db $A8 
	db $AA 
	db $AA 
	db $81 
	db $2A 
	db $A8 
	db $A8 
	db $AA 
	db $44 
	db $E1 
	db $11 
	db $28 
	db $AE 
	db $AC 
gfx_StartToStab:
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $01 
	db $80 
	db $00 
	db $00 
	db $00 
	db $00 
	db $03 
	db $CC 
	db $00 
	db $00 
	db $00 
	db $07 
	db $33 
	db $DE 
	db $00 
	db $00 
	db $00 
	db $00 
	db $7B 
	db $DE 
	db $00 
	db $00 
	db $00 
	db $07 
	db $7B 
	db $86 
	db $00 
	db $FF 
	db $4D 
	db $E0 
	db $7B 
	db $02 
	db $38 
	db $FF 
	db $BC 
	db $F7 
	db $7B 
	db $44 
	db $64 
	db $7F 
	db $FE 
	db $F7 
	db $7B 
	db $7E 
	db $78 
	db $7F 
	db $7E 
	db $F0 
	db $31 
	db $BE 
	db $7C 
	db $3F 
	db $FE 
	db $F7 
	db $00 
	db $0F 
	db $7C 
	db $1F 
	db $FF 
	db $F7 
	db $55 
	db $1F 
	db $78 
	db $07 
	db $FF 
	db $F0 
	db $2A 
	db $2F 
	db $64 
	db $00 
	db $FB 
	db $C7 
	db $00 
	db $5F 
	db $38 
	db $00 
	db $52 
	db $00 
	db $7A 
	db $FF 
	db $00 
	db $00 
	db $C2 
	db $07 
	db $3F 
	db $FE 
	db $00 
	db $00 
	db $E4 
	db $00 
	db $3E 
	db $FE 
	db $00 
	db $00 
	db $44 
	db $00 
	db $1F 
	db $FC 
	db $00 
	db $00 
	db $00 
	db $00 
	db $0B 
	db $70 
	db $00 
	db $00 
	db $04 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $0C 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $0C 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $4E 
	db $4C 
	db $E3 
	db $90 
	db $4E 
	db $4C 
	db $A4 
	db $AA 
	db $41 
	db $28 
	db $A4 
	db $AA 
	db $84 
	db $AA 
	db $41 
	db $28 
	db $84 
	db $AA 
	db $44 
	db $EC 
	db $41 
	db $28 
	db $44 
	db $EC 
	db $24 
	db $AA 
	db $41 
	db $28 
	db $24 
	db $AA 
	db $A4 
	db $AA 
	db $41 
	db $28 
	db $A4 
	db $AA 
	db $44 
	db $AA 
	db $41 
	db $10 
	db $44 
	db $AC 
gfx_ImTheCure:
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $0F 
	db $B7 
	db $7F 
	db $FF 
	db $00 
	db $00 
	db $1F 
	db $B0 
	db $FF 
	db $FF 
	db $00 
	db $00 
	db $1F 
	db $BF 
	db $FF 
	db $FE 
	db $00 
	db $00 
	db $10 
	db $1F 
	db $FF 
	db $F0 
	db $00 
	db $00 
	db $0F 
	db $80 
	db $00 
	db $0E 
	db $00 
	db $00 
	db $3F 
	db $E0 
	db $FF 
	db $EC 
	db $00 
	db $00 
	db $7F 
	db $F6 
	db $60 
	db $00 
	db $00 
	db $00 
	db $FF 
	db $E7 
	db $00 
	db $00 
	db $00 
	db $01 
	db $F7 
	db $67 
	db $40 
	db $00 
	db $00 
	db $01 
	db $F8 
	db $60 
	db $C0 
	db $00 
	db $00 
	db $03 
	db $F8 
	db $33 
	db $80 
	db $00 
	db $00 
	db $0F 
	db $F2 
	db $08 
	db $00 
	db $00 
	db $00 
	db $3B 
	db $E4 
	db $FC 
	db $00 
	db $00 
	db $00 
	db $FF 
	db $EA 
	db $FC 
	db $00 
	db $00 
	db $00 
	db $FB 
	db $44 
	db $78 
	db $00 
	db $00 
	db $00 
	db $FD 
	db $88 
	db $80 
	db $00 
	db $00 
	db $00 
	db $FE 
	db $35 
	db $F0 
	db $00 
	db $00 
	db $00 
	db $FD 
	db $29 
	db $F0 
	db $00 
	db $00 
	db $00 
	db $FA 
	db $34 
	db $E0 
	db $00 
	db $00 
	db $00 
	db $ED 
	db $9F 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $EB 
	db $40 
	db $EA 
	db $E0 
	db $4A 
	db $CE 
	db $4A 
	db $A0 
	db $4A 
	db $80 
	db $AA 
	db $A8 
	db $42 
	db $A0 
	db $4A 
	db $80 
	db $8A 
	db $A8 
	db $42 
	db $A0 
	db $4E 
	db $C0 
	db $8A 
	db $CC 
	db $42 
	db $A0 
	db $4A 
	db $80 
	db $8A 
	db $A8 
	db $42 
	db $A0 
	db $4A 
	db $80 
	db $AA 
	db $A8 
	db $E2 
	db $A0 
	db $4A 
	db $E0 
	db $44 
	db $AE 
gfx_DontPushMe:
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $FF 
	db $FE 
	db $7F 
	db $FD 
	db $FF 
	db $F0 
	db $00 
	db $00 
	db $7F 
	db $FD 
	db $FF 
	db $F8 
	db $00 
	db $00 
	db $31 
	db $FD 
	db $FF 
	db $F8 
	db $00 
	db $00 
	db $0E 
	db $00 
	db $F9 
	db $50 
	db $00 
	db $00 
	db $0E 
	db $00 
	db $0F 
	db $F0 
	db $02 
	db $F0 
	db $0A 
	db $00 
	db $05 
	db $50 
	db $47 
	db $DB 
	db $0F 
	db $7F 
	db $F8 
	db $00 
	db $6D 
	db $EF 
	db $8F 
	db $00 
	db $06 
	db $F8 
	db $EF 
	db $A4 
	db $7F 
	db $FF 
	db $06 
	db $FB 
	db $FF 
	db $00 
	db $7F 
	db $FF 
	db $F8 
	db $FF 
	db $FE 
	db $0C 
	db $08 
	db $00 
	db $FE 
	db $1F 
	db $FF 
	db $C1 
	db $87 
	db $F7 
	db $0F 
	db $E0 
	db $5D 
	db $6A 
	db $08 
	db $07 
	db $57 
	db $FF 
	db $13 
	db $BD 
	db $0C 
	db $01 
	db $54 
	db $C1 
	db $01 
	db $38 
	db $0C 
	db $00 
	db $00 
	db $1E 
	db $00 
	db $20 
	db $0C 
	db $00 
	db $E1 
	db $BF 
	db $00 
	db $00 
	db $0C 
	db $00 
	db $E1 
	db $B7 
	db $00 
	db $00 
	db $0C 
	db $00 
	db $E0 
	db $33 
	db $00 
	db $00 
	db $0E 
	db $00 
	db $E0 
	db $C3 
	db $00 
	db $00 
	db $0E 
	db $00 
	db $E0 
	db $71 
	db $00 
	db $00 
	db $03 
	db $00 
	db $E0 
	db $0C 
	db $00 
	db $00 
	db $00 
	db $00 
	db $E0 
	db $1C 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $C4 
	db $CB 
	db $8C 
	db $A4 
	db $A3 
	db $CE 
	db $AA 
	db $A9 
	db $0A 
	db $AA 
	db $A2 
	db $A8 
	db $AA 
	db $A1 
	db $0A 
	db $A8 
	db $A2 
	db $A8 
	db $AA 
	db $A1 
	db $0C 
	db $A4 
	db $E2 
	db $AC 
	db $AA 
	db $A1 
	db $08 
	db $A2 
	db $A2 
	db $A8 
	db $AA 
	db $A1 
	db $08 
	db $AA 
	db $A2 
	db $A8 
	db $C4 
	db $A1 
	db $08 
	db $44 
	db $A2 
	db $AE 
gfx_CobraSnakeImage:
	db $00 
	db $00 
	db $7C 
	db $00 
	db $00 
	db $FF 
	db $87 
	db $FF 
	db $C3 
	db $FC 
	db $00 
	db $3F 
	db $FF 
	db $F8 
	db $00 
	db $00 
	db $FF 
	db $FF 
	db $FC 
	db $00 
	db $01 
	db $9F 
	db $FF 
	db $F3 
	db $00 
	db $02 
	db $06 
	db $FF 
	db $60 
	db $80 
	db $04 
	db $00 
	db $7E 
	db $00 
	db $40 
	db $E8 
	db $00 
	db $3C 
	db $00 
	db $4C 
	db $08 
	db $81 
	db $FF 
	db $80 
	db $20 
	db $10 
	db $03 
	db $E7 
	db $C0 
	db $A0 
	db $10 
	db $03 
	db $A5 
	db $C0 
	db $20 
	db $35 
	db $01 
	db $A5 
	db $81 
	db $10 
	db $A2 
	db $01 
	db $A5 
	db $88 
	db $14 
	db $20 
	db $00 
	db $81 
	db $20 
	db $90 
	db $2C 
	db $90 
	db $42 
	db $02 
	db $D0 
	db $37 
	db $40 
	db $66 
	db $13 
	db $70 
	db $BD 
	db $81 
	db $3C 
	db $87 
	db $F4 
	db $2F 
	db $50 
	db $00 
	db $2D 
	db $A0 
	db $3A 
	db $A1 
	db $AF 
	db $17 
	db $E0 
	db $BF 
	db $CA 
	db $7F 
	db $AD 
	db $EC 
	db $2E 
	db $A2 
	db $C3 
	db $BF 
	db $C0 
	db $97 
	db $F3 
	db $3C 
	db $57 
	db $5C 
	db $1F 
	db $A0 
	db $DF 
	db $5F 
	db $C0 
	db $CF 
	db $F1 
	db $7F 
	db $BF 
	db $9C 
	db $EB 
	db $6A 
	db $57 
	db $BD 
	db $BC 
	db $07 
	db $FA 
	db $3F 
	db $9F 
	db $00 
	db $F5 
	db $F2 
	db $C0 
	db $7F 
	db $7C 
	db $F2 
	db $79 
	db $3F 
	db $AE 
	db $7C 
	db $F9 
	db $B4 
	db $FF 
	db $DE 
	db $FC 
	db $00 
	db $D9 
	db $56 
	db $DC 
	db $00 
	db $FE 
	db $71 
	db $1F 
	db $CD 
	db $FC 
	db $FF 
	db $39 
	db $38 
	db $39 
	db $FC 
	db $FF 
	db $8C 
	db $C7 
	db $BB 
	db $FC 
	db $FF 
	db $C6 
	db $3F 
	db $DB 
	db $FC 
	db $00 
	db $03 
	db $4D 
	db $E8 
	db $00 
	db $FF 
	db $F9 
	db $43 
	db $6D 
	db $FC 
	db $FF 
	db $FD 
	db $A7 
	db $ED 
	db $FC 
	db $FF 
	db $FC 
	db $BC 
	db $14 
	db $FC 
	db $FF 
	db $FE 
	db $43 
	db $FA 
	db $7C 
	db $FF 
	db $FF 
	db $6C 
	db $6B 
	db $7C 

gfx_PramLeft:
	db $E0 
	db $00 
	db $3F 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $1F 
	db $C0 
	db $C0 
	db $1F 
	db $80 
	db $34 
	db $1F 
	db $40 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $1F 
	db $40 
	db $80 
	db $24 
	db $00 
	db $62 
	db $1F 
	db $C0 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $3F 
	db $80 
	db $00 
	db $5A 
	db $00 
	db $4A 
	db $3C 
	db $80 
	db $FF 
	db $00 
	db $7F 
	db $00 
	db $38 
	db $83 
	db $00 
	db $45 
	db $00 
	db $75 
	db $70 
	db $04 
	db $3F 
	db $80 
	db $3F 
	db $80 
	db $00 
	db $04 
	db $00 
	db $4B 
	db $00 
	db $7F 
	db $00 
	db $FB 
	db $7F 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $AC 
	db $00 
	db $6A 
	db $80 
	db $35 
	db $01 
	db $54 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $01 
	db $AC 
	db $80 
	db $3A 
	db $C0 
	db $0F 
	db $03 
	db $F8 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $07 
	db $E0 
	db $F0 
	db $03 
	db $F0 
	db $06 
	db $07 
	db $30 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $DF 
	db $80 
	db $7D 
	db $00 
	db $C7 
	db $00 
	db $71 
	db $7F 
	db $80 
	db $7F 
	db $80 
	db $80 
	db $24 
	db $00 
	db $92 
	db $01 
	db $AA 
	db $C0 
	db $2A 
	db $7F 
	db $80 
	db $7F 
	db $80 
	db $C0 
	db $24 
	db $01 
	db $92 
	db $01 
	db $C6 
	db $C0 
	db $31 
	db $7F 
	db $80 
	db $FF 
	db $00 
	db $E0 
	db $1F 
	db $83 
	db $7C 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $0F 
	db $00 
	db $F8 
	db $00 
	db $F0 
	db $07 
	db $07 
	db $F0 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $07 
	db $10 
	db $E0 
	db $0D 
	db $E0 
	db $09 
	db $07 
	db $10 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $07 
	db $B0 
	db $C0 
	db $18 
	db $C0 
	db $16 
	db $0F 
	db $A0 
	db $FF 
	db $00 
	db $3F 
	db $00 
	db $0F 
	db $A0 
	db $C0 
	db $12 
	db $C0 
	db $11 
	db $0E 
	db $60 
	db $1F 
	db $C0 
	db $0F 
	db $20 
	db $1C 
	db $41 
	db $C0 
	db $1D 
	db $C0 
	db $12 
	db $00 
	db $C1 
	db $0F 
	db $20 
	db $1F 
	db $C0 
	db $00 
	db $FE 
	db $C0 
	db $1F 
	db $C0 
	db $1A 
	db $00 
	db $AB 
	db $3F 
	db $00 
	db $7F 
	db $00 
	db $00 
	db $55 
	db $E0 
	db $0D 
	db $E0 
	db $0E 
	db $00 
	db $AB 
	db $7F 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $FE 
	db $F0 
	db $03 
	db $FC 
	db $00 
	db $01 
	db $F8 
	db $FF 
	db $00 
	db $3F 
	db $C0 
	db $00 
	db $8F 
	db $E0 
	db $1F 
	db $C0 
	db $31 
	db $00 
	db $FC 
	db $1F 
	db $60 
	db $1F 
	db $20 
	db $00 
	db $D9 
	db $C0 
	db $24 
	db $C0 
	db $2A 
	db $20 
	db $8A 
	db $1F 
	db $A0 
	db $1F 
	db $20 
	db $70 
	db $89 
	db $C0 
	db $24 
	db $C0 
	db $31 
	db $70 
	db $8C 
	db $1F 
	db $60 
	db $3F 
	db $C0 
	db $F8 
	db $07 
	db $E0 
	db $1F 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $03 
	db $00 
	db $FE 
	db $00 
	db $FC 
	db $01 
	db $01 
	db $FC 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $01 
	db $44 
	db $F8 
	db $03 
	db $F8 
	db $02 
	db $01 
	db $44 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $01 
	db $2C 
	db $F0 
	db $06 
	db $F0 
	db $05 
	db $03 
	db $A8 
	db $FF 
	db $00 
	db $CF 
	db $00 
	db $03 
	db $A8 
	db $F0 
	db $04 
	db $F0 
	db $04 
	db $03 
	db $58 
	db $87 
	db $30 
	db $03 
	db $48 
	db $07 
	db $50 
	db $F0 
	db $07 
	db $F0 
	db $04 
	db $00 
	db $B0 
	db $03 
	db $48 
	db $07 
	db $B0 
	db $00 
	db $FF 
	db $F0 
	db $07 
	db $F0 
	db $06 
	db $00 
	db $AA 
	db $0F 
	db $C0 
	db $1F 
	db $40 
	db $00 
	db $55 
	db $F8 
	db $03 
	db $F8 
	db $03 
	db $00 
	db $AA 
	db $1F 
	db $C0 
	db $3F 
	db $80 
	db $00 
	db $FF 
	db $FC 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $3E 
	db $7F 
	db $00 
	db $0F 
	db $F0 
	db $00 
	db $E3 
	db $F8 
	db $07 
	db $F0 
	db $0C 
	db $00 
	db $7F 
	db $07 
	db $18 
	db $07 
	db $48 
	db $08 
	db $36 
	db $F0 
	db $09 
	db $F0 
	db $0A 
	db $1C 
	db $A2 
	db $07 
	db $A8 
	db $07 
	db $48 
	db $1C 
	db $22 
	db $F0 
	db $09 
	db $F0 
	db $0C 
	db $1C 
	db $63 
	db $07 
	db $18 
	db $0F 
	db $F0 
	db $3E 
	db $C1 
	db $F8 
	db $07 
	db $FF 
	db $00 
	db $80 
	db $00 
	db $FF 
	db $00 
	db $7F 
	db $00 
	db $00 
	db $7F 
	db $FF 
	db $00 
	db $FE 
	db $00 
	db $00 
	db $D1 
	db $7F 
	db $00 
	db $7F 
	db $00 
	db $00 
	db $91 
	db $FE 
	db $00 
	db $FC 
	db $01 
	db $00 
	db $8B 
	db $7F 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $6A 
	db $FC 
	db $01 
	db $FC 
	db $01 
	db $00 
	db $2A 
	db $F3 
	db $00 
	db $E1 
	db $0C 
	db $00 
	db $16 
	db $FC 
	db $01 
	db $FC 
	db $01 
	db $01 
	db $D4 
	db $C0 
	db $12 
	db $00 
	db $12 
	db $00 
	db $2C 
	db $FC 
	db $01 
	db $FC 
	db $01 
	db $00 
	db $FF 
	db $01 
	db $EC 
	db $03 
	db $B0 
	db $00 
	db $AA 
	db $FC 
	db $01 
	db $FE 
	db $00 
	db $00 
	db $D5 
	db $07 
	db $50 
	db $07 
	db $B0 
	db $00 
	db $EA 
	db $FE 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $3F 
	db $0F 
	db $E0 
	db $1F 
	db $80 
	db $C0 
	db $0F 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $C0 
	db $18 
	db $1F 
	db $C0 
	db $03 
	db $7C 
	db $00 
	db $F7 
	db $FE 
	db $01 
	db $FC 
	db $03 
	db $00 
	db $1D 
	db $01 
	db $C6 
	db $01 
	db $92 
	db $02 
	db $48 
	db $FC 
	db $02 
	db $FC 
	db $02 
	db $07 
	db $A8 
	db $01 
	db $AA 
	db $01 
	db $92 
	db $07 
	db $48 
	db $FC 
	db $02 
	db $FC 
	db $03 
	db $07 
	db $18 
	db $01 
	db $C6 
	db $83 
	db $7C 
	db $0F 
	db $F0 
	db $FE 
	db $01 

gfx_Burger2:
	db $F0 
	db $0F 
	db $03 
	db $FC 
	db $FF 
	db $00 
	db $7F 
	db $80 
	db $00 
	db $07 
	db $80 
	db $78 
	db $00 
	db $C0 
	db $00 
	db $00 
	db $3F 
	db $C0 
	db $3F 
	db $40 
	db $00 
	db $00 
	db $00 
	db $80 
	db $00 
	db $80 
	db $00 
	db $00 
	db $3F 
	db $40 
	db $7F 
	db $80 
	db $00 
	db $FF 
	db $80 
	db $7F 
	db $00 
	db $DA 
	db $00 
	db $12 
	db $3F 
	db $C0 
	db $3F 
	db $40 
	db $00 
	db $80 
	db $00 
	db $BC 
	db $00 
	db $D4 
	db $00 
	db $10 
	db $3F 
	db $C0 
	db $7F 
	db $80 
	db $00 
	db $FF 
	db $80 
	db $7F 
	db $80 
	db $4A 
	db $00 
	db $32 
	db $7F 
	db $80 
	db $3F 
	db $C0 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $80 
	db $00 
	db $00 
	db $3F 
	db $40 
	db $3F 
	db $40 
	db $00 
	db $00 
	db $00 
	db $80 
	db $00 
	db $C0 
	db $00 
	db $00 
	db $3F 
	db $C0 
	db $7F 
	db $80 
	db $00 
	db $FF 
	db $80 
	db $7F 
	db $FC 
	db $03 
	db $00 
	db $FF 
	db $FF 
	db $00 
	db $1F 
	db $E0 
	db $00 
	db $01 
	db $E0 
	db $1E 
	db $C0 
	db $30 
	db $00 
	db $00 
	db $0F 
	db $30 
	db $0F 
	db $10 
	db $00 
	db $00 
	db $C0 
	db $20 
	db $C0 
	db $20 
	db $00 
	db $00 
	db $0F 
	db $10 
	db $1F 
	db $E0 
	db $00 
	db $FF 
	db $E0 
	db $1F 
	db $C0 
	db $36 
	db $00 
	db $84 
	db $0F 
	db $B0 
	db $0F 
	db $10 
	db $00 
	db $20 
	db $C0 
	db $2F 
	db $C0 
	db $35 
	db $00 
	db $04 
	db $0F 
	db $30 
	db $1F 
	db $E0 
	db $00 
	db $FF 
	db $E0 
	db $1F 
	db $E0 
	db $12 
	db $00 
	db $8C 
	db $1F 
	db $A0 
	db $0F 
	db $F0 
	db $00 
	db $FF 
	db $C0 
	db $3F 
	db $C0 
	db $20 
	db $00 
	db $00 
	db $0F 
	db $10 
	db $0F 
	db $10 
	db $00 
	db $00 
	db $C0 
	db $20 
	db $C0 
	db $30 
	db $00 
	db $00 
	db $0F 
	db $30 
	db $1F 
	db $E0 
	db $00 
	db $FF 
	db $E0 
	db $1F 
	db $FF 
	db $00 
	db $00 
	db $FF 
	db $3F 
	db $C0 
	db $07 
	db $78 
	db $00 
	db $80 
	db $F8 
	db $07 
	db $F0 
	db $0C 
	db $00 
	db $00 
	db $03 
	db $0C 
	db $03 
	db $04 
	db $00 
	db $00 
	db $F0 
	db $08 
	db $F0 
	db $08 
	db $00 
	db $00 
	db $03 
	db $04 
	db $07 
	db $F8 
	db $00 
	db $FF 
	db $F8 
	db $07 
	db $F0 
	db $0D 
	db $00 
	db $A1 
	db $03 
	db $2C 
	db $03 
	db $04 
	db $00 
	db $C8 
	db $F0 
	db $0B 
	db $F0 
	db $0D 
	db $00 
	db $41 
	db $03 
	db $0C 
	db $07 
	db $F8 
	db $00 
	db $FF 
	db $F8 
	db $07 
	db $F8 
	db $04 
	db $00 
	db $A3 
	db $07 
	db $28 
	db $03 
	db $FC 
	db $00 
	db $FF 
	db $F0 
	db $0F 
	db $F0 
	db $08 
	db $00 
	db $00 
	db $03 
	db $04 
	db $03 
	db $04 
	db $00 
	db $00 
	db $F0 
	db $08 
	db $F0 
	db $0C 
	db $00 
	db $00 
	db $03 
	db $0C 
	db $07 
	db $F8 
	db $00 
	db $FF 
	db $F8 
	db $07 
	db $FF 
	db $00 
	db $C0 
	db $3F 
	db $0F 
	db $F0 
	db $01 
	db $1E 
	db $00 
	db $E0 
	db $FE 
	db $01 
	db $FC 
	db $03 
	db $00 
	db $00 
	db $00 
	db $03 
	db $00 
	db $01 
	db $00 
	db $00 
	db $FC 
	db $02 
	db $FC 
	db $02 
	db $00 
	db $00 
	db $00 
	db $01 
	db $01 
	db $FE 
	db $00 
	db $FF 
	db $FE 
	db $01 
	db $FC 
	db $03 
	db $00 
	db $68 
	db $00 
	db $4B 
	db $00 
	db $01 
	db $00 
	db $F2 
	db $FC 
	db $02 
	db $FC 
	db $03 
	db $00 
	db $50 
	db $00 
	db $43 
	db $01 
	db $FE 
	db $00 
	db $FF 
	db $FE 
	db $01 
	db $FE 
	db $01 
	db $00 
	db $28 
	db $01 
	db $CA 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $FC 
	db $03 
	db $FC 
	db $02 
	db $00 
	db $00 
	db $00 
	db $01 
	db $00 
	db $01 
	db $00 
	db $00 
	db $FC 
	db $02 
	db $FC 
	db $03 
	db $00 
	db $00 
	db $00 
	db $03 
	db $01 
	db $FE 
	db $00 
	db $FF 
	db $FE 
	db $01 

gfx_MissileLeft:
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $DF 
	db $20 
	db $17 
	db $08 
	db $02 
	db $01 
	db $C0 
	db $00 
	db $80 
	db $3F 
	db $00 
	db $FC 
	db $07 
	db $80 
	db $00 
	db $25 
	db $00 
	db $15 
	db $00 
	db $40 
	db $00 
	db $7F 
	db $00 
	db $FD 
	db $07 
	db $48 
	db $1F 
	db $80 
	db $01 
	db $FC 
	db $80 
	db $3F 
	db $C0 
	db $00 
	db $03 
	db $00 
	db $DF 
	db $20 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $EF 
	db $10 
	db $CF 
	db $00 
	db $00 
	db $00 
	db $F0 
	db $00 
	db $E0 
	db $0F 
	db $00 
	db $FF 
	db $0D 
	db $52 
	db $01 
	db $00 
	db $00 
	db $05 
	db $C0 
	db $10 
	db $C0 
	db $1F 
	db $00 
	db $FF 
	db $01 
	db $24 
	db $60 
	db $01 
	db $00 
	db $FF 
	db $E0 
	db $0F 
	db $F0 
	db $00 
	db $00 
	db $00 
	db $F7 
	db $08 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $DB 
	db $24 
	db $00 
	db $09 
	db $00 
	db $00 
	db $FC 
	db $00 
	db $F8 
	db $03 
	db $00 
	db $FF 
	db $01 
	db $C0 
	db $01 
	db $4A 
	db $00 
	db $01 
	db $F0 
	db $04 
	db $F0 
	db $07 
	db $00 
	db $FF 
	db $01 
	db $D0 
	db $01 
	db $C4 
	db $00 
	db $FF 
	db $F8 
	db $03 
	db $FC 
	db $00 
	db $00 
	db $00 
	db $2E 
	db $11 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FB 
	db $04 
	db $08 
	db $01 
	db $00 
	db $00 
	db $FF 
	db $00 
	db $FE 
	db $00 
	db $00 
	db $FF 
	db $01 
	db $F8 
	db $01 
	db $54 
	db $00 
	db $00 
	db $FC 
	db $01 
	db $FC 
	db $01 
	db $00 
	db $FF 
	db $00 
	db $F1 
	db $03 
	db $F4 
	db $00 
	db $FF 
	db $FE 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $00 
	db $0F 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 

gfx_MissileRight:
	db $DF 
	db $20 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $00 
	db $10 
	db $80 
	db $80 
	db $1F 
	db $00 
	db $FF 
	db $7F 
	db $00 
	db $3F 
	db $80 
	db $00 
	db $00 
	db $80 
	db $2A 
	db $00 
	db $8F 
	db $00 
	db $FF 
	db $3F 
	db $80 
	db $7F 
	db $00 
	db $00 
	db $FF 
	db $C0 
	db $2F 
	db $F0 
	db $00 
	db $00 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $DB 
	db $24 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $3F 
	db $00 
	db $00 
	db $00 
	db $00 
	db $90 
	db $80 
	db $03 
	db $00 
	db $FF 
	db $1F 
	db $C0 
	db $0F 
	db $20 
	db $00 
	db $80 
	db $80 
	db $52 
	db $80 
	db $0B 
	db $00 
	db $FF 
	db $0F 
	db $E0 
	db $1F 
	db $C0 
	db $00 
	db $FF 
	db $80 
	db $23 
	db $74 
	db $88 
	db $00 
	db $00 
	db $3F 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $F7 
	db $08 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $0F 
	db $00 
	db $00 
	db $00 
	db $F3 
	db $00 
	db $B0 
	db $4A 
	db $00 
	db $FF 
	db $07 
	db $F0 
	db $03 
	db $08 
	db $00 
	db $A0 
	db $80 
	db $00 
	db $80 
	db $24 
	db $00 
	db $FF 
	db $03 
	db $F8 
	db $07 
	db $F0 
	db $00 
	db $FF 
	db $06 
	db $80 
	db $EF 
	db $10 
	db $00 
	db $00 
	db $0F 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FB 
	db $04 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $03 
	db $00 
	db $40 
	db $80 
	db $E8 
	db $10 
	db $E0 
	db $01 
	db $00 
	db $3F 
	db $01 
	db $FC 
	db $00 
	db $02 
	db $00 
	db $A8 
	db $00 
	db $A4 
	db $E0 
	db $12 
	db $00 
	db $BF 
	db $00 
	db $FE 
	db $01 
	db $FC 
	db $80 
	db $3F 
	db $F8 
	db $01 
	db $FB 
	db $04 
	db $C0 
	db $00 
	db $03 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $FF 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
; PreShiftedTiles - Each round's tiles are shifted and stored here.
; 
; The first tuple of tiles is the wrapping parallax ground tile.
;

	org $ee80

PreShiftedTiles:
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $55 
	db $55 
	db $55 
	db $55 
	db $55 
	db $55 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $01 
	db $00 
	db $01 
	db $00 
	db $01 
	db $00 
	db $01 
	db $00 
	db $03 
	db $00 
	db $01 
	db $08 
	db $01 
	db $04 
	db $41 
	db $41 
	db $05 
	db $40 
	db $0B 
	db $50 
	db $93 
	db $14 
	db $6B 
	db $A5 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $ED 
	db $6F 
	db $BF 
	db $B5 
	db $84 
	db $DF 
	db $BD 
	db $A5 
	db $F5 
	db $D7 
	db $51 
	db $36 
	db $EB 
	db $D6 
	db $AE 
	db $82 
	db $84 
	db $2F 
	db $D5 
	db $62 
	db $74 
	db $14 
	db $02 
	db $4D 
	db $42 
	db $88 
	db $20 
	db $80 
	db $20 
	db $06 
	db $90 
	db $00 
	db $44 
	db $02 
	db $04 
	db $05 
	db $00 
	db $82 
	db $01 
	db $00 
	db $00 
	db $20 
	db $08 
	db $10 
	db $00 
	db $20 
	db $01 
	db $00 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $55 
	db $55 
	db $55 
	db $55 
	db $55 
	db $55 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $00 
	db $40 
	db $00 
	db $40 
	db $00 
	db $40 
	db $00 
	db $40 
	db $00 
	db $C0 
	db $00 
	db $42 
	db $00 
	db $41 
	db $10 
	db $50 
	db $41 
	db $50 
	db $42 
	db $D4 
	db $24 
	db $C5 
	db $1A 
	db $E9 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FB 
	db $5B 
	db $EF 
	db $ED 
	db $61 
	db $37 
	db $AF 
	db $69 
	db $7D 
	db $75 
	db $D4 
	db $4D 
	db $FA 
	db $F5 
	db $AB 
	db $A0 
	db $A1 
	db $0B 
	db $75 
	db $58 
	db $9D 
	db $05 
	db $00 
	db $93 
	db $90 
	db $A2 
	db $08 
	db $20 
	db $08 
	db $01 
	db $64 
	db $00 
	db $11 
	db $00 
	db $81 
	db $01 
	db $00 
	db $20 
	db $80 
	db $40 
	db $00 
	db $08 
	db $02 
	db $04 
	db $00 
	db $08 
	db $00 
	db $40 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $55 
	db $55 
	db $55 
	db $55 
	db $55 
	db $55 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $00 
	db $10 
	db $00 
	db $10 
	db $00 
	db $10 
	db $80 
	db $10 
	db $00 
	db $30 
	db $00 
	db $10 
	db $00 
	db $10 
	db $44 
	db $14 
	db $10 
	db $54 
	db $50 
	db $B5 
	db $09 
	db $31 
	db $46 
	db $BA 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FE 
	db $D6 
	db $FB 
	db $FB 
	db $58 
	db $4D 
	db $6B 
	db $DA 
	db $5F 
	db $5D 
	db $75 
	db $13 
	db $FE 
	db $BD 
	db $6A 
	db $E8 
	db $28 
	db $42 
	db $DD 
	db $56 
	db $27 
	db $41 
	db $40 
	db $24 
	db $64 
	db $28 
	db $82 
	db $08 
	db $02 
	db $00 
	db $59 
	db $00 
	db $04 
	db $40 
	db $20 
	db $40 
	db $00 
	db $08 
	db $20 
	db $10 
	db $00 
	db $02 
	db $00 
	db $81 
	db $00 
	db $02 
	db $00 
	db $10 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $55 
	db $55 
	db $55 
	db $55 
	db $55 
	db $55 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $00 
	db $04 
	db $00 
	db $04 
	db $00 
	db $04 
	db $20 
	db $04 
	db $00 
	db $0C 
	db $00 
	db $04 
	db $00 
	db $04 
	db $11 
	db $05 
	db $04 
	db $15 
	db $94 
	db $2D 
	db $42 
	db $4C 
	db $51 
	db $AE 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $7F 
	db $B5 
	db $BE 
	db $FE 
	db $D6 
	db $13 
	db $DA 
	db $F6 
	db $97 
	db $D7 
	db $5D 
	db $44 
	db $BF 
	db $AF 
	db $5A 
	db $BA 
	db $0A 
	db $10 
	db $37 
	db $55 
	db $89 
	db $D0 
	db $50 
	db $09 
	db $19 
	db $0A 
	db $20 
	db $82 
	db $00 
	db $80 
	db $16 
	db $40 
	db $01 
	db $10 
	db $08 
	db $10 
	db $80 
	db $02 
	db $08 
	db $04 
	db $00 
	db $00 
	db $00 
	db $20 
	db $40 
	db $00 
	db $80 
	db $04 
label_F000:
	db $FF 
	db $FF 
	db $FF 
function_F003:
	db $FF 
	db $FF 
	db $FF 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $3F 
	db $10 
	db $10 
	db $10 
	db $10 
	db $10 
	db $3F 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $3F 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $F8 
	db $17 
	db $F8 
	db $17 
	db $F8 
	db $BF 
	db $F1 
	db $8B 
	db $F1 
	db $8B 
	db $F1 
	db $7F 
	db $E2 
	db $C5 
	db $E2 
	db $C5 
	db $E2 
	db $FF 
	db $C5 
	db $E2 
	db $C5 
	db $E2 
	db $C5 
	db $FF 
	db $8B 
	db $F1 
	db $8B 
	db $F1 
	db $8B 
	db $FF 
	db $17 
	db $F8 
	db $17 
	db $F8 
	db $17 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $3F 
	db $10 
	db $10 
	db $10 
	db $10 
	db $10 
	db $3F 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $3F 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $C0 
	db $00 
	db $00 
	db $00 
	db $00 
	db $0F 
	db $C4 
	db $04 
	db $04 
	db $04 
	db $04 
	db $0F 
	db $C0 
	db $00 
	db $00 
	db $00 
	db $00 
	db $0F 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FE 
	db $05 
	db $FE 
	db $05 
	db $FE 
	db $2F 
	db $FC 
	db $62 
	db $FC 
	db $62 
	db $FC 
	db $5F 
	db $F8 
	db $B1 
	db $78 
	db $B1 
	db $78 
	db $BF 
	db $F1 
	db $78 
	db $B1 
	db $78 
	db $B1 
	db $7F 
	db $E2 
	db $FC 
	db $62 
	db $FC 
	db $62 
	db $FF 
	db $C5 
	db $FE 
	db $05 
	db $FE 
	db $05 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $C0 
	db $00 
	db $00 
	db $00 
	db $00 
	db $0F 
	db $C4 
	db $04 
	db $04 
	db $04 
	db $04 
	db $0F 
	db $C0 
	db $00 
	db $00 
	db $00 
	db $00 
	db $0F 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $F0 
	db $00 
	db $00 
	db $00 
	db $00 
	db $03 
	db $F1 
	db $01 
	db $01 
	db $01 
	db $01 
	db $03 
	db $F0 
	db $00 
	db $00 
	db $00 
	db $00 
	db $03 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $81 
	db $7F 
	db $81 
	db $7F 
	db $8B 
	db $FF 
	db $18 
	db $BF 
	db $18 
	db $BF 
	db $17 
	db $FE 
	db $2C 
	db $5E 
	db $2C 
	db $5E 
	db $2F 
	db $FC 
	db $5E 
	db $2C 
	db $5E 
	db $2C 
	db $5F 
	db $F8 
	db $BF 
	db $18 
	db $BF 
	db $18 
	db $BF 
	db $F1 
	db $7F 
	db $81 
	db $7F 
	db $81 
	db $7F 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $F0 
	db $00 
	db $00 
	db $00 
	db $00 
	db $03 
	db $F1 
	db $01 
	db $01 
	db $01 
	db $01 
	db $03 
	db $F0 
	db $00 
	db $00 
	db $00 
	db $00 
	db $03 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FC 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $FC 
	db $40 
	db $40 
	db $40 
	db $40 
	db $40 
	db $FC 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $E0 
	db $5F 
	db $E0 
	db $5F 
	db $E2 
	db $FF 
	db $C6 
	db $2F 
	db $C6 
	db $2F 
	db $C5 
	db $FF 
	db $8B 
	db $17 
	db $8B 
	db $17 
	db $8B 
	db $FF 
	db $17 
	db $8B 
	db $17 
	db $8B 
	db $17 
	db $FE 
	db $2F 
	db $C6 
	db $2F 
	db $C6 
	db $2F 
	db $FC 
	db $5F 
	db $E0 
	db $5F 
	db $E0 
	db $5F 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FC 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $FC 
	db $40 
	db $40 
	db $40 
	db $40 
	db $40 
	db $FC 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $EC 
	db $FF 
	db $FF 
	db $FF 
	db $D8 
	db $7F 
	db $EC 
	db $FF 
	db $60 
	db $3F 
	db $FF 
	db $FF 
	db $EC 
	db $FF 
	db $60 
	db $3F 
	db $EC 
	db $FF 
	db $EC 
	db $FF 
	db $FF 
	db $FF 
	db $EC 
	db $FF 
	db $EC 
	db $FF 
	db $B0 
	db $7F 
	db $FF 
	db $FF 
	db $EC 
	db $FF 
	db $B0 
	db $7F 
	db $D8 
	db $7F 
	db $EC 
	db $FF 
	db $B0 
	db $7F 
	db $FF 
	db $FF 
	db $EC 
	db $FF 
	db $B0 
	db $7F 
	db $EC 
	db $FF 
	db $EC 
	db $FF 
	db $B0 
	db $7F 
	db $EC 
	db $FF 
	db $EC 
	db $FF 
	db $B0 
	db $7F 
	db $EC 
	db $FF 
	db $EC 
	db $FF 
	db $B0 
	db $7F 
	db $EC 
	db $FF 
	db $EC 
	db $FF 
	db $B0 
	db $7F 
	db $EC 
	db $FF 
	db $EC 
	db $FF 
	db $B0 
	db $7F 
	db $EC 
	db $FF 
	db $EC 
	db $FF 
	db $FF 
	db $FF 
	db $EC 
	db $FF 
	db $EC 
	db $FF 
	db $60 
	db $3F 
	db $EC 
	db $FF 
	db $EC 
	db $FF 
	db $60 
	db $3F 
	db $FF 
	db $FF 
	db $FB 
	db $3F 
	db $FF 
	db $FF 
	db $F6 
	db $1F 
	db $FB 
	db $3F 
	db $D8 
	db $0F 
	db $FF 
	db $FF 
	db $FB 
	db $3F 
	db $D8 
	db $0F 
	db $FB 
	db $3F 
	db $FB 
	db $3F 
	db $FF 
	db $FF 
	db $FB 
	db $3F 
	db $FB 
	db $3F 
	db $EC 
	db $1F 
	db $FF 
	db $FF 
	db $FB 
	db $3F 
	db $EC 
	db $1F 
	db $F6 
	db $1F 
	db $FB 
	db $3F 
	db $EC 
	db $1F 
	db $FF 
	db $FF 
	db $FB 
	db $3F 
	db $EC 
	db $1F 
	db $FB 
	db $3F 
	db $FB 
	db $3F 
	db $EC 
	db $1F 
	db $FB 
	db $3F 
	db $FB 
	db $3F 
	db $EC 
	db $1F 
	db $FB 
	db $3F 
	db $FB 
	db $3F 
	db $EC 
	db $1F 
	db $FB 
	db $3F 
	db $FB 
	db $3F 
	db $EC 
	db $1F 
	db $FB 
	db $3F 
	db $FB 
	db $3F 
	db $EC 
	db $1F 
	db $FB 
	db $3F 
	db $FB 
	db $3F 
	db $FF 
	db $FF 
	db $FB 
	db $3F 
	db $FB 
	db $3F 
	db $D8 
	db $0F 
	db $FB 
	db $3F 
	db $FB 
	db $3F 
	db $D8 
	db $0F 
	db $FF 
	db $FF 
	db $FE 
	db $CF 
	db $FF 
	db $FF 
	db $FD 
	db $87 
	db $FE 
	db $CF 
	db $F6 
	db $03 
	db $FF 
	db $FF 
	db $FE 
	db $CF 
	db $F6 
	db $03 
	db $FE 
	db $CF 
	db $FE 
	db $CF 
	db $FF 
	db $FF 
	db $FE 
	db $CF 
	db $FE 
	db $CF 
	db $FB 
	db $07 
	db $FF 
	db $FF 
	db $FE 
	db $CF 
	db $FB 
	db $07 
	db $FD 
	db $87 
	db $FE 
	db $CF 
	db $FB 
	db $07 
	db $FF 
	db $FF 
	db $FE 
	db $CF 
	db $FB 
	db $07 
	db $FE 
	db $CF 
	db $FE 
	db $CF 
	db $FB 
	db $07 
	db $FE 
	db $CF 
	db $FE 
	db $CF 
	db $FB 
	db $07 
	db $FE 
	db $CF 
	db $FE 
	db $CF 
	db $FB 
	db $07 
	db $FE 
	db $CF 
	db $FE 
	db $CF 
	db $FB 
	db $07 
	db $FE 
	db $CF 
	db $FE 
	db $CF 
	db $FB 
	db $07 
	db $FE 
	db $CF 
	db $FE 
	db $CF 
	db $FF 
	db $FF 
	db $FE 
	db $CF 
	db $FE 
	db $CF 
	db $F6 
	db $03 
	db $FE 
	db $CF 
	db $FE 
	db $CF 
	db $F6 
	db $03 
	db $FF 
	db $FF 
	db $FF 
	db $B3 
	db $FF 
	db $FF 
	db $FF 
	db $61 
	db $FF 
	db $B3 
	db $FD 
	db $80 
	db $FF 
	db $FF 
	db $FF 
	db $B3 
	db $FD 
	db $80 
	db $FF 
	db $B3 
	db $FF 
	db $B3 
	db $FF 
	db $FF 
	db $FF 
	db $B3 
	db $FF 
	db $B3 
	db $FE 
	db $C1 
	db $FF 
	db $FF 
	db $FF 
	db $B3 
	db $FE 
	db $C1 
	db $FF 
	db $61 
	db $FF 
	db $B3 
	db $FE 
	db $C1 
	db $FF 
	db $FF 
	db $FF 
	db $B3 
	db $FE 
	db $C1 
	db $FF 
	db $B3 
	db $FF 
	db $B3 
	db $FE 
	db $C1 
	db $FF 
	db $B3 
	db $FF 
	db $B3 
	db $FE 
	db $C1 
	db $FF 
	db $B3 
	db $FF 
	db $B3 
	db $FE 
	db $C1 
	db $FF 
	db $B3 
	db $FF 
	db $B3 
	db $FE 
	db $C1 
	db $FF 
	db $B3 
	db $FF 
	db $B3 
	db $FE 
	db $C1 
	db $FF 
	db $B3 
	db $FF 
	db $B3 
	db $FF 
	db $FF 
	db $FF 
	db $B3 
	db $FF 
	db $B3 
	db $FD 
	db $80 
	db $FF 
	db $B3 
	db $FF 
	db $B3 
	db $FD 
	db $80 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $01 
	db $01 
	db $01 
	db $01 
	db $01 
	db $FF 
	db $01 
	db $01 
	db $01 
	db $01 
	db $01 
	db $FF 
	db $01 
	db $01 
	db $01 
	db $01 
	db $01 
	db $FF 
	db $01 
	db $01 
	db $01 
	db $01 
	db $01 
	db $FF 
	db $01 
	db $01 
	db $01 
	db $01 
	db $01 
	db $FF 
	db $01 
	db $01 
	db $01 
	db $01 
	db $01 
	db $FF 
	db $01 
	db $01 
	db $01 
	db $01 
	db $01 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $08 
	db $21 
	db $08 
	db $21 
	db $09 
	db $FF 
	db $08 
	db $21 
	db $08 
	db $21 
	db $09 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $C4 
	db $44 
	db $44 
	db $44 
	db $47 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $F5 
	db $55 
	db $55 
	db $55 
	db $5F 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $C0 
	db $40 
	db $40 
	db $40 
	db $40 
	db $7F 
	db $C0 
	db $40 
	db $40 
	db $40 
	db $40 
	db $7F 
	db $C0 
	db $40 
	db $40 
	db $40 
	db $40 
	db $7F 
	db $C0 
	db $40 
	db $40 
	db $40 
	db $40 
	db $7F 
	db $C0 
	db $40 
	db $40 
	db $40 
	db $40 
	db $7F 
	db $C0 
	db $40 
	db $40 
	db $40 
	db $40 
	db $7F 
	db $C0 
	db $40 
	db $40 
	db $40 
	db $40 
	db $7F 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $C2 
	db $08 
	db $42 
	db $08 
	db $42 
	db $7F 
	db $C2 
	db $08 
	db $42 
	db $08 
	db $42 
	db $7F 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $F1 
	db $11 
	db $11 
	db $11 
	db $11 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FD 
	db $55 
	db $55 
	db $55 
	db $57 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $F0 
	db $10 
	db $10 
	db $10 
	db $10 
	db $1F 
	db $F0 
	db $10 
	db $10 
	db $10 
	db $10 
	db $1F 
	db $F0 
	db $10 
	db $10 
	db $10 
	db $10 
	db $1F 
	db $F0 
	db $10 
	db $10 
	db $10 
	db $10 
	db $1F 
	db $F0 
	db $10 
	db $10 
	db $10 
	db $10 
	db $1F 
	db $F0 
	db $10 
	db $10 
	db $10 
	db $10 
	db $1F 
	db $F0 
	db $10 
	db $10 
	db $10 
	db $10 
	db $1F 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $F0 
	db $82 
	db $10 
	db $82 
	db $10 
	db $9F 
	db $F0 
	db $82 
	db $10 
	db $82 
	db $10 
	db $9F 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FC 
	db $44 
	db $44 
	db $44 
	db $44 
	db $7F 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $55 
	db $55 
	db $55 
	db $55 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FC 
	db $04 
	db $04 
	db $04 
	db $04 
	db $07 
	db $FC 
	db $04 
	db $04 
	db $04 
	db $04 
	db $07 
	db $FC 
	db $04 
	db $04 
	db $04 
	db $04 
	db $07 
	db $FC 
	db $04 
	db $04 
	db $04 
	db $04 
	db $07 
	db $FC 
	db $04 
	db $04 
	db $04 
	db $04 
	db $07 
	db $FC 
	db $04 
	db $04 
	db $04 
	db $04 
	db $07 
	db $FC 
	db $04 
	db $04 
	db $04 
	db $04 
	db $07 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FC 
	db $20 
	db $84 
	db $20 
	db $84 
	db $27 
	db $FC 
	db $20 
	db $84 
	db $20 
	db $84 
	db $27 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $11 
	db $11 
	db $11 
	db $11 
	db $1F 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $D5 
	db $55 
	db $55 
	db $55 
	db $7F 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $01 
	db $01 
	db $01 
	db $01 
	db $01 
	db $FF 
	db $01 
	db $01 
	db $01 
	db $01 
	db $01 
	db $FF 
	db $01 
	db $01 
	db $01 
	db $01 
	db $01 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $10 
	db $10 
	db $10 
	db $10 
	db $11 
	db $FF 
	db $10 
	db $10 
	db $10 
	db $10 
	db $11 
	db $FF 
	db $10 
	db $10 
	db $10 
	db $10 
	db $11 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $01 
	db $01 
	db $01 
	db $01 
	db $01 
	db $FF 
	db $01 
	db $01 
	db $01 
	db $01 
	db $01 
	db $FF 
	db $01 
	db $01 
	db $01 
	db $01 
	db $01 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $10 
	db $10 
	db $10 
	db $10 
	db $11 
	db $FF 
	db $10 
	db $10 
	db $10 
	db $10 
	db $11 
	db $FF 
	db $10 
	db $10 
	db $10 
	db $10 
	db $11 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $C0 
	db $40 
	db $40 
	db $40 
	db $40 
	db $7F 
	db $C0 
	db $40 
	db $40 
	db $40 
	db $40 
	db $7F 
	db $C0 
	db $40 
	db $40 
	db $40 
	db $40 
	db $7F 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $C4 
	db $04 
	db $04 
	db $04 
	db $04 
	db $7F 
	db $C4 
	db $04 
	db $04 
	db $04 
	db $04 
	db $7F 
	db $C4 
	db $04 
	db $04 
	db $04 
	db $04 
	db $7F 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $C0 
	db $40 
	db $40 
	db $40 
	db $40 
	db $7F 
	db $C0 
	db $40 
	db $40 
	db $40 
	db $40 
	db $7F 
	db $C0 
	db $40 
	db $40 
	db $40 
	db $40 
	db $7F 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $C4 
	db $04 
	db $04 
	db $04 
	db $04 
	db $7F 
	db $C4 
	db $04 
	db $04 
	db $04 
	db $04 
	db $7F 
	db $C4 
	db $04 
	db $04 
	db $04 
	db $04 
	db $7F 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $F0 
	db $10 
	db $10 
	db $10 
	db $10 
	db $1F 
	db $F0 
	db $10 
	db $10 
	db $10 
	db $10 
	db $1F 
	db $F0 
	db $10 
	db $10 
	db $10 
	db $10 
	db $1F 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $F1 
	db $01 
	db $01 
	db $01 
	db $01 
	db $1F 
	db $F1 
	db $01 
	db $01 
	db $01 
	db $01 
	db $1F 
	db $F1 
	db $01 
	db $01 
	db $01 
	db $01 
	db $1F 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $F0 
	db $10 
	db $10 
	db $10 
	db $10 
	db $1F 
	db $F0 
	db $10 
	db $10 
	db $10 
	db $10 
	db $1F 
	db $F0 
	db $10 
	db $10 
	db $10 
	db $10 
	db $1F 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $F1 
	db $01 
	db $01 
	db $01 
	db $01 
	db $1F 
	db $F1 
	db $01 
	db $01 
	db $01 
	db $01 
	db $1F 
	db $F1 
	db $01 
	db $01 
	db $01 
	db $01 
	db $1F 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FC 
	db $04 
	db $04 
	db $04 
	db $04 
	db $07 
	db $FC 
	db $04 
	db $04 
	db $04 
	db $04 
	db $07 
	db $FC 
	db $04 
	db $04 
	db $04 
	db $04 
	db $07 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FC 
	db $40 
	db $40 
	db $40 
	db $40 
	db $47 
	db $FC 
	db $40 
	db $40 
	db $40 
	db $40 
	db $47 
	db $FC 
	db $40 
	db $40 
	db $40 
	db $40 
	db $47 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FC 
	db $04 
	db $04 
	db $04 
	db $04 
	db $07 
	db $FC 
	db $04 
	db $04 
	db $04 
	db $04 
	db $07 
	db $FC 
	db $04 
	db $04 
	db $04 
	db $04 
	db $07 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FC 
	db $40 
	db $40 
	db $40 
	db $40 
	db $47 
	db $FC 
	db $40 
	db $40 
	db $40 
	db $40 
	db $47 
	db $FC 
	db $40 
	db $40 
	db $40 
	db $40 
	db $47 
	db $F3 
	db $F3 
	db $F3 
	db $F3 
	db $F3 
	db $FF 
	db $15 
	db $15 
	db $15 
	db $15 
	db $15 
	db $FF 
	db $19 
	db $19 
	db $19 
	db $19 
	db $19 
	db $FF 
	db $15 
	db $15 
	db $15 
	db $15 
	db $15 
	db $FF 
	db $13 
	db $13 
	db $13 
	db $13 
	db $13 
	db $FF 
	db $15 
	db $15 
	db $15 
	db $15 
	db $15 
	db $FF 
	db $19 
	db $19 
	db $19 
	db $19 
	db $19 
	db $FF 
	db $15 
	db $15 
	db $15 
	db $15 
	db $15 
	db $FF 
	db $1F 
	db $1F 
	db $1F 
	db $1F 
	db $1F 
	db $FF 
	db $15 
	db $15 
	db $15 
	db $15 
	db $15 
	db $FF 
	db $19 
	db $19 
	db $19 
	db $19 
	db $19 
	db $FF 
	db $15 
	db $15 
	db $15 
	db $15 
	db $15 
	db $FF 
	db $13 
	db $13 
	db $13 
	db $13 
	db $13 
	db $FF 
	db $15 
	db $15 
	db $15 
	db $15 
	db $15 
	db $FF 
	db $19 
	db $19 
	db $19 
	db $19 
	db $19 
	db $FF 
	db $15 
	db $15 
	db $15 
	db $15 
	db $15 
	db $FF 
	db $FC 
	db $FC 
	db $FC 
	db $FC 
	db $FC 
	db $FF 
	db $C5 
	db $45 
	db $45 
	db $45 
	db $45 
	db $7F 
	db $C6 
	db $46 
	db $46 
	db $46 
	db $46 
	db $7F 
	db $C5 
	db $45 
	db $45 
	db $45 
	db $45 
	db $7F 
	db $C4 
	db $C4 
	db $C4 
	db $C4 
	db $C4 
	db $FF 
	db $C5 
	db $45 
	db $45 
	db $45 
	db $45 
	db $7F 
	db $C6 
	db $46 
	db $46 
	db $46 
	db $46 
	db $7F 
	db $C5 
	db $45 
	db $45 
	db $45 
	db $45 
	db $7F 
	db $C7 
	db $C7 
	db $C7 
	db $C7 
	db $C7 
	db $FF 
	db $C5 
	db $45 
	db $45 
	db $45 
	db $45 
	db $7F 
	db $C6 
	db $46 
	db $46 
	db $46 
	db $46 
	db $7F 
	db $C5 
	db $45 
	db $45 
	db $45 
	db $45 
	db $7F 
	db $C4 
	db $C4 
	db $C4 
	db $C4 
	db $C4 
	db $FF 
	db $C5 
	db $45 
	db $45 
	db $45 
	db $45 
	db $7F 
	db $C6 
	db $46 
	db $46 
	db $46 
	db $46 
	db $7F 
	db $C5 
	db $45 
	db $45 
	db $45 
	db $45 
	db $7F 
	db $FF 
	db $3F 
	db $3F 
	db $3F 
	db $3F 
	db $3F 
	db $F1 
	db $51 
	db $51 
	db $51 
	db $51 
	db $5F 
	db $F1 
	db $91 
	db $91 
	db $91 
	db $91 
	db $9F 
	db $F1 
	db $51 
	db $51 
	db $51 
	db $51 
	db $5F 
	db $F1 
	db $31 
	db $31 
	db $31 
	db $31 
	db $3F 
	db $F1 
	db $51 
	db $51 
	db $51 
	db $51 
	db $5F 
	db $F1 
	db $91 
	db $91 
	db $91 
	db $91 
	db $9F 
	db $F1 
	db $51 
	db $51 
	db $51 
	db $51 
	db $5F 
	db $F1 
	db $F1 
	db $F1 
	db $F1 
	db $F1 
	db $FF 
	db $F1 
	db $51 
	db $51 
	db $51 
	db $51 
	db $5F 
	db $F1 
	db $91 
	db $91 
	db $91 
	db $91 
	db $9F 
	db $F1 
	db $51 
	db $51 
	db $51 
	db $51 
	db $5F 
	db $F1 
	db $31 
	db $31 
	db $31 
	db $31 
	db $3F 
	db $F1 
	db $51 
	db $51 
	db $51 
	db $51 
	db $5F 
	db $F1 
	db $91 
	db $91 
	db $91 
	db $91 
	db $9F 
	db $F1 
	db $51 
	db $51 
	db $51 
	db $51 
	db $5F 
	db $FF 
	db $CF 
	db $CF 
	db $CF 
	db $CF 
	db $CF 
	db $FC 
	db $54 
	db $54 
	db $54 
	db $54 
	db $57 
	db $FC 
	db $64 
	db $64 
	db $64 
	db $64 
	db $67 
	db $FC 
	db $54 
	db $54 
	db $54 
	db $54 
	db $57 
	db $FC 
	db $4C 
	db $4C 
	db $4C 
	db $4C 
	db $4F 
	db $FC 
	db $54 
	db $54 
	db $54 
	db $54 
	db $57 
	db $FC 
	db $64 
	db $64 
	db $64 
	db $64 
	db $67 
	db $FC 
	db $54 
	db $54 
	db $54 
	db $54 
	db $57 
	db $FC 
	db $7C 
	db $7C 
	db $7C 
	db $7C 
	db $7F 
	db $FC 
	db $54 
	db $54 
	db $54 
	db $54 
	db $57 
	db $FC 
	db $64 
	db $64 
	db $64 
	db $64 
	db $67 
	db $FC 
	db $54 
	db $54 
	db $54 
	db $54 
	db $57 
	db $FC 
	db $4C 
	db $4C 
	db $4C 
	db $4C 
	db $4F 
	db $FC 
	db $54 
	db $54 
	db $54 
	db $54 
	db $57 
	db $FC 
	db $64 
	db $64 
	db $64 
	db $64 
	db $67 
	db $FC 
	db $54 
	db $54 
	db $54 
	db $54 
	db $57 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $E0 
	db $C3 
	db $F0 
	db $7F 
	db $E0 
	db $7F 
	db $DA 
	db $28 
	db $CC 
	db $7F 
	db $9A 
	db $3F 
	db $DD 
	db $40 
	db $CE 
	db $3F 
	db $3C 
	db $BF 
	db $BA 
	db $00 
	db $4C 
	db $3F 
	db $70 
	db $3F 
	db $BC 
	db $00 
	db $50 
	db $3F 
	db $20 
	db $3F 
	db $B0 
	db $00 
	db $40 
	db $3F 
	db $90 
	db $BF 
	db $70 
	db $02 
	db $68 
	db $3F 
	db $80 
	db $BF 
	db $20 
	db $00 
	db $7C 
	db $3F 
	db $50 
	db $BF 
	db $50 
	db $00 
	db $E6 
	db $7F 
	db $40 
	db $7F 
	db $20 
	db $82 
	db $C3 
	db $FF 
	db $00 
	db $3F 
	db $40 
	db $00 
	db $C8 
	db $FF 
	db $20 
	db $3F 
	db $21 
	db $06 
	db $40 
	db $3F 
	db $40 
	db $3F 
	db $41 
	db $2B 
	db $50 
	db $3F 
	db $71 
	db $3F 
	db $22 
	db $16 
	db $68 
	db $3F 
	db $28 
	db $7F 
	db $83 
	db $E0 
	db $E0 
	db $7F 
	db $80 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $F8 
	db $30 
	db $FC 
	db $1F 
	db $F8 
	db $1F 
	db $F6 
	db $8A 
	db $33 
	db $1F 
	db $E6 
	db $8F 
	db $F7 
	db $50 
	db $33 
	db $8F 
	db $CF 
	db $2F 
	db $EE 
	db $80 
	db $13 
	db $0F 
	db $DC 
	db $0F 
	db $EF 
	db $00 
	
function_F800:
	db $14 
	db $0F 
	db $C8 
	db $0F 
	db $EC 
	db $00 
	db $10 
	db $0F 
	db $E4 
	db $2F 
	db $DC 
	db $00 
	db $9A 
	db $0F 
	db $E0 
	db $2F 
	db $C8 
	db $00 
	db $1F 
	db $0F 
	db $D4 
	db $2F 
	db $D4 
	db $00 
	db $39 
	db $9F 
	db $D0 
	db $1F 
	db $C8 
	db $20 
	db $B0 
	db $FF 
	db $C0 
	db $0F 
	db $D0 
	db $00 
	db $32 
	db $3F 
	db $C8 
	db $0F 
	db $C8 
	db $41 
	db $90 
	db $0F 
	db $D0 
	db $0F 
	db $D0 
	db $4A 
	db $D4 
	db $0F 
	db $DC 
	db $4F 
	db $C8 
	db $85 
	db $9A 
	db $0F 
	db $CA 
	db $1F 
	db $E0 
	db $F8 
	db $38 
	db $1F 
	db $E0 
	db $3F 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FE 
	db $0C 
	db $3F 
	db $07 
	db $FE 
	db $07 
	db $FD 
	db $A2 
	db $8C 
	db $C7 
	db $F9 
	db $A3 
	db $FD 
	db $D4 
	db $0C 
	db $E3 
	db $F3 
	db $CB 
	db $FB 
	db $A0 
	db $04 
	db $C3 
	db $F7 
	db $03 
	db $FB 
	db $C0 
	db $05 
	db $03 
	db $F2 
	db $03 
	db $FB 
	db $00 
	db $04 
	db $03 
	db $F9 
	db $0B 
	db $F7 
	db $00 
	db $26 
	db $83 
	db $F8 
	db $0B 
	db $F2 
	db $00 
	db $07 
	db $C3 
	db $F5 
	db $0B 
	db $F5 
	db $00 
	db $0E 
	db $67 
	db $F4 
	db $07 
	db $F2 
	db $08 
	db $2C 
	db $3F 
	db $F0 
	db $03 
	db $F4 
	db $00 
	db $0C 
	db $8F 
	db $F2 
	db $03 
	db $F2 
	db $10 
	db $64 
	db $03 
	db $F4 
	db $03 
	db $F4 
	db $12 
	db $B5 
	db $03 
	db $F7 
	db $13 
	db $F2 
	db $21 
	db $66 
	db $83 
	db $F2 
	db $87 
	db $F8 
	db $3E 
	db $0E 
	db $07 
	db $F8 
	db $0F 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $83 
	db $0F 
	db $C1 
	db $FF 
	db $81 
	db $FF 
	db $68 
	db $A3 
	db $31 
	db $FE 
	db $68 
	db $FF 
	db $75 
	db $03 
	db $38 
	db $FC 
	db $F2 
	db $FE 
	db $E8 
	db $01 
	db $30 
	db $FD 
	db $C0 
	db $FE 
	db $F0 
	db $01 
	db $40 
	db $FC 
	db $80 
	db $FE 
	db $C0 
	db $01 
	db $00 
	db $FE 
	db $42 
	db $FD 
	db $C0 
	db $09 
	db $A0 
	db $FE 
	db $02 
	db $FC 
	db $80 
	db $01 
	db $F0 
	db $FD 
	db $42 
	db $FD 
	db $40 
	db $03 
	db $99 
	db $FD 
	db $01 
	db $FC 
	db $82 
	db $0B 
	db $0F 
	db $FC 
	db $00 
	db $FD 
	db $00 
	db $03 
	db $23 
	db $FC 
	db $80 
	db $FC 
	db $84 
	db $19 
	db $00 
	db $FD 
	db $00 
	db $FD 
	db $04 
	db $AD 
	db $40 
	db $FD 
	db $C4 
	db $FC 
	db $88 
	db $59 
	db $A0 
	db $FC 
	db $A1 
	db $FE 
	db $0F 
	db $83 
	db $81 
	db $FE 
	db $03 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FE 
	db $43 
	db $C0 
	db $03 
	db $C2 
	db $7F 
	db $FF 
	db $FE 
	db $7F 
	db $FE 
	db $7F 
	db $FF 
	db $FC 
	db $43 
	db $C0 
	db $03 
	db $C2 
	db $3F 
	db $FF 
	db $C2 
	db $40 
	db $02 
	db $43 
	db $FF 
	db $FE 
	db $43 
	db $C0 
	db $03 
	db $C2 
	db $7F 
	db $FE 
	db $7F 
	db $FF 
	db $FF 
	db $FE 
	db $7F 
	db $FE 
	db $7F 
	db $FF 
	db $FF 
	db $FE 
	db $7F 
	db $FE 
	db $7F 
	db $FF 
	db $FF 
	db $FE 
	db $7F 
	db $FE 
	db $7F 
	db $FF 
	db $FF 
	db $FE 
	db $7F 
	db $FE 
	db $7F 
	db $FF 
	db $FF 
	db $FE 
	db $7F 
	db $FE 
	db $7F 
	db $FF 
	db $FF 
	db $FE 
	db $7F 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FD 
	db $3F 
	db $FF 
	db $FF 
	db $FD 
	db $3F 
	db $FD 
	db $3F 
	db $FF 
	db $FF 
	db $FD 
	db $3F 
	db $FD 
	db $3F 
	db $FF 
	db $FF 
	db $FD 
	db $3F 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $90 
	db $F0 
	db $00 
	db $F0 
	db $9F 
	db $FF 
	db $FF 
	db $9F 
	db $FF 
	db $9F 
	db $FF 
	db $FF 
	db $10 
	db $F0 
	db $00 
	db $F0 
	db $8F 
	db $FF 
	db $F0 
	db $90 
	db $00 
	db $90 
	db $FF 
	db $FF 
	db $90 
	db $F0 
	db $00 
	db $F0 
	db $9F 
	db $FF 
	db $9F 
	db $FF 
	db $FF 
	db $FF 
	db $9F 
	db $FF 
	db $9F 
	db $FF 
	db $FF 
	db $FF 
	db $9F 
	db $FF 
	db $9F 
	db $FF 
	db $FF 
	db $FF 
	db $9F 
	db $FF 
	db $9F 
	db $FF 
	db $FF 
	db $FF 
	db $9F 
	db $FF 
	db $9F 
	db $FF 
	db $FF 
	db $FF 
	db $9F 
	db $FF 
	db $9F 
	db $FF 
	db $FF 
	db $FF 
	db $9F 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $4F 
	db $FF 
	db $FF 
	db $FF 
	db $4F 
	db $FF 
	db $4F 
	db $FF 
	db $FF 
	db $FF 
	db $4F 
	db $FF 
	db $4F 
	db $FF 
	db $FF 
	db $FF 
	db $4F 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $E4 
	db $3C 
	db $00 
	db $3C 
	db $27 
	db $FF 
	db $FF 
	db $E7 
	db $FF 
	db $E7 
	db $FF 
	db $FF 
	db $C4 
	db $3C 
	db $00 
	db $3C 
	db $23 
	db $FF 
	db $FC 
	db $24 
	db $00 
	db $24 
	db $3F 
	db $FF 
	db $E4 
	db $3C 
	db $00 
	db $3C 
	db $27 
	db $FF 
	db $E7 
	db $FF 
	db $FF 
	db $FF 
	db $E7 
	db $FF 
	db $E7 
	db $FF 
	db $FF 
	db $FF 
	db $E7 
	db $FF 
	db $E7 
	db $FF 
	db $FF 
	db $FF 
	db $E7 
	db $FF 
	db $E7 
	db $FF 
	db $FF 
	db $FF 
	db $E7 
	db $FF 
	db $E7 
	db $FF 
	db $FF 
	db $FF 
	db $E7 
	db $FF 
	db $E7 
	db $FF 
	db $FF 
	db $FF 
	db $E7 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $D3 
	db $FF 
	db $FF 
	db $FF 
	db $D3 
	db $FF 
	db $D3 
	db $FF 
	db $FF 
	db $FF 
	db $D3 
	db $FF 
	db $D3 
	db $FF 
	db $FF 
	db $FF 
	db $D3 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $F9 
	db $0F 
	db $00 
	db $0F 
	db $09 
	db $FF 
	db $FF 
	db $F9 
	db $FF 
	db $F9 
	db $FF 
	db $FF 
	db $F1 
	db $0F 
	db $00 
	db $0F 
	db $08 
	db $FF 
	db $FF 
	db $09 
	db $00 
	db $09 
	db $0F 
	db $FF 
	db $F9 
	db $0F 
	db $00 
	db $0F 
	db $09 
	db $FF 
	db $F9 
	db $FF 
	db $FF 
	db $FF 
	db $F9 
	db $FF 
	db $F9 
	db $FF 
	db $FF 
	db $FF 
	db $F9 
	db $FF 
	db $F9 
	db $FF 
	db $FF 
	db $FF 
	db $F9 
	db $FF 
	db $F9 
	db $FF 
	db $FF 
	db $FF 
	db $F9 
	db $FF 
	db $F9 
	db $FF 
	db $FF 
	db $FF 
	db $F9 
	db $FF 
	db $F9 
	db $FF 
	db $FF 
	db $FF 
	db $F9 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $F4 
	db $FF 
	db $FF 
	db $FF 
	db $F4 
	db $FF 
	db $F4 
	db $FF 
	db $FF 
	db $FF 
	db $F4 
	db $FF 
	db $F4 
	db $FF 
	db $FF 
	db $FF 
	db $F4 
	db $E9 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $B8 
	db $7F 
	db $FE 
	db $7F 
	db $FE 
	db $7F 
	db $70 
	db $3F 
	db $FE 
	db $7F 
	db $FE 
	db $7F 
	db $FF 
	db $FF 
	db $FE 
	db $7F 
	db $FE 
	db $7F 
	db $BA 
	db $7F 
	db $FE 
	db $7F 
	db $FE 
	db $7F 
	db $BA 
	db $7F 
	db $E6 
	db $7F 
	db $FE 
	db $7F 
	db $BA 
	db $7F 
	db $EF 
	db $FF 
	db $FE 
	db $7F 
	db $3A 
	db $3F 
	db $E5 
	db $3F 
	db $FE 
	db $7F 
	db $3A 
	db $3F 
	db $AD 
	db $3F 
	db $FE 
	db $7F 
	db $BA 
	db $7F 
	db $AD 
	db $3F 
	db $FE 
	db $7F 
	db $BA 
	db $7F 
	db $E5 
	db $3F 
	db $FE 
	db $7F 
	db $BA 
	db $7F 
	db $EF 
	db $FF 
	db $FE 
	db $7F 
	db $BA 
	db $7F 
	db $E6 
	db $7F 
	db $FF 
	db $FF 
	db $BA 
	db $7F 
	db $FE 
	db $7F 
	db $FD 
	db $3F 
	db $FF 
	db $FF 
	db $FE 
	db $7F 
	db $FD 
	db $3F 
	db $70 
	db $3F 
	db $FE 
	db $7F 
	db $FD 
	db $3F 
	db $FA 
	db $7F 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $EE 
	db $1F 
	db $FF 
	db $9F 
	db $FF 
	db $9F 
	db $DC 
	db $0F 
	db $FF 
	db $9F 
	db $FF 
	db $9F 
	db $FF 
	db $FF 
	db $FF 
	db $9F 
	db $FF 
	db $9F 
	db $EE 
	db $9F 
	db $FF 
	db $9F 
	db $FF 
	db $9F 
	db $EE 
	db $9F 
	db $F9 
	db $9F 
	db $FF 
	db $9F 
	db $EE 
	db $9F 
	db $FB 
	db $FF 
	db $FF 
	db $9F 
	db $CE 
	db $8F 
	db $F9 
	db $4F 
	db $FF 
	db $9F 
	db $CE 
	db $8F 
	db $EB 
	db $4F 
	db $FF 
	db $9F 
	db $EE 
	db $9F 
	db $EB 
	db $4F 
	db $FF 
	db $9F 
	db $EE 
	db $9F 
	db $F9 
	db $4F 
	db $FF 
	db $9F 
	db $EE 
	db $9F 
	db $FB 
	db $FF 
	db $FF 
	db $9F 
	db $EE 
	db $9F 
	db $F9 
	db $9F 
	db $FF 
	db $FF 
	db $EE 
	db $9F 
	db $FF 
	db $9F 
	db $FF 
	db $4F 
	db $FF 
	db $FF 
	db $FF 
	db $9F 
	db $FF 
	db $4F 
	db $DC 
	db $0F 
	db $FF 
	db $9F 
	db $FF 
	db $4F 
	db $FE 
	db $9F 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FB 
	db $87 
	db $FF 
	db $E7 
	db $FF 
	db $E7 
	db $F7 
	db $03 
	db $FF 
	db $E7 
	db $FF 
	db $E7 
	db $FF 
	db $FF 
	db $FF 
	db $E7 
	db $FF 
	db $E7 
	db $FB 
	db $A7 
	db $FF 
	db $E7 
	db $FF 
	db $E7 
	db $FB 
	db $A7 
	db $FE 
	db $67 
	db $FF 
	db $E7 
	db $FB 
	db $A7 
	db $FE 
	db $FF 
	db $FF 
	db $E7 
	db $F3 
	db $A3 
	db $FE 
	db $53 
	db $FF 
	db $E7 
	db $F3 
	db $A3 
	db $FA 
	db $D3 
	db $FF 
	db $E7 
	db $FB 
	db $A7 
	db $FA 
	db $D3 
	db $FF 
	db $E7 
	db $FB 
	db $A7 
	db $FE 
	db $53 
	db $FF 
	db $E7 
	db $FB 
	db $A7 
	db $FE 
	db $FF 
	db $FF 
	db $E7 
	db $FB 
	db $A7 
	db $FE 
	db $67 
	db $FF 
	db $FF 
	db $FB 
	db $A7 
	db $FF 
	db $E7 
	db $FF 
	db $D3 
	db $FF 
	db $FF 
	db $FF 
	db $E7 
	db $FF 
	db $D3 
	db $F7 
	db $03 
	db $FF 
	db $E7 
	db $FF 
	db $D3 
	db $FF 
	db $A7 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FE 
	db $E1 
	db $FF 
	db $F9 
	db $FF 
	db $F9 
	db $FD 
	db $C0 
	db $FF 
	db $F9 
	db $FF 
	db $F9 
	db $FF 
	db $FF 
	db $FF 
	db $F9 
	db $FF 
	db $F9 
	db $FE 
	db $E9 
	db $FF 
	db $F9 
	db $FF 
	db $F9 
	db $FE 
	db $E9 
	db $FF 
	db $99 
	db $FF 
	db $F9 
	db $FE 
	db $E9 
	db $FF 
	db $BF 
	db $FF 
	db $F9 
	db $FC 
	db $E8 
	db $FF 
	db $94 
	db $FF 
	db $F9 
	db $FC 
	db $E8 
	db $FE 
	db $B4 
	db $FF 
	db $F9 
	db $FE 
	db $E9 
	db $FE 
	db $B4 
	db $FF 
	db $F9 
	db $FE 
	db $E9 
	db $FF 
	db $94 
	db $FF 
	db $F9 
	db $FE 
	db $E9 
	db $FF 
	db $BF 
	db $FF 
	db $F9 
	db $FE 
	db $E9 
	db $FF 
	db $99 
	db $FF 
	db $FF 
	db $FE 
	db $E9 
	db $FF 
	db $F9 
	db $FF 
	db $F4 
	db $FF 
	db $FF 
	db $FF 
	db $F9 
	db $FF 
	db $F4 
	db $FD 
	db $C0 
	db $FF 
	db $F9 
	db $FF 
	db $F4 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

SineTable:
	db $00 
	db $01 
	db $02 
	db $04 
	db $05 
	db $06 
	db $07 
	db $08 
	db $09 
	db $0A 
	db $0C 
	db $0D 
	db $0E 
	db $0F 
	db $10 
	db $11 
	db $12 
	db $14 
	db $15 
	db $16 
	db $17 
	db $18 
	db $19 
	db $1A 
	db $1B 
	db $1C 
	db $1D 
	db $1E 
	db $1F 
	db $20 
	db $21 
	db $22 
	db $23 
	db $24 
	db $25 
	db $26 
	db $27 
	db $28 
	db $29 
	db $2A 
	db $2B 
	db $2C 
	db $2D 
	db $2D 
	db $2E 
	db $2F 
	db $30 
	db $31 
	db $31 
	db $32 
data_FC32:
	db $33 
	db $34 
	db $34 
	db $35 
	db $36 
	db $36 
	db $37 
	db $38 
	db $38 
	db $39 
	db $39 
	db $3A 
	db $3A 
	db $3B 
	db $3B 
	db $3C 
	db $3C 
	db $3D 
	db $3D 
	db $3E 
	db $3E 
	db $3E 
	db $3F 
	db $3F 
	db $3F 
	db $3F 
	db $40 
	db $40 
	db $40 
	db $40 
	db $40 
	db $41 
	db $41 
	db $41 
	db $41 
	db $41 
	db $41 
	db $41 
	db $41 
	db $41 
data_FC5A:
	db $41 
	db $41 
	db $41 
	db $41 
	db $41 
	db $40 
	db $40 
	db $40 
	db $40 
	db $40 
	db $3F 
	db $3F 
	db $3F 
	db $3E 
	db $3E 
	db $3E 
	db $3D 
	db $3D 
	db $3D 
	db $3C 
	db $3C 
	db $3B 
	db $3B 
	db $3A 
	db $3A 
	db $39 
	db $38 
	db $38 
	db $37 
	db $37 
	db $36 
	db $35 
	db $35 
	db $34 
	db $33 
	db $33 
	db $32 
	db $31 
	db $30 
	db $30 
	db $2F 
	db $2E 
	db $2D 
	db $2C 
	db $2B 
	db $2A 
	db $2A 
	db $29 
	db $28 
	db $27 
	db $26 
	db $25 
	db $24 
	db $23 
	db $22 
	db $21 
	db $20 
	db $1F 
	db $1E 
	db $1D 
	db $1C 
	db $1B 
	db $1A 
	db $19 
	db $17 
	db $16 
	db $15 
	db $14 
	db $13 
	db $12 
	db $11 
	db $10 
	db $0F 
	db $0D 
	db $0C 
	db $0B 
	db $0A 
	db $09 
	db $08 
	db $06 
	db $05 
	db $04 
	db $03 
	db $02 
	db $01 
	db $00 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
; Core game variables.
;
; Pointed at via IY.  Can be addressed directly, or via a IY+<V_xxxxxx> variable offset
;

	org $fcb0

Variables:
Variables_ScrnX:
	db $09 			; scrnx
Variables_ScrnY:
	db $12 			; scrny
Variables_Direct:
	db $02 			; direction
	db $00 			; sysflag
Variables_TabXPos:
	db $09 			; tabxpos
Variables_Attr:
	db $FF 			; attr
Variables_Chars:
	dw Charset		; charset
Variables_High:
	db $02 
FUDLR:
	db $00 
LastPlayerDir:
	db $00 
HeadButtCounter:
	db $00 
PlayerInAir:			; $00, $35 (jump), $5a (fall)
	db $00 
PlayerJumpFallIndex:
	db $00 
PlayerJumpFallYStart:
	db $00 
PlayerWeapon:
	db $00 
PlayerWeaponInFlight:
	db $00 
KnifeYIndex:
	db $00 
KnifeYStart:
	db $00 
BulletFireDelay:
	db $00 
PlayerFireJiggle:			; jiggles the player Y +-2 pixels when firing
	db $00 
	db $00 
StarIndex:
	db $00 
StarUpdateDelay:
	db $02 
DuckOn:
	db $00 
FrameCounter:			; framerate counter
	db $00 
FireDebounce:
	db $00 
InvulnerableCount:
	db $00 
	db $00 
	db $00 
GirlfriendOnScreen:
	db $00 
GirlfriendIsLeaving:
	db $00 
ProjectileFireDelayCounter:
	db $04 
StunnedCounter:
	db $00 
GirlfriendStatus:
	db $00 
PlayerLostLife:
	db $FF 
GirlfriendFoundPlayer:
	db $00 
AllBaddiesKilled:
	db $00 
LevelEndCountdown:
	db $00 
NightSlasherFlag:
	db $00 
NumLives:
	db $00 
ColourMonoFlag:
	db $00 
SoundsMuteFlag:
	db $00 
ProjectileSpeed:
	db $04 
BurgerWeaponAdjust:
	db $00 
RoundNumber:
	db $00 
ProjectileFireDelay:
	db $19 
ControlMethod:
	db $01 
RND1:
	db $74 
RND2:
	db $4E 
RND3:
	db $80 
GirlfriendEnterX:
	db $06 
BurgerCount:
	db $04 
InitialGirlfriendCountdown:
	dw $0271
GirlfriendCountdown:
	dw $0499
RandomNumMask:
	db $1F 


	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 
	db $FF 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

gfx_CobraLogo:
	db $FF 
	db $7D 
	db $C0 
	db $7C 
	db $0F 
	db $FE 
	db $0F 
	db $FE 
	db $00 
	db $03 
	db $FC 
	db $00 
	db $01 
	db $FF 
	db $C1 
	db $FF 
	db $0F 
	db $FF 
	db $8F 
	db $FF 
	db $80 
	db $03 
	db $FC 
	db $00 
	db $03 
	db $FF 
	db $C3 
	db $FF 
	db $8F 
	db $FF 
	db $CF 
	db $FF 
	db $C0 
	db $03 
	db $FC 
	db $00 
	db $07 
	db $FF 
	db $C7 
	db $FF 
	db $CF 
	db $FF 
	db $EF 
	db $FF 
	db $E0 
	db $03 
	db $FC 
	db $00 
	db $07 
	db $FF 
	db $C7 
	db $FF 
	db $C7 
	db $FF 
	db $E7 
	db $FF 
	db $E0 
	db $07 
	db $FE 
	db $00 
	db $0F 
	db $EF 
	db $CF 
	db $EF 
	db $E3 
	db $F7 
	db $F3 
	db $F7 
	db $F0 
	db $07 
	db $FE 
	db $00 
	db $0F 
	db $C7 
	db $CF 
	db $C7 
	db $E3 
	db $F3 
	db $F3 
	db $F3 
	db $F0 
	db $07 
	db $FE 
	db $00 
	db $0F 
	db $C7 
	db $CF 
	db $C7 
	db $E3 
	db $F3 
	db $F3 
	db $F3 
	db $F0 
	db $07 
	db $FE 
	db $00 
	db $1F 
	db $C7 
	db $DF 
	db $C7 
	db $F3 
	db $F3 
	db $F3 
	db $F3 
	db $F0 
	db $0F 
	db $BF 
	db $00 
	db $1F 
	db $C7 
	db $DF 
	db $C7 
	db $F3 
	db $F3 
	db $F3 
	db $F3 
	db $F0 
	db $0F 
	db $BF 
	db $00 
	db $1F 
	db $C7 
	db $DF 
	db $C7 
	db $F3 
	db $F7 
	db $F3 
	db $F7 
	db $F0 
	db $0F 
	db $BF 
	db $00 
	db $1F 
	db $C0 
	db $1F 
	db $C7 
	db $F3 
	db $FF 
	db $E3 
	db $FF 
	db $E0 
	db $0F 
	db $BF 
	db $00 
	db $1F 
	db $C0 
	db $1F 
	db $C7 
	db $F3 
	db $FF 
	db $C3 
	db $FF 
	db $C0 
	db $1F 
	db $1F 
	db $80 
	db $3F 
	db $C0 
	db $1F 
	db $C7 
	db $F3 
	db $FF 
	db $E3 
	db $FF 
	db $E0 
	db $1F 
	db $1F 
	db $80 
	db $1F 
	db $C7 
	db $DF 
	db $C7 
	db $F3 
	db $F7 
	db $E3 
	db $F7 
	db $E0 
	db $1F 
	db $1F 
	db $80 
	db $1F 
	db $C7 
	db $DF 
	db $C7 
	db $F3 
	db $F3 
	db $F3 
	db $F3 
	db $F0 
	db $1F 
	db $FF 
	db $80 
	db $1F 
	db $C7 
	db $DF 
	db $C7 
	db $F3 
	db $F3 
	db $F3 
	db $F3 
	db $F0 
	db $3F 
	db $FF 
	db $C0 
	db $1F 
	db $C7 
	db $DF 
	db $C7 
	db $F3 
	db $F3 
	db $F3 
	db $F3 
	db $F0 
	db $3F 
	db $FF 
	db $C0 
	db $0F 
	db $C7 
	db $CF 
	db $C7 
	db $E3 
	db $F3 
	db $F3 
	db $F3 
	db $F0 
	db $3E 
	db $0F 
	db $C0 
	db $0F 
	db $C7 
	db $CF 
	db $C7 
	db $E3 
	db $F3 
	db $F3 
	db $F3 
	db $F0 
	db $3E 
	db $0F 
	db $C0 
	db $0F 
	db $EF 
	db $CF 
	db $EF 
	db $E3 
	db $F7 
	db $F3 
	db $F3 
	db $F6 
	db $7E 
	db $0F 
	db $E0 
	db $07 
	db $FF 
	db $C7 
	db $FF 
	db $C7 
	db $FF 
	db $E7 
	db $FB 
	db $FE 
	db $FF 
	db $1F 
	db $F0 
	db $07 
	db $FF 
	db $87 
	db $FF 
	db $CF 
	db $FF 
	db $EF 
	db $FF 
	db $FF 
	db $FF 
	db $BF 
	db $F8 
	db $03 
	db $FF 
	db $83 
	db $FF 
	db $8F 
	db $FF 
	db $CF 
	db $FD 
	db $FF 
	db $FF 
	db $BF 
	db $F8 
	db $01 
	db $FF 
	db $01 
	db $FF 
	db $0F 
	db $FF 
	db $8F 
	db $FD 
	db $FD 
	db $FF 
	db $BF 
	db $F8 
	db $00 
	db $7C 
	db $00 
	db $7C 
	db $0F 
	db $FE 
	db $0F 
	db $FC 
	db $79 
	db $FF 
	db $BF 
	db $F8 

gfx_WarnerLogo:
	db $01 
	db $C0 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $02 
	db $21 
	db $77 
	db $21 
	db $10 
	db $00 
	db $00 
	db $18 
	db $00 
	db $01 
	db $C0 
	db $00 
	db $05 
	db $D1 
	db $55 
	db $41 
	db $10 
	db $00 
	db $00 
	db $14 
	db $00 
	db $00 
	db $80 
	db $00 
	db $05 
	db $11 
	db $77 
	db $71 
	db $51 
	db $77 
	db $37 
	db $19 
	db $DC 
	db $C0 
	db $9D 
	db $C0 
	db $05 
	db $D1 
	db $15 
	db $51 
	db $B3 
	db $45 
	db $74 
	db $15 
	db $14 
	db $80 
	db $95 
	db $00 
	db $02 
	db $21 
	db $27 
	db $71 
	db $15 
	db $45 
	db $44 
	db $19 
	db $1D 
	db $91 
	db $D5 
	db $D0 
	db $01 
	db $C0 
	db $00 
	db $00 
	db $00 
	db $00 
	db $20 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $00 
	db $3E 
	db $08 
	db $08 
	db $08 
	db $08 
	db $3E 
	db $00 
	db $00 
	db $02 
	db $02 
	db $02 
	db $42 
	db $42 
	db $3C 
	db $00 
	db $00 
	db $44 
	db $48 
	db $70 
	db $48 
	db $44 
	db $42 
	db $00 
	db $00 
	db $40 
	db $40 
	db $40 
	db $40 
	db $40 
	db $7E 
	db $00 
	db $00 
	db $42 
	db $66 
	db $5A 
	db $42 
	db $42 
	db $42 
	db $00 
	db $00 
	db $42 
	db $62 
	db $52 
	db $4A 
	db $46 
	db $42 
	db $00 
	db $00 
	db $3C 
	db $42 
	db $42 
	db $42 
	db $42 
	db $3C 
	db $00 
	db $00 
	db $7C 
	db $42 
	db $42 
	db $7C 
	db $40 
	db $40 
	db $00 
	db $00 
	db $3C 
	db $42 
	db $42 
	db $52 
	db $4A 
	db $3C 
	db $00 
	db $00 
	db $7C 
	db $42 
	db $42 
	db $7C 
	db $44 
	db $42 
	db $00 
	db $00 
	db $3C 
	db $40 
	db $3C 
	db $02 
	db $42 
	db $3C 
	db $00 
	db $00 
	db $FE 
	db $10 
	db $10 


;	org $fff4
;label_FFF4:
;	JP   OurDrumInt
;	db $80 
;	db $40 
;	db $20 
;	db $10 
;	db $08 
;	db $04 
;	db $02 
;	db $01 
;	db $24

;
; END
;

	SAVESNA "cobra.sna", Start
	
	

	