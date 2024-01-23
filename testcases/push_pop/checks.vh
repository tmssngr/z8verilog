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

// ld r0, #12
	repeat (3) @(negedge clk);
        `assertInstr('h0C);
        `assertSecond('h12);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h20, 'h12);

// ld r0, #34
	repeat (3) @(negedge clk);
        `assertInstr('h1C);
        `assertSecond('h34);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h20, 'h12);
        `assertRegister('h21, 'h34);

// ld FF, #80
	repeat (5) @(negedge clk);
        `assertInstr('hE6);
        `assertSecond('hFF);
        `assertThird('h80);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assert(uut.proc.sp, 'h80);

// push r0
    repeat (3) @(negedge clk);
        `assertInstr('h70);
        `assertSecond('hE0);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assert(uut.proc.register, 'h20);
        `assertState(STATE_PUSH_I1);
    @(negedge clk);
        `assertState(STATE_PUSH_I2);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assert(uut.proc.sp, 'h7F);
        `assertRegister('h7F, 'h12);

// push r1
    repeat (3) @(negedge clk);
        `assertInstr('h70);
        `assertSecond('hE1);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assert(uut.proc.register, 'h21);
        `assertState(STATE_PUSH_I1);
    @(negedge clk);
        `assertState(STATE_PUSH_I2);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assert(uut.proc.sp, 'h7E);
        `assertRegister('h7E, 'h34);
        `assertRegister('h7F, 'h12);

// pop r0
    repeat (3) @(negedge clk);
        `assertInstr('h50);
        `assertSecond('hE0);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assert(uut.proc.register, 'h20);
        `assertState(STATE_POP_I);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assert(uut.proc.sp, 'h7F);
        `assertRegister('h20, 'h34);
        `assertRegister('h21, 'h34);

// pop r1
    repeat (3) @(negedge clk);
        `assertInstr('h50);
        `assertSecond('hE1);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assert(uut.proc.register, 'h21);
        `assertState(STATE_POP_I);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assert(uut.proc.sp, 'h80);
        `assertRegister('h20, 'h34);
        `assertRegister('h21, 'h12);

// ld r2, #20
	repeat (3) @(negedge clk);
        `assertInstr('h2C);
        `assertSecond('h20);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h20, 'h34);
        `assertRegister('h21, 'h12);
        `assertRegister('h22, 'h20);

// push @22
    repeat (3) @(negedge clk);
        `assertInstr('h71);
        `assertSecond('h22);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assert(uut.proc.register, 'h20);
        `assertState(STATE_PUSH_I1);
    @(negedge clk);
        `assertState(STATE_PUSH_I2);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assert(uut.proc.sp, 'h7F);
        `assertRegister('h7F, 'h34);

// ld r2, #24
	repeat (3) @(negedge clk);
        `assertInstr('h2C);
        `assertSecond('h24);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h20, 'h34);
        `assertRegister('h21, 'h12);
        `assertRegister('h22, 'h24);

// pop @22
    repeat (3) @(negedge clk);
        `assertInstr('h51);
        `assertSecond('h22);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assert(uut.proc.register, 'h24);
        `assertState(STATE_POP_I);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assert(uut.proc.sp, 'h80);
        `assertRegister('h20, 'h34);
        `assertRegister('h21, 'h12);
        `assertRegister('h22, 'h24);
        `assertRegister('h24, 'h34);

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
