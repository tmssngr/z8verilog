localparam L0_ = 16'h0C;
localparam L1_ = 16'h13;
localparam L2_ = 16'h20;

initial begin
	default_interrupt_vectors();

label(L0_);
	asm_srp(8'h20);

	asm_jp(JC_NEVER, 16'hFFFE);

	asm_ld_r_IM(0, 3);

label(L1_);
	asm_add_R_IM(8'h20, 8'hFF);
	asm_jp(JC_NZ, L1_);

	asm_ld_r_IM(0, L2_ >> 8);
	asm_ld_r_IM(1, L2_);
	asm_jp_IRR(8'hE0);

	asm_nop();

label(L2_);
	asm_jp(JC_ALWAYS, L0_);
end
