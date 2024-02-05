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

    chk_push_intern(8'hE1,
                    8'h21, 8'h0C, 8'h7F);
    chk_push_intern(8'hE0,
                    8'h20, 8'h00, 8'h7E);
    chk_push_intern(8'hE2,
                    8'h22, 8'hA5, 8'h7D);

    chk_iret_intern(16'h000C, 8'h80, 8'b1010_0101);

    #3
