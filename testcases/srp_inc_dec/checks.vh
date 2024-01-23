    @(negedge clk);
// srp #10
    repeat (3) @(negedge clk);
        `assertInstr('h31);
        `assertSecond('h10);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assert(uut.proc.rp, 'h1);

// ld r0, #9
    repeat (3) @(negedge clk);
        `assertInstr('h0C);
        `assertSecond('h09);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h10, 'h09);

// inc r0
    repeat (2) @(negedge clk);
        `assertInstr('h0E);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_ALU1_OP);
        `assert(uut.proc.register, 'h10);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h10, 'h0A);
        `assertFlags('b0000_0000);

// dec 10
    repeat (3) @(negedge clk);
        `assertInstr('h00);
        `assertSecond('h10);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_ALU1_OP);
        `assert(uut.proc.register, 'h10);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h10, 'h09);
        `assertFlags('b0000_0000);

// ld r0, #7f
    repeat (3) @(negedge clk);
        `assertInstr('h0C);
        `assertSecond('h7f);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h10, 'h7f);

// inc 10
    repeat (3) @(negedge clk);
        `assertInstr('h20);
        `assertSecond('h10);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_ALU1_OP);
        `assert(uut.proc.register, 'h10);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h10, 'h80);
        // sv
        `assertFlags('b0011_0000);

// dec 10
    repeat (3) @(negedge clk);
        `assertInstr('h00);
        `assertSecond('h10);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_ALU1_OP);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h10, 'h7F);
        // v
        `assertFlags('b0001_0000);

// ld r0, #FE
    repeat (3) @(negedge clk);
        `assertInstr('h0C);
        `assertSecond('hFE);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h10, 'hFE);

// inc 10
    repeat (3) @(negedge clk);
        `assertInstr('h20);
        `assertSecond('h10);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_ALU1_OP);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h10, 'hFF);
        // s
        `assertFlags('b0010_0000);

// inc 10
    repeat (3) @(negedge clk);
        `assertInstr('h20);
        `assertSecond('h10);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_ALU1_OP);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h10, 'h00);
        // z
        `assertFlags('b0100_0000);

// dec 10
    repeat (3) @(negedge clk);
        `assertInstr('h00);
        `assertSecond('h10);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_ALU1_OP);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h10, 'hFF);
        // s
        `assertFlags('b0010_0000);

// dec 10
    repeat (3) @(negedge clk);
        `assertInstr('h00);
        `assertSecond('h10);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_ALU1_OP);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h10, 'hFE);
        // s
        `assertFlags('b0010_0000);

// ld r1, #10
    repeat (3) @(negedge clk);
        `assertInstr('h1C);
        `assertSecond('h10);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h10, 'hFE);
        `assertRegister('h11, 'h10);

// dec @r1
    repeat (3) @(negedge clk);
        `assertInstr('h01);
        `assertSecond('hE1);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_ALU1_OP);
        `assert(uut.proc.register, 'h10);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h10, 'hFD);
        `assertRegister('h11, 'h10);
        // s
        `assertFlags('b0010_0000);

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
