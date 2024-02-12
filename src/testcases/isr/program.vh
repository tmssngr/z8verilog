localparam L1_ = 16'h0019;
localparam ISR = 16'h001B;

initial begin
	asm2('h8, 0); // IRQ0
	asm2('h8, 3); // IRQ1
	asm2('h8, 6); // IRQ2
	asm2('h8, 9); // IRQ3
	asm2(ISR[15:8], ISR[7:0]); // IRQ4
	asm2('h8, 'hF); // IRQ5

	asm_srp(8'h70);
	asm_ld_r_IM(0, 3);

	asm_ld_R_IM(SPL, 8'h80);
	asm_ld_R_IM(IMR, 8'h90);
	asm_ld_R_IM(IRQ, 8'h10);

label(L1_);
	asm_jr(JC_ALWAYS, L1_);

label(ISR);
	asm_alu1(ALU1_DEC, 8'h70);
	asm_iret();
end
