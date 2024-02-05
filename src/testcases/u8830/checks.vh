    @(negedge clk);

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
// ld P01M, #B6
	chk_ld_R_IM(8'hF8, 8'hB6);
        `assert(uut.proc.p01m, 'hB6);

// ld P3M, #8
	chk_ld_R_IM(8'hF7, 8'h08);
        `assert(uut.proc.p3m, 'h08);


	chk_ld_r_IM(4'h4, 8'h08,
	            8'h04);
	chk_ld_r_IM(4'h5, 8'h12,
	            8'h05);
        `assertRegister('h04, 'h08);
        `assertRegister('h05, 'h12);

// ldc r6, Irr4
	chk_2byteOp(8'hC2, 8'h64);
        `assertState(STATE_LDC_READ1);
    @(negedge clk);
        `assertState(STATE_LDC_READ2);
    @(negedge clk);
        `assertState(STATE_READ_MEM1);
    @(negedge clk);
        `assertState(STATE_READ_MEM2);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister(8'h06, 8'h00);


	chk_alu1(ALU1_COM, 8'hE6,
	         8'h06, 8'hFF, FLAG_S);

// ldc Irr4, r6
	chk_2byteOp(8'hD2, 8'h64);
        `assertState(STATE_LDC_WRITE1);
    @(negedge clk);
        `assertState(STATE_LDC_WRITE2);
    @(negedge clk);
        `assertState(STATE_LDC_WRITE3);
    @(negedge clk);
        `assertState(STATE_WRITE_MEM);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRom(16'h0812, 8'h00);
        `assertRegister(8'h06, 8'hFF);

// ldc r7, Irr4
	chk_2byteOp(8'hC2, 8'h74);
        `assertState(STATE_LDC_READ1);
    @(negedge clk);
        `assertState(STATE_LDC_READ2);
    @(negedge clk);
        `assertState(STATE_READ_MEM1);
    @(negedge clk);
        `assertState(STATE_READ_MEM2);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister(8'h06, 8'hFF);
        `assertRegister(8'h07, 8'h00);


	chk_alu1(ALU1_COM, 8'hE6,
	         8'h06, 8'h00, FLAG_Z);

// ldc Irr4, r6
	chk_2byteOp(8'hD2, 8'h64);
        `assertState(STATE_LDC_WRITE1);
    @(negedge clk);
        `assertState(STATE_LDC_WRITE2);
    @(negedge clk);
        `assertState(STATE_LDC_WRITE3);
    @(negedge clk);
        `assertState(STATE_WRITE_MEM);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister(8'h06, 8'h00);

	chk_alu2_r_r(ALU2_XOR, 6, 7,
	             8'h06, 8'h00, FLAG_Z);

	chk_srp(4'hF);

	chk_jp_false(JC_NZ, 16'hE000);

	chk_jp(16'h0812);
