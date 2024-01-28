    @(negedge clk);

	chk_srp(2);

	chk_ld_r_IM(4'h0, 8'h09,
	            8'h20);

	chk_ld_r_IM(4'h1, 8'h01,
	            8'h21);

// add r0, r1
    repeat (3) @(negedge clk);
        `assertInstr('h02);
        `assertSecond('h01);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_ALU2_OP);
    @(negedge clk);
        `assert(uut.proc.register, 'h20);
        `assert(uut.proc.aluMode, ALU2_ADD);
        `assert(uut.proc.aluA, 'h09);
        `assert(uut.proc.aluB, 'h01);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h20, 'h0A);
        `assertRegister('h21, 'h01);
        `assertFlags('b0000_0000);


	chk_ld_r_IM(4'h1, 8'h06,
	            8'h21);

// add r0, r1
    repeat (3) @(negedge clk);
        `assertInstr('h02);
        `assertSecond('h01);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_ALU2_OP);
    @(negedge clk);
        `assert(uut.proc.register, 'h20);
        `assert(uut.proc.aluMode, ALU2_ADD);
        `assert(uut.proc.aluA, 'h0A);
        `assert(uut.proc.aluB, 'h06);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h20, 'h10);
        `assertRegister('h21, 'h06);
        // h
        `assertFlags('b0000_0100);


	chk_ld_r_IM(4'h1, 8'h80,
	            8'h21);

// add r0, r1
    repeat (3) @(negedge clk);
        `assertInstr('h02);
        `assertSecond('h01);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_ALU2_OP);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h20, 'h90);
        // s
        `assertFlags('b0010_0000);


	chk_ld_r_IM(4'h1, 8'h70,
	            8'h21);


// add R0, R1
    repeat (5) @(negedge clk);
        `assertState(STATE_DECODE);
        `assertInstr('h04);
        `assertSecond('hE1);
        `assertThird('hE0);
    @(negedge clk);
        `assertState(STATE_ALU2_OP);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h20, 'h00);
        `assertRegister('h21, 'h70);
        // cz
        `assertFlags('b1100_0000);


	chk_ld_r_IM(4'h0, 8'hFF,
	            8'h20);

	chk_ld_r_IM(4'h1, 8'hFF,
	            8'h21);

// add r1, r0
    repeat (3) @(negedge clk);
        `assertInstr('h02);
        `assertSecond('h10);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_ALU2_OP);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h20, 'hFF);
        `assertRegister('h21, 'hFE);
        // csh
        `assertFlags('b1010_0100);

	chk_jp(16'h000C);
