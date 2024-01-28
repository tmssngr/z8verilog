    @(negedge clk);

	chk_srp(2);

	chk_ld_r_IM(4'h0, 8'h00,
	            8'h20);
	chk_ld_r_IM(4'h1, 8'h0B,
	            8'h21);
        `assertRegister('h20, 'h00);
        `assertRegister('h21, 'h0B);

// ldc r2, Irr0
    repeat (3) @(negedge clk);
        `assertInstr('hC2);
        `assertSecond('h20);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assert(uut.proc.register, 'h22);
        `assertState(STATE_LDC_READ1);
    @(negedge clk);
        `assert(uut.proc.register, 'h22);
        `assert(uut.proc.addr[15:8], 'h0);
        `assertState(STATE_LDC_READ2);
    @(negedge clk);
        `assert(uut.proc.register, 'h22);
        `assert(uut.proc.addr, 'h0B);
        `assertState(STATE_READ_MEM1);
    @(negedge clk);
        `assert(uut.proc.register, 'h22);
        `assert(uut.proc.addr, 'h0B);
        `assertState(STATE_READ_MEM2);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister(8'h20, 'h00);
        `assertRegister(8'h21, 'h0B);
        `assertRegister(8'h22, 'h0F);

// ROM
	chk_ld_r_IM(4'h0, 8'h08,
	            8'h20);
	chk_ld_r_IM(4'h1, 8'h12,
	            8'h21);
        `assertRegister('h20, 'h08);
        `assertRegister('h21, 'h12);

// ldc Irr0, r2
    repeat (3) @(negedge clk);
        `assertInstr('hD2);
        `assertSecond('h20);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assert(uut.proc.register, 'h22);
        `assertState(STATE_LDC_WRITE1);
    @(negedge clk);
        `assert(uut.proc.register, 'h22);
        `assert(uut.proc.addr[15:8], 'h08);
        `assertState(STATE_LDC_WRITE2);
    @(negedge clk);
        `assert(uut.proc.register, 'h22);
        `assert(uut.proc.addr, 'h0812);
        `assertState(STATE_LDC_WRITE3);
    @(negedge clk);
        `assert(uut.proc.register, 'h22);
        `assert(uut.proc.aluA, 'h0F);
        `assert(uut.proc.addr, 'h0812);
        `assertState(STATE_WRITE_MEM);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRom(16'h812, 8'h00); // remains as is (read-only)
        `assertRegister(8'h20, 'h08);
        `assertRegister(8'h21, 'h12);
        `assertRegister(8'h22, 'h0F);

// RAM
	chk_ld_r_IM(4'h0, 8'hFF,
	            8'h20);
	chk_ld_r_IM(4'h1, 8'h80,
	            8'h21);
        `assertRegister('h20, 'hFF);
        `assertRegister('h21, 'h80);

// ldc r2, Irr0
    repeat (3) @(negedge clk);
        `assertInstr('hC2);
        `assertSecond('h20);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assert(uut.proc.register, 'h22);
        `assertState(STATE_LDC_READ1);
    @(negedge clk);
        `assert(uut.proc.register, 'h22);
        `assert(uut.proc.addr[15:8], 'hFF);
        `assertState(STATE_LDC_READ2);
    @(negedge clk);
        `assert(uut.proc.register, 'h22);
        `assert(uut.proc.addr, 'hFF80);
        `assertState(STATE_READ_MEM1);
    @(negedge clk);
        `assertRam(16'hFF80, 8'h00);
        `assertState(STATE_READ_MEM2);
    @(negedge clk);
        `assert(uut.proc.aluA, 'h00);
        `assert(uut.proc.aluMode, ALU1_LD);
        `assert(uut.proc.writeRegister, 1);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister(8'h22, 'h00);

        `assertRegister(8'h20, 'hFF);
        `assertRegister(8'h21, 'h80);

// inc 22
    repeat (3) @(negedge clk);
        `assertInstr('h20);
        `assertSecond('h22);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_ALU1_OP);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister(8'h22, 'h01);

        `assertRegister(8'h20, 'hFF);
        `assertRegister(8'h21, 'h80);

// ldc Irr0, r2
    repeat (3) @(negedge clk);
        `assertInstr('hD2);
        `assertSecond('h20);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assert(uut.proc.register, 'h22);
        `assertState(STATE_LDC_WRITE1);
    @(negedge clk);
        `assert(uut.proc.register, 'h22);
        `assert(uut.proc.addr[15:8], 'hFF);
        `assertState(STATE_LDC_WRITE2);
    @(negedge clk);
        `assert(uut.proc.register, 'h22);
        `assert(uut.proc.addr, 'hFF80);
        `assertState(STATE_LDC_WRITE3);
    @(negedge clk);
        `assert(uut.proc.aluA, 'h01);
        `assert(uut.proc.addr, 'hFF80);
        `assertState(STATE_WRITE_MEM);
    @(negedge clk);
        `assertRam(16'hFF80, 8'h01);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister(8'h20, 'hFF);
        `assertRegister(8'h21, 'h80);
        `assertRegister(8'h22, 'h01);


	chk_jp(16'h000C);
