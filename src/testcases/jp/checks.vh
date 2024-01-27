    @(negedge clk);

    chk_srp(2);

// jp never, 0
    repeat (5) @(negedge clk);
        `assertInstr('h0D);
        `assertSecond('hFF);
        `assertThird('hFE);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);


	chk_ld_r_IM(4'h0, 8'h03,
	            8'h20);

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


	chk_ld_r_IM(4'h0, 8'h00,
	            8'h20);

	chk_ld_r_IM(4'h1, 8'h20,
	            8'h21);

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
	chk_jp(16'h000C);

    #3
