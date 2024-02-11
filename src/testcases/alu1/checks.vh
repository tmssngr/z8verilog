	chk_srp(1);

	chk_ld_r_IM(4'h0, 8'h09,
	            8'h10);
	chk_ld_r_IM(4'h1, 8'h10,
	            8'h11);
        `assertRegister(8'h10, 8'h09);
        `assertRegister(8'h11, 8'h10);

	chk_alu1(ALU1_SWAP, 8'hE0,
	         8'h10, 8'h90, FLAG_S);
        `assertRegister(8'h10, 8'h90);

	chk_alu1_IR(ALU1_SWAP, 8'hE1,
	            8'h10, 8'h09, FLAG_NONE);
        `assertRegister(8'h10, 8'h09);

	chk_jp(16'h000C);
