    @(negedge clk);
// scf
    repeat (2) @(negedge clk);
        `assertInstr('hDF);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
        // c
        `assertFlags('b1000_0000);
    @(negedge clk);

// rcf
    repeat (2) @(negedge clk);
        `assertInstr('hCF);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
        // -c
        `assertFlags('b0000_0000);
    @(negedge clk);

// ccf
    repeat (2) @(negedge clk);
        `assertInstr('hEF);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
        // !c
        `assertFlags('b1000_0000);
    @(negedge clk);


// ccf
    repeat (2) @(negedge clk);
        `assertInstr('hEF);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
        // !c
        `assertFlags('b0000_0000);
    @(negedge clk);


// jmp L0
	chk_jp(16'h000C);

    #3
