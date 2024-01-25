    @(negedge clk);
// srp 20
    repeat (3) @(negedge clk);
        `assertInstr('h31);
        `assertSecond('h20);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assert(uut.proc.rp, 'h2);

// ld r0, #9
    repeat (3) @(negedge clk);
        `assertInstr('h0C);
        `assertSecond('h09);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assert(uut.proc.register, 'h20);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h20, 'h09);

// ld r1, #1
    repeat (3) @(negedge clk);
        `assertInstr('h1C);
        `assertSecond('h01);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assert(uut.proc.register, 'h21);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h21, 'h01);

// ld r2, #20
    repeat (3) @(negedge clk);
        `assertInstr('h2C);
        `assertSecond('h20);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assert(uut.proc.register, 'h22);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h22, 'h20);

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

// ld r2, #21
    repeat (3) @(negedge clk);
        `assertInstr('h2C);
        `assertSecond('h21);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assert(uut.proc.register, 'h22);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h22, 'h21);

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
    repeat (5) @(negedge clk);
        `assertInstr('h8D);
        `assertSecond('h00);
        `assertThird('h0C);
    repeat (2) @(negedge clk);
        `assertPc('h000C);

    #3
