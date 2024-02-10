    chk_srp(0);

	chk_ld_r_IM(4'h4, 8'h05,
	            8'h04);

	chk_ld_r_IM(4'h2, 8'b1,
	            8'h02);

// L1:
	chk_alu1(ALU1_RL, 8'hE2,
	         8'h02, 8'b10, FLAG_NONE);

	chk_djnz_true(4'h4, 8'hFC,
	              8'h04, 8'h04, 16'h0012);

// L1:
	chk_alu1(ALU1_RL, 8'hE2,
	         8'h02, 8'b100, FLAG_NONE);

	chk_djnz_true(4'h4, 8'hFC,
	              8'h04, 8'h03, 16'h0012);

// L1
	chk_alu1(ALU1_RL, 8'hE2,
	         8'h02, 8'b1000, FLAG_NONE);

	chk_djnz_true(4'h4, 8'hFC,
	              8'h04, 8'h02, 16'h0012);

// L1:
	chk_alu1(ALU1_RL, 8'hE2,
	         8'h02, 8'b1_0000, FLAG_NONE);

	chk_djnz_true(4'h4, 8'hFC,
	              8'h04, 8'h01, 16'h0012);

// L1:
	chk_alu1(ALU1_RL, 8'hE2,
	         8'h02, 8'b10_0000, FLAG_NONE);

	chk_djnz_false(4'h4, 8'hFC,
	              8'h04, 16'h0016);

// jp 0812
	chk_jr(8'hF4,
	       16'h000C);
