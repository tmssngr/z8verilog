    @(negedge clk);

	chk_ld_R_IM(8'h10, 8'h01);
	chk_ld_R_IM(8'h11, 8'h02);
        `assertRegister('h10, 'h01);
        `assertRegister('h11, 'h02);
        `assertFlags('b0000_0000);

	chk_incw(8'h10,
	         16'h0103, 8'b0000_0000);

	chk_decw(8'h10,
	         16'h0102, 8'b0000_0000);


	chk_ld_R_IM(8'h11, 8'h7F);
        `assertRegister('h10, 'h01);
        `assertRegister('h11, 'h7F);
        `assertFlags('b0000_0000);

	chk_incw(8'h10,
	         16'h0180, 8'b0000_0000);

	chk_decw(8'h10,
	         16'h017F, 8'b0000_0000);


	chk_ld_R_IM(8'h11, 8'hFF);
        `assertRegister('h10, 'h01);
        `assertRegister('h11, 'hFF);

	chk_incw(8'h10,
	         16'h0200, 8'b0000_0000);

	chk_decw(8'h10,
	         16'h01FF, 8'b0000_0000);


	chk_ld_R_IM(8'h10, 8'hFF);
        `assertRegister('h10, 'hFF);
        `assertRegister('h11, 'hFF);

	chk_incw(8'h10,
	         16'h0000, 8'b0100_0000); // z

	chk_incw(8'h10,
	         16'h0001, 8'b0000_0000);

	chk_decw(8'h10,
	         16'h0000, 8'b0100_0000); // z

	chk_decw(8'h10,
	         16'hFFFF, 8'b0010_0000); // s


	chk_jp(16'h000C);
