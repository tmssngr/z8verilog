    @(negedge clk);

	chk_srp(3);

	chk_ld_r_IM(4'h0, 8'h03,
	            8'h30);

// L1: nop
    repeat (2) @(negedge clk);
        `assertInstr('hFF);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);

// djnz r0, L1
    repeat (3) @(negedge clk);
        `assertInstr('h0A);
        `assertSecond('hFD);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_DJNZ1);
        `assert(uut.proc.register, 'h30);
    @(negedge clk);
        `assert(uut.proc.aluA, 'h03);
        `assert(uut.proc.aluMode, ALU1_DEC);
        `assertState(STATE_DJNZ2);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
        `assertRegister('h30, 'h02);
        `assertPc('h0010);
    @(negedge clk);

// L1: nop
    repeat (2) @(negedge clk);
        `assertInstr('hFF);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);

// djnz r0, L1
    repeat (3) @(negedge clk);
        `assertInstr('h0A);
        `assertSecond('hFD);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_DJNZ1);
        `assert(uut.proc.register, 'h30);
    @(negedge clk);
        `assert(uut.proc.aluA, 'h02);
        `assert(uut.proc.aluMode, ALU1_DEC);
        `assertState(STATE_DJNZ2);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
        `assertRegister('h30, 'h01);
        `assertPc('h0010);
    @(negedge clk);

// L1: nop
    repeat (2) @(negedge clk);
        `assertInstr('hFF);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);

// djnz r0, L1
    repeat (3) @(negedge clk);
        `assertInstr('h0A);
        `assertSecond('hFD);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_DJNZ1);
        `assert(uut.proc.register, 'h30);
    @(negedge clk);
        `assert(uut.proc.aluA, 'h01);
        `assert(uut.proc.aluMode, ALU1_DEC);
        `assertState(STATE_DJNZ2);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
        `assertRegister('h30, 'h00);
        `assertPc('h0013);
    @(negedge clk);

// jr L0
    repeat (3) @(negedge clk);
        `assertInstr('h8B);
        `assertSecond('hF7);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
        `assertPc('h000C);

    #3
