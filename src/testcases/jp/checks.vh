    @(negedge clk);

    chk_srp(2);

// jp never, 0
	chk_jp_false(JC_NEVER, 16'hFFFE);

	chk_ld_r_IM(4'h0, 8'h03,
	            8'h20);

// L1: add 0, #FF
	chk_alu2_R_IM(ALU2_ADD, 8'h20, 8'hFF,
	              .expDst(8'h20), .expResult(8'h02), .expFlags(8'b1000_0100)); // ch

// jp nz, L1
	chk_jp_true(JC_NZ, 16'h0013);

// L1: add 0, #FF
	chk_alu2_R_IM(ALU2_ADD, 8'h20, 8'hFF,
	              .expDst(8'h20), .expResult(8'h01), .expFlags(8'b1000_0100)); // ch

	chk_jp_true(JC_NZ, 16'h0013);

// L1: add 0, #FF
	chk_alu2_R_IM(ALU2_ADD, 8'h20, 8'hFF,
	              .expDst(8'h20), .expResult(8'h00), .expFlags(8'b1100_0100)); // czh

	chk_jp_false(JC_NZ, 16'h0013);


	chk_ld_r_IM(4'h0, 8'h00,
	            8'h20);

	chk_ld_r_IM(4'h1, 8'h20,
	            8'h21);

// jp @r0
    repeat (3) @(negedge clk);
        `assertInstr('h30);
        `assertSecond('he0);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_JP1);
    @(negedge clk);
        `assert(uut.proc.addr[15:8], 8'h00);
        `assertState(STATE_JP2);
    @(negedge clk);
        `assert(uut.proc.addr, 16'h0020);
        `assertState(STATE_JP3);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertPc(16'h0020);


	chk_jp(16'h000C);
