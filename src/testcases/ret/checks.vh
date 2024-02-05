    @(negedge clk);

	// SPL
    chk_ld_R_IM(8'hFF, 8'h80);

// call L1_
	chk_call_intern(16'h0028,
	                16'h0012, 8'h7E);


	chk_srp(2);

	chk_ret_intern(16'h0012, 8'h80);


	chk_ld_r_IM(4'h0, 8'h00,
	            8'h20);
	chk_ld_r_IM(4'h1, 8'h28,
	            8'h21);
        `assertRegister('h20, 'h00);
        `assertRegister('h21, 'h28);

// call IRR0
	chk_call_IRR_intern(8'hE0,
	                    16'h0028, 16'h0018, 8'h7E);

	chk_srp(2);

	chk_ret_intern(16'h0018, 8'h80);


	chk_ld_r_IM(4'h0, 8'h00,
	            8'h20);
	chk_ld_r_IM(4'h1, 8'h0C,
	            8'h21);
	chk_ld_r_IM(4'h2, 8'hA5,
	            8'h22);
        `assertRegister('h20, 'h00);
        `assertRegister('h21, 'h0C);
        `assertRegister('h22, 'hA5);

// push r1
	chk_2byteOp(8'h70, 8'hE1);
        `assert(uut.proc.register, 'h21);
        `assertState(STATE_PUSH_I1);
    @(negedge clk);
        `assertState(STATE_PUSH_I2);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assert(uut.proc.sp, 'h7F);
        `assertRegister('h7F, 'h0C);

// push r0
	chk_2byteOp(8'h70, 8'hE0);
        `assert(uut.proc.register, 'h20);
        `assertState(STATE_PUSH_I1);
    @(negedge clk);
        `assertState(STATE_PUSH_I2);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assert(uut.proc.sp, 'h7E);
        `assertRegister('h7E, 'h00);
        `assertRegister('h7F, 'h0C);

// push r2
	chk_2byteOp(8'h70, 8'hE2);
        `assert(uut.proc.register, 'h22);
        `assertState(STATE_PUSH_I1);
    @(negedge clk);
        `assertState(STATE_PUSH_I2);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assert(uut.proc.sp, 'h7D);
        `assertRegister('h7D, 'hA5);
        `assertRegister('h7E, 'h00);
        `assertRegister('h7F, 'h0C);

    chk_iret_intern(16'h000C, 8'h80, 8'b1010_0101);

    #3
