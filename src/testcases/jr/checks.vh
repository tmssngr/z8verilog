    @(negedge clk);

	chk_srp(7);

	chk_jr_false(JC_NEVER, 8'hFC,
	             16'h0010);


	chk_ld_r_IM(4'h0, 8'h03,
	            8'h70);

// L1
	chk_alu2_R_IM(ALU2_ADD, 8'h70, 8'hFF,
	              8'h70, 8'h02, FLAG_C | FLAG_H);

	chk_jr_true(JC_NZ, 8'hFB,
	            16'h0012);

// L1
	chk_alu2_R_IM(ALU2_ADD, 8'h70, 8'hFF,
	              8'h70, 8'h01, FLAG_C | FLAG_H);

	chk_jr_true(JC_NZ, 8'hFB,
	            16'h0012);

// L1
	chk_alu2_R_IM(ALU2_ADD, 8'h70, 8'hFF,
	              8'h70, 8'h00, FLAG_C | FLAG_Z | FLAG_H);

	chk_jr_false(JC_NZ, 8'hFB,
	             16'h0017);

// jr L0
	chk_jr(8'hF3,
	       16'h000C);
