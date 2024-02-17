	chk_ld_R_IM(P01M, 8'h92);

	chk_alu1(ALU1_CLR, SPH,
	         8'hFE, 8'h00, FLAG_NONE);
	chk_alu1(ALU1_CLR, SPL,
	         8'hFF, 8'h00, FLAG_NONE);

	chk_srp(7);

	chk_ld_r_IM(4'h0, 8'h03,
	            8'h70);

	chk_scf();

	chk_ld_R_IM(IMR, 8'h90);
	chk_ld_R_IM(IRQ, 8'h10);
	// isr
        `assertFetchState(FETCH_SECOND2);
        assertRegister(IMR, 8'h90);
    @(negedge clk);
		`assertOpType(OP_ISR);
		`assertOpState(0);
        assertRegister(IMR, 8'h10);
		`assertPc(16'h001F);
		`assert(uut.proc.sp, 16'h0000);
		`assert(uut.proc.canFetch, 0);
    @(negedge clk);
		`assertOpState(1);
		`assertPc(16'h001E);
		`assert(uut.proc.sp, 16'hFFFF);
    @(negedge clk);
        `assert(uut.proc.aluA, 8'h1E);
        `assert(uut.proc.addr, 16'hFFFF);
		`assert(uut.proc.writeMem, 1);
		`assert(uut.proc.sp, 16'hFFFE);
		`assertOpState(2);
    @(negedge clk);
        `assertRam(16'hFFFF, 8'h1E);

        `assert(uut.proc.aluA, 8'h00);
        `assert(uut.proc.addr, 16'hFFFE);
		`assert(uut.proc.writeMem, 1);
		`assert(uut.proc.sp, 16'hFFFD);
		`assertOpState(3);
    @(negedge clk);
        `assertRam(16'hFFFF, 8'h1E);
        `assertRam(16'hFFFE, 8'h00);

        `assert(uut.proc.aluA, FLAG_C);
        `assert(uut.proc.addr, 16'hFFFD);
    	`assert(uut.proc.writeMem, 1);
		`assertOpState(4);
    @(negedge clk);
        `assertRam(16'hFFFF, 8'h1E); // PCL
        `assertRam(16'hFFFE, 8'h00); // PCH
        `assertRam(16'hFFFD, FLAG_C); // FLAGS

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
        `assert(uut.proc.pc, 16'h0021);
//    $display("here");
		`assert(uut.proc.canFetch, 1);
        assertRegister(IRQ, 8'h00);
        assertRegister(IMR, 8'h10);
        chk_fetch();
	//$display("pc=%h fS=%h oT=%h oS=%h", uut.proc.pc, uut.proc.fetchState, uut.proc.opType, uut.proc.opState);

	chk_alu1(ALU1_DEC, 8'h70,
	         8'h70, 8'h02, FLAG_C); // kept

	chk_rcf();

	chk_iret_extern(16'h001E, 16'h0000, FLAG_C);
        assertRegister(IRQ, 8'h00);
        assertRegister(IMR, 8'h90);

// jr L0
	chk_nop();

	chk_jr(8'hFD,
	       16'h001E);
