localparam L0_ = 16'h000C;

initial begin
    default_interrupt_vectors();

label(L0_);
    asm_srp('h20);
    asm_ld_r_IM(0, 9);
    asm_ld_R_R('hE1, 'hE0);
    asm_ld_r_IM(1, 8'h22);
    asm_ld_IR_R(8'hE1, 8'hE0);
    asm_ld_R_IR(8'hE1, 8'hE1);

    asm_ld_r_IM(1, 8'h80);
    asm_ld_r_R(2, 8'h21);
    asm_ld_R_r(8'h30, 0);

	asm_ld_r_IM(0, 8'h30);
    asm_ld_r_Ir(3, 0);
    asm_ld_Ir_r(0, 1);

    asm_ld_IR_IM(8'hE0, 8'hFF);

    asm_ld_r_IrX(4'h4, 4'h0, 8'h00);
    asm_ld_r_IrX(4'h4, 4'h0, 8'hF0);

    asm_jp(JC_ALWAYS, L0_);
end
