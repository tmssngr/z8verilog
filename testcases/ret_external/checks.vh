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

// call L1_
	repeat (5) @(negedge clk);
        `assertInstr('hD6);
        `assertSecond('h00);
        `assertThird('h26);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assert(uut.proc.sp, 16'hFFFF);
        `assertState(STATE_CALL_E1);
    @(negedge clk);
        `assert(uut.proc.addr, 16'hFFFF);
        `assert(uut.proc.sp, 16'hFFFE);
        `assert(uut.proc.aluA, 8'h16);
        `assertState(STATE_CALL_E2);
    @(negedge clk);
        `assertRam(16'hFFFF, 8'h16);

        `assert(uut.proc.addr, 16'hFFFE);
        `assert(uut.proc.aluA, 8'h00);
        `assertState(STATE_CALL_E3);
    @(negedge clk);
        `assertRam(16'hFFFE, 8'h00);
        `assertPc(16'h0026);

        `assertState(STATE_FETCH_INSTR);
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

// ret
    repeat (2) @(negedge clk);
        `assertInstr('hAF);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assert(uut.proc.sp, 16'hFFFE);
        `assertState(STATE_RET_E1);
    @(negedge clk);
        `assertState(STATE_RET_E2);
    @(negedge clk);
        `assert(uut.proc.addr, 16'hFFFE);
        `assert(uut.proc.sp, 16'hFFFF);
        `assertState(STATE_RET_E3);
    @(negedge clk);
        `assertState(STATE_RET_E4);
    @(negedge clk);
        `assert(uut.proc.aluA, 'h00);
        `assert(uut.proc.addr, 'hFFFF);
        `assert(uut.proc.sp, 16'h0000);
        `assertState(STATE_RET_E5);
    @(negedge clk);
        `assert(uut.proc.addr, 'h0016);
        `assertState(STATE_RET_E6);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
        `assertPc(16'h0016);
    @(negedge clk);

// ld r0, #00
	repeat (3) @(negedge clk);
        `assertInstr('h0C);
        `assertSecond('h00);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h20, 'h00);

// ld r1, #0C
	repeat (3) @(negedge clk);
        `assertInstr('h1C);
        `assertSecond('h0C);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h20, 'h00);
        `assertRegister('h21, 'h0C);

// ld r2, #A5
	repeat (3) @(negedge clk);
        `assertInstr('h2C);
        `assertSecond('hA5);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h20, 'h00);
        `assertRegister('h21, 'h0C);
        `assertRegister('h22, 'hA5);

// push r1
    repeat (3) @(negedge clk);
        `assertInstr('h70);
        `assertSecond('hE1);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assert(uut.proc.register, 'h21);
        `assertState(STATE_PUSH_E1);
    @(negedge clk);
        `assertState(STATE_PUSH_E2);
    @(negedge clk);
        `assertState(STATE_PUSH_E3);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assert(uut.proc.sp, 16'hFFFF);
        `assertRam('hFFFF, 'h0C);

// push r0
    repeat (3) @(negedge clk);
        `assertInstr('h70);
        `assertSecond('hE0);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assert(uut.proc.register, 'h20);
        `assertState(STATE_PUSH_E1);
    @(negedge clk);
        `assertState(STATE_PUSH_E2);
    @(negedge clk);
        `assertState(STATE_PUSH_E3);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assert(uut.proc.sp, 16'hFFFE);
        `assertRam('hFFFE, 'h00);

// push r2
    repeat (3) @(negedge clk);
        `assertInstr('h70);
        `assertSecond('hE2);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assert(uut.proc.register, 'h22);
        `assertState(STATE_PUSH_E1);
    @(negedge clk);
        `assertState(STATE_PUSH_E2);
    @(negedge clk);
        `assertState(STATE_PUSH_E3);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assert(uut.proc.sp, 16'hFFFD);
        `assertRam('hFFFD, 'hA5);

// iret
    repeat (2) @(negedge clk);
        `assertInstr('hBF);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_IRET_E1);
    @(negedge clk);
        `assert(uut.proc.addr, 16'hFFFD);
        `assertState(STATE_IRET_E2);
    @(negedge clk);
        `assert(uut.proc.aluMode, ALU1_LD);
        `assert(uut.proc.aluA, 'hA5);
        `assert(uut.proc.sp, 16'hFFFE);
        `assert(uut.proc.register, 'hFC);
        `assert(uut.proc.writeRegister, 1);
        `assertState(STATE_RET_E1);
    @(negedge clk);
        `assertFlags(8'b1010_0101);
        `assert(uut.proc.addr, 16'hFFFE);
        `assert(uut.proc.sp, 16'hFFFF);
        `assertState(STATE_RET_E2);
    @(negedge clk);
        `assertState(STATE_RET_E3);
    @(negedge clk);
        `assert(uut.proc.aluA, 8'h00);
        `assert(uut.proc.addr, 16'hFFFF);
        `assert(uut.proc.sp, 16'h0000);
        `assertState(STATE_RET_E4);
    @(negedge clk);
        `assertState(STATE_RET_E5);
    @(negedge clk);
        `assert(uut.proc.addr, 16'h000C);
        `assertState(STATE_RET_E6);
    @(negedge clk);
        `assertPc(16'h000C);
        `assertState(STATE_FETCH_INSTR);

    #3
