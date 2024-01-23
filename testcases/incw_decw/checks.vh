// ld 10, #1
    repeat (6) @(negedge clk);
        `assertInstr('hE6);
        `assertSecond('h10);
        `assertThird('h01);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 0);
    @(negedge clk);
        `assertRegister('h10, 'h01);
        `assertFlags('b0000_0000);

// ld 11, #2
    repeat (5) @(negedge clk);
        `assertInstr('hE6);
        `assertSecond('h11);
        `assertThird('h02);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 0);
    @(negedge clk);
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

// ld 11, #7F
    repeat (5) @(negedge clk);
        `assertInstr('hE6);
        `assertSecond('h11);
        `assertThird('h7F);
    @(negedge clk);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 0);
    @(negedge clk);
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

// ld 11, #FF
    repeat (5) @(negedge clk);
        `assertInstr('hE6);
        `assertSecond('h11);
        `assertThird('hFF);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 0);
    @(negedge clk);
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

// ld 10, #FF
    repeat (5) @(negedge clk);
        `assertInstr('hE6);
        `assertSecond('h10);
        `assertThird('hFF);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 0);
    @(negedge clk);
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

// jmp 0
    repeat (5) @(negedge clk);
        `assertInstr('h8D);
        `assertSecond('h00);
        `assertThird('h0C);
    repeat (1) @(negedge clk);
        `assertPc('h000C);

    #3
