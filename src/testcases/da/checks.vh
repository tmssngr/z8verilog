    @(negedge clk);

	chk_srp(1);

	chk_ld_r_IM(4'h0, 8'h09,
	            8'h10);

	chk_ld_r_IM(4'h1, 8'h01,
	            8'h11);

// add r0, r1
    repeat (3) @(negedge clk);
        `assertState(STATE_DECODE);
        `assertInstr('h02);
        `assertSecond('h01);
    @(negedge clk);
        `assertState(STATE_ALU2_OP);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h10, 'h0A);
        `assertRegister('h11, 'h01);
        `assertFlags('b0000_0000);

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
        `assertFlags('b0000_0000);
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
        `assertFlags('b0000_0000);


// sub r0, r1
    repeat (3) @(negedge clk);
        `assertState(STATE_DECODE);
        `assertInstr('h22);
        `assertSecond('h01);
    @(negedge clk);
        `assertState(STATE_ALU2_OP);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h10, 'h0F);
        `assertRegister('h11, 'h01);
        // dh
        `assertFlags('b0000_1100);

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
        `assertFlags('b0000_1100);
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
        // dh
        `assertFlags('b0000_1100);


	chk_ld_r_IM(4'h1, 8'h09,
	            8'h11);
        `assertRegister('h10, 'h09);
        `assertRegister('h11, 'h09);

// add r0, r1
    repeat (3) @(negedge clk);
        `assertState(STATE_DECODE);
        `assertInstr('h02);
        `assertSecond('h01);
    @(negedge clk);
        `assertState(STATE_ALU2_OP);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h10, 'h12);
        `assertRegister('h11, 'h09);
        // h
        `assertFlags('b0000_0100);

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


// sub r0, r1
    repeat (3) @(negedge clk);
        `assertState(STATE_DECODE);
        `assertInstr('h22);
        `assertSecond('h01);
    @(negedge clk);
        `assertState(STATE_ALU2_OP);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h10, 'h0F);
        `assertRegister('h11, 'h09);
        // hd
        `assertFlags('b0000_1100);

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

// add r0, r1
    repeat (3) @(negedge clk);
        `assertState(STATE_DECODE);
        `assertInstr('h02);
        `assertSecond('h01);
    @(negedge clk);
        `assertState(STATE_ALU2_OP);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h10, 'h9C);
        `assertRegister('h11, 'h87);
        // s
        `assertFlags('b0010_0000);

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


// sub r0, r1
    repeat (3) @(negedge clk);
        `assertState(STATE_DECODE);
        `assertInstr('h22);
        `assertSecond('h01);
    @(negedge clk);
        `assertState(STATE_ALU2_OP);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h10, 'h7B);
        `assertRegister('h11, 'h87);
        // hd
        `assertFlags('b1000_1100);

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

// sub r0, r1
    repeat (3) @(negedge clk);
        `assertState(STATE_DECODE);
        `assertInstr('h22);
        `assertSecond('h01);
    @(negedge clk);
        `assertState(STATE_ALU2_OP);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
    @(negedge clk);
        `assertRegister('h10, 'hFF);
        `assertRegister('h11, 'h01);
        // c_sv dh__
        `assertFlags('b1011_1100);

// da 10
    repeat (2) @(negedge clk);
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

// add r0, r1
    repeat (3) @(negedge clk);
        `assertState(STATE_DECODE);
        `assertInstr('h02);
        `assertSecond('h01);
    @(negedge clk);
        `assertState(STATE_ALU2_OP);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h10, 'h9A);
        `assertRegister('h11, 'h01);
        // s
        `assertFlags('b0010_0000);

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

// jmp L0
	chk_jp(16'h000C);

    #3
