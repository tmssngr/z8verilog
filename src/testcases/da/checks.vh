    @(negedge clk);

	chk_srp(1);

	chk_ld_r_IM(4'h0, 8'h09,
	            8'h10);

	chk_ld_r_IM(4'h1, 8'h01,
	            8'h11);

	chk_alu2_r_r(ALU2_ADD, 0, 1,
	             8'h10, 8'h0A, FLAG_NONE);

// da r0
    repeat (3) @(negedge clk);
        `assertInstr('h40);
        `assertSecond('hE0);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assert(uut.proc.aluMode, ALU1_DA);
        `assert(uut.proc.register, 'h10);
        `assertState(STATE_ALU1_OP);
    @(negedge clk);
        `assert(uut.proc.aluMode, ALU1_DA);
        `assert(uut.proc.aluA, 'h0A);
        `assertFlags(FLAG_NONE);
        `assert(uut.proc.register, 'h10);
        `assertState(STATE_ALU1_DA);
    @(negedge clk);
        `assert(uut.proc.aluA, 'h10);
        `assert(uut.proc.aluMode, ALU1_DA_H);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 1);
        `assert(uut.proc.register, 'h10);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h10, 'h10);
        `assertRegister('h11, 'h01);
        `assertFlags(FLAG_NONE);


	chk_alu2_r_r(ALU2_SUB, 0, 1,
	             8'h10, 8'h0F, FLAG_D | FLAG_H);

// da r0
    repeat (3) @(negedge clk);
        `assertState(STATE_DECODE);
        `assertInstr('h40);
        `assertSecond('hE0);
    @(negedge clk);
        `assert(uut.proc.aluMode, ALU1_DA);
        `assert(uut.proc.register, 'h10);
        `assertState(STATE_ALU1_OP);
    @(negedge clk);
        `assert(uut.proc.aluMode, ALU1_DA);
        `assert(uut.proc.aluA, 'h0F);
        `assertFlags(FLAG_D | FLAG_H);
        `assert(uut.proc.register, 'h10);
        `assertState(STATE_ALU1_DA);
    @(negedge clk);
        `assert(uut.proc.aluA, 'h09);
        `assert(uut.proc.aluMode, ALU1_DA_H);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 1);
        `assert(uut.proc.register, 'h10);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h10, 'h09);
        `assertRegister('h11, 'h01);
        `assertFlags(FLAG_D | FLAG_H);


	chk_ld_r_IM(4'h1, 8'h09,
	            8'h11);
        `assertRegister('h10, 'h09);
        `assertRegister('h11, 'h09);

	chk_alu2_r_r(ALU2_ADD, 0, 1,
	             8'h10, 8'h12, FLAG_H);

// da 10
    repeat (3) @(negedge clk);
        `assertState(STATE_DECODE);
        `assertInstr('h40);
        `assertSecond('h10);
    @(negedge clk);
        `assertState(STATE_ALU1_OP);
        `assert(uut.proc.register, 'h10);
    @(negedge clk);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h10, 'h18);
        `assertRegister('h11, 'h09);
        // h
        `assertFlags('b0000_0100);


	chk_alu2_r_r(ALU2_SUB, 0, 1,
	             8'h10, 8'h0F, 8'b0000_1100); // dh

// da 10
    repeat (3) @(negedge clk);
        `assertState(STATE_DECODE);
        `assertInstr('h40);
        `assertSecond('h10);
    @(negedge clk);
        `assertState(STATE_ALU1_OP);
        `assert(uut.proc.register, 'h10);
    @(negedge clk);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h10, 'h09);
        `assertRegister('h11, 'h09);
        // hd
        `assertFlags('b0000_1100);


	chk_ld_r_IM(4'h0, 8'h15,
	            8'h10);
	chk_ld_r_IM(4'h1, 8'h87,
	            8'h11);
        `assertRegister('h10, 'h15);
        `assertRegister('h11, 'h87);

	chk_alu2_r_r(ALU2_ADD, 0, 1,
	             8'h10, 8'h9C, 8'b0010_0000); // s

// da 10
    repeat (3) @(negedge clk);
        `assertState(STATE_DECODE);
        `assertInstr('h40);
        `assertSecond('h10);
    @(negedge clk);
        `assertState(STATE_ALU1_OP);
        `assert(uut.proc.register, 'h10);
    @(negedge clk);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h10, 'h02);
        `assertRegister('h11, 'h87);
        // ch
        `assertFlags('b1000_0000);


	chk_alu2_r_r(ALU2_SUB, 0, 1,
	             8'h10, 8'h7B, 8'b1000_1100); // cdh

// da 10
    repeat (3) @(negedge clk);
        `assertInstr('h40);
        `assertSecond('h10);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assert(uut.proc.aluMode, ALU1_DA);
        `assert(uut.proc.register, 'h10);
        `assertState(STATE_ALU1_OP);
    @(negedge clk);
        `assert(uut.proc.aluMode, ALU1_DA);
        `assert(uut.proc.aluA, 'h7B);
        `assertFlags('b1000_1100);
        `assert(uut.proc.register, 'h10);
        `assertState(STATE_ALU1_DA);
    @(negedge clk);
        `assert(uut.proc.aluMode, ALU1_DA_H);
        `assert(uut.proc.aluA, 'h75);
        `assertFlags('b1000_1100);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 1);
        `assert(uut.proc.register, 'h10);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h10, 'h15);
        `assertRegister('h11, 'h87);
        // dh
        `assertFlags('b1000_1100);


	chk_ld_r_IM(4'h0, 8'h00,
	            8'h10);
	chk_ld_r_IM(4'h1, 8'h01,
	            8'h11);
        `assertRegister('h10, 'h00);
        `assertRegister('h11, 'h01);

	chk_alu2_r_r(ALU2_SUB, 0, 1,
	             8'h10, 8'hFF, 8'b1011_1100); // c_sv dh__

// da 10
    repeat (3) @(negedge clk);
        `assertInstr('h40);
        `assertSecond('h10);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assert(uut.proc.aluMode, ALU1_DA);
        `assert(uut.proc.register, 'h10);
        `assertState(STATE_ALU1_OP);
    @(negedge clk);
        `assert(uut.proc.aluMode, ALU1_DA);
        `assert(uut.proc.aluA, 'hFF);
        `assertFlags('b1011_1100);
        `assert(uut.proc.register, 'h10);
        `assertState(STATE_ALU1_DA);
    @(negedge clk);
        `assert(uut.proc.aluMode, ALU1_DA_H);
        `assert(uut.proc.aluA, 'hF9);
        `assertFlags('b1011_1100);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 1);
        `assert(uut.proc.register, 'h10);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h10, 'h99);
        `assertRegister('h11, 'h01);
        // dh
        `assertFlags('b1011_1100);


	chk_alu2_r_r(ALU2_ADD, 0, 1,
	             8'h10, 8'h9A, 8'b0010_0000); // s

// da 10
    repeat (3) @(negedge clk);
        `assertState(STATE_DECODE);
        `assertInstr('h40);
        `assertSecond('h10);
    @(negedge clk);
        `assertState(STATE_ALU1_OP);
        `assert(uut.proc.register, 'h10);
    @(negedge clk);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h10, 'h00);
        `assertRegister('h11, 'h01);
        // cz__ ____
        `assertFlags('b1100_0000);


	chk_jp(16'h000C);
