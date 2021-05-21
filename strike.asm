ZP_5A   = $005A
ZP_5B   = $005B
ZP_5C   = $005C
ZP_5D   = $005D
ZP_5E   = $005E
ZP_5F   = $005F
ZP_60   = $0060
ZP_63   = $0063
ZP_64   = $0064
ZP_65   = $0065
ZP_66   = $0066
CR6850  = $FE08    \ 6850 control register (write only?)
TX_DR   = $FE09    \ transmit data register (write only)
S_ULA   = $FE10    \ Serial ULA
osasci  = $FFE3
osnewl  = $FFE7
oswrch  = $FFEE
osbyte  = $FFF4

        org     $7900
.entry
        JMP     start_L7932
        EQUS    "Searching",$0D,"Loading",$0D,"Data?",$0D,"Block?",$0D,"Reposition Tape",$0D

.start_L7932
        JSR     L7A36     \ Setup 6850 and Serial ULA
        JSR     print_Searching

.loop_L7938
        LDA     #$55       \ A = &55 
        STA     ZP_5A      \ ?&5A = &55
        JSR     L79D5
        JSR     print_Loading
        LDY     #$00       \ Y = 0
        JSR     L7A4F
        JSR     L7A70 
        JSR     L79C1
        CMP     ZP_63
        BEQ     L799C      \ goto L799C if A = ?&63 (good read)
        JSR     print_Data \ bad read
        JMP     loop_L7938
        LDA     #$00       \ A = 0
        STA     ZP_65      \ ?&65 = 0
        CLI                \ Clear interrupt disable flag
        INC     ZP_5B      \ ?&5B = ?&5B + 1
		
.L795E
        JSR     L79D5
        JSR     L79C1
        STA     ZP_5C       \ ?&5C = A
        JSR     printBlockNo_L79B0
        LDA     ZP_5C       \ A = ?&5C
        CMP     ZP_5B
        BEQ     L7975       \ A = ?&5B? block ok
        JSR     print_Block \ Bad block?
        JMP     L795E       \ loop back around

.L7975
        JSR     L79C1
        STA     ZP_5D     \ ?&5D = A
        JSR     L79C1
        STA     ZP_5E     \ ?&5E = A
        LDY     #$00
        STY     ZP_63     \ ?&63 = 0
		
.L7983
        \ Loads encrypted data to &1400-&2FFF
		\ Also loads decryption routine to &706 from block $1D
		\ Re-encrypts(?) data as it goes with EOR ?&63=last value written
		
        JSR     L79C1      \ get byte from tape?
        STA     (ZP_5D),Y  \ ?(&5D+Y) = A    \ Write encrypted byte
        EOR     ZP_63      \ A = A EOR ?&63
        STA     ZP_63      \ ?&63 = A
        INY                \ Y = Y + 1
        BNE     L7983
        JSR     L79C1
        CMP     ZP_63      \ A = ?&63?
        BEQ     L799C      \ Good read
        JSR     print_Data \ Bad read
        JMP     L795E      \ Loop back

.L799C
        SEI               \ Set interrupt disable
        JSR     L79C1
        STA     ZP_64     \ ?&64 = A
        JSR     L79C1
        STA     ZP_65     \ ?&65 = A
        JSR     L79C1
        STA     CR6850    \ Write 6850 control register
        JMP     (ZP_64)   \ jump to offset ?&64 - &7957 according to debugger (may change)

.printBlockNo_L79B0       \ Print current block number
        LDA     ZP_5C     \ A = ?&5C
        AND     #$0F      \ A = A AND 15
        ORA     #$30      \ A = A OR  48
        CMP     #$3A      \ A < &3A
        BCC     printBlockNo_L79BD
        CLC               \ CLC
        ADC     #$07      \ A = A + 7
		
.printBlockNo_L79BD
        JSR     oswrch
        RTS

.L79C1  \ Wait for / read tape data / 6850 status? - previous value returned in X when X=0/Y=&FF
        \ also used by $600 routine to set $00-$07 to the memory addresses in play
        LDA     CR6850    \ A = ?&FE08
        AND     #$01      \ A is odd?
        BEQ     L79C1
        LDA     CR6850    \ A = ?&FE08
        AND     #$50      \ A % 1010000?
        BEQ     L79D1
        STA     ZP_63     \ ?&63 = A
.L79D1
        LDA     TX_DR     \ A = write transmit data register
        RTS

.L79D5
        LDA     #$0D      \ A = 13
        JSR     delay_L79ED
        JSR     L79C1
        CMP     ZP_5A     \ A = ?&5A?
        BNE     L79D5     \ loop
        EOR     #$FF      \ A = A EOR 255
        STA     ZP_64     \ ?&64 = A
        JSR     L79C1
        CMP     ZP_64     \ A = ?&64?
        BNE     L79D5     \ loop
        RTS

.delay_L79ED              \ 13^3 delay loop
        STA     ZP_64     \ ?&64 = A (&0D on first run)
.L79EF
        STA     ZP_65     \ ?&65 = A
.L79F1
        STA     ZP_66     \ ?&66 = A
.L79F3
        DEC     ZP_66     \ ?&66 = ?&66 - 1
        BNE     L79F3     \ loop until ?&66 = 0
        DEC     ZP_65     \ ?&65 = ?&65 - 1
        BNE     L79F1
        DEC     ZP_64     \ ?&64 = ?&64 - 1
        BNE     L79EF      
        RTS               \ &79FF

\ Code must match from (here-2) for the decryption of block 0 to work.

.print_Searching                      \ Display 'Searching'
        LDX     #$03
        JMP     printText

.print_Loading                        \ Display 'Loading'
        LDX     #$0D
        JMP     printText

.print_Data                           \ Display 'Data?'
        JSR     osnewl
        LDX     #$15
        JSR     printText
        JMP     print_RepositionTape

.print_Block                          \ Display 'Block'
        JSR     osnewl
        LDX     #$1B
        JSR     printText
        JMP     print_RepositionTape

.print_RepositionTape                 \ Beep and display 'Reposition Tape'
        LDA     #$07
        JSR     oswrch
        LDX     #$22
        JMP     printText

.printText  \ Print text subroutine
        LDA     entry,X
        JSR     osasci
        INX
        CMP     #$0D
        BNE     printText
        RTS

.L7A36  \ Set up the 6850 and serial ULA
        LDA     #$E8
        LDX     #$FD
        LDY     #$00
        JSR     osbyte    \ R/W IRQ mask for 6850
        LDA     #$03
        STA     CR6850    \ Write 6850 control register
        LDA     #$19
        STA     CR6850    \ Write 6850 control register
        LDA     #$85      
        STA     S_ULA     \ Write Serial ULA
        RTS

.L7A4F
        JSR     L79C1
        STA     ZP_5A,Y   \ ?(&5A+Y) = A
        INY               \ Y = Y + 1
        CPY     #$06      \ Y = 6?
        BNE     L7A4F
        PLA
        STA     ZP_64     \ ?&64 = A
        PLA
        STA     ZP_60     \ ?&60 = A
        PHA
        LDY     #$00      \ Y = 0
        STY     ZP_5B     \ ?&5B = 0
        STY     ZP_5C     \ ?&5C = 0
        STY     ZP_63     \ ?&63 = 0
        LDA     ZP_64     \ ?&64 = 0
        PHA
        JSR     printBlockNo_L79B0
        RTS

.L7A70  \ Writes main decryption key to $600 from block 0?
        \ ($5F+Y) contains current decryption byte to decrypt this?
		\ Uses &79FE+Y (&79FE-&7AFD) to decrypt the decryption key.

        JSR     L79C1	
        PHA
        EOR     ZP_63     \ A = A EOR ?&63
        STA     ZP_63     \ ?&63 = A
        PLA
        EOR     (ZP_5F),Y \ ?(&5F+Y) = ?(&5F+Y) EOR A ?
        STA     (ZP_5D),Y \ ?(&5D+Y) = A
        INY
        BNE     L7A70
        RTS

		\ &7A81 additional decryption key for main game load (?)
        EQUB    $72,$0C,$A4,$82,$2E,$87,$C2,$60
        EQUB    $51,$56,$08,$C6,$F8,$5B,$AC,$E7
        EQUB    $C7,$6C,$4C,$53,$CC,$D2,$DB,$A7
        EQUB    $41,$37,$1B,$06,$E0,$29,$A5,$EC
        EQUB    $9B,$2B,$A1,$43,$45,$47,$CC,$93
        EQUB    $94,$83,$8E,$A2,$85,$CF,$42,$AE
        EQUB    $07,$EF,$CF,$A8,$C8,$E6,$73,$9A
        EQUB    $E3,$07,$FA,$8A,$96,$64,$A7,$05
        EQUB    $69,$54,$6B,$0F,$44,$AB,$89,$6B
        EQUB    $5B,$75,$F1,$18,$42,$84,$35,$C8
        EQUB    $38,$66,$49,$CA,$CE,$9C,$8E,$7C
        EQUB    $DD,$49,$8F,$91,$D2,$E3,$92,$B1
        EQUB    $47,$EB,$61,$A3,$37,$22,$E3,$44
        EQUB    $A5,$C7,$F9,$8E,$CA,$0C,$0D,$A6
        EQUB    $1B,$DB,$F7,$F8,$8D,$25,$FC,$2F
        EQUB    $4B,$FC,$AB,$CD,$35,$16,$1C
		\ next byte &7B00

.end
SAVE "strike.bin",entry,end

