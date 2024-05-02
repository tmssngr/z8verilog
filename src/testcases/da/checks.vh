	chk_srp(1);

	chk_ld_r_IM(4'h0, 8'h09,
	            8'h10);

	chk_ld_r_IM(4'h1, 8'h01,
	            8'h11);

	chk_alu2_r_r(ALU2_ADD, 0, 1,
	             8'h10, 8'h0A, FLAG_NONE);
	chk_da(8'hE0,
	       8'h10, 8'h10, FLAG_NONE);
        `assertRegister('h10, 'h10);
        `assertRegister('h11, 'h01);


	chk_alu2_r_r(ALU2_SUB, 0, 1,
	             8'h10, 8'h0F, FLAG_D | FLAG_H);
	chk_da(8'hE0,
	       8'h10, 8'h09, FLAG_D | FLAG_H);
        `assertRegister('h10, 'h09);
        `assertRegister('h11, 'h01);


	chk_ld_r_IM(4'h1, 8'h09,
	            8'h11);
        `assertRegister('h10, 'h09);
        `assertRegister('h11, 'h09);

	chk_alu2_r_r(ALU2_ADD, 0, 1,
	             8'h10, 8'h12, FLAG_H);
	chk_da(8'h10,
	       8'h10, 8'h18, FLAG_H);
        `assertRegister('h10, 'h18);
        `assertRegister('h11, 'h09);


	chk_alu2_r_r(ALU2_SUB, 0, 1,
	             8'h10, 8'h0F, FLAG_D | FLAG_H);
	chk_da(8'h10,
	       8'h10, 8'h09, FLAG_D | FLAG_H);
        `assertRegister('h10, 'h09);
        `assertRegister('h11, 'h09);


	chk_ld_r_IM(4'h0, 8'h15,
	            8'h10);
	chk_ld_r_IM(4'h1, 8'h87,
	            8'h11);
        `assertRegister('h10, 'h15);
        `assertRegister('h11, 'h87);

	chk_alu2_r_r(ALU2_ADD, 0, 1,
	             8'h10, 8'h9C, FLAG_S);
	chk_da(8'h10,
	       8'h10, 8'h02, FLAG_C);
        `assertRegister('h10, 'h02);
        `assertRegister('h11, 'h87);


	chk_alu2_r_r(ALU2_SUB, 0, 1,
	             8'h10, 8'h7B, FLAG_C | FLAG_D | FLAG_H);
	chk_da(8'h10,
	       8'h10, 8'h15, FLAG_C | FLAG_D | FLAG_H);
        `assertRegister('h10, 'h15);
        `assertRegister('h11, 'h87);


	chk_ld_r_IM(4'h0, 8'h00,
	            8'h10);
	chk_ld_r_IM(4'h1, 8'h01,
	            8'h11);
        `assertRegister('h10, 'h00);
        `assertRegister('h11, 'h01);

	chk_alu2_r_r(ALU2_SUB, 0, 1,
	             8'h10, 8'hFF, FLAG_C | FLAG_S | FLAG_V | FLAG_D | FLAG_H);
	chk_da(8'h10,
	       8'h10, 8'h99, FLAG_C | FLAG_S | FLAG_V | FLAG_D | FLAG_H);
        `assertRegister('h10, 'h99);
        `assertRegister('h11, 'h01);


	chk_alu2_r_r(ALU2_ADD, 0, 1,
	             8'h10, 8'h9A, FLAG_S);
	chk_da(8'h10,
	       8'h10, 8'h00, FLAG_C | FLAG_Z);
        `assertRegister('h10, 'h00);
        `assertRegister('h11, 'h01);

	chk_ld_r_IM(4'h0, 8'h96,
	            8'h10);
        `assertRegister('h10, 'h96);
	chk_alu2_r_r(ALU2_ADD, 0, 0,
	             8'h10, 8'h2C, FLAG_C | FLAG_V);
	chk_da(8'hE0,
	       8'h10, 8'h92, FLAG_C | FLAG_S | FLAG_V);
        `assertRegister('h10, 'h92);


	chk_jp(16'h000C);
