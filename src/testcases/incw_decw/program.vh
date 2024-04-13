`include "alu.vh"
`include "assembly.vh"

localparam L0_ = 16'h0C;

initial begin
	default_interrupt_vectors();

label(L0_);
	asm_ld_R_IM(8'h10, 1);
	asm_ld_R_IM(8'h11, 2);
	asm_alu1(ALU1_INCW, 8'h10);
	asm_alu1(ALU1_DECW, 8'h10);

	asm_ld_R_IM(8'h11, 8'h7F);
	asm_alu1(ALU1_INCW, 8'h10);
	asm_alu1(ALU1_DECW, 8'h10);

	asm_ld_R_IM(8'h11, 8'hFF);
	asm_alu1(ALU1_INCW, 8'h10);
	asm_alu1(ALU1_DECW, 8'h10);

	asm_ld_R_IM(8'h10, 8'hFF);
	asm_alu1(ALU1_INCW, 8'h10);
	asm_alu1(ALU1_INCW, 8'h10);
	asm_alu1(ALU1_DECW, 8'h10);
	asm_alu1(ALU1_DECW, 8'h10);

	asm_ld_R_IM(8'h12, 8'h10);
	asm_alu1_IR(ALU1_INCW, 8'h12);
	asm_alu1_IR(ALU1_DECW, 8'h12);

	asm_jp(JC_ALWAYS, L0_);
end
