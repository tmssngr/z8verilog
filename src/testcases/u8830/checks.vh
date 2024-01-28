    @(negedge clk);

    chk_srp(0);

	chk_ld_r_IM(4'h3, 8'h0F,
	            8'h03);

// nop
    repeat (2) @(negedge clk);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);

// tm r3, #0b0000_0100
    repeat (5) @(negedge clk);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_ALU2_OP);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h03, 'h0F);


	chk_ld_r_IM(4'h3, 8'hFF,
	            8'h03);

// jr nz, M_001D
    repeat (3) @(negedge clk);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
        `assertPc('h1D);
    @(negedge clk);

// M_001D:
// ld P01M, #B6
	chk_ld_R_IM(8'hF8, 8'hB6);
        `assert(uut.proc.p01m, 'hB6);

// ld P3M, #8
    repeat (5) @(negedge clk);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        //`assert(uut.proc.p3m, 'h08); //TODO


	chk_ld_r_IM(4'h4, 8'h08,
	            8'h04);
	chk_ld_r_IM(4'h5, 8'h12,
	            8'h05);
        `assertRegister('h04, 'h08);
        `assertRegister('h05, 'h12);

// ldc r6, Irr4
    repeat (3) @(negedge clk);
        `assertState(STATE_DECODE);
    @(negedge clk);
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

// com r6
    repeat (3) @(negedge clk);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_ALU1_OP);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister(8'h06, 8'hFF);

// ldc Irr4, r6
    repeat (3) @(negedge clk);
        `assertState(STATE_DECODE);
    @(negedge clk);
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
    repeat (3) @(negedge clk);
        `assertState(STATE_DECODE);
    @(negedge clk);
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
        `assertRegister(8'h07, 8'h00);

// com r6
    repeat (3) @(negedge clk);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_ALU1_OP);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister(8'h06, 8'h00);

// ldc Irr4, r6
    repeat (3) @(negedge clk);
        `assertState(STATE_DECODE);
    @(negedge clk);
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

// xor r6, r7
    repeat (3) @(negedge clk);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_ALU2_OP);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister(8'h06, 8'h00);
        `assertFlags('b0100_0000);


	chk_srp(4'hF);

	chk_jp_false(JC_NZ, 16'hE000);

	chk_jp(16'h0812);
