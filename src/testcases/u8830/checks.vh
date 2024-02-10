    chk_srp(0);

	chk_ld_r_IM(4'h3, 8'h0F,
	            8'h03);

	chk_nop();
        `assertRegister('h03, 'h0F);


	chk_alu2_R_IM(ALU2_TM, 8'hE3, 8'b0000_0100,
	              8'h03, 8'h0F, FLAG_NONE);


	chk_ld_r_IM(4'h3, 8'hFF,
	            8'h03);

	chk_jr_true(JC_NZ, 8'h05,
	            16'h001d);

// M_001D:
	chk_ld_R_IM(P01M, 8'hB6);
        `assert(uut.proc.p01m, 'hB6);

	chk_ld_R_IM(P3M, 8'h08);
        `assert(uut.proc.p3m, 'h08);


	chk_ld_r_IM(4'h4, 8'h08,
	            8'h04);
	chk_ld_r_IM(4'h5, 8'h12,
	            8'h05);
        `assertRegister('h04, 'h08);
        `assertRegister('h05, 'h12);

    chk_ldc_r_Irr(4'h6, 4'h4,
                  8'h06, 16'h0812, 8'h00);


	chk_alu1(ALU1_COM, 8'hE6,
	         8'h06, 8'hFF, FLAG_S);

	chk_ldc_Irr_r(4'h4, 4'h6,
	              8'h06, 16'h0812, 8'hFF);
        `assertRom(16'h0812, 8'h00);
        `assertRegister(8'h06, 8'hFF);

    chk_ldc_r_Irr(4'h7, 4'h4,
                  8'h07, 16'h0812, 8'h00);
        `assertRegister(8'h06, 8'hFF);
        `assertRegister(8'h07, 8'h00);


	chk_alu1(ALU1_COM, 8'hE6,
	         8'h06, 8'h00, FLAG_Z);

	chk_ldc_Irr_r(4'h4, 4'h6,
	              8'h06, 16'h0812, 8'h00);
        `assertRegister(8'h06, 8'h00);

	chk_alu2_r_r(ALU2_XOR, 6, 7,
	             8'h06, 8'h00, FLAG_Z);

	chk_srp(4'hF);

	chk_jp_false(JC_NZ, 16'hE000);

	chk_jp(16'h0812);
