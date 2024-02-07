    @(negedge clk);

    chk_scf();

    chk_rcf();

    chk_ccf(1);

    chk_ccf(0);

	chk_jp(16'h000C);
