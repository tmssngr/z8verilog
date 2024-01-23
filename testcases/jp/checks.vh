// jp never, 0
    repeat (6) @(negedge clk);
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
        `assertRegister(0, 'h03);

// L1: add 0, #FF
    repeat (5) @(negedge clk);
        `assertInstr('h06);
        `assertSecond('h00);
        `assertThird('hFF);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_ALU2_OP);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister(0, 'h02);
        // ch
        `assertFlags('b1000_0100);

// jp nz, L1
    repeat (5) @(negedge clk);
        `assertInstr('hED);
        `assertSecond('h00);
        `assertThird('h11);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
        `assertPc('h11);
    @(negedge clk);

// L1: add 0, #FF
    repeat (5) @(negedge clk);
        `assertInstr('h06);
        `assertSecond('h00);
        `assertThird('hFF);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_ALU2_OP);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister(0, 'h01);
        // ch
        `assertFlags('b1000_0100);

// jp nz, L1
    repeat (5) @(negedge clk);
        `assertInstr('hED);
        `assertSecond('h00);
        `assertThird('h11);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
        `assertPc('h11);
    @(negedge clk);

// L1: add 0, #FF
    repeat (5) @(negedge clk);
        `assertInstr('h06);
        `assertSecond('h00);
        `assertThird('hFF);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_ALU2_OP);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister(0, 'h00);
        // czh
        `assertFlags('b1100_0100);

// jp nz, L1
    repeat (5) @(negedge clk);
        `assertInstr('hED);
        `assertSecond('h00);
        `assertThird('h11);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
        `assertPc('h17);
    @(negedge clk);

// jmp 0
    repeat (5) @(negedge clk);
        `assertInstr('h8D);
        `assertSecond('h00);
        `assertThird('h0C);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertPc('h000C);

    #3
