    @(negedge clk);

	chk_srp(7);

// jr never, 0
    repeat (3) @(negedge clk);
        `assertInstr('h0B);
        `assertSecond('hFC);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
        `assertPc('h0010);
    @(negedge clk);


	chk_ld_r_IM(4'h0, 8'h03,
	            8'h70);

// L1: add 70, #ff
    repeat (5) @(negedge clk);
        `assertInstr('h06);
        `assertSecond('h70);
        `assertThird('hFF);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_ALU2_OP);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister(8'h70, 'h02);
        // ch
        `assertFlags('b1000_0100);

// jr nz, L1
    repeat (3) @(negedge clk);
        `assertInstr('hEB);
        `assertSecond('hFB);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
        `assertPc('h0012);
    @(negedge clk);

// L1: add 0, #ff
    repeat (5) @(negedge clk);
        `assertInstr('h06);
        `assertSecond('h70);
        `assertThird('hFF);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_ALU2_OP);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister(8'h70, 'h01);
        // ch
        `assertFlags('b1000_0100);

// jr nz, L1
    repeat (3) @(negedge clk);
        `assertInstr('hEB);
        `assertSecond('hFB);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
        `assertPc('h0012);
    @(negedge clk);

// L1: add 0, #ff
    repeat (5) @(negedge clk);
        `assertInstr('h06);
        `assertSecond('h70);
        `assertThird('hFF);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_ALU2_OP);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister(8'h70, 'h00);
        // czh
        `assertFlags('b1100_0100);

// jr nz, L1
    repeat (3) @(negedge clk);
        `assertInstr('hEB);
        `assertSecond('hFB);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
        `assertPc('h0017);
    @(negedge clk);

// jr L0
    repeat (3) @(negedge clk);
        `assertInstr('h8B);
        `assertSecond('hF3);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
        `assertPc('h000C);

    #3
