    @(negedge clk);

// ld P01M, #92
	chk_ld_R_IM(8'hF8, 8'h92);

// clr SPH
	chk_2byteOp(8'hB0, 8'hFE);
        `assertState(STATE_ALU1_OP);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assert(uut.proc.sp[15:8], 'h00);

// clr SPL
	chk_2byteOp(8'hB0, 8'hFF);
        `assertState(STATE_ALU1_OP);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assert(uut.proc.sp[7:0], 'h00);

// call L1_
	chk_call_extern(16'h002C,
	                16'h0016, 16'hFFFE);

	chk_srp(2);

	chk_ret_extern(16'h0016, 16'h0000);


	chk_ld_r_IM(4'h0, 8'h00,
	            8'h20);
	chk_ld_r_IM(4'h1, 8'h2C,
	            8'h21);
        `assertRegister('h20, 'h00);
        `assertRegister('h21, 'h2C);

// call @r0
	chk_call_IRR_extern(8'hE0,
	                    16'h002C, 16'h001C, 16'hFFFE);

	chk_srp(2);

	chk_ret_extern(16'h001C, 16'h0000);


	chk_ld_r_IM(4'h0, 8'h00,
	            8'h20);
	chk_ld_r_IM(4'h1, 8'h0C,
	            8'h21);
	chk_ld_r_IM(4'h2, 8'hA5,
	            8'h22);
        `assertRegister('h20, 'h00);
        `assertRegister('h21, 'h0C);
        `assertRegister('h22, 'hA5);

    chk_push_extern(8'hE1,
                    8'h21, 8'h0C, 16'hFFFF);
    chk_push_extern(8'hE0,
                    8'h20, 8'h00, 16'hFFFE);
    chk_push_extern(8'hE2,
                    8'h22, 8'hA5, 16'hFFFD);

    chk_iret_extern(16'h000C, 16'h0000, 8'b1010_0101);

    #3
