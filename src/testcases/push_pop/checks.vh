    @(negedge clk);

    chk_srp(2);

	chk_ld_r_IM(4'h0, 8'h12,
	            8'h20);
	chk_ld_r_IM(4'h1, 8'h34,
	            8'h21);
        `assertRegister('h20, 'h12);
        `assertRegister('h21, 'h34);

	chk_ld_R_IM(8'hFF, 8'h80);
        `assert(uut.proc.sp, 'h80);

// push r0
	chk_2byteOp(8'h70, 8'hE0);
        `assert(uut.proc.register, 'h20);
        `assertState(STATE_PUSH_I1);
    @(negedge clk);
        `assertState(STATE_PUSH_I2);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assert(uut.proc.sp, 'h7F);
        `assertRegister('h7F, 'h12);

// push r1
	chk_2byteOp(8'h70, 8'hE1);
        `assert(uut.proc.register, 'h21);
        `assertState(STATE_PUSH_I1);
    @(negedge clk);
        `assertState(STATE_PUSH_I2);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assert(uut.proc.sp, 'h7E);
        `assertRegister('h7E, 'h34);
        `assertRegister('h7F, 'h12);

	chk_pop(8'hE0,
	        8'h20, 8'h34, 16'h007F);

	chk_pop(8'hE1,
	        8'h21, 8'h12, 16'h0080);


	chk_ld_r_IM(4'h2, 8'h20,
	            8'h22);
        `assertRegister('h20, 'h34);
        `assertRegister('h21, 'h12);
        `assertRegister('h22, 'h20);

// push @22
	chk_2byteOp(8'h71, 8'h22);
        `assert(uut.proc.register, 'h20);
        `assertState(STATE_PUSH_I1);
    @(negedge clk);
        `assertState(STATE_PUSH_I2);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assert(uut.proc.sp, 'h7F);
        `assertRegister('h7F, 'h34);


	chk_ld_r_IM(4'h2, 8'h24,
	            8'h22);
        `assertRegister('h20, 'h34);
        `assertRegister('h21, 'h12);
        `assertRegister('h22, 'h24);

	chk_pop_IR(8'h22,
	           8'h24, 8'h34, 16'h0080);
        `assertRegister('h24, 'h34);


	chk_jp(16'h000C);
