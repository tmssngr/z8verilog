    @(negedge clk);

	chk_ld_R_IM(8'h10, 8'h01);
	chk_ld_R_IM(8'h11, 8'h02);
        `assertRegister('h10, 'h01);
        `assertRegister('h11, 'h02);
        `assertFlags('b0000_0000);

	chk_incw(8'h10,
	         16'h0103, 8'b0000_0000);

	chk_decw(8'h10,
	         16'h0102, 8'b0000_0000);


	chk_ld_R_IM(8'h11, 8'h7F);
        `assertRegister('h10, 'h01);
        `assertRegister('h11, 'h7F);
        `assertFlags('b0000_0000);

	chk_incw(8'h10,
	         16'h0180, 8'b0000_0000);

	chk_decw(8'h10,
	         16'h017F, 8'b0000_0000);


	chk_ld_R_IM(8'h11, 8'hFF);
        `assertRegister('h10, 'h01);
        `assertRegister('h11, 'hFF);

	chk_incw(8'h10,
	         16'h0200, 8'b0000_0000);

	chk_decw(8'h10,
	         16'h01FF, 8'b0000_0000);


	chk_ld_R_IM(8'h10, 8'hFF);
        `assertRegister('h10, 'hFF);
        `assertRegister('h11, 'hFF);

	chk_incw(8'h10,
	         16'h0000, 8'b0100_0000); // z

	chk_incw(8'h10,
	         16'h0001, 8'b0000_0000);

	chk_decw(8'h10,
	         16'h0000, 8'b0100_0000); // z

	chk_decw(8'h10,
	         16'hFFFF, 8'b0010_0000); // s


	chk_ld_R_IM(8'h12, 8'h10);
        `assertRegister('h10, 'hFF);
        `assertRegister('h11, 'hFF);
        `assertRegister('h12, 'h10);
        `assertFlags(8'b0010_0000);

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
        `assertFlags(8'b0010_0000); // unchanged
        // upper byte:
        `assert(uut.proc.aluMode, ALU1_INCW);
        `assert(uut.proc.register, 8'h10);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 1);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h10, 'h00);
        `assertFlags('b0100_0000); // z

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
        `assertFlags(8'b0100_0000); // unchanged
        // upper byte:
        `assert(uut.proc.aluMode, ALU1_DECW);
        `assert(uut.proc.register, 8'h10);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 1);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h10, 'hFF);
        `assertFlags('b0010_0000); // s


	chk_jp(16'h000C);
