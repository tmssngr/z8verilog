    @(negedge clk);
// scf
    repeat (2) @(negedge clk);
        `assertInstr('hDF);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
        // c
        `assertFlags(FLAG_C);
    @(negedge clk);

// rcf
    repeat (2) @(negedge clk);
        `assertInstr('hCF);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
        // -c
        `assertFlags(FLAG_NONE);
    @(negedge clk);

// ccf
    repeat (2) @(negedge clk);
        `assertInstr('hEF);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
        // !c
        `assertFlags(FLAG_C);
    @(negedge clk);


// ccf
    repeat (2) @(negedge clk);
        `assertInstr('hEF);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
        // !c
        `assertFlags(FLAG_NONE);
    @(negedge clk);


	chk_jp(16'h000C);
