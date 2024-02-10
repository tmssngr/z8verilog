	chk_srp(3);

	chk_ld_r_IM(4'h0, 8'h03,
	            8'h30);

// L1
	chk_nop();

	chk_djnz_true(4'h0, 8'hFD,
	              8'h30, 8'h02, 16'h0010);

// L1
	chk_nop();

	chk_djnz_true(4'h0, 8'hFD,
	              8'h30, 8'h01, 16'h0010);

// L1
	chk_nop();

	chk_djnz_false(4'h0, 8'hFD,
	               8'h30, 16'h0013);

// jr L0
	chk_jr(8'hF7,
	       16'h000C);
