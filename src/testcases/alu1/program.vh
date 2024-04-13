`include "alu.vh"
`include "assembly.vh"

localparam L0_ = 16'h0C;

initial begin
	default_interrupt_vectors();

label(L0_);
	asm_srp('h10);
	asm_ld_r_IM(0, 9);
	asm_ld_r_IM(1, 8'h10);
	asm_alu1(ALU1_SWAP, 8'hE0);
	asm_alu1_IR(ALU1_SWAP, 8'hE1);

	// RR
	// 0000_1001 -> 1000_0100
	asm_alu1(ALU1_RR, 8'hE0);

	// SRA
	// 1000_0100 -> 1100_0010
	asm_alu1(ALU1_SRA, 8'hE0);

	// RRC
	// 1100_0010 -> 0110_0001
	asm_alu1(ALU1_RRC, 8'hE0);
	// 0110_0001 -> 0011_0000
	asm_alu1(ALU1_RRC, 8'hE0);
	// 0011_0000 -> 1001_1000
	asm_alu1(ALU1_RRC, 8'hE0);

	// COM
	// 1001_1000 -> 0110_0111
	asm_alu1(ALU1_COM, 8'hE0);

	// RL
	// 0110_0111 -> 1100_1110
	asm_alu1(ALU1_RL, 8'hE0);
	// 1100_1110 -> 1001_1101
	asm_alu1(ALU1_RL, 8'hE0);

	// RLC
	// 1001_1101 -> 0011_1011
	asm_alu1(ALU1_RLC, 8'hE0);
	// 0011_1011 -> 0111_0111
	asm_alu1(ALU1_RLC, 8'hE0);
	// 0111_0111 -> 1110_1110
	asm_alu1(ALU1_RLC, 8'hE0);

	asm_jp(JC_ALWAYS, L0_);
end
