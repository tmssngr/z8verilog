    @(negedge clk);

    chk_srp(2);

	chk_ld_r_IM(4'h0, 8'h00,
	            8'h20);

	chk_ld_r_IM(4'h1, 8'h02,
	            8'h21);

	chk_ld_r_IM(4'h2, 8'h24,
	            8'h22);
        `assertRegister('h20, 'h00);
        `assertRegister('h21, 'h02);
        `assertRegister('h22, 'h24);

// ldci Ir2, Irr0
    repeat (3) @(negedge clk);
        `assertInstr('hC3);
        `assertSecond('h20);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assert(uut.proc.register, 'h24);
        `assertState(STATE_LDC_READ1);
    @(negedge clk);
        `assert(uut.proc.addr[15:8], 'h0);
        `assertState(STATE_LDC_READ2);
    @(negedge clk);
        `assert(uut.proc.addr, 16'h0002);
        `assertState(STATE_READ_MEM1);
    @(negedge clk);
        `assertRom(16'h0002, 8'h08);
        `assertState(STATE_READ_MEM2);
    @(negedge clk);
        `assert(uut.proc.aluA, 8'h08);
        `assert(uut.proc.aluMode, ALU1_LD);
        `assert(uut.proc.writeRegister, 1);
        `assertState(STATE_INC_R_RR1);
    @(negedge clk);
        `assertRegister(8'h24, 8'h08);

        `assert(uut.proc.aluA, 8'h24);
        `assert(uut.proc.register, 8'h22);
        `assert(uut.proc.aluMode, ALU1_INC);
        `assert(uut.proc.writeRegister, 1);
        `assertState(STATE_INC_R_RR2);
    @(negedge clk);
        `assertRegister(8'h22, 8'h25);

        `assert(uut.proc.aluA, 8'h02);
        `assert(uut.proc.register, 8'h21);
        `assert(uut.proc.aluMode, ALU1_INC);
        `assert(uut.proc.writeRegister, 1);
        `assertState(STATE_INC_R_RR3);
    @(negedge clk);
        `assertRegister(8'h21, 8'h03);

        `assert(uut.proc.aluA, 8'h00);
        `assert(uut.proc.register, 8'h20);
        `assert(uut.proc.aluMode, ALU1_INCW);
        `assert(uut.proc.writeRegister, 1);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister(8'h20, 8'h00);

// ldci Ir2, Irr0
    repeat (3) @(negedge clk);
        `assertInstr('hC3);
        `assertSecond('h20);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assert(uut.proc.register, 'h25);
        `assertState(STATE_LDC_READ1);
    @(negedge clk);
        `assert(uut.proc.addr[15:8], 'h0);
        `assertState(STATE_LDC_READ2);
    @(negedge clk);
        `assert(uut.proc.addr, 16'h0003);
        `assertState(STATE_READ_MEM1);
    @(negedge clk);
        `assertRom(16'h0003, 8'h03);
        `assertState(STATE_READ_MEM2);
    @(negedge clk);
        `assert(uut.proc.aluA, 8'h03);
        `assert(uut.proc.aluMode, ALU1_LD);
        `assert(uut.proc.writeRegister, 1);
        `assertState(STATE_INC_R_RR1);
    @(negedge clk);
        `assertRegister(8'h25, 8'h03);

        `assert(uut.proc.aluA, 8'h25);
        `assert(uut.proc.register, 8'h22);
        `assert(uut.proc.aluMode, ALU1_INC);
        `assert(uut.proc.writeRegister, 1);
        `assertState(STATE_INC_R_RR2);
    @(negedge clk);
        `assertRegister(8'h22, 8'h26);

        `assert(uut.proc.aluA, 8'h03);
        `assert(uut.proc.register, 8'h21);
        `assert(uut.proc.aluMode, ALU1_INC);
        `assert(uut.proc.writeRegister, 1);
        `assertState(STATE_INC_R_RR3);
    @(negedge clk);
        `assertRegister(8'h21, 8'h04);

        `assert(uut.proc.aluA, 8'h00);
        `assert(uut.proc.register, 8'h20);
        `assert(uut.proc.aluMode, ALU1_INCW);
        `assert(uut.proc.writeRegister, 1);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister(8'h20, 8'h00);


	chk_ld_r_IM(4'h0, 8'hFF,
	            8'h20);
	chk_ld_r_IM(4'h1, 8'hFE,
	            8'h21);
	chk_ld_r_IM(4'h2, 8'h24,
	            8'h22);
        `assertRegister('h20, 'hFF);
        `assertRegister('h21, 'hFE);
        `assertRegister('h22, 'h24);

// ldci Irr0, Ir2
    repeat (3) @(negedge clk);
        `assertInstr('hD3);
        `assertSecond('h20);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assert(uut.proc.register, 'h24);
        `assertState(STATE_LDC_WRITE1);
    @(negedge clk);
        `assert(uut.proc.addr[15:8], 'hFF);
        `assertState(STATE_LDC_WRITE2);
    @(negedge clk);
        `assert(uut.proc.addr, 16'hFFFE);
        `assertState(STATE_LDC_WRITE3);
    @(negedge clk);
        `assertState(STATE_WRITE_MEM);
    @(negedge clk);
        `assertRam(16'hFFFE, 8'h08);

        `assertState(STATE_INC_R_RR1);
    @(negedge clk);
        `assertRegister(8'h24, 8'h08);

        `assert(uut.proc.aluA, 8'h24);
        `assert(uut.proc.register, 8'h22);
        `assert(uut.proc.aluMode, ALU1_INC);
        `assert(uut.proc.writeRegister, 1);
        `assertState(STATE_INC_R_RR2);
    @(negedge clk);
        `assertRegister(8'h22, 8'h25);

        `assert(uut.proc.aluA, 8'hFE);
        `assert(uut.proc.register, 8'h21);
        `assert(uut.proc.aluMode, ALU1_INC);
        `assert(uut.proc.writeRegister, 1);
        `assertState(STATE_INC_R_RR3);
    @(negedge clk);
        `assertRegister(8'h21, 8'hFF);

        `assert(uut.proc.aluA, 8'hFF);
        `assert(uut.proc.register, 8'h20);
        `assert(uut.proc.aluMode, ALU1_INCW);
        `assert(uut.proc.writeRegister, 1);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister(8'h20, 8'hFF);

// ldci Irr0, Ir2
    repeat (3) @(negedge clk);
        `assertInstr('hD3);
        `assertSecond('h20);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assert(uut.proc.register, 'h25);
        `assertState(STATE_LDC_WRITE1);
    @(negedge clk);
        `assert(uut.proc.addr[15:8], 'hFF);
        `assertState(STATE_LDC_WRITE2);
    @(negedge clk);
        `assert(uut.proc.addr, 16'hFFFF);
        `assertState(STATE_LDC_WRITE3);
    @(negedge clk);
        `assertState(STATE_WRITE_MEM);
    @(negedge clk);
        `assertRam(16'hFFFF, 8'h03);

        `assertState(STATE_INC_R_RR1);
    @(negedge clk);
        `assertRegister(8'h25, 8'h03);

        `assert(uut.proc.aluA, 8'h25);
        `assert(uut.proc.register, 8'h22);
        `assert(uut.proc.aluMode, ALU1_INC);
        `assert(uut.proc.writeRegister, 1);
        `assertState(STATE_INC_R_RR2);
    @(negedge clk);
        `assertRegister(8'h22, 8'h26);

        `assert(uut.proc.aluA, 8'hFF);
        `assert(uut.proc.register, 8'h21);
        `assert(uut.proc.aluMode, ALU1_INC);
        `assert(uut.proc.writeRegister, 1);
        `assertState(STATE_INC_R_RR3);
    @(negedge clk);
        `assertRegister(8'h21, 8'h00);

        `assert(uut.proc.aluA, 8'hFF);
        `assert(uut.proc.register, 8'h20);
        `assert(uut.proc.aluMode, ALU1_INCW);
        `assert(uut.proc.writeRegister, 1);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister(8'h20, 8'h00);

// jmp L0
	chk_jp(16'h000C);

    #3
