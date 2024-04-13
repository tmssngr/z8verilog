`include "alu.vh"
`include "assembly.vh"
`include "sfr.vh"

localparam L0_ = 16'h001b;

initial begin
	default_interrupt_vectors();

	asm_ld_R_IM(T1, 3);
	asm_ld_R_IM(PRE1, {6'h1, 2'b01});
	asm_ld_R_IM(T0, 4);
	asm_ld_R_IM(PRE0, {6'h2, 2'b01});
	asm_ld_R_IM(TMR, 8'b0000_1111);

label(L0_);
	asm_jp(JC_ALWAYS, L0_);
end
