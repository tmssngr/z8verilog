    @(negedge clk);
// scf
	chk_1byteOp(8'hDF);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
        // c
        `assertFlags(FLAG_C);
    @(negedge clk);

// rcf
	chk_1byteOp(8'hCF);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
        // -c
        `assertFlags(FLAG_NONE);
    @(negedge clk);

// ccf
	chk_1byteOp(8'hEF);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
        // !c
        `assertFlags(FLAG_C);
    @(negedge clk);


// ccf
	chk_1byteOp(8'hEF);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
        // !c
        `assertFlags(FLAG_NONE);
    @(negedge clk);


	chk_jp(16'h000C);
