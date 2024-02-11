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

	// RR
	chk_alu1(ALU1_RR, 8'hE0,
	         8'h10, 8'b1000_0100, FLAG_C | FLAG_S);

	// SRA
	chk_alu1(ALU1_SRA, 8'hE0,
	         8'h10, 8'b1100_0010, FLAG_S);

	// RRC
	chk_alu1(ALU1_RRC, 8'hE0,
	         8'h10, 8'b0110_0001, FLAG_NONE);
	chk_alu1(ALU1_RRC, 8'hE0,
	         8'h10, 8'b0011_0000, FLAG_C);
	chk_alu1(ALU1_RRC, 8'hE0,
	         8'h10, 8'b1001_1000, FLAG_S);

	// COM
	chk_alu1(ALU1_COM, 8'hE0,
	         8'h10, 8'b0110_0111, FLAG_NONE);

	// RL
	chk_alu1(ALU1_RL, 8'hE0,
	         8'h10, 8'b1100_1110, FLAG_S);
	chk_alu1(ALU1_RL, 8'hE0,
	         8'h10, 8'b1001_1101, FLAG_C | FLAG_S);

	// RLC
	chk_alu1(ALU1_RLC, 8'hE0,
	         8'h10, 8'b0011_1011, FLAG_C);
	chk_alu1(ALU1_RLC, 8'hE0,
	         8'h10, 8'b0111_0111, FLAG_NONE);
	chk_alu1(ALU1_RLC, 8'hE0,
	         8'h10, 8'b1110_1110, FLAG_S);

	chk_jp(16'h000C);
