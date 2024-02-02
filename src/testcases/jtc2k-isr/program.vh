localparam M_000C = 16'h000C;
localparam M_0AEB = 16'h001D;
localparam M_0AFD = 16'h002F;
localparam M_0B00 = 16'h0032;
localparam M_0B02 = 16'h0034;
localparam M_0B27 = 16'h0059;

initial begin
	default_interrupt_vectors();

label(M_000C);
	asm_srp(8'h50);
	asm_ld_R_IM(P01M, 'h92); // external stack
	asm_ld_R_IM(SPH, 8'hFE);
	asm_alu1(ALU1_CLR, SPL);
	asm_ld_r_IM(5, 8'hFD);
	asm_ld_r_IM(4, 8'h40);
	asm_ld_R_IM(8'h6D, 0);

label(M_0AEB);
	asm_alu1(ALU1_SWAP, 8'h80);            // bug? 8 cycles
	asm_alu2_R_IM(ALU2_OR, 8'h03, 8'h80);  // P37 = 1, 10 cycles = 2.5us
	asm_alu2_R_IM(ALU2_AND, 8'h03, 8'h7F); // P37 = 0, -"-
	asm_alu2_R_IM(ALU2_TM, 8'h6D, 8'h80);  // 10 cycles
	asm_jr(JC_Z, M_0AFD);                  // 12 cycles
	asm_alu2_R_IM(ALU2_XOR, 8'h03, 8'h40); // 10 cycles
	asm_jr(JC_ALWAYS, M_0B02);             // 12 cycles

label(M_0AFD);
	asm_alu2_R_IM(ALU2_AND, 8'h03, 8'h3F); // P36 = P37 = 0; 10 cycles

label(M_0B00);
	asm_jr(JC_NEVER, M_0B00);              // 10 cycles

label(M_0B02);
	asm_jr(JC_NEVER, M_0B02);              // -"-
	asm_nop();                             // 6 cycles
	asm_pop(8'h80);                        // 10 cycles, read FE00
	asm_nop();                             // 6 cycles
	asm_pop(8'h80);                        // 10 cycles, read FE01
	asm_nop();                             // 6 cycles
	asm_pop(8'h80);                        // 10 cycles, read FE02
	asm_nop();                             // 6 cycles
	asm_pop(8'h80);                        // 10 cycles, read FE03
	asm_nop();                             // 6 cycles
	asm_pop(8'h80);                        // 10 cycles, read FE04
	asm_nop();                             // 6 cycles
	asm_pop(8'h80);                        // 10 cycles, read FE05
	asm_nop();                             // 6 cycles
	asm_pop(8'h80);                        // 10 cycles, read FE06
	asm_nop();                             // 6 cycles
	asm_pop(8'h80);                        // 10 cycles, read FE07
	asm_inc_r(5);
	asm_jr(JC_Z, M_0B27);
	asm_alu2_R_IM(ALU2_SUB, SPL, 8);
	asm_alu2_R_IM(ALU2_SBC, SPH, 0);
	asm_jr(JC_ALWAYS, M_0AEB);             // 1 loop is 256 cycles = 64us
	                                       // 3 loops per row
label(M_0B27);
	asm_ld_r_IM(5, 8'hFD);
	asm_nop();                             // 6 cycles
	asm_nop();
	asm_djnz(4, M_0AEB);

	asm_jp(JC_ALWAYS, M_000C);
end
