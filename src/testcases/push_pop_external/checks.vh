    chk_srp(2);

	chk_ld_R_IM(P01M, 8'h92);

	chk_alu1(ALU1_CLR, SPH,
	         8'hFE, 8'h00, FLAG_NONE);
	chk_alu1(ALU1_CLR, SPL,
	         8'hFF, 8'h00, FLAG_NONE);


	chk_ld_r_IM(4'h0, 8'h12,
	            8'h20);

	chk_push_extern(8'hE0,
	                8'h20, 8'h12, 16'hFFFF);

	chk_pop(8'hE1,
	        8'h21, 8'h12, 16'h0000);
        `assertRegister('h20, 'h12);
        `assertRegister('h21, 'h12);


	chk_jp(16'h000C);
