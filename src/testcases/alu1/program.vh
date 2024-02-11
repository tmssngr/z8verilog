localparam L0_ = 16'h0C;

initial begin
	default_interrupt_vectors();

label(L0_);
	asm_srp('h10);
	asm_ld_r_IM(0, 9);
	asm_ld_r_IM(1, 8'h10);
	asm_alu1(ALU1_SWAP, 8'hE0);
	asm_alu1_IR(ALU1_SWAP, 8'hE1);

	asm_jp(JC_ALWAYS, L0_);
end
