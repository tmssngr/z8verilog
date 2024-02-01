    @(negedge clk);

	chk_srp(2);

	chk_ld_r_IM(4'h0, 8'h09,
	            8'h20);

	chk_ld_r_IM(4'h1, 8'h01,
	            8'h21);
        `assertRegister('h20, 'h09);
        `assertRegister('h21, 'h01);

	chk_alu2_r_r(ALU2_ADD, 0, 1,
	             8'h20, 8'h0A, 8'b0000_0000);
        `assertRegister('h20, 'h0A);
        `assertRegister('h21, 'h01);

	chk_ld_r_IM(4'h1, 8'h06,
	            8'h21);
        `assertRegister('h20, 'h0A);
        `assertRegister('h21, 'h06);

	chk_alu2_r_r(ALU2_ADD, 0, 1,
	             8'h20, 8'h10, 8'b0000_0100); // h
        `assertRegister('h20, 'h10);
        `assertRegister('h21, 'h06);

	chk_ld_r_IM(4'h1, 8'h80,
	            8'h21);
        `assertRegister('h20, 'h10);
        `assertRegister('h21, 'h80);

	chk_alu2_r_r(ALU2_ADD, 0, 1,
	             8'h20, 8'h90, 8'b0010_0000); // s
        `assertRegister('h20, 'h90);
        `assertRegister('h21, 'h80);


	chk_ld_r_IM(4'h1, 8'h70,
	            8'h21);
        `assertRegister('h20, 'h90);
        `assertRegister('h21, 'h70);

	chk_alu2_R_R(ALU2_ADD, 8'hE0, 8'hE1,
	             8'h20, 8'h00, 8'b1100_0000); // cz
        `assertRegister('h20, 'h00);
        `assertRegister('h21, 'h70);


	chk_ld_r_IM(4'h0, 8'hFF,
	            8'h20);

	chk_ld_r_IM(4'h1, 8'hFF,
	            8'h21);

	chk_alu2_r_r(ALU2_ADD, 1, 0,
	             8'h21, 8'hFE, 8'b1010_0100); // csh
        `assertRegister('h20, 'hFF);
        `assertRegister('h21, 'hFE);

    chk_ld_r_IM(4'h0, 45,
                8'h20);
    chk_ld_r_IM(1, 56,
                8'h21);
    chk_ld_r_IM(2, 8'h20,
                8'h22);
        `assertRegister('h20, 8'h2D);
        `assertRegister('h21, 8'h38);
        `assertRegister('h22, 8'h20);
    chk_alu2_R_IR(ALU2_SUB, 8'hE1, 8'hE2,
                  8'h21, 8'd11, 8'b0000_1100); // dh
        `assertRegister('h20, 8'h2D);
        `assertRegister('h21, 8'h0B);
        `assertRegister('h22, 8'h20);

	chk_jp(16'h000C);
