
    chk_srp(2);

	chk_ld_r_IM(4'h0, 8'h00,
	            8'h20);

	chk_ld_r_IM(4'h1, 8'h02,
	            8'h21);

	chk_ld_r_IM(4'h2, 8'h24,
	            8'h22);
        `assertRegister('h20, 'h00);
        `assertRegister('h21, 'h02);
        `assertRegister('h22, 'h24);
        `assertRom(16'h0002, 8'h08);

    chk_ldci_Ir_Irr(4'h2, 4'h0,
                    8'h22, 8'h20, 8'h24, 16'h0002, 8'h08,
                    16'h0003);
        `assertRegister(8'h20, 8'h00);
        `assertRegister(8'h21, 8'h03);
        `assertRegister(8'h22, 8'h25);
        `assertRegister(8'h24, 8'h08);

        `assertRom(16'h0003, 8'h03);
    chk_ldci_Ir_Irr(4'h2, 4'h0,
                    8'h22, 8'h20, 8'h25, 16'h0003, 8'h03,
                    16'h0004);
        `assertRegister(8'h20, 8'h00);
        `assertRegister(8'h21, 8'h04);
        `assertRegister(8'h22, 8'h26);
        `assertRegister(8'h24, 8'h08);
        `assertRegister(8'h25, 8'h03);


	chk_ld_r_IM(4'h0, 8'hFF,
	            8'h20);
	chk_ld_r_IM(4'h1, 8'hFE,
	            8'h21);
	chk_ld_r_IM(4'h2, 8'h24,
	            8'h22);
        `assertRegister(8'h20, 8'hFF);
        `assertRegister(8'h21, 8'hFE);
        `assertRegister(8'h22, 8'h24);
        `assertRegister(8'h24, 8'h08);

    chk_ldci_Irr_Ir(4'h0, 4'h2,
                    8'h20, 8'h22, 8'h24, 16'hFFFE, 8'h08, 16'hFFFF);
        `assertRegister(8'h20, 8'hFF);
        `assertRegister(8'h21, 8'hFF);
        `assertRegister(8'h22, 8'h25);
    chk_ldci_Irr_Ir(4'h0, 4'h2,
                    8'h20, 8'h22, 8'h25, 16'hFFFF, 8'h03, 16'h0000);
        `assertRegister(8'h20, 8'h00);
        `assertRegister(8'h21, 8'h00);
        `assertRegister(8'h22, 8'h26);

	chk_jp(16'h000C);
