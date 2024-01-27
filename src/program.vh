`ifdef BENCH

localparam L0_ = 16'h000C;
localparam L1_ = 16'h0012;

initial begin
	default_interrupt_vectors();

label(L0_);
	asm_srp('h00);
	asm_ld_r_IM(4, 5);
	asm_ld_r_IM(2, 8'b1);

label(L1_);
	asm_rl('hE2);
	asm_djnz(4, L1_);

	asm_jr(JC_ALWAYS, L0_);
end

`else
initial begin
`include "memory.txt"
end
`endif
