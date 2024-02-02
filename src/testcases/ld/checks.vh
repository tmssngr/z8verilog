    @(negedge clk);

	chk_srp(2);

	chk_ld_r_IM(4'h0, 8'h09,
	            8'h20);
		`assertRegister(8'h20, 8'h09);

	chk_ld_R_R(8'hE1, 8'hE0,
	           8'h21, 8'h09);
		`assertRegister(8'h20, 8'h09);
		`assertRegister(8'h21, 8'h09);

	chk_ld_r_IM(4'h1, 8'h22,
	            8'h21);
		`assertRegister(8'h20, 8'h09);
		`assertRegister(8'h21, 8'h22);

	chk_ld_IR_R(8'hE1, 8'hE0,
	            8'h22, 8'h09);
		`assertRegister(8'h20, 8'h09);
		`assertRegister(8'h21, 8'h22);
		`assertRegister(8'h22, 8'h09);

	chk_ld_R_IR(8'hE1, 8'hE1,
	            8'h21, 8'h09);
		`assertRegister(8'h20, 8'h09);
		`assertRegister(8'h21, 8'h09);
		`assertRegister(8'h22, 8'h09);

	chk_ld_r_IM(4'h1, 8'h80,
	            8'h21);
		`assertRegister(8'h21, 8'h80);
	chk_ld_r_R(4'h2, 8'h21,
	           8'h22, 8'h80);
		`assertRegister(8'h21, 8'h80);
		`assertRegister(8'h22, 8'h80);
	chk_ld_R_r(8'h30, 4'h0,
	           8'h30, 8'h09);
		`assertRegister(8'h30, 8'h09);

	chk_ld_r_IM(4'h0, 8'h30,
	            8'h20);
		`assertRegister(8'h20, 8'h30);
	chk_ld_r_Ir(4'h3, 4'h0,
	            8'h23, 8'h09);
		`assertRegister(8'h20, 8'h30);
		`assertRegister(8'h23, 8'h09);
	chk_ld_Ir_r(4'h0, 4'h1,
	            8'h30, 8'h80);
		`assertRegister(8'h30, 8'h80);
	chk_ld_IR_IM(8'hE0, 8'hFF,
	             8'h30);
		`assertRegister(8'h30, 8'hFF);

	chk_jp(16'h000C);
