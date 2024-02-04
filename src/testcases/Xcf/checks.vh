    @(negedge clk);
// scf
	chk_1byteOp(8'hDF);
        `assertState(STATE_FETCH_INSTR);
        // c
        `assertFlags(FLAG_C);
    @(negedge clk);

// rcf
	chk_1byteOp(8'hCF);
        `assertState(STATE_FETCH_INSTR);
        // -c
        `assertFlags(FLAG_NONE);
    @(negedge clk);

// ccf
	chk_1byteOp(8'hEF);
        `assertState(STATE_FETCH_INSTR);
        // !c
        `assertFlags(FLAG_C);
    @(negedge clk);


// ccf
	chk_1byteOp(8'hEF);
        `assertState(STATE_FETCH_INSTR);
        // !c
        `assertFlags(FLAG_NONE);
    @(negedge clk);


	chk_jp(16'h000C);
