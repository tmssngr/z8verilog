	// T1
	chk_ld_R_IM_noRegCheck(8'hF2, 8'h03);
		`assert(uut.proc.t1load, 3);

	// PRE1 = 1, continues
	chk_ld_R_IM_noRegCheck(8'hF3, 8'b0000_0101);
		`assert(uut.proc.pre1, 8'h5);

	// T0
	chk_ld_R_IM_noRegCheck(8'hF4, 8'h04);
		`assert(uut.proc.t0load, 4);

	// PRE0 = 2, continues
	chk_ld_R_IM_noRegCheck(8'hF5, 8'b0000_1001);
		`assert(uut.proc.pre0, 8'h9);

	// TMR
	chk_ld_R_IM_noRegCheck(8'hF1, 8'b0000_1111);
		`assert(uut.proc.tmr, 8'b0000_1010);
		`assert(uut.proc.pre1counter, 9'b0_000001_01);
		`assert(uut.proc.t1counter, 3);
		`assert(uut.proc.pre0counter, 9'b0_000010_01);
		`assert(uut.proc.t0counter, 4);
		`assert(uut.proc.irq, 0);
		@(negedge clk);
		`assert(uut.proc.pre1counter, 9'b0_000001_00);
		`assert(uut.proc.t1counter, 3);
		`assert(uut.proc.pre0counter, 9'b0_000010_00);
		`assert(uut.proc.t0counter, 4);
		`assert(uut.proc.irq, 0);
		@(negedge clk);
		`assert(uut.proc.pre1counter, 9'b0_000001_11);
		`assert(uut.proc.t1counter, 2);
		`assert(uut.proc.pre0counter, 9'b0_000001_11);
		`assert(uut.proc.t0counter, 4);
		`assert(uut.proc.irq, 0);
		repeat (3) @(negedge clk);
		`assert(uut.proc.pre1counter, 9'b0_000001_00);
		`assert(uut.proc.t1counter, 2);
		`assert(uut.proc.pre0counter, 9'b0_000001_00);
		`assert(uut.proc.t0counter, 4);
		`assert(uut.proc.irq, 0);
		@(negedge clk);
		`assert(uut.proc.pre1counter, 9'b0_000001_11);
		`assert(uut.proc.t1counter, 1);
		`assert(uut.proc.pre0counter, 9'b0_000010_11);
		`assert(uut.proc.t0counter, 3);
		`assert(uut.proc.irq, 0);
		repeat (3) @(negedge clk);
		`assert(uut.proc.pre1counter, 9'b0_000001_00);
		`assert(uut.proc.t1counter, 1);
		`assert(uut.proc.pre0counter, 9'b0_000010_00);
		`assert(uut.proc.t0counter, 3);
		`assert(uut.proc.irq, 0);
		@(negedge clk);
		`assert(uut.proc.pre1counter, 9'b0_000001_11);
		`assert(uut.proc.t1counter, 3);
		`assert(uut.proc.pre0counter, 9'b0_000001_11);
		`assert(uut.proc.t0counter, 3);
		`assert(uut.proc.irq, 8'h20); // IRQ4

		repeat (3) @(negedge clk);
		`assert(uut.proc.pre1counter, 9'b0_000001_00);
		`assert(uut.proc.t1counter, 3);
		`assert(uut.proc.pre0counter, 9'b0_000001_00);
		`assert(uut.proc.t0counter, 3);
		`assert(uut.proc.irq, 8'h20);
		@(negedge clk);
		`assert(uut.proc.pre1counter, 9'b0_000001_11);
		`assert(uut.proc.t1counter, 2);
		`assert(uut.proc.pre0counter, 9'b0_000010_11);
		`assert(uut.proc.t0counter, 2);
		`assert(uut.proc.irq, 8'h20);

		repeat (3) @(negedge clk);
		`assert(uut.proc.pre1counter, 9'b0_000001_00);
		`assert(uut.proc.t1counter, 2);
		`assert(uut.proc.pre0counter, 9'b0_000010_00);
		`assert(uut.proc.t0counter, 2);
		`assert(uut.proc.irq, 8'h20);
		@(negedge clk);
		`assert(uut.proc.pre1counter, 9'b0_000001_11);
		`assert(uut.proc.t1counter, 1);
		`assert(uut.proc.pre0counter, 9'b0_000001_11);
		`assert(uut.proc.t0counter, 2);
		`assert(uut.proc.irq, 8'h20);

		repeat (3) @(negedge clk);
		`assert(uut.proc.pre1counter, 9'b0_000001_00);
		`assert(uut.proc.t1counter, 1);
		`assert(uut.proc.pre0counter, 9'b0_000001_00);
		`assert(uut.proc.t0counter, 2);
		`assert(uut.proc.irq, 8'h20);
		@(negedge clk);
		`assert(uut.proc.pre1counter, 9'b0_000001_11);
		`assert(uut.proc.t1counter, 3);
		`assert(uut.proc.pre0counter, 9'b0_000010_11);
		`assert(uut.proc.t0counter, 1);
		`assert(uut.proc.irq, 8'h20);

		repeat (3) @(negedge clk);
		`assert(uut.proc.pre1counter, 9'b0_000001_00);
		`assert(uut.proc.t1counter, 3);
		`assert(uut.proc.pre0counter, 9'b0_000010_00);
		`assert(uut.proc.t0counter, 1);
		`assert(uut.proc.irq, 8'h20);
		@(negedge clk);
		`assert(uut.proc.pre1counter, 9'b0_000001_11);
		`assert(uut.proc.t1counter, 2);
		`assert(uut.proc.pre0counter, 9'b0_000001_11);
		`assert(uut.proc.t0counter, 1);
		`assert(uut.proc.irq, 8'h20);

		repeat (3) @(negedge clk);
		`assert(uut.proc.pre1counter, 9'b0_000001_00);
		`assert(uut.proc.t1counter, 2);
		`assert(uut.proc.pre0counter, 9'b0_000001_00);
		`assert(uut.proc.t0counter, 1);
		`assert(uut.proc.irq, 8'h20);
		@(negedge clk);
		`assert(uut.proc.pre1counter, 9'b0_000001_11);
		`assert(uut.proc.t1counter, 1);
		`assert(uut.proc.pre0counter, 9'b0_000010_11);
		`assert(uut.proc.t0counter, 4);
		`assert(uut.proc.irq, 8'h30); // +IRQ5

		@(negedge clk);
		@(negedge clk);


//	chk_jp(16'h001B);
