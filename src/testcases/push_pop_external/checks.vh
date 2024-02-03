    @(negedge clk);

    chk_srp(2);

	chk_ld_R_IM(P01M, 8'h92);

// clr SPH
	repeat (3) @(negedge clk);
        `assertInstr('hB0);
        `assertSecond('hFE);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_ALU1_OP);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assert(uut.proc.sp[15:8], 'h00);

// clr SPL
	repeat (3) @(negedge clk);
        `assertInstr('hB0);
        `assertSecond('hFF);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_ALU1_OP);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assert(uut.proc.sp[7:0], 'h00);


	chk_ld_r_IM(4'h0, 8'h12,
	            8'h20);

// push r0
    repeat (3) @(negedge clk);
        `assertInstr('h70);
        `assertSecond('hE0);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assert(uut.proc.register, 'h20);
        `assertState(STATE_PUSH_E1);
    @(negedge clk);
        `assert(uut.proc.sp, 16'hFFFF);
        `assertState(STATE_PUSH_E2);
    @(negedge clk);
        `assertState(STATE_PUSH_E3);
    @(negedge clk);
        `assert(uut.proc.aluA, 8'h12);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRam(16'hFFFF, 'h12);


	chk_pop(8'hE1,
	        8'h21, 8'h12, 16'h0000);
        `assertRegister('h20, 'h12);
        `assertRegister('h21, 'h12);


	chk_jp(16'h000C);
