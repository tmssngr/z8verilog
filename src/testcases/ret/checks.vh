    @(negedge clk);

	// SPL
    chk_ld_R_IM(8'hFF, 8'h80);

// call L1_
	repeat (5) @(negedge clk);
        `assertInstr('hD6);
        `assertSecond('h00);
        `assertThird('h28);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assert(uut.proc.sp, 'h7F);
        `assertState(STATE_CALL_I1);
    @(negedge clk);
        `assert(uut.proc.sp, 'h7E);
        `assert(uut.proc.aluMode, ALU1_LD);
        `assert(uut.proc.aluA, 8'h12);
        `assert(uut.proc.register, 'h7F);
        `assert(uut.proc.writeRegister, 1);
        `assertState(STATE_CALL_I2);
    @(negedge clk);
        `assertRegister(8'h7F, 8'h12);

        `assert(uut.proc.aluMode, ALU1_LD);
        `assert(uut.proc.aluA, 8'h00);
        `assert(uut.proc.register, 'h7E);
        `assert(uut.proc.writeRegister, 1);
        `assertState(STATE_JP1);
    @(negedge clk);
        `assert(uut.proc.addr[15:8], 8'h00);
        `assertState(STATE_JP2);
    @(negedge clk);
        `assert(uut.proc.addr[7:0], 8'h28);
        `assertState(STATE_JP3);
    @(negedge clk);
        `assertRegister(8'h7E, 8'h00);
        `assertPc(16'h0028);

        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);


	chk_srp(2);

// ret
    repeat (2) @(negedge clk);
        `assertInstr('hAF);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assert(uut.proc.sp, 'h7E);
        `assertState(STATE_RET_I1);
    @(negedge clk);
        `assert(uut.proc.addr[15:8], 'h00);
        `assert(uut.proc.sp, 'h7F);
        `assertState(STATE_RET_I2);
    @(negedge clk);
        `assert(uut.proc.addr, 'h0012);
        `assert(uut.proc.sp, 'h80);
        `assertState(STATE_RET_I3);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
        `assertPc(16'h0012);
    @(negedge clk);


	chk_ld_r_IM(4'h0, 8'h00,
	            8'h20);
	chk_ld_r_IM(4'h1, 8'h28,
	            8'h21);
        `assertRegister('h20, 'h00);
        `assertRegister('h21, 'h28);

// call IRR0
	repeat (3) @(negedge clk);
        `assertInstr('hD4);
        `assertSecond('hE0);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assert(uut.proc.sp, 'h7F);
        `assertState(STATE_CALL_I1);
    @(negedge clk);
        `assert(uut.proc.sp, 'h7E);
        `assert(uut.proc.aluMode, ALU1_LD);
        `assert(uut.proc.aluA, 8'h18);
        `assert(uut.proc.register, 'h7F);
        `assert(uut.proc.writeRegister, 1);
        `assertState(STATE_CALL_I2);
    @(negedge clk);
        `assertRegister(8'h7F, 8'h18);

        `assert(uut.proc.aluMode, ALU1_LD);
        `assert(uut.proc.aluA, 8'h00);
        `assert(uut.proc.register, 'h7E);
        `assert(uut.proc.writeRegister, 1);
        `assertState(STATE_JP1);
    @(negedge clk);
        `assert(uut.proc.addr[15:8], 8'h00);
        `assertState(STATE_JP2);
    @(negedge clk);
        `assert(uut.proc.addr[7:0], 8'h28);
        `assertState(STATE_JP3);
    @(negedge clk);
        `assertRegister(8'h7E, 8'h00);
        `assertPc(16'h0028);

        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);


	chk_srp(2);

// ret
    repeat (2) @(negedge clk);
        `assertInstr('hAF);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assert(uut.proc.sp, 'h7E);
        `assertState(STATE_RET_I1);
    @(negedge clk);
        `assert(uut.proc.addr[15:8], 'h00);
        `assert(uut.proc.sp, 'h7F);
        `assertState(STATE_RET_I2);
    @(negedge clk);
        `assert(uut.proc.addr, 'h0018);
        `assert(uut.proc.sp, 'h80);
        `assertState(STATE_RET_I3);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
        `assertPc(16'h0018);
    @(negedge clk);


	chk_ld_r_IM(4'h0, 8'h00,
	            8'h20);
	chk_ld_r_IM(4'h1, 8'h0C,
	            8'h21);
	chk_ld_r_IM(4'h2, 8'hA5,
	            8'h22);
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
        `assertState(STATE_PUSH_I1);
    @(negedge clk);
        `assertState(STATE_PUSH_I2);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assert(uut.proc.sp, 'h7F);
        `assertRegister('h7F, 'h0C);

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
        `assert(uut.proc.sp, 'h7E);
        `assertRegister('h7E, 'h00);
        `assertRegister('h7F, 'h0C);

// push r2
    repeat (3) @(negedge clk);
        `assertInstr('h70);
        `assertSecond('hE2);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assert(uut.proc.register, 'h22);
        `assertState(STATE_PUSH_I1);
    @(negedge clk);
        `assertState(STATE_PUSH_I2);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assert(uut.proc.sp, 'h7D);
        `assertRegister('h7D, 'hA5);
        `assertRegister('h7E, 'h00);
        `assertRegister('h7F, 'h0C);

// iret
    repeat (2) @(negedge clk);
        `assertInstr('hBF);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_IRET_I);
    @(negedge clk);
        `assert(uut.proc.aluMode, ALU1_LD);
        `assert(uut.proc.aluA, 'hA5);
        `assert(uut.proc.sp, 'h7E);
        `assert(uut.proc.register, 'hFC);
        `assert(uut.proc.writeRegister, 1);
        `assertState(STATE_RET_I1);
    @(negedge clk);
        `assertFlags(8'b1010_0101);
        `assert(uut.proc.addr[15:8], 'h00);
        `assert(uut.proc.sp, 'h7F);
        `assertState(STATE_RET_I2);
    @(negedge clk);
        `assert(uut.proc.addr, 'h000C);
        `assert(uut.proc.sp, 'h80);
        `assertState(STATE_RET_I3);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
        `assertPc(16'h000C);

    #3
