	chk_srp(7);

	chk_ld_r_IM(4'h0, 8'h03,
	            8'h70);
	chk_ld_R_IM(SPL, 8'h80);
	chk_ld_R_IM(IMR, 8'h90);
	chk_ld_R_IM(IRQ, 8'h10);
	// isr
        `assertFetchState(FETCH_SECOND2);
        assertRegister(IMR, 8'h90);
    @(negedge clk);
		`assertOpType(OP_ISR);
		`assertOpState(0);
        assertRegister(IMR, 8'h10);
		`assertPc(16'h001B);
		`assert(uut.proc.sp, 16'h80);
		`assert(uut.proc.canFetch, 0);
    @(negedge clk);
		`assertOpState(1);
		`assertPc(16'h0019);
		`assert(uut.proc.sp, 16'h7F);
    @(negedge clk);
        `assert(uut.proc.register, 8'h7F);
        `assert(uut.proc.writeRegister, 1);
		`assertOpState(2);
    @(negedge clk);
        `assertRegister(8'h7F, 8'h19);

        `assert(uut.proc.register, 8'h7E);
        `assert(uut.proc.writeRegister, 1);
		`assertOpState(3);
    @(negedge clk);
        `assertRegister(8'h7F, 8'h19);
        `assertRegister(8'h7E, 8'h00);

        `assert(uut.proc.register, 8'h7D);
        `assert(uut.proc.writeRegister, 1);
		`assertOpState(4);
    @(negedge clk);
        `assertRegister(8'h7F, 8'h19); // PCL
        `assertRegister(8'h7E, 8'h00); // PCH
        `assertRegister(8'h7D, 8'h00); // FLAGS

		`assert(uut.proc.addr, 16'h0008);
        `assert(uut.proc.readMem, 1);
		`assertOpState(5);
    @(negedge clk);
        `assert(uut.proc.readMem, 1);
		`assertOpState(6);
    @(negedge clk);
        `assert(uut.proc.pc[15:8], 8'h00);
		`assert(uut.proc.addr, 16'h0009);

        `assert(uut.proc.readMem, 1);
		`assertOpState(7);
    @(negedge clk);
        `assert(uut.proc.readMem, 1);
		`assertOpState(8);
    @(negedge clk);
        `assert(uut.proc.pc, 16'h001B);
		`assert(uut.proc.canFetch, 1);
        assertRegister(IRQ, 8'h00);
        assertRegister(IMR, 8'h10);
        chk_fetch();
	//$display("pc=%h fS=%h oT=%h oS=%h", uut.proc.pc, uut.proc.fetchState, uut.proc.opType, uut.proc.opState);

	chk_alu1(ALU1_DEC, 8'h70,
	         8'h70, 8'h02, FLAG_NONE);

	chk_iret_intern(16'h0019, 8'h80, FLAG_NONE);
        assertRegister(IMR, 8'h90);

// jr L0
	chk_jr(8'hFE,
	       16'h0019);
