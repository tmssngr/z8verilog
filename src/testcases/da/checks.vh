// srp #10
    repeat (4) @(negedge clk);
        `assertState(STATE_DECODE);
        `assertInstr('h31);
        `assertSecond('h10);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assert(uut.proc.rp, 'h1);

// ld r0, #9
    repeat (3) @(negedge clk);
        `assertState(STATE_DECODE);
        `assertInstr('h0C);
        `assertSecond('h09);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h10, 'h09);

// ld r1, #1
    repeat (3) @(negedge clk);
        `assertState(STATE_DECODE);
        `assertInstr('h1C);
        `assertSecond('h01);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h10, 'h09);
        `assertRegister('h11, 'h01);

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

// ld r1, #9
    repeat (3) @(negedge clk);
        `assertState(STATE_DECODE);
        `assertInstr('h1C);
        `assertSecond('h09);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
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

// ld r0, #15
    repeat (3) @(negedge clk);
        `assertState(STATE_DECODE);
        `assertInstr('h0C);
        `assertSecond('h15);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h10, 'h15);

// ld r1, #87
    repeat (3) @(negedge clk);
        `assertState(STATE_DECODE);
        `assertInstr('h1C);
        `assertSecond('h87);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
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

// ld r0, #00
    repeat (3) @(negedge clk);
        `assertState(STATE_DECODE);
        `assertInstr('h0C);
        `assertSecond('h00);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h10, 'h00);

// ld r1, #01
    repeat (3) @(negedge clk);
        `assertState(STATE_DECODE);
        `assertInstr('h1C);
        `assertSecond('h01);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
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
    repeat (5) @(negedge clk);
        `assertState(STATE_DECODE);
        `assertInstr('h8D);
        `assertSecond('h00);
        `assertThird('h0C);
    repeat (1) @(negedge clk);
        `assertPc('h000C);

    #3
