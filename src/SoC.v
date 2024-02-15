`default_nettype none

module Memory #(
    parameter addrBusWidth = 8
) (
    input  wire                      clk,
    input  wire [addrBusWidth - 1:0] addr,
    input  wire                [7:0] dataIn,
    output reg                 [7:0] dataOut,
    input  wire                      write,
    input  wire                      strobe
);
    localparam size = 1 << addrBusWidth;
    reg [7:0] memory[0 : size - 1];
`ifdef BENCH
    integer i, file;
    initial begin
        for (i = 0; i < size; i = i + 1) begin
            memory[i] = 8'h0;
        end

        file = $fopen("memory.txt", "w");
    end
`endif

`include "alu.vh"
`include "assembly.vh"
`include "program.vh"
`ifdef BENCH
    initial begin
        $fclose(file);
    end
`endif
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
    input  wire        clk,
    //input  wire        reset,
    output wire [15:0] memAddr,
    input  wire  [7:0] memDataRead,
    output wire  [7:0] memDataWrite,
    output wire        memWrite,
    output wire        memStrobe,
    output wire  [7:0] port2Out,
    output wire  [3:0] port3Out
);
    `include "flags.vh"

    reg [15:0] pc, sp, addr;
    initial begin
        pc = 'hC;
        sp = 0;
    end
    wire [7:0] spH = sp[15:8];
    wire [7:0] spL = sp[7:0];

    reg [7:0] first;
    wire [3:0] firstH = first[7:4];
    wire [3:0] firstL = first[3:0];

    reg  [7:0] second;
    wire [3:0] secondH = second[7:4];
    wire [3:0] secondL = second[3:0];

    reg  [7:0] third;
    wire [3:0] thirdH = third[7:4];
    wire [3:0] thirdL = third[3:0];

    reg  [7:0] instruction;
    wire [3:0] instrH = instruction[7:4];
    wire [3:0] instrL = instruction[3:0];
    wire isCallDA = instrH == 4'hD && instrL == 4'h6;
    wire isInstrSize1 = firstL[3:1] == 3'b111;
    // call IRR is treated as 3 byte command
    wire isInstrSize3 = firstL[3:2] == 2'b01  // columns 04-07
                      | firstL      == 4'hD   // jp DA
                      ;
    wire isInstrSize2 = first[2]   == 0     // columns 00-03, 08-0B
                      | first[3:0] == 4'hC  // column 0C
                      ;

    wire [15:0] directAddress = {second, third};

    reg [8:0] pre0counter = 0;
    reg [7:0] pre0 = 0;
    reg [8:0] t0counter = 0;
    reg [7:0] t0load = 0;

    reg [8:0] pre1counter = 0;
    reg [7:0] pre1 = 0;
    reg [8:0] t1counter = 0;
    reg [7:0] t1load = 0;

    reg [7:0] tmr = 0;

    reg [7:0] ipr = 0;
    reg [7:0] irq = 0;
    reg [7:0] imr = 0;
    wire [5:0] enabledAndRequestedInterrupts = irq[5:0] & imr[5:0];

    reg [3:0] rp = 0;
    reg [7:0] registers[0:'h7F];
    reg [7:0] p01m = 8'b01_0_01_1_01;
    //                  || | || | ++ P00-P03 Mode: 00 output, 01 input, 1x address A8-A11
    //                  || | || +--- Stack: 0 external,  1 internal
    //                  || | ++----- P1 Mode: 00 Output, 01 Input, 10 AD0-AD7, 11 tristate
    //                  || +-------- Memory timing: 0 normal, 1 extended
    //                  ++---------- P04-P07 Mode: 00 output, 01 input, 1x A12-A15 
    reg [7:0] p3m = 0;
    wire stackInternal = p01m[2];
    reg [7:0] port2;
    assign port2Out = port2;
    reg [7:0] port3;
    assign port3Out = port3[7:4];
    initial begin
        port2 = 0;
        port3 = 0;
        registers[2] = 0;
        registers[3] = 0;
    end

    reg [7:0] register;
    reg writeRegister = 0;
`ifdef BENCH
    initial begin
        for (register = 4; register != 8'h80; register = register + 1) begin
            registers[register] <= 0;
        end
    end
`endif

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
        2:            readRegister8 = port2;
        3:            readRegister8 = port3;
        8'b0???_????: readRegister8 = registers[r[6:0]];
        // SIO
        // TMR is not readable
        T1:           readRegister8 = t1counter[7:0];
        // PRE1
        T0:           readRegister8 = t0counter[7:0];
        // PRE0
        P3M:          readRegister8 = p3m;
        P01M:         readRegister8 = p01m;
        IPR:          readRegister8 = ipr;
        IRQ:          readRegister8 = irq;
        IMR:          readRegister8 = imr;
        FLAGS:        readRegister8 = flags;
        RP:           readRegister8 = { rp, 4'h0 };
        SPH:          readRegister8 = spH;
        SPL:          readRegister8 = spL;
        default:      readRegister8 = 0;
        endcase
    endfunction

    function [7:0] readRegister4(
        input [3:0] r
    );
        readRegister4 = readRegister8(r4(r));
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

`ifdef BENCH
    function [1:4*8] alu1OpName(
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

    function [1:3*8] alu2OpName(
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

    function [1:3*8] ccName(
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
`endif

    `include "states.vh"
    reg [FETCH_MSB:0] fetchState = FETCH_INSTR0;
    reg [OP_MSB:0] opType = OP_UNDECIDED;
    reg [OPSTATE_MSB:0] opState = OPSTATE0;

    wire [15:0] nextRelativePc = pc + { {8{second[7]}}, second };
    reg incPc = 0;
    reg loadPc = 0;
    reg canFetch = 1;
    reg readMem = 0;
    reg writeMem = 0;
    assign memAddr = readMem | writeMem
                     ? addr : pc;
    assign memDataWrite = aluA;
    assign memWrite = writeMem;
    assign memStrobe = canFetch & (fetchState == FETCH_INSTR1
                                 | fetchState == FETCH_SECOND1
                                 | fetchState == FETCH_THIRD1)
                     | readMem
                     | writeMem;
`ifdef BENCH
    reg[4:0] cycleCounter = 26;
    reg[4:0] expectedCycles = 0;
`endif

    always @(posedge clk) begin
        if (writeFlags) begin
`ifdef BENCH
            $display("    alu:    %h       %h    =>    %h", aluA, aluB, aluOut);
            $display("         %b %b => %b", aluA, aluB, aluOut);
            $display("    flags = %b_%b", flagsOut[7:4], flagsOut[3:0]);
`endif
            flags <= flagsOut;
        end
        writeFlags <= 0;

        if (writeRegister) begin
`ifdef BENCH
            $display("    reg[%h] = %h", register, aluOut);
`endif
            casez (register)
            8'b0???_????: registers[register] <= aluOut;
            //SIO:          sioOut              <= aluOut;
            TMR:          tmr                 <= aluOut;
            T1:           t1load              <= aluOut;
            PRE1:         pre1                <= aluOut;
            T0:           t0load              <= aluOut;
            PRE0:         pre0                <= aluOut;
            P3M:          p3m                 <= aluOut;
            P01M:         p01m                <= aluOut;
            IPR:          ipr                 <= aluOut;
            IRQ:          irq                 <= aluOut;
            IMR:          imr                 <= aluOut;
            FLAGS:        flags               <= aluOut;
            RP:           rp                  <= aluOut[7:4];
            SPH:          sp[15:8]            <= aluOut;
            SPL:          sp[7:0]             <= aluOut;
            endcase

            // store in registers AND ports, so it is easier to check registers
            case (register)
            2: port2 <= aluOut;
            3: port3 <= aluOut;
            endcase
        end
        writeRegister <= 0;
        readMem <= 0;
        writeMem <= 0;

`ifdef BENCH
        if (fetchState == FETCH_SECOND2) begin
            if (cycleCounter != 0 & cycleCounter != 31) begin
                if (expectedCycles == 0) begin
                    $display("expected cycles not defined");
                    $finish(2);
                end

                if (cycleCounter < expectedCycles) 
                    $display("%d cycles, expected %d", cycleCounter, expectedCycles);
                else if (cycleCounter > expectedCycles) 
                    $display("%d cycles, expected %d - TOO SLOW", cycleCounter, expectedCycles);
                else
                    $display("exact %d cycles", cycleCounter);
                expectedCycles <= 0;
            end
            cycleCounter <= 1;
        end
        else begin
            cycleCounter <= cycleCounter + 1;
        end
`endif

        if (canFetch) begin
            fetchState <= fetchState + FETCH_INC;
        end
        if (opType != OP_UNDECIDED) begin
            opState <= opState + OPSTATE_INC;
        end

        pc <= loadPc ? addr
                     : incPc ? pc + 16'b1
                             : pc;
        incPc <= 0;
        loadPc <= 0;

        case (fetchState)
        FETCH_INSTR0: begin
`ifdef BENCH
/*             addr <= 0;
            aluA <= 0;
            aluB <= 0;
            aluMode <= 0;
            register <= 0;
            first <= 0;
            second <= 0;
            third <= 0;
 */
`endif
        end
        
        FETCH_INSTR1: begin
            incPc <= canFetch;
        end

        FETCH_INSTR2: begin
`ifdef BENCH
            $display("\n%h: read 1st byte %h", pc, memDataRead);
`endif
            first <= memDataRead;
        end

        FETCH_SECOND0: begin
            opType <= OP_UNDECIDED;
        end

        FETCH_SECOND1: begin
            if (~isInstrSize1) begin
                incPc <= 1;
            end
        end

        FETCH_SECOND2: begin
`ifdef BENCH
            $display("%h: read 2nd byte %h", pc, memDataRead);
`endif
            if (imr[7] & (enabledAndRequestedInterrupts != 0)) begin
`ifdef BENCH
                $display("starting isr");
`endif
                imr[7] <= 0;
                canFetch <= 0;
                opType <= OP_ISR;
                opState <= OPSTATE0;
            end
            else begin
                second <= memDataRead;
                instruction <= first;
                if (isInstrSize1 | isInstrSize2) begin
                    opType <= OP_DECODE;
                    fetchState <= FETCH_INSTR0;
                end
            end
        end

        FETCH_THIRD1: begin
            incPc <= instruction != 8'hD4;
        end

        FETCH_THIRD2: begin
`ifdef BENCH
            $display("%h: read 3rd byte %h", pc, memDataRead);
`endif
            third <= memDataRead;
            opType <= OP_DECODE;
            fetchState <= FETCH_INSTR0;
        end
        endcase

        case (opType)
        OP_DECODE: begin
`ifdef BENCH
            // $display("  decoding");
            if (isInstrSize1)
                $display("  %h", instruction);
            else if (isInstrSize2)
                $display("  %h %h", instruction, second);
            else if (isInstrSize3)
                $display("  %h %h %h", instruction, second, third);
`endif
            opState <= OPSTATE0;

            case (instrL)
            // ================================================================
            // Column 0
            // ================================================================
            4'h0: begin
                case (instrH)
                4'h3: begin
`ifdef BENCH
                    $display("    jp @%h", second);
                    expectedCycles <= 8;
`endif
                    addr[7:0] = readRegister8(r8({second[7:1], 1'b1}));
                    opType <= OP_JP_IRR;
                    canFetch <= 0;
                end
                4'h4: begin
`ifdef BENCH
                    $display("   da %h", second);
                    expectedCycles <= 8;
`endif
                    aluMode <= alu1OpCode(instrH);
                    register <= r8(second);
                    opType <= OP_ALU1DA;
                    canFetch <= 0;
                end
                4'h5: begin
`ifdef BENCH
                    $display("    pop %h", second);
                    expectedCycles <= 10;
`endif
                    // dst <- @SP
                    // SP <- SP + 1
                    register <= r8(second);
                    opType <= OP_POP;
                    canFetch <= 0;
                end
                4'h7: begin
`ifdef BENCH
                    $display("    push %h", second);
                    expectedCycles <= stackInternal ? 10 : 12;
`endif
                    register <= r8(second);
                    opType <= OP_PUSH;
                    opState <= OPSTATE2;
                    canFetch <= 0;
                end
                4'h8: begin
`ifdef BENCH
                    $display("    decw %h", second);
                    expectedCycles <= 10;
`endif
                    opType <= OP_ALU1WORD;
                    canFetch <= 0;
                end
                4'hA: begin
`ifdef BENCH
                    $display("    incw %h", second);
                    expectedCycles <= 10;
`endif
                    opType <= OP_ALU1WORD;
                    canFetch <= 0;
                end
                default: begin
`ifdef BENCH
                    $display("   %s %h", 
                            alu1OpName(instrH), second);
                    expectedCycles <= instrH == 4'hF ? 8 : 6;
`endif
                    aluMode <= alu1OpCode(instrH);
                    register <= r8(second);
                    opType <= OP_ALU1;
                    canFetch <= instrH != 4'hF;
                end
                endcase
            end
            // ================================================================
            // Column 1
            // ================================================================
            4'h1: begin
                case (instrH)
                4'h3: begin
`ifdef BENCH
                    $display("    srp %h", second);
                    expectedCycles <= 6;
`endif
                    register <= RP;
                    opType <= OP_LD;
                end
                4'h4: begin
`ifdef BENCH
                    $display("   da @%h", second);
                    expectedCycles <= 8;
`endif
                    aluMode <= alu1OpCode(instrH);
                    register <= readRegister8(r8(second));
                    opType <= OP_ALU1DA;
                    canFetch <= 0;
                end
                4'h5: begin
`ifdef BENCH
                    $display("    pop @%h", second);
                    expectedCycles <= 10;
`endif
                    register <= readRegister8(r8(second));
                    opType <= OP_POP;
                    canFetch <= 0;
                end
                4'h7: begin
`ifdef BENCH
                    $display("    push @%h", second);
                    expectedCycles <= stackInternal ? 12 : 14;
`endif
                    register <= r8(second);
                    opType <= OP_PUSH;
                    canFetch <= 0;
                end
                4'h8: begin
`ifdef BENCH
                    $display("    decw @%h", second);
                    expectedCycles <= 10;
`endif
                    opType <= OP_ALU1WORD;
                    canFetch <= 0;
                end
                4'hA: begin
`ifdef BENCH
                    $display("    incw @%h", second);
                    expectedCycles <= 10;
`endif
                    opType <= OP_ALU1WORD;
                    canFetch <= 0;
                end
                default: begin
`ifdef BENCH
                    $display("   %s @%h", 
                            alu1OpName(instrH), second);
                    expectedCycles <= instrH == 4'hF ? 8 : 6;
`endif
                    aluMode <= alu1OpCode(instrH);
                    register <= readRegister8(r8(second));
                    opType <= OP_ALU1;
                    canFetch <= instrH != 4'hF;
                end
                endcase
            end
            // ================================================================
            // Column 2
            // ================================================================
            4'h2: begin
                case (instrH)
                4'h8: begin
`ifdef BENCH
                    $display("    lde r%h, Irr%h",
                            secondH, secondL);
                    expectedCycles <= 12;
`endif
                    register <= r4(secondH);
                    opType <= OP_LDC;
                    canFetch <= 0;
                end
                4'h9: begin
`ifdef BENCH
                    $display("    lde Irr%h, r%h",
                            secondL, secondH);
                    expectedCycles <= 12;
`endif
                    register <= r4(secondH);
                    opType <= OP_LDC;
                    canFetch <= 0;
                end
                4'hC: begin
`ifdef BENCH
                    $display("    ldc r%h, Irr%h",
                            secondH, secondL);
                    expectedCycles <= 12;
`endif
                    register <= r4(secondH);
                    opType <= OP_LDC;
                    canFetch <= 0;
                end
                4'hD: begin
`ifdef BENCH
                    $display("    ldc Irr%h, r%h",
                            secondL, secondH);
                    expectedCycles <= 12;
`endif
                    register <= r4(secondH);
                    opType <= OP_LDC;
                    canFetch <= 0;
                end
                4'hE,
                4'hF: begin
`ifdef BENCH
                    $display("    ? %h", second);
`endif
                    opType <= OP_ILLEGAL;
                end
                // x2
                default: begin
`ifdef BENCH
                    $display("    %s r%h, r%h",
                            alu2OpName(instrH),
                            secondH, secondL);
                    expectedCycles <= 6;
`endif
                    register <= r4(secondL);
                    opType <= OP_ALU2;
                end
                endcase
            end
            // ================================================================
            // Column 3
            // ================================================================
            4'h3: begin
                case (instrH)
                4'h8: begin
`ifdef BENCH
                    $display("    ldei Ir%h, Irr%h",
                            secondH, secondL);
                    expectedCycles <= 18;
`endif
                    register <= readRegister4(secondH);
                    opType <= OP_LDC;
                    canFetch <= 0;
                end
                4'h9: begin
`ifdef BENCH
                    $display("    ldei Irr%h, Ir%h",
                            secondL, secondH);
                    expectedCycles <= 18;
`endif
                    register <= readRegister4(secondH);
                    opType <= OP_LDC;
                    canFetch <= 0;
                end
                4'hC: begin
`ifdef BENCH
                    $display("    ldci Ir%h, Irr%h",
                            secondH, secondL);
                    expectedCycles <= 18;
`endif
                    register <= readRegister4(secondH);
                    opType <= OP_LDC;
                    canFetch <= 0;
                end
                4'hD: begin
`ifdef BENCH
                    $display("    ldci Irr%h, Ir%h",
                            secondL, secondH);
                    expectedCycles <= 18;
`endif
                    register <= readRegister4(secondH);
                    opType <= OP_LDC;
                    canFetch <= 0;
                end
                4'hE: begin
`ifdef BENCH
                    $display("    ld r%h, @r%h",
                            secondH, secondL);
                    expectedCycles <= 6;
`endif
                    register <= readRegister4(secondL);
                    opType <= OP_LD;
                end
                4'hF: begin
`ifdef BENCH
                    $display("    ld @r%h, r%h",
                            secondH, secondL);
                    expectedCycles <= 6;
`endif
                    register <= readRegister4(secondH);
                    opType <= OP_LD;
                end
                default: begin
`ifdef BENCH
                    $display("    %s r%h, Ir%h",
                            alu2OpName(instrH),
                            secondH, secondL);
                    expectedCycles <= 6;
`endif
                    register <= readRegister4(secondL);
                    opType <= OP_ALU2;
                end
                endcase
            end
            // ================================================================
            // Column 4
            // ================================================================
            4'h4: begin
                case (instrH)
                4'h8,
                4'h9,
                4'hC,
                4'hF: begin
`ifdef BENCH
                    $display("    ? %h", instruction);
`endif
                    opType <= OP_ILLEGAL;
                end
                4'hD: begin
`ifdef BENCH
                    $display("    call @%h", second);
                    expectedCycles <= 20;
`endif
                    opType <= OP_CALL;
                    canFetch <= 0;
                end
                4'hE: begin
`ifdef BENCH
                    $display("    ld %h, %h", third, second);
                    expectedCycles <= 10;
`endif
                    register <= r8(second);
                    opType <= OP_LD;
                    canFetch <= 0;
                end
                // x4
                default: begin
`ifdef BENCH
                    $display("    %s %h, %h",
                            alu2OpName(instrH),
                            third, second);
                    expectedCycles <= 10;
`endif
                    register <= r8(second);
                    opType <= OP_ALU2;
                    canFetch <= 0;
                end
                endcase
            end
            // ================================================================
            // Column 5
            // ================================================================
            4'h5: begin
                case (instrH)
                4'h8,
                4'h9,
                4'hC,
                4'hD:
                begin
`ifdef BENCH
                    $display("    ? %h", instruction);
`endif
                    opType <= OP_ILLEGAL;
                end
                4'hE: begin
`ifdef BENCH
                    $display("    ld %h, @%h", third, second);
                    expectedCycles <= 10;
`endif
                    register <= readRegister8(r8(second));
                    opType <= OP_LD;
                    canFetch <= 0;
                end
                4'hF: begin
`ifdef BENCH
                    $display("    ld @%h, %h", third, second);
                    expectedCycles <= 10;
`endif
                    aluA <= readRegister8(r8(second));
                    opType <= OP_LD;
                    canFetch <= 0;
                end
                // x5
                default: begin
`ifdef BENCH
                    $display("    %s %h, @%h",
                            alu2OpName(instrH),
                            third, second);
                    expectedCycles <= 10;
`endif
                    register <= readRegister8(r8(second));
                    opType <= OP_ALU2;
                    canFetch <= 0;
                end
                endcase
            end
            // ================================================================
            // Column 6
            // ================================================================
            4'h6: begin
                case (instrH)
                4'h8,
                4'h9,
                4'hC,
                4'hF: begin
`ifdef BENCH
                    $display("    ? %h", instruction);
`endif
                    opType <= OP_ILLEGAL;
                end
                4'hD: begin
`ifdef BENCH
                    $display("    call %h", directAddress);
                    expectedCycles <= 20;
`endif
                    opType <= OP_CALL;
                    canFetch <= 0;
                end
                4'hE: begin
`ifdef BENCH
                    $display("    ld %h, #%h", second, third);
                    expectedCycles <= 10;
`endif
                    register <= r8(second);
                    opType <= OP_LD;
                    canFetch <= 0;
                end
                default: begin
`ifdef BENCH
                    $display("    %s %h, #%h",
                            alu2OpName(instrH),
                            second, third);
                    expectedCycles <= 10;
`endif
                    register <= r8(second);
                    opType <= OP_ALU2;
                    canFetch <= 0;
                end
                endcase
            end
            // ================================================================
            // Column 7
            // ================================================================
            4'h7: begin
                case (instrH)
                4'h8,
                4'h9,
                4'hF: begin
`ifdef BENCH
                    $display("    ? %h", instruction);
`endif
                    opType <= OP_ILLEGAL;
                end
                4'hC: begin
`ifdef BENCH
                    $display("    ld r%h, @r%h+%h", 
                            secondH, secondL, third);
                    expectedCycles <= 10;
`endif
                    register <= readRegister4(secondL);
                    opType <= OP_LD;
                    canFetch <= 0;
                end
                4'hD: begin
`ifdef BENCH
                    $display("    ld @r%h+%h, r%h", 
                            secondL, third, secondH);
                    expectedCycles <= 10;
`endif
                    register <= readRegister4(secondL);
                    opType <= OP_LD;
                    canFetch <= 0;
                end
                4'hE: begin
`ifdef BENCH
                    $display("    ld @%h, #%h", second, third);
                    expectedCycles <= 10;
`endif
                    register <= readRegister8(r8(second));
                    opType <= OP_LD;
                    canFetch <= 0;
                end
                default: begin
`ifdef BENCH
                    $display("    %s @%h, #%h",
                            alu2OpName(instrH),
                            second, third);
                    expectedCycles <= 10;
`endif
                    register <= readRegister8(r8(second));
                    opType <= OP_ALU2;
                    canFetch <= 0;
                end
                endcase
            end
            // ================================================================
            // Column 8
            // ================================================================
            4'h8: begin
`ifdef BENCH
                $display("    ld r%h, %h", instrH, second);
                expectedCycles <= 6;
`endif
                register <= r4(instrH);
                opType <= OP_LD;
            end
            // ================================================================
            // Column 9
            // ================================================================
            4'h9: begin
`ifdef BENCH
                $display("    ld %h, r%h", second, instrH);
                expectedCycles <= 6;
`endif
                register <= second; // no r8(second) !
                opType <= OP_LD;
            end
            // ================================================================
            // Column A
            // ================================================================
            4'hA: begin
`ifdef BENCH
                $display("    djnz r%h, %h", instrH, second);
`endif
                register <= r4(instrH);
                opType <= OP_DJNZ;
                canFetch <= 0;
            end
            // ================================================================
            // Column B
            // ================================================================
            4'hB: begin
`ifdef BENCH
                $display("    jr %s, %h", ccName(instrH), second);
                expectedCycles <= takeBranch ? 12 : 10;
`endif
                opType <= OP_JR;
                canFetch <= 0;
            end
            // ================================================================
            // Column C
            // ================================================================
            4'hC: begin
`ifdef BENCH
                $display("    ld r%h, #%h", instrH, second);
                expectedCycles <= 6;
`endif
                register <= r4(instrH);
                opType <= OP_LD;
            end
            // ================================================================
            // Column D
            // ================================================================
            4'hD: begin
`ifdef BENCH
                $display("    jp %s, %h", ccName(instrH), directAddress);
                expectedCycles <= takeBranch ? 12 : 10;
`endif
                opType <= OP_JP;
                canFetch <= 0;
            end
            // ================================================================
            // Column E
            // ================================================================
            4'hE: begin
`ifdef BENCH
                $display("    inc r%h", instrH);
                expectedCycles <= 6;
`endif
                register <= r4(instrH);
                aluMode <= ALU1_INC;
                opType <= OP_ALU1;
            end
            // ================================================================
            // Column F
            // ================================================================
            4'hF: begin
                case (instrH)
                4'h8: begin
`ifdef BENCH
                    $display("    di");
                    expectedCycles <= 6;
`endif
                    imr[7] <= instrH[0];
                end
                4'h9: begin
`ifdef BENCH
                    $display("    ei");
                    expectedCycles <= 6;
`endif
                    imr[7] <= instrH[0];
                end
                4'hA: begin
`ifdef BENCH
                    $display("    ret");
                    expectedCycles <= 14;
`endif
                    opType <= OP_RET;
                    canFetch <= 0;
                end
                4'hB: begin
`ifdef BENCH
                    $display("    iret");
                    expectedCycles <= 16;
`endif
                    opType <= OP_IRET;
                    canFetch <= 0;
                end
                4'hC: begin
`ifdef BENCH
                    $display("    rcf");
                    expectedCycles <= 6;
`endif
                    flags[FLAG_INDEX_C] <= instrH[0];
                    opType <= OP_MISC;
                end
                4'hD: begin
`ifdef BENCH
                    $display("    scf");
                    expectedCycles <= 6;
`endif
                    flags[FLAG_INDEX_C] <= instrH[0];
                    opType <= OP_MISC;
                end
                4'hE: begin
`ifdef BENCH
                    $display("    ccf");
                    expectedCycles <= 6;
`endif
                    flags[FLAG_INDEX_C] <= ~flags[FLAG_INDEX_C];
                    opType <= OP_MISC;
                end
                4'hF: begin
`ifdef BENCH
                    $display("    nop");
                    expectedCycles <= 6;
`endif
                    opType <= OP_MISC;
                end
                default: begin
`ifdef BENCH
                    $display("    ?");
`endif
                    opType <= OP_ILLEGAL;
                end
                endcase
            end
            endcase
        end

        OP_LD: begin
            case (opState)
            OPSTATE0: begin
                canFetch <= 1;
                case (instrL)
                4'h1: begin
                    // srp
                    aluA <= second;
                end
                4'h3: begin
                    case (instrH)
                    4'hE: begin
                        aluA <= readRegister8(register);
                        register <= r4(secondH);
                    end
                    4'hF: begin
                        aluA <= readRegister4(secondL);
                    end
                    endcase
                end
                4'h4: begin
                    case (instrH)
                    4'hE: begin
                        aluA <= readRegister8(register);
                        register <= r8(third);
                    end
                    endcase
                end
                4'h5: begin
                    case (instrH)
                    4'hE: begin
                        aluA <= readRegister8(register);
                        register <= r8(third);
                    end
                    4'hF: begin
                        register <= readRegister8(r8(third));
                    end
                    endcase
                end
                4'h6: begin
                    case (instrH)
                    4'hE: begin
                        aluA <= third;
                    end
                    endcase
                end
                4'h7: begin
                    case (instrH)
                    4'hC: begin
                        aluA <= readRegister8(register + third);
                        register <= r4(secondH);
                    end
                    4'hD: begin
                        aluA <= readRegister4(secondH);
                        register <= register + third;
                    end
                    4'hE: begin
                        aluA <= third;
                    end
                    endcase
                end
                4'h8: begin
                    aluA <= readRegister8(r8(second));
                end
                4'h9: begin
                    aluA <= readRegister4(instrH);
                end
                4'hC: begin
                    aluA <= second;
                end
                endcase
                aluMode <= ALU1_LD;
                writeRegister <= 1;
            end
            endcase
        end
        OP_ALU1: begin
            case (opState)
            OPSTATE0: begin
                aluA <= readRegister8(register);
                writeRegister <= 1;
                writeFlags <= 1;
            end
            OPSTATE1:
                canFetch <= 1;
            endcase
        end
        OP_ALU1DA: begin
            case (opState)
            OPSTATE0: begin
                aluA <= readRegister8(register);
                writeRegister <= 1;
                writeFlags <= 1;
            end
            OPSTATE1: begin
                aluA <= aluOut;
                aluMode <= ALU1_DA_H;
                writeRegister <= 1;
                writeFlags <= 1;
                canFetch <= 1;
            end
            endcase
        end
        OP_ALU1WORD: begin
            case (opState)
            OPSTATE0: begin
                aluMode <= instrH & 7;
                register <= instrL & 1 
                    ? readRegister8(r8(second))
                    : r8(second);
            end
            OPSTATE1: begin
                register <= {register[7:1], 1'h1};
            end
            OPSTATE2: begin
                aluA <= readRegister8(register);
                writeRegister <= 1;
            end
            OPSTATE3: begin
                register <= { register[7:1], 1'b0 };
                canFetch <= 1;
            end
            OPSTATE4: begin
                aluA <= readRegister8(register);
                aluB <= aluOut;
                aluMode <= aluMode | 'h8; // inc/dec -> incw/decw
                writeRegister <= 1;
                writeFlags <= 1;
            end
            endcase
        end
        OP_ALU2: begin
            case (opState)
            OPSTATE0: begin
                case (instrL)
                2, // r, r
                3: // r, Ir
                begin
                    aluB <= readRegister8(register);
                    register <= r4(secondH);
                end
                4, // R, R
                5: // R, IR
                begin
                    aluB <= readRegister8(register);
                    register <= r8(third);
                end
                6, // R, IM
                7: // IR, IM
                begin
                    aluB <= third;
                end
                endcase
                canFetch <= 1;
            end
            OPSTATE1: begin
                aluA <= readRegister8(register);
            end
            OPSTATE2: begin
                aluMode <= alu2OpCode(instrH);
                writeRegister <= (instrH[3:2] == 2'b00)     // add, adc, sub, sbc
                                | (instrH[3:1] == 3'b010)   // or, and
                                | (instrH      == 4'b1011); // xor
                writeFlags <= 1;
            end
            endcase
        end
        OP_POP: begin
            case (opState)
            OPSTATE0: begin
                addr <= sp;
                readMem <= 1;
            end
            OPSTATE1: begin
                readMem <= 1;
            end
            OPSTATE2: begin
                aluA <= stackInternal
                    ? readRegister8(addr[7:0])
                    : memDataRead;
            end
            OPSTATE3: begin
                aluMode <= ALU1_LD;
                sp <= sp + 16'b1;
                writeRegister <= 1;
                canFetch <= 1;
            end
            endcase
        end
        OP_PUSH: begin
            case (opState)
            OPSTATE0: begin
                register <= readRegister8(register);
            end
            OPSTATE2: begin
                sp <= sp - 16'b1;
            end
            OPSTATE3: begin
                if (stackInternal) begin
                    aluMode <= ALU1_LD;
                    aluA <= readRegister8(register);
                    register <= spL;
                    writeRegister <= 1;
                end
                else begin
                    aluA <= readRegister8(register);
                    addr <= sp;
                    writeMem <= 1;
                end
            end
            OPSTATE5: begin
                canFetch <= stackInternal;
            end
            OPSTATE7: begin
                canFetch <= 1;
            end
            endcase
        end
        OP_DJNZ: begin
            case (opState)
            OPSTATE0: begin
                aluA <= readRegister8(register);
                aluMode <= ALU1_DEC;
                writeRegister <= 1;
            end
            OPSTATE1: begin
`ifdef BENCH
                expectedCycles <= flagsOut[FLAG_INDEX_Z] ? 10 : 12;
`endif
                if (flagsOut[FLAG_INDEX_Z])
                    opState <= OPSTATE4;
            end
            OPSTATE3: begin
                addr <= nextRelativePc;
                loadPc <= 1;
            end
            OPSTATE4: begin
                canFetch <= 1;
                fetchState <= FETCH_INSTR0;
            end
            endcase
        end
        OP_JP_IRR: begin
            case (opState)
            OPSTATE0: begin
                addr[15:8] = readRegister8(r8({second[7:1], 1'b0}));
                loadPc <= 1;
                canFetch <= 1;
                fetchState <= FETCH_INSTR0;
            end
            endcase
        end
        OP_JP: begin
            case (opState)
            OPSTATE0: begin
                addr <= {second, third};
                if (takeBranch) begin
                    loadPc <= 1;
                    fetchState <= FETCH_INSTR0;
                end
                else begin
                    canFetch <= 1;
                end
            end
            OPSTATE1: begin
                canFetch <= 1;
            end
            endcase
        end
        OP_JR: begin
            case (opState)
            OPSTATE0: begin
                addr[7:0] = nextRelativePc[7:0];
            end
            OPSTATE1: begin
                addr[15:8] = nextRelativePc[15:8];
            end
            OPSTATE3: begin
                if (takeBranch) begin
                    loadPc <= 1;
                    fetchState <= FETCH_INSTR0;
                end
                else begin
                    canFetch <= 1;
                end
            end
            OPSTATE4: begin
                canFetch <= 1;
            end
            endcase
        end
        OP_CALL: begin
            // push PCL, PCH
            case (opState)
            OPSTATE0: begin
                sp <= sp - 16'b1;
                aluA <= pc[7:0];
            end
            OPSTATE1,
            OPSTATE3: begin
                if (stackInternal) begin
                    aluMode <= ALU1_LD;
                    register <= spL;
                    writeRegister <= 1;
                end
                else begin
                    addr <= sp;
                    writeMem <= 1;
                end
            end
            OPSTATE2: begin
                sp <= sp - 16'b1;
                aluA <= pc[15:8];
            end
            OPSTATE4: begin
                addr[15:8] = isCallDA 
                    ? second
                    : readRegister8(r8({second[7:1], 1'b0}));
            end
            OPSTATE5: begin
                addr[7:0] = isCallDA
                    ? third
                    : readRegister8(r8({second[7:1], 1'b1}));
                loadPc <= 1;
                fetchState <= FETCH_INSTR0;
            end
            OPSTATE9:
                canFetch <= 1;
            endcase
        end
        OP_IRET: begin
            // flags, PCH, PCL
            case (opState)
            OPSTATE0: begin
                addr <= sp;
                sp <= sp + 16'b1;
                readMem <= ~stackInternal;
            end
            OPSTATE1: begin
                aluMode <= ALU1_LD;
                aluA <= stackInternal
                    ? readRegister8(addr[7:0])
                    : memDataRead;
                register <= FLAGS;
                writeRegister <= 1;
                opType <= OP_RET;
                opState <= OPSTATE0;
            end
            endcase
        end
        OP_RET: begin
            // PCH, PCL
            case (opState)
            OPSTATE0: begin
                addr <= sp;
                readMem <= ~stackInternal;
            end
            OPSTATE1: begin
                sp <= sp + 16'b1;
                readMem <= ~stackInternal;
            end
            OPSTATE2: begin
                aluA <= stackInternal
                    ? readRegister8(addr[7:0])
                    : memDataRead; // temp
                addr <= sp;
                readMem <= ~stackInternal;
            end
            OPSTATE3: begin
                sp <= sp + 16'b1;
                readMem <= ~stackInternal;
            end
            OPSTATE4: begin
                addr[15:8] <= aluA;
                addr[7:0] <= stackInternal
                    ? readRegister8(addr[7:0])
                    : memDataRead;
                loadPc <= 1;
                fetchState <= FETCH_INSTR0;
            end
            OPSTATE6:
                canFetch <= 1;
            OPSTATE8: begin
                // iret?
                if (instrH[0])
                    imr[7] <= 1;
            end
            endcase
        end
        OP_LDC: begin
            case (opState)
            OPSTATE0: begin
                addr[15:8] <= readRegister4({secondL[3:1], 1'b0});
            end
            OPSTATE1: begin
                addr[7:0] <= readRegister4({secondL[3:1], 1'b1});
                if (instrH[0] == 0) begin
                    readMem <= 1;
                end
            end
            OPSTATE2: begin
                if (instrH[0] == 0) begin
                    readMem <= 1;
                end
                else begin
                    aluA <= readRegister8(register);
                    writeMem <= 1;
                end
            end
            OPSTATE3: begin
                if (instrH[0] == 0) begin
                    aluA <= memDataRead;
                    aluMode <= ALU1_LD;
                    writeRegister <= 1;
                end
            end
            OPSTATE4: begin
                // ldci?
                if (instrL[0] == 1) begin
                    aluA <= register;
                    register <= r4(secondH);
                    aluMode <= ALU1_INC;
                    writeRegister <= 1;
                end
            end
            OPSTATE5: begin
                if (instrL[0] == 1) begin
                    aluA <= addr[7:0];
                    register <= r4({secondL[3:1], 1'b1});
                    aluMode <= ALU1_INC;
                    writeRegister <= 1;
                end
                else begin
                    canFetch <= 1;
                end
            end
            OPSTATE6: begin
                if (instrL[0] == 1) begin
                    aluA <= addr[15:8];
                    aluB <= aluOut;
                    register[0] <= 1'b0;
                    aluMode <= ALU1_INCW;
                    writeRegister <= 1;
                end
            end
            11:
                canFetch <= 1;
            endcase
        end
        OP_MISC: begin
        end
        OP_ISR: begin
            // todo check IPR
            case (opState)
            OPSTATE0: begin
                sp <= sp - 16'b1;
                pc <= pc - (isInstrSize1 ? 16'd1 : 16'd2);
            end
            OPSTATE1: begin
                aluA <= pc[7:0];
                if (stackInternal) begin
                    aluMode <= ALU1_LD;
                    register <= spL;
                    writeRegister <= 1;
                end
                else begin
                    addr <= sp;
                    writeMem <= 1;
                end
                sp <= sp - 16'b1;
            end
            OPSTATE2: begin
                aluA <= pc[15:8];
                if (stackInternal) begin
                    aluMode <= ALU1_LD;
                    register <= spL;
                    writeRegister <= 1;
                end
                else begin
                    addr <= sp;
                    writeMem <= 1;
                end
                sp <= sp - 16'b1;
            end
            OPSTATE3: begin
                aluA <= flags;
                if (stackInternal) begin
                    aluMode <= ALU1_LD;
                    register <= spL;
                    writeRegister <= 1;
                end
                else begin
                    addr <= sp;
                    writeMem <= 1;
                end
            end
            OPSTATE4: begin
                if (enabledAndRequestedInterrupts[0]) begin
                    addr <= 16'h0000;
                    irq[0] <= 0;
                end
                else if (enabledAndRequestedInterrupts[1]) begin
                    addr <= 16'h0002;
                    irq[1] <= 0;
                end
                else if (enabledAndRequestedInterrupts[2]) begin
                    addr <= 16'h0004;
                    irq[2] <= 0;
                end
                else if (enabledAndRequestedInterrupts[3]) begin
                    addr <= 16'h0006;
                    irq[3] <= 0;
                end
                else if (enabledAndRequestedInterrupts[4]) begin
                    addr <= 16'h0008;
                    irq[4] <= 0;
                end
                else begin
                    addr <= 16'h000A;
                    irq[5] <= 0;
                end
                readMem <= 1;
            end
            OPSTATE5: begin
                readMem <= 1;
            end
            OPSTATE6: begin
                pc[15:8] <= memDataRead;
                addr[0] <= 1;
                readMem <= 1;
            end
            OPSTATE7: begin
                readMem <= 1;
            end
            OPSTATE8: begin
                pc[7:0] <= memDataRead;
                canFetch <= 1;
                fetchState <= FETCH_INSTR0;
`ifdef BENCH
                cycleCounter <= 26;
`endif
            end
            endcase
        end
        OP_ILLEGAL: begin
            opState <= OPSTATE0;
        end
        endcase

        `include "timers.vh"
    end
endmodule

module SoC(
    input  wire       clk,
    output wire [7:0] port2,
    output wire [3:0] port3
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
        .memStrobe(memStrobe),
        .port2Out(port2),
        .port3Out(port3)
    );
endmodule
