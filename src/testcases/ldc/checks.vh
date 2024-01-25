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

// ld r0, #0
    repeat (3) @(negedge clk);
        `assertInstr('h0C);
        `assertSecond('h00);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h20, 'h00);

// ld r1, #B
    repeat (3) @(negedge clk);
        `assertInstr('h1C);
        `assertSecond('h0B);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
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
// ld r0, #8
    repeat (3) @(negedge clk);
        `assertInstr('h0C);
        `assertSecond('h08);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h20, 'h08);

// ld r1, #12
    repeat (3) @(negedge clk);
        `assertInstr('h1C);
        `assertSecond('h12);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
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
// ld r0, #FF
    repeat (3) @(negedge clk);
        `assertInstr('h0C);
        `assertSecond('hFF);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h20, 'hFF);

// ld r1, #80
    repeat (3) @(negedge clk);
        `assertInstr('h1C);
        `assertSecond('h80);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
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

// int 22
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

// jmp L0
    repeat (5) @(negedge clk);
        `assertInstr('h8D);
        `assertSecond('h00);
        `assertThird('h0C);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
        `assertPc('h000C);

    #3
