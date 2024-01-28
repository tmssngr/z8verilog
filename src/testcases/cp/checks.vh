    @(negedge clk);

    chk_srp(2);

	chk_ld_r_IM(4'h0, 8'h09,
	            8'h20);

	chk_ld_r_IM(4'h1, 8'h01,
	            8'h21);

	chk_ld_r_IM(4'h2, 8'h20,
	            8'h22);
        `assertRegister('h20, 'h09);
        `assertRegister('h21, 'h01);
        `assertRegister('h22, 'h20);

	chk_alu2_r_Ir(ALU2_CP, 0, 2,
	              .expDst(8'h20), .expResult(8'h09), .expFlags(8'b0100_0000)); //z
        `assertRegister('h20, 'h09);
        `assertRegister('h21, 'h01);
        `assertRegister('h22, 'h20);

	chk_ld_r_IM(4'h2, 8'h21,
	            8'h22);
        `assertRegister('h20, 'h09);
        `assertRegister('h21, 'h01);
        `assertRegister('h22, 'h21);

	chk_alu2_r_Ir(ALU2_CP, 0, 2,
	              .expDst(8'h20), .expResult(8'h09), .expFlags(8'b0000_0000));
        `assertRegister('h20, 'h09);
        `assertRegister('h21, 'h01);
        `assertRegister('h22, 'h21);

	chk_jp(16'h000C);
