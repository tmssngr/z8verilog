	chk_srp(2);

	chk_ld_r_IM(4'h0, 8'h00,
	            8'h20);
	chk_ld_r_IM(4'h1, 8'h0B,
	            8'h21);
        `assertRegister('h20, 'h00);
        `assertRegister('h21, 'h0B);

	chk_ldc_r_Irr(4'h2, 4'h0,
	              8'h22, 16'h000B, 8'h0F);
        `assertRegister(8'h20, 'h00);
        `assertRegister(8'h21, 'h0B);
        `assertRegister(8'h22, 'h0F);

// ROM
	chk_ld_r_IM(4'h0, 8'h08,
	            8'h20);
	chk_ld_r_IM(4'h1, 8'h12,
	            8'h21);
        `assertRegister(8'h20, 'h08);
        `assertRegister(8'h21, 'h12);
        `assertRegister(8'h22, 'h0F);

	chk_ldc_Irr_r(4'h0, 4'h2,
	              8'h22, 16'h0812, 8'h0F);
        `assertRom(16'h812, 8'h00); // remains as is (read-only)
        `assertRegister(8'h20, 'h08);
        `assertRegister(8'h21, 'h12);
        `assertRegister(8'h22, 'h0F);

// RAM
	chk_ld_r_IM(4'h0, 8'hFF,
	            8'h20);
	chk_ld_r_IM(4'h1, 8'h80,
	            8'h21);
        `assertRegister('h20, 'hFF);
        `assertRegister('h21, 'h80);

// ldc r2, Irr0
	chk_ldc_r_Irr(4'h2, 4'h0,
	              8'h22, 16'hFF80, 8'h00);
        `assertRegister(8'h20, 'hFF);
        `assertRegister(8'h21, 'h80);
        `assertRegister(8'h22, 'h00);

// inc 22
	chk_alu1(ALU1_INC, 8'h22,
	         8'h22, 8'h01, FLAG_NONE);
        `assertRegister(8'h20, 'hFF);
        `assertRegister(8'h21, 'h80);
        `assertRegister(8'h22, 'h01);

// ldc Irr0, r2
	chk_ldc_Irr_r(4'h0, 4'h2,
	              8'h22, 16'hFF80, 8'h01);
        `assertRam(16'hFF80, 8'h01);
        `assertRegister(8'h20, 'hFF);
        `assertRegister(8'h21, 'h80);
        `assertRegister(8'h22, 'h01);


	chk_jp(16'h000C);
