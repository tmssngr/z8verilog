    @(negedge clk);

// ld P01M, #92
	chk_ld_R_IM(8'hF8, 8'h92);

// clr SPH
	chk_2byteOp(8'hB0, 8'hFE);
        `assertState(STATE_ALU1_OP);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assert(uut.proc.sp[15:8], 'h00);

// clr SPL
	chk_2byteOp(8'hB0, 8'hFF);
        `assertState(STATE_ALU1_OP);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assert(uut.proc.sp[7:0], 'h00);

// call L1_
	chk_3byteOp(8'hD6, 8'h00, 8'h2C);
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
        `assertState(STATE_JP1);
    @(negedge clk);
        `assert(uut.proc.addr[15:8], 8'h00);
        `assertState(STATE_JP2);
    @(negedge clk);
        `assert(uut.proc.addr[7:0], 8'h2C);
        `assertState(STATE_JP3);
    @(negedge clk);
        `assertPc(16'h002C);

        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);


	chk_srp(2);

// ret
	chk_1byteOp(8'hAF);
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


	chk_ld_r_IM(4'h0, 8'h00,
	            8'h20);
	chk_ld_r_IM(4'h1, 8'h2C,
	            8'h21);
        `assertRegister('h20, 'h00);
        `assertRegister('h21, 'h2C);

// call @r0
	chk_2byteOp(8'hD4, 8'hE0);
        `assert(uut.proc.sp, 16'hFFFF);
        `assertState(STATE_CALL_E1);
    @(negedge clk);
        `assert(uut.proc.addr, 16'hFFFF);
        `assert(uut.proc.sp, 16'hFFFE);
        `assert(uut.proc.aluA, 8'h1C);
        `assertState(STATE_CALL_E2);
    @(negedge clk);
        `assertRam(16'hFFFF, 8'h1C);

        `assert(uut.proc.addr, 16'hFFFE);
        `assert(uut.proc.aluA, 8'h00);
        `assertState(STATE_CALL_E3);
    @(negedge clk);
        `assertRam(16'hFFFE, 8'h00);
        `assertState(STATE_JP1);
    @(negedge clk);
        `assert(uut.proc.addr[15:8], 8'h00);
        `assertState(STATE_JP2);
    @(negedge clk);
        `assert(uut.proc.addr[7:0], 8'h2C);
        `assertState(STATE_JP3);
    @(negedge clk);
        `assertPc(16'h002C);

        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);


	chk_srp(2);

// ret
	chk_1byteOp(8'hAF);
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
        `assert(uut.proc.addr, 'h001C);
        `assertState(STATE_RET_E6);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
        `assertPc(16'h001C);
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
	chk_2byteOp(8'h70, 8'hE1);
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
	chk_2byteOp(8'h70, 8'hE0);
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
	chk_2byteOp(8'h70, 8'hE2);
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
	chk_1byteOp(8'hBF);
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
