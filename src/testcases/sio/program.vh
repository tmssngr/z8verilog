`include "alu.vh"
`include "assembly.vh"
`include "sfr.vh"

localparam L0_ = 16'h001b;
localparam L1_ = 16'h0020;

initial begin
	default_interrupt_vectors();

	asm_ld_R_IM(P3M, 8'b0100_0000);
	asm_ld_R_IM(T0, 1);
	asm_ld_R_IM(PRE0, {6'h1, 2'b01});
	asm_ld_R_IM(TMR, 8'b0000_0011);

	asm_ld_R_IM(SIO, 8'hA5);

label(L0_);
	asm_alu2_R_IM(ALU2_TM, IRQ, 8'b0001_0000);
	asm_jr(JC_Z, L0_);

label(L1_);
	asm_jr(JC_ALWAYS, L1_);
end
