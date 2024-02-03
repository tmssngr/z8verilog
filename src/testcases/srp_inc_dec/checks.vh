    @(negedge clk);

    chk_srp(1);

	chk_ld_r_IM(4'h0, 8'h09,
	            8'h10);

	chk_inc_r(4'h0,
	          8'h10, 8'h0A, FLAG_NONE);

	chk_alu1(ALU1_DEC, 8'h10,
	         8'h10, 8'h09, FLAG_NONE);


	chk_ld_r_IM(4'h0, 8'h7F,
	            8'h10);
        `assertRegister('h10, 'h7f);

	chk_alu1(ALU1_INC, 8'h10,
	         8'h10, 8'h80, FLAG_S | FLAG_V);

	chk_alu1(ALU1_DEC, 8'h10,
	         8'h10, 8'h7F, FLAG_V);


	chk_ld_r_IM(4'h0, 8'hFE,
	            8'h10);
        `assertRegister('h10, 'hFE);

	chk_alu1(ALU1_INC, 8'h10,
	         8'h10, 8'hFF, FLAG_S);
	chk_alu1(ALU1_INC, 8'hE0,
	         8'h10, 8'h00, FLAG_Z);

	chk_alu1(ALU1_DEC, 8'hE0,
	         8'h10, 8'hFF, FLAG_S);

	chk_alu1(ALU1_DEC, 8'h10,
	         8'h10, 8'hFE, FLAG_S);


	chk_ld_r_IM(4'h1, 8'h10,
	            8'h11);
        `assertRegister('h10, 'hFE);
        `assertRegister('h11, 'h10);

	chk_alu1_IR(ALU1_DEC, 8'hE1,
	            8'h10, 8'hFD, FLAG_S);
        `assertRegister('h10, 'hFD);
        `assertRegister('h11, 'h10);


	chk_jp(16'h000C);
