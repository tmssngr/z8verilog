    @(negedge clk);

	chk_ld_R_IM(8'h10, 8'h01);
	chk_ld_R_IM(8'h11, 8'h02);
        `assertRegister('h10, 'h01);
        `assertRegister('h11, 'h02);
        `assertFlags(FLAG_NONE);

	chk_incw(8'h10,
	         16'h0103, FLAG_NONE);

	chk_decw(8'h10,
	         16'h0102, FLAG_NONE);


	chk_ld_R_IM(8'h11, 8'h7F);
        `assertRegister('h10, 'h01);
        `assertRegister('h11, 'h7F);
        `assertFlags(FLAG_NONE);

	chk_incw(8'h10,
	         16'h0180, FLAG_NONE);

	chk_decw(8'h10,
	         16'h017F, FLAG_NONE);


	chk_ld_R_IM(8'h11, 8'hFF);
        `assertRegister('h10, 'h01);
        `assertRegister('h11, 'hFF);

	chk_incw(8'h10,
	         16'h0200, FLAG_NONE);

	chk_decw(8'h10,
	         16'h01FF, FLAG_NONE);


	chk_ld_R_IM(8'h10, 8'hFF);
        `assertRegister('h10, 'hFF);
        `assertRegister('h11, 'hFF);

	chk_incw(8'h10,
	         16'h0000, FLAG_Z);

	chk_incw(8'h10,
	         16'h0001, FLAG_NONE);

	chk_decw(8'h10,
	         16'h0000, FLAG_Z);

	chk_decw(8'h10,
	         16'hFFFF, FLAG_S);


	chk_ld_R_IM(8'h12, 8'h10);
        `assertRegister('h10, 'hFF);
        `assertRegister('h11, 'hFF);
        `assertRegister('h12, 'h10);
        `assertFlags(FLAG_S);

// incw @12
    repeat (3) @(negedge clk);
        `assertInstr(8'hA1);
        `assertSecond(8'h12);
        `assertState(STATE_DECODE);
        // lower byte:
    @(negedge clk);
        `assert(uut.proc.aluMode, ALU1_INC);
        `assert(uut.proc.register, 8'h10);
        `assertState(STATE_ALU1_WORD1);
    @(negedge clk);
        `assert(uut.proc.aluMode, ALU1_INC);
        `assert(uut.proc.register, 8'h11);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 0);
        `assertState(STATE_ALU1_WORD2);
    @(negedge clk);
        `assertRegister(8'h11, 'h00);
        `assertFlags(FLAG_S); // unchanged
        // upper byte:
        `assert(uut.proc.aluMode, ALU1_INCW);
        `assert(uut.proc.register, 8'h10);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 1);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h10, 'h00);
        `assertFlags(FLAG_Z);

// decw @12
    repeat (3) @(negedge clk);
        `assertInstr(8'h81);
        `assertSecond(8'h12);
        `assertState(STATE_DECODE);
        // lower byte:
    @(negedge clk);
        `assert(uut.proc.aluMode, ALU1_DEC);
        `assert(uut.proc.register, 8'h10);
        `assertState(STATE_ALU1_WORD1);
    @(negedge clk);
        `assert(uut.proc.aluMode, ALU1_DEC);
        `assert(uut.proc.register, 8'h11);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 0);
        `assertState(STATE_ALU1_WORD2);
    @(negedge clk);
        `assertRegister(8'h11, 'hFF);
        `assertFlags(FLAG_Z); // unchanged
        // upper byte:
        `assert(uut.proc.aluMode, ALU1_DECW);
        `assert(uut.proc.register, 8'h10);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 1);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h10, 'hFF);
        `assertFlags(FLAG_S);


	chk_jp(16'h000C);
