    @(negedge clk);

	chk_ld_R_IM(8'h10, 8'h01);
	chk_ld_R_IM(8'h11, 8'h02);
        `assertRegister('h10, 'h01);
        `assertRegister('h11, 'h02);
        `assertFlags('b0000_0000);

// incw 10
    repeat (3) @(negedge clk);
        `assertInstr('hA0);
        `assertSecond('h10);
        `assertState(STATE_DECODE);
        // lower byte:
    @(negedge clk);
        `assert(uut.proc.aluMode, ALU1_INC);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 0);
    @(negedge clk);
        `assertRegister('h11, 'h03);
        `assertFlags('b0000_0000);
		// upper byte:
        `assert(uut.proc.aluMode, ALU1_INCW);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 1);
    @(negedge clk);
        `assertRegister('h10, 'h01);
        `assertFlags('b0000_0000);

// decw 10
    repeat (3) @(negedge clk);
        `assertInstr('h80);
        `assertSecond('h10);
        `assertState(STATE_DECODE);
        // lower byte:
    @(negedge clk);
        `assert(uut.proc.aluMode, ALU1_DEC);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 0);
    @(negedge clk);
        `assertRegister('h11, 'h02);
        `assertFlags('b0000_0000);
        // upper byte:
        `assert(uut.proc.aluMode, ALU1_DECW);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 1);
    @(negedge clk);
        `assertRegister('h10, 'h01);
        `assertFlags('b0000_0000);


	chk_ld_R_IM(8'h11, 8'h7F);
        `assertRegister('h10, 'h01);
        `assertRegister('h11, 'h7F);
        `assertFlags('b0000_0000);

// incw 10
    repeat (3) @(negedge clk);
        `assertInstr('hA0);
        `assertSecond('h10);
        `assertState(STATE_DECODE);
        // lower byte:
    @(negedge clk);
        `assert(uut.proc.aluMode, ALU1_INC);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 0);
    @(negedge clk);
        `assertRegister('h11, 'h80);
        // sv
        `assertFlags('b0000_0000); // unchanged
        // upper byte:
        `assert(uut.proc.aluMode, ALU1_INCW);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 1);
    @(negedge clk);
        `assertRegister('h10, 'h01);
        `assertFlags('b0000_0000);

// decw 10
    repeat (3) @(negedge clk);
        `assertInstr('h80);
        `assertSecond('h10);
        `assertState(STATE_DECODE);
        // lower byte:
    @(negedge clk);
        `assert(uut.proc.aluMode, ALU1_DEC);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 0);
    @(negedge clk);
        `assertRegister('h11, 'h7F);
        // v
        `assertFlags('b0000_0000); // unchanged
        // upper byte:
        `assert(uut.proc.aluMode, ALU1_DECW);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 1);
    @(negedge clk);
        `assertRegister('h10, 'h01);
        `assertFlags('b0000_0000);


	chk_ld_R_IM(8'h11, 8'hFF);
        `assertRegister('h10, 'h01);
        `assertRegister('h11, 'hFF);

// incw 10
    repeat (3) @(negedge clk);
        `assertInstr('hA0);
        `assertSecond('h10);
        `assertState(STATE_DECODE);
        // lower byte:
    @(negedge clk);
        `assert(uut.proc.aluMode, ALU1_INC);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 0);
    @(negedge clk);
        `assertRegister('h11, 'h00);
        `assertFlags('b0000_0000); // unchanged
        // upper byte:
        `assert(uut.proc.aluMode, ALU1_INCW);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 1);
    @(negedge clk);
        `assertRegister('h10, 'h02);
        `assertRegister('h11, 'h00);
        `assertFlags('b0000_0000);

// decw 10
    repeat (3) @(negedge clk);
        `assertInstr('h80);
        `assertSecond('h10);
        `assertState(STATE_DECODE);
        // lower byte:
    @(negedge clk);
        `assert(uut.proc.aluMode, ALU1_DEC);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 0);
    @(negedge clk);
        `assertRegister('h11, 'hFF);
        // s
        `assertFlags('b0000_0000); // unchanged
        // upper byte:
        `assert(uut.proc.aluMode, ALU1_DECW);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 1);
    @(negedge clk);
        `assertRegister('h10, 'h01);
        `assertFlags('b0000_0000);


	chk_ld_R_IM(8'h10, 8'hFF);
        `assertRegister('h10, 'hFF);
        `assertRegister('h11, 'hFF);

// incw 10
    repeat (3) @(negedge clk);
        `assertInstr('hA0);
        `assertSecond('h10);
        `assertState(STATE_DECODE);
        // lower byte:
    @(negedge clk);
        `assert(uut.proc.aluMode, ALU1_INC);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 0);
    @(negedge clk);
        `assertRegister('h11, 'h00);
        `assertFlags('b0000_0000); // unchanged
        // upper byte:
        `assert(uut.proc.aluMode, ALU1_INCW);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 1);
    @(negedge clk);
        `assertRegister('h10, 'h00);
        // z
        `assertFlags('b0100_0000);

// incw 10
    repeat (3) @(negedge clk);
        `assertInstr('hA0);
        `assertSecond('h10);
        `assertState(STATE_DECODE);
        // lower byte:
    @(negedge clk);
        `assert(uut.proc.aluMode, ALU1_INC);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 0);
    @(negedge clk);
        `assertRegister('h11, 'h01);
        `assertFlags('b0100_0000); // unchanged
        // upper byte:
        `assert(uut.proc.aluMode, ALU1_INCW);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 1);
    @(negedge clk);
        `assertRegister('h10, 'h00);
        `assertFlags('b0000_0000);

// decw 10
    repeat (3) @(negedge clk);
        `assertInstr('h80);
        `assertSecond('h10);
        `assertState(STATE_DECODE);
        // lower byte:
    @(negedge clk);
        `assert(uut.proc.aluMode, ALU1_DEC);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 0);
    @(negedge clk);
        // upper byte:
        `assert(uut.proc.aluMode, ALU1_DECW);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 1);
    @(negedge clk);
        `assertRegister('h10, 'h00);
        `assertRegister('h11, 'h00);
        // z
        `assertFlags('b0100_0000);

// decw 10
    repeat (3) @(negedge clk);
        `assertInstr('h80);
        `assertSecond('h10);
        `assertState(STATE_DECODE);
        // lower byte:
    @(negedge clk);
        `assert(uut.proc.aluMode, ALU1_DEC);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 0);
    @(negedge clk);
        `assertRegister('h11, 'hFF);
        // s
        `assertFlags('b0100_0000); // unchanged
        // upper byte:
        `assert(uut.proc.aluMode, ALU1_DECW);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 1);
    @(negedge clk);
        `assertRegister('h10, 'hFF);
        // s
        `assertFlags('b0010_0000);


	chk_jp(16'h000C);
