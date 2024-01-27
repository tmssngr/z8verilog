    @(negedge clk);
// srp 20
    repeat (3) @(negedge clk);
        `assertInstr('h31);
        `assertSecond('h20);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assert(uut.proc.rp, 'h2);

// jp never, 0
    repeat (5) @(negedge clk);
        `assertInstr('h0D);
        `assertSecond('hFF);
        `assertThird('hFE);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);

// ld r0, #3
    repeat (3) @(negedge clk);
        `assertInstr('h0C);
        `assertSecond('h03);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister(8'h20, 'h03);

// L1: add 0, #FF
    repeat (5) @(negedge clk);
        `assertInstr('h06);
        `assertSecond('h20);
        `assertThird('hFF);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_ALU2_OP);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister(8'h20, 'h02);
        // ch
        `assertFlags('b1000_0100);

// jp nz, L1
    repeat (5) @(negedge clk);
        `assertInstr('hED);
        `assertSecond('h00);
        `assertThird('h13);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
        `assertPc('h13);
    @(negedge clk);

// L1: add 0, #FF
    repeat (5) @(negedge clk);
        `assertInstr('h06);
        `assertSecond('h20);
        `assertThird('hFF);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_ALU2_OP);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister(8'h20, 'h01);
        // ch
        `assertFlags('b1000_0100);

// jp nz, L1
    repeat (5) @(negedge clk);
        `assertInstr('hED);
        `assertSecond('h00);
        `assertThird('h13);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
        `assertPc('h13);
    @(negedge clk);

// L1: add 0, #FF
    repeat (5) @(negedge clk);
        `assertInstr('h06);
        `assertSecond('h20);
        `assertThird('hFF);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_ALU2_OP);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister(8'h20, 'h00);
        // czh
        `assertFlags('b1100_0100);

// jp nz, L1
    repeat (5) @(negedge clk);
        `assertInstr('hED);
        `assertSecond('h00);
        `assertThird('h13);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
        `assertPc('h19);
    @(negedge clk);

// ld r0, #0
    repeat (3) @(negedge clk);
        `assertInstr('h0C);
        `assertSecond('h00);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister(8'h20, 'h00);

// ld r1, #20
    repeat (3) @(negedge clk);
        `assertInstr('h1C);
        `assertSecond('h20);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister(8'h21, 'h20);

// jp @r0
    repeat (3) @(negedge clk);
        `assertInstr('h30);
        `assertSecond('he0);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_JP1);
    @(negedge clk);
        `assert(uut.proc.addr[15:8], 8'h00);
        `assertState(STATE_JP2);
    @(negedge clk);
        `assert(uut.proc.addr, 16'h0020);
        `assertState(STATE_JP3);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertPc(16'h0020);

// jmp 0
    repeat (5) @(negedge clk);
        `assertInstr('h8D);
        `assertSecond('h00);
        `assertThird('h0C);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertPc('h000C);

    #3
