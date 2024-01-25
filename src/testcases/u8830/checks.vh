    @(negedge clk);
// srp #00
    repeat (3) @(negedge clk);
        `assertInstr('h31);
        `assertSecond('h00);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assert(uut.proc.rp, 'h0);

// ld r3, #0F
    repeat (3) @(negedge clk);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h03, 'h0F);

// nop
    repeat (2) @(negedge clk);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);

// tm r3, #0b0000_0100
    repeat (5) @(negedge clk);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_ALU2_OP);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h03, 'h0F);

// ld r3, #hFF
    repeat (3) @(negedge clk);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h03, 'hFF);

// jr nz, M_001D
    repeat (3) @(negedge clk);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
        `assertPc('h1D);
    @(negedge clk);

// M_001D:
// ld P01M, #B6
    repeat (5) @(negedge clk);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assert(uut.proc.p01m, 'hB6);

// ld P3M, #8
    repeat (5) @(negedge clk);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        //`assert(uut.proc.p3m, 'h08); //TODO

// ld r4, #8
    repeat (3) @(negedge clk);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h04, 'h08);

// ld r5, #12
    repeat (3) @(negedge clk);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h05, 'h12);

// ldc r6, Irr4
    repeat (3) @(negedge clk);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_LDC_READ1);
    @(negedge clk);
        `assertState(STATE_LDC_READ2);
    @(negedge clk);
        `assertState(STATE_READ_MEM1);
    @(negedge clk);
        `assertState(STATE_READ_MEM2);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister(8'h06, 8'h00);

// com r6
    repeat (3) @(negedge clk);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_ALU1_OP);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister(8'h06, 8'hFF);

// ldc Irr4, r6
    repeat (3) @(negedge clk);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_LDC_WRITE1);
    @(negedge clk);
        `assertState(STATE_LDC_WRITE2);
    @(negedge clk);
        `assertState(STATE_LDC_WRITE3);
    @(negedge clk);
        `assertState(STATE_WRITE_MEM);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRom(16'h0812, 8'h00);
        `assertRegister(8'h06, 8'hFF);

// ldc r7, Irr4
    repeat (3) @(negedge clk);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_LDC_READ1);
    @(negedge clk);
        `assertState(STATE_LDC_READ2);
    @(negedge clk);
        `assertState(STATE_READ_MEM1);
    @(negedge clk);
        `assertState(STATE_READ_MEM2);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister(8'h07, 8'h00);

// com r6
    repeat (3) @(negedge clk);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_ALU1_OP);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister(8'h06, 8'h00);

// ldc Irr4, r6
    repeat (3) @(negedge clk);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_LDC_WRITE1);
    @(negedge clk);
        `assertState(STATE_LDC_WRITE2);
    @(negedge clk);
        `assertState(STATE_LDC_WRITE3);
    @(negedge clk);
        `assertState(STATE_WRITE_MEM);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister(8'h06, 8'h00);

// xor r6, r7
    repeat (3) @(negedge clk);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_ALU2_OP);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister(8'h06, 8'h00);
        `assertFlags('b0100_0000);

// srp #F0
    repeat (3) @(negedge clk);
        `assertInstr('h31);
        `assertSecond('hF0);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assert(uut.proc.rp, 'hF);

// jp nz, E000
    repeat (5) @(negedge clk);
        `assertInstr('hED);
        `assertSecond('hE0);
        `assertThird('h00);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertPc(16'h003a);

// jp 0812
    repeat (5) @(negedge clk);
        `assertInstr('h8D);
        `assertSecond('h08);
        `assertThird('h12);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertPc('h0812);

      #3
