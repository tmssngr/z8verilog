localparam L0_ = 16'h0C;
localparam L1_ = 16'h26;

initial begin
	default_interrupt_vectors();

label(L0_);
	asm_ld_R_IM(P01M, 'h92); // external stack
	asm_clr(SPH);
	asm_clr(SPL);

	asm_call(L1_);
	asm_ld_r_IM(0, L0_ >> 8);
	asm_ld_r_IM(1, L0_);
	asm_ld_r_IM(2, 'hA5);
	asm_push('hE1);
	asm_push('hE0);
	asm_push('hE2);
	asm_iret();
	asm_jp(JC_ALWAYS, L0_);

label(L1_);
	asm_srp('h20);
	asm_ret();
end
