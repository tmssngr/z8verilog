    @(negedge clk);

	chk_srp(7);

// jr never, 0
    repeat (3) @(negedge clk);
        `assertInstr('h0B);
        `assertSecond('hFC);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
        `assertPc('h0010);
    @(negedge clk);


	chk_ld_r_IM(4'h0, 8'h03,
	            8'h70);

// L1: add 70, #ff
	chk_alu2_R_IM(ALU2_ADD, 8'h70, 8'hFF,
	              .expDst(8'h70), .expResult(8'h02), .expFlags(8'b1000_0100)); // ch

// jr nz, L1
    repeat (3) @(negedge clk);
        `assertInstr('hEB);
        `assertSecond('hFB);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
        `assertPc('h0012);
    @(negedge clk);

// L1: add 0, #ff
	chk_alu2_R_IM(ALU2_ADD, 8'h70, 8'hFF,
	              .expDst(8'h70), .expResult(8'h01), .expFlags(8'b1000_0100)); // ch

// jr nz, L1
    repeat (3) @(negedge clk);
        `assertInstr('hEB);
        `assertSecond('hFB);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
        `assertPc('h0012);
    @(negedge clk);

// L1: add 0, #ff
	chk_alu2_R_IM(ALU2_ADD, 8'h70, 8'hFF,
	              .expDst(8'h70), .expResult(8'h00), .expFlags(8'b1100_0100)); // czh

// jr nz, L1
    repeat (3) @(negedge clk);
        `assertInstr('hEB);
        `assertSecond('hFB);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
        `assertPc('h0017);
    @(negedge clk);

// jr L0
    repeat (3) @(negedge clk);
        `assertInstr('h8B);
        `assertSecond('hF3);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
        `assertPc('h000C);

    #3
