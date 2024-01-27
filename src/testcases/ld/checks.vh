    @(negedge clk);

	chk_srp(2);

	chk_ld_r_IM(4'h0, 8'h09,
	            8'h20);

// ld E1, E0
    repeat (5) @(negedge clk);
        `assertInstr('hE4);
        `assertSecond('hE0);
        `assertThird('hE1);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h20, 'h09);
        `assertRegister('h21, 'h09);

// jmp L0
	chk_jp(16'h000C);

    #3
