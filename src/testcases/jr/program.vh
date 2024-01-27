localparam L0_ = 16'h000C;
localparam L1_ = 16'h0012;

initial begin
	default_interrupt_vectors();

label(L0_);
	asm_srp(8'h70);
	asm_jr(JC_NEVER, L0_);

	asm_ld_r_IM(0, 3);

label(L1_);
	asm_add_R_IM(8'h70, 8'hFF);
	asm_jr(JC_NZ, L1_);

	asm_jr(JC_ALWAYS, L0_);
end
