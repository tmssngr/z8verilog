localparam L0_ = 16'h0C;
localparam L1_ = 16'h2E;

initial begin
	default_interrupt_vectors();

label(L0_);
	asm_ld_R_IM(P01M, 'h92); // external stack
	asm_alu1(ALU1_CLR, SPH);
	asm_alu1(ALU1_CLR, SPL);

	asm_call(L1_);

	asm_ld_r_IM(0, L1_ >> 8);
	asm_ld_r_IM(1, L1_);
	asm_call_IRR(8'hE0);

	asm_ld_r_IM(0, L0_ >> 8);
	asm_ld_r_IM(1, L0_);
	asm_ld_r_IM(2, 'hA5);
	asm_push('hE1);
	asm_push('hE0);
	asm_push('hE2);
	asm_ldc_r_Irr(2, 0);
	asm_iret();
	asm_jp(JC_ALWAYS, L0_);

label(L1_);
	asm_srp('h20);
	asm_ret();
end
