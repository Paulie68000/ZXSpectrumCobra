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
	cspectmap

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

NO_BADDY_COLLISIONS		equ 0

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

SYSBorder 	equ 	0x5C48				; Used by ROM beeper!
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
	db $18,$05,$1b,$0f,$1d,$37,$00,$05,$1d,$05,$1f,$0f,$18,$05,$00,$05
	db $18,$05,$00,$05,$24,$05,$18,$05,$00,$05,$18,$0a,$ff

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

Tune_RoundStartDrums:
	db $2a,$0a,$4a,$0a,$2a,$0a,$45,$2a,$25,$2a,$0a,$4a,$25,$25,$8a,$25

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

Tune_LoseLife:
	db $32 
	db $01 
	dw Tune_RoundStartDrums
	db $24,$05,$1f,$05,$1b,$05,$18,$05,$1f,$05,$1b,$05,$18,$05,$13,$05
	db $1b,$05,$18,$05,$13,$05,$0f,$05,$0c,$05,$ff

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
	db $18,$05,$00,$0a,$24,$05,$00,$0a,$22,$05,$00,$05,$22,$05,$24,$05
	db $00,$0a,$1f,$05,$00,$0a,$24,$05,$00,$0a,$1b,$05,$00,$05,$1b,$05
	db $1f,$05,$1b,$05,$1a,$05,$18,$05,$ff

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

Tune_GameUnderDrums:
	db $3e,$5e,$39,$25,$4a,$25,$45,$25,$25,$8a,$25,$84,$08,$44,$86,$84
	db $08,$64,$86,$02,$0e,$02,$0e,$02,$06,$02,$06,$02,$0e,$88,$22,$26
	db $02,$06,$22,$26,$02,$06,$42,$42,$44,$02,$06,$02,$06,$22,$26,$02
	db $06,$22,$26,$22,$26,$02,$06,$42,$42,$44,$88,$80,$de,$84,$02,$06
	db $22,$26,$02,$06,$80,$de,$84,$22,$26,$02,$06,$22,$26,$80,$de,$84
	db $02,$06,$22,$26,$02,$06,$82,$de,$84,$80,$fb,$84,$62,$66,$80,$26
	db $85,$80,$fb,$84,$22,$26,$62,$66,$62,$66,$88,$80,$44,$85,$08,$28
	db $08,$80,$44,$85,$28,$08,$28,$80,$44,$85,$08,$28,$08,$80,$44,$85
	db $28,$48,$48,$88,$28,$08,$28,$08,$48,$08,$08,$28,$08,$28,$28,$08
	db $48,$88

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

Tune_TitlesDrums:
	db $80,$cb,$84,$80,$19,$85,$80,$cb,$84,$84,$04,$80,$2b,$85,$86,$8a
	db $24,$80,$2b,$85,$8a,$24,$80,$cb,$84,$8a,$24,$84,$04,$22,$22,$24
	db $02,$06,$86,$42,$42,$44,$22,$26,$84,$02,$42,$42,$44,$42,$42,$44
	db $22,$26,$86,$82,$55,$85,$84,$04,$22,$22,$24,$86,$84,$03,$42,$42
	db $44,$86,$22,$22,$24,$84,$04,$28,$86,$84,$04,$62,$66,$86,$02,$8a
	db $04,$84,$04,$22,$26,$86,$42,$46,$02,$06,$84,$02,$22,$26,$22,$26
	db $02,$06,$86,$62,$66,$22,$26,$42,$46,$42,$46,$02,$8a,$04,$24,$01
	db $21,$01,$1b,$01,$18,$01,$00,$04,$ff,$24,$01,$1f,$01,$1b,$01,$18
	db $01,$00,$04,$ff,$22,$01,$21,$01,$1b,$01,$16,$01,$00,$04,$ff,$22
	db $01,$1f,$01,$1b,$01,$16,$01,$00,$04,$ff,$2e,$03,$28,$c0,$85,$18
	db $04,$00,$04,$30,$2e,$02,$24,$04,$00,$04,$28,$c0,$85,$30,$18,$04
	db $00,$04,$24,$04,$00,$04,$28,$c0,$85,$2e,$03,$18,$04,$00,$04,$30
	db $ff,$28,$cb,$85,$18,$04,$00,$04,$2e,$04,$28,$cb,$85,$30,$2e,$02
	db $24,$04,$00,$04,$28,$cb,$85,$30,$2e,$02,$28,$cb,$85,$24,$04,$00
	db $04,$30,$2e,$02,$18,$04,$00,$04,$30,$ff,$2e,$03,$28,$d6,$85,$1b
	db $04,$00,$04,$30,$2e,$02,$27,$04,$00,$04,$28,$d6,$85,$30,$1b,$04
	db $00,$04,$27,$04,$00,$04,$28,$d6,$85,$2e,$03,$1b,$04,$00,$04,$30
	db $ff,$28,$e1,$85,$1b,$04,$00,$04,$2e,$04,$28,$e1,$85,$30,$2e,$02
	db $27,$04,$00,$04,$28,$e1,$85,$30,$2e,$02,$28,$e1,$85,$27,$04,$00
	db $04,$30,$2e,$02,$1b,$04,$00,$04,$30,$ff,$28,$c0,$85,$00,$08,$2e
	db $04,$24,$01,$21,$01,$1b,$01,$18,$01,$30,$2e,$03,$28,$c0,$85,$30
	db $00,$08,$2e,$02,$28,$c0,$85,$30,$00,$08,$28,$c0,$85,$00,$20,$ff
	db $2e,$02,$28,$c0,$85,$28,$c0,$85,$00,$10,$30,$28,$c0,$85,$28,$c0
	db $85,$00,$08,$28,$c0,$85,$00,$20,$ff,$2c,$ec,$85,$13,$86,$3c,$86
	db $63,$86,$ff,$ff

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

Tune_Titles:
	db $32 
	db $01 
	dw Tune_TitlesDrums
	db $2e,$09,$00,$80,$30,$01,$01,$34,$18,$fc,$66,$2e,$02,$2e,$10,$28
	db $c0,$85,$30,$2e,$10,$28,$cb,$85,$30,$2e,$10,$28,$d6,$85,$30,$2e
	db $10,$28,$e1,$85,$30,$30,$2e,$03,$28,$cb,$86,$30,$32,$01,$63,$85
	db $28,$cb,$86,$28,$8c,$86,$32,$01,$68,$85,$00,$80,$28,$b2,$86,$32
	db $01,$88,$85,$00,$80,$28,$8c,$86,$32,$01,$a3,$85,$00,$80,$28,$b2
	db $86,$32,$01,$6d,$85,$2a,$da,$86

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;
Tune_Pause:
	db $32 
	db $01 
	dw Tune_PauseDrums
	db $00,$01,$2a,$36,$87,$32,$6c,$66,$52,$6c,$66,$88,$2c,$66,$06,$66
	db $06,$4c,$66,$06,$66,$06,$88,$84,$04,$80,$3b,$87,$86,$84,$03,$80
	db $42,$87,$86,$88,$22,$30,$62,$6a,$62,$64,$42,$50,$62,$6a,$62,$64
	db $88,$22,$2a,$62,$64,$62,$04,$62,$64,$62,$04,$42,$42,$48,$62,$64
	db $62,$04,$62,$64,$62,$04,$88,$84,$04,$80,$5a,$87,$86,$84,$03,$80
	db $67,$87,$86,$88,$2c,$66,$66,$26,$26,$06,$26,$06,$26,$06,$06,$88
	db $06,$26,$06,$26,$06,$06,$66,$66,$66,$6c,$66,$88

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;
Tune_PauseDrums:
	db $84,$08,$80,$4d,$87,$80,$8a,$87,$80,$4d,$87,$80,$96,$87,$86,$84
	db $08,$80,$7d,$87,$80,$8a,$87,$80,$7d,$87,$80,$96,$87,$86,$82,$a2
	db $87,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$1f,$1b
	db $1f,$1b,$00,$1b,$1e,$1b,$1d,$36,$1f,$1b,$00,$1b,$1f,$1b,$1f,$1b
	db $00,$1b,$00,$1b,$19,$9f,$1a,$9f,$1b,$9f,$00,$3f,$00,$3f,$00,$3f
	db $00,$3f,$00,$3f,$00,$3f,$00,$3f,$00,$3f,$07,$b6,$07,$9b
	
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
; PAGE $80 
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
	
data_8800:				; PAGE $88

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
	org $8900		; PAGE $89

PushMapEven:

	ds 240,0

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
; Tileset2Code - This code is copied into the generated even/odd code when we want to switch
;				 to a second tileset on a horizontal row. 
;

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
	org $8a00			; PAGE $8A
	
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

AttrLineTable:	
	db $03,$58
	db $23,$58
	db $43,$58
	db $63,$58
	db $83,$58
	db $a3,$58
	db $c3,$58
	db $e3,$58
	db $03,$59
	db $23,$59
	db $43,$59
	db $63,$59
	db $83,$59
	db $a3,$59
	db $c3,$59
	db $e3,$59

AttrLineTable2:	
	db $1d,$58
	db $3d,$58
	db $5d,$58
	db $7d,$58
	db $9d,$58
	db $bd,$58
	db $dd,$58
	db $fd,$58
	db $1d,$59
	db $3d,$59
	db $5d,$59
	db $7d,$59
	db $9d,$59
	db $bd,$59
	db $dd,$59
	db $fd,$59

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

	ds 240,0

SP_StoreMap:
	dw	$4FF5 

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
	db $00,$fb,$ed,$e0,$d3,$c7,$bc,$b2,$a8,$9e,$95,$8d,$85,$7e,$76,$70
	db $6a,$64,$5e,$59,$54,$4f,$4b,$46,$43,$3f
	
StarPositions:
	db $94,$48,$69,$4a,$f3,$46,$bb,$48,$57,$46,$04,$4a,$c5,$40,$bd,$46

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
	
	if NO_BADDY_COLLISIONS != 1
	XOR  A						; yes, lose the weapon, not a life
	CALL SetWeapon
	LD   A,$04					; weapon gone jingle
	CALL PlayBeepJingle
	endif

	JR   SetStunned				; and stun you for good measure

NoWeapon:
	LD   A,(GirlfriendStatus)
	OR   A
	JR   NZ,WithGirlfriend

PlayerLosesALife:
	if NO_BADDY_COLLISIONS == 1
	RET
	endif

	DEC  A
	LD   (PlayerLostLife),A
	JR   DoSpriteExplode

WithGirlfriend:					; if player is with his girlfriend when hit, he loses her, not a life
	PUSH IX
	LD   IX,(GirlfriendSpriteAddress)
	CALL LoseGirfriend
	POP  IX

SetStunned:
	if NO_BADDY_COLLISIONS != 1
	LD   (IY+V_STUNNEDCOUNTER),$14			; IY+StunnedCounter
	endif
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
	db $18,$04,$10,$03,$18,$02,$10,$02,$18,$02,$10,$02,$1c,$04,$18,$04
	db $1c,$04,$1f,$04,$24,$0c

Jingle6:
	db $12,$01,$13,$01,$14,$01,$15,$01,$16,$01,$17,$01,$18,$01,$19,$01
	db $16,$01,$17,$01,$18,$01,$19,$01,$1a,$01,$1b,$01,$1c,$01,$1d,$01
	db $1f,$04,$1d,$04,$1c,$04,$1a,$04,$18,$0c,$ff

Jingle2:
	db $1c,$04,$1d,$04,$1c,$04,$1a,$04,$10,$04,$1f,$04,$18,$0d,$ff

Jingle3:
	db $24,$04,$18,$04,$1b,$04,$1f,$04,$20,$04,$1f,$04,$1b,$04,$1a,$04
	db $18,$06,$ff

Jingle4:
	db $1a,$01,$1b,$03,$10,$08,$17,$01,$18,$03,$10,$04,$1c,$01,$1d,$03
	db $1a,$01,$1b,$03,$10,$08,$17,$01,$18,$03,$10,$08,$1a,$01,$1b,$03
	db $10,$04,$1a,$01,$1b,$03,$17,$01,$18,$03,$10,$04,$1c,$01,$1d,$03
	db $1a,$01,$1b,$03,$10,$08,$17,$01,$18,$03,$ff

Jingle5:
	db $19,$03,$10,$01,$19,$03,$10,$05,$19,$03,$10,$01,$1b,$03,$10,$05
	db $1d,$03,$10,$05,$1e,$03,$10,$0d,$11,$10,$ff

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
	db $46,$46,$46,$46,$46,$46,$46,$46,$46,$46,$46,$46,$46,$46,$46,$46
	db $46,$46,$46,$46,$46,$46,$46,$46,$46
	
gfx_CobraSnakeAttrs:
	db $07,$06,$06,$06,$07,$07,$06,$56,$06,$07,$07,$07,$46,$07,$07,$07
	db $07,$46,$07,$07,$07,$07,$46,$46,$07

gfx_UserYourHeadAttrs:
	db $07,$07,$42,$42,$07,$07,$47,$07,$42,$42,$07,$47,$47,$47,$42,$42
	db $47,$47

gfx_StartToStabAttrs:
	db $00,$00,$46,$47,$47,$00,$46,$72,$46,$47,$47,$45,$00,$42,$46,$47
	db $47,$00

gfx_ImTheCureAttrs:
	db $00,$45,$07,$07,$07,$00,$47,$47,$47,$45,$45,$00,$47,$4e,$47,$00
	db $00,$00

gfx_DontPushMeAttrs:
	db $42,$42,$05,$05,$47,$47,$42,$72,$45,$45,$45,$07,$42,$42,$07,$07
	db $07,$47

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
	LD   A,$FD			; page $FD00
	LD   I,A
	LD   HL,IM2Handler
	LD   DE,$FFF4
	LD   BC,$000C
	LDIR

	LD   HL,$FD00		; page $FD00 points to $FFFF
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
	LD   B,(Score & $ff) 	;$E7
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
	LD   H,(Score / $100 )		;$88; 88e7 Score text digits
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
	LD   DE,RightEdgeAttrs		;$A831
	JR   FillEdgeAttributes

FeedLeftEdge:			; feed left edge
	LD   A,(MapXPosAttr)
	INC  A
	LD   DE,LeftEdgeAttrs		;$A841
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

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

ScrollAttrLeftToRight:
	LD   HL,LeftEdgeAttrs				;$A841
	EXX 
	LD   HL,AttrLineTable				;$8A20
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

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

ScrollAttrRightToLeft:
	LD   HL,RightEdgeAttrs			;$A831
	EXX 
	LD   HL,AttrLineTable2			;$8A40
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
	
RightEdgeAttrs:
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
	
LeftEdgeAttrs:
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
	LD   HL,SinclairKeys	;$B4F7
	JR   SetJoy

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

MenuCursor:
	POP  HL
	LD   HL,CursorKeys		;$B4ED

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

SetJoy:
	LD   DE,KeyTab
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
	db $5d,$5c,$4d,$4e,$42
	db $5e,$4c,$4b,$4a,$48
	db $50,$4f,$49,$55,$59
	db $30,$39,$38,$37,$36
	db $31,$32,$33,$34,$35
	db $51,$57,$45,$52,$54
	db $41,$53,$44,$46,$47
	db $5b,$5a,$58,$43,$56

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
	
CursorKeys	
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
	
SinclairKeys	
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
	db $EF, $FE 
	db $F7, $FE 
	db $F7, $FD 
	db $F7, $FB 
	db $F7, $F7 
	db $F7, $EF 
	db $EF, $EF 
	db $EF, $F7 
	db $EF, $FB 
	db $EF, $FD 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;
	org $b5d0

gfx_Burger:
	db $ff,$00,$ff,$00,$ff,$00,$ff,$00,$03,$fc,$f0,$0f,$80,$78,$00,$07
	db $7f,$80,$3f,$c0,$00,$00,$00,$c0,$00,$80,$00,$00,$3f,$40,$3f,$40
	db $00,$00,$00,$80,$80,$7f,$00,$ff,$7f,$80,$3f,$c0,$00,$12,$00,$da
	db $00,$bc,$00,$80,$3f,$40,$3f,$c0,$00,$10,$00,$d4,$80,$7f,$00,$ff
	db $7f,$80,$3f,$c0,$00,$ff,$00,$ff,$00,$80,$00,$00,$3f,$40,$3f,$40
	db $00,$00,$00,$80,$00,$c0,$00,$00,$3f,$c0,$7f,$80,$00,$ff,$80,$7f
	db $ff,$00,$ff,$00,$ff,$00,$ff,$00,$00,$ff,$fc,$03,$e0,$1e,$00,$01
	db $1f,$e0,$0f,$30,$00,$00,$c0,$30,$c0,$20,$00,$00,$0f,$10,$0f,$10
	db $00,$00,$c0,$20,$e0,$1f,$00,$ff,$1f,$e0,$0f,$b0,$00,$84,$c0,$36
	db $c0,$2f,$00,$20,$0f,$10,$0f,$30,$00,$04,$c0,$35,$e0,$1f,$00,$ff
	db $1f,$e0,$0f,$f0,$00,$ff,$c0,$3f,$c0,$20,$00,$00,$0f,$10,$0f,$10
	db $00,$00,$c0,$20,$c0,$30,$00,$00,$0f,$30,$1f,$e0,$00,$ff,$e0,$1f
	db $ff,$00,$ff,$00,$ff,$00,$3f,$c0,$00,$ff,$ff,$00,$f8,$07,$00,$80
	db $07,$78,$03,$0c,$00,$00,$f0,$0c,$f0,$08,$00,$00,$03,$04,$03,$04
	db $00,$00,$f0,$08,$f8,$07,$00,$ff,$07,$f8,$03,$2c,$00,$a1,$f0,$0d
	db $f0,$0b,$00,$c8,$03,$04,$03,$0c,$00,$41,$f0,$0d,$f8,$07,$00,$ff
	db $07,$f8,$03,$fc,$00,$ff,$f0,$0f,$f0,$08,$00,$00,$03,$04,$03,$04
	db $00,$00,$f0,$08,$f0,$0c,$00,$00,$03,$0c,$07,$f8,$00,$ff,$f8,$07
	db $ff,$00,$ff,$00,$ff,$00,$0f,$f0,$c0,$3f,$ff,$00,$fe,$01,$00,$e0
	db $01,$1e,$00,$03,$00,$00,$fc,$03,$fc,$02,$00,$00,$00,$01,$00,$01
	db $00,$00,$fc,$02,$fe,$01,$00,$ff,$01,$fe,$00,$4b,$00,$68,$fc,$03
	db $fc,$02,$00,$f2,$00,$01,$00,$43,$00,$50,$fc,$03,$fe,$01,$00,$ff
	db $01,$fe,$00,$ff,$00,$ff,$fc,$03,$fc,$02,$00,$00,$00,$01,$00,$01
	db $00,$00,$fc,$02,$fc,$03,$00,$00,$00,$03,$01,$fe,$00,$ff,$fe,$01
	
	
gfx_OceanLogo:
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$01,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db $ff,$ff,$ff,$80,$07,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$e0
	db $06,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$60,$0c,$ff,$ff,$ff
	db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$30,$0d,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db $ff,$ff,$ff,$b0,$0d,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$b0
	db $0d,$01,$f8,$01,$f8,$01,$f8,$01,$fb,$cf,$80,$b0,$0d,$07,$fe,$07
	db $fe,$07,$fe,$07,$ff,$df,$e0,$b0,$0d,$0f,$ff,$0f,$ff,$0f,$ff,$0f
	db $ff,$ff,$f0,$b0,$0d,$1f,$ff,$9f,$ff,$9f,$9f,$9f,$ff,$ff,$f8,$b0
	db $0d,$1f,$9f,$9f,$9f,$9e,$07,$9f,$9f,$f9,$f8,$b0,$0d,$3e,$07,$fe
	db $07,$fe,$07,$fe,$07,$e0,$7c,$b0,$0d,$3e,$07,$fe,$00,$3f,$ff,$fe
	db $07,$e0,$7c,$b0,$0d,$3c,$03,$fc,$00,$3f,$ff,$fc,$03,$c0,$3c,$b0
	db $0d,$3c,$03,$fc,$00,$3f,$ff,$fc,$03,$c0,$3c,$b0,$0d,$3e,$07,$fe
	db $00,$3e,$00,$3e,$07,$c0,$3c,$b0,$0d,$3e,$07,$fe,$07,$fe,$07,$fe
	db $07,$c0,$3c,$b0,$0d,$1f,$9f,$9f,$9f,$9f,$9f,$9f,$9f,$c0,$3c,$b0
	db $0d,$1f,$ff,$9f,$ff,$9f,$ff,$9f,$ff,$c0,$3c,$b0,$0d,$0f,$ff,$0f
	db $ff,$0f,$ff,$0f,$ff,$c0,$3c,$b0,$0d,$07,$fe,$07,$fe,$07,$fe,$07
	db $ff,$c0,$3c,$b0,$0d,$01,$f8,$01,$f8,$01,$f8,$01,$fb,$c0,$3c,$b0
	db $0d,$fe,$07,$fe,$07,$fe,$07,$fe,$04,$3f,$c3,$b0,$0d,$f8,$01,$f8
	db $01,$f8,$01,$f0,$00,$3f,$c3,$b0,$0c,$f0,$00,$f0,$00,$f0,$00,$e0
	db $00,$3f,$c3,$30,$06,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$60
	db $07,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$e0,$01,$ff,$ff,$ff
	db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$80,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
; Sprites are stored with the mask and data interleaved and alternately zig-zag each line of data,
; writing out the first line left to right and the second line right to left.
;
; Mask and data are POPed off together in one 16 bit register pair
;
;

gfx_NightSlasherLeft:			; Sprites start here
	db $ff,$00,$ff,$00,$ff,$00,$ff,$00,$9f,$00,$e8,$00,$c0,$17,$07,$60
	db $ff,$00,$ff,$00,$03,$e8,$80,$39,$00,$70,$07,$f0,$ff,$00,$ff,$00
	db $01,$f8,$80,$3a,$c0,$1a,$00,$5e,$ff,$00,$7f,$00,$00,$b3,$c0,$10
	db $80,$39,$00,$a1,$7f,$00,$3f,$80,$00,$21,$00,$6f,$00,$40,$00,$20
	db $3f,$80,$3f,$80,$00,$30,$00,$40,$00,$40,$00,$10,$3f,$80,$3f,$80
	db $00,$38,$80,$24,$80,$3b,$00,$dc,$3f,$80,$3f,$80,$00,$3c,$80,$34
	db $00,$7b,$00,$68,$3f,$80,$3f,$80,$00,$c1,$00,$5f,$00,$4c,$00,$41
	db $7f,$00,$7f,$00,$00,$e3,$00,$67,$80,$3c,$00,$9e,$ff,$00,$ff,$00
	db $00,$c6,$c0,$11,$c0,$1b,$01,$6c,$ff,$00,$ff,$00,$83,$38,$e0,$0e
	db $fa,$00,$27,$00,$ff,$00,$ff,$00,$01,$d8,$f0,$05,$e0,$0e,$00,$7a
	db $ff,$00,$ff,$00,$01,$3c,$c0,$1c,$e0,$0e,$01,$bc,$ff,$00,$7f,$00
	db $00,$9e,$f0,$06,$f0,$04,$00,$27,$3f,$80,$1f,$c0,$00,$6c,$f0,$06
	db $e0,$0f,$00,$c8,$1f,$40,$0f,$60,$00,$08,$c0,$18,$c0,$10,$00,$08
	db $0f,$20,$0f,$20,$00,$0c,$c0,$10,$c0,$10,$00,$04,$0f,$20,$0f,$20
	db $00,$0e,$e0,$09,$e0,$0e,$00,$f7,$0f,$20,$0f,$20,$00,$0f,$e0,$0d
	db $c0,$1e,$00,$da,$0f,$20,$0f,$60,$00,$f0,$c0,$17,$c0,$13,$00,$10
	db $1f,$40,$1f,$c0,$00,$f8,$c0,$19,$e0,$0f,$00,$27,$3f,$80,$3f,$80
	db $00,$71,$f0,$04,$f0,$06,$00,$db,$7f,$00,$ff,$00,$20,$8e,$f8,$03
	db $fe,$00,$89,$00,$ff,$00,$7f,$00,$00,$76,$fc,$01,$f8,$03,$00,$9e
	db $3f,$80,$7f,$00,$00,$0f,$f0,$07,$f8,$03,$00,$af,$1f,$80,$0f,$e0
	db $00,$a5,$fc,$01,$fc,$01,$00,$0b,$07,$30,$07,$10,$00,$9a,$f8,$03
	db $f0,$06,$00,$f2,$03,$18,$03,$08,$00,$02,$f0,$04,$f0,$04,$00,$03
	db $03,$08,$03,$08,$00,$01,$f0,$04,$f8,$02,$00,$43,$03,$88,$03,$c8
	db $00,$bd,$f8,$03,$f8,$03,$00,$43,$03,$c8,$03,$88,$00,$b6,$f0,$07
	db $f0,$05,$00,$fc,$03,$18,$07,$10,$00,$c4,$f0,$04,$f0,$06,$00,$7e
	db $07,$30,$0f,$e0,$00,$c9,$f8,$01,$fe,$00,$00,$48,$1f,$80,$3f,$80
	db $00,$48,$ff,$00,$ff,$00,$00,$48,$3f,$80,$3f,$80,$00,$7f,$ff,$00
	db $ff,$00,$a2,$00,$7f,$00,$1f,$80,$00,$5d,$ff,$00,$fe,$00,$00,$e7
	db $0f,$a0,$1f,$c0,$00,$c3,$fc,$01,$fe,$00,$00,$eb,$07,$e0,$03,$78
	db $00,$69,$ff,$00,$ff,$00,$00,$42,$01,$cc,$01,$84,$00,$e6,$fe,$00
	db $fc,$01,$00,$bc,$00,$86,$00,$82,$00,$00,$fc,$01,$fc,$01,$00,$00
	db $00,$c2,$00,$42,$00,$00,$fc,$01,$fe,$00,$00,$90,$00,$e2,$00,$72
	db $00,$ef,$fe,$00,$fe,$00,$00,$d0,$00,$f2,$00,$a2,$00,$ed,$fc,$01
	db $fc,$01,$00,$7f,$00,$06,$01,$04,$00,$31,$fc,$01,$fc,$01,$00,$9f
	db $01,$8c,$03,$78,$00,$72,$fe,$00,$ff,$00,$80,$12,$07,$20,$0f,$20
	db $c0,$12,$ff,$00,$ff,$00,$c0,$12,$0f,$20,$0f,$e0,$c0,$1f,$ff,$00

gfx_NightSlasherRight:
	db $fe,$00,$45,$00,$ff,$00,$ff,$00,$00,$ba,$f8,$01,$f0,$05,$00,$e7
	db $7f,$00,$3f,$80,$00,$c3,$f8,$03,$e0,$07,$00,$d7,$7f,$00,$ff,$00
	db $00,$96,$c0,$1e,$80,$33,$00,$42,$ff,$00,$7f,$00,$00,$67,$80,$21
	db $00,$61,$00,$3d,$3f,$80,$3f,$80,$00,$00,$00,$41,$00,$43,$00,$00
	db $3f,$80,$3f,$80,$00,$00,$00,$42,$00,$47,$00,$09,$7f,$00,$7f,$00
	db $00,$f7,$00,$4e,$00,$4f,$00,$0b,$7f,$00,$3f,$80,$00,$b7,$00,$45
	db $00,$60,$00,$fe,$3f,$80,$3f,$80,$00,$8c,$80,$20,$80,$31,$00,$f9
	db $3f,$80,$7f,$00,$00,$4e,$c0,$1e,$e0,$04,$01,$48,$ff,$00,$ff,$00
	db $03,$48,$f0,$04,$f0,$04,$03,$48,$ff,$00,$ff,$00,$03,$f8,$f0,$07
	db $ff,$00,$91,$00,$7f,$00,$3f,$80,$00,$6e,$fe,$00,$fc,$01,$00,$79
	db $1f,$c0,$0f,$e0,$00,$f0,$fe,$00,$f8,$01,$00,$f5,$1f,$c0,$3f,$80
	db $00,$a5,$f0,$07,$e0,$0c,$00,$d0,$3f,$80,$1f,$c0,$00,$59,$e0,$08
	db $c0,$18,$00,$4f,$0f,$60,$0f,$20,$00,$40,$c0,$10,$c0,$10,$00,$c0
	db $0f,$20,$0f,$20,$00,$80,$c0,$10,$c0,$11,$00,$c2,$1f,$40,$1f,$c0
	db $00,$bd,$c0,$13,$c0,$13,$00,$c2,$1f,$c0,$0f,$e0,$00,$6d,$c0,$11
	db $c0,$18,$00,$3f,$0f,$a0,$0f,$20,$00,$23,$e0,$08,$e0,$0c,$00,$7e
	db $0f,$60,$1f,$80,$00,$93,$f0,$07,$f8,$01,$00,$12,$7f,$00,$ff,$00
	db $00,$12,$fc,$01,$fc,$01,$00,$12,$ff,$00,$ff,$00,$00,$fe,$fc,$01
	db $ff,$00,$e4,$00,$5f,$00,$0f,$a0,$80,$1b,$ff,$00,$ff,$00,$00,$5e
	db $07,$70,$03,$38,$80,$3c,$ff,$00,$ff,$00,$80,$3d,$07,$70,$0f,$60
	db $00,$79,$fe,$00,$fc,$01,$00,$e4,$0f,$20,$0f,$60,$00,$36,$f8,$03
	db $f8,$02,$00,$13,$07,$f0,$03,$18,$00,$10,$f0,$06,$f0,$04,$00,$10
	db $03,$08,$03,$08,$00,$30,$f0,$04,$f0,$04,$00,$20,$03,$08,$07,$90
	db $00,$70,$f0,$04,$f0,$04,$00,$ef,$07,$70,$07,$b0,$00,$f0,$f0,$04
	db $f0,$04,$00,$5b,$03,$78,$03,$e8,$00,$0f,$f0,$06,$f8,$02,$00,$08
	db $03,$c8,$03,$98,$00,$1f,$f8,$03,$fc,$01,$00,$e4,$07,$f0,$0f,$20
	db $00,$8e,$fc,$01,$fe,$00,$00,$db,$0f,$60,$1f,$c0,$04,$71,$ff,$00
	db $ff,$00,$ff,$00,$ff,$00,$17,$00,$f9,$00,$ff,$00,$ff,$00,$e0,$06
	db $03,$e8,$01,$9c,$c0,$17,$ff,$00,$ff,$00,$e0,$0f,$00,$0e,$01,$5c
	db $80,$1f,$ff,$00,$ff,$00,$00,$7a,$03,$58,$03,$08,$00,$cd,$fe,$00
	db $fe,$00,$00,$85,$01,$9c,$00,$f6,$00,$84,$fc,$01,$fc,$01,$00,$04
	db $00,$02,$00,$02,$00,$0c,$fc,$01,$fc,$01,$00,$08,$00,$02,$01,$24
	db $00,$1c,$fc,$01,$fc,$01,$00,$3b,$01,$dc,$01,$2c,$00,$3c,$fc,$01
	db $fc,$01,$00,$16,$00,$de,$00,$fa,$00,$83,$fc,$01,$fe,$00,$00,$82
	db $00,$32,$00,$e6,$00,$c7,$fe,$00,$ff,$00,$00,$79,$01,$3c,$03,$88
	db $00,$63,$ff,$00,$ff,$00,$80,$36,$03,$d8,$07,$70,$c1,$1c,$ff,$00

gfx_BazookaLadyLeft:
	db $ff,$00,$ff,$00,$ff,$00,$ff,$00,$c5,$00,$ff,$00,$ff,$00,$00,$3a
	db $ff,$00,$7f,$00,$00,$ff,$fe,$00,$fc,$01,$00,$fe,$ff,$00,$7f,$00
	db $00,$ff,$fe,$00,$bc,$01,$00,$3e,$7f,$00,$3f,$80,$00,$7a,$00,$40
	db $00,$7f,$00,$fb,$3f,$80,$3f,$80,$00,$72,$00,$40,$00,$7f,$00,$83
	db $3f,$80,$3f,$80,$00,$d3,$00,$7f,$00,$79,$00,$e7,$3f,$80,$3f,$80
	db $00,$fe,$00,$51,$80,$11,$00,$e6,$7f,$00,$ff,$00,$00,$a2,$e0,$08
	db $c0,$1c,$00,$32,$ff,$00,$ff,$00,$00,$1e,$80,$24,$80,$26,$01,$3c
	db $ff,$00,$ff,$00,$01,$e4,$c0,$1d,$e0,$0d,$01,$fc,$ff,$00,$ff,$00
	db $00,$3e,$f0,$03,$f0,$06,$00,$6f,$7f,$00,$7f,$00,$00,$bb,$f0,$04
	db $e0,$0c,$00,$6f,$3f,$80,$3f,$80,$00,$bd,$e0,$08,$e0,$09,$00,$6f
	db $3f,$80,$3f,$80,$00,$bd,$e0,$08,$c0,$1f,$00,$ff,$1f,$c0,$1f,$40
	db $00,$25,$c0,$15,$c0,$15,$00,$25,$1f,$40,$1f,$c0,$00,$ff,$c0,$1f
	db $ff,$00,$f1,$00,$7f,$00,$3f,$80,$c0,$0e,$ff,$00,$ff,$00,$80,$3f
	db $1f,$c0,$3f,$80,$00,$7f,$ff,$00,$ff,$00,$80,$3f,$1f,$c0,$1f,$80
	db $00,$4f,$ef,$00,$c0,$10,$00,$12,$0f,$a0,$0f,$e0,$00,$fa,$c0,$1f
	db $c0,$10,$00,$1c,$0f,$a0,$0f,$e0,$00,$e0,$c0,$1f,$c0,$1f,$00,$f4
	db $0f,$e0,$0f,$e0,$00,$79,$c0,$1e,$c0,$14,$00,$7f,$0f,$a0,$1f,$80
	db $00,$79,$e0,$04,$f8,$02,$00,$28,$3f,$80,$3f,$80,$00,$0c,$f0,$07
	db $e0,$09,$00,$07,$3f,$80,$7f,$00,$00,$8f,$e0,$09,$f0,$07,$00,$7f
	db $7f,$00,$7f,$00,$00,$51,$f8,$03,$fc,$00,$00,$7f,$7f,$00,$3f,$80
	db $00,$cf,$fe,$00,$fc,$01,$00,$9b,$1f,$c0,$1f,$c0,$00,$2e,$fc,$01
	db $f8,$03,$00,$1b,$0f,$e0,$0f,$60,$00,$2f,$f8,$02,$f8,$02,$00,$5b
	db $0f,$e0,$0f,$60,$00,$2f,$f8,$02,$f0,$07,$00,$ff,$07,$f0,$07,$50
	db $00,$49,$f0,$05,$f0,$05,$00,$49,$07,$50,$07,$f0,$00,$ff,$f0,$07
	db $ff,$00,$fc,$00,$5f,$00,$0f,$a0,$f0,$03,$ff,$00,$ff,$00,$e0,$0f
	db $07,$f0,$0f,$e0,$c0,$1f,$ff,$00,$fb,$00,$e0,$0f,$07,$f0,$03,$e8
	db $00,$13,$f0,$04,$f0,$07,$00,$fc,$03,$b8,$03,$a8,$00,$06,$f0,$04
	db $f0,$07,$00,$ff,$03,$38,$03,$38,$00,$f8,$f0,$07,$f0,$07,$00,$9d
	db $03,$38,$03,$e8,$00,$1f,$f0,$05,$f8,$01,$00,$1e,$07,$60,$0f,$20
	db $00,$8a,$fe,$00,$fc,$01,$00,$c3,$0f,$20,$0f,$e0,$00,$41,$f8,$02
	db $f8,$02,$00,$63,$1f,$c0,$1f,$c0,$00,$df,$fc,$01,$fe,$00,$00,$df
	db $1f,$c0,$1f,$40,$00,$14,$ff,$00,$ff,$00,$c0,$1f,$1f,$c0,$0f,$e0
	db $80,$33,$ff,$00,$ff,$00,$00,$66,$07,$f0,$07,$b0,$00,$4b,$ff,$00
	db $fe,$00,$00,$c6,$03,$f8,$03,$d8,$00,$8b,$fe,$00,$fe,$00,$00,$96
	db $03,$f8,$03,$d8,$00,$8b,$fe,$00,$fc,$01,$00,$ff,$01,$fc,$01,$54
	db $00,$52,$fc,$01,$fc,$01,$00,$52,$01,$54,$01,$fc,$00,$ff,$fc,$01
	db $ff,$00,$ff,$00,$ff,$00,$17,$00,$ff,$00,$ff,$00,$ff,$00,$fc,$00
	db $03,$e8,$01,$fc,$f8,$03,$ff,$00,$ff,$00,$f0,$07,$03,$f8,$01,$fc
	db $f8,$03,$ff,$00,$fe,$00,$f0,$04,$01,$f8,$00,$2a,$00,$01,$fc,$01
	db $fc,$01,$00,$ff,$00,$2e,$00,$ca,$00,$01,$fc,$01,$fc,$01,$00,$fe
	db $00,$0e,$00,$4e,$00,$ff,$fc,$01,$fc,$01,$00,$e7,$00,$9e,$00,$fa
	db $00,$47,$fc,$01,$fe,$00,$00,$47,$01,$98,$03,$88,$80,$22,$ff,$00
	db $ff,$00,$00,$70,$03,$c8,$03,$78,$00,$90,$fe,$00,$fe,$00,$00,$98
	db $07,$f0,$07,$90,$00,$77,$ff,$00,$ff,$00,$80,$37,$07,$f0,$03,$f8
	db $c0,$0c,$ff,$00,$ff,$00,$c0,$19,$01,$bc,$01,$ec,$c0,$12,$ff,$00
	db $ff,$00,$80,$31,$00,$be,$00,$f6,$80,$22,$ff,$00,$ff,$00,$80,$25
	db $00,$be,$00,$f6,$80,$22,$ff,$00,$ff,$00,$00,$7f,$00,$ff,$00,$95
	db $00,$54,$ff,$00,$ff,$00,$00,$54,$00,$95,$00,$ff,$00,$7f,$ff,$00

gfx_BazookaLadyRight:
	db $ff,$00,$ff,$00,$ff,$00,$ff,$00,$ff,$00,$e8,$00,$c0,$17,$3f,$00
	db $ff,$00,$ff,$00,$1f,$c0,$80,$3f,$c0,$1f,$0f,$e0,$ff,$00,$ff,$00
	db $1f,$c0,$80,$3f,$80,$1f,$0f,$20,$7f,$00,$3f,$80,$00,$80,$00,$54
	db $00,$74,$00,$ff,$3f,$80,$3f,$80,$00,$80,$00,$53,$00,$70,$00,$7f
	db $3f,$80,$3f,$80,$00,$ff,$00,$72,$00,$79,$00,$e7,$3f,$80,$3f,$80
	db $00,$e2,$00,$5f,$80,$19,$00,$e2,$7f,$00,$ff,$00,$01,$44,$c0,$11
	db $c0,$13,$00,$0e,$ff,$00,$7f,$00,$00,$09,$c0,$1e,$e0,$0f,$00,$19
	db $7f,$00,$ff,$00,$00,$ee,$e0,$09,$e0,$0f,$01,$ec,$ff,$00,$ff,$00
	db $03,$30,$c0,$1f,$80,$3d,$03,$98,$ff,$00,$ff,$00,$03,$48,$80,$37
	db $00,$7d,$01,$8c,$ff,$00,$ff,$00,$01,$44,$00,$6f,$00,$7d,$01,$a4
	db $ff,$00,$ff,$00,$01,$44,$00,$6f,$00,$ff,$00,$fe,$ff,$00,$ff,$00
	db $00,$2a,$00,$a9,$00,$a9,$00,$2a,$ff,$00,$ff,$00,$00,$fe,$00,$ff
	db $fa,$00,$3f,$00,$ff,$00,$ff,$00,$0f,$c0,$f0,$05,$e0,$0f,$07,$f0
	db $ff,$00,$ff,$00,$03,$f8,$f0,$07,$e0,$0f,$07,$f0,$df,$00,$0f,$20
	db $00,$c8,$c0,$17,$c0,$1d,$00,$3f,$0f,$e0,$0f,$20,$00,$60,$c0,$15
	db $c0,$1c,$00,$ff,$0f,$e0,$0f,$e0,$00,$1f,$c0,$1c,$c0,$1c,$00,$b9
	db $0f,$e0,$0f,$a0,$00,$f8,$c0,$17,$e0,$06,$00,$78,$1f,$80,$7f,$00
	db $00,$51,$f0,$04,$f0,$04,$00,$c3,$3f,$80,$1f,$40,$00,$82,$f0,$07
	db $f8,$03,$00,$c6,$1f,$40,$3f,$80,$00,$fb,$f8,$03,$f8,$03,$00,$fb
	db $7f,$00,$ff,$00,$00,$28,$f8,$02,$f8,$03,$03,$f8,$ff,$00,$ff,$00
	db $01,$cc,$f0,$07,$e0,$0f,$00,$66,$ff,$00,$ff,$00,$00,$d2,$e0,$0d
	db $c0,$1f,$00,$63,$7f,$00,$7f,$00,$00,$d1,$c0,$1b,$c0,$1f,$00,$69
	db $7f,$00,$7f,$00,$00,$d1,$c0,$1b,$80,$3f,$00,$ff,$3f,$80,$3f,$80
	db $00,$4a,$80,$2a,$80,$2a,$00,$4a,$3f,$80,$3f,$80,$00,$ff,$80,$3f
	db $fe,$00,$8f,$00,$ff,$00,$ff,$00,$03,$70,$fc,$01,$f8,$03,$01,$fc
	db $ff,$00,$ff,$00,$00,$fe,$fc,$01,$f8,$03,$01,$fc,$ff,$00,$f7,$00
	db $00,$f2,$f8,$01,$f0,$05,$00,$48,$03,$08,$03,$f8,$00,$5f,$f0,$07
	db $f0,$05,$00,$38,$03,$08,$03,$f8,$00,$07,$f0,$07,$f0,$07,$00,$2f
	db $03,$f8,$03,$78,$00,$9e,$f0,$07,$f0,$05,$00,$fe,$03,$28,$07,$20
	db $00,$9e,$f8,$01,$fc,$01,$00,$14,$1f,$40,$0f,$e0,$00,$30,$fc,$01
	db $fc,$01,$00,$e0,$07,$90,$07,$90,$00,$f1,$fe,$00,$fe,$00,$00,$fe
	db $0f,$e0,$1f,$c0,$00,$8a,$fe,$00,$fe,$00,$00,$fe,$3f,$00,$7f,$00
	db $00,$f3,$fc,$01,$f8,$03,$00,$d9,$3f,$80,$3f,$80,$00,$74,$f8,$03
	db $f0,$07,$00,$d8,$1f,$c0,$1f,$40,$00,$f4,$f0,$06,$f0,$07,$00,$da
	db $1f,$40,$1f,$40,$00,$f4,$f0,$06,$e0,$0f,$00,$ff,$0f,$e0,$0f,$a0
	db $00,$92,$e0,$0a,$e0,$0a,$00,$92,$0f,$a0,$0f,$e0,$00,$ff,$e0,$0f
	db $ff,$00,$ff,$00,$ff,$00,$ff,$00,$a3,$00,$ff,$00,$ff,$00,$00,$5c
	db $ff,$00,$7f,$00,$00,$ff,$fe,$00,$ff,$00,$00,$7f,$3f,$80,$7f,$00
	db $00,$ff,$fe,$00,$fe,$00,$00,$7c,$3d,$80,$00,$02,$00,$5e,$fc,$01
	db $fc,$01,$00,$df,$00,$fe,$00,$02,$00,$4e,$fc,$01,$fc,$01,$00,$c1
	db $00,$fe,$00,$fe,$00,$cb,$fc,$01,$fc,$01,$00,$e7,$00,$9e,$00,$8a
	db $00,$7f,$fc,$01,$fe,$00,$00,$67,$01,$88,$07,$10,$00,$45,$ff,$00
	db $ff,$00,$00,$4c,$03,$38,$01,$24,$00,$78,$ff,$00,$ff,$00,$80,$3c
	db $01,$64,$03,$b8,$80,$27,$ff,$00,$ff,$00,$80,$3f,$07,$b0,$0f,$c0
	db $00,$7c,$ff,$00,$fe,$00,$00,$f6,$0f,$60,$0f,$20,$00,$dd,$fe,$00
	db $fc,$01,$00,$f6,$07,$30,$07,$10,$00,$bd,$fc,$01,$fc,$01,$00,$f6
	db $07,$90,$07,$10,$00,$bd,$fc,$01,$f8,$03,$00,$ff,$03,$f8,$03,$a8
	db $00,$a4,$f8,$02,$f8,$02,$00,$a4,$03,$a8,$03,$f8,$00,$ff,$f8,$03

gfx_CobraWalkLeft:
	db $ff,$00,$0b,$00,$ff,$00,$ff,$00,$01,$f4,$fe,$00,$fc,$01,$00,$fe
	db $ff,$00,$7f,$00,$00,$bf,$f8,$03,$fc,$01,$00,$0f,$7f,$00,$ff,$00
	db $00,$fe,$fc,$01,$fc,$01,$00,$b7,$7f,$00,$ff,$00,$00,$06,$fc,$01
	db $fc,$01,$00,$04,$1f,$00,$07,$e0,$00,$ef,$fe,$00,$fe,$00,$00,$ca
	db $03,$18,$01,$04,$00,$f4,$fc,$01,$fc,$01,$00,$ac,$00,$02,$00,$02
	db $00,$54,$fc,$01,$f0,$01,$00,$aa,$00,$22,$00,$e2,$00,$d7,$e0,$0e
	db $c0,$11,$00,$af,$00,$62,$00,$42,$00,$d7,$c0,$11,$c0,$11,$00,$fe
	db $00,$42,$01,$44,$00,$fe,$e0,$0f,$f0,$03,$00,$ff,$03,$38,$47,$00
	db $00,$ff,$f0,$07,$e0,$0f,$00,$ff,$7f,$00,$7f,$00,$00,$df,$e0,$0f
	db $e0,$0f,$00,$9f,$7f,$00,$7f,$00,$00,$df,$f0,$07,$f8,$03,$00,$ef
	db $3f,$80,$3f,$80,$00,$ef,$fc,$00,$fc,$01,$00,$e7,$3f,$80,$3f,$80
	db $10,$c3,$f8,$03,$f8,$03,$20,$0f,$1f,$c0,$1f,$c0,$c0,$1f,$fc,$00
	db $ff,$00,$85,$00,$ff,$00,$ff,$00,$00,$7a,$ff,$00,$fe,$00,$00,$ff
	db $7f,$00,$3f,$80,$00,$df,$fc,$01,$fe,$00,$00,$87,$3f,$80,$7f,$00
	db $00,$ff,$fe,$00,$fe,$00,$00,$db,$3f,$80,$7f,$00,$00,$83,$fe,$00
	db $fe,$00,$00,$82,$3f,$00,$0f,$c0,$00,$77,$ff,$00,$fe,$00,$00,$ea
	db $07,$30,$03,$08,$00,$f4,$fc,$01,$fc,$01,$00,$ac,$03,$08,$01,$04
	db $00,$54,$fc,$01,$fc,$01,$00,$aa,$01,$04,$01,$04,$00,$d7,$fe,$00
	db $fc,$01,$00,$af,$01,$c4,$01,$44,$00,$d7,$f8,$02,$f0,$04,$00,$7e
	db $03,$08,$03,$08,$00,$7e,$f0,$04,$f8,$02,$00,$ff,$07,$10,$0f,$e0
	db $00,$ff,$fc,$01,$fc,$01,$00,$ff,$1f,$80,$3f,$80,$00,$ff,$f8,$03
	db $f8,$03,$00,$ff,$1f,$c0,$0f,$e0,$00,$e7,$f8,$03,$f0,$07,$10,$c7
	db $07,$f0,$01,$f8,$18,$c3,$f0,$07,$c0,$07,$3c,$81,$00,$fe,$00,$7e
	db $3e,$80,$80,$3f,$80,$3f,$7f,$00,$80,$1e,$81,$3c,$7f,$00,$c0,$1f
	db $ff,$00,$0b,$00,$ff,$00,$ff,$00,$01,$f4,$fe,$00,$fc,$01,$00,$fe
	db $ff,$00,$7f,$00,$00,$bf,$f8,$03,$fc,$01,$00,$0f,$7f,$00,$ff,$00
	db $00,$fe,$fc,$01,$fc,$01,$00,$b7,$7f,$00,$ff,$00,$00,$06,$fc,$01
	db $fc,$01,$00,$04,$3f,$00,$1f,$c0,$00,$ef,$fe,$00,$fe,$00,$00,$ca
	db $0f,$20,$07,$10,$00,$f4,$fc,$01,$fc,$01,$00,$ac,$07,$10,$07,$10
	db $00,$54,$fc,$01,$fc,$01,$00,$aa,$03,$08,$03,$08,$00,$d7,$fe,$00
	db $fe,$00,$00,$af,$03,$08,$03,$08,$00,$d9,$fe,$00,$ff,$00,$00,$70
	db $07,$10,$0f,$60,$00,$70,$ff,$00,$fe,$00,$00,$f8,$1f,$80,$3f,$80
	db $00,$ff,$fc,$01,$fc,$01,$00,$ff,$0f,$00,$07,$70,$00,$ff,$f8,$03
	db $f8,$03,$00,$ff,$07,$f0,$03,$f8,$00,$ef,$f8,$03,$f8,$03,$00,$ef
	db $03,$f8,$03,$98,$00,$e7,$fc,$01,$fc,$01,$08,$e0,$63,$08,$f7,$00
	db $07,$f0,$fe,$00,$fc,$01,$07,$f0,$ff,$00,$ff,$00,$07,$f0,$f8,$03
	db $fe,$00,$17,$00,$ff,$00,$ff,$00,$03,$e8,$fc,$01,$f8,$03,$01,$fc
	db $ff,$00,$ff,$00,$00,$7e,$f0,$07,$f8,$02,$00,$1e,$ff,$00,$ff,$00
	db $01,$fc,$f8,$03,$f8,$03,$00,$6e,$ff,$00,$ff,$00,$01,$0c,$f8,$02
	db $f8,$02,$00,$08,$3f,$00,$0f,$c0,$00,$df,$fc,$01,$fe,$00,$00,$da
	db $07,$30,$03,$08,$00,$f4,$fc,$01,$fc,$01,$00,$ac,$03,$08,$01,$04
	db $00,$54,$fc,$01,$fc,$01,$00,$aa,$01,$04,$01,$04,$00,$d7,$fe,$00
	db $fc,$01,$00,$af,$01,$c4,$01,$44,$00,$d7,$f8,$02,$f0,$04,$00,$7e
	db $03,$08,$03,$08,$00,$3e,$f0,$04,$f8,$02,$00,$7f,$07,$10,$0f,$e0
	db $00,$ff,$fc,$01,$fe,$00,$00,$ff,$1f,$00,$ff,$00,$00,$fe,$fe,$00
	db $fc,$01,$00,$fc,$ff,$00,$1f,$00,$00,$ff,$fc,$01,$fc,$01,$00,$ff
	db $0f,$e0,$0f,$e0,$00,$ff,$fe,$00,$ff,$00,$00,$3f,$0f,$e0,$0f,$e0
	db $80,$3c,$ff,$00,$ff,$00,$00,$7c,$1f,$c0,$3f,$80,$00,$fc,$fe,$00

gfx_CobraWalkRight:
	db $ff,$00,$d0,$00,$ff,$00,$7f,$00,$80,$2f,$ff,$00,$ff,$00,$00,$7f
	db $3f,$80,$1f,$c0,$00,$fd,$fe,$00,$fe,$00,$00,$f0,$3f,$80,$3f,$80
	db $00,$7f,$ff,$00,$fe,$00,$00,$ed,$3f,$80,$3f,$80,$00,$60,$ff,$00
	db $f8,$00,$00,$20,$3f,$80,$7f,$00,$00,$f7,$e0,$07,$c0,$18,$00,$53
	db $7f,$00,$3f,$80,$00,$2f,$80,$20,$00,$40,$00,$35,$3f,$80,$3f,$80
	db $00,$2a,$00,$40,$00,$44,$00,$55,$0f,$80,$07,$70,$00,$eb,$00,$47
	db $00,$46,$00,$f5,$03,$88,$03,$88,$00,$eb,$00,$42,$00,$42,$00,$7f
	db $03,$88,$07,$f0,$00,$7f,$80,$22,$c0,$1c,$00,$ff,$0f,$c0,$0f,$e0
	db $00,$ff,$e2,$00,$fe,$00,$00,$ff,$07,$f0,$07,$f0,$00,$fb,$fe,$00
	db $fe,$00,$00,$f9,$07,$f0,$0f,$e0,$00,$fb,$fe,$00,$fc,$01,$00,$f7
	db $1f,$c0,$3f,$00,$00,$f7,$fc,$01,$fc,$01,$00,$e7,$3f,$80,$1f,$c0
	db $08,$c3,$fc,$01,$f8,$03,$04,$f0,$1f,$c0,$3f,$00,$03,$f8,$f8,$03
	db $ff,$00,$a1,$00,$ff,$00,$ff,$00,$00,$5e,$ff,$00,$fe,$00,$00,$ff
	db $7f,$00,$3f,$80,$00,$fb,$fc,$01,$fc,$01,$00,$e1,$7f,$00,$7f,$00
	db $00,$ff,$fe,$00,$fc,$01,$00,$db,$7f,$00,$7f,$00,$00,$c1,$fe,$00
	db $fc,$00,$00,$41,$7f,$00,$ff,$00,$00,$ee,$f0,$03,$e0,$0c,$00,$57
	db $7f,$00,$3f,$80,$00,$2f,$c0,$10,$c0,$10,$00,$35,$3f,$80,$3f,$80
	db $00,$2a,$80,$20,$80,$20,$00,$55,$3f,$80,$7f,$00,$00,$eb,$80,$20
	db $80,$23,$00,$f5,$3f,$80,$1f,$40,$00,$eb,$80,$22,$c0,$10,$00,$7e
	db $0f,$20,$0f,$20,$00,$7e,$c0,$10,$e0,$08,$00,$ff,$1f,$40,$3f,$80
	db $00,$ff,$f0,$07,$f8,$01,$00,$ff,$3f,$80,$1f,$c0,$00,$ff,$fc,$01
	db $f8,$03,$00,$ff,$1f,$c0,$1f,$c0,$00,$e7,$f0,$07,$e0,$0f,$08,$e3
	db $0f,$e0,$0f,$e0,$18,$c3,$80,$1f,$00,$7f,$3c,$81,$03,$e0,$01,$fc
	db $7c,$01,$00,$7e,$01,$78,$fe,$00,$01,$fc,$03,$f8,$fe,$00,$81,$3c
	db $ff,$00,$d0,$00,$ff,$00,$7f,$00,$80,$2f,$ff,$00,$ff,$00,$00,$7f
	db $3f,$80,$1f,$c0,$00,$fd,$fe,$00,$fe,$00,$00,$f0,$3f,$80,$3f,$80
	db $00,$7f,$ff,$00,$fe,$00,$00,$ed,$3f,$80,$3f,$80,$00,$60,$ff,$00
	db $fc,$00,$00,$20,$3f,$80,$7f,$00,$00,$f7,$f8,$03,$f0,$04,$00,$53
	db $7f,$00,$3f,$80,$00,$2f,$e0,$08,$e0,$08,$00,$35,$3f,$80,$3f,$80
	db $00,$2a,$e0,$08,$c0,$10,$00,$55,$3f,$80,$7f,$00,$00,$eb,$c0,$10
	db $c0,$10,$00,$f5,$7f,$00,$7f,$00,$00,$9b,$c0,$10,$e0,$08,$00,$0e
	db $ff,$00,$ff,$00,$00,$0e,$f0,$06,$f8,$01,$00,$1f,$7f,$00,$3f,$80
	db $00,$ff,$fc,$01,$f0,$00,$00,$ff,$3f,$80,$1f,$c0,$00,$ff,$e0,$0e
	db $e0,$0f,$00,$ff,$1f,$c0,$1f,$c0,$00,$f7,$c0,$1f,$c0,$1f,$00,$f7
	db $1f,$c0,$3f,$80,$00,$e7,$c0,$19,$c6,$10,$10,$07,$3f,$80,$7f,$00
	db $e0,$0f,$ef,$00,$ff,$00,$e0,$0f,$3f,$80,$1f,$c0,$e0,$0f,$ff,$00
	db $ff,$00,$e8,$00,$7f,$00,$3f,$80,$c0,$17,$ff,$00,$ff,$00,$80,$3f
	db $1f,$c0,$0f,$e0,$00,$7e,$ff,$00,$ff,$00,$00,$78,$1f,$40,$1f,$c0
	db $80,$3f,$ff,$00,$ff,$00,$00,$76,$1f,$c0,$1f,$40,$80,$30,$ff,$00
	db $fc,$00,$00,$10,$1f,$40,$3f,$80,$00,$fb,$f0,$03,$e0,$0c,$00,$5b
	db $7f,$00,$3f,$80,$00,$2f,$c0,$10,$c0,$10,$00,$35,$3f,$80,$3f,$80
	db $00,$2a,$80,$20,$80,$20,$00,$55,$3f,$80,$7f,$00,$00,$eb,$80,$20
	db $80,$23,$00,$f5,$3f,$80,$1f,$40,$00,$eb,$80,$22,$c0,$10,$00,$7e
	db $0f,$20,$0f,$20,$00,$7c,$c0,$10,$e0,$08,$00,$fe,$1f,$40,$3f,$80
	db $00,$ff,$f0,$07,$f8,$00,$00,$ff,$7f,$00,$7f,$00,$00,$7f,$ff,$00
	db $ff,$00,$00,$3f,$3f,$80,$3f,$80,$00,$ff,$f8,$00,$f0,$07,$00,$ff
	db $3f,$80,$7f,$00,$00,$ff,$f0,$07,$f0,$07,$00,$fc,$ff,$00,$ff,$00
	db $01,$3c,$f0,$07,$f8,$03,$00,$3e,$ff,$00,$7f,$00,$00,$3f,$fc,$01

gfx_CobraHeadbuttLeft:
	db $ff,$00,$ff,$00,$ff,$00,$ff,$00,$7f,$00,$fa,$00,$f0,$05,$3f,$80
	db $ff,$00,$ff,$00,$1f,$c0,$e0,$0f,$c0,$1f,$0f,$c0,$ff,$00,$ff,$00
	db $07,$f0,$c0,$1d,$80,$33,$0f,$20,$ff,$00,$3f,$00,$00,$10,$80,$37
	db $c0,$1c,$00,$0f,$1f,$c0,$0f,$20,$00,$5a,$e0,$04,$f8,$02,$00,$f4
	db $07,$10,$07,$10,$00,$ac,$f0,$07,$f0,$05,$00,$54,$07,$10,$03,$08
	db $00,$aa,$f0,$05,$f0,$02,$00,$d7,$03,$08,$03,$08,$00,$af,$e0,$0e
	db $c0,$12,$00,$59,$03,$08,$07,$10,$00,$30,$80,$20,$80,$20,$00,$50
	db $0f,$60,$1f,$80,$00,$f8,$c0,$11,$e0,$0e,$00,$ff,$3f,$80,$3f,$80
	db $00,$ff,$f0,$01,$fc,$01,$00,$ff,$0f,$00,$07,$70,$00,$ff,$f8,$03
	db $f8,$03,$00,$ff,$07,$f0,$03,$f8,$00,$ef,$f8,$03,$f8,$03,$00,$ef
	db $03,$f8,$03,$98,$00,$e7,$fc,$01,$fc,$01,$08,$e0,$63,$08,$f7,$00
	db $07,$f0,$fe,$00,$fc,$01,$07,$f0,$ff,$00,$ff,$00,$07,$f0,$f8,$03

gfx_CobraHeadbuttRight:
	db $ff,$00,$ff,$00,$ff,$00,$5f,$00,$fe,$00,$ff,$00,$ff,$00,$fc,$01
	db $0f,$a0,$07,$f0,$f8,$03,$ff,$00,$ff,$00,$f0,$03,$03,$f8,$03,$b8
	db $e0,$0f,$ff,$00,$ff,$00,$f0,$04,$01,$cc,$01,$ec,$00,$08,$fc,$00
	db $f8,$03,$00,$f0,$03,$38,$07,$20,$00,$5a,$f0,$04,$e0,$08,$00,$2f
	db $1f,$40,$0f,$e0,$00,$35,$e0,$08,$e0,$08,$00,$2a,$0f,$a0,$0f,$a0
	db $00,$55,$c0,$10,$c0,$10,$00,$eb,$0f,$40,$07,$70,$00,$f5,$c0,$10
	db $c0,$10,$00,$9a,$03,$48,$01,$04,$00,$0c,$e0,$08,$f0,$06,$00,$0e
	db $01,$04,$03,$88,$00,$1f,$f8,$01,$fc,$01,$00,$ff,$07,$70,$0f,$80
	db $00,$ff,$fc,$01,$f0,$00,$00,$ff,$3f,$80,$1f,$c0,$00,$ff,$e0,$0e
	db $e0,$0f,$00,$ff,$1f,$c0,$1f,$c0,$00,$f7,$c0,$1f,$c0,$1f,$00,$f7
	db $1f,$c0,$3f,$80,$00,$e7,$c0,$19,$c6,$10,$10,$07,$3f,$80,$7f,$00
	db $e0,$0f,$ef,$00,$ff,$00,$e0,$0f,$3f,$80,$1f,$c0,$e0,$0f,$ff,$00
	
gfx_CobraJumpLeft:
	db $ff,$00,$0b,$00,$ff,$00,$ff,$00,$01,$f4,$fe,$00,$fc,$01,$00,$fe
	db $ff,$00,$7f,$00,$00,$bf,$f8,$03,$fc,$01,$00,$0f,$7f,$00,$ff,$00
	db $00,$fe,$fc,$01,$fc,$01,$00,$b7,$7f,$00,$1f,$00,$00,$06,$fc,$01
	db $fc,$01,$00,$07,$07,$e0,$03,$18,$00,$ea,$fc,$01,$f0,$03,$00,$d4
	db $01,$04,$00,$02,$00,$ac,$e0,$0f,$c0,$13,$00,$54,$00,$02,$00,$22
	db $00,$aa,$80,$21,$80,$23,$00,$d7,$00,$e2,$00,$62,$00,$ae,$c0,$10
	db $e0,$0c,$00,$d6,$00,$42,$00,$42,$01,$fc,$f0,$03,$fc,$01,$01,$fc
	db $01,$44,$83,$38,$00,$fe,$f8,$03,$f0,$07,$00,$fe,$c7,$00,$0f,$20
	db $00,$fe,$f0,$07,$e0,$0f,$00,$9e,$07,$f0,$07,$f0,$00,$9f,$f0,$07
	db $f0,$07,$20,$8f,$03,$f8,$03,$d8,$00,$cf,$f8,$03,$f8,$01,$10,$c7
	db $23,$08,$f7,$00,$08,$e0,$f0,$07,$e0,$0f,$0f,$e0,$ff,$00,$ff,$00
	db $0f,$e0,$f0,$00,$ff,$00,$1f,$00,$ff,$00,$ff,$00,$ff,$00,$ff,$00

gfx_CobraJumpRight:
	db $ff,$00,$d0,$00,$ff,$00,$7f,$00,$80,$2f,$ff,$00,$ff,$00,$00,$7f
	db $3f,$80,$1f,$c0,$00,$fd,$fe,$00,$fe,$00,$00,$f0,$3f,$80,$3f,$80
	db $00,$7f,$ff,$00,$fe,$00,$00,$ed,$3f,$80,$3f,$80,$00,$60,$f8,$00
	db $e0,$07,$00,$e0,$3f,$80,$3f,$80,$00,$57,$c0,$18,$80,$20,$00,$2b
	db $0f,$c0,$07,$f0,$00,$35,$00,$40,$00,$40,$00,$2a,$03,$c8,$01,$84
	db $00,$55,$00,$44,$00,$47,$00,$eb,$01,$c4,$03,$08,$00,$75,$00,$46
	db $00,$42,$00,$6b,$07,$30,$0f,$c0,$80,$3f,$00,$42,$80,$22,$80,$3f
	db $3f,$80,$1f,$c0,$00,$7f,$c1,$1c,$e3,$00,$00,$7f,$0f,$e0,$0f,$e0
	db $00,$7f,$f0,$04,$e0,$0f,$00,$79,$07,$f0,$0f,$e0,$00,$f9,$e0,$0f
	db $c0,$1f,$04,$f1,$0f,$e0,$1f,$c0,$00,$f3,$c0,$1b,$c4,$10,$08,$e3
	db $1f,$80,$0f,$e0,$10,$07,$ef,$00,$ff,$00,$f0,$07,$07,$f0,$0f,$00
	db $f0,$07,$ff,$00,$ff,$00,$f8,$00,$ff,$00,$ff,$00,$ff,$00,$ff,$00

gfx_CobraDuckLeft:
	db $fe,$00,$17,$00,$ff,$00,$ff,$00,$03,$e8,$fc,$01,$f8,$03,$01,$fc
	db $ff,$00,$ff,$00,$00,$7e,$f0,$07,$f8,$02,$00,$1e,$ff,$00,$ff,$00
	db $01,$fc,$f8,$03,$f8,$03,$00,$6e,$3f,$00,$0f,$c0,$00,$0f,$f8,$02
	db $f8,$02,$00,$0a,$07,$30,$03,$08,$00,$dc,$fc,$01,$fc,$01,$00,$ac
	db $03,$08,$01,$04,$00,$54,$e0,$01,$c0,$1d,$00,$aa,$01,$04,$01,$04
	db $00,$d7,$80,$23,$80,$20,$00,$af,$01,$c4,$01,$44,$00,$ff,$80,$20
	db $c0,$13,$00,$fe,$03,$08,$03,$08,$00,$be,$e0,$0f,$f0,$03,$00,$7f
	db $07,$10,$0f,$e0,$00,$7d,$f8,$03,$f0,$06,$00,$fb,$1f,$c0,$0f,$e0
	db $00,$ff,$f0,$06,$f0,$06,$00,$ff,$0f,$e0,$07,$70,$00,$7e,$f8,$03

gfx_CobraDuckRight:
	db $ff,$00,$e8,$00,$7f,$00,$3f,$80,$c0,$17,$ff,$00,$ff,$00,$80,$3f
	db $1f,$c0,$0f,$e0,$00,$7e,$ff,$00,$ff,$00,$00,$78,$1f,$40,$1f,$c0
	db $80,$3f,$ff,$00,$fc,$00,$00,$76,$1f,$c0,$1f,$40,$00,$f0,$f0,$03
	db $e0,$0c,$00,$50,$1f,$40,$3f,$80,$00,$3b,$c0,$10,$c0,$10,$00,$35
	db $3f,$80,$07,$80,$00,$2a,$80,$20,$80,$20,$00,$55,$03,$b8,$01,$c4
	db $00,$eb,$80,$20,$80,$23,$00,$f5,$01,$04,$01,$04,$00,$ff,$80,$22
	db $c0,$10,$00,$7f,$03,$c8,$07,$f0,$00,$7d,$c0,$10,$e0,$08,$00,$fe
	db $0f,$c0,$1f,$c0,$00,$be,$f0,$07,$f8,$03,$00,$df,$0f,$60,$0f,$60
	db $00,$ff,$f0,$07,$f0,$07,$00,$ff,$0f,$60,$1f,$c0,$00,$7e,$e0,$0e

gfx_GirlfriendLeft:
	db $f8,$00,$3f,$00,$ff,$00,$ff,$00,$0f,$c0,$e0,$07,$c0,$1f,$07,$f0
	db $ff,$00,$ff,$00,$07,$f0,$c0,$1d,$80,$3a,$03,$f8,$ff,$00,$ff,$00
	db $03,$78,$80,$3b,$c0,$1b,$07,$30,$ff,$00,$ff,$00,$07,$70,$c0,$10
	db $c0,$16,$03,$38,$ff,$00,$ff,$00,$03,$70,$e0,$08,$c0,$1f,$01,$3c
	db $ff,$00,$ff,$00,$00,$66,$e0,$0e,$c0,$1b,$00,$83,$7f,$00,$7f,$00
	db $00,$11,$c0,$10,$c0,$10,$00,$19,$3f,$80,$3f,$80,$00,$3c,$c0,$19
	db $80,$3f,$00,$f4,$3f,$80,$3f,$80,$00,$36,$00,$7e,$00,$5b,$00,$fd
	db $3f,$80,$3f,$80,$00,$f8,$00,$57,$80,$2f,$00,$fd,$3f,$80,$7f,$00
	db $00,$ff,$c0,$0f,$c0,$1f,$00,$fe,$ff,$00,$ff,$00,$00,$fe,$c0,$1f
	db $80,$3f,$00,$ff,$7f,$00,$7f,$00,$00,$ff,$80,$3f,$80,$3f,$00,$ff
	db $7f,$00,$3f,$80,$00,$ff,$00,$7f,$00,$7f,$00,$ff,$3f,$80,$3f,$80
	db $00,$ff,$00,$7f,$00,$7f,$00,$ff,$3f,$80,$7f,$00,$00,$00,$80,$00
	db $fe,$00,$0f,$00,$ff,$00,$ff,$00,$03,$f0,$f8,$01,$f0,$07,$01,$fc
	db $ff,$00,$ff,$00,$01,$7c,$f0,$07,$e0,$0e,$00,$be,$ff,$00,$ff,$00
	db $00,$de,$e0,$0e,$f0,$06,$01,$cc,$ff,$00,$ff,$00,$01,$1c,$f0,$04
	db $f0,$05,$00,$8e,$ff,$00,$ff,$00,$00,$1c,$f8,$02,$f0,$07,$00,$cf
	db $7f,$00,$3f,$80,$00,$99,$f8,$03,$f0,$06,$00,$e0,$1f,$c0,$1f,$40
	db $00,$04,$f0,$04,$f0,$04,$00,$06,$0f,$60,$0f,$20,$00,$4f,$f0,$06
	db $e0,$0f,$00,$fd,$0f,$20,$0f,$a0,$00,$8d,$c0,$1f,$c0,$16,$00,$ff
	db $0f,$60,$0f,$20,$00,$fe,$c0,$15,$e0,$0b,$00,$ff,$0f,$60,$1f,$c0
	db $00,$ff,$f0,$03,$f0,$07,$00,$ff,$3f,$80,$3f,$80,$00,$ff,$f0,$07
	db $e0,$0f,$00,$ff,$1f,$c0,$1f,$c0,$00,$ff,$e0,$0f,$e0,$0f,$00,$ff
	db $1f,$c0,$0f,$e0,$00,$ff,$c0,$1f,$c0,$1f,$00,$ff,$0f,$e0,$0f,$e0
	db $00,$ff,$c0,$1f,$c0,$1f,$00,$ff,$0f,$e0,$1f,$00,$00,$00,$e0,$00
	db $ff,$00,$83,$00,$ff,$00,$ff,$00,$00,$7c,$fe,$00,$fc,$01,$00,$ff
	db $7f,$00,$7f,$00,$00,$df,$fc,$01,$f8,$03,$00,$af,$3f,$80,$3f,$80
	db $00,$b7,$f8,$03,$fc,$01,$00,$b3,$7f,$00,$7f,$00,$00,$07,$fc,$01
	db $fc,$01,$00,$63,$3f,$80,$3f,$00,$00,$87,$fe,$00,$fc,$01,$00,$f3
	db $1f,$c0,$0f,$60,$00,$e6,$fe,$00,$fc,$01,$00,$b8,$07,$30,$07,$10
	db $00,$01,$fc,$01,$fc,$01,$00,$01,$03,$98,$03,$c8,$00,$93,$fc,$01
	db $f8,$03,$00,$ff,$03,$48,$03,$68,$00,$e3,$f0,$07,$f0,$05,$00,$bf
	db $03,$d8,$03,$88,$00,$7f,$f0,$05,$f8,$02,$00,$ff,$03,$d8,$07,$f0
	db $00,$ff,$fc,$00,$fc,$01,$00,$ff,$0f,$e0,$0f,$e0,$00,$ff,$fc,$01
	db $f8,$03,$00,$ff,$07,$f0,$07,$f0,$00,$ff,$f8,$03,$f8,$03,$00,$ff
	db $07,$f0,$03,$f8,$00,$ff,$f0,$07,$f0,$07,$00,$ff,$03,$f8,$03,$f8
	db $00,$ff,$f0,$07,$f0,$07,$00,$ff,$03,$f8,$07,$00,$00,$00,$f8,$00
	db $ff,$00,$e0,$00,$ff,$00,$3f,$00,$80,$1f,$ff,$00,$ff,$00,$00,$7f
	db $1f,$c0,$1f,$c0,$00,$77,$ff,$00,$fe,$00,$00,$eb,$0f,$e0,$0f,$e0
	db $00,$ed,$fe,$00,$ff,$00,$00,$6c,$1f,$c0,$1f,$c0,$00,$41,$ff,$00
	db $ff,$00,$00,$58,$0f,$e0,$0f,$c0,$80,$21,$ff,$00,$ff,$00,$00,$7c
	db $07,$f0,$03,$98,$80,$39,$ff,$00,$ff,$00,$00,$6e,$01,$0c,$01,$44
	db $00,$40,$ff,$00,$ff,$00,$00,$40,$00,$66,$00,$f2,$00,$64,$ff,$00
	db $fe,$00,$00,$ff,$00,$d2,$00,$da,$00,$f8,$fc,$01,$fc,$01,$00,$6f
	db $00,$f6,$00,$e2,$00,$5f,$fc,$01,$fe,$00,$00,$bf,$00,$f6,$01,$fc
	db $00,$3f,$ff,$00,$ff,$00,$00,$7f,$03,$f8,$03,$f8,$00,$7f,$ff,$00
	db $fe,$00,$00,$ff,$01,$fc,$01,$fc,$00,$ff,$fe,$00,$fe,$00,$00,$ff
	db $01,$fc,$00,$fe,$00,$ff,$fc,$01,$fc,$01,$00,$ff,$00,$fe,$00,$fe
	db $00,$ff,$fc,$01,$fc,$01,$00,$ff,$00,$fe,$01,$00,$00,$00,$fe,$00

gfx_GirlfriendRight:
	db $ff,$00,$07,$00,$ff,$00,$ff,$00,$01,$f8,$fc,$00,$f8,$03,$00,$fe
	db $ff,$00,$ff,$00,$00,$ee,$f8,$03,$f0,$07,$00,$d7,$7f,$00,$7f,$00
	db $00,$b7,$f0,$07,$f8,$03,$00,$36,$ff,$00,$ff,$00,$00,$82,$f8,$03
	db $f0,$07,$00,$1a,$ff,$00,$ff,$00,$01,$84,$f0,$03,$e0,$0f,$00,$3e
	db $ff,$00,$ff,$00,$01,$9c,$c0,$19,$80,$30,$00,$76,$ff,$00,$ff,$00
	db $00,$02,$80,$22,$00,$66,$00,$02,$ff,$00,$ff,$00,$00,$26,$00,$4f
	db $00,$4b,$00,$ff,$7f,$00,$3f,$80,$00,$1f,$00,$5b,$00,$6f,$00,$f6
	db $3f,$80,$3f,$80,$00,$fa,$00,$47,$00,$6f,$00,$fd,$7f,$00,$ff,$00
	db $00,$fc,$80,$3f,$c0,$1f,$00,$fe,$ff,$00,$ff,$00,$00,$fe,$c0,$1f
	db $80,$3f,$00,$ff,$7f,$00,$7f,$00,$00,$ff,$80,$3f,$80,$3f,$00,$ff
	db $7f,$00,$3f,$80,$00,$ff,$00,$7f,$00,$7f,$00,$ff,$3f,$80,$3f,$80
	db $00,$ff,$00,$7f,$00,$7f,$00,$ff,$3f,$80,$7f,$00,$00,$00,$80,$00
	db $ff,$00,$c1,$00,$ff,$00,$7f,$00,$00,$3e,$ff,$00,$fe,$00,$00,$ff
	db $3f,$80,$3f,$80,$00,$fb,$fe,$00,$fc,$01,$00,$f5,$1f,$c0,$1f,$c0
	db $00,$ed,$fc,$01,$fe,$00,$00,$cd,$3f,$80,$3f,$80,$00,$e0,$fe,$00
	db $fc,$01,$00,$c6,$3f,$80,$7f,$00,$00,$e1,$fc,$00,$f8,$03,$00,$cf
	db $3f,$80,$7f,$00,$00,$67,$f0,$06,$e0,$0c,$00,$1d,$3f,$80,$3f,$80
	db $00,$80,$e0,$08,$c0,$19,$00,$80,$3f,$80,$3f,$80,$00,$c9,$c0,$13
	db $c0,$12,$00,$ff,$1f,$c0,$0f,$e0,$00,$c7,$c0,$16,$c0,$1b,$00,$fd
	db $0f,$a0,$0f,$a0,$00,$fe,$c0,$11,$c0,$1b,$00,$ff,$1f,$40,$3f,$00
	db $00,$ff,$e0,$0f,$f0,$07,$00,$ff,$3f,$80,$3f,$80,$00,$ff,$f0,$07
	db $e0,$0f,$00,$ff,$1f,$c0,$1f,$c0,$00,$ff,$e0,$0f,$e0,$0f,$00,$ff
	db $1f,$c0,$0f,$e0,$00,$ff,$c0,$1f,$c0,$1f,$00,$ff,$0f,$e0,$0f,$e0
	db $00,$ff,$c0,$1f,$c0,$1f,$00,$ff,$0f,$e0,$1f,$00,$00,$00,$e0,$00
	db $ff,$00,$f0,$00,$7f,$00,$1f,$80,$c0,$0f,$ff,$00,$ff,$00,$80,$3f
	db $0f,$e0,$0f,$e0,$80,$3e,$ff,$00,$ff,$00,$00,$7d,$07,$70,$07,$70
	db $00,$7b,$ff,$00,$ff,$00,$80,$33,$0f,$60,$0f,$20,$80,$38,$ff,$00
	db $ff,$00,$00,$71,$0f,$a0,$1f,$40,$00,$38,$ff,$00,$fe,$00,$00,$f3
	db $0f,$e0,$1f,$c0,$00,$99,$fc,$01,$f8,$03,$00,$07,$0f,$60,$0f,$20
	db $00,$20,$f8,$02,$f0,$06,$00,$60,$0f,$20,$0f,$60,$00,$f2,$f0,$04
	db $f0,$04,$00,$bf,$07,$f0,$03,$f8,$00,$b1,$f0,$05,$f0,$06,$00,$ff
	db $03,$68,$03,$a8,$00,$7f,$f0,$04,$f0,$06,$00,$ff,$07,$d0,$0f,$c0
	db $00,$ff,$f8,$03,$fc,$01,$00,$ff,$0f,$e0,$0f,$e0,$00,$ff,$fc,$01
	db $f8,$03,$00,$ff,$07,$f0,$07,$f0,$00,$ff,$f8,$03,$f8,$03,$00,$ff
	db $07,$f0,$03,$f8,$00,$ff,$f0,$07,$f0,$07,$00,$ff,$03,$f8,$03,$f8
	db $00,$ff,$f0,$07,$f0,$07,$00,$ff,$03,$f8,$07,$00,$00,$00,$f8,$00
	db $ff,$00,$fc,$00,$1f,$00,$07,$e0,$f0,$03,$ff,$00,$ff,$00,$e0,$0f
	db $03,$f8,$03,$b8,$e0,$0f,$ff,$00,$ff,$00,$c0,$1f,$01,$5c,$01,$dc
	db $c0,$1e,$ff,$00,$ff,$00,$e0,$0c,$03,$d8,$03,$08,$e0,$0e,$ff,$00
	db $ff,$00,$c0,$1c,$03,$68,$07,$10,$c0,$0e,$ff,$00,$ff,$00,$80,$3c
	db $03,$f8,$07,$70,$00,$66,$ff,$00,$fe,$00,$00,$c1,$03,$d8,$03,$08
	db $00,$88,$fe,$00,$fc,$01,$00,$98,$03,$08,$03,$98,$00,$3c,$fc,$01
	db $fc,$01,$00,$2f,$01,$fc,$00,$7e,$00,$6c,$fc,$01,$fc,$01,$00,$bf
	db $00,$da,$00,$ea,$00,$1f,$fc,$01,$fc,$01,$00,$bf,$01,$f4,$03,$f0
	db $00,$ff,$fe,$00,$ff,$00,$00,$7f,$03,$f8,$03,$f8,$00,$7f,$ff,$00
	db $fe,$00,$00,$ff,$01,$fc,$01,$fc,$00,$ff,$fe,$00,$fe,$00,$00,$ff
	db $01,$fc,$00,$fe,$00,$ff,$fc,$01,$fc,$01,$00,$ff,$00,$fe,$00,$fe
	db $00,$ff,$fc,$01,$fc,$01,$00,$ff,$00,$fe,$01,$00,$00,$00,$fe,$00

gfx_KnifeRight:
	db $ff,$00,$df,$00,$ff,$00,$ff,$00,$00,$20,$80,$00,$00,$7f,$00,$df
	db $7f,$00,$3f,$80,$00,$52,$00,$40,$80,$30,$00,$5f,$3f,$80,$7f,$00
	db $00,$df,$c0,$0f,$f0,$00,$00,$20,$ff,$00,$ff,$00,$df,$00,$ff,$00
	db $ff,$00,$f7,$00,$ff,$00,$3f,$00,$00,$08,$e0,$00,$c0,$1f,$00,$f7
	db $1f,$c0,$0f,$a0,$00,$14,$c0,$10,$e0,$0c,$00,$17,$0f,$e0,$1f,$c0
	db $00,$f7,$f0,$03,$fc,$00,$00,$08,$3f,$00,$ff,$00,$f7,$00,$ff,$00
	db $ff,$00,$fd,$00,$ff,$00,$0f,$00,$00,$02,$f8,$00,$f0,$07,$00,$fd
	db $07,$f0,$03,$28,$00,$05,$f0,$04,$f8,$03,$00,$05,$03,$f8,$07,$f0
	db $00,$fd,$fc,$00,$ff,$00,$00,$02,$0f,$00,$ff,$00,$fd,$00,$ff,$00
	db $ff,$00,$ff,$00,$7f,$00,$03,$80,$00,$00,$fe,$00,$fc,$01,$00,$ff
	db $01,$7c,$00,$4a,$00,$01,$fc,$01,$fe,$00,$00,$c1,$00,$7e,$01,$7c
	db $00,$3f,$ff,$00,$ff,$00,$c0,$00,$03,$80,$7f,$00,$ff,$00,$ff,$00

gfx_KnifeLeft:
	db $fe,$00,$ff,$00,$ff,$00,$7f,$00,$00,$00,$c0,$01,$80,$3e,$00,$ff
	db $3f,$80,$3f,$80,$00,$80,$00,$52,$00,$7e,$00,$83,$7f,$00,$ff,$00
	db $00,$fc,$80,$3e,$c0,$01,$03,$00,$ff,$00,$ff,$00,$ff,$00,$fe,$00
	db $ff,$00,$bf,$00,$ff,$00,$1f,$00,$00,$40,$f0,$00,$e0,$0f,$00,$bf
	db $0f,$e0,$0f,$20,$00,$a0,$c0,$14,$c0,$1f,$00,$a0,$1f,$c0,$3f,$00
	db $00,$bf,$e0,$0f,$f0,$00,$00,$40,$ff,$00,$ff,$00,$bf,$00,$ff,$00
	db $ff,$00,$ef,$00,$ff,$00,$07,$00,$00,$10,$fc,$00,$f8,$03,$00,$ef
	db $03,$f8,$03,$08,$00,$28,$f0,$05,$f0,$07,$00,$e8,$07,$30,$0f,$c0
	db $00,$ef,$f8,$03,$fc,$00,$00,$10,$3f,$00,$ff,$00,$ef,$00,$ff,$00
	db $ff,$00,$fb,$00,$ff,$00,$01,$00,$00,$04,$ff,$00,$fe,$00,$00,$fb
	db $00,$fe,$00,$02,$00,$4a,$fc,$01,$fc,$01,$00,$fa,$01,$0c,$03,$f0
	db $00,$fb,$fe,$00,$ff,$00,$00,$04,$0f,$00,$ff,$00,$fb,$00,$ff,$00

gfx_PistolLeft:
	db $e0,$00,$07,$00,$ff,$00,$ff,$00,$03,$78,$c0,$1e,$c0,$1f,$03,$f8
	db $ff,$00,$ff,$00,$03,$c8,$e0,$0f,$f0,$00,$01,$44,$ff,$00,$ff,$00
	db $81,$24,$ff,$00,$ff,$00,$81,$3c,$ff,$00,$ff,$00,$c3,$00,$ff,$00

gfx_PistolRight:
	db $c0,$00,$0f,$00,$ff,$00,$ff,$00,$07,$f0,$80,$3c,$80,$3f,$07,$f0
	db $ff,$00,$ff,$00,$0f,$e0,$80,$27,$00,$44,$1f,$00,$ff,$00,$ff,$00
	db $ff,$00,$03,$48,$03,$78,$ff,$00,$ff,$00,$ff,$00,$ff,$00,$87,$00

gfx_MachineGunLeft:
	db $ff,$00,$ff,$00,$ff,$00,$ff,$00,$07,$00,$c0,$00,$80,$3f,$03,$f8
	db $ff,$00,$ff,$00,$01,$d4,$80,$3f,$c0,$18,$01,$7c,$ff,$00,$ff,$00
	db $03,$f8,$80,$17,$00,$71,$00,$3c,$ff,$00,$7f,$00,$00,$33,$80,$1f
	db $c0,$10,$00,$d9,$3f,$80,$3f,$80,$00,$cc,$c6,$10,$c6,$10,$10,$c6
	db $3f,$80,$3f,$80,$18,$c3,$ee,$00,$fe,$00,$1c,$c0,$7f,$00,$ff,$00
	db $1f,$c0,$fe,$00,$ff,$00,$3f,$00,$ff,$00,$ff,$00,$ff,$00,$ff,$00

gfx_MachineGunRight:
	db $ff,$00,$ff,$00,$ff,$00,$03,$00,$e0,$00,$ff,$00,$ff,$00,$c0,$1f
	db $01,$fc,$01,$fc,$80,$2b,$ff,$00,$ff,$00,$80,$3e,$03,$18,$01,$e8
	db $c0,$1f,$ff,$00,$ff,$00,$00,$3c,$00,$8e,$01,$f8,$00,$cc,$fe,$00
	db $fc,$01,$00,$9b,$03,$08,$63,$08,$00,$33,$fc,$01,$fc,$01,$08,$63
	db $63,$08,$77,$00,$18,$c3,$fc,$01,$fe,$00,$38,$03,$7f,$00,$7f,$00
	db $f8,$03,$ff,$00,$ff,$00,$fc,$00,$ff,$00,$ff,$00,$ff,$00,$ff,$00

gfx_Quackometer:
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$03,$f8,$00,$00,$00,$0f,$fe,$00,$00,$00
	db $1f,$82,$00,$00,$00,$3f,$19,$00,$00,$00,$3f,$3d,$00,$00,$00,$3f
	db $39,$00,$00,$00,$7f,$99,$00,$00,$00,$7f,$cd,$00,$00,$00,$7f,$f2
	db $00,$00,$00,$3f,$ff,$00,$00,$00,$3f,$df,$fc,$00,$00,$1f,$ef,$f8
	db $00,$00,$1f,$f3,$e0,$01,$00,$0f,$f8,$00,$00,$00,$07,$fc,$00,$01
	db $00,$07,$fe,$00,$01,$10,$03,$ff,$00,$03,$10,$01,$ff,$c0,$09,$20
	db $fc,$ff,$e0,$0d,$a7,$ff,$7f,$f0,$03,$1f,$ff,$ff,$f8,$03,$3f,$ff
	db $ff,$f8,$00,$7f,$ff,$ff,$fc,$0c,$ff,$ff,$ff,$fc,$00,$ff,$ff,$ff
	db $fe,$01,$ff,$ff,$ff,$fe,$01,$ff,$ff,$ff,$fe,$03,$ff,$ff,$ff,$ff
	db $03,$ff,$ff,$ff,$ff,$03,$ff,$ff,$ff,$ff,$03,$ff,$ff,$ff,$ff,$03
	db $ff,$ff,$ff,$ff,$01,$ff,$ff,$ff,$fe,$01,$ff,$ff,$ff,$fe,$00,$ff
	db $ff,$ff,$fc,$00,$3f,$ff,$ff,$f0

gfx_Explosion:
	db $ff,$00,$ff,$00,$ff,$00,$ff,$00,$ff,$00,$ff,$00,$ff,$00,$ff,$00
	db $ff,$00,$ff,$00,$ff,$00,$ff,$00,$ff,$00,$ff,$00,$ff,$00,$ff,$00
	db $c7,$38,$ff,$00,$ff,$00,$80,$6f,$ff,$00,$ff,$00,$00,$d1,$ff,$00
	db $fe,$01,$00,$83,$ff,$00,$7f,$80,$00,$09,$fe,$01,$fc,$03,$00,$78
	db $7f,$80,$3f,$c0,$30,$4c,$fc,$02,$fc,$02,$38,$46,$3f,$40,$3f,$40
	db $10,$6c,$fc,$02,$fc,$03,$00,$38,$3f,$40,$7f,$80,$00,$01,$fe,$01
	db $fe,$01,$00,$83,$ff,$00,$ff,$00,$01,$d6,$ff,$00,$ff,$00,$83,$7c
	db $ff,$00,$ff,$00,$ff,$00,$ff,$00,$ff,$00,$ff,$00,$ff,$00,$ff,$00
	db $ff,$00,$ff,$00,$ff,$00,$ff,$00,$ff,$00,$ff,$00,$ff,$00,$ff,$00
	db $ff,$00,$ff,$00,$ff,$00,$ff,$00,$ff,$00,$ff,$00,$ff,$00,$ff,$00
	db $ff,$00,$7f,$80,$1c,$e3,$fe,$01,$fe,$01,$00,$3e,$7f,$80,$7f,$80
	db $00,$8d,$fe,$01,$f0,$0f,$00,$01,$ff,$00,$7f,$80,$00,$01,$f0,$08
	db $f0,$0c,$00,$80,$1f,$e0,$1f,$20,$00,$e4,$f0,$08,$e0,$19,$40,$bc
	db $1f,$60,$07,$38,$f8,$06,$e0,$13,$e0,$11,$7c,$83,$07,$08,$07,$18
	db $78,$86,$e0,$10,$e0,$18,$60,$9c,$0f,$10,$0f,$30,$00,$f4,$f0,$08
	db $f0,$08,$00,$60,$1f,$e0,$7f,$80,$00,$21,$f0,$0c,$f8,$05,$00,$01
	db $ff,$00,$ff,$00,$00,$8b,$f8,$07,$ff,$00,$01,$be,$ff,$00,$ff,$00
	db $1f,$e0,$ff,$00,$ff,$00,$ff,$00,$ff,$00,$ff,$00,$ff,$00,$ff,$00
	db $ff,$00,$ff,$00,$ff,$00,$7f,$80,$32,$cd,$ff,$00,$ff,$00,$00,$ba
	db $3f,$c0,$3f,$40,$00,$88,$f8,$07,$e0,$1d,$00,$00,$7f,$80,$1f,$e0
	db $00,$00,$e0,$10,$e0,$18,$00,$80,$07,$38,$07,$08,$00,$80,$c0,$30
	db $c0,$20,$00,$e5,$07,$18,$0f,$10,$40,$be,$c0,$31,$80,$67,$fc,$03
	db $03,$1c,$03,$84,$fe,$01,$80,$41,$80,$61,$7e,$81,$01,$86,$01,$02
	db $7e,$81,$c0,$20,$c0,$20,$70,$8f,$01,$06,$03,$84,$60,$9a,$c0,$30
	db $e0,$1c,$00,$f0,$03,$2c,$07,$38,$00,$60,$e0,$10,$e0,$18,$00,$20
	db $1f,$60,$3f,$c0,$00,$80,$f0,$0a,$f0,$0f,$00,$1d,$7f,$80,$ff,$00
	db $09,$b6,$fe,$01,$ff,$00,$1f,$e0,$ff,$00,$ff,$00,$ff,$00,$ff,$00
	db $fe,$01,$32,$cd,$3f,$c0,$1f,$20,$00,$7a,$fc,$03,$f0,$0f,$00,$08
	db $1f,$20,$3f,$40,$00,$00,$c0,$3a,$c0,$20,$00,$00,$1f,$60,$07,$38
	db $00,$80,$e0,$10,$80,$70,$00,$80,$03,$0c,$03,$04,$00,$c5,$80,$41
	db $80,$43,$80,$6e,$03,$0c,$07,$08,$c4,$3a,$81,$62,$01,$c2,$fc,$02
	db $03,$0c,$01,$06,$fc,$03,$01,$8e,$80,$43,$fe,$01,$01,$c2,$00,$83
	db $fe,$01,$00,$c1,$00,$81,$7e,$81,$00,$01,$00,$03,$70,$8f,$00,$c0
	db $80,$60,$60,$9a,$01,$82,$01,$96,$00,$f1,$c0,$39,$c0,$20,$00,$60
	db $03,$1c,$0f,$30,$00,$20,$c0,$30,$e0,$15,$00,$00,$1f,$a0,$1f,$e0
	db $00,$1d,$e0,$1f,$f6,$09,$08,$b7,$ff,$00,$ff,$00,$1f,$e0,$ff,$00

gfx_PirateGuyLeft:
	db $e0,$0f,$1f,$80,$ff,$00,$ff,$00,$0f,$60,$c0,$10,$80,$3f,$07,$f0
	db $ff,$00,$ff,$00,$0f,$60,$80,$36,$00,$5e,$07,$d0,$ff,$00,$ff,$00
	db $03,$18,$00,$4c,$00,$40,$01,$7c,$ff,$00,$ff,$00,$00,$c6,$00,$68
	db $80,$3d,$00,$82,$ff,$00,$7f,$00,$00,$81,$80,$25,$80,$23,$00,$01
	db $7f,$00,$3f,$80,$00,$80,$00,$77,$00,$7f,$00,$80,$3f,$80,$3f,$80
	db $00,$c0,$00,$7f,$00,$7f,$00,$e0,$3f,$80,$3f,$80,$00,$f8,$80,$3f
	db $80,$3f,$00,$f0,$3f,$80,$3f,$80,$00,$f0,$c0,$1f,$e0,$07,$00,$b0
	db $3f,$80,$3f,$80,$00,$40,$e0,$0c,$c0,$13,$00,$81,$7f,$00,$7f,$00
	db $00,$81,$c0,$13,$c0,$11,$00,$81,$7f,$00,$ff,$00,$00,$c2,$e0,$09
	db $90,$07,$00,$fc,$3f,$00,$1f,$c0,$00,$bf,$08,$63,$00,$53,$40,$0f
	db $1f,$40,$1f,$40,$70,$01,$00,$53,$00,$53,$40,$0e,$1f,$40,$1f,$c0
	db $00,$30,$00,$4f,$00,$61,$00,$21,$3f,$80,$7f,$00,$c0,$1f,$80,$3e
	db $f8,$03,$07,$e0,$ff,$00,$ff,$00,$03,$18,$f0,$04,$e0,$0f,$01,$fc
	db $ff,$00,$ff,$00,$03,$98,$e0,$08,$c0,$14,$01,$b4,$ff,$00,$ff,$00
	db $00,$06,$c0,$13,$c0,$10,$00,$1f,$7f,$00,$3f,$80,$00,$31,$c0,$1a
	db $e0,$0f,$00,$60,$3f,$80,$1f,$40,$00,$60,$e0,$09,$e0,$08,$00,$c0
	db $1f,$40,$0f,$20,$00,$e0,$c0,$1d,$c0,$1f,$00,$e0,$0f,$20,$0f,$20
	db $00,$f0,$c0,$1f,$c0,$1f,$00,$f8,$0f,$20,$0f,$20,$00,$fe,$e0,$0f
	db $e0,$0f,$00,$fc,$0f,$20,$0f,$20,$00,$fc,$f0,$07,$f8,$01,$00,$ec
	db $0f,$20,$0f,$20,$00,$10,$f8,$03,$f0,$04,$00,$e0,$1f,$40,$1f,$40
	db $00,$e0,$f0,$04,$f0,$04,$00,$60,$1f,$40,$3f,$80,$00,$70,$f8,$02
	db $e4,$01,$00,$ff,$0f,$00,$07,$f0,$00,$ef,$c2,$18,$c0,$14,$10,$c3
	db $07,$d0,$07,$50,$1c,$c0,$c0,$14,$c0,$14,$10,$c3,$07,$90,$07,$30
	db $00,$cc,$c0,$13,$c0,$18,$00,$48,$0f,$60,$1f,$c0,$30,$87,$e0,$0f
	db $fe,$00,$01,$f8,$ff,$00,$ff,$00,$00,$06,$fc,$01,$f8,$03,$00,$ff
	db $7f,$00,$ff,$00,$00,$66,$f8,$03,$f0,$05,$00,$ed,$7f,$00,$3f,$80
	db $00,$c1,$f0,$04,$f0,$04,$00,$07,$1f,$c0,$0f,$60,$00,$8c,$f0,$06
	db $f8,$03,$00,$d8,$0f,$20,$07,$10,$00,$58,$f8,$02,$f8,$02,$00,$30
	db $07,$10,$03,$08,$00,$78,$f0,$07,$f0,$07,$00,$f8,$03,$08,$03,$08
	db $00,$fc,$f0,$07,$f0,$07,$00,$fe,$03,$08,$03,$88,$00,$ff,$f8,$03
	db $f8,$03,$00,$ff,$03,$08,$03,$08,$00,$ff,$fc,$01,$fe,$00,$00,$7b
	db $03,$08,$03,$08,$00,$c4,$fe,$00,$fc,$01,$00,$38,$07,$10,$07,$10
	db $00,$38,$fc,$01,$fc,$01,$00,$18,$07,$10,$0f,$20,$00,$9c,$fe,$00
	db $ff,$00,$00,$6f,$1f,$c0,$3f,$00,$80,$0e,$ff,$00,$ff,$00,$f0,$06
	db $ff,$00,$ff,$00,$c0,$06,$ff,$00,$ff,$00,$00,$3f,$7f,$00,$3f,$80
	db $00,$c3,$fe,$00,$fe,$00,$00,$80,$1f,$40,$1f,$c0,$00,$7f,$ff,$00
	db $ff,$00,$80,$3e,$7f,$00,$3f,$80,$00,$41,$ff,$00,$fe,$00,$00,$ff
	db $1f,$c0,$3f,$80,$00,$f9,$fe,$00,$fc,$01,$00,$7b,$1f,$40,$0f,$60
	db $00,$30,$fc,$01,$fc,$01,$00,$01,$07,$f0,$03,$18,$00,$a3,$fc,$01
	db $fe,$00,$00,$f6,$03,$08,$01,$04,$00,$96,$fe,$00,$fe,$00,$00,$8c
	db $01,$04,$00,$02,$00,$de,$fc,$01,$fc,$01,$00,$fe,$00,$02,$00,$02
	db $00,$ff,$fc,$01,$fc,$01,$00,$ff,$00,$82,$00,$e2,$00,$ff,$fe,$00
	db $fe,$00,$00,$ff,$00,$c2,$00,$c2,$00,$7f,$ff,$00,$ff,$00,$80,$1e
	db $00,$c2,$00,$02,$80,$31,$ff,$00,$ff,$00,$00,$4e,$01,$04,$01,$04
	db $00,$4e,$ff,$00,$ff,$00,$00,$46,$01,$04,$03,$08,$80,$27,$ff,$00
	db $ff,$00,$c0,$1b,$07,$f0,$0f,$80,$e0,$03,$ff,$00,$ff,$00,$fc,$01
	db $3f,$80,$3f,$80,$f0,$01,$ff,$00,$ff,$00,$c0,$0f,$1f,$c0,$0f,$e0
	db $80,$30,$ff,$00,$ff,$00,$80,$20,$07,$10,$07,$f0,$c0,$1f,$ff,$00

gfx_PirateGuyRight:
	db $fe,$00,$01,$7c,$ff,$00,$ff,$00,$00,$82,$fc,$01,$f8,$03,$00,$ff
	db $7f,$00,$7f,$00,$00,$9f,$fc,$01,$f8,$02,$00,$de,$3f,$80,$3f,$80
	db $00,$0c,$f0,$06,$e0,$0f,$00,$80,$3f,$80,$3f,$80,$00,$c5,$c0,$18
	db $c0,$10,$00,$6f,$7f,$00,$7f,$00,$00,$69,$80,$20,$80,$20,$00,$31
	db $7f,$00,$3f,$80,$00,$7b,$00,$40,$00,$40,$00,$7f,$3f,$80,$3f,$80
	db $00,$ff,$00,$40,$00,$41,$00,$ff,$3f,$80,$7f,$00,$00,$ff,$00,$47
	db $00,$43,$00,$ff,$7f,$00,$ff,$00,$00,$fe,$00,$43,$00,$43,$01,$78
	db $ff,$00,$ff,$00,$01,$8c,$00,$40,$80,$20,$00,$72,$ff,$00,$ff,$00
	db $00,$72,$80,$20,$80,$20,$00,$62,$ff,$00,$ff,$00,$01,$e4,$c0,$10
	db $e0,$0f,$03,$d8,$ff,$00,$ff,$00,$07,$c0,$f0,$01,$fc,$01,$3f,$80
	db $ff,$00,$ff,$00,$0f,$80,$fc,$01,$f8,$03,$03,$f0,$ff,$00,$ff,$00
	db $01,$0c,$f0,$07,$e0,$08,$01,$04,$ff,$00,$ff,$00,$03,$f8,$e0,$0f
	db $ff,$00,$80,$1f,$7f,$00,$3f,$80,$00,$60,$ff,$00,$fe,$00,$00,$ff
	db $1f,$c0,$1f,$c0,$00,$66,$ff,$00,$fe,$00,$00,$b7,$0f,$a0,$0f,$20
	db $00,$83,$fc,$01,$f8,$03,$00,$e0,$0f,$20,$0f,$60,$00,$31,$f0,$06
	db $f0,$04,$00,$1b,$1f,$c0,$1f,$40,$00,$1a,$e0,$08,$e0,$08,$00,$0c
	db $1f,$40,$0f,$e0,$00,$1e,$c0,$10,$c0,$10,$00,$1f,$0f,$e0,$0f,$e0
	db $00,$3f,$c0,$10,$c0,$10,$00,$7f,$0f,$e0,$1f,$c0,$00,$ff,$c0,$11
	db $c0,$10,$00,$ff,$1f,$c0,$3f,$80,$00,$ff,$c0,$10,$c0,$10,$00,$de
	db $7f,$00,$7f,$00,$00,$23,$c0,$10,$e0,$08,$00,$1c,$3f,$80,$3f,$80
	db $00,$1c,$e0,$08,$e0,$08,$00,$18,$3f,$80,$7f,$00,$00,$39,$f0,$04
	db $f8,$03,$00,$f6,$ff,$00,$ff,$00,$01,$70,$fc,$00,$ff,$00,$0f,$60
	db $ff,$00,$ff,$00,$03,$60,$ff,$00,$fe,$00,$00,$fc,$ff,$00,$7f,$00
	db $00,$c3,$fc,$01,$f8,$02,$00,$01,$7f,$00,$ff,$00,$00,$fe,$f8,$03
	db $ff,$00,$e0,$07,$1f,$c0,$0f,$20,$c0,$18,$ff,$00,$ff,$00,$80,$3f
	db $07,$f0,$07,$10,$c0,$19,$ff,$00,$ff,$00,$80,$2d,$03,$28,$03,$c8
	db $00,$60,$ff,$00,$fe,$00,$00,$f8,$03,$08,$03,$58,$00,$8c,$fc,$01
	db $fc,$01,$00,$06,$07,$f0,$07,$90,$00,$06,$f8,$02,$f8,$02,$00,$03
	db $07,$10,$03,$b8,$00,$07,$f0,$04,$f0,$04,$00,$07,$03,$f8,$03,$f8
	db $00,$0f,$f0,$04,$f0,$04,$00,$1f,$03,$f8,$07,$f0,$00,$7f,$f0,$04
	db $f0,$04,$00,$3f,$07,$f0,$0f,$e0,$00,$3f,$f0,$04,$f0,$04,$00,$37
	db $1f,$80,$1f,$c0,$00,$08,$f0,$04,$f8,$02,$00,$07,$0f,$20,$0f,$20
	db $00,$07,$f8,$02,$f8,$02,$00,$06,$0f,$20,$1f,$40,$00,$0e,$fc,$01
	db $f0,$00,$00,$ff,$27,$80,$43,$18,$00,$f7,$e0,$0f,$e0,$0b,$08,$c3
	db $03,$28,$03,$28,$38,$03,$e0,$0a,$e0,$09,$08,$c3,$03,$28,$03,$c8
	db $00,$33,$e0,$0c,$f0,$06,$00,$12,$03,$18,$07,$f0,$0c,$e1,$f8,$03
	db $ff,$00,$f8,$01,$07,$f0,$03,$08,$f0,$06,$ff,$00,$ff,$00,$e0,$0f
	db $01,$fc,$01,$6c,$f0,$06,$ff,$00,$ff,$00,$e0,$0b,$00,$7a,$00,$32
	db $c0,$18,$ff,$00,$ff,$00,$80,$3e,$00,$02,$00,$16,$00,$63,$ff,$00
	db $ff,$00,$00,$41,$01,$bc,$01,$a4,$00,$81,$fe,$00,$fe,$00,$00,$80
	db $01,$c4,$00,$ee,$00,$01,$fc,$01,$fc,$01,$00,$01,$00,$fe,$00,$fe
	db $00,$03,$fc,$01,$fc,$01,$00,$07,$00,$fe,$01,$fc,$00,$1f,$fc,$01
	db $fc,$01,$00,$0f,$01,$fc,$03,$f8,$00,$0f,$fc,$01,$fc,$01,$00,$0d
	db $07,$e0,$07,$30,$00,$02,$fc,$01,$fe,$00,$00,$81,$03,$c8,$03,$c8
	db $00,$81,$fe,$00,$fe,$00,$00,$81,$03,$88,$07,$90,$00,$43,$ff,$00
	db $fc,$00,$00,$3f,$09,$e0,$10,$c6,$00,$fd,$f8,$03,$f8,$02,$02,$f0
	db $00,$ca,$00,$ca,$0e,$80,$f8,$02,$f8,$02,$02,$70,$00,$ca,$00,$f2
	db $00,$0c,$f8,$03,$fc,$01,$00,$84,$00,$86,$01,$7c,$03,$f8,$fe,$00

gfx_KnifeGuyLeft:
	db $fe,$00,$0f,$00,$ff,$00,$ff,$00,$03,$f0,$c0,$01,$80,$3f,$01,$1c
	db $ff,$00,$ff,$00,$00,$0a,$00,$42,$80,$22,$00,$0a,$ff,$00,$ff,$00
	db $01,$1c,$c0,$1e,$e0,$04,$03,$30,$ff,$00,$ff,$00,$03,$38,$c0,$14
	db $a0,$0c,$01,$7c,$ff,$00,$ff,$00,$03,$38,$00,$5c,$80,$3c,$01,$3c
	db $ff,$00,$ff,$00,$00,$1e,$80,$3e,$00,$7e,$00,$0e,$ff,$00,$7f,$00
	db $00,$0f,$80,$3f,$00,$4f,$00,$9f,$7f,$00,$7f,$00,$00,$ff,$00,$6a
	db $00,$70,$00,$ff,$7f,$00,$7f,$00,$00,$ff,$00,$41,$00,$43,$00,$7e
	db $ff,$00,$ff,$00,$80,$3e,$00,$76,$81,$1c,$00,$7e,$ff,$00,$7f,$00
	db $00,$ff,$e2,$00,$fc,$01,$00,$ff,$7f,$00,$7f,$00,$00,$ff,$f8,$03
	db $f8,$03,$00,$fe,$ff,$00,$3f,$00,$00,$ff,$f0,$07,$80,$07,$00,$9f
	db $1f,$c0,$1f,$c0,$20,$8f,$00,$77,$00,$5f,$20,$8e,$1f,$40,$1f,$40
	db $30,$86,$00,$73,$80,$31,$60,$0d,$1f,$40,$1f,$c0,$60,$0f,$c0,$1f
	db $ff,$00,$83,$00,$ff,$00,$ff,$00,$00,$7c,$f0,$00,$e0,$0f,$00,$c7
	db $7f,$00,$3f,$80,$00,$82,$c0,$10,$e0,$08,$00,$82,$3f,$80,$7f,$00
	db $00,$87,$f0,$07,$f8,$01,$00,$0c,$ff,$00,$ff,$00,$01,$08,$f8,$01
	db $f0,$05,$00,$1e,$ff,$00,$7f,$00,$00,$0f,$e8,$03,$c0,$17,$00,$0f
	db $7f,$00,$3f,$80,$00,$87,$e0,$0f,$e0,$0f,$00,$83,$3f,$80,$1f,$c0
	db $00,$c3,$c0,$1f,$e0,$0f,$00,$e7,$1f,$c0,$1f,$c0,$00,$ff,$c0,$13
	db $c0,$1a,$00,$bf,$1f,$c0,$1f,$c0,$00,$3f,$c0,$1c,$c0,$10,$00,$7f
	db $3f,$80,$3f,$80,$00,$cf,$c0,$10,$c0,$1d,$00,$9f,$3f,$80,$1f,$c0
	db $00,$3f,$e0,$07,$f8,$00,$00,$7f,$1f,$c0,$1f,$c0,$00,$ff,$fe,$00
	db $fe,$00,$00,$ff,$3f,$80,$0f,$c0,$00,$ff,$fc,$01,$e0,$01,$00,$e7
	db $07,$f0,$07,$f0,$08,$e3,$c0,$1d,$c0,$17,$08,$e3,$07,$90,$07,$90
	db $0c,$e1,$c0,$1c,$e0,$0c,$18,$43,$07,$50,$07,$f0,$18,$c3,$f0,$07
	db $ff,$00,$e0,$00,$ff,$00,$3f,$00,$00,$1f,$fc,$00,$f8,$03,$00,$f1
	db $1f,$c0,$0f,$a0,$00,$20,$f0,$04,$f8,$02,$00,$20,$0f,$a0,$1f,$c0
	db $00,$e1,$fc,$01,$fe,$00,$00,$43,$3f,$00,$3f,$80,$00,$43,$fc,$01
	db $fa,$00,$00,$c7,$1f,$c0,$3f,$80,$00,$c3,$f0,$05,$f8,$03,$00,$c3
	db $1f,$c0,$0f,$e0,$00,$e1,$f8,$03,$f0,$07,$00,$e0,$0f,$e0,$07,$f0
	db $00,$f0,$f8,$03,$f0,$04,$00,$f9,$07,$f0,$07,$f0,$00,$af,$f0,$06
	db $f0,$07,$00,$0f,$07,$f0,$07,$f0,$00,$1f,$f0,$04,$f0,$04,$00,$37
	db $0f,$e0,$0f,$e0,$08,$63,$f0,$07,$f8,$01,$18,$c3,$0f,$e0,$07,$f0
	db $30,$07,$fe,$00,$ff,$00,$f0,$07,$07,$f0,$07,$f0,$e0,$0f,$ff,$00
	db $ff,$00,$e0,$0f,$0f,$e0,$1f,$c0,$e0,$0f,$ff,$00,$ff,$00,$f0,$07
	db $0f,$e0,$0f,$e0,$f0,$07,$ff,$00,$ff,$00,$f0,$03,$0f,$e0,$07,$30
	db $e0,$0e,$ff,$00,$ff,$00,$c0,$1b,$07,$30,$07,$f0,$c0,$1f,$ff,$00
	db $ff,$00,$f8,$00,$3f,$00,$0f,$c0,$00,$07,$ff,$00,$fe,$00,$00,$fc
	db $07,$70,$03,$28,$00,$08,$fc,$01,$fe,$00,$00,$88,$03,$28,$07,$70
	db $00,$78,$ff,$00,$ff,$00,$80,$10,$0f,$c0,$0f,$e0,$00,$50,$ff,$00
	db $fe,$00,$80,$31,$07,$f0,$0f,$e0,$00,$70,$fc,$01,$fe,$00,$00,$f0
	db $07,$f0,$03,$78,$00,$f8,$fe,$00,$fc,$01,$00,$f8,$03,$38,$01,$3c
	db $00,$fc,$fe,$00,$fc,$01,$00,$3e,$01,$7c,$01,$fc,$00,$ab,$fc,$01
	db $fc,$01,$00,$c3,$01,$fc,$01,$fc,$00,$07,$fc,$01,$fc,$01,$00,$0d
	db $03,$f8,$03,$f8,$02,$d8,$fc,$01,$fe,$00,$06,$70,$03,$f8,$01,$fc
	db $8c,$01,$ff,$00,$ff,$00,$fc,$01,$01,$fc,$01,$fc,$f8,$03,$ff,$00
	db $ff,$00,$f8,$03,$03,$f8,$07,$f0,$f8,$03,$ff,$00,$ff,$00,$fc,$01
	db $03,$f8,$03,$f8,$fc,$01,$ff,$00,$ff,$00,$fc,$00,$03,$f8,$01,$8c
	db $f8,$03,$ff,$00,$ff,$00,$f0,$06,$01,$cc,$01,$fc,$f0,$07,$ff,$00

gfx_KnifeGuyRight:
	db $f8,$00,$3f,$00,$ff,$00,$ff,$00,$01,$c0,$e0,$07,$c0,$1c,$00,$7e
	db $ff,$00,$7f,$00,$00,$21,$80,$28,$80,$28,$00,$22,$ff,$00,$ff,$00
	db $01,$3c,$c0,$1c,$e0,$06,$03,$10,$ff,$00,$ff,$00,$01,$14,$e0,$0e
	db $c0,$1f,$02,$18,$ff,$00,$7f,$00,$00,$1d,$e0,$0e,$c0,$1e,$00,$1e
	db $ff,$00,$ff,$00,$00,$3e,$80,$3c,$80,$38,$00,$3f,$7f,$00,$ff,$00
	db $00,$7e,$00,$78,$00,$7c,$00,$f9,$7f,$00,$7f,$00,$00,$ab,$00,$7f
	db $00,$7f,$00,$87,$7f,$00,$7f,$00,$00,$c1,$00,$7f,$80,$3f,$00,$61
	db $7f,$00,$7f,$00,$80,$37,$80,$3e,$80,$3e,$c0,$1c,$ff,$00,$ff,$00
	db $63,$00,$00,$7f,$00,$7f,$7f,$00,$ff,$00,$ff,$00,$3f,$80,$00,$7f
	db $80,$3f,$3f,$80,$ff,$00,$ff,$00,$3f,$80,$c0,$1f,$80,$3f,$7f,$00
	db $ff,$00,$ff,$00,$7f,$00,$80,$3f,$80,$3e,$7f,$00,$ff,$00,$ff,$00
	db $3f,$80,$00,$63,$00,$66,$1f,$c0,$ff,$00,$ff,$00,$1f,$c0,$00,$7f
	db $fe,$00,$0f,$00,$ff,$00,$7f,$00,$00,$f0,$f8,$01,$f0,$07,$00,$1f
	db $3f,$80,$1f,$40,$00,$08,$e0,$0a,$e0,$0a,$00,$08,$3f,$80,$7f,$00
	db $00,$0f,$f0,$07,$f8,$01,$00,$84,$ff,$00,$7f,$00,$00,$85,$f8,$03
	db $f0,$07,$00,$c6,$bf,$00,$1f,$40,$00,$87,$f8,$03,$f0,$07,$00,$87
	db $3f,$80,$3f,$80,$00,$0f,$e0,$0f,$e0,$0e,$00,$0f,$1f,$c0,$3f,$80
	db $00,$1f,$c0,$1e,$c0,$1f,$00,$3e,$1f,$40,$1f,$c0,$00,$ea,$c0,$1f
	db $c0,$1f,$00,$e1,$1f,$c0,$1f,$40,$00,$f0,$c0,$1f,$e0,$0f,$00,$d8
	db $1f,$40,$1f,$c0,$20,$8d,$e0,$0f,$e0,$0f,$30,$87,$3f,$00,$ff,$00
	db $18,$c0,$c0,$1f,$c0,$1f,$1f,$c0,$ff,$00,$ff,$00,$0f,$e0,$c0,$1f
	db $e0,$0f,$0f,$e0,$ff,$00,$ff,$00,$0f,$e0,$f0,$07,$e0,$0f,$1f,$c0
	db $ff,$00,$ff,$00,$1f,$c0,$e0,$0f,$e0,$0f,$1f,$80,$ff,$00,$ff,$00
	db $0f,$e0,$c0,$18,$c0,$19,$07,$b0,$ff,$00,$ff,$00,$07,$f0,$c0,$1f
	db $ff,$00,$83,$00,$ff,$00,$1f,$00,$00,$7c,$fe,$00,$fc,$01,$00,$c7
	db $0f,$e0,$07,$10,$00,$82,$f8,$02,$f8,$02,$00,$82,$0f,$20,$1f,$c0
	db $00,$c3,$fc,$01,$fe,$00,$00,$61,$3f,$00,$3f,$00,$00,$21,$ff,$00
	db $fe,$00,$00,$f1,$1f,$40,$2f,$80,$00,$e1,$fc,$01,$fc,$01,$00,$e1
	db $07,$d0,$0f,$e0,$00,$c3,$f8,$03,$f8,$03,$00,$83,$0f,$e0,$07,$f0
	db $00,$87,$f0,$07,$f0,$07,$00,$cf,$0f,$e0,$07,$90,$00,$ff,$f0,$07
	db $f0,$07,$00,$fa,$07,$b0,$07,$70,$00,$f8,$f0,$07,$f8,$03,$00,$fc
	db $07,$10,$07,$10,$00,$e6,$f8,$03,$f8,$03,$00,$f3,$07,$70,$0f,$c0
	db $00,$f9,$f0,$07,$f0,$07,$00,$fc,$3f,$00,$ff,$00,$00,$fe,$f0,$07
	db $f8,$03,$00,$fe,$ff,$00,$7f,$00,$00,$ff,$e0,$07,$c0,$1f,$00,$cf
	db $0f,$00,$07,$70,$20,$8f,$c0,$1f,$c0,$13,$20,$8f,$07,$d0,$07,$70
	db $60,$0e,$c0,$13,$c0,$15,$30,$84,$0f,$60,$1f,$c0,$30,$87,$c0,$1f
	db $ff,$00,$e0,$00,$ff,$00,$07,$00,$80,$1f,$ff,$00,$ff,$00,$00,$71
	db $03,$f8,$01,$84,$00,$a0,$fe,$00,$fe,$00,$00,$a0,$03,$88,$07,$f0
	db $00,$70,$ff,$00,$ff,$00,$80,$18,$0f,$40,$07,$50,$80,$38,$ff,$00
	db $ff,$00,$00,$7c,$0b,$60,$01,$74,$80,$38,$ff,$00,$ff,$00,$00,$78
	db $03,$78,$03,$f8,$00,$f0,$fe,$00,$fe,$00,$00,$e0,$01,$fc,$03,$f8
	db $00,$e1,$fc,$01,$fc,$01,$00,$f3,$01,$e4,$01,$ac,$00,$fe,$fc,$01
	db $fc,$01,$00,$fe,$01,$1c,$01,$04,$00,$ff,$fc,$01,$fe,$00,$00,$fd
	db $01,$84,$01,$dc,$02,$f8,$fe,$00,$fe,$00,$01,$fc,$03,$70,$8f,$00
	db $00,$fe,$fc,$01,$fc,$01,$00,$ff,$7f,$00,$3f,$80,$00,$ff,$fc,$01
	db $fe,$00,$00,$ff,$3f,$80,$1f,$c0,$00,$ff,$f8,$01,$f0,$07,$00,$f3
	db $03,$c0,$01,$dc,$08,$e3,$f0,$07,$f0,$04,$08,$e3,$01,$f4,$01,$9c
	db $18,$c3,$f0,$04,$f0,$05,$0c,$61,$03,$18,$07,$f0,$0c,$e1,$f0,$07

gfx_Glove:
	db $00,$1f,$00,$00,$ff,$c0,$03,$ff,$f0,$07,$ff,$f0,$07,$ff,$f8,$0f
	db $ff,$f8,$0f,$fe,$38,$0f,$f9,$c8,$0f,$f7,$f0,$07,$ef,$f0,$07,$cf
	db $f8,$03,$8f,$f8,$00,$47,$78,$02,$a0,$7c,$07,$d4,$f8,$07,$eb,$f8
	db $07,$d7,$f8,$03,$ff,$f0,$03,$ff,$f0,$01,$ff,$c0,$02,$ff,$a0,$03
	db $ae,$e0,$01,$ff,$c0,$00,$7f,$00

gfx_UseYourHead:
	db $00,$00,$1e,$b0,$00,$00,$01,$80,$7b,$7c,$01,$80,$33,$c0,$5c,$ee
	db $03,$cc,$7b,$cc,$d7,$d5,$33,$de,$7b,$de,$fb,$87,$7b,$de,$7b,$de
	db $90,$1b,$7b,$de,$79,$9e,$20,$05,$79,$9e,$33,$de,$00,$76,$7b,$cc
	db $7b,$cc,$00,$0a,$33,$de,$7b,$de,$03,$bc,$7b,$de,$61,$9e,$00,$68
	db $79,$86,$40,$de,$05,$d0,$7b,$02,$22,$cc,$13,$e0,$33,$44,$7e,$5e
	db $0e,$80,$7a,$7e,$7c,$ae,$1d,$00,$75,$3e,$f1,$74,$3e,$00,$2e,$8f
	db $f8,$ae,$74,$00,$75,$1f,$f5,$56,$78,$00,$6a,$af,$fa,$be,$f8,$00
	db $7d,$5f,$ff,$5e,$f4,$00,$7a,$ff,$7f,$fc,$fb,$70,$3f,$fe,$7f,$7c
	db $7f,$ee,$3e,$fe,$3f,$f8,$7f,$ff,$1f,$fc,$0e,$d0,$1f,$fe,$0b,$70
	db $00,$00,$00,$00,$00,$00,$a4,$e2,$92,$b0,$ae,$4c,$aa,$82,$aa,$a8
	db $a8,$aa,$a8,$82,$aa,$a8,$a8,$aa,$a4,$c1,$2a,$b0,$ec,$ea,$a2,$81
	db $2a,$a8,$a8,$aa,$aa,$81,$2a,$a8,$a8,$aa,$44,$e1,$11,$28,$ae,$ac

gfx_StartToStab:
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$01,$80,$00,$00,$00,$00,$03,$cc,$00,$00,$00
	db $07,$33,$de,$00,$00,$00,$00,$7b,$de,$00,$00,$00,$07,$7b,$86,$00
	db $ff,$4d,$e0,$7b,$02,$38,$ff,$bc,$f7,$7b,$44,$64,$7f,$fe,$f7,$7b
	db $7e,$78,$7f,$7e,$f0,$31,$be,$7c,$3f,$fe,$f7,$00,$0f,$7c,$1f,$ff
	db $f7,$55,$1f,$78,$07,$ff,$f0,$2a,$2f,$64,$00,$fb,$c7,$00,$5f,$38
	db $00,$52,$00,$7a,$ff,$00,$00,$c2,$07,$3f,$fe,$00,$00,$e4,$00,$3e
	db $fe,$00,$00,$44,$00,$1f,$fc,$00,$00,$00,$00,$0b,$70,$00,$00,$04
	db $00,$00,$00,$00,$00,$0c,$00,$00,$00,$00,$00,$0c,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$4e,$4c,$e3,$90,$4e,$4c,$a4,$aa,$41,$28
	db $a4,$aa,$84,$aa,$41,$28,$84,$aa,$44,$ec,$41,$28,$44,$ec,$24,$aa
	db $41,$28,$24,$aa,$a4,$aa,$41,$28,$a4,$aa,$44,$aa,$41,$10,$44,$ac

gfx_ImTheCure:
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$0f,$b7,$7f,$ff,$00,$00,$1f
	db $b0,$ff,$ff,$00,$00,$1f,$bf,$ff,$fe,$00,$00,$10,$1f,$ff,$f0,$00
	db $00,$0f,$80,$00,$0e,$00,$00,$3f,$e0,$ff,$ec,$00,$00,$7f,$f6,$60
	db $00,$00,$00,$ff,$e7,$00,$00,$00,$01,$f7,$67,$40,$00,$00,$01,$f8
	db $60,$c0,$00,$00,$03,$f8,$33,$80,$00,$00,$0f,$f2,$08,$00,$00,$00
	db $3b,$e4,$fc,$00,$00,$00,$ff,$ea,$fc,$00,$00,$00,$fb,$44,$78,$00
	db $00,$00,$fd,$88,$80,$00,$00,$00,$fe,$35,$f0,$00,$00,$00,$fd,$29
	db $f0,$00,$00,$00,$fa,$34,$e0,$00,$00,$00,$ed,$9f,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$eb,$40,$ea,$e0,$4a,$ce,$4a,$a0,$4a,$80
	db $aa,$a8,$42,$a0,$4a,$80,$8a,$a8,$42,$a0,$4e,$c0,$8a,$cc,$42,$a0
	db $4a,$80,$8a,$a8,$42,$a0,$4a,$80,$aa,$a8,$e2,$a0,$4a,$e0,$44,$ae

gfx_DontPushMe:
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$ff,$fe,$7f,$fd
	db $ff,$f0,$00,$00,$7f,$fd,$ff,$f8,$00,$00,$31,$fd,$ff,$f8,$00,$00
	db $0e,$00,$f9,$50,$00,$00,$0e,$00,$0f,$f0,$02,$f0,$0a,$00,$05,$50
	db $47,$db,$0f,$7f,$f8,$00,$6d,$ef,$8f,$00,$06,$f8,$ef,$a4,$7f,$ff
	db $06,$fb,$ff,$00,$7f,$ff,$f8,$ff,$fe,$0c,$08,$00,$fe,$1f,$ff,$c1
	db $87,$f7,$0f,$e0,$5d,$6a,$08,$07,$57,$ff,$13,$bd,$0c,$01,$54,$c1
	db $01,$38,$0c,$00,$00,$1e,$00,$20,$0c,$00,$e1,$bf,$00,$00,$0c,$00
	db $e1,$b7,$00,$00,$0c,$00,$e0,$33,$00,$00,$0e,$00,$e0,$c3,$00,$00
	db $0e,$00,$e0,$71,$00,$00,$03,$00,$e0,$0c,$00,$00,$00,$00,$e0,$1c
	db $00,$00,$00,$00,$00,$00,$c4,$cb,$8c,$a4,$a3,$ce,$aa,$a9,$0a,$aa
	db $a2,$a8,$aa,$a1,$0a,$a8,$a2,$a8,$aa,$a1,$0c,$a4,$e2,$ac,$aa,$a1
	db $08,$a2,$a2,$a8,$aa,$a1,$08,$aa,$a2,$a8,$c4,$a1,$08,$44,$a2,$ae

gfx_CobraSnakeImage:
	db $00,$00,$7c,$00,$00,$ff,$87,$ff,$c3,$fc,$00,$3f,$ff,$f8,$00,$00
	db $ff,$ff,$fc,$00,$01,$9f,$ff,$f3,$00,$02,$06,$ff,$60,$80,$04,$00
	db $7e,$00,$40,$e8,$00,$3c,$00,$4c,$08,$81,$ff,$80,$20,$10,$03,$e7
	db $c0,$a0,$10,$03,$a5,$c0,$20,$35,$01,$a5,$81,$10,$a2,$01,$a5,$88
	db $14,$20,$00,$81,$20,$90,$2c,$90,$42,$02,$d0,$37,$40,$66,$13,$70
	db $bd,$81,$3c,$87,$f4,$2f,$50,$00,$2d,$a0,$3a,$a1,$af,$17,$e0,$bf
	db $ca,$7f,$ad,$ec,$2e,$a2,$c3,$bf,$c0,$97,$f3,$3c,$57,$5c,$1f,$a0
	db $df,$5f,$c0,$cf,$f1,$7f,$bf,$9c,$eb,$6a,$57,$bd,$bc,$07,$fa,$3f
	db $9f,$00,$f5,$f2,$c0,$7f,$7c,$f2,$79,$3f,$ae,$7c,$f9,$b4,$ff,$de
	db $fc,$00,$d9,$56,$dc,$00,$fe,$71,$1f,$cd,$fc,$ff,$39,$38,$39,$fc
	db $ff,$8c,$c7,$bb,$fc,$ff,$c6,$3f,$db,$fc,$00,$03,$4d,$e8,$00,$ff
	db $f9,$43,$6d,$fc,$ff,$fd,$a7,$ed,$fc,$ff,$fc,$bc,$14,$fc,$ff,$fe
	db $43,$fa,$7c,$ff,$ff,$6c,$6b,$7c

gfx_PramLeft:
	db $e0,$00,$3f,$00,$ff,$00,$ff,$00,$1f,$c0,$c0,$1f,$80,$34,$1f,$40
	db $ff,$00,$ff,$00,$1f,$40,$80,$24,$00,$62,$1f,$c0,$ff,$00,$ff,$00
	db $3f,$80,$00,$5a,$00,$4a,$3c,$80,$ff,$00,$7f,$00,$38,$83,$00,$45
	db $00,$75,$70,$04,$3f,$80,$3f,$80,$00,$04,$00,$4b,$00,$7f,$00,$fb
	db $7f,$00,$ff,$00,$00,$ac,$00,$6a,$80,$35,$01,$54,$ff,$00,$ff,$00
	db $01,$ac,$80,$3a,$c0,$0f,$03,$f8,$ff,$00,$ff,$00,$07,$e0,$f0,$03
	db $f0,$06,$07,$30,$ff,$00,$ff,$00,$00,$df,$80,$7d,$00,$c7,$00,$71
	db $7f,$80,$7f,$80,$80,$24,$00,$92,$01,$aa,$c0,$2a,$7f,$80,$7f,$80
	db $c0,$24,$01,$92,$01,$c6,$c0,$31,$7f,$80,$ff,$00,$e0,$1f,$83,$7c
	db $ff,$00,$ff,$00,$ff,$00,$ff,$00,$0f,$00,$f8,$00,$f0,$07,$07,$f0
	db $ff,$00,$ff,$00,$07,$10,$e0,$0d,$e0,$09,$07,$10,$ff,$00,$ff,$00
	db $07,$b0,$c0,$18,$c0,$16,$0f,$a0,$ff,$00,$3f,$00,$0f,$a0,$c0,$12
	db $c0,$11,$0e,$60,$1f,$c0,$0f,$20,$1c,$41,$c0,$1d,$c0,$12,$00,$c1
	db $0f,$20,$1f,$c0,$00,$fe,$c0,$1f,$c0,$1a,$00,$ab,$3f,$00,$7f,$00
	db $00,$55,$e0,$0d,$e0,$0e,$00,$ab,$7f,$00,$ff,$00,$00,$fe,$f0,$03
	db $fc,$00,$01,$f8,$ff,$00,$3f,$c0,$00,$8f,$e0,$1f,$c0,$31,$00,$fc
	db $1f,$60,$1f,$20,$00,$d9,$c0,$24,$c0,$2a,$20,$8a,$1f,$a0,$1f,$20
	db $70,$89,$c0,$24,$c0,$31,$70,$8c,$1f,$60,$3f,$c0,$f8,$07,$e0,$1f
	db $ff,$00,$ff,$00,$ff,$00,$ff,$00,$03,$00,$fe,$00,$fc,$01,$01,$fc
	db $ff,$00,$ff,$00,$01,$44,$f8,$03,$f8,$02,$01,$44,$ff,$00,$ff,$00
	db $01,$2c,$f0,$06,$f0,$05,$03,$a8,$ff,$00,$cf,$00,$03,$a8,$f0,$04
	db $f0,$04,$03,$58,$87,$30,$03,$48,$07,$50,$f0,$07,$f0,$04,$00,$b0
	db $03,$48,$07,$b0,$00,$ff,$f0,$07,$f0,$06,$00,$aa,$0f,$c0,$1f,$40
	db $00,$55,$f8,$03,$f8,$03,$00,$aa,$1f,$c0,$3f,$80,$00,$ff,$fc,$00
	db $ff,$00,$00,$3e,$7f,$00,$0f,$f0,$00,$e3,$f8,$07,$f0,$0c,$00,$7f
	db $07,$18,$07,$48,$08,$36,$f0,$09,$f0,$0a,$1c,$a2,$07,$a8,$07,$48
	db $1c,$22,$f0,$09,$f0,$0c,$1c,$63,$07,$18,$0f,$f0,$3e,$c1,$f8,$07
	db $ff,$00,$80,$00,$ff,$00,$7f,$00,$00,$7f,$ff,$00,$fe,$00,$00,$d1
	db $7f,$00,$7f,$00,$00,$91,$fe,$00,$fc,$01,$00,$8b,$7f,$00,$ff,$00
	db $00,$6a,$fc,$01,$fc,$01,$00,$2a,$f3,$00,$e1,$0c,$00,$16,$fc,$01
	db $fc,$01,$01,$d4,$c0,$12,$00,$12,$00,$2c,$fc,$01,$fc,$01,$00,$ff
	db $01,$ec,$03,$b0,$00,$aa,$fc,$01,$fe,$00,$00,$d5,$07,$50,$07,$b0
	db $00,$ea,$fe,$00,$ff,$00,$00,$3f,$0f,$e0,$1f,$80,$c0,$0f,$ff,$00
	db $ff,$00,$c0,$18,$1f,$c0,$03,$7c,$00,$f7,$fe,$01,$fc,$03,$00,$1d
	db $01,$c6,$01,$92,$02,$48,$fc,$02,$fc,$02,$07,$a8,$01,$aa,$01,$92
	db $07,$48,$fc,$02,$fc,$03,$07,$18,$01,$c6,$83,$7c,$0f,$f0,$fe,$01

gfx_Burger2:
	db $f0,$0f,$03,$fc,$ff,$00,$7f,$80,$00,$07,$80,$78,$00,$c0,$00,$00
	db $3f,$c0,$3f,$40,$00,$00,$00,$80,$00,$80,$00,$00,$3f,$40,$7f,$80
	db $00,$ff,$80,$7f,$00,$da,$00,$12,$3f,$c0,$3f,$40,$00,$80,$00,$bc
	db $00,$d4,$00,$10,$3f,$c0,$7f,$80,$00,$ff,$80,$7f,$80,$4a,$00,$32
	db $7f,$80,$3f,$c0,$00,$ff,$00,$ff,$00,$80,$00,$00,$3f,$40,$3f,$40
	db $00,$00,$00,$80,$00,$c0,$00,$00,$3f,$c0,$7f,$80,$00,$ff,$80,$7f
	db $fc,$03,$00,$ff,$ff,$00,$1f,$e0,$00,$01,$e0,$1e,$c0,$30,$00,$00
	db $0f,$30,$0f,$10,$00,$00,$c0,$20,$c0,$20,$00,$00,$0f,$10,$1f,$e0
	db $00,$ff,$e0,$1f,$c0,$36,$00,$84,$0f,$b0,$0f,$10,$00,$20,$c0,$2f
	db $c0,$35,$00,$04,$0f,$30,$1f,$e0,$00,$ff,$e0,$1f,$e0,$12,$00,$8c
	db $1f,$a0,$0f,$f0,$00,$ff,$c0,$3f,$c0,$20,$00,$00,$0f,$10,$0f,$10
	db $00,$00,$c0,$20,$c0,$30,$00,$00,$0f,$30,$1f,$e0,$00,$ff,$e0,$1f
	db $ff,$00,$00,$ff,$3f,$c0,$07,$78,$00,$80,$f8,$07,$f0,$0c,$00,$00
	db $03,$0c,$03,$04,$00,$00,$f0,$08,$f0,$08,$00,$00,$03,$04,$07,$f8
	db $00,$ff,$f8,$07,$f0,$0d,$00,$a1,$03,$2c,$03,$04,$00,$c8,$f0,$0b
	db $f0,$0d,$00,$41,$03,$0c,$07,$f8,$00,$ff,$f8,$07,$f8,$04,$00,$a3
	db $07,$28,$03,$fc,$00,$ff,$f0,$0f,$f0,$08,$00,$00,$03,$04,$03,$04
	db $00,$00,$f0,$08,$f0,$0c,$00,$00,$03,$0c,$07,$f8,$00,$ff,$f8,$07
	db $ff,$00,$c0,$3f,$0f,$f0,$01,$1e,$00,$e0,$fe,$01,$fc,$03,$00,$00
	db $00,$03,$00,$01,$00,$00,$fc,$02,$fc,$02,$00,$00,$00,$01,$01,$fe
	db $00,$ff,$fe,$01,$fc,$03,$00,$68,$00,$4b,$00,$01,$00,$f2,$fc,$02
	db $fc,$03,$00,$50,$00,$43,$01,$fe,$00,$ff,$fe,$01,$fe,$01,$00,$28
	db $01,$ca,$00,$ff,$00,$ff,$fc,$03,$fc,$02,$00,$00,$00,$01,$00,$01
	db $00,$00,$fc,$02,$fc,$03,$00,$00,$00,$03,$01,$fe,$00,$ff,$fe,$01

gfx_MissileLeft:
	db $ff,$00,$ff,$00,$df,$20,$17,$08,$02,$01,$c0,$00,$80,$3f,$00,$fc
	db $07,$80,$00,$25,$00,$15,$00,$40,$00,$7f,$00,$fd,$07,$48,$1f,$80
	db $01,$fc,$80,$3f,$c0,$00,$03,$00,$df,$20,$ff,$00,$ff,$00,$ff,$00
	db $ff,$00,$ff,$00,$ef,$10,$cf,$00,$00,$00,$f0,$00,$e0,$0f,$00,$ff
	db $0d,$52,$01,$00,$00,$05,$c0,$10,$c0,$1f,$00,$ff,$01,$24,$60,$01
	db $00,$ff,$e0,$0f,$f0,$00,$00,$00,$f7,$08,$ff,$00,$ff,$00,$ff,$00
	db $ff,$00,$ff,$00,$db,$24,$00,$09,$00,$00,$fc,$00,$f8,$03,$00,$ff
	db $01,$c0,$01,$4a,$00,$01,$f0,$04,$f0,$07,$00,$ff,$01,$d0,$01,$c4
	db $00,$ff,$f8,$03,$fc,$00,$00,$00,$2e,$11,$ff,$00,$ff,$00,$ff,$00
	db $ff,$00,$ff,$00,$fb,$04,$08,$01,$00,$00,$ff,$00,$fe,$00,$00,$ff
	db $01,$f8,$01,$54,$00,$00,$fc,$01,$fc,$01,$00,$ff,$00,$f1,$03,$f4
	db $00,$ff,$fe,$00,$ff,$00,$00,$00,$0f,$00,$ff,$00,$ff,$00,$ff,$00

gfx_MissileRight:
	db $df,$20,$ff,$00,$ff,$00,$ff,$00,$00,$00,$10,$80,$80,$1f,$00,$ff
	db $7f,$00,$3f,$80,$00,$00,$80,$2a,$00,$8f,$00,$ff,$3f,$80,$7f,$00
	db $00,$ff,$c0,$2f,$f0,$00,$00,$00,$ff,$00,$ff,$00,$ff,$00,$ff,$00
	db $db,$24,$ff,$00,$ff,$00,$3f,$00,$00,$00,$00,$90,$80,$03,$00,$ff
	db $1f,$c0,$0f,$20,$00,$80,$80,$52,$80,$0b,$00,$ff,$0f,$e0,$1f,$c0
	db $00,$ff,$80,$23,$74,$88,$00,$00,$3f,$00,$ff,$00,$ff,$00,$ff,$00
	db $f7,$08,$ff,$00,$ff,$00,$0f,$00,$00,$00,$f3,$00,$b0,$4a,$00,$ff
	db $07,$f0,$03,$08,$00,$a0,$80,$00,$80,$24,$00,$ff,$03,$f8,$07,$f0
	db $00,$ff,$06,$80,$ef,$10,$00,$00,$0f,$00,$ff,$00,$ff,$00,$ff,$00
	db $fb,$04,$ff,$00,$ff,$00,$03,$00,$40,$80,$e8,$10,$e0,$01,$00,$3f
	db $01,$fc,$00,$02,$00,$a8,$00,$a4,$e0,$12,$00,$bf,$00,$fe,$01,$fc
	db $80,$3f,$f8,$01,$fb,$04,$c0,$00,$03,$00,$ff,$00,$ff,$00,$ff,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
; PreShiftedTiles - Each round's tiles are shifted and stored here.
; 
; The first tuple of tiles is the wrapping parallax ground tile.
;

	org $ee80

PreShiftedTiles:
	db $ff,$ff,$ff,$ff,$ff,$ff,$55,$55,$55,$55,$55,$55,$ff,$ff,$ff,$ff
	db $ff,$ff,$01,$00,$01,$00,$01,$00,$01,$00,$03,$00,$01,$08,$01,$04
	db $41,$41,$05,$40,$0b,$50,$93,$14,$6b,$a5,$ff,$ff,$ff,$ff,$ff,$ff
	db $ed,$6f,$bf,$b5,$84,$df,$bd,$a5,$f5,$d7,$51,$36,$eb,$d6,$ae,$82
	db $84,$2f,$d5,$62,$74,$14,$02,$4d,$42,$88,$20,$80,$20,$06,$90,$00
	db $44,$02,$04,$05,$00,$82,$01,$00,$00,$20,$08,$10,$00,$20,$01,$00
	db $ff,$ff,$ff,$ff,$ff,$ff,$55,$55,$55,$55,$55,$55,$ff,$ff,$ff,$ff
	db $ff,$ff,$00,$40,$00,$40,$00,$40,$00,$40,$00,$c0,$00,$42,$00,$41
	db $10,$50,$41,$50,$42,$d4,$24,$c5,$1a,$e9,$ff,$ff,$ff,$ff,$ff,$ff
	db $fb,$5b,$ef,$ed,$61,$37,$af,$69,$7d,$75,$d4,$4d,$fa,$f5,$ab,$a0
	db $a1,$0b,$75,$58,$9d,$05,$00,$93,$90,$a2,$08,$20,$08,$01,$64,$00
	db $11,$00,$81,$01,$00,$20,$80,$40,$00,$08,$02,$04,$00,$08,$00,$40
	db $ff,$ff,$ff,$ff,$ff,$ff,$55,$55,$55,$55,$55,$55,$ff,$ff,$ff,$ff
	db $ff,$ff,$00,$10,$00,$10,$00,$10,$80,$10,$00,$30,$00,$10,$00,$10
	db $44,$14,$10,$54,$50,$b5,$09,$31,$46,$ba,$ff,$ff,$ff,$ff,$ff,$ff
	db $fe,$d6,$fb,$fb,$58,$4d,$6b,$da,$5f,$5d,$75,$13,$fe,$bd,$6a,$e8
	db $28,$42,$dd,$56,$27,$41,$40,$24,$64,$28,$82,$08,$02,$00,$59,$00
	db $04,$40,$20,$40,$00,$08,$20,$10,$00,$02,$00,$81,$00,$02,$00,$10
	db $ff,$ff,$ff,$ff,$ff,$ff,$55,$55,$55,$55,$55,$55,$ff,$ff,$ff,$ff
	db $ff,$ff,$00,$04,$00,$04,$00,$04,$20,$04,$00,$0c,$00,$04,$00,$04
	db $11,$05,$04,$15,$94,$2d,$42,$4c,$51,$ae,$ff,$ff,$ff,$ff,$ff,$ff
	db $7f,$b5,$be,$fe,$d6,$13,$da,$f6,$97,$d7,$5d,$44,$bf,$af,$5a,$ba
	db $0a,$10,$37,$55,$89,$d0,$50,$09,$19,$0a,$20,$82,$00,$80,$16,$40
	db $01,$10,$08,$10,$80,$02,$08,$04,$00,$00,$00,$20,$40,$00,$80,$04
	db $ff,$ff,$ff,$ff,$ff,$ff,$00,$00,$00,$00,$00,$3f,$10,$10,$10,$10
	db $10,$3f,$00,$00,$00,$00,$00,$3f,$ff,$ff,$ff,$ff,$ff,$ff,$f8,$17
	db $f8,$17,$f8,$bf,$f1,$8b,$f1,$8b,$f1,$7f,$e2,$c5,$e2,$c5,$e2,$ff
	db $c5,$e2,$c5,$e2,$c5,$ff,$8b,$f1,$8b,$f1,$8b,$ff,$17,$f8,$17,$f8
	db $17,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00,$00,$00,$00,$00,$3f,$10,$10
	db $10,$10,$10,$3f,$00,$00,$00,$00,$00,$3f,$ff,$ff,$ff,$ff,$ff,$ff
	db $ff,$ff,$ff,$ff,$ff,$ff,$c0,$00,$00,$00,$00,$0f,$c4,$04,$04,$04
	db $04,$0f,$c0,$00,$00,$00,$00,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$fe,$05
	db $fe,$05,$fe,$2f,$fc,$62,$fc,$62,$fc,$5f,$f8,$b1,$78,$b1,$78,$bf
	db $f1,$78,$b1,$78,$b1,$7f,$e2,$fc,$62,$fc,$62,$ff,$c5,$fe,$05,$fe
	db $05,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$c0,$00,$00,$00,$00,$0f,$c4,$04
	db $04,$04,$04,$0f,$c0,$00,$00,$00,$00,$0f,$ff,$ff,$ff,$ff,$ff,$ff
	db $ff,$ff,$ff,$ff,$ff,$ff,$f0,$00,$00,$00,$00,$03,$f1,$01,$01,$01
	db $01,$03,$f0,$00,$00,$00,$00,$03,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$81
	db $7f,$81,$7f,$8b,$ff,$18,$bf,$18,$bf,$17,$fe,$2c,$5e,$2c,$5e,$2f
	db $fc,$5e,$2c,$5e,$2c,$5f,$f8,$bf,$18,$bf,$18,$bf,$f1,$7f,$81,$7f
	db $81,$7f,$ff,$ff,$ff,$ff,$ff,$ff,$f0,$00,$00,$00,$00,$03,$f1,$01
	db $01,$01,$01,$03,$f0,$00,$00,$00,$00,$03,$ff,$ff,$ff,$ff,$ff,$ff
	db $ff,$ff,$ff,$ff,$ff,$ff,$fc,$00,$00,$00,$00,$00,$fc,$40,$40,$40
	db $40,$40,$fc,$00,$00,$00,$00,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$e0
	db $5f,$e0,$5f,$e2,$ff,$c6,$2f,$c6,$2f,$c5,$ff,$8b,$17,$8b,$17,$8b
	db $ff,$17,$8b,$17,$8b,$17,$fe,$2f,$c6,$2f,$c6,$2f,$fc,$5f,$e0,$5f
	db $e0,$5f,$ff,$ff,$ff,$ff,$ff,$ff,$fc,$00,$00,$00,$00,$00,$fc,$40
	db $40,$40,$40,$40,$fc,$00,$00,$00,$00,$00,$ff,$ff,$ff,$ff,$ff,$ff
	db $ff,$ff,$ec,$ff,$ff,$ff,$d8,$7f,$ec,$ff,$60,$3f,$ff,$ff,$ec,$ff
	db $60,$3f,$ec,$ff,$ec,$ff,$ff,$ff,$ec,$ff,$ec,$ff,$b0,$7f,$ff,$ff
	db $ec,$ff,$b0,$7f,$d8,$7f,$ec,$ff,$b0,$7f,$ff,$ff,$ec,$ff,$b0,$7f
	db $ec,$ff,$ec,$ff,$b0,$7f,$ec,$ff,$ec,$ff,$b0,$7f,$ec,$ff,$ec,$ff
	db $b0,$7f,$ec,$ff,$ec,$ff,$b0,$7f,$ec,$ff,$ec,$ff,$b0,$7f,$ec,$ff
	db $ec,$ff,$ff,$ff,$ec,$ff,$ec,$ff,$60,$3f,$ec,$ff,$ec,$ff,$60,$3f
	db $ff,$ff,$fb,$3f,$ff,$ff,$f6,$1f,$fb,$3f,$d8,$0f,$ff,$ff,$fb,$3f
	db $d8,$0f,$fb,$3f,$fb,$3f,$ff,$ff,$fb,$3f,$fb,$3f,$ec,$1f,$ff,$ff
	db $fb,$3f,$ec,$1f,$f6,$1f,$fb,$3f,$ec,$1f,$ff,$ff,$fb,$3f,$ec,$1f
	db $fb,$3f,$fb,$3f,$ec,$1f,$fb,$3f,$fb,$3f,$ec,$1f,$fb,$3f,$fb,$3f
	db $ec,$1f,$fb,$3f,$fb,$3f,$ec,$1f,$fb,$3f,$fb,$3f,$ec,$1f,$fb,$3f
	db $fb,$3f,$ff,$ff,$fb,$3f,$fb,$3f,$d8,$0f,$fb,$3f,$fb,$3f,$d8,$0f
	db $ff,$ff,$fe,$cf,$ff,$ff,$fd,$87,$fe,$cf,$f6,$03,$ff,$ff,$fe,$cf
	db $f6,$03,$fe,$cf,$fe,$cf,$ff,$ff,$fe,$cf,$fe,$cf,$fb,$07,$ff,$ff
	db $fe,$cf,$fb,$07,$fd,$87,$fe,$cf,$fb,$07,$ff,$ff,$fe,$cf,$fb,$07
	db $fe,$cf,$fe,$cf,$fb,$07,$fe,$cf,$fe,$cf,$fb,$07,$fe,$cf,$fe,$cf
	db $fb,$07,$fe,$cf,$fe,$cf,$fb,$07,$fe,$cf,$fe,$cf,$fb,$07,$fe,$cf
	db $fe,$cf,$ff,$ff,$fe,$cf,$fe,$cf,$f6,$03,$fe,$cf,$fe,$cf,$f6,$03
	db $ff,$ff,$ff,$b3,$ff,$ff,$ff,$61,$ff,$b3,$fd,$80,$ff,$ff,$ff,$b3
	db $fd,$80,$ff,$b3,$ff,$b3,$ff,$ff,$ff,$b3,$ff,$b3,$fe,$c1,$ff,$ff
	db $ff,$b3,$fe,$c1,$ff,$61,$ff,$b3,$fe,$c1,$ff,$ff,$ff,$b3,$fe,$c1
	db $ff,$b3,$ff,$b3,$fe,$c1,$ff,$b3,$ff,$b3,$fe,$c1,$ff,$b3,$ff,$b3
	db $fe,$c1,$ff,$b3,$ff,$b3,$fe,$c1,$ff,$b3,$ff,$b3,$fe,$c1,$ff,$b3
	db $ff,$b3,$ff,$ff,$ff,$b3,$ff,$b3,$fd,$80,$ff,$b3,$ff,$b3,$fd,$80
	db $ff,$ff,$ff,$ff,$ff,$ff,$01,$01,$01,$01,$01,$ff,$01,$01,$01,$01
	db $01,$ff,$01,$01,$01,$01,$01,$ff,$01,$01,$01,$01,$01,$ff,$01,$01
	db $01,$01,$01,$ff,$01,$01,$01,$01,$01,$ff,$01,$01,$01,$01,$01,$ff
	db $ff,$ff,$ff,$ff,$ff,$ff,$08,$21,$08,$21,$09,$ff,$08,$21,$08,$21
	db $09,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$c4,$44,$44,$44,$47,$ff,$ff,$ff
	db $ff,$ff,$ff,$ff,$f5,$55,$55,$55,$5f,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db $ff,$ff,$ff,$ff,$ff,$ff,$c0,$40,$40,$40,$40,$7f,$c0,$40,$40,$40
	db $40,$7f,$c0,$40,$40,$40,$40,$7f,$c0,$40,$40,$40,$40,$7f,$c0,$40
	db $40,$40,$40,$7f,$c0,$40,$40,$40,$40,$7f,$c0,$40,$40,$40,$40,$7f
	db $ff,$ff,$ff,$ff,$ff,$ff,$c2,$08,$42,$08,$42,$7f,$c2,$08,$42,$08
	db $42,$7f,$ff,$ff,$ff,$ff,$ff,$ff,$f1,$11,$11,$11,$11,$ff,$ff,$ff
	db $ff,$ff,$ff,$ff,$fd,$55,$55,$55,$57,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db $ff,$ff,$ff,$ff,$ff,$ff,$f0,$10,$10,$10,$10,$1f,$f0,$10,$10,$10
	db $10,$1f,$f0,$10,$10,$10,$10,$1f,$f0,$10,$10,$10,$10,$1f,$f0,$10
	db $10,$10,$10,$1f,$f0,$10,$10,$10,$10,$1f,$f0,$10,$10,$10,$10,$1f
	db $ff,$ff,$ff,$ff,$ff,$ff,$f0,$82,$10,$82,$10,$9f,$f0,$82,$10,$82
	db $10,$9f,$ff,$ff,$ff,$ff,$ff,$ff,$fc,$44,$44,$44,$44,$7f,$ff,$ff
	db $ff,$ff,$ff,$ff,$ff,$55,$55,$55,$55,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db $ff,$ff,$ff,$ff,$ff,$ff,$fc,$04,$04,$04,$04,$07,$fc,$04,$04,$04
	db $04,$07,$fc,$04,$04,$04,$04,$07,$fc,$04,$04,$04,$04,$07,$fc,$04
	db $04,$04,$04,$07,$fc,$04,$04,$04,$04,$07,$fc,$04,$04,$04,$04,$07
	db $ff,$ff,$ff,$ff,$ff,$ff,$fc,$20,$84,$20,$84,$27,$fc,$20,$84,$20
	db $84,$27,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$11,$11,$11,$11,$1f,$ff,$ff
	db $ff,$ff,$ff,$ff,$ff,$d5,$55,$55,$55,$7f,$ff,$ff,$ff,$ff,$ff,$ff
	db $ff,$ff,$ff,$ff,$ff,$ff,$01,$01,$01,$01,$01,$ff,$01,$01,$01,$01
	db $01,$ff,$01,$01,$01,$01,$01,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$10,$10
	db $10,$10,$11,$ff,$10,$10,$10,$10,$11,$ff,$10,$10,$10,$10,$11,$ff
	db $ff,$ff,$ff,$ff,$ff,$ff,$01,$01,$01,$01,$01,$ff,$01,$01,$01,$01
	db $01,$ff,$01,$01,$01,$01,$01,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$10,$10
	db $10,$10,$11,$ff,$10,$10,$10,$10,$11,$ff,$10,$10,$10,$10,$11,$ff
	db $ff,$ff,$ff,$ff,$ff,$ff,$c0,$40,$40,$40,$40,$7f,$c0,$40,$40,$40
	db $40,$7f,$c0,$40,$40,$40,$40,$7f,$ff,$ff,$ff,$ff,$ff,$ff,$c4,$04
	db $04,$04,$04,$7f,$c4,$04,$04,$04,$04,$7f,$c4,$04,$04,$04,$04,$7f
	db $ff,$ff,$ff,$ff,$ff,$ff,$c0,$40,$40,$40,$40,$7f,$c0,$40,$40,$40
	db $40,$7f,$c0,$40,$40,$40,$40,$7f,$ff,$ff,$ff,$ff,$ff,$ff,$c4,$04
	db $04,$04,$04,$7f,$c4,$04,$04,$04,$04,$7f,$c4,$04,$04,$04,$04,$7f
	db $ff,$ff,$ff,$ff,$ff,$ff,$f0,$10,$10,$10,$10,$1f,$f0,$10,$10,$10
	db $10,$1f,$f0,$10,$10,$10,$10,$1f,$ff,$ff,$ff,$ff,$ff,$ff,$f1,$01
	db $01,$01,$01,$1f,$f1,$01,$01,$01,$01,$1f,$f1,$01,$01,$01,$01,$1f
	db $ff,$ff,$ff,$ff,$ff,$ff,$f0,$10,$10,$10,$10,$1f,$f0,$10,$10,$10
	db $10,$1f,$f0,$10,$10,$10,$10,$1f,$ff,$ff,$ff,$ff,$ff,$ff,$f1,$01
	db $01,$01,$01,$1f,$f1,$01,$01,$01,$01,$1f,$f1,$01,$01,$01,$01,$1f
	db $ff,$ff,$ff,$ff,$ff,$ff,$fc,$04,$04,$04,$04,$07,$fc,$04,$04,$04
	db $04,$07,$fc,$04,$04,$04,$04,$07,$ff,$ff,$ff,$ff,$ff,$ff,$fc,$40
	db $40,$40,$40,$47,$fc,$40,$40,$40,$40,$47,$fc,$40,$40,$40,$40,$47
	db $ff,$ff,$ff,$ff,$ff,$ff,$fc,$04,$04,$04,$04,$07,$fc,$04,$04,$04
	db $04,$07,$fc,$04,$04,$04,$04,$07,$ff,$ff,$ff,$ff,$ff,$ff,$fc,$40
	db $40,$40,$40,$47,$fc,$40,$40,$40,$40,$47,$fc,$40,$40,$40,$40,$47
	db $f3,$f3,$f3,$f3,$f3,$ff,$15,$15,$15,$15,$15,$ff,$19,$19,$19,$19
	db $19,$ff,$15,$15,$15,$15,$15,$ff,$13,$13,$13,$13,$13,$ff,$15,$15
	db $15,$15,$15,$ff,$19,$19,$19,$19,$19,$ff,$15,$15,$15,$15,$15,$ff
	db $1f,$1f,$1f,$1f,$1f,$ff,$15,$15,$15,$15,$15,$ff,$19,$19,$19,$19
	db $19,$ff,$15,$15,$15,$15,$15,$ff,$13,$13,$13,$13,$13,$ff,$15,$15
	db $15,$15,$15,$ff,$19,$19,$19,$19,$19,$ff,$15,$15,$15,$15,$15,$ff
	db $fc,$fc,$fc,$fc,$fc,$ff,$c5,$45,$45,$45,$45,$7f,$c6,$46,$46,$46
	db $46,$7f,$c5,$45,$45,$45,$45,$7f,$c4,$c4,$c4,$c4,$c4,$ff,$c5,$45
	db $45,$45,$45,$7f,$c6,$46,$46,$46,$46,$7f,$c5,$45,$45,$45,$45,$7f
	db $c7,$c7,$c7,$c7,$c7,$ff,$c5,$45,$45,$45,$45,$7f,$c6,$46,$46,$46
	db $46,$7f,$c5,$45,$45,$45,$45,$7f,$c4,$c4,$c4,$c4,$c4,$ff,$c5,$45
	db $45,$45,$45,$7f,$c6,$46,$46,$46,$46,$7f,$c5,$45,$45,$45,$45,$7f
	db $ff,$3f,$3f,$3f,$3f,$3f,$f1,$51,$51,$51,$51,$5f,$f1,$91,$91,$91
	db $91,$9f,$f1,$51,$51,$51,$51,$5f,$f1,$31,$31,$31,$31,$3f,$f1,$51
	db $51,$51,$51,$5f,$f1,$91,$91,$91,$91,$9f,$f1,$51,$51,$51,$51,$5f
	db $f1,$f1,$f1,$f1,$f1,$ff,$f1,$51,$51,$51,$51,$5f,$f1,$91,$91,$91
	db $91,$9f,$f1,$51,$51,$51,$51,$5f,$f1,$31,$31,$31,$31,$3f,$f1,$51
	db $51,$51,$51,$5f,$f1,$91,$91,$91,$91,$9f,$f1,$51,$51,$51,$51,$5f
	db $ff,$cf,$cf,$cf,$cf,$cf,$fc,$54,$54,$54,$54,$57,$fc,$64,$64,$64
	db $64,$67,$fc,$54,$54,$54,$54,$57,$fc,$4c,$4c,$4c,$4c,$4f,$fc,$54
	db $54,$54,$54,$57,$fc,$64,$64,$64,$64,$67,$fc,$54,$54,$54,$54,$57
	db $fc,$7c,$7c,$7c,$7c,$7f,$fc,$54,$54,$54,$54,$57,$fc,$64,$64,$64
	db $64,$67,$fc,$54,$54,$54,$54,$57,$fc,$4c,$4c,$4c,$4c,$4f,$fc,$54
	db $54,$54,$54,$57,$fc,$64,$64,$64,$64,$67,$fc,$54,$54,$54,$54,$57
	db $ff,$ff,$ff,$ff,$ff,$ff,$e0,$c3,$f0,$7f,$e0,$7f,$da,$28,$cc,$7f
	db $9a,$3f,$dd,$40,$ce,$3f,$3c,$bf,$ba,$00,$4c,$3f,$70,$3f,$bc,$00
	db $50,$3f,$20,$3f,$b0,$00,$40,$3f,$90,$bf,$70,$02,$68,$3f,$80,$bf
	db $20,$00,$7c,$3f,$50,$bf,$50,$00,$e6,$7f,$40,$7f,$20,$82,$c3,$ff
	db $00,$3f,$40,$00,$c8,$ff,$20,$3f,$21,$06,$40,$3f,$40,$3f,$41,$2b
	db $50,$3f,$71,$3f,$22,$16,$68,$3f,$28,$7f,$83,$e0,$e0,$7f,$80,$ff
	db $ff,$ff,$ff,$ff,$ff,$ff,$f8,$30,$fc,$1f,$f8,$1f,$f6,$8a,$33,$1f
	db $e6,$8f,$f7,$50,$33,$8f,$cf,$2f,$ee,$80,$13,$0f,$dc,$0f,$ef,$00
	db $14,$0f,$c8,$0f,$ec,$00,$10,$0f,$e4,$2f,$dc,$00,$9a,$0f,$e0,$2f
	db $c8,$00,$1f,$0f,$d4,$2f,$d4,$00,$39,$9f,$d0,$1f,$c8,$20,$b0,$ff
	db $c0,$0f,$d0,$00,$32,$3f,$c8,$0f,$c8,$41,$90,$0f,$d0,$0f,$d0,$4a
	db $d4,$0f,$dc,$4f,$c8,$85,$9a,$0f,$ca,$1f,$e0,$f8,$38,$1f,$e0,$3f
	db $ff,$ff,$ff,$ff,$ff,$ff,$fe,$0c,$3f,$07,$fe,$07,$fd,$a2,$8c,$c7
	db $f9,$a3,$fd,$d4,$0c,$e3,$f3,$cb,$fb,$a0,$04,$c3,$f7,$03,$fb,$c0
	db $05,$03,$f2,$03,$fb,$00,$04,$03,$f9,$0b,$f7,$00,$26,$83,$f8,$0b
	db $f2,$00,$07,$c3,$f5,$0b,$f5,$00,$0e,$67,$f4,$07,$f2,$08,$2c,$3f
	db $f0,$03,$f4,$00,$0c,$8f,$f2,$03,$f2,$10,$64,$03,$f4,$03,$f4,$12
	db $b5,$03,$f7,$13,$f2,$21,$66,$83,$f2,$87,$f8,$3e,$0e,$07,$f8,$0f
	db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$83,$0f,$c1,$ff,$81,$ff,$68,$a3,$31
	db $fe,$68,$ff,$75,$03,$38,$fc,$f2,$fe,$e8,$01,$30,$fd,$c0,$fe,$f0
	db $01,$40,$fc,$80,$fe,$c0,$01,$00,$fe,$42,$fd,$c0,$09,$a0,$fe,$02
	db $fc,$80,$01,$f0,$fd,$42,$fd,$40,$03,$99,$fd,$01,$fc,$82,$0b,$0f
	db $fc,$00,$fd,$00,$03,$23,$fc,$80,$fc,$84,$19,$00,$fd,$00,$fd,$04
	db $ad,$40,$fd,$c4,$fc,$88,$59,$a0,$fc,$a1,$fe,$0f,$83,$81,$fe,$03
	db $ff,$ff,$ff,$ff,$ff,$ff,$fe,$43,$c0,$03,$c2,$7f,$ff,$fe,$7f,$fe
	db $7f,$ff,$fc,$43,$c0,$03,$c2,$3f,$ff,$c2,$40,$02,$43,$ff,$fe,$43
	db $c0,$03,$c2,$7f,$fe,$7f,$ff,$ff,$fe,$7f,$fe,$7f,$ff,$ff,$fe,$7f
	db $fe,$7f,$ff,$ff,$fe,$7f,$fe,$7f,$ff,$ff,$fe,$7f,$fe,$7f,$ff,$ff
	db $fe,$7f,$fe,$7f,$ff,$ff,$fe,$7f,$ff,$ff,$ff,$ff,$ff,$ff,$fd,$3f
	db $ff,$ff,$fd,$3f,$fd,$3f,$ff,$ff,$fd,$3f,$fd,$3f,$ff,$ff,$fd,$3f
	db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$90,$f0,$00,$f0,$9f,$ff,$ff,$9f,$ff
	db $9f,$ff,$ff,$10,$f0,$00,$f0,$8f,$ff,$f0,$90,$00,$90,$ff,$ff,$90
	db $f0,$00,$f0,$9f,$ff,$9f,$ff,$ff,$ff,$9f,$ff,$9f,$ff,$ff,$ff,$9f
	db $ff,$9f,$ff,$ff,$ff,$9f,$ff,$9f,$ff,$ff,$ff,$9f,$ff,$9f,$ff,$ff
	db $ff,$9f,$ff,$9f,$ff,$ff,$ff,$9f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$4f
	db $ff,$ff,$ff,$4f,$ff,$4f,$ff,$ff,$ff,$4f,$ff,$4f,$ff,$ff,$ff,$4f
	db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$e4,$3c,$00,$3c,$27,$ff,$ff,$e7,$ff
	db $e7,$ff,$ff,$c4,$3c,$00,$3c,$23,$ff,$fc,$24,$00,$24,$3f,$ff,$e4
	db $3c,$00,$3c,$27,$ff,$e7,$ff,$ff,$ff,$e7,$ff,$e7,$ff,$ff,$ff,$e7
	db $ff,$e7,$ff,$ff,$ff,$e7,$ff,$e7,$ff,$ff,$ff,$e7,$ff,$e7,$ff,$ff
	db $ff,$e7,$ff,$e7,$ff,$ff,$ff,$e7,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$d3
	db $ff,$ff,$ff,$d3,$ff,$d3,$ff,$ff,$ff,$d3,$ff,$d3,$ff,$ff,$ff,$d3
	db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$f9,$0f,$00,$0f,$09,$ff,$ff,$f9,$ff
	db $f9,$ff,$ff,$f1,$0f,$00,$0f,$08,$ff,$ff,$09,$00,$09,$0f,$ff,$f9
	db $0f,$00,$0f,$09,$ff,$f9,$ff,$ff,$ff,$f9,$ff,$f9,$ff,$ff,$ff,$f9
	db $ff,$f9,$ff,$ff,$ff,$f9,$ff,$f9,$ff,$ff,$ff,$f9,$ff,$f9,$ff,$ff
	db $ff,$f9,$ff,$f9,$ff,$ff,$ff,$f9,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$f4
	db $ff,$ff,$ff,$f4,$ff,$f4,$ff,$ff,$ff,$f4,$ff,$f4,$ff,$ff,$ff,$f4
	db $e9,$ff,$ff,$ff,$ff,$ff,$b8,$7f,$fe,$7f,$fe,$7f,$70,$3f,$fe,$7f
	db $fe,$7f,$ff,$ff,$fe,$7f,$fe,$7f,$ba,$7f,$fe,$7f,$fe,$7f,$ba,$7f
	db $e6,$7f,$fe,$7f,$ba,$7f,$ef,$ff,$fe,$7f,$3a,$3f,$e5,$3f,$fe,$7f
	db $3a,$3f,$ad,$3f,$fe,$7f,$ba,$7f,$ad,$3f,$fe,$7f,$ba,$7f,$e5,$3f
	db $fe,$7f,$ba,$7f,$ef,$ff,$fe,$7f,$ba,$7f,$e6,$7f,$ff,$ff,$ba,$7f
	db $fe,$7f,$fd,$3f,$ff,$ff,$fe,$7f,$fd,$3f,$70,$3f,$fe,$7f,$fd,$3f
	db $fa,$7f,$ff,$ff,$ff,$ff,$ee,$1f,$ff,$9f,$ff,$9f,$dc,$0f,$ff,$9f
	db $ff,$9f,$ff,$ff,$ff,$9f,$ff,$9f,$ee,$9f,$ff,$9f,$ff,$9f,$ee,$9f
	db $f9,$9f,$ff,$9f,$ee,$9f,$fb,$ff,$ff,$9f,$ce,$8f,$f9,$4f,$ff,$9f
	db $ce,$8f,$eb,$4f,$ff,$9f,$ee,$9f,$eb,$4f,$ff,$9f,$ee,$9f,$f9,$4f
	db $ff,$9f,$ee,$9f,$fb,$ff,$ff,$9f,$ee,$9f,$f9,$9f,$ff,$ff,$ee,$9f
	db $ff,$9f,$ff,$4f,$ff,$ff,$ff,$9f,$ff,$4f,$dc,$0f,$ff,$9f,$ff,$4f
	db $fe,$9f,$ff,$ff,$ff,$ff,$fb,$87,$ff,$e7,$ff,$e7,$f7,$03,$ff,$e7
	db $ff,$e7,$ff,$ff,$ff,$e7,$ff,$e7,$fb,$a7,$ff,$e7,$ff,$e7,$fb,$a7
	db $fe,$67,$ff,$e7,$fb,$a7,$fe,$ff,$ff,$e7,$f3,$a3,$fe,$53,$ff,$e7
	db $f3,$a3,$fa,$d3,$ff,$e7,$fb,$a7,$fa,$d3,$ff,$e7,$fb,$a7,$fe,$53
	db $ff,$e7,$fb,$a7,$fe,$ff,$ff,$e7,$fb,$a7,$fe,$67,$ff,$ff,$fb,$a7
	db $ff,$e7,$ff,$d3,$ff,$ff,$ff,$e7,$ff,$d3,$f7,$03,$ff,$e7,$ff,$d3
	db $ff,$a7,$ff,$ff,$ff,$ff,$fe,$e1,$ff,$f9,$ff,$f9,$fd,$c0,$ff,$f9
	db $ff,$f9,$ff,$ff,$ff,$f9,$ff,$f9,$fe,$e9,$ff,$f9,$ff,$f9,$fe,$e9
	db $ff,$99,$ff,$f9,$fe,$e9,$ff,$bf,$ff,$f9,$fc,$e8,$ff,$94,$ff,$f9
	db $fc,$e8,$fe,$b4,$ff,$f9,$fe,$e9,$fe,$b4,$ff,$f9,$fe,$e9,$ff,$94
	db $ff,$f9,$fe,$e9,$ff,$bf,$ff,$f9,$fe,$e9,$ff,$99,$ff,$ff,$fe,$e9
	db $ff,$f9,$ff,$f4,$ff,$ff,$ff,$f9,$ff,$f4,$fd,$c0,$ff,$f9,$ff,$f4

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

SineTable:
	db $00,$01,$02,$04,$05,$06,$07,$08,$09,$0a,$0c,$0d,$0e,$0f,$10,$11
	db $12,$14,$15,$16,$17,$18,$19,$1a,$1b,$1c,$1d,$1e,$1f,$20,$21,$22
	db $23,$24,$25,$26,$27,$28,$29,$2a,$2b,$2c,$2d,$2d,$2e,$2f,$30,$31
	db $31,$32,$33,$34,$34,$35,$36,$36,$37,$38,$38,$39,$39,$3a,$3a,$3b
	db $3b,$3c,$3c,$3d,$3d,$3e,$3e,$3e,$3f,$3f,$3f,$3f,$40,$40,$40,$40
	db $40,$41,$41,$41,$41,$41,$41,$41,$41,$41,$41,$41,$41,$41,$41,$40
	db $40,$40,$40,$40,$3f,$3f,$3f,$3e,$3e,$3e,$3d,$3d,$3d,$3c,$3c,$3b
	db $3b,$3a,$3a,$39,$38,$38,$37,$37,$36,$35,$35,$34,$33,$33,$32,$31
	db $30,$30,$2f,$2e,$2d,$2c,$2b,$2a,$2a,$29,$28,$27,$26,$25,$24,$23
	db $22,$21,$20,$1f,$1e,$1d,$1c,$1b,$1a,$19,$17,$16,$15,$14,$13,$12
	db $11,$10,$0f,$0d,$0c,$0b,$0a,$09,$08,$06,$05,$04,$03,$02,$01,$00

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

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
; $FD00 - PAGE $FD
;

; IM2 I register points to this $FD page and sets it to point to the interrupt handler at $FFFF

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

	org $fe00		; page $FE

gfx_CobraLogo:
	db $ff,$7d,$c0,$7c,$0f,$fe,$0f,$fe,$00,$03,$fc,$00,$01,$ff,$c1,$ff
	db $0f,$ff,$8f,$ff,$80,$03,$fc,$00,$03,$ff,$c3,$ff,$8f,$ff,$cf,$ff
	db $c0,$03,$fc,$00,$07,$ff,$c7,$ff,$cf,$ff,$ef,$ff,$e0,$03,$fc,$00
	db $07,$ff,$c7,$ff,$c7,$ff,$e7,$ff,$e0,$07,$fe,$00,$0f,$ef,$cf,$ef
	db $e3,$f7,$f3,$f7,$f0,$07,$fe,$00,$0f,$c7,$cf,$c7,$e3,$f3,$f3,$f3
	db $f0,$07,$fe,$00,$0f,$c7,$cf,$c7,$e3,$f3,$f3,$f3,$f0,$07,$fe,$00
	db $1f,$c7,$df,$c7,$f3,$f3,$f3,$f3,$f0,$0f,$bf,$00,$1f,$c7,$df,$c7
	db $f3,$f3,$f3,$f3,$f0,$0f,$bf,$00,$1f,$c7,$df,$c7,$f3,$f7,$f3,$f7
	db $f0,$0f,$bf,$00,$1f,$c0,$1f,$c7,$f3,$ff,$e3,$ff,$e0,$0f,$bf,$00
	db $1f,$c0,$1f,$c7,$f3,$ff,$c3,$ff,$c0,$1f,$1f,$80,$3f,$c0,$1f,$c7
	db $f3,$ff,$e3,$ff,$e0,$1f,$1f,$80,$1f,$c7,$df,$c7,$f3,$f7,$e3,$f7
	db $e0,$1f,$1f,$80,$1f,$c7,$df,$c7,$f3,$f3,$f3,$f3,$f0,$1f,$ff,$80
	db $1f,$c7,$df,$c7,$f3,$f3,$f3,$f3,$f0,$3f,$ff,$c0,$1f,$c7,$df,$c7
	db $f3,$f3,$f3,$f3,$f0,$3f,$ff,$c0,$0f,$c7,$cf,$c7,$e3,$f3,$f3,$f3
	db $f0,$3e,$0f,$c0,$0f,$c7,$cf,$c7,$e3,$f3,$f3,$f3,$f0,$3e,$0f,$c0
	db $0f,$ef,$cf,$ef,$e3,$f7,$f3,$f3,$f6,$7e,$0f,$e0,$07,$ff,$c7,$ff
	db $c7,$ff,$e7,$fb,$fe,$ff,$1f,$f0,$07,$ff,$87,$ff,$cf,$ff,$ef,$ff
	db $ff,$ff,$bf,$f8,$03,$ff,$83,$ff,$8f,$ff,$cf,$fd,$ff,$ff,$bf,$f8
	db $01,$ff,$01,$ff,$0f,$ff,$8f,$fd,$fd,$ff,$bf,$f8,$00,$7c,$00,$7c
	db $0f,$fe,$0f,$fc,$79,$ff,$bf,$f8

gfx_WarnerLogo:
	db $01,$c0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$02,$21,$77,$21
	db $10,$00,$00,$18,$00,$01,$c0,$00,$05,$d1,$55,$41,$10,$00,$00,$14
	db $00,$00,$80,$00,$05,$11,$77,$71,$51,$77,$37,$19,$dc,$c0,$9d,$c0
	db $05,$d1,$15,$51,$b3,$45,$74,$15,$14,$80,$95,$00,$02,$21,$27,$71
	db $15,$45,$44,$19,$1d,$91,$d5,$d0,$01,$c0,$00,$00,$00,$00,$20,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$3e,$08,$08,$08,$08,$3e,$00,$00,$02,$02,$02,$42,$42,$3c,$00
	db $00,$44,$48,$70,$48,$44,$42,$00,$00,$40,$40,$40,$40,$40,$7e,$00
	db $00,$42,$66,$5a,$42,$42,$42,$00,$00,$42,$62,$52,$4a,$46,$42,$00
	db $00,$3c,$42,$42,$42,$42,$3c,$00,$00,$7c,$42,$42,$7c,$40,$40,$00
	db $00,$3c,$42,$42,$52,$4a,$3c,$00,$00,$7c,$42,$42,$7c,$44,$42,$00
	db $00,$3c,$40,$3c,$02,$42,$3c,$00,$00,$fe,$10,$10


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
	
	

	