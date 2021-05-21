REM BBC BASIC / assembler version of strike.asm
REM Set PAGE to &3000, LOAD, RUN and CALL &7900 to start

IF PAGE<>&3000 P."Set page to &3000 and reload.":END
HIMEM   = &5000
TX_DR   = &FE09
S_ULA   = &FE10
CR6850  = &FE08
osasci  = &FFE3
osnewl  = &FFE7
oswrch  = &FFEE
osbyte  = &FFF4

FOR p=0 TO 3 STEP 3
P%=&7900
[OPT p

.entry
JMP     start_L7932
EQUS    "Searching"+CHR$(13)
EQUS    "Loading"+CHR$(13)
EQUS    "Data?"+CHR$(13)
EQUS    "Block?"+CHR$(13)
EQUS    "Reposition Tape"+CHR$(13)

.start_L7932
JSR     L7A36
JSR     print_Searching

.loop_L7938
LDA     #&55
STA     &5A
JSR     L79D5
JSR     print_Loading
LDY     #&00
JSR     L7A4F
JSR     L7A70 
JSR     L79C1
CMP     &63
BEQ     L799C
JSR     print_Data
JMP     loop_L7938
LDA     #&00
STA     &65 
CLI
INC     &5B
		
.L795E
JSR     L79D5
JSR     L79C1
STA     &5C
JSR     printBlockNo_L79B0
LDA     &5C
CMP     &5B
BEQ     L7975
JSR     print_Block
JMP     L795E

.L7975
JSR     L79C1
STA     &5D
JSR     L79C1
STA     &5E
LDY     #&00
STY     &63
		
.L7983
JSR     L79C1
STA     (&5D),Y
EOR     &63
STA     &63
INY
BNE     L7983
JSR     L79C1
CMP     &63
BEQ     L799C
JSR     print_Data
JMP     L795E

.L799C
SEI
JSR     L79C1
STA     &64
JSR     L79C1
STA     &65
JSR     L79C1
STA     CR6850
JMP     (&64)

.printBlockNo_L79B0
LDA     &5C
AND     #&0F
ORA     #&30
CMP     #&3A
BCC     printBlockNo_L79BD
CLC
ADC     #&07
		
.printBlockNo_L79BD
JSR     oswrch
RTS

.L79C1
LDA     CR6850
AND     #&01
BEQ     L79C1
LDA     CR6850
AND     #&50
BEQ     L79D1
STA     &63

.L79D1
LDA     TX_DR
RTS

.L79D5
LDA     #&0D
JSR     delay_L79ED
JSR     L79C1
CMP     &5A
BNE     L79D5
EOR     #&FF
STA     &64
JSR     L79C1
CMP     &64
BNE     L79D5
RTS

.delay_L79ED
STA     &64

.L79EF
STA     &65

.L79F1
STA     &66

.L79F3
DEC     &66
BNE     L79F3
DEC     &65
BNE     L79F1
DEC     &64
BNE     L79EF      
RTS

.print_Searching
LDX     #&03
JMP     printText

.print_Loading
LDX     #&0D
JMP     printText

.print_Data
JSR     osnewl
LDX     #&15
JSR     printText
JMP     print_RepositionTape

.print_Block
JSR     osnewl
LDX     #&1B
JSR     printText
JMP     print_RepositionTape

.print_RepositionTape
LDA     #&07
JSR     oswrch
LDX     #&22
JMP     printText

.printText
LDA     entry,X
JSR     osasci
INX
CMP     #&0D
BNE     printText
RTS

.L7A36
LDA     #&E8
LDX     #&FD
LDY     #&00
JSR     osbyte
LDA     #&03
STA     CR6850
LDA     #&19
STA     CR6850
LDA     #&85      
STA     S_ULA
RTS

.L7A4F
JSR     L79C1
STA     &5A,Y
INY
CPY     #&06
BNE     L7A4F
PLA
STA     &64
PLA
STA     &60
PHA
LDY     #&00
STY     &5B
STY     &5C
STY     &63
LDA     &64
PHA
JSR     printBlockNo_L79B0
RTS

.L7A70
JSR     L79C1	
PHA
EOR     &63
STA     &63
PLA
EOR     (&5F),Y
STA     (&5D),Y
INY
BNE     L7A70
RTS

EQUB    &72
EQUB    &0CEQUB    &A4EQUB    &82EQUB    &2EEQUB    &87EQUB    &C2EQUB    &60
EQUB    &51EQUB    &56EQUB    &08EQUB    &C6EQUB    &F8EQUB    &5BEQUB    &ACEQUB    &E7
EQUB    &C7EQUB    &6CEQUB    &4CEQUB    &53EQUB    &CCEQUB    &D2EQUB    &DBEQUB    &A7
EQUB    &41EQUB    &37EQUB    &1BEQUB    &06EQUB    &E0EQUB    &29EQUB    &A5EQUB    &EC
EQUB    &9BEQUB    &2BEQUB    &A1EQUB    &43EQUB    &45EQUB    &47EQUB    &CCEQUB    &93
EQUB    &94EQUB    &83EQUB    &8EEQUB    &A2EQUB    &85EQUB    &CFEQUB    &42EQUB    &AE
EQUB    &07EQUB    &EFEQUB    &CFEQUB    &A8EQUB    &C8EQUB    &E6EQUB    &73EQUB    &9A
EQUB    &E3EQUB    &07EQUB    &FAEQUB    &8AEQUB    &96EQUB    &64EQUB    &A7EQUB    &05
EQUB    &69EQUB    &54EQUB    &6BEQUB    &0FEQUB    &44EQUB    &ABEQUB    &89EQUB    &6B
EQUB    &5BEQUB    &75EQUB    &F1EQUB    &18EQUB    &42EQUB    &84EQUB    &35EQUB    &C8
EQUB    &38EQUB    &66EQUB    &49EQUB    &CAEQUB    &CEEQUB    &9CEQUB    &8EEQUB    &7C
EQUB    &DDEQUB    &49EQUB    &8FEQUB    &91EQUB    &D2EQUB    &E3EQUB    &92EQUB    &B1
EQUB    &47EQUB    &EBEQUB    &61EQUB    &A3EQUB    &37EQUB    &22EQUB    &E3EQUB    &44
EQUB    &A5EQUB    &C7EQUB    &F9EQUB    &8EEQUB    &CAEQUB    &0CEQUB    &0DEQUB    &A6
EQUB    &1BEQUB    &DBEQUB    &F7EQUB    &F8EQUB    &8DEQUB    &25EQUB    &FCEQUB    &2F
EQUB    &4BEQUB    &FCEQUB    &ABEQUB    &CDEQUB    &35EQUB    &16EQUB    &1C

.end
]
NEXT
