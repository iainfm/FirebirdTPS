
# Firebird Tape Protection System
Firebird Tape Protection System disassembly and analysis

An investigation into how the tape copy protection system worked for Firebird BBC Micro games (specifically Bird Strike by Andrew Frigaard).

Background
----------
The game was supplied by the author to the publisher (Firebird) who added loading music and a tape protection system. The primary purpose of the protection was to prevent the game from being transferred to floppy disc for fast copying and illegal distribution.

The encryption was originally defeated by 'Mr Spock' as documented here http://www.acornelectron.co.uk/eug/71/h-bird.html (side note: I wish I'd found this before starting the analysis!).

Also of interest is a fault with the decryption routine or key that fails to decrypt the very last byte of the game correctly. This manifests itself as a pair of additional pixels in the wave 4 enemy aircraft sprite that are not present in the author's source or in the Electron version.

Analysis
--------

Caveat: My 6052 knowledge is not great, nor is my expertise in the internal workings of the BBC Micro, so this analysis is incomplete. However...

On the tape version of Bird Strike a simple loader ("BIRDSTRIKE") changes PAGE to &3000 and chains "BIRD". BIRD contains the loading screen in BBC Basic, plus some assembly above it that is called to start the interrupt-driven music playing. The EVNT and WRCH vector addresses are stored in memory page &35 and changed for the music player routine.

The "BIRD" program then runs the next program on tape - a binary called "STRIKE".

STRIKE is responsible for things:
1) Loading a decryption table from the first block (&00) of the tape to address &600-&6FF. Uses code as data, and the data at the end of STRIKE (&79FE-&7AFD), to decrypt the decryption key.
2) Loading the encrypted game code into memory between &1400 and $2FFF. An EOR routine pre-decrypts the data using the last block as the EOR value.
3) Loading and decrypting a decrypter routine from the last block of the encrypted tape data (Block &1D) to address &706 to & &7B0 (&79D to &7B0 unused) using the EOR <last value> method.
  
Once this is complete STRIKE calls the decrypter routine at &706.

The decrypter routine at &706 then:
Loads memory addresses &00-&07 with values from tape using the subroutine at &79C1. These are:

```
&00/&01 -> ZPG address of decryption table (&00)
&02/&03 -> ZPG address of start of memory to decrypt (&1400)
&04/&05 -> ZPG address of end of memory to decrypt (&3000) (only top byte used)
&06/&07 -> ZPG address of memory to jump to to begin the decrypted game code
```

The decryption routine is a simple EOR loop. The contents of page &6 is used repeatedy to decrypt memory &1400-&2FFF inclusive.

Once decryption is complete the EVNT and WRCH vectors are restored, some other housekeeping is done and execution is passed to the decrypted game at &1E00 via (&06).

Summary
-------
It's complicated. More complicated than I can (as yet) fully understand.
The error in decrypting the final byte of the game (&2FFF) appears to come from the last byte of the decryption table being wrong. It is decrypted as &3A because the last byte of the decryption table is &00. (A EOR 0) = A. The last byte of the decryption table should have been &3A. (&3A EOR &3A) = 0.

The decryption table appears to have been a random page of memory. Why the last byte doesn not match the encryption key remains a mystery at present.

Files
-----
```
$.STRIKE      STRIKE file from Bird Strike tape
$.STRIKE.INF  Metadata for importing into emulator

strike.ctl    Beebdis control file for disassembling $.STRIKE
strike.asm    Dissassembled and (partly) annotated source for $.STRIKE

706-7ff.bin   The binary that is decrypted from block &1D of the encrypted tape to &706-&7B0
706-7ff.ctl   Beebdis control file for disassembling 706-7ff.bin
706-7ff.asm   Disassembly and (partly) annotated source for 706-7ff.bin

dectable.bin  Decryption table that gets loaded at &600-&6FF
dectable.txt  Text version of the decryption table
```
Thanks
------

To Chris (https://github.com/scarybeasts/) for Beebjit (https://github.com/scarybeasts/beebjit) and implementing .csw files in his emulator just to test the Bird Strike loaded. ``-fasttape`` is a life saver!
  
Phill for Beebdis - a great 6502 disassembler! https://github.com/prime6809/BeebDis

The White Flame developers of https://www.white-flame.com/wfdis/ - a great interactive browser-based disassembler.
