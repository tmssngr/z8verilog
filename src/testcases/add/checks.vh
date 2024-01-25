    @(negedge clk);
// srp #20
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

// ld r1, #6
    repeat (3) @(negedge clk);
        `assertInstr('h1C);
        `assertSecond('h06);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assert(uut.proc.register, 'h21);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h21, 'h06);

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

// ld r1, #80
    repeat (3) @(negedge clk);
        `assertInstr('h1C);
        `assertSecond('h80);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h21, 'h80);

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

// ld r1, #70
    repeat (3) @(negedge clk);
        `assertInstr('h1C);
        `assertSecond('h70);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h20, 'h90);
        `assertRegister('h21, 'h70);

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

// ld r0, #FF
    repeat (3) @(negedge clk);
        `assertInstr('h0C);
        `assertSecond('hFF);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h20, 'hFF);

// ld r1, #FF
    repeat (3) @(negedge clk);
        `assertInstr('h1C);
        `assertSecond('hFF);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h21, 'hFF);

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

// jmp L0
    repeat (5) @(negedge clk);
        `assertInstr('h8D);
        `assertSecond('h00);
        `assertThird('h0C);
    repeat (2) @(negedge clk);
        `assertPc('h000C);

    #3
