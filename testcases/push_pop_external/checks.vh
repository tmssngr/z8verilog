    @(negedge clk);
// srp #10
    repeat (3) @(negedge clk);
        `assertInstr('h31);
        `assertSecond('h20);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assert(uut.proc.rp, 'h2);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);

// ld P01M, #92
	repeat (5) @(negedge clk);
        `assertInstr('hE6);
        `assertSecond('hF8);
        `assertThird('h92);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assert(uut.proc.p01m, 'h92);

// clr SPH
	repeat (3) @(negedge clk);
        `assertInstr('hB0);
        `assertSecond('hFE);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_ALU1_OP);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assert(uut.proc.sp[15:8], 'h00);

// clr SPL
	repeat (3) @(negedge clk);
        `assertInstr('hB0);
        `assertSecond('hFF);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_ALU1_OP);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assert(uut.proc.sp[7:0], 'h00);

// ld r0, #12
	repeat (3) @(negedge clk);
        `assertInstr('h0C);
        `assertSecond('h12);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h20, 'h12);

// push r0
    repeat (3) @(negedge clk);
        `assertInstr('h70);
        `assertSecond('hE0);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assert(uut.proc.register, 'h20);
        `assertState(STATE_PUSH_E1);
    @(negedge clk);
        `assert(uut.proc.sp, 16'hFFFF);
        `assertState(STATE_PUSH_E2);
    @(negedge clk);
        `assertState(STATE_PUSH_E3);
    @(negedge clk);
        `assert(uut.proc.aluA, 8'h12);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRam(16'hFFFF, 'h12);

// pop r1
    repeat (3) @(negedge clk);
        `assertInstr('h50);
        `assertSecond('hE1);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assert(uut.proc.register, 'h21);
        `assertState(STATE_POP_E1);
    @(negedge clk);
        `assert(uut.proc.addr, 16'hFFFF);
        `assertState(STATE_POP_E2);
    @(negedge clk);
        `assertState(STATE_POP_E3);
    @(negedge clk);
        `assert(uut.proc.aluMode, ALU1_LD);
        `assert(uut.proc.aluA, 8'h12);
        `assert(uut.proc.sp, 16'h0000);
        `assert(uut.proc.writeRegister, 1);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h21, 'h12);

        `assertRegister('h20, 'h12);

// jmp 0
    repeat (5) @(negedge clk);
        `assertInstr('h8D);
        `assertSecond('h00);
        `assertThird('h0C);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
        `assertPc('h000C);

    #3
