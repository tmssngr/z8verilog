    @(negedge clk);

    chk_srp(2);

	chk_ld_r_IM(4'h0, 8'h09,
	            8'h20);

	chk_ld_r_IM(4'h1, 8'h01,
	            8'h21);

	chk_ld_r_IM(4'h2, 8'h20,
	            8'h22);

// cp r0, Ir1
    repeat (3) @(negedge clk);
        `assertInstr('hA3);
        `assertSecond('h02);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assert(uut.proc.register, 'h20);
        `assert(uut.proc.aluA, 'h09);
        `assertState(STATE_ALU2_IR);
    @(negedge clk);
        `assert(uut.proc.register, 'h20);
        `assertState(STATE_ALU2_OP);
    @(negedge clk);
        `assert(uut.proc.register, 'h20);
        `assert(uut.proc.aluMode, ALU2_CP);
        `assert(uut.proc.aluB, 'h09);
        `assert(uut.proc.writeRegister, 0);
        `assert(uut.proc.writeFlags, 1);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h20, 'h09);
        `assertRegister('h21, 'h01);
        `assertRegister('h22, 'h20);
        // z
        `assertFlags('b0100_0000);


	chk_ld_r_IM(4'h2, 8'h21,
	            8'h22);

// cp r0, Ir1
    repeat (3) @(negedge clk);
        `assertInstr('hA3);
        `assertSecond('h02);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assert(uut.proc.register, 'h21);
        `assert(uut.proc.aluA, 'h09);
        `assertState(STATE_ALU2_IR);
    @(negedge clk);
        `assert(uut.proc.register, 'h20);
        `assertState(STATE_ALU2_OP);
    @(negedge clk);
        `assert(uut.proc.register, 'h20);
        `assert(uut.proc.aluMode, ALU2_CP);
        `assert(uut.proc.aluB, 'h01);
        `assert(uut.proc.writeRegister, 0);
        `assert(uut.proc.writeFlags, 1);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h20, 'h09);
        `assertRegister('h21, 'h01);
        `assertRegister('h22, 'h21);
        `assertFlags('b0000_0000);

// jmp L0
	chk_jp(16'h000C);

    #3
