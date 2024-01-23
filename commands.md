##00/01 dec R/IR
- 6 cycles
- dstRegister = instr[0] == 0
    - ? second
    - : registers[second]
-
    - aluA = registers[register]
    - aluMode = DEC
    - writeRegister = 1
    - writeFlags = 1

##10/11 rlc R/IR
- 6 cycles
- dstRegister = instr[0] == 0
    - ? second
    - : registers[second]
-
    - aluA = registers[register]
    - aluMode = RLC
    - writeRegister = 1
    - writeFlags = 1

##20/21 inc R/IR
- 6 cycles
- dstRegister = instr[0] == 0
    - ? second
    - : registers[second]
-
    - aluA = registers[register]
    - aluMode = INC
    - writeRegister = 1
    - writeFlags = 1

##30 jp IRR
- 8 cycles
-
    - PcH = registers[second]
    - second = second | 1
-
    - PcL = registers[second]

##31 srp IM
- 6 cycles
-
    - aluA = second
    - aluMode = LD
    - dstRegister = #FD
    - writeRegister = 1
    - writeFlags = 1

##40/41 da R/IR
- 8 cycles
- dstRegister = instr[0] == 0
    - ? second
    - : registers[second]
-
    - aluA = registers[register]
    - aluMode = DA
    - writeRegister = 1
    - writeFlags = 1

##50/51 pop R/IR
- 10 cycles
- 
    - dstRegister = instr[0] == 0
        - ? second
        - : registers[second]
    - address = SP
- 
    - aluA = memory[address]
    - aluMode = LD
    - writeRegister = 1
    - SP = SP + 1

##60/61 com R/IR
- 6 cycles
- dstRegister = instr[0] == 0
    - ? second
    - : registers[second]
-
    - aluA = registers[register]
    - aluMode = COM
    - writeRegister = 1
    - writeFlags = 1

##70/71 push R/IR
- 10 cycles (intern), 12 cycles (extern)
- 
    - dstRegister = instr[0] == 0
        - ? second
        - : registers[second]
    - address = SP - 1
    - SP = SP - 1
- aluA = registers[dstRegister]
- 
    - memory[address] = alu

##80(10) decw R/IR
- 10 cycles
- dstRegister = instr[0] == 0
    - ? second
    - : registers[second]
-
    - aluA = registers[register]
    - register = register | 1
-
    - aluB = registers[register]
    - aluMode = INC
    - writeRegister = 1
    - writeFlags = 0
