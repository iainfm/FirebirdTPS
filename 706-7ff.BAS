REM BBC BASIC / assembler version of 706-7FF.asm
REM *LOAD dectable.bin at &600
REM assemble STRIKE.BAS first
REM Set PAGE to &3000, LOAD, RUN and CALL &706 to start

IF PAGE<>&3000 P."Set page to &3000 and reload.":END
HIMEM   = &5000

USERV   = &0200
L020E   = &020E
L020F   = &020F
L0220   = &0220
L0221   = &0221

L3527   = &3527
L3528   = &3528
L3529   = &3529
L352A   = &352A

L79C1   = &79C1

S_ULA   = &FE10
LFFB6   = &FFB6
LFFB7   = &FFB7
LFFB8   = &FFB8
osbyte  = &FFF4

FOR p=0 TO 3 STEP 3
P%=&706

[OPT p
.entry
LDY     #&00
STY     &65
CLI
		
.L070B
JSR     L79C1
STA     &00,Y
INY
CPY     #&08
BNE     L070B
SEI

\ Restore WRCH vectors
LDA     L3527
STA     L020E
LDA     L3528
STA     L020F

\ Restore EVNT vectors
LDA     L3529
STA     L0220
LDA     L352A
STA     L0221		
CLI

\ Disable output buffer empty event
LDA     #&0D
LDX     #&00
JSR     osbyte

\ Disable ESCAPE pressed event
LDA     #&0D
LDX     #&06
JSR     osbyte

\ Flush all buffers
LDA     #&0F
LDX     #&00
JSR     osbyte

\ Get OS version
LDA     #&00
LDX     #&01
LDY     #&00
JSR     osbyte

CPX     #&01    \ OS1.2?
BNE     L076B

\ Do OS 1.20 things
SEI
LDA     LFFB7
STA     &0A
LDA     LFFB8
STA     &0B
LDY     #&00
		
.L075F
LDA     (&0A),Y
STA     USERV,Y
INY
CPY     LFFB6
BNE     L075F
CLI
		
.L076B
LDA     #&C8
LDX     #&03
LDY     #&00
\ R/W Econet read chr interception status
JSR     osbyte
LDA     #&7C
\ clear ESCAPE condition
JSR     osbyte
SEI
LDY     #&00
		
.decrypt_L077C
LDA     (&00),Y
EOR     (&02),Y
STA     (&02),Y
INY
BNE     decrypt_L077C
INC     &03
LDA     &03
CMP     &05
BNE     decrypt_L077C \ loop
LDA     #&40
STA     S_ULA
LDA     #&01
STA     &5C
STA     &5D
STA     &5E
STA     &5F
CLI
JMP     (&06)

.end
]

NEXT
