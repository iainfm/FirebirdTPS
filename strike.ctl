# Control file for Beebdis.exe to disassemble the BirdSk2 binary
# Data regions originally found using https://www.white-flame.com/wfdis/
# There's probably an easier way to do it though...

# Change this line to reflect the name of your original binary
# Leave the load address as $1200
load $7900 $.STRIKE

# Where the code executes at
entry $7900

# Data areas to ignore
string $7903 47
byte   $7a81 119

# What to save the output as
save strike.asm

# Probably unnecessary, but to save ambiguity
cpu 6502
