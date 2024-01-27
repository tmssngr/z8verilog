    @(negedge clk);
// srp #00
    repeat (3) @(negedge clk);
        `assertInstr('h31);
        `assertSecond('h00);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assert(uut.proc.rp, 'h0);

// ld r4, #05
    repeat (3) @(negedge clk);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h04, 'h05);

// ld r2, #01
    repeat (3) @(negedge clk);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h02, 'b1);

// L1:
// rl r2
    repeat (3) @(negedge clk);
        `assertState(STATE_DECODE);
    @(negedge clk);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h02, 'b10);

// djnz r4, L1
    repeat (3) @(negedge clk);
        `assertState(STATE_DECODE);
    @(negedge clk);
    @(negedge clk);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h04, 'h04);

// L1:
// rl r2
    repeat (3) @(negedge clk);
        `assertState(STATE_DECODE);
    @(negedge clk);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h02, 'b100);

// djnz r4, L1
    repeat (3) @(negedge clk);
        `assertState(STATE_DECODE);
    @(negedge clk);
    @(negedge clk);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h04, 'h03);

// L1
// rl r2
    repeat (3) @(negedge clk);
        `assertState(STATE_DECODE);
    @(negedge clk);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h02, 'b1000);

// djnz r4, L1
    repeat (3) @(negedge clk);
        `assertState(STATE_DECODE);
    @(negedge clk);
    @(negedge clk);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h04, 'h02);

// L1:
// rl r2
    repeat (3) @(negedge clk);
        `assertState(STATE_DECODE);
    @(negedge clk);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h02, 'b1_0000);

// djnz r4, L2
    repeat (3) @(negedge clk);
        `assertState(STATE_DECODE);
    @(negedge clk);
    @(negedge clk);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h04, 'h01);

// L1:
// rl r2
    repeat (3) @(negedge clk);
        `assertState(STATE_DECODE);
    @(negedge clk);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h02, 'b10_0000);

// djnz r4, L2
    repeat (3) @(negedge clk);
        `assertState(STATE_DECODE);
    @(negedge clk);
    @(negedge clk);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h04, 'h00);

// jp 0812
    repeat (3) @(negedge clk);
        `assertInstr('h8B);
        `assertSecond('hF4);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertPc(16'h000C);

      #3
