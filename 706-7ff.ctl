# Control file for Beebdis.exe to disassemble the BirdSk2 binary
# Data regions originally found using https://www.white-flame.com/wfdis/
# There's probably an easier way to do it though...

# Change this line to reflect the name of your original binary
# Leave the load address as $1200
load $706 706-7ff.bin

# Where the code executes at
entry $706

# Data areas to ignore
byte $7a0 1888

# What to save the output as
save 706-709.asm

# Probably unnecessary, but to save ambiguity
cpu 6502
