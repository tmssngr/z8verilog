// ld P01M, #92
	chk_ld_R_IM(P01M, 8'h92);

	chk_alu1(ALU1_CLR, SPH,
	         8'hFE, 8'h00, FLAG_NONE);
	chk_alu1(ALU1_CLR, SPL,
	         8'hFF, 8'h00, FLAG_NONE);

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
