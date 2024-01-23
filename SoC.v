`default_nettype none

module Memory #(
    parameter addrBusWidth = 8
) (
    input                      clk,
    input [addrBusWidth - 1:0] addr,
    input                [7:0] dataIn,
    output            reg[7:0] dataOut,
    input                      write,
    input                      strobe
);
    localparam size = 1 << addrBusWidth;
    reg [7:0] memory[0 : size - 1];
`ifdef BENCH
    integer i;
    initial begin
        for (i = 0; i < size; i = i + 1) begin
            memory[i] = 8'h0;
        end
    end
`endif

`include "assembly.vh"
`include "program.vh"
`include "sfr.vh"

    always @(posedge clk) begin
        if (strobe) begin
            if (write) begin
                memory[addr] <= dataIn;
                dataOut <= dataIn;
            end
            else begin
                dataOut <= memory[addr];
            end
        end
    end
endmodule

`include "Alu.v"

module Processor(
    input         clk,
    input         reset,
    output [15:0] memAddr,
    input  [7:0]  memDataRead,
    output [7:0]  memDataWrite,
    output        memWrite,
    output        memStrobe
);
    `include "flags.vh"

    reg [15:0] pc, sp, addr;
    initial begin
        pc = 'hC;
        sp = 0;
    end

    reg  [7:0] instruction;
    wire [3:0] instrH = instruction[7:4];
    wire [3:0] instrL = instruction[3:0];
    wire isJumpRel = instrL == 4'hB;
    wire isJumpDA = instrL == 4'hD;
    wire isInstrSize1 = (instrL[3:1] == 3'b111);
    wire isInstrSize3 = (instrL[3:2] == 2'b01)
                      | isJumpDA;
    wire isInstrSize2 = ~isInstrSize1 & ~isInstrSize3;

    reg  [7:0] second;
    wire [3:0] secondH = second[7:4];
    wire [3:0] secondL = second[3:0];

    reg  [7:0] third;
    wire [3:0] thirdH = third[7:4];
    wire [3:0] thirdL = third[3:0];
    wire [15:0] directAddress = {second, third};

    reg [3:0] rp = 0;
    reg [7:0] registers[0:'h7F];
    reg [7:0] p01m = 8'b01_0_01_1_01;
    //                  || | || | ++ P00-P03 Mode: 00 output, 01 input, 1x address A8-A11
    //                  || | || +--- Stack: 0 external,  1 internal
    //                  || | ++----- P1 Mode: 00 Output, 01 Input, 10 AD0-AD7, 11 tristate
    //                  || +-------- Memory timing: 0 normal, 1 extended
    //                  ++---------- P04-P07 Mode: 00 output, 01 input, 1x A12-A15 
    wire stackInternal = p01m[2];

    reg [7:0] register;
    reg writeRegister = 0;

    `include "sfr.vh"
    `include "alu.vh"
    reg  [7:0] aluA = 0;
    reg  [7:0] aluB = 0;
    reg  [4:0] aluMode;
    wire [7:0] aluOut;
    reg  [7:0] flags = 0;
    wire [7:0] flagsOut;
    reg writeFlags = 0;
    Alu alu(
        .mode(aluMode),
        .a(aluA),
        .b(aluB),
        .flags(flags),
        .out(aluOut),
        .outFlags(flagsOut)
    );

    function [7:0] r4(
        input [3:0] r
    );
        r4 = { rp, r };
    endfunction

    function [7:0] r8(
        input [7:0] r
    );
        if (r[7:4] == 4'hE)
            r8 = r4(r[3:0]);
        else
            r8 = r;
    endfunction

    function [7:0] readRegister8(
        input [7:0] r
    );
        casez (r)
        8'b0???_????: readRegister8 = registers[r[6:0]];
        P01M:         readRegister8 = p01m;
        FLAGS:        readRegister8 = flags;
        RP:           readRegister8 = { rp, 4'h0 };
        SPH:          readRegister8 = sp[15:8];
        SPL:          readRegister8 = sp[7:0];
        default:      readRegister8 = 0;
        endcase
    endfunction

    function [7:0] readRegister4(
        input [3:0] r
    );
        readRegister4 = readRegister8(r4(r));
    endfunction

    function [1:4*8] alu1OpName( // maximum of 4 characters
        input [3:0] instrH
    );
    begin
        case (instrH)
        ALU1_DEC : alu1OpName = "dec";
        ALU1_RLC : alu1OpName = "rlc";
        ALU1_INC : alu1OpName = "inc";
        ALU1_DA  : alu1OpName = "da";
        ALU1_COM : alu1OpName = "com";
        ALU1_DECW: alu1OpName = "decw";
        ALU1_RL  : alu1OpName = "rl";
        ALU1_INCW: alu1OpName = "incw";
        ALU1_CLR : alu1OpName = "clr";
        ALU1_RRC : alu1OpName = "rrc";
        ALU1_SRA : alu1OpName = "sra";
        ALU1_RR  : alu1OpName = "rr";
        ALU1_SWAP: alu1OpName = "swap";
        default  : alu1OpName = "?";
        endcase;
    end
    endfunction

    function [4:0] alu1OpCode(
        input[3:0] instrH
    );
        alu1OpCode = { 1'b0, instrH };
    endfunction

    function [4:0] alu2OpCode(
        input[3:0] instrH
    );
        alu2OpCode = { 1'b1, instrH };
    endfunction

    function [1:3*8] alu2OpName( // maximum of 3 characters
        input [3:0] instrH
    );
    begin
        case (alu2OpCode(instrH))
        ALU2_ADD: alu2OpName = "add";
        ALU2_ADC: alu2OpName = "adc";
        ALU2_SUB: alu2OpName = "sub";
        ALU2_SBC: alu2OpName = "sbc";
        ALU2_OR : alu2OpName = "or";
        ALU2_AND: alu2OpName = "and";
        ALU2_TCM: alu2OpName = "tcm";
        ALU2_TM : alu2OpName = "tm";
        ALU2_CP : alu2OpName = "cp";
        ALU2_XOR: alu2OpName = "xor";
        default : alu2OpName = "?";
        endcase
    end
    endfunction

    reg takeBranchTmp;
    always @(*) begin
        case (instrH[2:0])
        0: takeBranchTmp = 0;
        1: takeBranchTmp =  flags[FLAG_INDEX_S] ^ flags[FLAG_INDEX_V];
        2: takeBranchTmp = (flags[FLAG_INDEX_S] ^ flags[FLAG_INDEX_V]) | flags[FLAG_INDEX_Z];
        3: takeBranchTmp =  flags[FLAG_INDEX_C] | flags[FLAG_INDEX_Z];
        4: takeBranchTmp =  flags[FLAG_INDEX_V];
        5: takeBranchTmp =  flags[FLAG_INDEX_S];
        6: takeBranchTmp =  flags[FLAG_INDEX_Z];
        7: takeBranchTmp =  flags[FLAG_INDEX_C];
        endcase
    end
    wire takeBranch = takeBranchTmp ^ instrH[3];

    function [1:3*8] ccName( // maximum of 3 characters
        input [3:0] instrH
    );
    begin
        case (instrH)
        0: ccName = "f";
        1: ccName = "lt";
        2: ccName = "le";
        3: ccName = "ule";
        4: ccName = "ov";
        5: ccName = "mi";
        6: ccName = "z";
        7: ccName = "c";
        8: ccName = "";
        9: ccName = "ge";
        10: ccName = "gt";
        11: ccName = "ugt";
        12: ccName = "nov";
        13: ccName = "pl";
        14: ccName = "nz";
        15: ccName = "nc";
        endcase
    end
    endfunction

    `include "states.vh"
    reg [STATES_MAX_BIT:0] state = STATE_FETCH_INSTR;

    wire [15:0] nextRelativePc = pc + { {8{second[7]}}, second };
    wire [15:0] nextPc = ( state == STATE_READ_INSTR
                         | state == STATE_READ_2
                         | state == STATE_READ_3)
                         ? pc + 1
                         : ((state == STATE_DECODE & isJumpDA & takeBranch)
                           |(state == STATE_CALL_I3)
                           |(state == STATE_CALL_E3))
                            ? directAddress
                            : ( (state == STATE_DECODE & isJumpRel & takeBranch)
                              || (state == STATE_DJNZ2 && flagsOut[FLAG_INDEX_Z] == 1'b0 )
                              ) 
                                ? nextRelativePc
                                : (state == STATE_RET_I3
                                  |state == STATE_RET_E6)
                                  ? addr
                                  : pc;
    assign memAddr = (state == STATE_PUSH_E3)
                   | (state == STATE_POP_E2)
                   | (state == STATE_POP_E3)
                   | (state == STATE_CALL_E2)
                   | (state == STATE_CALL_E3)
                   | (state == STATE_IRET_E2)
                   | (state == STATE_RET_E2)
                   | (state == STATE_RET_E3)
                   | (state == STATE_RET_E4)
                   | (state == STATE_RET_E5)
                   | (state == STATE_READ_MEM1)
                   | (state == STATE_READ_MEM2)
                   | (state == STATE_WRITE_MEM)
                     ? addr : pc;
    assign memDataWrite = aluA;
    assign memWrite = (state == STATE_PUSH_E3)
                    | (state == STATE_CALL_E2)
                    | (state == STATE_CALL_E3)
                    | (state == STATE_WRITE_MEM);
    assign memStrobe = (state == STATE_FETCH_INSTR)
                     | (state == STATE_WAIT_2 & ~isInstrSize1)
                     | (state == STATE_WAIT_3)
                     | (state == STATE_POP_E2)
                     | (state == STATE_IRET_E2)
                     | (state == STATE_RET_E2)
                     | (state == STATE_RET_E4)
                     | (state == STATE_READ_MEM1)
                     | memWrite;

    always @(posedge clk) begin
        if (writeFlags) begin
            $display("    alu:    %h       %h    =>    %h", aluA, aluB, aluOut);
            $display("         %b %b => %b", aluA, aluB, aluOut);
            $display("    flags = %b_%b", flagsOut[7:4], flagsOut[3:0]);
            flags <= flagsOut;
        end
        writeFlags <= 0;

        if (writeRegister) begin
            $display("    reg[%h] = %h", register, aluOut);
            casez (register)
            8'b0???_????: registers[register] <= aluOut;
            P01M:         p01m                <= aluOut;
            FLAGS:        flags               <= aluOut;
            RP:           rp                  <= aluOut[7:4];
            SPH:          sp[15:8]            <= aluOut;
            SPL:          sp[7:0]             <= aluOut;
            endcase
        end
        writeRegister <= 0;

        state <= state + 1;

        case (state)
        STATE_FETCH_INSTR: begin
            $display("\n%h: read instruction", pc);
            aluA <= 0;
            aluB <= 0;
            aluMode <= 0;
            register <= 0;
            instruction <= 0;
            second <= 0;
            third <= 0;
        end

        STATE_READ_INSTR: begin
            instruction <= memDataRead;
        end

        STATE_WAIT_2: begin
            $display("  %h", instruction);
            if (isInstrSize1) begin
                state <= STATE_DECODE;
            end
        end

        STATE_READ_2: begin
            $display("%h: read 2nd byte", pc);
            second <= memDataRead;
            if (isInstrSize2) begin
                state <= STATE_DECODE;
            end
        end

        STATE_WAIT_3: begin
            $display("  %h %h", instruction, second);
        end

        STATE_READ_3: begin
            $display("%h: read 3rd byte", pc);
            third <= memDataRead;
        end

        STATE_DECODE: begin
            if (isInstrSize2) begin
                $display("  %h %h", instruction, second);
            end else if (isInstrSize3) begin
                $display("  %h %h %h", instruction, second, third);
            end

            state <= STATE_FETCH_INSTR;

            case (instrL)
            4'h0: begin
                case (instrH)
                4'h3: begin
                    $display("    jp IRR%h", second);
                    //TODO
                end
                4'h5: begin
                    $display("    pop %h", second);
                    // 10+5 cycles
                    // dst <- @SP
                    // SP <- SP + 1
                    register <= r8(second);
                    state <= stackInternal ? STATE_POP_I : STATE_POP_E1;
                end
                4'h7: begin
                    $display("    push %h", second);
                    // 10/12+1 cycles
                    register <= r8(second);
                    state <= stackInternal ? STATE_PUSH_I1 : STATE_PUSH_E1;
                end
                4'h8: begin
                    $display("    decw %h", second);
                    aluMode <= ALU1_DEC;
                    writeRegister <= 1;
                    register <= r8({second[7:1], 1'h1});
                    aluA <= readRegister8({second[7:1], 1'h1});
                    state <= STATE_ALU1_WORD;
                end
                4'hA: begin
                    $display("    incw %h", second);
                    aluMode <= ALU1_INC;
                    writeRegister <= 1;
                    register <= r8({second[7:1], 1'h1});
                    aluA <= readRegister8({second[7:1], 1'h1});
                    state <= STATE_ALU1_WORD;
                end
                default: begin
                    $display("   %s %h", 
                             alu1OpName(instrH), second);
                    aluMode <= alu1OpCode(instrH);
                    register <= r8(second);
                    state <= STATE_ALU1_OP;
                end
                endcase
            end
            4'h1: begin
                case (instrH)
                4'h3: begin
                    $display("    srp %h", second);
                    rp <= second[7:4];
                end
                4'h5: begin
                    $display("    pop @%h", second);
                    // 10+5 cycles
                    register <= readRegister8(second);
                    state <= stackInternal ? STATE_POP_I : STATE_POP_E1;
                end
                4'h7: begin
                    $display("    push @%h", second);
                    // 12/14+1 cycles
                    register <= readRegister8(second);
                    state <= stackInternal ? STATE_PUSH_I1 : STATE_PUSH_E1;
                end
                4'h8: begin
                    $display("    decw @%h", second);
                    //TODO
                end
                4'hA: begin
                    $display("    incw @%h", second);
                    //TODO
                end
                default: begin
                    $display("   %s @%h", 
                             alu1OpName(instrH), second);
                    aluMode <= alu1OpCode(instrH);
                    register <= readRegister8(r8(second));
                    state <= STATE_ALU1_OP;
                end
                endcase
            end
            4'h2: begin
                casez (instrH)
                4'h8: begin
                    $display("    lde r%h, Irr%h",
                             secondH, secondL);
                    //TODO
                end
                4'h9: begin
                    $display("    lde Irr%h, r%h",
                             secondL, secondH);
                    //TODO
                end
                4'hC: begin
                    $display("    ldc r%h, Irr%h",
                             secondH, secondL);
                    register <= r4(secondH);
                    state <= STATE_LDC_READ1;
                end
                4'hD: begin
                    $display("    ldc Irr%h, r%h",
                             secondL, secondH);
                    register <= r4(secondH);
                    state <= STATE_LDC_WRITE1;
                end
                4'b111x: begin
                    $display("    ? %h", second);
                end
                default: begin
                    $display("    %s r%h, r%h",
                             alu2OpName(instrH),
                             secondH, secondL);
                    register <= r4(secondH);
                    aluA <= readRegister4(secondH);
                    //TODO
                    aluB <= readRegister4(secondL);
                    state <= STATE_ALU2_OP;
                end
                endcase
            end
            4'h3: begin
                casez (instrH)
                4'h8: begin
                    $display("    ldei r%h, Irr%h",
                             secondH, secondL);
                    //TODO
                end
                4'h9: begin
                    $display("    ldei Irr%h, r%h",
                             secondL, secondH);
                    //TODO
                end
                4'hC: begin
                    $display("    ldci Ir%h, Irr%h",
                             secondH, secondL);
                    register <= readRegister4(secondH);
                    state <= STATE_LDC_READ1;
                end
                4'hD: begin
                    $display("    ldci Irr%h, Ir%h",
                             secondL, secondH);
                    register <= readRegister4(secondH);
                    state <= STATE_LDC_WRITE1;
                end
                4'hE: begin
                    $display("    ld r%h, Ir%h",
                             secondL, secondH);
                    //TODO
                end
                4'hF: begin
                    $display("    ld Ir%h, r%h",
                             secondL, secondH);
                    //TODO
                end
                default: begin
                    $display("    %s r%h, Ir%h",
                             alu2OpName(instrH),
                             secondH, secondL);
                    aluA <= readRegister4(secondH);
                    register <= readRegister4(secondL);
                    state <= STATE_ALU2_IR;
                end
                endcase
            end
            4'h4: begin
                case (instrH)
                4'b100x,
                4'b1100,
                4'b1111: begin
                    $display("    ? %h", instruction);
                end
                4'hD: begin
                    $display("    call IRR%h", directAddress);
                    // 20 cycles
                    //TODO
                end
                4'hE: begin
                    $display("    ld %h, %h", third, second);
                    register <= r8(third);
                    aluA <= readRegister8(r8(second));
                    aluMode <= ALU1_LD;
                    writeRegister <= 1;
                end
                default: begin
                    $display("    %s %h, %h",
                             alu2OpName(instrH),
                             third, second);
                    register <= r8(third);
                    aluA <= readRegister8(r8(third));
                    //TODO
                    aluB <= readRegister8(r8(second));
                    state <= STATE_ALU2_OP;
                end
                endcase
            end
            4'h6: begin
                case (instrH)
                4'b100x,
                4'b1100,
                4'b1111: begin
                    $display("    ? %h", instruction);
                end
                4'hD: begin
                    $display("    call %h", directAddress);
                    // 20 cycles
                    // push PCL, PCH
                    sp <= sp - 1;
                    state <= stackInternal ? STATE_CALL_I1 : STATE_CALL_E1;
                end
                4'hE: begin
                    $display("    ld %h, #%h", second, third);
                    register <= r8(second);
                    aluA <= third;
                    aluMode <= ALU1_LD;
                    writeRegister <= 1;
                end
                default: begin
                    $display("    %s %h, #%h",
                             alu2OpName(instrH),
                             second, third);
                    register <= r8(second);
                    aluA <= readRegister8(r8(second));
                    aluB <= third;
                    state <= STATE_ALU2_OP;
                end
                endcase
            end
            4'h8: begin
                $display("    ld r%h, %h", instrH, secondL);
                register <= r4(instrH);
                aluB <= readRegister8(r8(second));
                aluMode <= ALU1_LD;
                writeRegister <= 1;
            end
            4'h9: begin
                $display("    ld %h, r%h", secondL, instrH);
                //TODO
            end
            4'hA: begin
                $display("    djnz r%h, %h", instrH, second);
                register <= r4(instrH);
                state <= STATE_DJNZ1;
            end
            4'hB: begin
                $display("    jr %s, %h", ccName(instrH), second);
            end
            4'hC: begin
                $display("    ld r%h, #%h", instrH, second);
                register <= r4(instrH);
                aluA <= second;
                aluMode <= ALU1_LD;
                writeRegister <= 1;
            end
            4'hD: begin
                $display("    jmp %s, %h", ccName(instrH), directAddress);
            end
            4'hE: begin
                $display("    inc r%h", instrH);
                register <= r4(instrH);
                aluMode <= ALU1_INC;
                state <= STATE_ALU1_OP;
            end
            4'hF: begin
                casez (instrH)
                4'h8: begin
                    $display("    di");
                    //TODO
                end
                4'h9: begin
                    $display("    ei");
                    //TODO
                end
                4'hA: begin
                    $display("    ret");
                    // 14 cycles
                    // PCH, PCL
                    state <= stackInternal ? STATE_RET_I1 : STATE_RET_E1;
                end
                4'hB: begin
                    $display("    iret");
                    // 16 cycles
                    // flags, PCH, PCL
                    state <= stackInternal ? STATE_IRET_I : STATE_IRET_E1;
                end
                4'b110?: begin
                    $display("    %scf", instrH[0] ? "s" : "r");
                    flags[FLAG_INDEX_C] <= instrH[0];
                end
                4'hE: begin
                    $display("    ccf");
                    flags[FLAG_INDEX_C] <= ~flags[FLAG_INDEX_C];
                end
                4'hF: begin
                    $display("    nop");
                end
                default: begin
                    $display("    ?");
                end
                endcase
            end
            default: begin
            end
            endcase
        end

        STATE_ALU1_WORD: begin
            register <= { register[7:1], 1'b0 };
            aluA <= readRegister8({register[7:1], 1'b0});
            aluB <= aluOut;
            aluMode <= aluMode | 'h8; // inc/dec -> incw/decw
            writeRegister <= 1;
            writeFlags <= 1;
            state <= STATE_FETCH_INSTR;
        end

        STATE_ALU1_OP: begin
            aluA <= readRegister8(register);
            writeRegister <= 1;
            writeFlags <= 1;

            if (aluMode == ALU1_DA) begin
                state <= STATE_ALU1_DA;
            end
            else begin
                state <= STATE_FETCH_INSTR;
            end
        end

        STATE_ALU1_DA: begin
            aluA <= aluOut;
            aluMode <= ALU1_DA_H;
            writeRegister <= 1;
            writeFlags <= 1;
            state <= STATE_FETCH_INSTR;
        end

        STATE_ALU2_IR: begin
            aluB <= readRegister8(register);
            register <= r4(secondH);
        end

        STATE_ALU2_OP: begin
            aluMode <= alu2OpCode(instrH);
            writeRegister <= (instrH[3:2] == 2'b00)     // add, adc, sub, sbc
                            | (instrH[3:1] == 3'b010)   // or, and
                            | (instrH      == 4'b1011); // xor
            writeFlags <= 1;
            state <= STATE_FETCH_INSTR;
        end

        STATE_PUSH_I1: begin
            sp <= sp - 1;
        end
        STATE_PUSH_I2: begin
            aluMode <= ALU1_LD;
            aluA <= readRegister8(register);
            register <= sp[7:0];
            writeRegister <= 1;
            state <= STATE_FETCH_INSTR;
        end

        STATE_PUSH_E1: begin
            sp <= sp - 1;
        end
        STATE_PUSH_E2: begin
            aluA <= readRegister8(register);
            addr <= sp;
        end
        STATE_PUSH_E3: begin
            state <= STATE_FETCH_INSTR;
        end

        STATE_POP_I: begin
            aluMode <= ALU1_LD;
            aluA <= readRegister8(sp[7:0]);
            sp <= sp + 1;
            writeRegister <= 1;
            state <= STATE_FETCH_INSTR;
        end

        STATE_POP_E1: begin
            addr <= sp;
        end
        STATE_POP_E2: begin
        end
        STATE_POP_E3: begin
            aluMode <= ALU1_LD;
            aluA <= memDataRead;
            sp <= sp + 1;
            writeRegister <= 1;
            state <= STATE_FETCH_INSTR;
        end

        STATE_DJNZ1: begin
            aluA <= readRegister8(register);
            aluMode <= ALU1_DEC;
            writeRegister <= 1;
        end

        STATE_DJNZ2: begin
            // needs a special state to handle the pc
            state <= STATE_FETCH_INSTR;
        end

        STATE_LDC_READ1: begin
            addr[15:8] <= readRegister4({secondL[3:1], 1'b0});
            state <= STATE_LDC_READ2;
        end
        STATE_LDC_READ2: begin
            addr[7:0] <= readRegister4({secondL[3:1], 1'b1});
            state <= STATE_READ_MEM1;
        end

        STATE_LDC_WRITE1: begin
            addr[15:8] <= readRegister4({secondL[3:1], 1'b0});
        end
        STATE_LDC_WRITE2: begin
            addr[7:0] <= readRegister4({secondL[3:1], 1'b1});
        end
        STATE_LDC_WRITE3: begin
            aluA <= readRegister8(register);
            state <= STATE_WRITE_MEM;
        end

        STATE_READ_MEM1: begin
        end
        STATE_READ_MEM2: begin
            aluA <= memDataRead;
            aluMode <= ALU1_LD;
            writeRegister <= 1;
            // ldci?
            state <= instrL == 4'h3
                ? STATE_INC_R_RR1
                : STATE_FETCH_INSTR;
        end

        STATE_INC_R_RR1: begin
            aluA <= register;
            register <= r4(secondH);
            aluMode <= ALU1_INC;
            writeRegister <= 1;
        end
        STATE_INC_R_RR2: begin
            aluA <= addr[7:0];
            register <= r4({secondL[3:1], 1'b1});
            aluMode <= ALU1_INC;
            writeRegister <= 1;
        end
        STATE_INC_R_RR3: begin
            aluA <= addr[15:8];
            aluB <= aluOut;
            register[0] <= 1'b0;
            aluMode <= ALU1_INCW;
            writeRegister <= 1;
            state <= STATE_FETCH_INSTR;
        end

        STATE_WRITE_MEM: begin
            state <= instrL == 4'h3
                ? STATE_INC_R_RR1
                : STATE_FETCH_INSTR;
        end

        STATE_CALL_I1: begin
            sp <= sp - 1;
            aluMode <= ALU1_LD;
            aluA <= pc[7:0];
            register <= sp[7:0];
            writeRegister <= 1;
        end
        STATE_CALL_I2: begin
            aluA <= pc[15:8];
            register <= sp[7:0];
            writeRegister <= 1;
        end
        STATE_CALL_I3: begin
            state <= STATE_FETCH_INSTR;
        end
        STATE_CALL_E1: begin
            addr <= sp;
            sp <= sp - 1;
            aluA <= pc[7:0];
        end
        STATE_CALL_E2: begin
            addr <= sp;
            aluA <= pc[15:8];
        end
        STATE_CALL_E3: begin
            state <= STATE_FETCH_INSTR;
        end

        STATE_IRET_I: begin
            aluMode <= ALU1_LD;
            aluA <= readRegister8(sp[7:0]);
            sp <= sp + 1;
            register <= FLAGS;
            writeRegister <= 1;
        end
        STATE_RET_I1: begin
            addr[15:8] <= readRegister8(sp[7:0]);
            sp <= sp + 1;
        end
        STATE_RET_I2: begin
            addr[7:0] <= readRegister8(sp[7:0]);
            sp <= sp + 1;
        end
        STATE_RET_I3: begin
            state <= STATE_FETCH_INSTR;
            //TODO: for iret enable interrupts
        end
        STATE_IRET_E1: begin
            addr <= sp;
            sp <= sp + 1;
        end
        STATE_IRET_E2: begin
            aluMode <= ALU1_LD;
            aluA <= memDataRead;
            register <= FLAGS;
            writeRegister <= 1;
        end
        STATE_RET_E1: begin
            addr <= sp;
            sp <= sp + 1;
        end
        STATE_RET_E2: begin
        end
        STATE_RET_E3: begin
            aluA <= memDataRead;// temp
            addr <= sp;
            sp <= sp + 1;
        end
        STATE_RET_E4: begin
        end
        STATE_RET_E5: begin
            addr[15:8] <= aluA;
            addr[7:0] <= memDataRead;
        end
        STATE_RET_E6: begin
            state <= STATE_FETCH_INSTR;
            //TODO: for iret enable interrupts
        end

        endcase

        pc <= nextPc;
    end
endmodule

module SoC(
    input clk
);
    wire [15:0] memAddr;
    wire [7:0]  memDataRead, romRead, ramRead;
    wire [7:0]  memDataWrite;
    wire        memWrite;
    wire        memStrobe, romStrobe, ramStrobe;
    wire        romEnable, ramEnable;

    // 8k
    Memory #(.addrBusWidth(13)) rom(
        .clk(clk),
        .addr(memAddr[12:0]),
        .dataOut(romRead),
        .dataIn(memDataWrite),
        .write(1'b0),
        .strobe(romStrobe)
    );

    // 2k
    Memory #(.addrBusWidth(11)) ram(
        .clk(clk),
        .addr(memAddr[10:0]),
        .dataOut(ramRead),
        .dataIn(memDataWrite),
        .write(memWrite),
        .strobe(ramStrobe)
    );

    assign romEnable = memAddr[15] == 1'b0;
    assign ramEnable = memAddr[15] == 1'b1;
    assign romStrobe = memStrobe  & romEnable;
    assign ramStrobe = memStrobe  & ramEnable;
    assign memDataRead = romEnable ? romRead : ramRead;

    Processor proc(
        .clk(clk),
        .memAddr(memAddr),
        .memDataRead(memDataRead),
        .memDataWrite(memDataWrite),
        .memWrite(memWrite),
        .memStrobe(memStrobe)
    );
endmodule
