// jr never, 0
    @(negedge clk);
    repeat (3) @(negedge clk);
        `assertInstr('h0B);
        `assertSecond('hFE);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
        `assertPc('h000E);
    @(negedge clk);

// ld r0, #3
    repeat (3) @(negedge clk);
        `assertInstr('h0C);
        `assertSecond('h03);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
        `assertPc('h0010);
    @(negedge clk);
        `assertRegister(0, 'h03);

// L1: add 0, #ff
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

// jr nz, L1
    repeat (3) @(negedge clk);
        `assertInstr('hEB);
        `assertSecond('hFB);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
        `assertPc('h0010);
    @(negedge clk);

// L1: add 0, #ff
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

// jr nz, L1
    repeat (3) @(negedge clk);
        `assertInstr('hEB);
        `assertSecond('hFB);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
        `assertPc('h0010);
    @(negedge clk);

// L1: add 0, #ff
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

// jr nz, L1
    repeat (3) @(negedge clk);
        `assertInstr('hEB);
        `assertSecond('hFB);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
        `assertPc('h0015);
    @(negedge clk);

// jr L0
    repeat (3) @(negedge clk);
        `assertInstr('h8B);
        `assertSecond('hF5);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
        `assertPc('h000C);

    #3
